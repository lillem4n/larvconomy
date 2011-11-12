<?php defined('SYSPATH') OR die('No direct access allowed.');

class Controller_Admin_Wages extends Admincontroller {

	public function before()
	{
		$this->xslt_stylesheet = 'admin/wages';
		xml::to_XML(array('admin_page' => 'Wages'), $this->xml_meta);
		xml::to_XML(array('current_date' => date('Y-m-d', time())), $this->xml_meta);
	}

	public function action_index()
	{
		// Period-stuff (Needs to be before $_POST-handling)
			$year  = $start_year  = $current_year  = date('Y', time());
			$month = $start_month = $current_month = date('m', time());

			foreach (Transactions::get(array('description' => 'Salary payout')) as $transaction)
			{
				$year  = $start_year  = intval(substr($transaction['accounting_date'], 0, 4));
				$month = $start_month = intval(substr($transaction['accounting_date'], 5, 2));
				break;
			}

			$periods = array();
			while ($year <= $current_year && $month <= $current_month)
			{
				$periods[$year.$month.'option'] = array(
					'@value' => $year.'-'.$month,
					$year.' '.date('F', mktime(0,0,0,$month,1))
				);

				$month++;
				if ($month > 12)
				{
					$year++;
					$month = 1;
				}
			}
			xml::to_XML($periods, $this->xml_content->appendChild($this->dom->createElement('periods')));

			if ( ! isset($_GET['period']) || ! preg_match('/^\d{4}-\d{1,2}$/', $_GET['period']))
			{
				$_GET['period'] = $start_year.'-'.$start_month;
			}
			$this->set_formdata(array('period'=>$_GET['period']));
		// End of period-stuff


		if (count($_POST))
		{
			// Data submitted
			$post = new Validation($_POST);
			$post->filter('trim');

			$post_array        = $post->as_array();
			foreach (array_keys($post_array) as $key)
			{
				if (substr($key, 0, 13) == 'submit_button')
				{
					$employee_id = (int) substr($key, 14);
				}
			}

			$transaction_data = array(
				'accounting_date' => date('Y-m-d', time()),
				'transfer_date'   => date('Y-m-d', time()),
				'description'     => 'Social fees period '.$_GET['period'],
				'journal_id'      => NULL,
				'vat'             => 0,
				'sum'             => -$post_array['social_fee_cost_'.$employee_id],
				'employee_id'     => $employee_id
			);

			$soc_fee = new Transaction(NULL, $transaction_data);

			$transaction_data['description'] = 'Income taxes period '.$_GET['period'];
			$transaction_data['sum']         = -$post_array['income_tax_cost_'.$employee_id];

			$inc_tax = new Transaction(NULL, $transaction_data);

			$this->redirect();
		}

		// Employees_totals
			$employees                = array();
			$where                    = 'description = \'Salary payout\' AND YEAR(accounting_date) = '.substr($_GET['period'],0,4).' AND MONTH(accounting_date) = '.substr($_GET['period'],5);
			$transactions_this_period = Transactions::get(NULL, 'accounting_date', $where);

			foreach ($transactions_this_period as $transaction)
			{

				$employee = new Employee($transaction['employee_id']);
				if ( ! isset($employees[$transaction['employee_id']]))
				{
					$employees[$transaction['employee_id']] = array(
						'payout_cost'     => 0,
						'soc_fee_cost'    => 0,
						'income_tax_cost' => 0,
					)+$employee->get();
				}

				$employees[$transaction['employee_id']]['payout_cost'] -= $transaction['sum'];

				@list($accounted_income_tax) = Transactions::get(NULL, 'accounting_date', ' description = \'Income taxes period '.$_GET['period'].'\' AND employee_id = '.$transaction['employee_id']);
				@list($accounted_soc_fee)    = Transactions::get(NULL, 'accounting_date', ' description = \'Social fees period '.$_GET['period'].'\' AND employee_id = '.$transaction['employee_id']);
				if ($accounted_income_tax && $accounted_soc_fee)
				{
					// First we check the database
					$employees[$transaction['employee_id']]['income_tax_cost'] = -$accounted_income_tax['sum'];
					$employees[$transaction['employee_id']]['soc_fee_cost']    = -$accounted_soc_fee['sum'];
				}
				else
				{
					// Nothing in database, calculate
					$employees[$transaction['employee_id']]['calculated']       = array();
					$employees[$transaction['employee_id']]['income_tax_cost'] -= (($transaction['sum'] / (100 - $employee->get('tax_level')) * 100) - $transaction['sum']);
					$employees[$transaction['employee_id']]['soc_fee_cost']    -= (($transaction['sum'] / (100 - $employee->get('tax_level')) * 100) * $employee->get('soc_fee_level') / 100);
				}
			}

			// Round employee totals
			foreach ($employees as $nr => $employee)
			{
				$employees[$nr]['income_tax_cost'] = floor($employees[$nr]['income_tax_cost']);
				$employees[$nr]['soc_fee_cost']    = floor($employees[$nr]['soc_fee_cost']);
			}

			xml::to_XML($employees, $this->xml_content->appendChild($this->dom->createElement('employees_totals')), 'employee', 'id');
		// End of Employees_totals
	}

	public function action_payouts()
	{
		xml::to_XML(Transactions::get(array('description' => 'Salary payout')), $this->xml_content->appendChild($this->dom->createElement('payouts')), 'payout', 'id');
	}

	public function action_payout()
	{

		// Set employees node
		$employees_node       = $this->xml_content->appendChild($this->dom->createElement('employees'));
		$employees            = array();
		$counter              = 0;
		$employees_from_model = Employees::get();
		foreach ($employees_from_model as $employee)
		{
			$employees[$counter.'option'] = array(
				'@value' => $employee['id'],
				$employee['lastname'].', '.$employee['firstname'],
			);
			$counter++;
		}
		xml::to_XML($employees, $employees_node); // This is for the select box
		xml::to_XML($employees_from_model, $employees_node, 'employee', 'id');

		if (isset($_GET['id']))
		{
			if (count($_POST))
			{
				$post = new Validation($_POST);
				$post->filter('trim');
				$salary->set($post->as_array());
			}

			$this->set_formdata($salary->get());

			xml::to_XML(
				array(
					'statuses' => array(
						'1option' => array(
							'@value' => 'active',
							'Active',
						),
						'2option' => array(
							'@value' => 'inactive',
							'Inactive',
						),
					)
				),
				$this->xml_content
			);
			xml::to_XML($employee->get(), $this->xml_content->appendChild($this->dom->createElement('employee')), NULL, 'id');
			$this->add_message('Employee '.$_GET['id'].' information updated');
		}
		elseif (count($_POST))
		{
			// Add new payout
			$post = new Validation($_POST);
			$post->filter('trim');
			$post->rule('Valid::digit', 'amount');
			$post->rule('strtotime',    'date');
			if ($post->validate())
			{
				$post_array = $post->as_array();
				$transaction_data = array(
					'accounting_date' => date('Y-m-d', strtotime($post_array['date'])),
					'transfer_date'   => date('Y-m-d', strtotime($post_array['date'])),
					'description'     => 'Salary payout',
					'journal_id'      => NULL,
					'vat'             => 0,
					'sum'             => -$post_array['amount'],
					'employee_id'     => $post_array['employee_id'],
				);

				$transaction = new Transaction(NULL, $transaction_data);
				if ($id = $transaction->get_id()) $this->add_message('New transaction added (ID '.$id.')');
				else                              $this->add_error('Something fucked up');
			}
			else
			{
				$this->set_formdata($post->as_array());
				$errors = $post->errors();
				$this->add_form_errors($errors);
				if (isset($errors['date']))   $this->add_form_errors(array('date'=>'Invalid date format'));
				if (isset($errors['amount'])) $this->add_form_errors(array('amount'=>'Must be numbers ONLY'));

			}
		}
	}

}
