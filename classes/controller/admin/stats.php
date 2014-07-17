<?php defined('SYSPATH') OR die('No direct access allowed.');

class Controller_Admin_Stats extends Admincontroller
{

	public function before()
	{
		xml::to_XML(array('admin_page' => 'Stats'), $this->xml_meta);
	}

	public function action_index()
	{
		$where            = 'accounting_date <= \''.date('Y-12-31').'\'';
		$order_by         = 'IF(accounting_date = 0,1,0),accounting_date;';
		$transactions     = Transactions::get(NULL, $order_by, $where, TRUE);

		$profit           = array();
		$balance          = 0;
		$balance_by_month = array();
		$turnover         = array();

		foreach ($transactions as $transaction)
		{
			if (date('Ym') != date('Ym', strtotime($transaction['accounting_date'])))
			{
				$balance += ($transaction['sum'] - $transaction['vat']);

				$month = 'month'.date('Y-m', strtotime($transaction['accounting_date']));

				$balance_by_month[$month] = $balance; // Update until all is accounted for

				if ( ! isset($profit[$month]))
					$profit[$month] = 0;

				$profit[$month] += ($transaction['sum'] - $transaction['vat']);

				if ( ! isset($turnover[$month]))
					$turnover[$month] = 0;

				if (($transaction['sum'] - $transaction['vat']) > 0)
					$turnover[$month] += ($transaction['sum'] - $transaction['vat']);
			}
		}

		xml::to_XML(array('balance_by_month' => $balance_by_month), $this->xml_content);
		xml::to_XML(array('profit'           => $profit),           $this->xml_content);
		xml::to_XML(array('turnover'         => $turnover),         $this->xml_content);

		//$accounting_node = $this->xml_content->appendChild($this->dom->createElement('accounting'));

		//xml::to_XML($transactions, $accounting_node, 'entry', 'id');
	}

}