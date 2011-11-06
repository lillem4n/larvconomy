<?php defined('SYSPATH') or die('No direct script access.');

class Model_Customers extends Model
{

	public static function get_customers()
	{
		$pdo = Kohana_pdo::instance();

		return $pdo->query('SELECT * FROM customers;')->fetchAll(PDO::FETCH_ASSOC);
	}

}
