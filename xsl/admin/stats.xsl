<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="tpl.default.xsl" />

	<xsl:template name="tabs">
	</xsl:template>

	<xsl:template match="/">
		<xsl:call-template name="template">
			<xsl:with-param name="title" select="'Admin - Stats'" />
			<xsl:with-param name="h1" select="'Stats'" />
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="content[../meta/action = 'index']">
		<script type="text/javascript" src="/js/highcharts.js"><xsl:comment></xsl:comment></script>
		<script type="text/javascript">
			$(function() {
				$('#highsharts_container').highcharts({
					title: {
						text: 'Stats',
						x: -20 //center
					},
					xAxis: {
						categories: [
							<xsl:for-each select="balance_by_month/*">
								<xsl:text>'</xsl:text>
								<xsl:value-of select="substring(name(), 6)" />
								<xsl:text>'</xsl:text>
								<xsl:if test="position() != last()">,</xsl:if>
							</xsl:for-each>
						],
						labels: {
							rotation: -90
						}
					},
					yAxis: {
						title: {
							text: 'Cash ex VAT'
						},
						plotLines: [{
							value: 0,
							width: 1,
							color: '#808080'
						}]
					},
					legend: {
						layout: 'vertical',
						align: 'right',
						verticalAlign: 'middle',
						borderWidth: 0
					},
					series: [{
						name: 'Balance',
						data: [
							<xsl:for-each select="balance_by_month/*">
								<xsl:value-of select="." />
								<xsl:if test="position() != last()">,</xsl:if>
							</xsl:for-each>
						]
					}, {
						name: 'Profit',
						data: [
							<xsl:for-each select="profit/*">
								<xsl:value-of select="." />
								<xsl:if test="position() != last()">,</xsl:if>
							</xsl:for-each>
						]
					}, {
						name: 'Turnover',
						data: [
							<xsl:for-each select="turnover/*">
								<xsl:value-of select="." />
								<xsl:if test="position() != last()">,</xsl:if>
							</xsl:for-each>
						]
					}]
				});
			});
		</script>
		<div id="highsharts_container" style="min-width: 310px; height: 400px; margin: 0 auto;"></div>
	</xsl:template>

</xsl:stylesheet>