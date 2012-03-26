<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- INCLUDES -->
	<!--xsl:include href="inc.elements.xsl" /-->
	<xsl:include href="inc.common.xsl" />

	<xsl:output
		method="html"
		encoding="utf-8"
		indent="no"
	/>

	<xsl:key name="nav_categories" match="/root/content/menuoptions/menuoption" use="@category" />

	<!-- TEMPLATE -->
	<xsl:template name="template">
		<xsl:param name="title" />
		<xsl:param name="h1" />

		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
				<link type="text/css" href="{/root/meta/base}css/admin/larvconomy.css" rel="stylesheet" media="all" />
				<link href='http://fonts.googleapis.com/css?family=Cuprum&amp;subset=latin' rel='stylesheet' type='text/css' />
				<script type="text/javascript" src="{/root/meta/base}js/jquery-1.6.2.min.js"><xsl:comment></xsl:comment></script>
				<script type="text/javascript" src="{/root/meta/base}js/common.js"><xsl:comment></xsl:comment></script>
				<base href="http://{root/meta/domain}{/root/meta/base}admin/" />
				<title><xsl:value-of select="$title" /></title>
				<!--[if lt IE 7]>
					<style media="screen" type="text/css">
						.contentwrap2
						{
							width: 100%;
						}
					</style>
				<![endif]-->
			</head>
			<body>

				<xsl:call-template name="header" />

				<div class="colsoutercontainer">
					<div class="colscontainer">

						<div class="contentwrap">
							<div class="contentwrap2">

								<h1><xsl:value-of select="$h1" /></h1>
								<xsl:call-template name="tabs" />
								<div class="content">
									<!-- Content start -->

									<xsl:for-each select="/root/content/errors/error">
										<div class="error"><xsl:value-of select="." /></div>
									</xsl:for-each>
									<xsl:for-each select="/root/content/messages/message">
										<div class="message"><xsl:value-of select="." /></div>
									</xsl:for-each>

									<xsl:apply-templates select="/root/content" />

									<!-- Content end -->
								</div>

							</div>
						</div>

						<div class="menu">
							<!-- Menu start -->

							<xsl:for-each select="/root/content/menuoptions/menuoption">
								<xsl:sort select="@category" />
								<xsl:if test="generate-id() = generate-id(key('nav_categories',@category))">
									<div>
										<p>
											<xsl:if test="@category != ''">
												<xsl:value-of select="@category" />
											</xsl:if>
											<xsl:if test="@category = ''">
												<xsl:text>System</xsl:text>
											</xsl:if>
										</p>
										<ul>
											<xsl:call-template name="menuoptions">
												<xsl:with-param name="cat_name" select="@category" />
											</xsl:call-template>
										</ul>
									</div>
								</xsl:if>
							</xsl:for-each>

							<!-- Menu end -->
						</div>

					</div>
				</div>

				<!--div id="footer">
					Fot
				</div-->
			</body>
		</html>
	</xsl:template>

	<xsl:template name="menuoptions">
		<xsl:param name="cat_name" />

		<xsl:for-each select="/root/content/menuoptions/menuoption">
			<xsl:sort select="position" />
			<xsl:if test="@category = $cat_name">
				<li>
					<a href="{href}">
						<xsl:if test="/root/meta/admin_page = name">
							<xsl:attribute name="class">selected</xsl:attribute>
						</xsl:if>
						<xsl:if test="not(/root/meta/admin_page) and href = ''">
							<xsl:attribute name="class">selected</xsl:attribute>
						</xsl:if>
						<xsl:value-of select="name" />
					</a>
				</li>
			</xsl:if>
		</xsl:for-each>

	</xsl:template>

</xsl:stylesheet>
