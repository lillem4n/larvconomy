<?php defined('SYSPATH') or die('No direct script access.');
if ( ! is_dir(APPPATH.'user_content/pdf'))         mkdir(APPPATH.'user_content/pdf');
if ( ! is_dir(APPPATH.'user_content/attachments')) mkdir(APPPATH.'user_content/attachments');

$pdo		= Kohana_pdo::instance('default');
$db_name	= Kohana::$config->load('pdo.default.database_name');
#$prefix		= Kohana::$config->load('pdo.default.db_prefix');
$columns	= $pdo->query('
					SHOW Tables in
						'.$db_name.'
					WHERE Tables_in_'.$db_name.'
					IN (\'bills_items\',
						\'bills\',
						\'employees\',
						\'transactions\',
						\'customers\')')
					->fetchAll(PDO::FETCH_COLUMN);

if (count($columns) != 5)
{
	$pdo->query('
		--
		-- Table structure for table `bills`
		--

		CREATE TABLE IF NOT EXISTS `bills` (
		  `id` int(11) NOT NULL AUTO_INCREMENT,
		  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
		  `due_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
		  `customer_id` int(10) unsigned NOT NULL,
		  `customer_name` varchar(255) COLLATE utf8_bin NOT NULL,
		  `customer_orgnr` bigint(20) unsigned NOT NULL,
		  `customer_contact` varchar(255) COLLATE utf8_bin NOT NULL,
		  `customer_tel` varchar(100) COLLATE utf8_bin NOT NULL,
		  `customer_email` varchar(100) COLLATE utf8_bin NOT NULL,
		  `customer_street` varchar(255) COLLATE utf8_bin NOT NULL,
		  `customer_zip` varchar(50) COLLATE utf8_bin NOT NULL,
		  `customer_city` varchar(255) COLLATE utf8_bin NOT NULL,
		  `comment` text COLLATE utf8_bin NOT NULL,
		  `paid_date` timestamp NULL DEFAULT NULL,
		  `contact` varchar(255) COLLATE utf8_bin NOT NULL,
		  `email_sent` timestamp NULL DEFAULT NULL,
		  `template` varchar(256) COLLATE utf8_bin NOT NULL,
		  `mail_body` text COLLATE utf8_bin NOT NULL,
		  PRIMARY KEY (`id`),
		  KEY `customer_id` (`customer_id`)
		) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

		-- --------------------------------------------------------

		--
		-- Table structure for table `bills_items`
		--

		CREATE TABLE IF NOT EXISTS `bills_items` (
			`item_id` int(11) NOT NULL,
			`bill_id` int(11) NOT NULL,
			`artnr` varchar(50) NOT NULL,
			`spec` varchar(255) NOT NULL,
			`qty` float NOT NULL,
			`price` double NOT NULL,
			`delivery_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
			PRIMARY KEY (`item_id`,`bill_id`)
		) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_bin;

		-- --------------------------------------------------------

		--
		-- Table structure for table `customers`
		--

		CREATE TABLE IF NOT EXISTS `customers` (
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
		) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_bin;

		-- --------------------------------------------------------

		--
		-- Table structure for table `employees`
		--


		CREATE TABLE IF NOT EXISTS `employees` (
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
		) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_bin;

		-- --------------------------------------------------------

		--
		-- Table structure for table `transactions`
		--

		CREATE TABLE IF NOT EXISTS `transactions` (
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
		) ENGINE = INNODB CHARACTER SET utf8 COLLATE utf8_bin;
	');
}
