<?php defined('SYSPATH') or die('No direct script access.');

class Model_Customer extends Model
{

	private $customer_id;
	private $customer_data;

	public function __construct($customer_id)
	{
		parent::__construct();

		$this->customer_id = (int)$customer_id;
		$this->customer_data = $this->pdo->query('SELECT * FROM customers WHERE id = '.$this->pdo->quote($this->customer_id))->fetch(PDO::FETCH_ASSOC);
	}

	public static function add_customer($customer_data)
	{
		$pdo = Kohana_pdo::instance();

		$sql = 'INSERT INTO customers ('.implode(',', array_keys($customer_data)).') VALUES(';
		foreach ($customer_data as $data) $sql .= $pdo->quote($data).',';
		$sql = substr($sql, 0, strlen($sql) - 1).');';

		$pdo->exec($sql);

		return $pdo->lastInsertId();
	}

	public function get_customer_data($field = FALSE)
	{
		if ($field && isset($this->customer_data[$field]))
		{
			return $this->customer_data[$field];
		}

		return $this->customer_data;
	}

	public function set_customer_data($customer_data)
	{
		$this->customer_data = $customer_data;

		$sql = 'UPDATE customers SET ';
		foreach ($customer_data as $field => $data)
		{
			$sql .= $field.' = '.$this->pdo->quote($data).',';
		}
		$sql = substr($sql, 0, strlen($sql) - 1).' WHERE id = '.$this->pdo->quote($this->customer_id);
		return $this->pdo->exec($sql);
	}


}
