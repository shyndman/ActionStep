/* See LICENSE for copyright and terms of use */

import org.actionstep.NSDate; 
import org.actionstep.NSDateFormatter;
import org.actionstep.NSDictionary;
import org.actionstep.NSCopying;
import org.actionstep.NSObject;
import org.actionstep.NSTimeZone;

/**
 * <p><code>NSCalendarDate</code> is a public subclass of {@link NSDate} that
 * represents concrete date objects and performs date computations based on the
 * Gregorian calendar.</p>
 *
 * <p>For an example of this class' usage, please see
 * {@link org.actionstep.test.ASTestDate}.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSCalendarDate extends NSDate implements NSCopying
{
	/** The number of milliseconds in a day. */
	private static var MSPERDAY:Number 		= 86400000;
	/** The number of milliseconds in an hour. */
	private static var MSPERHOUR:Number		= 3600000;
	/** The number of milliseconds in a minute. */
	private static var MSPERMINUTE:Number	= 60000;
	/** The number of milliseconds in a second. */
	private static var MSPERSECOND:Number	= 1000;

	/** Format specifier character to function map. */
	private static var g_types:Object;
	private static var g_firstDayInCommonEra:Date;
	private var m_calendarFormat:String;
	private var m_timeZone:NSTimeZone;

	//******************************************************
	//*                    Construction
	//******************************************************

	/**
	 * Creates an instance of the <code>NSCalendarDate</code> class.
	 */
	public function NSCalendarDate() {
		super();
	}

	/**
	 * Creates a date from a string. The string must adhere to the format
	 * <code>"%Y-%m-%d %H:%M:%S %z"</code> exactly, or <code>null</code> will be
	 * returned.
	 */
	public function initWithString(description:String):NSCalendarDate {
		return initWithStringCalendarFormat(description, "%Y-%m-%d %H:%M:%S %z");
	}

	/**
	 * Creates a date from a string using the calendar format
	 * <code>format</code> to interpret the string.
	 */
	public function initWithStringCalendarFormat(description:String,
			format:String):NSCalendarDate {
		return initWithStringCalendarFormatLocale(description, format, null); //! last param
	}

	/**
	 * TODO Document
	 */
	public function initWithStringCalendarFormatLocale(description:String,
			format:String, locale:NSDictionary):NSCalendarDate {
		super.init();

		var dt:NSCalendarDate =
			NSCalendarDate.reverseFormatWithDescriptionFormatLocale(description,
			format, locale);
		internalDate().setTime(dt.internalDate().getTime());

		m_calendarFormat = format;
		m_timeZone = NSTimeZone.defaultTimeZone();

		return this;
	}

	/**
	 * Inits a caledar date using the specified values.
	 *
	 * @param year 		The year. Must include a century (1999, not 99).
	 * @param month 	The month. A value from 1 to 12.
	 * @param day 		The day. A value from 1 to 31.
	 * @param hour		The hour. A value from 0 to 23.
	 * @param minute	The minute. A value from 0 to 59.
	 * @param second	The second. A value from 0 to 59.
	 * @param timezone	The timezone.
	 */
	public function initWithYearMonthDayHourMinuteSecondTimeZone(
			year:Number, month:Number, day:Number, hour:Number,
			minute:Number, second:Number,
			timezone:NSTimeZone):NSCalendarDate {
		super.init();

		m_dt.setFullYear(year);
		m_dt.setMonth(month - 1);
		m_dt.setDate(day);
		m_dt.setHours(hour);
		m_dt.setMinutes(minute);
		m_dt.setSeconds(second);
		m_timeZone = timezone;

		return this;
	}

	/**
	 * <p>Inits a calendar date using an instance of ActionScript's
	 * {@link Date} class.</p>
	 *
	 * <p>ActionStep only.</p>
	 */
	public function initWithDate(date:Date):NSCalendarDate {
		super.init();
		m_dt.setTime(date.getTime());
		m_timeZone = NSTimeZone.defaultTimeZone();

		return this;
	}

	//******************************************************
	//*               Retrieving date elements
	//******************************************************

	/**
	 * Returns the number of days since the beginning of the Common Era.
	 * The base year of the Common Era is 1 C.E. (which is the same as 1 A.D.).
	 */
	public function dayOfCommonEra():Number {
		var ms:Number = m_dt.getTime();
		ms += -1 * g_firstDayInCommonEra.getTime();

		return Math.floor(ms / MSPERDAY);
	}

	/**
	 * Returns the day of the month (<code>1</code> through <code>31</code>).
	 */
	public function dayOfMonth():Number {
		return m_dt.getDate();
	}

	/**
	 * Returns the day of the week (<code>0</code> through <code>6</code>).
	 */
	public function dayOfWeek():Number {
		return m_dt.getDay();
	}

	/**
	 * Returns the day of the year (<code>1</code> through <code>366</code>).
	 */
	public function dayOfYear():Number {
		var delta:Number;
		var calcDate:Date;

		calcDate = NSDate(super.copy()).internalDate();
		calcDate.setMonth(0);
		calcDate.setDate(1);
		calcDate.setHours(0);
		calcDate.setMinutes(0);
		calcDate.setSeconds(0);
		calcDate.setMilliseconds(0);

		delta = m_dt.getTime() - calcDate.getTime();
		return Math.ceil(delta / MSPERDAY);
	}

	/**
	 * Returns the hour of the day (<code>0</code> through <code>23</code>).
	 */
	public function hourOfDay():Number {
		return m_dt.getHours();
	}

	/**
	 * Returns the minute of the hour (<code>0</code> through <code>59</code>).
	 */
	public function minuteOfHour():Number {
		return m_dt.getMinutes();
	}

	/**
	 * Returns the month of the year (<code>1</code> through <code>12</code>).
	 */
	public function monthOfYear():Number {
		return m_dt.getMonth() + 1;
	}

	/**
	 * Returns the second of the current minute (<code>0</code> through
	 * <code>59</code>).
	 */
	public function secondOfMinute():Number {
		return m_dt.getSeconds();
	}

	/**
	 * Returns a number that indicates the year (ie. <code>2005</code>).
	 */
	public function yearOfCommonEra():Number {
		return m_dt.getFullYear();
	}

	//******************************************************
	//*                 Adjusting a date
	//******************************************************

	/**
	 * <p>Creates a new calendar date by adding the arguments to the this
	 * dates values, and returns the new date.</p>
	 *
	 * <p>Arguments can be both negative and positive.</p>
	 */
	public function dateByAddingYearsMonthsDaysHoursMinutesSeconds(
			years:Number, months:Number, days:Number, hours:Number,
			minutes:Number, seconds:Number):NSCalendarDate {
		var currentTime:Number;
		var offset:Number;
		var calcDate:Date;
		var totalMonths:Number;
		var remainingMonths:Number;
		var monthsInYears:Number;

		//
		// Add years.
		//
		calcDate = NSDate(super.copy()).internalDate();
		calcDate.setFullYear(calcDate.getFullYear() + years);

		//
		// Add months.
		//
		totalMonths = months + calcDate.getMonth() + 1;
		remainingMonths = totalMonths % 12;
		monthsInYears = Math.floor(totalMonths / 12);
		calcDate.setFullYear(calcDate.getFullYear() + monthsInYears);
		calcDate.setMonth(remainingMonths);

		//
		// Calc offset using days, hours, minutes, and seconds (always constant milliseconds)
		//
		offset = 0;
		offset += MSPERDAY * days;
		offset += MSPERHOUR * hours;
		offset += MSPERMINUTE * minutes;
		offset += MSPERSECOND * seconds;
		calcDate.setTime(calcDate.getTime() + offset);

		//
		// Return the new date.
		//
		return (new NSCalendarDate()).initWithYearMonthDayHourMinuteSecondTimeZone(
			calcDate.getFullYear(), calcDate.getMonth(), calcDate.getDate(),
			calcDate.getHours(), calcDate.getMinutes(), calcDate.getSeconds(),
			m_timeZone);
	}

	//******************************************************
	//*              Computing date intervals
	//******************************************************

	/**
	 * <p>Returns an object containing the number of years, months, days, hours,
	 * minutes and seconds between this and the date date.</p>
	 *
	 * <p>The object is formatted as follows:<br/>
	 * <code>{years:Number, months:Number, days:Number, hours:Number, minutes:Number,
	 * 		seconds:Number}</code></p>
	 *
	 * <p>This differs from Cocoa because we don't have access to pointers in
	 * ActionScript, so we return an object containing multiple values instead.</p>
	 */
	public function yearsMonthsDaysHoursMinutesSecondsSinceDate(
			calDate:NSCalendarDate):Object {
		var delta:Number;
		var dayBeforeShift:Number, dayOffset:Number;
		var dt:Date, date:Date;
		var years:Number, months:Number, days:Number, hours:Number,
			minutes:Number, seconds:Number;
		var ms:Number;

		//
		// Account for timezones
		//
		dt = NSDate(super.copy()).internalDate();
		dt.setTime(dt.getTime() - timeZone().secondsFromGMT() * 1000);
		date = NSDate(calDate.copy()).internalDate();
		date.setTime(date.getTime() - calDate.timeZone().secondsFromGMT() * 1000);

		//
		// Find years
		//
		years = m_dt.getFullYear() - date.getFullYear();

		//
		// Decrease if necessary
		//
		dt.setFullYear(date.getFullYear());

		if (dt < date) {
			years--;
		}

		//
		// Find months
		//
		months = dt.getMonth() - date.getMonth();

		if (months < 0) {
			months += 12;
		}

		//
		// Find days
		//
		dayBeforeShift = date.getDate();
		date.setMonth(dt.getMonth());
		dayOffset = dayBeforeShift - date.getDate();

		days = dt.getDate() - date.getDate();

		if (days < 0) {
			months--;
			days *= -1;
		}

		days += dayOffset; //! This might be wrong sometimes. Think about it.

		//
		// Find hours
		//
		date.setDate(dt.getDate());
		hours = dt.getHours() - date.getHours();

		if (hours < 0) {
			days--;
			hours *= -1;
		}

		//
		// Find minutes
		//
		minutes = dt.getMinutes() - date.getMinutes();

		if (minutes < 0) {
			hours--;
			minutes *= -1;
		}

		//
		// Find seconds
		//
		seconds = dt.getSeconds() - date.getSeconds();

		if (seconds < 0) {
			minutes--;
			seconds *= -1;
		}

		//
		// Use milliseconds to properly adjust seconds
		//
		ms = dt.getMilliseconds() - date.getMilliseconds();

		if (ms < 0) {
			seconds--;
		}

		return {years: years, months: months, days: days, hours: hours,
			minutes: minutes, seconds: seconds};
	}

	//******************************************************
	//*            Representing dates as strings
	//******************************************************

	/**
	 * Returns a string representing the date using the default calendar
	 * format. This format can be seen by accessing this date's
	 * {@link #calendarFormat()} method.
	 */
	public function description():String {
		return descriptionWithCalendarFormat(m_calendarFormat);
	}

	/**
	 * Returns a string representation of the date using the provided
	 * format string, <code>format</code>.
	 */
	public function descriptionWithCalendarFormat(format:String):String {
		return descriptionWithCalendarFormatLocale(format, null);
	}

	/**
	 * Returns a string representation of the receiver. The string is formatted
	 * according to the conversion specifiers in <code>format</code> and
	 * represented according to the locale information in <code>locale</code>.
	 */
	public function descriptionWithCalendarFormatLocale(format:String,
			locale:NSDictionary):String {
		var dtf:NSDateFormatter = (new NSDateFormatter())
			.initWithDateFormatAllowNaturalLanguage(format, true);
		dtf.__setAttributes(locale);
		return dtf.stringFromDate(this); 
	}

	/**
	 * <p>Returns a string representation of the receiver. The string is formatted
	 * according to the default <code>format</code> and represented according to
	 * the locale information in <code>locale</code>.</p>
	 *
	 * <p>This method is used to print the <code>NSCalendarDate</code> when the
	 * <code>%@</code> conversion specifier is used.</p>
	 */
	public function descriptionWithLocale(locale:NSDictionary):String {
		return descriptionWithCalendarFormatLocale(m_calendarFormat, locale);
	}

	//******************************************************
	//*       Getting and setting calendar formats
	//******************************************************

	/**
	 * Returns the date's default calendar format. This format is used
	 * for {@link #description()} strings.
	 */
	public function calendarFormat():String
	{
		return m_calendarFormat;
	}

	/**
	 * Sets the date's default calendar format. This format is used
	 * for {@link #description()} strings.
	 */
	public function setCalendarFormat(format:String):Void
	{
		m_calendarFormat = format;
	}

	//******************************************************
	//*         Getting and setting the time zone
	//******************************************************

	/**
	 * Returns this date's timezone.
	 */
	public function timeZone():NSTimeZone {
		return m_timeZone;
	}

	/**
	 * Sets the time zone of this date.
	 */
	public function setTimeZone(timeZone:NSTimeZone):Void {
		m_timeZone = timeZone;
	}

	//******************************************************
	//*                  Date Formatting
	//******************************************************

	/**
	 * Uses a string representation of a date and the format string
	 * originally used to output the date, and returns the date described.
	 */
	private static function reverseFormatWithDescriptionFormatLocale(
			date:String, format:String, locale:NSDictionary):NSCalendarDate {
		var ret:NSCalendarDate;
		ret = new NSCalendarDate();

		//! TODO implement

		return ret;
	}

	//******************************************************
	//*                    NSCopying
	//******************************************************

	/**
	 * Returns a copy of this calendar date.
	 */
	public function copyWithZone():NSObject {
		var dt:NSCalendarDate = NSCalendarDate((new NSCalendarDate())
			.initWithTimeIntervalSinceDate(0, this));
		dt.setTimeZone(timeZone());
		return dt;
	}

	//******************************************************
	//*         Creating an NSCalendarDate instance
	//******************************************************

	/**
	 * Creates and returns a calendar date initialized to the current date and
	 * time.
	 */
	public static function calendarDate():NSCalendarDate {
		return (new NSCalendarDate()).initWithDate(new Date());
	}

	/**
	 * Creates and returns a calendar date initialized with the date specified
	 * in the string description. <code>NSCalendarDate</code> uses
	 * <code>format</code> both to interpret the <code>description</code> string
	 * and as the default calendar format for this new object.
	 * <code>format</code> consists of conversion specifiers similar to those
	 * used in <code>strftime()</code>. If <code>description</code> does not
	 * match format exactly, this method returns <code>null</code>.
	 */
	public static function dateWithStringCalendarFormat(description:String,
			format:String):NSCalendarDate {
		return (new NSCalendarDate()).initWithStringCalendarFormat(description,
			format);
	}

	/**
	 * <p>Creates and returns a calendar date initialized with the date specified
	 * in the string <code>description</code>. <code>NSCalendarDate</code> uses
	 * <code>format</code> both to interpret the <code>description</code> string
	 * and as the default calendar format for this new object.
	 * <code>format</code> consists of conversion specifiers similar to those
	 * used in <code>strftime()</code>. The keys and values that represent the
	 * locale data in <code>locale</code> are used when parsing the string. If
	 * <code>description</code> does not match <code>format</code> exactly, this
	 * method returns <code>null</code>.</p>
	 *
	 * <p>View <a href="http://developer.apple.com/documentation/Cocoa/Reference/Foundation/ObjC_classic/Classes/NSCalendarDate.html#//apple_ref/doc/uid/20000446-353730">
	 * NSString Representations for NSCalendarDates</a> for additional
	 * information on valid keys and values for the <code>locale</code>
	 * dictionary.</p>
	 *
	 * TODO Change URL above
	 */
	public static function dateWithStringCalendarFormatLocale(description:String,
			format:String, locale:NSDictionary):NSCalendarDate {
		return (new NSCalendarDate()).initWithStringCalendarFormatLocale(
			description, format, locale);
	}

	/**
	 * Creates and returns a calendar date initialized with the argument values.
	 *
	 * @param year 		The year. Must include a century (1999, not 99).
	 * @param month 	The month. A value from 1 to 12.
	 * @param day 		The day. A value from 1 to 31.
	 * @param hour		The hour. A value from 0 to 23.
	 * @param minute	The minute. A value from 0 to 59.
	 * @param second	The second. A value from 0 to 59.
	 * @param timezone	The timezone offset. From -12 to 12.
	 */
	public static function dateWithYearMonthDayHourMinuteSecondTimeZone(
			year:Number, month:Number, day:Number, hour:Number,
			minute:Number, second:Number,
			timezone:NSTimeZone):NSCalendarDate {
		return (new NSCalendarDate()).initWithYearMonthDayHourMinuteSecondTimeZone(
			year, month, day, hour, minute, second, timezone);
	}

	//******************************************************
	//*               Static Constructor
	//******************************************************

	/**
	 * Runs when the application begins.
	 */
	private static function classConstruct():Boolean {
		if (classConstructed) {
			return true;
		}

		g_firstDayInCommonEra = new Date(1, 0, 1, 0, 0, 0, 0);

		return true;
	}

	private static var classConstructed:Boolean = classConstruct();
}
