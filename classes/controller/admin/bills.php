<?php defined('SYSPATH') OR die('No direct access allowed.');

class Controller_Admin_Bills extends Admincontroller {

	public function before()
	{
		$this->xslt_stylesheet = 'admin/bills';
		xml::to_XML(array('admin_page' => 'Bills'), $this->xml_meta);
		xml::to_XML(array('current_date' => date('Y-m-d', time())), $this->xml_meta);
	}

	public function action_index()
	{
		$this->xml_content_bills = $this->xml_content->appendChild($this->dom->createElement('bills'));
		xml::to_XML(Bills::get(), $this->xml_content_bills, 'bill', 'id');
	}
 
  public function action_email()
  {
    //Get the bill data.
    $bill = New Bill($_GET['invoice']);
    $costumer = $bill->get_customer_data('costumer_email'); 
    
    $mail = new Mail();
    $mail->from('Larv IT AB', 'info@larvit.se');
    $mail->to($costumer);
    $mail->subject('Invoice from Larv IT');
    $mail->content('Invoice sent');
    $mail->attachment(url::base('http',FALSE).'/user_content/pdf/bill_'.$_GET['invoice'].'.pdf');

    if($mail->send())
    {
      die('Email was sent and costumer = '.$costumer);
    }
    else
    {
      die('email was not sent and costumer = '.$costumer);
    }

    // if email sent then update bills.invoice_sent with CURRENT_TIMESTAMP 
  }


	public function action_new_bill()
	{
		$this->xml_content_customers = $this->xml_content->appendChild($this->dom->createElement('customers'));
		xml::to_XML(Customers::get_customers(), $this->xml_content_customers, 'customer', 'id');

		if ( ! isset($_SESSION['bills']['items']))
		{
			$_SESSION['bills']['items']['1item'] = 1;
		}

		if (count($_POST))
		{
			$post = new Validation($_POST);
			$post->filter('trim');
			$post_array = $post->as_array();


			if (isset($post_array['add_item']))
			{
				$_SESSION['bills']['items'][(count($_SESSION['bills']['items']) + 1).'item'] = count($_SESSION['bills']['items']) + 1;
				$this->set_formdata($post_array);
			}
			else
			{
				$items   = array();
				$sum     = 0;
				$vat_sum = 0;
				foreach ($_SESSION['bills']['items'] as $item_nr)
				{
					$item = array(
						'artnr'         => $post->get('artnr_item_'.$item_nr),
						'spec'          => $post->get('spec_item_'.$item_nr),
						'price'         => (float)$post->get('price_item_'.$item_nr),
						'qty'           => (float)$post->get('qty_item_'.$item_nr),
						'delivery_date' => date('Y-m-d', time()),
					);

					if ($item != array('artnr'=>'','spec'=>'','price'=>0,'qty'=>0,'delivery_date'=>date('Y-m-d',time())))
					{
						$items[]  = $item;
						$sum     += ($item['qty'] * $item['price'] * 1.25);
						$vat_sum += ($item['qty'] * $item['price'] * 0.25);
					}
				}

				if (count($items) && $post->validate())
				{
					$bill_id = Bill::new_bill($post->get('customer_id'), strtotime($post->get('due_date')), $post->get('contact'), $items, $post->get('comment'));
					$this->add_message('Created bill nr '.$bill_id);
					unset($_SESSION['bills']['items']);

					// Create the transaction
					$data = array(
						'accounting_date' => date('Y-m-d', time()),
						'transfer_date'   => '0000-00-00',
						'description'     => 'Bill '.$bill_id,
						'vat'             => $vat_sum,
						'sum'             => $sum,
						'employee_id'     => NULL,
						'journal_id'      => NULL,
					);

					$transaction = new Transaction(NULL, $data);
					// End of Create the transaction

					// Make the PDF

					shell_exec('wkhtmltopdf '.$_SERVER['SERVER_NAME'].URL::site('bill?billnr='.$bill_id).' '.APPPATH.'user_content/pdf/bill_'.$bill_id.'.pdf');
				}
				else
				{
					$this->add_error('Not enough data');
					$post->set('due_date', date('Y-m-d', strtotime($post->get('due_date'))));
					$this->set_formdata($post->as_array());
				}
			}

		}
		else
		{
			$this->set_formdata(array('due_date' => date('Y-m-d', time() + 20*24*60*60)));
		}

		xml::to_XML($_SESSION['bills'], $this->xml_content);
	}

	public function action_mark_as_paid()
	{
		$details = $this->request->param('options');

		list($bill_id, $pay_date) = explode('/', $details);

		$bill = new bill($bill_id);
		$bill->pay($pay_date);
		$this->redirect();
	}
 

}
