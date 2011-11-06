<?php defined('SYSPATH') or die('No direct script access.');

class Model_Bills extends Model
{

	public static function get()
	{
		$pdo = Kohana_pdo::instance();

		return $pdo->query('
			SELECT
				*,
				(SELECT SUM(qty * price * 1.25) FROM bills_items WHERE bills_items.bill_id = bills.id) AS sum,
				(SELECT SUM(qty * price * 0.25) FROM bills_items WHERE bills_items.bill_id = bills.id) AS vat
			FROM bills order by ID ASC;
		')->fetchAll(PDO::FETCH_ASSOC);
	}

}
