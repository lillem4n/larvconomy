<?php defined('SYSPATH') OR die('No direct access allowed.');

class Controller_Payslip extends Xsltcontroller {

	public function before()
	{
//		$this->transform = TRUE;
	}

	public function action_index()
	{
		// Set the name of the template to use
		$this->xslt_stylesheet = 'payslip';

		if ( ! isset($_GET['employee_id']) || ! isset($_GET['period']) || ! preg_match('/^\d{4}-\d{1,2}$/', $_GET['period']))
		{
			throw new Kohana_exception('Invalid parameters');
		}

		$employee = new Employee($_GET['employee_id']);
		xml::to_XML($employee->get(), $this->xml_content->appendChild($this->dom->createElement('employee')), NULL, 'id');

		$where = '
			employee_id = '.intval($_GET['employee_id']).' AND
			(
				description = \'Social fees period '.$_GET['period'].'\' OR
				description = \'Income taxes period '.$_GET['period'].'\' OR
				(
					description = \'Salary payout\' AND
					MONTH(transfer_date) = '.substr($_GET['period'], 5).' AND
					YEAR(transfer_date) = '.substr($_GET['period'], 0, 4).'
				)
			)';

		xml::to_XML(Transactions::get(NULL, 'accounting_date', $where), $this->xml_content->appendChild($this->dom->createElement('transactions')), 'transaction', 'id');
	}

}
