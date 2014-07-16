$(document).ready(function() {

	// Current date
	var currentTime = new Date()
	var year        = currentTime.getFullYear();
	var month       = currentTime.getMonth() + 1;
	if (month.toString().length == 1) month = '0'+month;
	var day         = currentTime.getDate();
	if (day.toString().length == 1) day = '0'+day;


	////////////////////////////
	// Calculations for wages //
	////////////////////////////

		// Check so we are at the correct page
		var pathArray = window.location.pathname.split( '/' );
		if (pathArray[pathArray.length-2]+'/'+pathArray[pathArray.length-1] == 'wages/payout')
		{
			// Inital settings

				// Set tax level based on employee
				$('#tax_level').val($('#employee_'+$('#employee_id').val()+' div.tax_level').text());

				// Set current date if none is provided
				if ($('#date').val() == '') $('#date').val(year+'-'+month+'-'+day);

				// Set soc fee level based on age
				if (getAge($('#employee_'+$('#employee_id').val()+' div.SSN').text()) > 25)
					$('#soc_fee_level').val(31.42);
				else
					$('#soc_fee_level').val(15.49);

			// Update when change employee
			$('#employee_id').change(function() {
				if ($('#tax_level').val() != $('#employee_'+$(this).val()+' div.tax_level').text())
				{
					$('#tax_level').val($('#employee_'+$(this).val()+' div.tax_level').text());
					$('#tax_level').trigger('change'); // Make sure the form gets updated
				}

				if (getAge($('#employee_'+$('#employee_id').val()+' div.SSN').text()) > 25)
				{
					if ($('#soc_fee_level').val() != 31.42)
					{
						$('#soc_fee_level').val(31.42);
						$('#soc_fee_level').trigger('keyup'); // Make sure the form gets updated
					}
				}
				else
				{
					if ($('#soc_fee_level').val() != 15.49)
					{
						$('#soc_fee_level').val(15.49);
						$('#soc_fee_level').trigger('keyup'); // Make sure the form gets updated
					}
				}
			});

			// Update when change soc fee level
			$('#soc_fee_level').keyup(function() {
				$('#gross_pay').trigger('keyup');
			});

			// Update when change soc fee level
			$('#tax_level').keyup(function() {
				$('#gross_pay').trigger('keyup');
			});

			// Update when change payout
			$('#amount').keyup(function() {
				$('#gross_pay').val(Math.round(
					(parseFloat($('#amount').val())    / (100-parseFloat($('#tax_level').val()))) * 100
				));
				$('#income_taxes').val(Math.round(
					(parseFloat($('#gross_pay').val()) * parseFloat($('#tax_level')    .val()))   / 100
				));
				$('#soc_fees').val(Math.floor(
					(parseFloat($('#gross_pay').val()) * parseFloat($('#soc_fee_level').val()))   / 100
				));
				$('#total_cost').val(Math.round(
					(parseFloat($('#gross_pay').val()) + parseFloat($('#soc_fees')     .val()))
				));
			});

			// Update when change gross pay
			$('#gross_pay').keyup(function() {
				$('#income_taxes').val(Math.round(
					(parseFloat($('#gross_pay').val()) * parseFloat($('#tax_level')    .val()))   / 100
				));
				$('#soc_fees').val(Math.floor(
					(parseFloat($('#gross_pay').val()) * parseFloat($('#soc_fee_level').val()))   / 100
				));
				$('#total_cost').val(Math.round(
					(parseFloat($('#gross_pay').val()) + parseFloat($('#soc_fees')     .val()))
				));
				$('#amount').val(Math.round(
					(parseFloat($('#gross_pay').val()) - parseFloat($('#income_taxes') .val()))
				));
			});

			// Update when change total payout cost
			$('#total_cost').keyup(function() {
				$('#gross_pay').val(Math.round(
					parseFloat($('#total_cost').val()) / (parseFloat($('#soc_fee_level').val()) / 100 + 1)
				));
				$('#income_taxes').val(Math.round(
					(parseFloat($('#gross_pay').val()) * parseFloat($('#tax_level')    .val()))   / 100
				));
				$('#soc_fees').val(Math.floor(
					(parseFloat($('#gross_pay').val()) * parseFloat($('#soc_fee_level').val()))   / 100
				));
				$('#amount').val(Math.round(
					(parseFloat($('#gross_pay').val()) - parseFloat($('#income_taxes') .val()))
				));
			});

			// Update when change income taxes
			$('#income_taxes').keyup(function() {
				$('#gross_pay').val(Math.round(
					parseFloat($('#income_taxes').val()) / (parseFloat($('#tax_level').val()) / 100)
				));
				$('#soc_fees').val(Math.floor(
					(parseFloat($('#gross_pay').val()) * parseFloat($('#soc_fee_level').val()))   / 100
				));
				$('#total_cost').val(Math.round(
					(parseFloat($('#gross_pay').val()) + parseFloat($('#soc_fees')     .val()))
				));
				$('#amount').val(Math.round(
					(parseFloat($('#gross_pay').val()) - parseFloat($('#income_taxes') .val()))
				));
			});

			// Update when change social fees
			$('#soc_fees').keyup(function() {
				$('#gross_pay').val(Math.round(
					parseFloat($('#soc_fees').val()) / (parseFloat($('#soc_fee_level').val()) / 100)
				));
				$('#income_taxes').val(Math.round(
					(parseFloat($('#gross_pay').val()) * parseFloat($('#tax_level')    .val()))   / 100
				));
				$('#total_cost').val(Math.round(
					(parseFloat($('#gross_pay').val()) + parseFloat($('#soc_fees')     .val()))
				));
				$('#amount').val(Math.round(
					(parseFloat($('#gross_pay').val()) - parseFloat($('#income_taxes') .val()))
				));
			});
		}

	///////////////////////////////////
	// End of Calculations for wages //
	///////////////////////////////////

	// Pay link to mark a bill paid in the bills admin
	$('a.paylink').click(function() {
		event.preventDefault();

		var pay_date = prompt('Enter date of payment', year+'-'+month+'-'+day);

		if (pay_date != null && pay_date != '')
		{
			href = $(this).attr('href');
			window.location = href.substring(0, href.toString().length - 10) + pay_date;
		}
	});

	// Update-selector for wages
	$('#update_button').hide();
	$('#period').change(function() {
		$('#periods').submit();
	});

});

// Get age based on SSN
function getAge(SSN)
{
	// Current date
	var currentTime       = new Date()
	var year              = currentTime.getFullYear();
	var yearTwoDigits     = parseInt(year.toString().substring(2,4));
	var month             = currentTime.getMonth() + 1;
	var day               = currentTime.getDate();

	// Born date
	var bornYearTwoDigits = parseInt(SSN.substring(0, 2));
	var bornMonth         = parseInt(SSN.substring(2, 4));
	var bornDay           = parseInt(SSN.substring(4, 6));
	var bornYear          = parseInt(year.toString().substring(0,2));

	if (yearTwoDigits < bornYearTwoDigits)
		bornYear = parseInt(year.toString().substring(0,2)) - 1;

	bornYear = parseInt(bornYear.toString()+bornYearTwoDigits.toString());

	var bornTime          = new Date(bornYear, bornMonth, bornDay);

// Tax system doesnt care, it only cares about whole years
return year - bornYear;

	if (month > bornMonth || (month == bornMonth && day >= bornDay))
		return year - bornYear;
	else
		return year - bornYear - 1;
}