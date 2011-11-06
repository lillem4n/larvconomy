<?php defined('SYSPATH') OR die('No direct access allowed.');

class Controller_Bill extends Xsltcontroller {

	public function before()
	{
		$this->transform = TRUE;
	}

	public function action_index()
	{
		// Set the name of the template to use
		$this->xslt_stylesheet = 'bill';

		if (isset($_GET['billnr']))
		{
			$bill = new Bill($_GET['billnr']);
		}

		$bill_data = $bill->data;
		foreach ($bill_data['items'] as $nr => $item)
		{
			$bill_data['items'][$nr.'item'] = $item;
			unset($bill_data['items'][$nr]);
		}

		$bill_data['due_days'] = (strtotime($bill_data['due_date']) - strtotime($bill_data['date'])) / (24*60*60);

		// And round it up
		$bill_data['due_days']      += 1;
		list($bill_data['due_days']) = explode('.', strval($bill_data['due_days']));

		xml::to_XML(array('bill'=>$bill_data), $this->xml_content, NULL, array('id', 'artnr'));
/*
		if (isset($_GET['billnr']) && $_GET['billnr'] == 1)
		{
			$bill = array(
				'bill id="1"' => array(
					'customer id="1"' => array(
						'name'      => 'Kristoffer Nolgren Firma',
						'reference' => 'Kristoffer Nolgren',
						'street'    => 'Lyckostigen 10',
						'zip'       => '18356',
						'city'      => 'Täby',
					),
					'payment_data' => array(
						'date'           => '2011-01-24',
						'due_date'       => '2011-02-13',
						'item artnr="-"' => array(
							'spec'          => 'Webbprogrammering',
							'qty'           => '1',
							'price'         => '700',
							'delivery_date' => '2010-01-03',
						),
					),
				),
			);
		}
		else die('fail');

		xml::to_XML($bill, $this->xml_content);
/**/
	}

}
