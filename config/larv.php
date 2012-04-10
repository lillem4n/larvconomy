<?php defined('SYSPATH') or die('No direct access allowed.');

return array
(
	'soc_fee_levels' => array(
		array(
			'start_age'  => 0,
			'end_age'    => 26,
			'level'      => 15.49,
		),
		array(
			'start_age'  => 27,
			'end_age'    => 65,
			'level'      => 31.42,
		),
		array(
			'start_age'  => 66,
			'end_age'    => 73,
			'level'      => 10.21,
		),
	),
	'email' => array(
		'from'         => 'info@larvit.se',
		'from_name'    => 'Larv IT AB',
		'bill_message' => 'This email contains an invoice from Larv IT AB',
		'bill_subject' => 'Invoice',
	),
	'dev_account' => array(
		'username'     => 'username',
		'password'     => 'password'
	),
);
