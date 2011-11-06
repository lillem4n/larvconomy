<?php defined('SYSPATH') or die('No direct script access.');

class Model_Bill extends Model
{

	public $id;
	public $data;
	private static $prepared_insert;
	private static $prepared_item_insert;

	public function __construct($id)
	{
		parent::__construct();

		$this->id            = (int) $id;

		$this->data          = $this->pdo->query('SELECT * FROM bills WHERE id = '.$this->id)->fetch(PDO::FETCH_ASSOC);
		$this->data['items'] = $this->pdo->query('SELECT * FROM bills_items WHERE bill_id = '.$this->id.' ORDER BY item_id')->fetchAll(PDO::FETCH_ASSOC);
	}

	/**
	 * Add a bill
	 *
	 * @param int $customer_id
	 * @param num $due_date (UNIX timestamp)
	 * @param str $contact - Their reference
	 * @param arr $items - array(
	                              array(
	                                'artnr'         => '239D',
	                                'spec'          => 'What to bill for',
	                                'price'         => 700,
	                                'qty'           => 2,
	                                'delivery_date' => '2011-01-01'
	                              ),
	                              etc
	                            )
	 * @param str $comment - Optional
	 */
	public static function new_bill($customer_id, $due_date, $contact, $items, $comment = '')
	{
		$pdo = Kohana_pdo::instance();

		if (self::$prepared_insert == NULL)
		{
			self::$prepared_insert      = $pdo->prepare('INSERT INTO bills (due_date,customer_id,customer_name,customer_orgnr,customer_contact,customer_tel,customer_email,customer_street,customer_zip,customer_city,comment,contact) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)');
			self::$prepared_item_insert = $pdo->prepare('INSERT INTO bills_items (item_id,bill_id,artnr,spec,qty,price,delivery_date) VALUES(?,?,?,?,?,?,?)');
		}

		$customer_model = new Customer($customer_id);

		self::$prepared_insert->execute(array(
			date('Y-m-d', $due_date),
			intval($customer_id),
			$customer_model->get_customer_data('name'),
			$customer_model->get_customer_data('orgnr'),
			$customer_model->get_customer_data('contact'),
			$customer_model->get_customer_data('tel'),
			$customer_model->get_customer_data('email'),
			$customer_model->get_customer_data('street'),
			$customer_model->get_customer_data('zip'),
			$customer_model->get_customer_data('city'),
			$comment,
			$contact
		));

		$bill_id = $pdo->lastInsertId();

		foreach ($items as $nr => $item)
		{
			self::$prepared_item_insert->execute(array(
				($nr + 1),
				$bill_id,
				$item['artnr'],
				$item['spec'],
				$item['qty'],
				$item['price'],
				date('Y-m-d', time()),
			));
		}

		return $bill_id;
	}

	public function pay($date = FALSE)
	{
		if ($date === FALSE) $date = date('Y-m-d', time());

		$this->pdo->query('UPDATE bills        SET paid_date     = \''.date('Y-m-d', strtotime($date)).'\' WHERE id          = '.$this->id);
		$this->pdo->query('UPDATE transactions SET transfer_date = \''.date('Y-m-d', strtotime($date)).'\' WHERE description = \'Bill '.$this->id.'\';');

		return TRUE;
	}

}
