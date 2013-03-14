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

				<title>Bill</title>
			</head>
			<body>
				<h1>Faktura</h1>

				<!--img src="img/larvit_rgb_fullfarg.png" alt="" /-->

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
						<th colspan="3">Fakturadatum</th>
					</tr>
					<tr>
						<td colspan="4" class="nocontent"></td>
						<td colspan="3"><xsl:value-of select="substring(/root/content/bill/date, 1, 10)" /></td>
					</tr>
					<tr><td colspan="7" class="hclearer"></td></tr>

					<tr>
						<td colspan="4" class="nocontent"></td>
						<th colspan="3">Fakturanummer</th>
					</tr>
					<tr>
						<td colspan="4" class="nocontent"></td>
						<td colspan="3"><xsl:value-of select="/root/content/bill/@id" /></td>
					</tr>
					<tr><td colspan="7" class="hclearer"></td></tr>

					<tr>
						<td colspan="4" class="nocontent"></td>
						<th colspan="3">Kundnummer</th>
					</tr>
					<tr>
						<td colspan="4" class="nocontent"></td>
						<td colspan="3"><xsl:value-of select="/root/content/bill/customer_id" /></td>
					</tr>
					<tr><td colspan="7" class="hclearer"></td></tr>

					<tr>
						<td colspan="4" class="nocontent"></td>
						<th colspan="3">Kund</th>
					</tr>
					<tr>
						<td colspan="4" class="nocontent"></td>
						<td colspan="3">
							<xsl:value-of select="/root/content/bill/customer_name" /><br />
							<xsl:value-of select="/root/content/bill/customer_street" /><br />
							<xsl:value-of select="substring(/root/content/bill/customer_zip,1,3)" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="substring(/root/content/bill/customer_zip,4,2)" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="/root/content/bill/customer_city" />
						</td>
					</tr>
					<tr><td colspan="7" class="hclearer"></td></tr>

					<tr>
						<th>Vår referens</th>
						<td class="vclearer"></td>
						<th>Er referens</th>
						<td class="vclearer"></td>
						<th>Betalningsvillkor</th>
						<td class="vclearer"></td>
						<th>Förfallodatum</th>
					</tr>
					<tr>
						<td><xsl:value-of select="/root/content/bill/contact" /></td>
						<td class="vclearer"></td>
						<td><xsl:value-of select="/root/content/bill/customer_contact" /></td>
						<td class="vclearer"></td>
						<td><xsl:value-of select="/root/content/bill/due_days" /> dagar netto</td>
						<td class="vclearer"></td>
						<td><xsl:value-of select="substring(/root/content/bill/due_date, 1, 10)" /></td>
					</tr>
					<tr><td colspan="7" class="hclearer"></td></tr>
				</table>

				<table class="items">
					<tr>
						<th class="artnr">Artikelnr</th>
						<th class="spec">Specifikation</th>
						<th class="qty">Antal</th>
						<th class="single_price">Á Pris</th>
						<th class="price">Pris</th>
						<th class="vat">Moms</th>
					</tr>

					<xsl:for-each select="/root/content/bill/items/item">
						<tr>
							<xsl:if test="position() mod 2">
								<xsl:attribute name="class">odd</xsl:attribute>
							</xsl:if>
							<td class="artnr">
								<xsl:if test="position() = count(/root/content/bill/items/item)">
									<xsl:attribute name="class">artnr last</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="@artnr" />
							</td>
							<td class="spec">
								<xsl:if test="position() = count(/root/content/bill/items/item)">
									<xsl:attribute name="class">spec last</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="spec" />
							</td>
							<td class="qty">
								<xsl:if test="position() = count(/root/content/bill/items/item)">
									<xsl:attribute name="class">qty last</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="format-number(qty, '#&#160;###')" />
							</td>
							<td class="single_price">
								<xsl:if test="position() = count(/root/content/bill/items/item)">
									<xsl:attribute name="class">single_price last</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="format-number(price, '#&#160;###,00')" />
							</td>
							<td class="price">
								<xsl:if test="position() = count(/root/content/bill/items/item)">
									<xsl:attribute name="class">price last</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="format-number(number(qty) * number(price), '#&#160;###,00')" />
							</td>
							<td class="price">
								<xsl:if test="position() = count(/root/content/bill/items/item)">
									<xsl:attribute name="class">vat last</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="format-number(number(qty) * number(price) * (number(vat) - 1), '#&#160;###,00')" />
							</td>
						</tr>
					</xsl:for-each>

					<tr class="bottom">
						<td colspan="2" rowspan="3" class="fail_info">Vid betalning efter förfallodatum debiteras<br />dröjsmålsränta enligt räntelagen.</td>
						<td colspan="2" class="tot_ex_vat">Totalpris ex moms</td>
						<td class="tot_ex_vat_value">
							<xsl:call-template name="tot_ex_vat" />
						</td>
					</tr>
					<tr class="bottom">
						<td colspan="2" class="vat">Moms</td>
						<td class="vat_value">
							<xsl:call-template name="vat" />
						</td>
					</tr>
					<tr class="bottom">
						<td colspan="2" class="tot">Att betala</td>
						<td class="tot_value">
							<xsl:call-template name="tot" />
						</td>
					</tr>
				</table>

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
						<td colspan="2" class="nocontent"></td>
						<th>Säte</th>
						<td class="vclearer"></td>
						<th colspan="3">Organisationsnummer</th>
					</tr>
					<tr>
						<td colspan="2" class="nocontent"></td>
						<td>Hittepåstaden</td>
						<td class="vclearer"></td>
						<td colspan="3">5588662431</td>
					</tr>
					<tr><td colspan="7" class="hclearer"></td></tr>
					<tr>
						<th>BankGiro</th>
						<td class="vclearer"></td>
						<th>Momsreg.nr</th>
						<td class="vclearer"></td>
						<td colspan="3" class="nocontent"></td>
					</tr>
					<tr>
						<td>1111 222</td>
						<td class="vclearer"></td>
						<td>SE558866243101</td>
						<td class="vclearer"></td>
						<td style="border: none;"></td>
						<td class="vclearer"></td>
						<td style="border: none;"></td>
					</tr>
				</table>

				<table class="footer">
					<td class="left">
						<strong>Telefon:</strong><br />
						<xsl:text>+46 8 111 22 11</xsl:text>
					</td>
					<td class="left">
						<strong>Internet:</strong><br />
						<xsl:text>foretaget.se</xsl:text>
					</td>
					<td class="center">
						<strong>Adress:</strong><br />
						<xsl:text>Gatanistan, 123 45 Hittepåstaden</xsl:text>
					</td>
					<td class="right">
						<strong>Stollebolaget AB innehar F-skattesedel.</strong>
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
					<xsl:with-param name="sum"      select="$sum + number(/root/content/bill/items/item[$position]/qty) * number(/root/content/bill/items/item[$position]/price) * (number(/root/content/bill/items/item[$position]/vat) - 1)"/>
				</xsl:call-template>

			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="format-number($sum, '#&#160;###,00')" />
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
					<xsl:with-param name="sum"      select="$sum + number(/root/content/bill/items/item[$position]/qty) * number(/root/content/bill/items/item[$position]/price) * number(/root/content/bill/items/item[$position]/vat)"/>
				</xsl:call-template>

			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="format-number($sum, '#&#160;###,00')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>
