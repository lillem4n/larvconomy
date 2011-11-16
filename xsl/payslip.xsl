<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="html" encoding="utf-8" />

	<xsl:decimal-format
   decimal-separator=','
   grouping-separator='&#160;'
	/>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
				<link type="text/css" href="css/pdfs.css" rel="stylesheet" media="all" />

				<base href="http://{root/meta/domain}{root/meta/base}" />

				<title>Pay slip</title>
			</head>
			<body>
				<h1>Lönebesked</h1>

				<img src="img/larvit_rgb_fullfarg.png" alt="" />

				<table class="box_table">
					<tr class="column_decider">
						<td class="col1 nocontent"></td>
						<td class="nocontent hclearer"></td>
						<td class="col2 nocontent"></td>
						<td class="nocontent hclearer"></td>

						<td class="col3 nocontent"></td>
						<td class="nocontent hclearer"></td>
						<td class="col4 nocontent"></td>
					</tr>

					<tr>
						<td colspan="4" class="nocontent"></td>
						<th colspan="3">Löneperiod</th>
					</tr>
					<tr>
						<td colspan="4" class="nocontent"></td>
						<td colspan="3"><xsl:value-of select="root/meta/url_params/period" /></td>
					</tr>
					<tr><td colspan="7" class="hclearer"></td></tr>

					<tr>
						<td colspan="4" class="nocontent"></td>
						<th colspan="3">Utbetalningsdatum</th>
					</tr>
					<tr>
						<td colspan="4" class="nocontent"></td>
						<td colspan="3">
							<xsl:for-each select="root/content/transactions/transaction[description = 'Salary payout']/transfer_date">
								<xsl:value-of select="." /><br />
							</xsl:for-each>
						</td>
					</tr>
					<tr><td colspan="7" class="hclearer"></td></tr>

					<tr>
						<td colspan="4" class="nocontent"></td>
						<th colspan="3">Bankkontonummer</th>
					</tr>
					<tr>
						<td colspan="4" class="nocontent"></td>
						<td colspan="3"><xsl:value-of select="root/content/employee/bank_account" /></td>
					</tr>
					<tr><td colspan="7" class="hclearer"></td></tr>

					<tr>
						<td colspan="4" class="nocontent"></td>
						<th colspan="3">Löntagare</th>
					</tr>
					<tr>
						<td colspan="4" class="nocontent"></td>
						<td colspan="3">
							<xsl:value-of select="root/content/employee/firstname" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="root/content/employee/lastname" />
							<br />
							<xsl:value-of select="root/content/employee/street" /><br />
							<xsl:value-of select="substring(root/content/employee/zip,1,3)" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="substring(root/content/employee/zip,4,2)" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="root/content/employee/city" />
						</td>
					</tr>
					<tr><td colspan="7" class="hclearer"></td></tr>

					<tr>
						<th>Skattesats</th>
						<td class="vclearer"></td>
						<th>Bank</th>
						<td class="vclearer"></td>
						<th>Bruttolön</th>
						<td class="vclearer"></td>
						<th>Land</th>
					</tr>
					<tr>
						<td><xsl:value-of select="root/content/employee/tax_level" />%</td>
						<td class="vclearer"></td>
						<td><xsl:value-of select="root/content/employee/bank_name" /></td>
						<td class="vclearer"></td>
						<td><xsl:value-of select="format-number(
							-sum(root/content/transactions/transaction[description = 'Salary payout']/sum)
							-sum(root/content/transactions/transaction[description = concat('Income taxes period ',/root/meta/url_params/period)]/sum)
						, '#&#160;###,00')" /></td>
						<td class="vclearer"></td>
						<td>Sverige</td>
					</tr>
					<tr><td colspan="7" class="hclearer"></td></tr>
				</table>

				<table class="salary">
					<tr>
						<th class="thingie">Beräkningspost</th>
						<th class="numbers">Belopp</th>
					</tr>
					<tr class="odd">
						<td class="thingie"><strong>Lönekostnad</strong></td>
						<td class="numbers">
							<strong>
								<xsl:value-of select="format-number(
									-sum(root/content/transactions/transaction[description = 'Salary payout']/sum)
									-sum(root/content/transactions/transaction[description = concat('Income taxes period ',/root/meta/url_params/period)]/sum)
									-sum(root/content/transactions/transaction[description = concat('Social fees period ',/root/meta/url_params/period)]/sum)
								, '#&#160;###,00')" />
							</strong>
						</td>
					</tr>
					<tr>
						<td class="thingie">Sociala avgifter</td>
						<td class="numbers">
							<strong>
								<xsl:value-of select="format-number(sum(root/content/transactions/transaction[description = concat('Social fees period ',/root/meta/url_params/period)]/sum), '#&#160;###,00')" />
							</strong>
						</td>
					</tr>
					<tr class="odd">
						<td class="thingie">Inkomstskatt</td>
						<td class="numbers">
							<strong>
								<xsl:value-of select="format-number(sum(root/content/transactions/transaction[description = concat('Income taxes period ',/root/meta/url_params/period)]/sum), '#&#160;###,00')" />
							</strong>
						</td>
					</tr>
					<tr class="last">
						<td class="thingie"><strong>Nettolön</strong></td>
						<td class="numbers">
							<strong>
								<xsl:value-of select="format-number(-sum(root/content/transactions/transaction[description = 'Salary payout']/sum), '#&#160;###,00')" />
							</strong>
						</td>
					</tr>
				</table>

				<table class="footer">
					<td class="left">
						<strong>Telefon:</strong><br />
						<xsl:text>+46 709 77 1337</xsl:text>
					</td>
					<td class="left">
						<strong>Internet:</strong><br />
						<xsl:text>www.larvit.se</xsl:text>
					</td>
					<td class="center">
						<strong>Adress:</strong><br />
						<xsl:text>Havsörnsvägen 8, 123 49 Farsta</xsl:text>
					</td>
					<td class="right">
						<strong>Larv IT AB innehar F-skattesedel.</strong>
					</td>
				</table>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="tot_ex_vat">
		<xsl:param name="position" select="1" />
		<xsl:param name="sum"      select="0" />

		<xsl:choose>
			<xsl:when test="/root/content/bill/items/item[$position]">

				<xsl:call-template name="tot_ex_vat">
					<xsl:with-param name="position" select="$position + 1" />
					<xsl:with-param name="sum"      select="$sum + number(/root/content/bill/items/item[$position]/qty) * number(/root/content/bill/items/item[$position]/price)"/>
				</xsl:call-template>

			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="format-number($sum, '#&#160;###,00')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="vat">
		<xsl:param name="position" select="1" />
		<xsl:param name="sum"      select="0" />

		<xsl:choose>
			<xsl:when test="/root/content/bill/items/item[$position]">

				<xsl:call-template name="vat">
					<xsl:with-param name="position" select="$position + 1" />
					<xsl:with-param name="sum"      select="$sum + number(/root/content/bill/items/item[$position]/qty) * number(/root/content/bill/items/item[$position]/price)"/>
				</xsl:call-template>

			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="format-number($sum * 0.25, '#&#160;###,00')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="tot">
		<xsl:param name="position" select="1" />
		<xsl:param name="sum"      select="0" />

		<xsl:choose>
			<xsl:when test="/root/content/bill/items/item[$position]">

				<xsl:call-template name="tot">
					<xsl:with-param name="position" select="$position + 1" />
					<xsl:with-param name="sum"      select="$sum + number(/root/content/bill/items/item[$position]/qty) * number(/root/content/bill/items/item[$position]/price)"/>
				</xsl:call-template>

			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="format-number($sum * 1.25, '#&#160;###,00')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>
