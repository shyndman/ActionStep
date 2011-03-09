/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSComparisonResult;
import org.actionstep.NSCopying;
import org.actionstep.NSDateFormatter;
import org.actionstep.NSDictionary;
import org.actionstep.NSObject;
import org.actionstep.NSUserDefaults;
import org.actionstep.NSTimeZone;
import org.actionstep.NSCalendarDate;

/**
 * <p>Class used for representing dates.</p>
 * 
 * <p>For an example of this class' usage, please see
 * {@link org.actionstep.test.ASTestDate}.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSDate extends NSObject
	implements NSCopying
{	
	/**
	 * Seconds between Jan 1st, 1970 to Jan 1st, 2001. 
	 */
	public static var NSTimeIntervalSince1970:Number;
	
	/** String format used by initWithString() */
	private static var DEF_STRING_FORMAT:String;
	
	/** January 1st, 2001, 00:00:00:0000 */
	private static var g_refDate:NSDate;
	
	/** A date formatter that uses to format all dates. */
	private static var g_dtFormatter:NSDateFormatter;
	
	/** The internal date. */
	private var m_dt:Date;
		
		
	//******************************************************															 
	//*                   Construction
	//******************************************************
		
	/**
	 * Constructs a new instance of the NSDate class.
	 */
	public function NSDate() {
		if (g_dtFormatter == undefined) {
			//
			// Do not construct and init in the same line. It will cause an
			// infinite loop.
			//
			g_dtFormatter = new NSDateFormatter();
			g_dtFormatter.initWithDateFormatAllowNaturalLanguage(
				DEF_STRING_FORMAT, false);
			g_dtFormatter.generatesCalendarDates(true); // for subclasses
			
			g_refDate = NSCalendarDate.dateWithYearMonthDayHourMinuteSecondTimeZone(
				2001, 1, 1, 0, 0, 0, null);
		}
	}
	
	
	/**
	 * Initializes an NSDate to the current date and time.
	 */
	public function init():NSDate
	{
		m_dt = new Date();
		return this;
	}
	
	
	/**
	 * Initializes an NSDate to the date and time specified by a string
	 * conforming to the international string representation format 
	 * YYYY-MM-DD HH:MM:SS ±HHMM. All fields must be specified.
	 */
	public function initWithString(description:String):NSDate
	{
		var genDt:NSDate;
		var old:String; 
		
		//
		// Since ActionScript is single-threaded, this is okay to do.
		//
		old = g_dtFormatter.dateFormat();
		g_dtFormatter.setDateFormat(DEF_STRING_FORMAT);
		genDt = g_dtFormatter.dateFromString(description);
		g_dtFormatter.setDateFormat(old); // reset
		
		this.m_dt.setTime(genDt.internalDate().getTime());
		//! deal with timezone
		
		return this;
	}
	
	
	/**
	 * Initializes an NSDate to the current date and time, offset by seconds
	 * seconds.
	 */
	public function initWithTimeIntervalSinceNow(seconds:Number):NSDate
	{
		m_dt = new Date();
		m_dt.setTime(m_dt.getTime() + seconds * 1000);
		
		return this;
	}
	
	
	/**
	 * Initializes an NSDate to the date and time of refDate, offset by 
	 * seconds seconds.
	 */
	public function initWithTimeIntervalSinceDate(seconds:Number, 
		refDate:NSDate):NSDate
	{
		m_dt = new Date();
		m_dt.setTime(refDate.m_dt.getTime() + seconds * 1000);
		
		return this;
	}
	
	
	/**
	 * Initializes an NSDate to the date and time of the absolute reference
	 * date, offset by seconds seconds.
	 */
	public function initWithTimeIntervalSinceReferenceDate(seconds:Number):NSDate
	{
		return initWithTimeIntervalSinceDate(seconds, g_refDate);
	}
	
	
	//******************************************************															 
	//*                    Properties
	//******************************************************
	
	/**
	 * <p>Uses the international date formatting style.</p>
	 *
	 * <p>Calls {@link #descriptionWithCalendarFormatTimeZoneLocale()}.</p>
	 */
	public function description():String 
	{
		return descriptionWithCalendarFormatTimeZoneLocale(NSDate.DEF_STRING_FORMAT,
			null, null);
	}
	
	
	/**
	 * Returns a string representation of this NSDate using the date format
	 * string format, the time zone timeZone and the locale locale. If null
	 * is provided for any of the arguments, the default is assumed.
	 */
	public function descriptionWithCalendarFormatTimeZoneLocale(
			format:String, timeZone:NSTimeZone, locale:NSDictionary):String {		
		if (format == null) {
			format = NSDate.DEF_STRING_FORMAT;
		}
		
		if (timeZone == null) {
			timeZone = NSTimeZone.defaultTimeZone();
		}
		
		var dtf:NSDateFormatter = (new NSDateFormatter()
			).initWithDateFormatAllowNaturalLanguage(format, true);
		dtf.setTimeZone(timeZone);
		// dtf.setLocale(locale);
		return dtf.stringFromDate(this); //! locale
	}
	
	
	/**
	 * <p>Uses the international date formatting style.</p>
	 *
	 * <p>Calls {@link #descriptionWithCalendarFormatTimeZoneLocale()}</p>
	 */
	public function descriptionWithLocale(locale:NSDictionary):String
	{
		return descriptionWithCalendarFormatTimeZoneLocale(NSDate.DEF_STRING_FORMAT,
			null, locale);
	}
	
	
	/**
	 * Returns the internal date representation. Should only be used when
	 * absolutely necessary.
	 */
	public function internalDate():Date
	{
		return m_dt;
	}
	
	//******************************************************															 
	//*                   Time Intervals
	//******************************************************
	
	/**
	 * <p>Returns the interval (seconds) between this date and Jan 1st, 1970.
	 * If this date is earlier than now a negative value is returned.</p>
	 *
	 * <p>Cocoa specs have this returning an NSTimeInterval. Number is fine for
	 * our purposes.</p>
	 */	
	public function timeIntervalSince1970():Number
	{
		return (this.m_dt.getTime() / 1000);
	}
	
	
	/**
	 * <p>Returns the interval (seconds) between this date and 
	 * <code>anotherDate</code>. If this date is earlier than anotherDate a 
	 * negative value is returned.</p>
	 *
	 * <p>Cocoa specs have this returning an NSTimeInterval. Number is fine for
	 * our purposes.</p>
	 */
	public function timeIntervalSinceDate(anotherDate:NSDate):Number
	{
		return timeIntervalSinceIntrinsicDate(anotherDate.m_dt);
	}


	/**
	 * <p>Returns the interval (seconds) between this date and the current date 
	 * and time. If this date is earlier than now a negative value is returned.</p>
	 *
	 * <p>Cocoa specs have this returning an NSTimeInterval. Number is fine for
	 * our purposes.</p>
	 */	
	public function timeIntervalSinceNow():Number
	{
		return timeIntervalSinceIntrinsicDate(new Date());
	}
	
	
	/**
	 * <p>Returns the interval (seconds) between this date and the reference date
	 * (Jan 1st, 2001). If this date is earlier than now a negative value is 
	 * returned.</p>
	 *
	 * <p>Cocoa specs have this returning an NSTimeInterval. Number is fine for
	 * our purposes.</p>
	 */	
	public function timeIntervalSinceReferenceDate():Number
	{
		return timeIntervalSinceIntrinsicDate(g_refDate.internalDate());
	}
	
	//******************************************************															 
	//*                 Public Methods
	//******************************************************
	
	/**
	 * Returns a new NSDate offset by seconds seconds from this date.
	 */
	public function addTimeInterval(seconds:Number):NSDate
	{
		return (new NSDate()).initWithTimeIntervalSinceDate(seconds, this);
	}
	
	
	/**
	 * <p>Uses timeIntervalSinceDate to compare this date to 
	 * <code>anotherDate</code> and returns an {@link NSComparisonResult}.</p>
	 *
	 * <p>
	 * <ul>
	 * <li>
	 * If the two dates are the same, {@link NSComparisonResult#NSOrderedSame} 
	 * is returned.
	 * </li>
	 * <li>
	 * If this date is later than <code>anotherDate</code>, 
	 * {@link NSComparisonResult#NSOrderedDescending} is returned.
	 * </li>
	 * <li>
	 * If this date is earlier, {@link NSComparisonResult#NSOrderedAscending} is
	 * returned.
	 * </li>
	 * </ul>
	 * </p>
	 */
	public function compare(anotherDate:NSDate):NSComparisonResult
	{
		var delta:Number = timeIntervalSinceDate(anotherDate);
		
		if (delta == 0)
		{
			return NSComparisonResult.NSOrderedSame;
		}
		else if (delta > 0)
		{
			return NSComparisonResult.NSOrderedDescending;
		}
		else // delta < 0
		{
			return NSComparisonResult.NSOrderedAscending;
		}
	}
	
	
	/**
	 * Returns whatever is earlier, this date or <code>anotherDate</code>.
	 */
	public function earlierDate(anotherDate:NSDate):NSDate
	{
		return timeIntervalSinceDate(anotherDate) < 0 ? this : anotherDate;
	}
	
	
	/**
	 * Returns whatever is later, this date or <code>anotherDate</code>.
	 */
	public function laterDate(anotherDate:NSDate):NSDate
	{
		return timeIntervalSinceDate(anotherDate) < 0 ? anotherDate : this;
	}
	
	
	/**
	 * @see org.actionstep.NSObject#isEqual
	 */
	public function isEqual(anObject:NSObject):Boolean
	{
		if (!(anObject instanceof NSDate))
			return false;
			
		return isEqualToDate(NSDate(anObject));
	}
	
	
	/**
	 * Returns <code>true</code> if this date is equal to 
	 * <code>anotherDate</code>, and <code>false</code> otherwise.
	 */
	public function isEqualToDate(anotherDate:NSDate):Boolean
	{
		//! Timezones
		return m_dt.getTime() == anotherDate.m_dt.getTime();
	}
	
	//******************************************************															 
	//*              NSCopying Implementation
	//******************************************************
	
	/**
	 * @see org.actionstep.NSCopying#copyWithZone
	 */
	public function copyWithZone():NSObject
	{
		return (new NSDate()).initWithTimeIntervalSinceDate(0, this);
	}
	
	//******************************************************															 
	//*                 Protected Methods
	//******************************************************
	//******************************************************															 
	//*                  Private Methods
	//******************************************************
	
	/**
	 * Returns the time in seconds between this date and the intrinsic Date
	 * argument.
	 */
	private function timeIntervalSinceIntrinsicDate(dt:Date):Number
	{
		return (this.m_dt.getTime() - dt.getTime()) / 1000;
	}
	
	
	//******************************************************															 
	//*             Public Static Properties
	//******************************************************
	
	/**
	 * Returns a date in the distant future (centuries distant).
	 */
	public function distantFuture():NSDate
	{
		return NSDate.dateWithDate(new Date(9999, 0, 1, 0, 0, 0, 0));
	}

	
	/**
	 * Returns a date in the distant past.
	 */
	public function distantPast():NSDate
	{
		return NSDate.dateWithDate(new Date(1, 0, 1, 0, 0, 0, 0));
	}	
	
	//******************************************************															 
	//*              Public Static Methods
	//******************************************************
	
	/**
	 * Constructs and returns a new date with the current date and time.
	 */
	public static function date():NSDate
	{
		return NSDate.dateWithDate(new Date());
	}
	
	
	/**
	 * Constructs and returns a new date set to the date and time of date.
	 */
	public static function dateWithDate(date:Date):NSDate
	{
		var seconds:Number = date.getTime() - g_refDate.m_dt.getTime();
		seconds /= 1000;
		return (new NSDate()).initWithTimeIntervalSinceReferenceDate(seconds);
	}
	
	
	/**
	 * Constructs a new date based on the information contained in string.
	 * The date formatter uses date and time preferences stored in the user
	 * defaults table to parse the string.
	 */
	public static function dateWithNaturalLanguageString(string:String):NSDate
	{
		return dateWithNaturalLanguageStringLocale(string, 
			NSUserDefaults.standardUserDefaults().dictionaryRepresentation());
	}
	
	
	public static function dateWithNaturalLanguageStringLocale(string:String, 
		locale:NSDictionary):NSDate
	{
		return null;
	}
	
	//******************************************************															 
	//*               Static Constructor
	//******************************************************
	
	/**
	 * Runs when the application begins.
	 */
	private static function classConstruct():Boolean
	{
		if (classConstructed)
			return true;
		
		// 
		// For formatting (YYYY-MM-DD HH:MM:SS ±HHMM)
		//
		DEF_STRING_FORMAT = "%Y-%m-%d %H:%M:%S %z";
		
		//
		// Initialize time zones
		//
		//NSTimeZone.initialize();
		
		return true;
	}
	
	private static var classConstructed:Boolean = classConstruct();
}
