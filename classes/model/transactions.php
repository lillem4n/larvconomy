<?php defined('SYSPATH') or die('No direct script access.');

class Model_Transactions extends Model
{

	public function __construct()
	{
		parent::__construct();
	}

	public static function get($search = NULL, $order_by = 'accounting_date', $where = NULL, $format_for_XML = FALSE)
	{
		$pdo = Kohana_pdo::instance();

		if (is_string($search) || is_array($search))
			$columns = array_keys($pdo->query('SELECT * FROM transactions LIMIT 1;')->fetch(PDO::FETCH_ASSOC));

		if (is_string($search))
		{
			$where = '';

			foreach ($columns as $column)
				$where .= '`'.$column.'` LIKE '.$pdo->quote('%'.$search.'%').' OR ';

			$where = substr($where, 0, strlen($where) - 4);
		}
		elseif (is_array($search))
		{
			$where = '';
			foreach ($search as $column => $string)
			{
				if (in_array($column, $columns))
					$where .= '`'.$column.'` LIKE '.$pdo->quote('%'.$string.'%').' OR ';
			}

			$where = substr($where, 0, strlen($where) - 4);
		}
		elseif ($where === NULL)
			$where = '1';

		$sql = '
			SELECT
				transactions.*,
				lastname AS employee_lastname,
				firstname AS employee_firstname
			FROM transactions
			LEFT JOIN employees ON employees.id = transactions.employee_id
			WHERE '.$where.'
			ORDER BY '.$order_by; // ORDER BY NEEDS TO BE SECURED!!!!!0101=!11111ett

		$transactions = array();
		$balance      = 0;
		foreach ($pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC) as $transaction)
		{
			foreach (glob(APPPATH.'user_content/vouchers/'.$transaction['id'].'/*') as $nr => $voucher)
			{
				if ($format_for_XML)
					$transaction['vouchers'][$nr.'voucher'] = pathinfo($voucher, PATHINFO_BASENAME);
				else
					$transaction['vouchers'][]              = pathinfo($voucher, PATHINFO_BASENAME);
			}

			$balance += $transaction['sum'];
			$transaction['balance'] = $balance;

			$transactions[] = $transaction;
		}

		return $transactions;
	}

	public static function get_cash_positions()
	{
		$pdo = Kohana_pdo::instance();

		$sql = 'SELECT DISTINCT cash_position FROM transactions ORDER BY cash_position;';

		$cash_positions = array('All');
		foreach ($pdo->query($sql) as $row)
			$cash_positions[] = $row['cash_position'];

		return $cash_positions;
	}

}