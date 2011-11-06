<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:decimal-format
   decimal-separator='.'
   grouping-separator=','
	/>

	<xsl:include href="tpl.default.xsl" />

	<xsl:template name="tabs">
		<ul class="tabs">
			<li>
				<a href="wages">
					<xsl:if test="/root/meta/action = 'index'">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>Wages</xsl:text>
				</a>
			</li>
			<li>
				<a href="wages/payouts">
					<xsl:if test="/root/meta/action = 'payouts'">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>Payouts</xsl:text>
				</a>
			</li>
			<li>
				<a href="wages/payout">
					<xsl:if test="/root/meta/action = 'payout' and not(/root/meta/url_params/id)">
						<xsl:attribute name="class">selected</xsl:attribute>
					</xsl:if>
					<xsl:text>New payout</xsl:text>
				</a>
			</li>
		</ul>
	</xsl:template>

	<xsl:template match="/">
		<xsl:if test="/root/content[../meta/action = 'index']">
			<xsl:call-template name="template">
				<xsl:with-param name="title" select="'Admin - Wages'" />
				<xsl:with-param name="h1" select="'Wages'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="/root/content[../meta/action = 'payouts']">
			<xsl:call-template name="template">
				<xsl:with-param name="title" select="'Admin - Payouts'" />
				<xsl:with-param name="h1" select="'Payouts'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="/root/content[../meta/action = 'payout'] and not(/root/meta/url_params/id)">
			<xsl:call-template name="template">
				<xsl:with-param name="title" select="'Admin - New payout'" />
				<xsl:with-param name="h1" select="'New payout'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="/root/content[../meta/action = 'payout'] and /root/meta/url_params/id">
			<xsl:call-template name="template">
				<xsl:with-param name="title" select="'Admin - Edit payout'" />
				<xsl:with-param name="h1" select="'Edit payout'" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- Wages statistics and stuff -->
	<xsl:template match="content[../meta/action = 'index']">
		<form id="periods" method="get">

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'period'" />
				<xsl:with-param name="label" select="'Period:'" />
				<xsl:with-param name="options" select="periods" />
			</xsl:call-template>

			<xsl:call-template name="form_button">
				<xsl:with-param name="id" select="'update_button'" />
				<xsl:with-param name="value" select="'Update'" />
			</xsl:call-template>

		</form>
		<form id="wages" method="post">

			<h2>Grand totals</h2>

			<div class="form_line">
				<xsl:text>Total salary cost:</xsl:text>
				<span><xsl:value-of select="format-number(sum(employees_totals/employee/payout_cost) + sum(employees_totals/employee/income_tax_cost) + sum(employees_totals/employee/soc_fee_cost), '#,###.00')" /></span>
			</div>

			<div class="form_line">
				<xsl:text>Social fee cost:</xsl:text>
				<span><xsl:value-of select="format-number(sum(employees_totals/employee/soc_fee_cost), '#,###.00')" /></span>
			</div>

			<div class="form_line">
				<xsl:text>Gross pay cost:</xsl:text>
				<span><xsl:value-of select="format-number(sum(employees_totals/employee/payout_cost) + sum(employees_totals/employee/income_tax_cost), '#,###.00')" /></span>
			</div>

			<div class="form_line">
				<xsl:text>Total income tax cost:</xsl:text>
				<span><xsl:value-of select="format-number(sum(employees_totals/employee/income_tax_cost), '#,###.00')" /></span>
			</div>

			<div class="form_line">
				<xsl:text>Total to pay tax collector:</xsl:text>
				<span><xsl:value-of select="format-number(sum(employees_totals/employee/soc_fee_cost) + sum(employees_totals/employee/income_tax_cost), '#,###.00')" /></span>
			</div>

			<div class="form_line">
				<xsl:text>Total payout cost:</xsl:text>
				<span><xsl:value-of select="format-number(sum(employees_totals/employee/payout_cost), '#,###.00')" /></span>
			</div>

			<h2>Individual salary</h2>
			<p>Submit to get a pay slip. If you submit you cannot change these values or do additional payouts for this month.</p>

			<xsl:for-each select="employees_totals/employee">
				<xsl:sort select="lastname" />
				<xsl:sort select="firstname" />

				<xsl:if test="calculated">
					<h3><xsl:value-of select="lastname" />, <xsl:value-of select="firstname" /> [Pay slip]</h3>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id" select="concat('total_salary_cost_',@id)" />
						<xsl:with-param name="label" select="'Total salary cost:'" />
						<xsl:with-param name="value" select="sum(payout_cost) + sum(income_tax_cost) + sum(soc_fee_cost)" />
						<xsl:with-param name="disabled" select="'yeah'" />
					</xsl:call-template>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id" select="concat('social_fee_cost_',@id)" />
						<xsl:with-param name="label" select="'Social fee cost:'" />
						<xsl:with-param name="value" select="sum(soc_fee_cost)" />
					</xsl:call-template>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id" select="concat('gross_pay_cost_',@id)" />
						<xsl:with-param name="label" select="'Gross pay cost:'" />
						<xsl:with-param name="value" select="sum(payout_cost) + sum(income_tax_cost)" />
					</xsl:call-template>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id" select="concat('income_tax_cost_',@id)" />
						<xsl:with-param name="label" select="'Income tax cost:'" />
						<xsl:with-param name="value" select="sum(income_tax_cost)" />
					</xsl:call-template>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id" select="concat('total_to_pay_tax_collector_',@id)" />
						<xsl:with-param name="label" select="'Total to pay tax collector:'" />
						<xsl:with-param name="value" select="sum(income_tax_cost) + sum(soc_fee_cost)" />
						<xsl:with-param name="disabled" select="'yeah'" />
					</xsl:call-template>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id" select="concat('total_payout_',@id)" />
						<xsl:with-param name="label" select="'Total payout:'" />
						<xsl:with-param name="value" select="sum(payout_cost)" />
						<xsl:with-param name="type" select="'none'" />
					</xsl:call-template>
					<xsl:call-template name="form_button">
						<xsl:with-param name="id" select="concat('submit_button_',@id)" />
						<xsl:with-param name="value" select="'Submit!'" />
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="not(calculated)">
					<h3><xsl:value-of select="lastname" />, <xsl:value-of select="firstname" /> [<a href="#">Pay slip</a>]</h3>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id" select="concat('total_salary_cost_',@id)" />
						<xsl:with-param name="label" select="'Total salary cost:'" />
						<xsl:with-param name="value" select="sum(payout_cost) + sum(income_tax_cost) + sum(soc_fee_cost)" />
						<xsl:with-param name="type" select="'none'" />
					</xsl:call-template>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id" select="concat('social_fee_cost_',@id)" />
						<xsl:with-param name="label" select="'Social fee cost:'" />
						<xsl:with-param name="value" select="sum(soc_fee_cost)" />
						<xsl:with-param name="type" select="'none'" />
					</xsl:call-template>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id" select="concat('gross_pay_cost_',@id)" />
						<xsl:with-param name="label" select="'Gross pay cost:'" />
						<xsl:with-param name="value" select="sum(payout_cost) + sum(income_tax_cost)" />
						<xsl:with-param name="type" select="'none'" />
					</xsl:call-template>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id" select="concat('income_tax_cost_',@id)" />
						<xsl:with-param name="label" select="'Income tax cost:'" />
						<xsl:with-param name="value" select="sum(income_tax_cost)" />
						<xsl:with-param name="type" select="'none'" />
					</xsl:call-template>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id" select="concat('total_to_pay_tax_collector_',@id)" />
						<xsl:with-param name="label" select="'Total to pay tax collector:'" />
						<xsl:with-param name="value" select="sum(income_tax_cost) + sum(soc_fee_cost)" />
						<xsl:with-param name="type" select="'none'" />
					</xsl:call-template>
					<xsl:call-template name="form_line">
						<xsl:with-param name="id" select="concat('total_payout_',@id)" />
						<xsl:with-param name="label" select="'Total payout:'" />
						<xsl:with-param name="value" select="sum(payout_cost)" />
						<xsl:with-param name="type" select="'none'" />
					</xsl:call-template>
				</xsl:if>

				<br style="clear: both;" />

			</xsl:for-each>

		</form>
	</xsl:template>

	<!-- List payouts -->
	<xsl:template match="content[../meta/action = 'payouts']">
		<table>
			<thead>
				<tr>
					<th>Date</th>
					<th>Employee</th>
					<th class="right">Sum</th>
					<th class="medium_row">Action</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="payouts/payout">
					<tr>
						<xsl:if test="position() mod 2 = 1">
							<xsl:attribute name="class">odd</xsl:attribute>
						</xsl:if>
						<td><xsl:value-of select="transfer_date" /></td>
						<td><xsl:value-of select="employee_lastname" />, <xsl:value-of select="employee_firstname" /></td>
						<td class="right"><xsl:value-of select="format-number(-sum, '#,###.00')" /></td>
						<td>
							[<a>
							<xsl:attribute name="href">
								<xsl:text>wages/payout/?id=</xsl:text>
								<xsl:value-of select="@id" />
							</xsl:attribute>
							<xsl:text>Edit</xsl:text>
							</a>]
							[<a>
							<xsl:attribute name="href">
								<xsl:text>wages/payout/?action=delete&amp;id=</xsl:text>
								<xsl:value-of select="@id" />
							</xsl:attribute>
							<xsl:text>Delete</xsl:text>
							</a>]
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>

	<!-- New/edit payout -->
	<xsl:template match="content[../meta/action = 'payout']">
		<div style="display: none;">
			<!-- Data needed by the javascripts to determine calculations -->
			<xsl:for-each select="employees/employee">
				<div id="employee_{@id}">
					<xsl:for-each select="current()/*">
						<div class="{local-name()}"><xsl:value-of select="." /></div>
					</xsl:for-each>
				</div>
			</xsl:for-each>
		</div>

		<form method="post">
			<xsl:if test="/root/meta/url_params/id">
				<xsl:attribute name="action">wages/payout?id=<xsl:value-of select="/root/meta/url_params/id" /></xsl:attribute>
			</xsl:if>
			<xsl:if test="not(/root/meta/url_params/id)">
				<xsl:attribute name="action">wages/payout</xsl:attribute>
			</xsl:if>

			<!--xsl:if test="/root/meta/url_params/id">
				<xsl:call-template name="form_line">
					<xsl:with-param name="id" select="'id'" />
					<xsl:with-param name="label" select="'ID:'" />
					<xsl:with-param name="type" select="'none'" />
					<xsl:with-param name="value" select="/root/meta/url_params/id" />
				</xsl:call-template>
			</xsl:if-->

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'employee_id'" />
				<xsl:with-param name="label" select="'Employee:'" />
				<xsl:with-param name="options" select="employees" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'date'" />
				<xsl:with-param name="label" select="'Date (YYYY-MM-DD):'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'amount'" />
				<xsl:with-param name="label" select="'Amount:'" />
			</xsl:call-template>

			<h2>References</h2>
			<p>These values will not be saved, they are just used to support the payout calculation.</p>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'gross_pay'" />
				<xsl:with-param name="label" select="'Gross pay:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'tax_level'" />
				<xsl:with-param name="label" select="'Tax level (%):'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'soc_fee_level'" />
				<xsl:with-param name="label" select="'Social fee level (%):'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'soc_fees'" />
				<xsl:with-param name="label" select="'Social fees:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'income_taxes'" />
				<xsl:with-param name="label" select="'Income taxes:'" />
			</xsl:call-template>

			<xsl:call-template name="form_line">
				<xsl:with-param name="id" select="'total_cost'" />
				<xsl:with-param name="label" select="'Total payout cost:'" />
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
					<xsl:with-param name="value" select="'Create payout'" />
				</xsl:call-template>
			</xsl:if>

		</form>
	</xsl:template>

</xsl:stylesheet>
