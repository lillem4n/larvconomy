<?php defined('SYSPATH') OR die('No direct access allowed.');

class Controller_Admin_Customers extends Admincontroller {

	public function before()
	{
		$this->xslt_stylesheet = 'admin/customers';
		xml::to_XML(array('admin_page' => 'Customers'), $this->xml_meta);
	}

	public function action_index()
	{
		$this->xml_content_customers = $this->xml_content->appendChild($this->dom->createElement('customers'));
		xml::to_XML(Customers::get_customers(), $this->xml_content_customers, 'customer', 'id');
	}

	public function action_add_customer()
	{
		if (count($_POST))
		{
			$post = new Validation($_POST);
			$post->filter('trim');

			if ($post->validate())
			{
				$customer_id = Customer::add_customer($post->as_array());
				$this->add_message('Customer '.$post->get('name').' added with ID #'.$customer_id);
			}
			else
			{
				$this->add_error('Fix errors and try again');
				$this->add_form_errors($post->errors());

				$this->set_formdata($post->as_array());
			}
		}
	}

	public function action_edit_customer($customer_id)
	{
		$customer_model = new Customer($customer_id);

		xml::to_XML(array('customer' => $customer_model->get_customer_data()), $this->xml_content, NULL, 'id');

		if (count($_POST))
		{
			$post = new Validation($_POST);
			$post->filter('trim');

			if ($post->validate())
			{
				$customer_model->set_customer_data($post->as_array());
				$this->add_message('Customer "'.$post->get('name').'" updated');
			}
		}

		$this->set_formdata($customer_model->get_customer_data());
	}

}
