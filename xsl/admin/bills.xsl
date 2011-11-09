<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:include href="tpl.default.xsl" />

	<xsl:template name="tabs">
		<ul class="tabs">
			<li>
				<a href="bills">
					<xsl:if test="/root/meta/action = 'index'">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>List bills</xsl:text>
				</a>
			</li>
			<li>
				<a href="bills/new_bill">
					<xsl:if test="/root/meta/action = 'new_bill'">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>New bill</xsl:text>
				</a>
			</li>
		</ul>
	</xsl:template>


  <xsl:template match="/">
  	<xsl:if test="/root/content[../meta/controller = 'bills' and ../meta/action = 'index']">
		  <xsl:call-template name="template">
		  	<xsl:with-param name="title" select="'Admin - Bills'" />
		  	<xsl:with-param name="h1" select="'Bills'" />
		  </xsl:call-template>
  	</xsl:if>
  	<xsl:if test="/root/content[../meta/controller = 'bills' and ../meta/action = 'new_bill']">
		  <xsl:call-template name="template">
		  	<xsl:with-param name="title" select="'Admin - Bills'" />
		  	<xsl:with-param name="h1" select="'New bill'" />
		  </xsl:call-template>
  	</xsl:if>
  	<xsl:if test="/root/content[../meta/controller = 'bills' and ../meta/action = 'view_bill']">
		  <xsl:call-template name="template">
		  	<xsl:with-param name="title" select="'Admin - Bills'" />
		  	<xsl:with-param name="h1" select="'View bill'" />
		  </xsl:call-template>
  	</xsl:if>
  </xsl:template>

	<!-- List bills -->
  <xsl:template match="content[../meta/controller = 'bills' and ../meta/action = 'index']">
		<table>
			<thead>
				<tr>
					<th class="small_row">ID</th>
					<th>Customer</th>
					<th>Date</th>
					<th>Due date</th>
					<th>Paid date</th>
					<th class="right">Sum</th>
					<th>PDF</th>
					<th class="medium_row">Action</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="bills/bill">
					<tr>
						<xsl:if test="position() mod 2 = 1">
							<xsl:attribute name="class">odd</xsl:attribute>
						</xsl:if>
						<td><xsl:value-of select="@id" /></td>
						<td><xsl:value-of select="customer_name" /></td>
						<td><xsl:value-of select="substring(date, 1, 10)" /></td>
						<td><xsl:value-of select="substring(due_date, 1, 10)" /></td>
						<td><xsl:value-of select="substring(paid_date, 1, 10)" /></td>
						<td class="right">
							<xsl:value-of select="format-number(number(sum), '###,###,###.00')" />
							<xsl:text> SEK</xsl:text>
						</td>
						<td><a href="http://{root/meta/domain}{/root/meta/base}{concat('user_content/pdf/bill_',@id,'.pdf')}">Link</a></td>
						<td>
							<xsl:text>[</xsl:text><a href="http://{root/meta/domain}{/root/meta/base}bill?billnr={@id}">Details</a><xsl:text>]</xsl:text>
							<xsl:if test="paid_date = ''">
								<xsl:text>[</xsl:text><a href="bills/mark_as_paid/{@id}/{/root/meta/current_date}" class="paylink" id="paylink_{@id}">Mark as paid</a><xsl:text>]</xsl:text>
							</xsl:if>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
  </xsl:template>

	<!-- New bill -->
  <xsl:template match="content[../meta/controller = 'bills' and ../meta/action = 'new_bill']">
		<form method="post" action="bills/new_bill">

			<!-- Include an error -->
			<!--xsl:if test="/root/content/errors/form_errors/field_name = 'User::field_name_available'">
				<xsl:call-template name="form_line">
					<xsl:with-param name="id" select="'field_name'" />
					<xsl:with-param name="label" select="'Field name:'" />
					<xsl:with-param name="error" select="'This field name is already taken'" />
				</xsl:call-template>
			</xsl:if-->

			<!-- no error -->
			<!--xsl:if test="not(/root/content/errors/form_errors/field_name = 'User::field_name_available')">
				<xsl:call-template name="form_line">
					<xsl:with-param name="id" select="'field_name'" />
					<xsl:with-param name="label" select="'Field name:'" />
				</xsl:call-template>
			</xsl:if-->

			<label for="add_field">
				<xsl:text>Customer:</xsl:text>
				<select name="customer_id" id="customer_id">
					<xsl:for-each select="/root/content/customers/customer">
						<xsl:sort select="name" />
						<xsl:sort select="@id" />
						<option value="{@id}">
							<xsl:if test="@id = /root/content/formdata/field[@id = 'customer_id']">
								<xsl:attribute name="selected">selected</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="name" />
						</option>
					</xsl:for-each>
				</select>
			</label>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'due_date'" />
				<xsl:with-param name="label" select="'Due date:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'contact'" />
				<xsl:with-param name="label" select="'Their reference:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'comment'" />
				<xsl:with-param name="label" select="'Comment:'" />
				<xsl:with-param name="type" select="'textarea'" />
				<xsl:with-param name="rows" select="'5'" />
			</xsl:call-template>

			<h2>Items:</h2>
			<xsl:for-each select="/root/content/items/item">
				<p>Item <xsl:value-of select="." /></p>

				<xsl:call-template name="form_line">
					<xsl:with-param name="id" select="concat('artnr_item_',.)" />
					<xsl:with-param name="label" select="'Artnr:'" />
				</xsl:call-template>

				<xsl:call-template name="form_line">
					<xsl:with-param name="id" select="concat('spec_item_',.)" />
					<xsl:with-param name="label" select="'Specification:'" />
				</xsl:call-template>

				<xsl:call-template name="form_line">
					<xsl:with-param name="id" select="concat('price_item_',.)" />
					<xsl:with-param name="label" select="'Price:'" />
				</xsl:call-template>

				<xsl:call-template name="form_line">
					<xsl:with-param name="id" select="concat('qty_item_',.)" />
					<xsl:with-param name="label" select="'Quantity:'" />
				</xsl:call-template>

				<p>---</p>
			</xsl:for-each>

			<xsl:call-template name="form_button">
				<xsl:with-param name="id" select="'add_item'" />
				<xsl:with-param name="value" select="'Add another item'" />
			</xsl:call-template>


			<xsl:call-template name="form_button">
				<xsl:with-param name="id" select="'create_bill'" />
				<xsl:with-param name="value" select="'Create bill'" />
			</xsl:call-template>

		</form>
  </xsl:template>

	<!-- Edit customer -->
  <xsl:template match="content[../meta/controller = 'customers' and ../meta/action = 'edit_customer']">
		<form method="post" action="customers/edit_customer/{customer/@id}">

			<!-- Include an error -->
			<!--xsl:if test="/root/content/errors/form_errors/field_name = 'User::field_name_available'">
				<xsl:call-template name="form_line">
					<xsl:with-param name="id" select="'field_name'" />
					<xsl:with-param name="label" select="'Field name:'" />
					<xsl:with-param name="error" select="'This field name is already taken'" />
				</xsl:call-template>
			</xsl:if-->

			<!-- no error -->
			<!--xsl:if test="not(/root/content/errors/form_errors/field_name = 'User::field_name_available')">
				<xsl:call-template name="form_line">
					<xsl:with-param name="id" select="'field_name'" />
					<xsl:with-param name="label" select="'Field name:'" />
				</xsl:call-template>
			</xsl:if-->

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
