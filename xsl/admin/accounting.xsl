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
		<div style="width: 300px;">
			<form method="get">
				<p>From date: <input type="text" name="from_date" placeholder="YYYY-MM-DD" value="{/root/meta/url_params/from_date}" /></p>
				<p>To date: <input type="text" name="to_date" placeholder="YYYY-MM-DD" value="{/root/meta/url_params/to_date}" /></p>
				<p>
					<xsl:text>Cash position: </xsl:text>
					<select name="cash_position">
						<xsl:for-each select="/root/content/cash_positions/cash_position">
							<option value="{.}">
								<xsl:if test=". = /root/meta/url_params/cash_position">
									<xsl:attribute name="selected">selected</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="." />
							</option>
						</xsl:for-each>
					</select>
				</p>
				<p>
					<button style="float: right;" type="submit">Show</button>
					<button style="float: right;" type="submit" name="downloadvouchers">Download vouchers</button>
				</p>
			</form>
		</div>
		<table>
			<thead>
				<tr>
					<th class="medium_row" style="white-space: nowrap;">
						<a href="/admin/accounting?cash_position={/root/meta/url_params/cash_position}&amp;from_date={/root/meta/url_params/from_date}&amp;to_date={/root/meta/url_params/to_date}&amp;order_by=accounting_date">Accounting date</a>
					</th>
					<th class="medium_row" style="white-space: nowrap;">
						<a href="/admin/accounting?cash_position={/root/meta/url_params/cash_position}&amp;from_date={/root/meta/url_params/from_date}&amp;to_date={/root/meta/url_params/to_date}&amp;order_by=transfer_date">Transfer date</a>
					</th>
					<!--th>Journal ID</th-->
					<th>Description</th>
					<th class="medium_row right">Sum</th>
					<th class="medium_row right">VAT</th>
					<th class="medium_row right">Balance</th>
					<th>Employee</th>
					<th class="medium_row" style="white-space: nowrap;">Action</th>
					<th>Vouchers</th>
				</tr>
			</thead>
			<tfoot>
				<tr>
					<th colspan="3"></th>
					<th class="right"><xsl:value-of select="format-number(number(balances/balance), '#,##0.00')" /></th>
					<th class="right"><xsl:value-of select="format-number(number(balances/vat_balance), '#,##0.00')" /></th>
					<th colspan="4"></th>
				</tr>
			</tfoot>
			<tbody>
				<xsl:apply-templates select="accounting/entry[1]">
					<xsl:sort select="transfer_date" />
				</xsl:apply-templates>
			</tbody>
		</table>
	</xsl:template>

	<xsl:template match="entry">
		<xsl:param name="odd_or_even" select="'odd'" />

		<tr class="{$odd_or_even}">
			<td style="white-space: nowrap;"><xsl:value-of select="accounting_date" /></td>
			<td style="white-space: nowrap;"><xsl:value-of select="transfer_date" /></td>
			<!--td><xsl:value-of select="journal_id" /></td-->
			<td><xsl:value-of select="description" /></td>
			<td style="white-space: nowrap;" class="right"><xsl:value-of select="format-number(number(sum), '#,##0.00')" /></td>
			<td style="white-space: nowrap;" class="right"><xsl:value-of select="format-number(number(vat), '#,##0.00')" /></td>
			<td style="white-space: nowrap;" class="right"><xsl:value-of select="format-number(number(balance), '#,##0.00')" /></td>
			<td><xsl:value-of select="employee_firstname" /><xsl:text> </xsl:text><xsl:value-of select="employee_lastname" /></td>
			<td>[<a href="accounting/entry?id={@id}">Edit</a>]</td>
			<td>
				<xsl:for-each select="vouchers/voucher">
					<a href="/user_content/vouchers/{../../@id}/{.}">
						<xsl:value-of select="position()" />
					</a>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</td>
		</tr>

		<xsl:if test="$odd_or_even = 'odd'">
			<xsl:apply-templates select="following-sibling::entry[1]">
				<xsl:with-param name="odd_or_even" select="'even'" />
			</xsl:apply-templates>
		</xsl:if>
		<xsl:if test="$odd_or_even = 'even'">
			<xsl:apply-templates select="following-sibling::entry[1]">
				<xsl:with-param name="odd_or_even" select="'odd'" />
			</xsl:apply-templates>
		</xsl:if>

	</xsl:template>

	<!-- New/edit entry -->
	<xsl:template match="content[../meta/action = 'entry']">
		<form method="post" action="accounting/entry" enctype="multipart/form-data">
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
				<xsl:with-param name="id" select="'cash_position'" />
				<xsl:with-param name="label" select="'Cash position:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'account'" />
				<xsl:with-param name="label" select="'Account:'" />
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

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'voucher'" />
				<xsl:with-param name="type" select="'file'" />
			</xsl:call-template>

			<h2>Vouchers</h2>

			<xsl:for-each select="vouchers/voucher">
				<a href="/user_content/vouchers/{/root/meta/url_params/id}/{.}" class="voucher">
					<xsl:value-of select="." />
				</a>

				<xsl:call-template name="form_line">
					<xsl:with-param name="name" select="'rm_voucher[]'" />
					<xsl:with-param name="type" select="'checkbox'" />
					<xsl:with-param name="label" select="'Delete the voucher above'" />
				</xsl:call-template>
				<input type="hidden" name="rm_voucher_names[]" value="{.}" />
			</xsl:for-each>

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