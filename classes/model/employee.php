<?php defined('SYSPATH') or die('No direct script access.');

class Model_Employee extends Model
{

	private $id;
	private $employee;

	public function __construct($id)
	{
		parent::__construct();

		$this->prepared_select = $this->pdo->prepare('SELECT * FROM employees WHERE id = ?');
		$this->prepared_select->execute(array($id));
		$this->id = $id;
		if ( ! ($this->employee = $this->prepared_select->fetch(PDO::FETCH_ASSOC)))
		{
			throw new Kohana_Exception('Invalid employee ID');
		}
	}

	public function get($detail = FALSE)
	{
		$current_year = date('Y', time());

		if (substr($current_year, 2, 2) < substr($this->employee['SSN'], 0, 2)) $born_year = (substr($current_year, 0, 2) - 1).substr($this->employee['SSN'], 0, 2);
		else                                                                    $born_year = substr($current_year, 0, 2)      .substr($this->employee['SSN'], 0, 2);

		$age                             = $current_year - $born_year;
		$this->employee['soc_fee_level'] = 0; // Initial setting, will change if any matches are found further down

		foreach (Kohana::$config->load('larv.soc_fee_levels') as $level_data)
		{
			if ($level_data['start_age'] <= $age && $level_data['end_age'] >= $age) $this->employee['soc_fee_level'] = $level_data['level'];
		}

		if ($detail)
		{
			if (isset($this->employee[$detail])) return $this->employee[$detail];
			else                                 return FALSE;
		}
		else return $this->employee;
	}

	public static function new_employee($data)
	{
		$pdo = Kohana_pdo::instance();

		$columns = array();
		foreach ($pdo->query('DESCRIBE employees')->fetchAll(PDO::FETCH_ASSOC) as $row)
			if ($row['Field'] != 'id') $columns[] = $row['Field'];

		foreach ($data as $field => $value)
			if ( ! in_array($field, $columns)) unset($data[$field]);

		$sql = 'INSERT INTO employees (`'.implode('`,`', array_keys($data)).'`) VALUES(';
		foreach ($data as $field => $value) $sql .= $pdo->quote($value).',';
		$sql = substr($sql, 0, strlen($sql) - 1).')';

		$pdo->query($sql);

		return $pdo->lastInsertId();
	}

	public function set($data)
	{
		$columns = array_keys($this->employee);
		unset($columns[0]); // Remove ID from the index
		$sql = 'UPDATE employees SET ';
		$counter = 0;
		foreach ($data as $key => $value)
		{
			if (in_array($key, $columns))
			{
				$sql .= ' `'.$key.'` = '.$this->pdo->quote($value).',';
				$counter++;
			}
		}
		if ($counter > 0)
		{
			$sql = substr($sql, 0, strlen($sql) - 1);
			$sql .= ' WHERE id = '.$this->pdo->quote($this->id);
			$this->pdo->query($sql);
			$this->prepared_select->execute(array($this->id));
			$this->employee = $this->prepared_select->fetch(PDO::FETCH_ASSOC);
		}

		return TRUE;
	}

}
