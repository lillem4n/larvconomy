<?php defined('SYSPATH') OR die('No direct access allowed.');

class Controller_Admin_Accounting extends Admincontroller
{

	public function before()
	{
		xml::to_XML(array('admin_page' => 'Accounting'), $this->xml_meta);
		xml::to_XML(array('current_date' => date('Y-m-d', time())), $this->xml_meta);
	}

	public function action_index()
	{
		$accounting_node = $this->xml_content->appendChild($this->dom->createElement('accounting'));

		xml::to_XML(Transactions::get(NULL, 'IF(transfer_date = 0,1,0),transfer_date;', NULL, TRUE), $accounting_node, 'entry', 'id');
	}

	public function action_dlvouchers()
	{
		set_time_limit(0);
		$files = array();

		/** /
		if     (date('m') < 4)  $quarter = 1;
		elseif (date('m') < 7)  $quarter = 2;
		elseif (date('m') < 10) $quarter = 3;
		else                    $quarter = 4;

		if ($quarter == 1)      $year = intval(date('Y') - 1);
		else                    $year = intval(date('Y'));

		$where = 'YEAR(accounting_date) = '.$year.' AND MONTH(accounting_date) BETWEEN ';

		if     ($quarter == 1) $where .= '10 AND 12';
		elseif ($quarter == 2) $where .= '1 AND 3';
		elseif ($quarter == 3) $where .= '4 AND 6';
		elseif ($quarter == 4) $where .= '7 AND 9';
		/**/

		if ( ! isset($_GET['from_date'])) $_GET['from_date'] = '1970-01-01';
		if ( ! isset($_GET['to_date']))   $_GET['to_date']   = date('Y-m-d');

		$from_date = date('Y-m-d', strtotime($_GET['from_date']));
		$to_date   = date('Y-m-d', strtotime($_GET['to_date']));

		$where = 'transfer_date >= \''.$from_date.'\' AND transfer_date <= \''.$to_date.'\'';

		foreach (Transactions::get(NULL, 'IF(transfer_date = 0,1,0),transfer_date;', $where, TRUE) as $transaction)
			if ( ! empty($transaction['vouchers']))
				foreach ($transaction['vouchers'] as $voucher_file)
					$files[date('Y-m-d', strtotime($transaction['transfer_date']))][] = APPPATH.'user_content/vouchers/'.$transaction['id'].'/'.$voucher_file;

		if (count($files))
		{
			$zipname = APPPATH.'user_content/'.$from_date.'_-_'.$to_date.'_vouchers.zip';
			$zip     = new ZipArchive;
			if ($zip->open($zipname, ZIPARCHIVE::CREATE | ZIPARCHIVE::OVERWRITE) === TRUE)
			{
				foreach ($files as $date => $files)
					foreach ($files as $file)
						if (file_exists($file))
							$zip->addFile($file, $date.' - '.pathinfo($file, PATHINFO_BASENAME));

				$zip->close();

				header('Content-Type: application/zip');
				header('Content-disposition: attachment; filename='.pathinfo($zipname, PATHINFO_BASENAME));
				header('Content-Length: '.filesize($zipname));
				echo file_get_contents($zipname);
				unlink($zipname);
				die();
			} else die('error opening ziparchive');
		}
		else die('no vouchers found');
	}

	public function action_entry()
	{
		// Set employees node
		$employees_node       = $this->xml_content->appendChild($this->dom->createElement('employees'));
		$employees            = array('0option'=>array('@value'=>'0', 'None'));
		$counter              = 1;
		foreach (Employees::get() as $employee)
		{
			$employees[$counter.'option'] = array(
				'@value' => $employee['id'],
				$employee['lastname'].', '.$employee['firstname'],
			);
			$counter++;
		}
		xml::to_XML($employees, $employees_node); // This is for the select box

		if (count($_POST))
		{
			$post = new Validation($_POST);
			$post->filter('trim');
			$post->filter('floatval',       'sum');
			$post->filter('floatval',       'vat');
			$post->rule('strtotime',        'accounting_date');
			$post->rule('strtotime',        'transfer_date');
			$post->rule('Valid::not_empty', 'description');

			if ($post->Validate())
			{
				$new_transaction_data = array(
					'accounting_date' => $post->get('accounting_date'),
					'transfer_date'   => $post->get('transfer_date'),
					'description'     => $post->get('description'),
					'journal_id'      => $post->get('journal_id'),
					'vat'             => $post->get('vat'),
					'sum'             => $post->get('sum'),
					'employee_id'     => $post->get('employee_id'),
				);

				if (isset($_POST['rm_voucher']))
				{
					$new_transaction_data['rm_vouchers'] = array();
					foreach (array_keys($_POST['rm_voucher']) as $nr)
						$new_transaction_data['rm_vouchers'][] = $_POST['rm_voucher_names'][$nr];
				}

				if ( ! isset($_GET['id']))
				{
					$transaction = new Transaction(NULL, $new_transaction_data);
					$this->add_message('Transaction '.$transaction->get_id().' added');
					if (isset($_FILES['voucher'])) $transaction->add_voucher($_FILES['voucher']);
					$this->set_formdata(array('accounting_date' => date('Y-m-d', time()), 'transfer_date' => date('Y-m-d', time())));
				}
				else
				{
					$transaction = new Transaction($_GET['id']);
					$transaction->set($new_transaction_data);
					$this->add_message('Transaction '.$transaction->get_id().' updated');
					$this->set_formdata($transaction->get());
					if (isset($_FILES['voucher'])) $transaction->add_voucher($_FILES['voucher']);
					xml::to_XML($transaction->get('vouchers'), array('vouchers' => $this->xml_content), 'voucher');
				}
			}
			else
			{
				$this->add_form_errors($post->errors());
				$this->set_formdata($post->as_array());
			}
		}
		elseif (isset($_GET['id']))
		{
			$transaction = new Transaction($_GET['id']);
			$this->set_formdata($transaction->get());
			xml::to_XML($transaction->get('vouchers'), array('vouchers' => $this->xml_content), 'voucher');
		}
		else
		{
			$this->set_formdata(array('accounting_date' => date('Y-m-d', time()), 'transfer_date' => date('Y-m-d', time())));
		}
	}

}
