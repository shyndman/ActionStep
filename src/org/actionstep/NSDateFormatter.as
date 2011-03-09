/* See LICENSE for copyright and terms of use */

import org.actionstep.formatter.ASFormatResult;
import org.actionstep.NSArray;
import org.actionstep.NSCalendarDate;
import org.actionstep.NSDate;
import org.actionstep.NSDictionary;
import org.actionstep.NSRange;
import org.actionstep.NSTimeZone;
import org.actionstep.NSUserDefaults;
import org.actionstep.NSException;
import org.actionstep.ASDebugger;

/**
 * <p>Transforms dates to strings, or strings to dates based on formatting
 * strings.</p>
 * 
 * <p>For information on how formatting strings should be structured, please see
 * {@link http://developer.apple.com/documentation/Cocoa/Conceptual/DataFormatting/index.html#//apple_ref/doc/uid/10000029i }</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSDateFormatter extends org.actionstep.NSFormatter
{	
	//
	// For parsing and formatting.
	//
	private static var ASFormatChar:Number = 0;
	private static var ASWord:Number = 1;
	private static var ASSpaceChar:Number = 2;
	
	/** Holds format methods. */
	private static var g_types:Object;
	private static var g_reverseTypes:Object;
	
	//
	// Behaviour
	//	
	private var m_allowsNaturalLang:Boolean;
	private var m_genCalDates:Boolean;
	private var m_isLenient:Boolean;
	private var m_twoDigitStartDate:NSDate;
	
	//
	// Attributes
	//
	private var m_format:String;
	private var m_attributes:NSDictionary;
	private var m_defaultDate:NSDate;
	private var m_timeZone:NSTimeZone;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of NSDateFormatter.
	 */
	public function NSDateFormatter() {	
		m_allowsNaturalLang = false;
		m_defaultDate = null;
		m_attributes = (new NSDictionary()).initWithDictionaryCopyItems(
			NSUserDefaults.standardUserDefaults().dictionaryRepresentation(), 
			true);
	}
	
	/**
	 * Initializes the date formatter with a format string and
	 * a flag that indicates whether or not to allow natural language.
	 */
	public function initWithDateFormatAllowNaturalLanguage(format:String, 
			flag:Boolean):NSDateFormatter {
		m_format = format;
		m_allowsNaturalLang = flag;
		m_twoDigitStartDate = NSCalendarDate.dateWithYearMonthDayHourMinuteSecondTimeZone(
			1949, 12, 31, 0, 0, 0, NSTimeZone.defaultTimeZone());
		return this;
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String {
		return "NSDateFormatter(dateFormat=" + dateFormat() + ", "
			+ "allowsNaturalLanguage=" + allowsNaturalLanguage() + ", "
			+ "isLenient=" + isLenient() + ", "
			+ "generatesCalendarDates=" + generatesCalendarDates() + ")";
	}
	
	//******************************************************															 
	//*            Getting and setting behavior
	//******************************************************
	
	/**
	 * Returns <code>true</code> if the formatter supports natural language 
	 * strings ("now", "yesterday", "tomorrow", ect.) when generating dates from 
	 * strings.
	 */
	public function allowsNaturalLanguage():Boolean {
		return m_allowsNaturalLang;
	}

	/**
	 * Returns whether the date formatter returns generates calendar dates
	 * instead of dates.
	 */
	public function generatesCalendarDates():Boolean {
		return m_genCalDates;
	}
	
	/**
	 * Sets whether the date formatter generates calendar dates. If 
	 * <code>flag</code> is <code>true</code>, it will. If <code>false</code>, 
	 * <code>NSDate</code> instances will be generated.
	 *
	 * @see org.actionstep.NSDateFormatter#dateFromString()
	 */
	public function setGeneratesCalendarDates(flag:Boolean):Void {
		m_genCalDates = flag;
	}
	
	/**
	 * Returns <code>true</code> if the formatter has been set to be lenient; 
	 * <code>false</code> otherwise.
	 */
	public function isLenient():Boolean {
		return m_isLenient;
	}
	
	/**
	 * Sets whether the formatter should be leniant.
	 */
	public function setLenient(flag:Boolean):Void {
		m_isLenient = flag;
	}
	
	/**
	 * <p>Returns the earliest date that can be denoted by a two-digit year 
	 * specifier.</p>
	 * 
	 * <p>The default date is December 31, 1949.</p>
	 */
	public function twoDigitStartDate():NSDate {
		return m_twoDigitStartDate;
	}
	
	/**
	 * Sets the receiver’s two-digit start date to <code>aDate</code>.
	 */
	public function setTwoDigitStartDate(aDate:NSDate):Void {
		m_twoDigitStartDate = aDate;
	}
	
	//******************************************************															 
	//*          Getting and setting attributes
	//******************************************************
	
	/**
	 * Returns the symbol used to represent AM.
	 */
	public function AMSymbol():String {
		return m_attributes.objectForKey(NSUserDefaults.NSAMPMDesignation)
			.objectAtIndex(0);
	}
	
	/**
	 * Sets the symbol used to represent AM to <code>symbol</code>.
	 */
	public function setAMSymbol(symbol:String):Void {
		m_attributes.objectForKey(NSUserDefaults.NSAMPMDesignation)
			.replaceObjectAtIndexWithObject(0, symbol);
	}
	
	/**
	 * Returns the format string used to convert dates to strings and strings
	 * to dates.
	 */
	public function dateFormat():String {
		return m_format;
	}
	
	/**
	 * Sets the format string used to convert between dates and strings and 
	 * strings and dates to <code>format</code>.
	 */
	public function setDateFormat(format:String):Void {
		m_format = format;
	}
	
	/**
	 * Returns the default date for the receiver. The default is 
	 * <code>null</code>.
	 */
	public function defaultDate():NSDate {
		return m_defaultDate;
	}
	
	/**
	 * Sets the receiver’s default date to <code>aDate</code>.
	 */
	public function setDefaultDate(aDate:NSDate):Void {
		m_defaultDate = aDate;
	}
	
	/**
	 * Returns the array of era symbols (for example, “BCE, CE”) for the 
	 * receiver.
	 */
	public function eraSymbols():NSArray {
		return NSArray(m_attributes.objectForKey(NSUserDefaults.NSEraDesignations));
	}
	
	/**
	 * Sets the receiver’s array of era symbols to <code>symbols</code>.
	 */
	public function setEraSymbols(symbols:NSArray):Void {
		m_attributes.setObjectForKey(symbols, NSUserDefaults.NSEraDesignations);
	}
	
	/**
	 * Returns the array of month symbols for the receiver.
	 */
	public function monthSymbols():NSArray {
		return NSArray(m_attributes.objectForKey(NSUserDefaults.NSMonthNameArray));
	}
	
	/**
	 * Sets the receiver’s array of month symbols to <code>symbols</code>.
	 */
	public function setMonthSymbols(symbols:NSArray):Void {
		m_attributes.setObjectForKey(symbols, NSUserDefaults.NSMonthNameArray);
	}
	
	/**
	 * Returns the symbol used to represent PM.
	 */
	public function PMSymbol():String {
		return m_attributes.objectForKey(NSUserDefaults.NSAMPMDesignation)
			.objectAtIndex(1);
	}
	
	/**
	 * Sets the symbol used to represent PM to <code>symbol</code>.
	 */
	public function setPMSymbol(symbol:String):Void {
		m_attributes.objectForKey(NSUserDefaults.NSAMPMDesignation)
			.replaceObjectAtIndexWithObject(1, symbol);
	}
	
	/**
	 * Returns the array of short month symbols for the receiver.
	 */
	public function shortMonthSymbols():NSArray {
		return NSArray(m_attributes.objectForKey(NSUserDefaults.NSShortMonthNameArray));
	}
	
	/**
	 * Sets the receiver’s array of short month symbols to <code>symbols</code>.
	 */
	public function setShortMonthSymbols(symbols:NSArray):Void {
		m_attributes.setObjectForKey(symbols, NSUserDefaults.NSShortMonthNameArray);
	}
	
	/**
	 * Returns the array of short weekday symbols for the receiver.
	 */
	public function shortWeekdaySymbols():NSArray {
		return NSArray(m_attributes.objectForKey(NSUserDefaults.NSShortWeekDayNameArray));
	}
	
	/**
	 * Sets the receiver’s array of short weekday symbols to <code>symbols</code>.
	 */
	public function setShortWeekdaySymbols(symbols:NSArray):Void {
		m_attributes.setObjectForKey(symbols, NSUserDefaults.NSShortWeekDayNameArray);
	}
	
	public function dateStyle():String {
		return String(m_attributes.objectForKey(NSUserDefaults.NSDateFormatString));
	}
	
	public function setDateStyle(style:String):Void {
		m_attributes.setObjectForKey(style, NSUserDefaults.NSDateFormatString);
	}
	
	public function timeStyle():String {
		return String(m_attributes.objectForKey(NSUserDefaults.NSTimeFormatString));
	}
	
	public function setTimeStyle(style:String):Void {
		m_attributes.setObjectForKey(style, NSUserDefaults.NSTimeFormatString);
	}
	
	/**
	 * Returns the time zone for the receiver.
	 */
	public function timeZone():NSTimeZone {
		return m_timeZone;
	}
	
	/**
	 * Sets the receiver’s time zone to <code>tz</code>.
	 */
	public function setTimeZone(tz:NSTimeZone):Void {
		m_timeZone = tz;
	}
	
	/**
	 * Returns the array of weekday symbols for the receiver.
	 */
	public function weekdaySymbols():NSArray {
		return NSArray(m_attributes.objectForKey(NSUserDefaults.NSWeekDayNameArray));
	}
	
	/**
	 * Sets the receiver’s array of weekday symbols to <code>symbols</code>.
	 */
	public function setWeekdaySymbols(symbols:NSArray):Void {
		m_attributes.setObjectForKey(symbols, NSUserDefaults.NSWeekDayNameArray);
	}
	
	public function __setAttributes(atts:NSDictionary):Void {
		if (atts == null) {
			m_attributes = NSUserDefaults.standardUserDefaults().dictionaryRepresentation();;
		} else {
			m_attributes = NSDictionary.dictionaryWithDictionary(atts);
		}
	}
	
	//******************************************************															 
	//*             Date to String Conversion
	//******************************************************
	
	/**
	 * Calls {@link #stringFromDate} if value is an <code>NSDate</code>.
	 *
	 * @see org.actionstep.NSFormatter#stringForObjectValue
	 * @see org.actionstep.NSDateFormatter#stringFromDate
	 */
	public function stringForObjectValue(value:Object):String {
		if (!(value instanceof NSDate)) {
			return null;
		}
		
		return stringFromDate(NSDate(value));
	}
		
	/**
	 * Returns a string representation of date based on this formatter's 
	 * current settings.
	 */
	public function stringFromDate(date:NSDate):String {
		return formatDate(dateFormat(), date, m_attributes);
	}
		
	//******************************************************															 
	//*             String to Date Conversion
	//******************************************************
	
	/**
	 * Calls {@link #dateFromString()}.
	 *
	 * @see org.actionstep.NSFormatter#getObjectValueForStringErrorDescription
	 * @see #dateFromString
	 */
	public function getObjectValueForString(string:String)
			:ASFormatResult	{
		var ret:ASFormatResult = new ASFormatResult();
		var dt:NSDate = dateFromString(string);
		
		if (dt == null)	{
			ret.initWithSuccessObjectError(false, null, 
				"There was a problem during the conversion process.");
		} else {
			ret.initWithSuccessObjectError(true, dt, null);
		}
		
		return ret;
	}
	
	/**
	 * Returns a date constructed from a string based on this formatter's
	 * current settings.
	 */
	public function dateFromString(string:String):NSDate {
		var res:ASFormatResult = buildDateFromStringFormat(dateFormat(), 
			string, m_attributes, m_genCalDates);
		return res.success() ? NSDate(res.objectValue()) : null;
	}
	
	//******************************************************															 
	//*                String Formatting
	//******************************************************	
	
	/**
	 * <p>Parses the format string into an intermediate format.</p>
	 *
	 * <p><strong>Format description:</strong>
	 *	The format consists of an array of simple objects. These objects can
	 *	represent one of three things:</p>
	 *
	 * <ol>
	 *		<li>A format character.</li>
	 *		<li>A word (not a format character or whitespace.</li>
	 *		<li>A space.</li>
	 * </ol>
	 *
	 * <p>Each object is formatted as follows:</br>
	 * <code>{type: ASFormatChar|ASWord|ASSpaceChar, value: The value (without % for format characters)}</code>
	 * </p>
	 */
	private static function parseFormatString(format:String):Array {
		var ret:Array;
		var char:String; // the current character
		var isFormatChar:Boolean = false;
		var onWord:Boolean = false;
		var wasOnWord:Boolean = false;
		var wordStartIdx:Number;
		var len:Number = format.length;
		var curObj:Object;
		
		ret = new Array();
		
		//
		// Move through the format string's characters.
		//
		for (var i:Number = 0; i < len; i++) {
			char = format.charAt(i);
			wasOnWord = onWord;
						
			if (isFormatChar) {
				if (isTypeCharacter(char)) { // output format
					ret.push({type: ASFormatChar, value: char});
				} else {
					//! error?
				}
				
				isFormatChar = false;
				continue;
			}
			
			switch (char) {
				case "%":
					onWord = false;
					isFormatChar = true;
					break;
					
				case " ": // space handling
				case "\t":
				case "\n":
				case "\r":
					onWord = false;
					ret.push({type: ASSpaceChar, value:char});
					break;
					
				default:
					onWord = true;
					break;
			}
			
			//
			// Word collection
			//
			if (!onWord && wasOnWord) {
				var top:Object = ret.pop();
				
				if (top != null && top.type != ASSpaceChar) {
					ret.push(top);
				}
				
				ret.push({type: ASWord, value: format.slice(wordStartIdx, i)});
				
				if (top.type == ASSpaceChar) {
					ret.push(top);
				}
			}
			else if (onWord && !wasOnWord) {
				wordStartIdx = i;
			}
		}
		
		if (onWord) {
			ret.push({type: ASWord, value: format.slice(wordStartIdx)});
		}
		
		return ret;
	}
	
	/**
	 * Formats the date date according to the calendar format format, and
	 * returns the resulting string.
	 */
	private static function formatDate(format:String, date:NSDate, 
			locale:NSDictionary):String {		

		
		if (locale == null) {
			locale = NSUserDefaults.standardUserDefaults().dictionaryRepresentation();
		}
		
		if (format == null) {
			format = String(locale.objectForKey(NSUserDefaults.NSDateFormatString));
		}
		
		var parts:Array = parseFormatString(format);
		var formatted:Array = new Array();
		var len:Number = parts.length;
		var obj:Object;
		
		for (var i:Number = 0; i < len; i++) {
			obj = parts[i];
			
			switch (obj.type) {
				case ASWord:
				case ASSpaceChar:
					formatted.push(obj.value);
					break;
				
				case ASFormatChar:
					formatted.push(g_types[obj.value](obj.value, date, locale));
					break;
			}
		}
		
		return formatted.join("");
	}
	
	/**
	 * Given a string representing a date and the format and locale with which
	 * the date was formatted, this method will build and return the date.
	 */
	private static function buildDateFromStringFormat(format:String, 
			date:String, locale:NSDictionary, caldate:Boolean):ASFormatResult {

		if (locale == null) {
			locale = NSUserDefaults.standardUserDefaults().dictionaryRepresentation();
		}
		
		if (format == null) {
			format = String(locale.objectForKey(NSUserDefaults.NSDateFormatString));
		}
		
		//
		// Replace default date and time formats with their locale 
		// representations
		//
		// FIXME there is a bug here with the replacement and % checking
		var idx:Number;
		if ((idx = format.indexOf("%c")) != -1 && format.charAt(idx - 1) != "%") {
			format = format.split("%c").join("%x %X");
		}
		if ((idx = format.indexOf("%x")) != -1 && format.charAt(idx - 1) != "%") {
			var dtf:String = String(locale.objectForKey(NSUserDefaults.NSDateFormatString));
			format = format.split("%x").join(dtf);
		}
		if ((idx = format.indexOf("%X")) != -1 && format.charAt(idx - 1) != "%") {
			
			var tmf:String = String(locale.objectForKey(NSUserDefaults.NSTimeDateFormatString));
			format = format.split("%X").join(tmf);
		}
		
		var obj:Object;
		var res:Object;
		var dtinfo:Object = {};		
		var parts:Array = parseFormatString(format);
		var len:Number = parts.length;
		
		for (var i:Number = 0; i < len; i++) {
			obj = parts[i];
			
			switch (obj.type) {
				case ASWord:
				case ASSpaceChar:
					date = date.substr(obj.value.length);
					break;
				
				case ASFormatChar:
					res = g_reverseTypes[obj.value](obj.value, date, locale);
					dtinfo[obj.value] = res;
					date = date.substr(res.offset);					
					break;
			}
		}
		
		var dt:Date = new Date(0, 0, 0, 0, 0, 0, 0);
		var ampm:Number = -2;
		var hour:Number;
		var dayofyear:Number = -1;
		for (var c:String in dtinfo) {
			var t:Object = dtinfo[c];
			switch (c) {
				case "d":
				case "e":
					dt.setDate(t.value);
					break;
					
				case "j": // day of year
					dayofyear = t.value;
					break;
					
				case "b":
				case "B":
				case "m":
					dt.setMonth(t.value);
					break;
					
				case "Y":
					dt.setFullYear(t.value);
					break;
					
				case "y":
					dt.setYear(t.value);
					break;
					
				case "H":
					dt.setHours(t.value);
					break;
					
				case "I":
					if (ampm >= 0) {
						dt.setHours(ampm * 12 + t.value);
					} else {
						ampm = -1;
						hour = t.value;
					}
					
					break;
					
				case "M":
					dt.setMinutes(t.value);
					break;
					
				case "S":
					dt.setSeconds(t.value);
					break;
					
				case "F":
					dt.setMilliseconds(t.value);
					break;
					
				case "p":
					if (ampm == -1) {
						dt.setHours(t.value * 12 + hour);
					}
					
					ampm = t.value;
					break;
			}
		}
		
		if (dayofyear != -1) {
			var offset:Number = dayofyear * 24 * 60 * 60 * 1000;
			dt.setMonth(0);
			dt.setDate(1);
			
			dt = new Date(dt.getTime() + offset);
		}
		
		var dtobj:NSDate;
		if (caldate) {
			dtobj = (new NSCalendarDate()).initWithDate(dt);
		} else {
			dtobj = NSDate.dateWithDate(dt);
		}
		
		return (new ASFormatResult()).initWithSuccessObjectError(true, dtobj, "");
	}
	
	/**
	 * Returns whether a character should be handled by one of the handlers or 
	 * not.
	 */
	private static function isTypeCharacter(char:String):Boolean {		
		return (g_types[char] != undefined);
	}
	
	/**
	 * Method to assist in debugging
	 */
	private static function traceCompiledFormat(format:Array):Void {
		trace("**** BEGIN COMPILED FORMAT trace ****");
		
		for (var i:Number = 0; i < format.length; i++) {
			var type:String;
			
			switch (format[i].type)	{
				case ASWord:
					type = "ASWord";
					break;
					
				case NSDateFormatter.ASFormatChar:
					type = "ASFormatChar";
					break;
					
				case NSDateFormatter.ASSpaceChar:
					type = "ASSpaceChar";
					break;
					
			}
			
			trace("** " + i + ": (type=" + type + ", value=" + format[i].value + ")");
		}
		
		trace("**** END COMPILED FORMAT trace ****");
	}
	
	//******************************************************															 
	//*                  Format Handlers
	//******************************************************	
	
	/**
	 * Handles a percentage symbol.
	 */
	private static function handlePercentage(char:String, date:NSDate,
			locale:NSDictionary):String {
		return "%";
	}
	
	/**
	 * Reverse operation on a percentage symbol.
	 */
	private static function reversePercentage(char:String, date:String,
			locale:NSDictionary):Object {
		return {offset: 1, value: null};		
	}

	/**
	 * Handles a formatted weekday.
	 */
	private static function handleWeekDay(char:String, date:NSDate,
			locale:NSDictionary):String {		
		var calDt:NSCalendarDate = (new NSCalendarDate()).initWithDate(
			date.internalDate());
		var str:String;
		var arr:NSArray;
		var dayOfWeek:Number = calDt.dayOfWeek();
		
		switch (char) {
			case "a":
				arr = NSArray(locale.objectForKey(
					NSUserDefaults.NSShortWeekDayNameArray));
				str = String(arr.objectAtIndex(dayOfWeek));
				break;
				
			case "A":
				arr = NSArray(locale.objectForKey(
					NSUserDefaults.NSWeekDayNameArray));
				str = String(arr.objectAtIndex(dayOfWeek));
				break;
				
			case "w":
				str = dayOfWeek.toString();
				break;	
		}
		
		return str;
	}
	
	/**
	 * <p>Changes a formatted weekday into a number (from 0 to 6), and returns 
	 * an object structured as follows:</p>
	 * <p><code>{offset:Number, value:Number}</code></p>
	 */
	private static function reverseWeekDay(char:String, date:String, 
			locale:NSDictionary):Object {
		var length:Number;
		var weekday:Number;
		var str:String;
		var arr:Array;
		
		switch (char) {
			case "a":
				arr = NSArray(locale.objectForKey(
					NSUserDefaults.NSShortWeekDayNameArray)).internalList();
				break;
				
			case "A":
				arr = NSArray(locale.objectForKey(
					NSUserDefaults.NSWeekDayNameArray)).internalList();
				break;
				
			case "w":				
				weekday = parseInt(date.substr(0, 1));
				
				if (isNaN(weekday)) {
					var e:NSException = NSException.exceptionWithNameReasonUserInfo(
						"DateFormattingException",
						"Could not turn " + str + " into a weekday for %m",
						null);
					trace(e);
					throw e;
				}
				
				return {offset: 1, value: weekday};	
		}
		
		//
		// Attempt to match month
		//
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			if (date.indexOf(arr[i]) == 0) {
				weekday = i;
				length = arr[i].length;
				return {offset: length, value: weekday};
			}
		}
		
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			"DateFormattingException",
			"Was not able to change " + date + " in a weekday for " + char,
			null);
		trace(e);
		throw e;
		
		return null;
	}
	
	/**
	 * Handles a formatted month.
	 */
	private static function handleMonth(char:String, date:NSDate, 
			locale:NSDictionary):String	{
		var str:String;
		var arr:NSArray;
		var month:Number = date.internalDate().getMonth();
		
		switch (char) {
			case "b":
				arr = NSArray(locale.objectForKey(
					NSUserDefaults.NSShortMonthNameArray));
				str = String(arr.objectAtIndex(month));
				break;
				
			case "B":
				arr = NSArray(locale.objectForKey(
					NSUserDefaults.NSMonthNameArray));
				str = String(arr.objectAtIndex(month));
				break;
				
			case "m":
				month++;
				str = month.toString();
				
				if (str.length == 1)
					str = "0" + str;
					
				break;
				
		}
		
		return str;
	}
	
	/**
	 * <p>Changes a formatted month into a number, and returns an object
	 * structured as follows:</p>
	 * <p><code>{offset:Number, value:Number}</code></p>
	 */
	private static function reverseMonth(char:String, date:String, 
			locale:NSDictionary):Object {
		var length:Number;
		var month:Number;
		var str:String;
		var arr:Array;
		
		switch (char) {
			case "b":
				arr = NSArray(locale.objectForKey(
					NSUserDefaults.NSShortMonthNameArray)).internalList();
				break;
				
			case "B":
				arr = NSArray(locale.objectForKey(
					NSUserDefaults.NSMonthNameArray)).internalList();
				break;
				
			case "m":
				str = date.substr(0, 2);				
				month = parseInt(str);
				
				if (isNaN(month)) {
					var e:NSException = NSException.exceptionWithNameReasonUserInfo(
						"DateFormattingException",
						"Could not turn " + str + " into a month for %m",
						null);
					trace(e);
					throw e;
				}
				
				month--;
				return {offset: 2, value: month};	
		}
		
		//
		// Attempt to match month
		//
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			if (date.indexOf(arr[i]) == 0) {
				month = i;
				length = arr[i].length;
				return {offset: length, value: month};
			}
		}
		
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			"DateFormattingException",
			"Was not able to change " + date + " in a month for " + char,
			null);
		trace(e);
		throw e;
		
		return null;
	}
	
	/**
	 * Handles the locale default (%c = %x %X).
	 */
	private static function handleLocaleDefault(char:String, date:NSDate, 
			locale:NSDictionary):String	{
		var str:String = "";
		
		str += handleDefaultDate(char, date, locale) + " ";
		str += handleDefaultTime(char, date, locale);
		
		return str;
	}
	
	/**
	 * Handles the day of the month.
	 */
	private static function handleDay(char:String, date:NSDate, 
			locale:NSDictionary):String	{
		var calDt:NSCalendarDate = (new NSCalendarDate()).initWithDate(
			date.internalDate());
		var str:String;
		
		switch (char) {
			case "d":
				str = calDt.dayOfMonth().toString();
				
				if (str.length == 1)
					str = "0" + str;
					
				break;
				
			case "e":
				str = calDt.dayOfMonth().toString();
				break;
				
			case "j":
				str = calDt.dayOfYear().toString();
				
				if (str.length == 1) {
					str = "00" + str;
				}
				else if (str.length == 2) {
					str = "0" + str;
				}
				
				break;
				
		}
		
		return str;
	}
	
	/**
	 * <p>Changes a formatted day into a number, and returns an object
	 * structured as follows:</p>
	 * <p><code>{offset:Number, value:Number}</code></p>
	 */
	private static function reverseDayOfMonth(char:String, date:String, 
			locale:NSDictionary):Object {
		var day:Number;
		var length:Number;
		
		if (char == "d") {
			day = parseInt(date.substr(0, 2));
			length = 2;
		} else { // char = "e"
			var fc:String = date.charAt(0);
			if (fc == "1" || fc == "2" || fc == "3") {
				var sc:Number = date.charCodeAt(1);
				if (sc >= 48 && sc <= 57) {
					day = parseInt(date.substr(0, 2));
					length = 2;
				} else {
					day = parseInt(date.substr(0, 1));
					length = 1;
				}
			} else {
				day = parseInt(date.substr(0, 1));
				length = 1;
			}
			
		}
		
		if (isNaN(day)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"DateFormattingException",
				"Was not able to change " + date + " into a day of month value "
				+ "for " + char,
				null);
			trace(e);
			throw e;
		}
		
		return {offset: length, value: day};	
	}
	
	/**
	 * <p>Changes a formatted day into a number, and returns an object
	 * structured as follows:</p>
	 * <p><code>{offset:Number, value:Number}</code></p>
	 */
	private static function reverseDayOfYear(char:String, date:String, 
			locale:NSDictionary):Object {
		var day:Number = parseInt(date.substr(0, 3));
		if (isNaN(day)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"DateFormattingException",
				"Was not able to change " + date + " into a day of year value "
				+ "for " + char,
				null);
			trace(e);
			throw e;
		}
		
		return {offset: 3, value: day};	
	}
	
	/**
	 * Returns the number of milliseconds (0 - 999).
	 */
	private static function handleMilliseconds(char:String, date:NSDate, 
			locale:NSDictionary):String	{
		var ms:String = date.internalDate().getMilliseconds().toString();
		
		if (ms.length == 1) {
			ms = "00" + ms;
		}
		else if (ms.length == 2) {
			ms = "0" + ms;
		}
		
		return ms;
	}
	
	/**
	 * Converts a string millisecond value back into a number.
	 */
	private static function reverseMilliseconds(char:String, date:String, 
			locale:NSDictionary):Object {
		var ms:Number = Number(date.substr(0, 3));
		
		if (isNaN(ms)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"DateFormattingException",
				"Was not able to change " + date + " into a millisecond value "
				+ "for " + char,
				null);
			trace(e);
			throw e;
		}
		
		return {offset: 3, value: ms};		
	}
	
	/**
	 * Handles the hour.
	 */
	private static function handleHour(char:String, date:NSDate, 
			locale:NSDictionary):String	{
		var calDt:NSCalendarDate = (new NSCalendarDate()).initWithDate(
			date.internalDate());
		var str:String;
		
		switch (char) {
			case "H":
				str = calDt.hourOfDay().toString();
				break;
				
			case "I":
				str = ((calDt.hourOfDay() % 12) + 1).toString();
				break;
				
		}
		
		if (str.length == 1) {
			str = "0" + str;
		}
			
		return str;
	}
	
	/**
	 * <p>Converts an string hour value back into a number. Returns an object
	 * structured as follows:</p>
	 * <p><code>{offset: Number, value: Number, requiresAMPM: Boolean}</code></p>
	 */
	private static function reverseHour(char:String, date:String, 
			locale:NSDictionary):Object {
		var hour:Number = parseInt(date.substr(0, 2));
		var length:Number = 2;
		var requiresAMPM:Boolean = false;
		
		if (isNaN(hour)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"DateFormattingException",
				"Was not able to change " + date + " into an hour value "
				+ "for " + char,
				null);
			trace(e);
			throw e;
		}
		
		if (char == "I") {
			hour--;
			requiresAMPM = true;
		}
		
		return {offset: length, value: hour, requiresAMPM: requiresAMPM};		
	}
	
	/**
	 * Handles the timezone.
	 */
	private static function handleTimeZone(char:String, date:NSDate, 
			locale:NSDictionary):String {
		var calDt:NSCalendarDate = (new NSCalendarDate()).initWithDate(
			date.internalDate());
		var str:String;
		
		switch (char) {
			case "z":
				var sec:Number = calDt.timeZone().secondsFromGMT();
				var mn:Number = Math.floor(sec / 60);
				var hr:Number = Math.floor(mn / 60);
				mn %= 60;
				var strHr:String = hr.toString();
				var strMn:String = mn.toString();
				
				if (strHr.length == 1)
					strHr = "0" + hr;
					
				if (strMn.length == 1)
					strMn = "0" + mn;
					
				str = strHr + strMn;				
				break;
				
			case "Z":
				str = calDt.timeZone().name();
				break;
		}
		
		return str;		
	}
	
	/**
	 * Handles the minute.
	 */
	private static function handleMinute(char:String, date:NSDate, 
			locale:NSDictionary):String {
		var calDt:NSCalendarDate = (new NSCalendarDate()).initWithDate(
			date.internalDate());
		var str:String = calDt.minuteOfHour().toString();
		
		if (str.length == 1) {
			str = "0" + str;
		}
			
		return str;
	}
	
	/**
	 * Changes a minute string back into a number.
	 */
	private static function reverseMinute(char:String, date:String, 
			locale:NSDictionary):Object {
		var minute:Number = parseInt(date.substr(0, 2));
		
		if (isNaN(minute)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"DateFormattingException",
				"Was not able to change " + date + " into a minute value "
				+ "for " + char,
				null);
			trace(e);
			throw e;
		}
		
		return {offset: 2, value: minute};
	}
	
	/**
	 * Returns AM / PM.
	 */
	private static function handleAmPm(char:String, date:NSDate, 
			locale:NSDictionary):String	{
		var str:String;
		var arr:NSArray = NSArray(locale.objectForKey(
			NSUserDefaults.NSAMPMDesignation));
				
		if ((date.internalDate().getHours() + 1) / 12 < 1) {
			str = String(arr.objectAtIndex(0));
		} else {
			str = String(arr.objectAtIndex(1));
		}
			
		return str;
	}
	
	private static function reverseAmPm(char:String, date:String, 
			locale:NSDictionary):Object {
		var arr:Array = NSArray(locale.objectForKey(
			NSUserDefaults.NSAMPMDesignation)).internalList();
		if (date.indexOf(arr[0]) == 0) {
			return {offset: arr[0].length, value: 0};
		} 
		else if (date.indexOf(arr[1]) == 0) {
			return {offset: arr[1].length, value: 1};
		} else {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"DateFormattingException",
				"Was not able to change " + date + " into an AM/PM value "
				+ "for " + char,
				null);
			trace(e);
			throw e;
		}		
	}
	
	/**
	 * Handles second representation.
	 */
	private static function handleSecond(char:String, date:NSDate, 
			locale:NSDictionary):String {
		var calDt:NSCalendarDate = (new NSCalendarDate()).initWithDate(
			date.internalDate());
		var str:String = calDt.secondOfMinute().toString();
		
		if (str.length == 1) {
			str = "0" + str;
		}
			
		return str;
	}
	
	/**
	 * Changes a second string back into a number.
	 */
	private static function reverseSecond(char:String, date:String, 
			locale:NSDictionary):Object {
		var second:Number = parseInt(date.substr(0, 2));
		
		if (isNaN(second)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"DateFormattingException",
				"Was not able to change " + date + " into a second value "
				+ "for " + char,
				null);
			trace(e);
			throw e;
		}
		
		return {offset: 2, value: second};
	}
	
	/**
	 * Handles years.
	 */
	private static function handleYear(char:String, date:NSDate, 
			locale:NSDictionary):String {
		var str:String;
		
		switch (char) {
			case "y":
				str = date.internalDate().getYear().toString();
				break;
				
			case "Y":
				str = date.internalDate().getFullYear().toString();
				break;
		}
		
		return str;
	}

	/**
	 * Changes a year string back into a number.
	 */
	private static function reverseYear(char:String, date:String, 
			locale:NSDictionary):Object {
		var length:Number;
		
		if (char == "y") {
			length = 2;
		} else {
			length = 4;
		}
		
		var year:Number = parseInt(date.substr(0, length));
		
		if (isNaN(year)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"DateFormattingException",
				"Was not able to change " + date + " into a year value "
				+ "for " + char,
				null);
			trace(e);
			throw e;
		}
		
		return {offset: length, value: year};
	}
	
	/**
	 * Handles the era according to the locale.
	 */
	private static function handleEra(char:String, date:NSDate,
			locale:NSDictionary):String {
		var eras:NSArray = NSArray(locale.objectForKey(NSUserDefaults.NSEraDesignations));
		var year:Number = date.internalDate().getFullYear();
		
		if (year < 0) {
			return eras.objectAtIndex(0).toString();
		}
		
		return eras.objectAtIndex(1).toString();
	}
	
	/**
	 * Handles default dates according to the locale.
	 */	
	private static function handleDefaultDate(char:String, date:NSDate, 
			locale:NSDictionary):String	{
		return formatDate(String(
			locale.objectForKey(NSUserDefaults.NSDateFormatString)),
			date, locale);
	}
	
	/**
	 * Handles default time according to the locale.
	 */
	private static function handleDefaultTime(char:String, date:NSDate, 
			locale:NSDictionary):String	{
		return formatDate(String(
			locale.objectForKey(NSUserDefaults.NSTimeDateFormatString)),
			date, locale);
	}
	
	//******************************************************															 
	//*               Static Constructor
	//******************************************************
	
	/**
	 * Runs when the application begins.
	 */
	private static function initialize():Void {			
		//
		// Handler functions (for date formatting)
		//
		g_types = new Object();
		g_types["%"] = handlePercentage;
		g_types["a"] = g_types["A"] = g_types["w"] = handleWeekDay;
		g_types["b"] = g_types["B"] = g_types["m"] = handleMonth;
		g_types["c"] = handleLocaleDefault;
		g_types["d"] = g_types["e"] = g_types["j"] = handleDay;
		g_types["F"] = handleMilliseconds;
		g_types["H"] = g_types["I"] = handleHour;
		g_types["M"] = handleMinute;
		g_types["p"] = handleAmPm;
		g_types["S"] = handleSecond;
		g_types["y"] = g_types["Y"] = handleYear;
		g_types["z"] = g_types["Z"] = handleTimeZone;
		g_types["x"] = handleDefaultDate;
		g_types["X"] = handleDefaultTime;
		g_types["G"] = handleEra;
		
		g_reverseTypes = new Object();
		g_reverseTypes["%"] = reversePercentage;
		g_reverseTypes["b"] = g_reverseTypes["B"] = g_reverseTypes["m"] 
			= reverseMonth;
//		g_reverseTypes["c"] = handleLocaleDefault;
		g_reverseTypes["a"] = g_reverseTypes["A"] = g_reverseTypes["w"]
			= reverseWeekDay;
		g_reverseTypes["d"] = g_reverseTypes["e"] = reverseDayOfMonth; 
		g_reverseTypes["j"] = reverseDayOfYear;
		g_reverseTypes["F"] = reverseMilliseconds;
		g_reverseTypes["H"] = g_reverseTypes["I"] = reverseHour;
		g_reverseTypes["M"] = reverseMinute;
		g_reverseTypes["p"] = reverseAmPm;
		g_reverseTypes["S"] = reverseSecond;
		g_reverseTypes["y"] = g_reverseTypes["Y"] = reverseYear;
//		g_reverseTypes["z"] = g_reverseTypes["Z"] = handleTimeZone;
//		g_reverseTypes["x"] = handleDefaultDate;
//		g_reverseTypes["X"] = handleDefaultTime;
//		g_reverseTypes["G"] = handleEra;
		
	}
}
