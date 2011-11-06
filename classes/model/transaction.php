<?php defined('SYSPATH') or die('No direct script access.');

class Model_Transaction extends Model
{

	private $data;
	private $id;
	private static $prepared_insert; // PDO prepared insert object

	public function __construct($id = NULL, $data = NULL)
	{
		parent::__construct();

		if ($id === NULL && is_array($data))
		{
			if ($this->id = $this->add($data))
			{
				$this->data = $data;
			}
		}
		elseif ($id > 0)
		{
			if ($this->load_entry_data($id))
			{
				$this->id = preg_replace("/[^0-9]+/", '', $id);
			}
		}
	}

	/**
	 * Add transaction and return the new transaction id
	 *
	 * @param arr $data - array(
	 *                        'accounting_date' => 'YYYY-MM-DD',                OPTIONAL
	 *                        'transfer_date'   => 'YYYY-MM-DD',
	 *                        'description'     => 'text',                      OPTIONAL
	 *                        'journal_id'      => int or NULL                  OPTIONAL
	 *                        'vat'             => amount of money, 0 or above  OPTIONAL
	 *                        'sum'             => amount of money, above 0
	 *                        'employee_id'     => int or NULL                  OPTIONAL
	 *                    )
	 * @return int
	 **/
	private function add($data)
	{
		if ( ! isset($data['accounting_date'])) $data['accounting_date'] = $data['transfer_date'];
		if ( ! isset($data['description']))     $data['description']     = '';
		if ( ! isset($data['journal_id']))      $data['journal_id']      = NULL;
		if ( ! isset($data['vat']))             $data['vat']             = 0;
		if ( ! isset($data['employee_id']))     $data['employee_id']     = NULL;

		if (self::$prepared_insert == NULL)
		{
			self::$prepared_insert = $this->pdo->prepare('INSERT INTO transactions (accounting_date, transfer_date, description, journal_id, vat, sum, employee_id) VALUES(?,?,?,?,?,?,?)');
		}

		self::$prepared_insert->execute(array(
			$data['accounting_date'],
			$data['transfer_date'],
			$data['description'],
			$data['journal_id'],
			$data['vat'],
			$data['sum'],
			$data['employee_id']
		));

		return $this->pdo->lastInsertId();
	}

	/**
	 * Set data in current transaction
	 *
	 * @param arr $data - array(
	 *                        'accounting_date' => 'YYYY-MM-DD',
	 *                        'transfer_date'   => 'YYYY-MM-DD',
	 *                        'description'     => 'text', or '',
	 *                        'journal_id'      => int or NULL
	 *                        'vat'             => amount of money, 0 or above
	 *                        'sum'             => amount of money, above 0
	 *                        'employee_id'     => int or NULL
	 *          ALL ARE OPTIONAL
	 *                    )
	 * @return int - affected rows
	 **/
	public function set($data)
	{
		if ( ! ($this->id > 0)) throw new Kohana_Exception('No transaction ID set');

		$sql = 'UPDATE transactions SET';

		foreach ($data as $field => $value)
		{
			$columns = array_keys($this->pdo->query('SELECT * FROM transactions LIMIT 1;')->fetch(PDO::FETCH_ASSOC));

			if (isset($columns[array_search('id', $columns)]))
				unset($columns[array_search('id', $columns)]); // Unset ID, we should never try to update that

			if (in_array($field, $columns))
				$sql .= '`'.$field.'` = '.$this->pdo->quote($value).',';
		}

		$sql = substr($sql, 0, strlen($sql) - 1) . ' WHERE id = '.$this->pdo->quote($this->get_id()).' LIMIT 1';

		$this->pdo->exec($sql);

		$this->load_entry_data($this->get_id()); // Load the new data to the local data cache

		return TRUE;
	}

	public function get($detail = FALSE)
	{
		if ($detail && isset($this->data[$detail])) return $this->data[$detail];
		elseif ($detail)                            return FALSE;
		else                                        return $this->data;
	}

	public function get_id()
	{
		return $this->id;
	}

	private function load_entry_data($id)
	{
		return ($this->data = $this->pdo->query('SELECT * FROM transactions WHERE id = ?', $id)->fetch(PDO::FETCH_ASSOC));
	}

}
