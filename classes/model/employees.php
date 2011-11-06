<?php defined('SYSPATH') or die('No direct script access.');

class Model_Employees extends Model
{

	public static function get()
	{
		$pdo = Kohana_pdo::instance();

		return $pdo->query('SELECT * FROM employees ORDER BY lastname, firstname;')->fetchAll(PDO::FETCH_ASSOC);
	}

}
