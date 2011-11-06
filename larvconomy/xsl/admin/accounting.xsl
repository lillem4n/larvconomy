<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:include href="tpl.default.xsl" />

	<xsl:template name="tabs">
		<ul class="tabs">
			<li>
				<a href="accounting">
					<xsl:if test="/root/meta/action = 'index'">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>Accounting</xsl:text>
				</a>
			</li>
			<li>
				<a href="accounting/entry">
					<xsl:if test="/root/meta/action = 'entry' and not(/root/meta/url_params/id)">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>New entry</xsl:text>
				</a>
			</li>
		</ul>
	</xsl:template>


  <xsl:template match="/">
  	<xsl:if test="/root/content[../meta/action = 'index']">
		  <xsl:call-template name="template">
		  	<xsl:with-param name="title" select="'Admin - Accounting'" />
		  	<xsl:with-param name="h1" select="'Accounting'" />
		  </xsl:call-template>
  	</xsl:if>
  	<xsl:if test="/root/content[../meta/action = 'entry' and not(../meta/url_params/id)]">
		  <xsl:call-template name="template">
		  	<xsl:with-param name="title" select="'Admin - New entry'" />
		  	<xsl:with-param name="h1" select="'New entry'" />
		  </xsl:call-template>
  	</xsl:if>
  	<xsl:if test="/root/content[../meta/action = 'entry' and ../meta/url_params/id]">
		  <xsl:call-template name="template">
		  	<xsl:with-param name="title" select="'Admin - Edit entry'" />
		  	<xsl:with-param name="h1" select="'Edit entry'" />
		  </xsl:call-template>
  	</xsl:if>
  </xsl:template>

	<!-- List entries -->
  <xsl:template match="content[../meta/action = 'index']">
		<table>
			<thead>
				<tr>
					<th class="medium_row">Accounting date</th>
					<th class="medium_row">Transfer date</th>
					<th>Journal ID</th>
					<th>Description</th>
					<th class="medium_row right">Sum</th>
					<th class="medium_row right">VAT</th>
					<th class="medium_row right">Balance</th>
					<th>Employee</th>
					<th class="medium_row">Action</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<td colspan="4"></td>
					<td class="right"><xsl:value-of select="format-number(number(sum(accounting/entry/sum)), '#,##0.00')" /></td>
					<td class="right"><xsl:value-of select="format-number(number(sum(accounting/entry/vat)), '#,##0.00')" /></td>
					<td colspan="3"></td>
				</tr>
			</tfoot>
			<tbody>
				<xsl:apply-templates select="accounting/entry[1]" />
			</tbody>
		</table>
  </xsl:template>

	<xsl:template match="entry">
		<xsl:param name="balance" select="0" />
		<xsl:param name="odd_or_even" select="'odd'" />

		<tr class="{$odd_or_even}">
			<td><xsl:value-of select="accounting_date" /></td>
			<td><xsl:value-of select="transfer_date" /></td>
			<td><xsl:value-of select="journal_id" /></td>
			<td><xsl:value-of select="description" /></td>
			<td class="right"><xsl:value-of select="format-number(number(sum), '#,##0.00')" /></td>
			<td class="right"><xsl:value-of select="format-number(number(vat), '#,##0.00')" /></td>
			<td class="right"><xsl:value-of select="format-number(number($balance + sum), '#,##0.00')" /></td>
			<td><xsl:value-of select="employee_firstname" /><xsl:text> </xsl:text><xsl:value-of select="employee_lastname" /></td>
			<td>
				[<a>
				<xsl:attribute name="href">
					<xsl:text>accounting/entry?id=</xsl:text>
					<xsl:value-of select="@id" />
				</xsl:attribute>
				<xsl:text>Edit</xsl:text>
				</a>]
			</td>
		</tr>

		<xsl:if test="$odd_or_even = 'odd'">
			<xsl:apply-templates select="following-sibling::entry[1]">
				<xsl:with-param name="balance" select="$balance + sum" />
				<xsl:with-param name="odd_or_even" select="'even'" />
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="$odd_or_even = 'even'">
			<xsl:apply-templates select="following-sibling::entry[1]">
				<xsl:with-param name="balance" select="$balance + sum" />
				<xsl:with-param name="odd_or_even" select="'odd'" />
			</xsl:apply-templates>
		</xsl:if>

	</xsl:template>

	<!-- New/edit entry -->
  <xsl:template match="content[../meta/action = 'entry']">
		<form method="post" action="accounting/entry">
			<xsl:if test="../meta/url_params/id">
				<xsl:attribute name="action">accounting/entry?id=<xsl:value-of select="../meta/url_params/id" /></xsl:attribute>
			</xsl:if>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'accounting_date'" />
				<xsl:with-param name="label" select="'Accounting date:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'transfer_date'" />
				<xsl:with-param name="label" select="'Transfer date:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'description'" />
				<xsl:with-param name="label" select="'Description:'" />
				<xsl:with-param name="type" select="'textarea'" />
				<xsl:with-param name="rows" select="'5'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'journal_id'" />
				<xsl:with-param name="label" select="'Journal ID:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'sum'" />
				<xsl:with-param name="label" select="'Sum:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'vat'" />
				<xsl:with-param name="label" select="'VAT:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'employee_id'" />
				<xsl:with-param name="label" select="'Employee:'" />
				<xsl:with-param name="options" select="employees" />
			</xsl:call-template>

			<xsl:if test="../meta/url_params/id">
				<xsl:call-template name="form_button">
					<xsl:with-param name="id" select="'update_entry'" />
					<xsl:with-param name="value" select="'Update entry'" />
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="not(../meta/url_params/id)">
				<xsl:call-template name="form_button">
					<xsl:with-param name="id" select="'create_entry'" />
					<xsl:with-param name="value" select="'Create entry'" />
				</xsl:call-template>
			</xsl:if>

		</form>
  </xsl:template>

</xsl:stylesheet>
