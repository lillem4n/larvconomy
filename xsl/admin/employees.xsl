<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="tpl.default.xsl" />

	<xsl:template name="tabs">
		<ul class="tabs">
			<li>
				<a href="employees">
					<xsl:if test="/root/meta/action = 'index'">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>Employees</xsl:text>
				</a>
			</li>
			<li>
				<a href="employees/employee">
					<xsl:if test="/root/meta/action = 'employee' and not(/root/meta/url_params/id)">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>New employee</xsl:text>
				</a>
			</li>
		</ul>
	</xsl:template>


	<xsl:template match="/">
		<xsl:if test="/root/content[../meta/action = 'index']">
			<xsl:call-template name="template">
				<xsl:with-param name="title" select="'Admin - Employees'" />
				<xsl:with-param name="h1" select="'Employees'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="/root/content[../meta/action = 'employee'] and not(/root/meta/url_params/id)">
			<xsl:call-template name="template">
				<xsl:with-param name="title" select="'Admin - New employee'" />
				<xsl:with-param name="h1" select="'New employee'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="/root/content[../meta/action = 'employee'] and /root/meta/url_params/id">
			<xsl:call-template name="template">
				<xsl:with-param name="title" select="'Admin - Employee details'" />
				<xsl:with-param name="h1" select="'Employee details'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>


	<!-- List employees -->
	<xsl:template match="content[../meta/action = 'index']">
		<table>
			<thead>
				<tr>
					<th class="small_row">ID</th>
					<th class="medium_row">Lastname</th>
					<th class="medium_row">Firstname</th>
					<th class="medium_row">SSN</th>
					<th>Address</th>
					<th>Email</th>
					<th class="medium_row">Tax lvl</th>
					<th class="medium_row">Status</th>
					<th class="medium_row">Action</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="employees/employee">
					<tr>
						<xsl:if test="position() mod 2 = 1">
							<xsl:attribute name="class">odd</xsl:attribute>
						</xsl:if>
						<td><xsl:value-of select="@id" /></td>
						<td><xsl:value-of select="lastname" /></td>
						<td><xsl:value-of select="firstname" /></td>
						<td><xsl:value-of select="SSN" /></td>
						<td>
							<xsl:value-of select="street" />
							<xsl:text>, </xsl:text>
							<xsl:value-of select="zip" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="city" />
						</td>
						<td><xsl:value-of select="email" /></td>
						<td><xsl:value-of select="tax_level" />%</td>
						<td><xsl:value-of select="status" /></td>
						<td>
							<xsl:text>[</xsl:text><a href="employees/employee?id={@id}">Details/Edit</a><xsl:text>]</xsl:text>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<!-- New/edit employee -->
	<xsl:template match="content[../meta/action = 'employee']">
		<form method="post">
			<xsl:if test="/root/meta/url_params/id">
				<xsl:attribute name="action">employees/employee?id=<xsl:value-of select="/root/meta/url_params/id" /></xsl:attribute>
			</xsl:if>
			<xsl:if test="not(/root/meta/url_params/id)">
				<xsl:attribute name="action">employees/employee</xsl:attribute>
			</xsl:if>

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

			<xsl:if test="/root/meta/url_params/id">
				<xsl:call-template name="form_line">
					<xsl:with-param name="id" select="'id'" />
					<xsl:with-param name="label" select="'ID:'" />
					<xsl:with-param name="type" select="'none'" />
					<xsl:with-param name="value" select="/root/meta/url_params/id" />
				</xsl:call-template>
			</xsl:if>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'firstname'" />
				<xsl:with-param name="label" select="'Firstname:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'lastname'" />
				<xsl:with-param name="label" select="'Lastname:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'SSN'" />
				<xsl:with-param name="label" select="'SSN:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'bank_name'" />
				<xsl:with-param name="label" select="'Bank name:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'bank_account'" />
				<xsl:with-param name="label" select="'Bank account:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'street'" />
				<xsl:with-param name="label" select="'Street address:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'zip'" />
				<xsl:with-param name="label" select="'Zip code:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'city'" />
				<xsl:with-param name="label" select="'City:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'email'" />
				<xsl:with-param name="label" select="'Email:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'tax_level'" />
				<xsl:with-param name="label" select="'Tax level (%):'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'status'" />
				<xsl:with-param name="label" select="'Status:'" />
				<xsl:with-param name="options" select="statuses" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'comments'" />
				<xsl:with-param name="label" select="'Comments:'" />
				<xsl:with-param name="type" select="'textarea'" />
				<xsl:with-param name="rows" select="'5'" />
			</xsl:call-template>

			<xsl:if test="/root/meta/url_params/id">
				<xsl:call-template name="form_button">
					<xsl:with-param name="id" select="'save_changes'" />
					<xsl:with-param name="value" select="'Save changes'" />
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="not(/root/meta/url_params/id)">
				<xsl:call-template name="form_button">
					<xsl:with-param name="id" select="'create_employee'" />
					<xsl:with-param name="value" select="'Create employee'" />
				</xsl:call-template>
			</xsl:if>

		</form>
	</xsl:template>

</xsl:stylesheet>
