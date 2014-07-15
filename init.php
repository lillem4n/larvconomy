<?php defined('SYSPATH') or die('No direct script access.');

if ( ! is_dir(APPPATH.'user_content/pdf'))
	mkdir(APPPATH.'user_content/pdf');

$pdo         = Kohana_pdo::instance('default');
$column_name = 'Tables_in_'.Kohana::$config->load('pdo.default.database_name');
$columns     = $pdo->query('
	SHOW TABLES
	WHERE
		'.$column_name.' = \'bills\' OR
		'.$column_name.' = \'bills_items\' OR
		'.$column_name.' = \'employees\' OR
		'.$column_name.' = \'transactions\' OR
		'.$column_name.' = \'customers\'
	')->fetchAll(PDO::FETCH_COLUMN);

if (count($columns) != 5)
{
	$pdo->query('CREATE TABLE `bills` (
		`id` int(11) NOT NULL AUTO_INCREMENT,
		`date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
		`due_date` timestamp NOT NULL DEFAULT \'0000-00-00 00:00:00\',
		`customer_id` int(10) unsigned NOT NULL,
		`customer_name` varchar(255) NOT NULL,
		`customer_orgnr` bigint(20) unsigned NOT NULL,
		`customer_contact` varchar(255) NOT NULL,
		`customer_tel` varchar(100) NOT NULL,
		`customer_email` varchar(100) NOT NULL,
		`customer_street` varchar(255) NOT NULL,
		`customer_zip` varchar(50) NOT NULL,
		`customer_city` varchar(255) NOT NULL,
		`comment` text NOT NULL,
		`paid_date` timestamp NULL DEFAULT NULL,
		`contact` varchar(255) NOT NULL,
		`email_sent` timestamp NULL DEFAULT NULL,
		PRIMARY KEY (`id`),
		KEY `customer_id` (`customer_id`)
	) ENGINE=MyISAM  DEFAULT CHARSET=latin1;
	CREATE TABLE `bills_items` (
		`item_id` int(11) NOT NULL,
		`bill_id` int(11) NOT NULL,
		`artnr` varchar(50) NOT NULL,
		`spec` varchar(255) NOT NULL,
		`qty` float NOT NULL,
		`price` double NOT NULL,
		`delivery_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		PRIMARY KEY (`item_id`,`bill_id`)
	) ENGINE=MyISAM DEFAULT CHARSET=latin1;
	CREATE TABLE `employees` (
		`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`lastname` varchar(255) NOT NULL,
		`firstname` varchar(255) NOT NULL,
		`SSN` varchar(100) NOT NULL,
		`bank_name` varchar(255) DEFAULT NULL,
		`bank_account` varchar(255) DEFAULT NULL,
		`street` varchar(255) NOT NULL,
		`zip` varchar(255) NOT NULL,
		`city` varchar(255) NOT NULL,
		`status` varchar(100) NOT NULL,
		`comments` text NOT NULL,
		`tax_level` float NOT NULL,
		`email` varchar(255) NOT NULL,
		PRIMARY KEY (`id`)
	) ENGINE=MyISAM  DEFAULT CHARSET=latin1;
	CREATE TABLE `transactions` (
		`id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
		`accounting_date` date NOT NULL,
		`transfer_date` date DEFAULT NULL,
		`description` text NOT NULL,
		`journal_id` varchar(255) DEFAULT NULL,
		`vat` double NOT NULL,
		`sum` double NOT NULL,
		`employee_id` int(10) unsigned DEFAULT NULL,
		PRIMARY KEY (`id`),
		KEY `journal_id` (`journal_id`),
		KEY `employee_id` (`employee_id`)
	) ENGINE=MyISAM  DEFAULT CHARSET=latin1;
	CREATE TABLE `customers` (
		`id` int(10) unsigned NOT NULL AUTO_INCREMENT,
		`name` varchar(255) NOT NULL,
		`orgnr` bigint(20) unsigned NOT NULL,
		`contact` varchar(255) NOT NULL,
		`tel` varchar(100) NOT NULL,
		`email` varchar(100) NOT NULL,
		`street` varchar(255) NOT NULL,
		`zip` varchar(50) NOT NULL,
		`city` varchar(255) NOT NULL,
		`comment` text NOT NULL,
		PRIMARY KEY (`id`)
	) ENGINE=MyISAM  DEFAULT CHARSET=latin1;');

}