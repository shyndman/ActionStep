/* See LICENSE for copyright and terms of use */

import org.actionstep.NSCalendarDate;
import org.actionstep.NSDateFormatter;
import org.actionstep.NSTimeZone;
import org.actionstep.NSApplication;
import org.actionstep.NSDate;

/**
 * Tests the <code>org.actionstep.NSCalendarDate</code> and 
 * <code>org.actionstep.NSDate</code> classes. 
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestDate 
{	
	public static function test():Void
	{
		NSApplication.sharedApplication().run();
		
		var dtFormatter:NSDateFormatter;
		var momsBDay:NSCalendarDate;
		var dob:NSCalendarDate;
		var tz:NSTimeZone = NSTimeZone.timeZoneForSecondsFromGMT(0);
			
		dob = (new NSCalendarDate()).initWithYearMonthDayHourMinuteSecondTimeZone(
			1965, 12, 7, 17, 25, 45, tz);
		
		
		//
		// Test formatting both ways
		//
		var format:String = "%A, %B %d, %Y, %H:%M:%S This is more text";
		dtFormatter = (new NSDateFormatter()).initWithDateFormatAllowNaturalLanguage
			(format, true);
		dtFormatter.setGeneratesCalendarDates(true);
		var str:String = dtFormatter.stringFromDate(dob);
		trace(str);
		var dt:NSDate = dtFormatter.dateFromString(str);
		trace(dtFormatter.stringFromDate(dt));
	}
	
	private static function traceSince(since:Object):Void
	{
		trace("years " + since.years);
		trace("months " + since.months);
		trace("days " + since.days);
		trace("hours " + since.hours);
		trace("minutes " + since.minutes);
		trace("seconds " + since.seconds);
	}
}