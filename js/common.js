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




// Debugging stuff
function var_dump () {
    // Dumps a string representation of variable to output
    //
    // version: 1109.2015
    // discuss at: http://phpjs.org/functions/var_dump
    // +   original by: Brett Zamir (http://brett-zamir.me)
    // +   improved by: Zahlii
    // +   improved by: Brett Zamir (http://brett-zamir.me)
    // -    depends on: echo
    // %        note 1: For returning a string, use var_export() with the second argument set to true
    // *     example 1: var_dump(1);
    // *     returns 1: 'int(1)'
    var output = '',
        pad_char = ' ',
        pad_val = 4,
        lgth = 0,
        i = 0,
        d = this.window.document;
    var _getFuncName = function (fn) {
        var name = (/\W*function\s+([\w\$]+)\s*\(/).exec(fn);
        if (!name) {
            return '(Anonymous)';
        }
        return name[1];
    };

    var _repeat_char = function (len, pad_char) {
        var str = '';
        for (var i = 0; i < len; i++) {
            str += pad_char;
        }
        return str;
    };
    var _getInnerVal = function (val, thick_pad) {
        var ret = '';
        if (val === null) {
            ret = 'NULL';
        } else if (typeof val === 'boolean') {
            ret = 'bool(' + val + ')';
        } else if (typeof val === 'string') {
            ret = 'string(' + val.length + ') "' + val + '"';
        } else if (typeof val === 'number') {
            if (parseFloat(val) == parseInt(val, 10)) {
                ret = 'int(' + val + ')';
            } else {
                ret = 'float(' + val + ')';
            }
        }
        // The remaining are not PHP behavior because these values only exist in this exact form in JavaScript
        else if (typeof val === 'undefined') {
            ret = 'undefined';
        } else if (typeof val === 'function') {
            var funcLines = val.toString().split('\n');
            ret = '';
            for (var i = 0, fll = funcLines.length; i < fll; i++) {
                ret += (i !== 0 ? '\n' + thick_pad : '') + funcLines[i];
            }
        } else if (val instanceof Date) {
            ret = 'Date(' + val + ')';
        } else if (val instanceof RegExp) {
            ret = 'RegExp(' + val + ')';
        } else if (val.nodeName) { // Different than PHP's DOMElement
            switch (val.nodeType) {
            case 1:
                if (typeof val.namespaceURI === 'undefined' || val.namespaceURI === 'http://www.w3.org/1999/xhtml') { // Undefined namespace could be plain XML, but namespaceURI not widely supported
                    ret = 'HTMLElement("' + val.nodeName + '")';
                } else {
                    ret = 'XML Element("' + val.nodeName + '")';
                }
                break;
            case 2:
                ret = 'ATTRIBUTE_NODE(' + val.nodeName + ')';
                break;
            case 3:
                ret = 'TEXT_NODE(' + val.nodeValue + ')';
                break;
            case 4:
                ret = 'CDATA_SECTION_NODE(' + val.nodeValue + ')';
                break;
            case 5:
                ret = 'ENTITY_REFERENCE_NODE';
                break;
            case 6:
                ret = 'ENTITY_NODE';
                break;
            case 7:
                ret = 'PROCESSING_INSTRUCTION_NODE(' + val.nodeName + ':' + val.nodeValue + ')';
                break;
            case 8:
                ret = 'COMMENT_NODE(' + val.nodeValue + ')';
                break;
            case 9:
                ret = 'DOCUMENT_NODE';
                break;
            case 10:
                ret = 'DOCUMENT_TYPE_NODE';
                break;
            case 11:
                ret = 'DOCUMENT_FRAGMENT_NODE';
                break;
            case 12:
                ret = 'NOTATION_NODE';
                break;
            }
        }
        return ret;
    };

    var _formatArray = function (obj, cur_depth, pad_val, pad_char) {
        var someProp = '';
        if (cur_depth > 0) {
            cur_depth++;
        }

        var base_pad = _repeat_char(pad_val * (cur_depth - 1), pad_char);
        var thick_pad = _repeat_char(pad_val * (cur_depth + 1), pad_char);
        var str = '';
        var val = '';

        if (typeof obj === 'object' && obj !== null) {
            if (obj.constructor && _getFuncName(obj.constructor) === 'PHPJS_Resource') {
                return obj.var_dump();
            }
            lgth = 0;
            for (someProp in obj) {
                lgth++;
            }
            str += 'array(' + lgth + ') {\n';
            for (var key in obj) {
                var objVal = obj[key];
                if (typeof objVal === 'object' && objVal !== null && !(objVal instanceof Date) && !(objVal instanceof RegExp) && !objVal.nodeName) {
                    str += thick_pad + '[' + key + '] =>\n' + thick_pad + _formatArray(objVal, cur_depth + 1, pad_val, pad_char);
                } else {
                    val = _getInnerVal(objVal, thick_pad);
                    str += thick_pad + '[' + key + '] =>\n' + thick_pad + val + '\n';
                }
            }
            str += base_pad + '}\n';
        } else {
            str = _getInnerVal(obj, thick_pad);
        }
        return str;
    };

    output = _formatArray(arguments[0], 0, pad_val, pad_char);
    for (i = 1; i < arguments.length; i++) {
        output += '\n' + _formatArray(arguments[i], 0, pad_val, pad_char);
    }

    if (d.body) {
        this.echo(output);
    } else {
        try {
            d = XULDocument; // We're in XUL, so appending as plain text won't work
            this.echo('<pre xmlns="http://www.w3.org/1999/xhtml" style="white-space:pre;">' + output + '</pre>');
        } catch (e) {
            this.echo(output); // Outputting as plain text may work in some plain XML
        }
    }
}
function echo () {
    // !No description available for echo. @php.js developers: Please update the function summary text file.
    //
    // version: 1109.2015
    // discuss at: http://phpjs.org/functions/echo
    // +   original by: Philip Peterson
    // +   improved by: echo is bad
    // +   improved by: Nate
    // +    revised by: Der Simon (http://innerdom.sourceforge.net/)
    // +   improved by: Brett Zamir (http://brett-zamir.me)
    // +   bugfixed by: Eugene Bulkin (http://doubleaw.com/)
    // +   input by: JB
    // +   improved by: Brett Zamir (http://brett-zamir.me)
    // +   bugfixed by: Brett Zamir (http://brett-zamir.me)
    // +   bugfixed by: Brett Zamir (http://brett-zamir.me)
    // +   bugfixed by: EdorFaus
    // +   improved by: Brett Zamir (http://brett-zamir.me)
    // %        note 1: If browsers start to support DOM Level 3 Load and Save (parsing/serializing),
    // %        note 1: we wouldn't need any such long code (even most of the code below). See
    // %        note 1: link below for a cross-browser implementation in JavaScript. HTML5 might
    // %        note 1: possibly support DOMParser, but that is not presently a standard.
    // %        note 2: Although innerHTML is widely used and may become standard as of HTML5, it is also not ideal for
    // %        note 2: use with a temporary holder before appending to the DOM (as is our last resort below),
    // %        note 2: since it may not work in an XML context
    // %        note 3: Using innerHTML to directly add to the BODY is very dangerous because it will
    // %        note 3: break all pre-existing references to HTMLElements.
    // *     example 1: echo('<div><p>abc</p><p>abc</p></div>');
    // *     returns 1: undefined
    // Fix: This function really needs to allow non-XHTML input (unless in true XHTML mode) as in jQuery
    var arg = '',
        argc = arguments.length,
        argv = arguments,
        i = 0,
        holder, win = this.window,
        d = win.document,
        ns_xhtml = 'http://www.w3.org/1999/xhtml',
        ns_xul = 'http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul'; // If we're in a XUL context
    var stringToDOM = function (str, parent, ns, container) {
        var extraNSs = '';
        if (ns === ns_xul) {
            extraNSs = ' xmlns:html="' + ns_xhtml + '"';
        }
        var stringContainer = '<' + container + ' xmlns="' + ns + '"' + extraNSs + '>' + str + '</' + container + '>';
        var dils = win.DOMImplementationLS,
            dp = win.DOMParser,
            ax = win.ActiveXObject;
        if (dils && dils.createLSInput && dils.createLSParser) {
            // Follows the DOM 3 Load and Save standard, but not
            // implemented in browsers at present; HTML5 is to standardize on innerHTML, but not for XML (though
            // possibly will also standardize with DOMParser); in the meantime, to ensure fullest browser support, could
            // attach http://svn2.assembla.com/svn/brettz9/DOMToString/DOM3.js (see http://svn2.assembla.com/svn/brettz9/DOMToString/DOM3.xhtml for a simple test file)
            var lsInput = dils.createLSInput();
            // If we're in XHTML, we'll try to allow the XHTML namespace to be available by default
            lsInput.stringData = stringContainer;
            var lsParser = dils.createLSParser(1, null); // synchronous, no schema type
            return lsParser.parse(lsInput).firstChild;
        } else if (dp) {
            // If we're in XHTML, we'll try to allow the XHTML namespace to be available by default
            try {
                var fc = new dp().parseFromString(stringContainer, 'text/xml');
                if (fc && fc.documentElement && fc.documentElement.localName !== 'parsererror' && fc.documentElement.namespaceURI !== 'http://www.mozilla.org/newlayout/xml/parsererror.xml') {
                    return fc.documentElement.firstChild;
                }
                // If there's a parsing error, we just continue on
            } catch (e) {
                // If there's a parsing error, we just continue on
            }
        } else if (ax) { // We don't bother with a holder in Explorer as it doesn't support namespaces
            var axo = new ax('MSXML2.DOMDocument');
            axo.loadXML(str);
            return axo.documentElement;
        }
/*else if (win.XMLHttpRequest) { // Supposed to work in older Safari
            var req = new win.XMLHttpRequest;
            req.open('GET', 'data:application/xml;charset=utf-8,'+encodeURIComponent(str), false);
            if (req.overrideMimeType) {
                req.overrideMimeType('application/xml');
            }
            req.send(null);
            return req.responseXML;
        }*/
        // Document fragment did not work with innerHTML, so we create a temporary element holder
        // If we're in XHTML, we'll try to allow the XHTML namespace to be available by default
        //if (d.createElementNS && (d.contentType && d.contentType !== 'text/html')) { // Don't create namespaced elements if we're being served as HTML (currently only Mozilla supports this detection in true XHTML-supporting browsers, but Safari and Opera should work with the above DOMParser anyways, and IE doesn't support createElementNS anyways)
        if (d.createElementNS && // Browser supports the method
        (d.documentElement.namespaceURI || // We can use if the document is using a namespace
        d.documentElement.nodeName.toLowerCase() !== 'html' || // We know it's not HTML4 or less, if the tag is not HTML (even if the root namespace is null)
        (d.contentType && d.contentType !== 'text/html') // We know it's not regular HTML4 or less if this is Mozilla (only browser supporting the attribute) and the content type is something other than text/html; other HTML5 roots (like svg) still have a namespace
        )) { // Don't create namespaced elements if we're being served as HTML (currently only Mozilla supports this detection in true XHTML-supporting browsers, but Safari and Opera should work with the above DOMParser anyways, and IE doesn't support createElementNS anyways); last test is for the sake of being in a pure XML document
            holder = d.createElementNS(ns, container);
        } else {
            holder = d.createElement(container); // Document fragment did not work with innerHTML
        }
        holder.innerHTML = str;
        while (holder.firstChild) {
            parent.appendChild(holder.firstChild);
        }
        return false;
        // throw 'Your browser does not support DOM parsing as required by echo()';
    };


    var ieFix = function (node) {
        if (node.nodeType === 1) {
            var newNode = d.createElement(node.nodeName);
            var i, len;
            if (node.attributes && node.attributes.length > 0) {
                for (i = 0, len = node.attributes.length; i < len; i++) {
                    newNode.setAttribute(node.attributes[i].nodeName, node.getAttribute(node.attributes[i].nodeName));
                }
            }
            if (node.childNodes && node.childNodes.length > 0) {
                for (i = 0, len = node.childNodes.length; i < len; i++) {
                    newNode.appendChild(ieFix(node.childNodes[i]));
                }
            }
            return newNode;
        } else {
            return d.createTextNode(node.nodeValue);
        }
    };

    var replacer = function (s, m1, m2) {
        // We assume for now that embedded variables do not have dollar sign; to add a dollar sign, you currently must use {$$var} (We might change this, however.)
        // Doesn't cover all cases yet: see http://php.net/manual/en/language.types.string.php#language.types.string.syntax.double
        if (m1 !== '\\') {
            return m1 + eval(m2);
        } else {
            return s;
        }
    };

    this.php_js = this.php_js || {};
    var phpjs = this.php_js,
        ini = phpjs.ini,
        obs = phpjs.obs;
    for (i = 0; i < argc; i++) {
        arg = argv[i];
        if (ini && ini['phpjs.echo_embedded_vars']) {
            arg = arg.replace(/(.?)\{?\$(\w*?\}|\w*)/g, replacer);
        }

        if (!phpjs.flushing && obs && obs.length) { // If flushing we output, but otherwise presence of a buffer means caching output
            obs[obs.length - 1].buffer += arg;
            continue;
        }

        if (d.appendChild) {
            if (d.body) {
                if (win.navigator.appName === 'Microsoft Internet Explorer') { // We unfortunately cannot use feature detection, since this is an IE bug with cloneNode nodes being appended
                    d.body.appendChild(stringToDOM(ieFix(arg)));
                } else {
                    var unappendedLeft = stringToDOM(arg, d.body, ns_xhtml, 'div').cloneNode(true); // We will not actually append the div tag (just using for providing XHTML namespace by default)
                    if (unappendedLeft) {
                        d.body.appendChild(unappendedLeft);
                    }
                }
            } else {
                d.documentElement.appendChild(stringToDOM(arg, d.documentElement, ns_xul, 'description')); // We will not actually append the description tag (just using for providing XUL namespace by default)
            }
        } else if (d.write) {
            d.write(arg);
        }
/* else { // This could recurse if we ever add print!
            print(arg);
        }*/
    }
}
