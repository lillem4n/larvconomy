<?php defined('SYSPATH') or die('No direct script access.');

class Model_Transaction extends Model
{

	private $data;
	private $id;
	private static $prepared_insert; // PDO prepared insert object

	public function __construct($id = NULL, $data = NULL, $voucher = FALSE)
	{
		parent::__construct();

		if ($id === NULL && is_array($data))
		{
			if ($this->id = $this->add($data, $voucher))
				$this->load_entry_data($this->id);
		}
		elseif ($id > 0)
		{
			$id = (int) preg_replace("/[^0-9]+/", '', $id);
			if ($this->load_entry_data($id)) $this->id = $id;
		}
	}

	/**
	 * Add transaction and return the new transaction id
	 *
	 * @param arr $data - array(
	 *                        'accounting_date' => 'YYYY-MM-DD',                OPTIONAL
	 *                        'transfer_date'   => 'YYYY-MM-DD',
	 *                        'description'     => 'text',                      OPTIONAL
	 *                        'journal_id'      => int or NULL                  OPTIONAL
	 *                        'vat'             => amount of money, 0 or above  OPTIONAL
	 *                        'sum'             => amount of money, above 0
	 *                        'employee_id'     => int or NULL                  OPTIONAL
	 *                        'cash_position'   => str or NULL                  OPTIONAL
	 *                        'account'         => int or NULL                  OPTIONAL
	 *                    )
	 * @param arr $voucher - from a file form field
	 * @return int
	 **/
	private function add($data)
	{
		if ( ! isset($data['accounting_date'])) $data['accounting_date'] = $data['transfer_date'];
		if ( ! isset($data['description']))     $data['description']     = '';
		if ( ! isset($data['journal_id']))      $data['journal_id']      = NULL;
		if ( ! isset($data['vat']))             $data['vat']             = 0;
		if ( ! isset($data['employee_id']))     $data['employee_id']     = NULL;
		if ( ! isset($data['cash_position']))   $data['cash_position']   = '';
		if ( ! isset($data['account']))         $data['account']         = NULL;

		if (self::$prepared_insert == NULL)
		{
			$sql = 'INSERT INTO transactions (accounting_date, transfer_date, description, journal_id, vat, sum, employee_id, cash_position, account) VALUES(?,?,?,?,?,?,?,?,?)';
			self::$prepared_insert = $this->pdo->prepare($sql);
		}

		self::$prepared_insert->execute(array(
			$data['accounting_date'],
			$data['transfer_date'],
			$data['description'],
			$data['journal_id'],
			$data['vat'],
			$data['sum'],
			$data['employee_id'],
			$data['cash_position'],
			$data['account']
		));

		return $this->pdo->lastInsertId();
	}

	/**
	 * Add voucher to this transaction
	 *
	 * @param arr $voucher - from a file form field
	 * @return boolean
	 **/
	public function add_voucher($voucher)
	{
		if ( ! ($this->id > 0)) throw new Kohana_Exception('No transaction ID set');

		$folder = APPPATH.'user_content/vouchers/'.$this->get_id();
		exec('mkdir -p '.$folder);

		if (isset($voucher['error']) && $voucher['error'] == 0)
		{
			move_uploaded_file($voucher['tmp_name'], $folder.'/'.$voucher['name']);
			$this->load_entry_data($this->get_id()); // Load the new data to the local data cache
			return TRUE;
		}
	}

	/**
	 * Set data in current transaction
	 *
	 * @param arr $data - array(
	 *                        'accounting_date' => 'YYYY-MM-DD',
	 *                        'transfer_date'   => 'YYYY-MM-DD',
	 *                        'description'     => 'text', or '',
	 *                        'journal_id'      => int or NULL
	 *                        'vat'             => amount of money, 0 or above
	 *                        'sum'             => amount of money, above 0
	 *                        'employee_id'     => int or NULL
	 *          ALL ARE OPTIONAL
	 *                    )
	 * @return int - affected rows
	 **/
	public function set($data)
	{
		if ( ! ($this->id > 0)) throw new Kohana_Exception('No transaction ID set');

		$sql     = 'UPDATE transactions SET';
		$columns = array_keys($this->pdo->query('SELECT * FROM transactions LIMIT 1;')->fetch(PDO::FETCH_ASSOC));
		if (isset($columns[array_search('id', $columns)]))
			unset($columns[array_search('id', $columns)]); // Unset ID, we should never try to update that

		foreach ($data as $field => $value)
		{
			if (in_array($field, $columns))
				$sql .= '`'.$field.'` = '.$this->pdo->quote($value).',';
			elseif ($field == 'rm_vouchers')
			{
				foreach ($value as $filename)
					unlink(APPPATH.'user_content/vouchers/'.$this->id.'/'.$filename);
			}
		}

		$sql = substr($sql, 0, strlen($sql) - 1) . ' WHERE id = '.$this->pdo->quote($this->get_id()).' LIMIT 1';

		$this->pdo->exec($sql);

		$this->load_entry_data($this->get_id()); // Load the new data to the local data cache

		return TRUE;
	}

	public function get($detail = FALSE)
	{
		if ($detail && isset($this->data[$detail])) return $this->data[$detail];
		elseif ($detail)                            return FALSE;
		else                                        return $this->data;
	}

	public function get_id()
	{
		return $this->id;
	}

	protected function load_entry_data($id)
	{
		if ($this->data = $this->pdo->query('SELECT * FROM transactions WHERE id = '.$id)->fetch(PDO::FETCH_ASSOC))
		{
			$this->data['vouchers'] = array();
			foreach (glob(APPPATH.'user_content/vouchers/'.$id.'/*') as $voucher)
				$this->data['vouchers'][] = pathinfo($voucher, PATHINFO_BASENAME);

			return TRUE;
		}

		return FALSE;
	}

}
