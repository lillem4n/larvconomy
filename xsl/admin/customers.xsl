<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:include href="tpl.default.xsl" />

	<xsl:template name="tabs">
		<ul class="tabs">
			<li>
				<a href="customers">
					<xsl:if test="/root/meta/action = 'index'">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>List customers</xsl:text>
				</a>
			</li>
			<li>
				<a href="customers/add_customer">
					<xsl:if test="/root/meta/action = 'add_customer'">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>Add customer</xsl:text>
				</a>
			</li>
		</ul>
	</xsl:template>


  <xsl:template match="/">
  	<xsl:if test="/root/content[../meta/controller = 'customers' and ../meta/action = 'index']">
		  <xsl:call-template name="template">
		  	<xsl:with-param name="title" select="'Admin - Customers'" />
		  	<xsl:with-param name="h1" select="'Customers'" />
		  </xsl:call-template>
  	</xsl:if>
  	<xsl:if test="/root/content[../meta/controller = 'customers' and ../meta/action = 'add_customer']">
		  <xsl:call-template name="template">
		  	<xsl:with-param name="title" select="'Admin - Customers'" />
		  	<xsl:with-param name="h1" select="'Add customer'" />
		  </xsl:call-template>
  	</xsl:if>
  	<xsl:if test="/root/content[../meta/controller = 'customers' and ../meta/action = 'edit_customer']">
		  <xsl:call-template name="template">
		  	<xsl:with-param name="title" select="'Admin - Customers'" />
		  	<xsl:with-param name="h1" select="'Edit customer'" />
		  </xsl:call-template>
  	</xsl:if>
  </xsl:template>

	<!-- List customers -->
  <xsl:template match="content[../meta/controller = 'customers' and ../meta/action = 'index']">
		<table>
			<thead>
				<tr>
					<th class="small_row">ID</th>
					<th>Name</th>
					<th>Orgnr</th>
					<th>Contact</th>
					<th>Tel</th>
					<th>Email</th>
					<th>Address</th>
					<th class="medium_row">Action</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="customers/customer">
					<tr>
						<xsl:if test="position() mod 2 = 1">
							<xsl:attribute name="class">odd</xsl:attribute>
						</xsl:if>
						<td><xsl:value-of select="@id" /></td>
						<td><xsl:value-of select="name" /></td>
						<td><xsl:value-of select="orgnr" /></td>
						<td><xsl:value-of select="contact" /></td>
						<td><xsl:value-of select="tel" /></td>
						<td><xsl:value-of select="email" /></td>
						<td>
							<xsl:value-of select="street" />
							<xsl:text>, </xsl:text>
							<xsl:value-of select="substring(zip,1,3)" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="substring(zip,4,2)" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="city" />
						</td>
						<td>
							[<a>
							<xsl:attribute name="href">
								<xsl:text>customers/edit_customer/</xsl:text>
								<xsl:value-of select="@id" />
							</xsl:attribute>
							<xsl:text>Edit</xsl:text>
							</a>]
							<!--[<a>
							<xsl:attribute name="href">
								<xsl:text>customers/rm_customer/</xsl:text>
								<xsl:value-of select="@id" />
							</xsl:attribute>
							<xsl:text>Delete</xsl:text>
							</a>]-->
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
  </xsl:template>

	<!-- Add customer -->
  <xsl:template match="content[../meta/controller = 'customers' and ../meta/action = 'add_customer']">
		<form method="post" action="customers/add_customer">

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'name'" />
				<xsl:with-param name="label" select="'Company name:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'orgnr'" />
				<xsl:with-param name="label" select="'Orgnr:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'contact'" />
				<xsl:with-param name="label" select="'Contact:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'tel'" />
				<xsl:with-param name="label" select="'Tel:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'email'" />
				<xsl:with-param name="label" select="'Email:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'street'" />
				<xsl:with-param name="label" select="'Street:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'zip'" />
				<xsl:with-param name="label" select="'Zip:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'city'" />
				<xsl:with-param name="label" select="'City:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'comment'" />
				<xsl:with-param name="label" select="'Comment:'" />
			</xsl:call-template>

			<xsl:call-template name="form_button">
				<xsl:with-param name="value" select="'Add'" />
			</xsl:call-template>

		</form>
  </xsl:template>

	<!-- Edit customer -->
  <xsl:template match="content[../meta/controller = 'customers' and ../meta/action = 'edit_customer']">
		<form method="post" action="customers/edit_customer/{customer/@id}">

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'name'" />
				<xsl:with-param name="label" select="'Company name:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'orgnr'" />
				<xsl:with-param name="label" select="'Orgnr:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'contact'" />
				<xsl:with-param name="label" select="'Contact:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'tel'" />
				<xsl:with-param name="label" select="'Tel:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'email'" />
				<xsl:with-param name="label" select="'Email:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'street'" />
				<xsl:with-param name="label" select="'Street:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'zip'" />
				<xsl:with-param name="label" select="'Zip:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'city'" />
				<xsl:with-param name="label" select="'City:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'comment'" />
				<xsl:with-param name="label" select="'Comment:'" />
			</xsl:call-template>

			<xsl:call-template name="form_button">
				<xsl:with-param name="value" select="'Save'" />
			</xsl:call-template>

		</form>
  </xsl:template>

</xsl:stylesheet>
