<?php defined('SYSPATH') or die('No direct script access.');

class Model_Customer extends Model
{

	private $id;
	private $data;

	public function __construct($id)
	{
		parent::__construct();

		$this->id = (int) $id;
		$this->data = $this->pdo->query('SELECT * FROM customers WHERE id = '.$this->id)->fetch(PDO::FETCH_ASSOC);
	}

	public static function add($customer_data)
	{
		$pdo = Kohana_pdo::instance();

// Here we should really do a check so those columns actually exists. It might be an SQL-injection exploit!
		$sql = 'INSERT INTO customers ('.implode(',', array_keys($customer_data)).') VALUES(';
		foreach ($customer_data as $data) $sql .= $pdo->quote($data).',';
		$sql = substr($sql, 0, strlen($sql) - 1).');';

		$pdo->exec($sql);

		return $pdo->lastInsertId();
	}

	public function get($field = FALSE)
	{
		if ($field && isset($this->data[$field]))
			return $this->data[$field];
		elseif ($field != FALSE && ! isset($this->data[$field]))
			return FALSE;

		return $this->data;
	}

	public function set($customer_data)
	{
		$this->data = $customer_data;

		$sql = 'UPDATE customers SET ';
		foreach ($customer_data as $field => $data)
			$sql .= $field.' = '.$this->pdo->quote($data).',';
		$sql = substr($sql, 0, strlen($sql) - 1).' WHERE id = '.$this->id;
		return $this->pdo->exec($sql);
	}


}
