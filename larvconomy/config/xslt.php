<?php defined('SYSPATH') or die('No direct script access.');


return array(
	/**
	 * Decides where the transformation of XSLT->HTML
	 * should be done
	 * ATTENTION! This setting is configurable in xslt.php
	 *
	 * options:
	 * 'auto' = Normally sends XML+XSLT, but sometimes HTML,
	 *          depending on the HTTP_USER_AGENT (see user_agents
	 *          setting)
	 * TRUE   = Always send HTML
	 * FALSE  = Always send XML+XSLT
	 */
	'transform'   => 'auto',

	/**
	 * Define wich user agents who will trigger an auto transform
	 *
	 */
	'user_agents' => array(
		'Firefox/2.0',
		'Googlebot',
		'MSIE 4.0',
		'MSIE 5.0',
		'MSIE 6.0',           // This is to give opera the HTML version... and also I dont trust IE6 ;)
		'acebookexternalhit', // Facebook resolving, facebook is incompetent and cannot handle XSLT
	),
);
