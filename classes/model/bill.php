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

	public function get($detail = FALSE)
	{
		if     ($detail == FALSE)            return $this->data;
		elseif (isset($this->data[$detail])) return $this->data[$detail];

		return FALSE;
	}


	public function get_attachments($bill_id)
	{
		$attachments = array();
		foreach(glob(Kohana::$config->load('user_content.dir').'/'.$bill_id.'/*') as $file_array)
		{
			$file = explode('/',$file_array);
			$file = end($file);
			$attachments[] = $file;
		}
		return $attachments;
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
	public static function new_bill($customer_id, $due_date, $contact, $items, $comment = '', $template = 'default', $mail_body = '')
	{
		$pdo = Kohana_pdo::instance();

		if (self::$prepared_insert == NULL)
		{
			self::$prepared_insert      = $pdo->prepare('INSERT INTO bills (due_date,customer_id,customer_name,customer_orgnr,customer_contact,customer_tel,customer_email,customer_street,customer_zip,customer_city,comment,contact,template,mail_body) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)');
			self::$prepared_item_insert = $pdo->prepare('INSERT INTO bills_items (item_id,bill_id,artnr,spec,qty,price,delivery_date) VALUES(?,?,?,?,?,?,?)');
		}

		$customer_model = new Customer($customer_id);

		self::$prepared_insert->execute(array(
			date('Y-m-d', $due_date),
			intval($customer_id),
			$customer_model->get('name'),
			$customer_model->get('orgnr'),
			$customer_model->get('contact'),
			$customer_model->get('tel'),
			$customer_model->get('email'),
			$customer_model->get('street'),
			$customer_model->get('zip'),
			$customer_model->get('city'),
			$comment,
			$contact,
			$template,
			$mail_body
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

		$this->pdo->query('UPDATE bills        SET paid_date     = \''.date('Y-m-d', strtotime($date)).'\' WHERE id          = '.$this->pdo->quote($this->id));
		$this->pdo->query('UPDATE transactions SET transfer_date = \''.date('Y-m-d', strtotime($date)).'\' WHERE description = \'Bill '.$this->pdo->quote($this->id).'\';');

		return TRUE;
	}

	public function send_mail()
	{
		try
		{
			$mail_body = $this->pdo->query('SELECT mail_body FROM bills WHERE id = '.$this->pdo->quote($this->id))->fetchColumn();
			$email_response = Email::factory(Kohana::$config->load('larv.email.bill_subject'), $mail_body)
				->to($this->get('customer_email'))
				->from(Kohana::$config->load('larv.email.from'), Kohana::$config->load('larv.email.from_name'))
				->attach_file(APPPATH.'user_content/pdf/bill_'.$this->id.'.pdf');
				foreach ( glob(Kohana::$config->load('user_content.dir').'/attachments/'.$this->id.'/*') as $attachment)
				{
					$email_response->attach_file($attachment);
				}
				$email_response->send($errors);
		}
		catch (Swift_RfcComplianceException $e)
		{
			// If the email address does not pass RFC Compliance
			return FALSE;
		}

		if ($email_response) $this->pdo->query('UPDATE bills SET email_sent = CURRENT_TIMESTAMP() WHERE id = '.$this->pdo->quote($this->id));

		return $email_response;
	}

	/**
	 * function upload
	 * @param  arr  (file) could be multi- or single dimensional file array
	 * @param  str  (path) to set where in the user_content dir the upload should be placed.
	 * @return bool $return to check whether all of the files could be uploaded.
	 **/

	public static function upload($file, $path = FALSE)
	{
		foreach ($file as $file_array => $attachments)
		{
			if (is_array($attachments))
			{
				foreach ($attachments as $type => $i) //Where $i is [<int>]
				{
					foreach ($i as $key => $val)
					$files[$key][$type] = $val;
				}
			}
			else
			{
				$files[] = $file;
			}
		}

		$path = Kohana::$config->load('user_content.dir').'/'.$path;
		if ( ! is_dir($path)) mkdir($path, 0777);

		foreach ($files as $file)
		{
			if (move_uploaded_file($file['tmp_name'], $path.'/'.$file['name']))
				$return = TRUE;
			else
				$return = FALSE;
		}
		return $return;
	}

}
