<?php defined('SYSPATH') OR die('No direct access allowed.');

class Controller_Admin_Employees extends Admincontroller {

	public function before()
	{
		$this->xslt_stylesheet = 'admin/employees';
		xml::to_XML(array('admin_page' => 'Employees'), $this->xml_meta);
		xml::to_XML(array('current_date' => date('Y-m-d', time())), $this->xml_meta);
	}

	public function action_index()
	{
		$employees_node = $this->xml_content->appendChild($this->dom->createElement('employees'));
		xml::to_XML(Employees::get(), $employees_node, 'employee', 'id');
	}

	public function action_employee()
	{
		if (isset($_GET['id']))
		{
			$employee = new Employee($_GET['id']);

			if (count($_POST))
			{
				$post = new Validation($_POST);
				$post->filter('trim');
				$employee->set($post->as_array());
				$this->add_message('Employee '.$_GET['id'].' information updated');
			}

			$this->set_formdata($employee->get());

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
		}
		else
		{
     
    $post = new Validation($_POST);
    $post->filter('trim');
    $employee = new Employee();

    $employee->set($post->as_array());
    $this->add_message($post->get('firstname') . ' was added as employee');
		}
	}

}
