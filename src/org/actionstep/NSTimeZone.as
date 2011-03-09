/* See LICENSE for copyright and terms of use */

import org.actionstep.dates.ASTimeZoneData;
import org.actionstep.NSCopying;
import org.actionstep.NSDictionary;
import org.actionstep.NSObject;
import org.actionstep.NSDate;
import org.actionstep.NSArray;
import org.actionstep.ASStringFormatter;
import org.actionstep.NSCalendarDate;

/**
 * <p><code>NSTimeZone</code> is a class that defines the behavior of time zone 
 * objects. Time zone objects represent geopolitical regions. Consequently, 
 * these objects have names for these regions. Time zone objects also represent 
 * a temporal offset, either plus or minus, from Greenwich Mean Time (GMT) and 
 * an abbreviation (such as PST for Pacific Standard Time).</p>
 * 
 * <p><code>NSTimeZone</code>s are used internally by 
 * {@link org.actionstep.NSCalendarDate} instances.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSTimeZone extends NSObject implements NSCopying {
	
	//******************************************************
	//*                  Class members
	//******************************************************
	
	private static var g_abbreviations:NSDictionary;
	private static var g_timeZones:NSDictionary;
	private static var g_defaultTimeZone:NSTimeZone;
	private static var g_systemTimeZone:NSTimeZone;
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_name:String;
	private var m_data:ASTimeZoneData;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSTimeZone</code> class.
	 */
	public function NSTimeZone() {
	}
	
	/**
	 * <p>Initializes a time zone with <code>aName</code>.</p>
	 * 
	 * <p>If <code>aName</code> is a known name, this method calls 
	 * {@link #initWithNameData} with the appropriate data object.</p>
	 */
	public function initWithName(aName:String):NSTimeZone {
		var tz:NSTimeZone = timeZoneWithName(aName);
		if (tz != null) {
			return initWithNameData(aName, tz.data());
		}
		
		m_name = aName;
		return this;
	}
	
	/**
	 * Initializes a time zone with <code>aName</code> and <code>data</code>.
	 */
	public function initWithNameData(aName:String, data:ASTimeZoneData)
			:NSTimeZone {
		m_name = aName;
		m_data = data;
		
		//
		// Record the name
		//
		if (g_timeZones.objectForKey(m_name) == null) {
			g_timeZones.setObjectForKey(this, m_name);
		}
		
		//
		// Make an association between the abbreviation and the name if
		// possible.
		//
		var abbr:String = this.data()["m_abbreviation"].toString();
		if (abbr != null && abbr.length > 0) {
			g_abbreviations.setObjectForKey(m_name, abbr);
		}
		
		return this;
	}
	
	//******************************************************
	//*    Getting information about a specific time zone
	//******************************************************
	
	/**
	 * <p>Returns the abbreviation for the receiver, such as "EDT" (Eastern 
	 * Daylight Time).</p>
	 * 
	 * <p>Invokes {@link #abbreviationForDate} with the current date and time.</p>
	 */
	public function abbreviation():String {
		return abbreviationForDate(NSDate.date());
	}
	
	/**
	 * Returns the abbreviation for the receiver at the specified date.
	 */
	public function abbreviationForDate(aDate:NSDate):String {
		return data().abbreviationForDate(aDate);
	}
	
	/**
	 * Returns the geopolitical region name that identifies the receiver.
	 */
	public function name():String {
		return m_name;
	}
	
	/**
	 * <p>Returns the current difference in seconds between the receiver and 
	 * Greenwich Mean Time.</p>
	 * 
	 * <p>This method invokes {@link #secondsFromGMTForDate} for the current
	 * date and time.</p>
	 */
	public function secondsFromGMT():Number {
		return secondsFromGMTForDate(NSDate.date());
	}
	
	/**
	 * Returns the difference in seconds between the receiver and Greenwich Mean
	 * Time at <code>aDate</code>.
	 */
	public function secondsFromGMTForDate(aDate:NSDate):Number {
		return data().secondsFromGMTForDate(aDate);
	}
	
	/**
	 * <p>Returns <code>true</code> if the receiver is currently using daylight 
	 * savings time.</p>
	 * 
	 * <p>This method invokes <code>#isDaylightSavingTimeForDate</code> for the
	 * current date and time.</p>
	 */
	public function isDaylightSavingTime():Boolean {
		return isDaylightSavingTimeForDate(NSDate.date());
	}
	
	/**
	 * Returns <code>true</code> if the receiver uses daylight savings time at 
	 * <code>aDate</code>.
	 */
	public function isDaylightSavingTimeForDate(aDate:NSDate):Boolean {
		return data().isDaylightSavingsTimeForDate(aDate);
	}
	
	/**
	 * Returns the data that stores the information used by the receiver.
	 */
	public function data():ASTimeZoneData {
		return m_data;
	}
	
	//******************************************************
	//*                Comparing time zones
	//******************************************************
	
	/**
	 * Overridden to call {@link #isEqualToTimeZone} in the event that
	 * <code>anObject</code> is an instance of <code>NSTimeZone</code>.
	 */
	public function isEqual(anObject:Object):Boolean {
		if (!(anObject instanceof NSTimeZone)) {
			return false;
		}
		
		return isEqualToTimeZone(NSTimeZone(anObject));
	}
	
	/**
	 * Returns <code>true</code> if <code>aTimeZone</code> and the receiver have
	 * the same name and data.
	 */
	public function isEqualToTimeZone(aTimeZone:NSTimeZone):Boolean {
		return m_name == aTimeZone.name()
			&& m_data.isEqual(aTimeZone.data());
	}
	
	//******************************************************
	//*               Describing a time zone
	//******************************************************
	
	/**
	 * Returns the description of the receiver, including the name, 
	 * abbreviation, offset from GMT, and whether or not daylight savings time 
	 * is currently in effect.
	 */
	public function description():String {
		return "NSTimeZone(name=" + name() + ")";
	}
	
	//******************************************************
	//*                    NSCopying
	//******************************************************
	
	/**
	 * Copies the time zone.
	 */
	public function copyWithZone():NSObject {
		return (new NSTimeZone()).initWithNameData(
			name(), ASTimeZoneData(data().copy()));
	}

	//******************************************************
	//*                 Getting time zones
	//******************************************************
	
	/**
	 * <p>Returns the time zone object identified by <code>abbreviation</code> by 
	 * resolving the abbreviation to a name using the abbreviation dictionary 
	 * and then returning the time zone for that name.</p>
	 * 
	 * <p>Returns <code>null</code> if there is no match for 
	 * <code>abbreviation</code>.</p>
	 * 
	 * @see #abbreviationDictionary
	 */
	public static function timeZoneWithAbbreviation(abbreviation:String):NSTimeZone {
		var name:String = g_abbreviations.objectForKey(abbreviation).toString();
		if (name == null) {
			return null;
		}
		
		return timeZoneWithName(name);
	}
	
	/**
	 * <p>Returns the time zone object identified by the name 
	 * <code>aTimeZoneName</code>.</p>
	 * 
	 * <p>It searches the time zone information directory for matching names. 
	 * Returns <code>null</code> if there is no match for the name.</p>
	 */
	public static function timeZoneWithName(aTimeZoneName:String):NSTimeZone {
		return NSTimeZone(g_timeZones.objectForKey(aTimeZoneName));
	}
	
	/**
	 * <p>Returns the time zone with the name <code>aTimeZoneName</code> whose data
	 * has been initialized using the contents of <code>data</code>.</p>
	 * 
	 * <p>You should not call this method directly—use {@link #timeZoneWithName} 
	 * to get the time zone object for a given name.</p>
	 */
	public static function timeZoneWithNameData(aTimeZoneName:String,
			data:ASTimeZoneData):NSTimeZone {
		var tz:NSTimeZone = timeZoneWithName(aTimeZoneName);
		if (tz == null) {
			return null;
		}
		
		return tz.data().isEqual(data) ? tz : null;
	}
	
	/**
	 * Returns a time zone object offset from Greenwich Mean Time by 
	 * <code>seconds</code>.
	 */
	public static function timeZoneForSecondsFromGMT(seconds:Number):NSTimeZone {
		var name:String = timeStringForTimeZone(seconds);
		var data:ASTimeZoneData = (new ASTimeZoneData())
			.initWithAbbreviationSecondsFromGMT("", seconds);
		
		return (new NSTimeZone()).initWithNameData(name, data);
	}
	
	/**
	 * Gets the time string for <code>seconds</code>.
	 */
	private static function timeStringForTimeZone(seconds:Number):String {
		var minutes:Number = Math.floor(seconds / 60);
		var hours:Number = Math.floor(minutes % 60);
		minutes %= 60;
		
		var isNegative:Boolean = false;
		if (hours < 0) {
			isNegative = true;
			hours = Math.abs(hours);
			minutes = Math.abs(minutes);
		}
		
		return "GMT " + (isNegative ? "-" : "+") + " " +
			ASStringFormatter.formatString(
			"%02i:%02i", 
			NSArray.arrayWithObjects(hours, minutes));
	}
	
	//******************************************************
	//*             Getting the default time zone
	//******************************************************
	
	/**
	 * <p>Returns the default time zone set for your application.</p>
	 * 
	 * <p>If no default time zone has been set, this method invokes 
	 * {@link #systemTimeZone} and returns the system time zone.</p>
	 * 
	 * @see #setDefaultTimeZone
	 * @see #systemTimeZone
	 */
	public static function defaultTimeZone():NSTimeZone {
		if (g_defaultTimeZone == undefined) {
			return systemTimeZone();
		}
		
		return g_defaultTimeZone;
	}
	
	/**
	 * Sets the default time zone for your application to 
	 * <code>aTimeZone</code>.
	 * 
	 * @see #defaultTimeZone
	 */
	public static function setDefaultTimeZone(aTimeZone:NSTimeZone):Void {
		g_defaultTimeZone = aTimeZone;
	}
	
	/**
	 * Returns the time zone currently used by the system.
	 */
	public static function systemTimeZone():NSTimeZone {
		if (g_systemTimeZone == undefined) {
			var dt:Date = new Date();
			g_systemTimeZone = timeZoneForSecondsFromGMT(
				dt.getTimezoneOffset() * 60);
		}
		
		return g_systemTimeZone;
	}
	
	//******************************************************
	//*             Getting time zone information
	//******************************************************
	
	/**
	 * Returns a dictionary holding the mappings of time zone abbreviations to 
	 * time zone names.
	 */
	public static function abbreviationDictionary():NSDictionary {
		return g_abbreviations;
	}
	
	/**
	 * Returns an array of strings listing the names of all the time zones known
	 * to the system.
	 */
	public static function knownTimeZoneNames():NSArray {
		return g_timeZones.allKeys();
	}
	
	//******************************************************
	//*                 Class constructor
	//******************************************************
	
	private static var g_initialized:Boolean;
	
	/**
	 * Creates some default time zones.
	 */
	public static function initialize():Void {
		if (g_initialized) {
			return;
		}
		
		g_timeZones = NSDictionary.dictionary();
		g_abbreviations = NSDictionary.dictionary();
		
		var data:ASTimeZoneData;
		
		//
		// Pacific Standard Time (PST) / Pacific Daylight Time (PDT)
		//
		data = (new ASTimeZoneData()).initDSTDataWithAbbreviationSecondsStartDateEndDate(
			"PST", "PDT", 
			-8 * 360, -7 * 360,
			buildBoundaryDate(3, 10),
			buildBoundaryDate(11, 4));
		(new NSTimeZone()).initWithNameData("Pacific Standard Time", data);
		(new NSTimeZone()).initWithNameData("Pacific Daylight Time", data);		
		
		//
		// Mountain Standard Time (MST)
		//
		data = (new ASTimeZoneData()).initDSTDataWithAbbreviationSecondsStartDateEndDate(
			"MST", "MST", 
			-7 * 360, -6 * 360,
			buildBoundaryDate(3, 10),
			buildBoundaryDate(11, 4));
		(new NSTimeZone()).initWithNameData("Mountain Standard Time", data);
			
		//
		// Central Standard Time (CST) / Central Daylight Time (CDT)
		//
		data = (new ASTimeZoneData()).initDSTDataWithAbbreviationSecondsStartDateEndDate(
			"CST", "CDT", 
			-6 * 360, -5 * 360,
			buildBoundaryDate(3, 10),
			buildBoundaryDate(11, 4));
		(new NSTimeZone()).initWithNameData("Central Standard Time", data);
		(new NSTimeZone()).initWithNameData("Central Daylight Time", data);
		
		//
		// Eastern Standard Time (EST) / Eastern Daylight Time (EDT)
		//
		data = (new ASTimeZoneData()).initDSTDataWithAbbreviationSecondsStartDateEndDate(
			"EST", "EDT", 
			-5 * 360, -4 * 360,
			buildBoundaryDate(3, 10),
			buildBoundaryDate(11, 4));
		(new NSTimeZone()).initWithNameData("Eastern Standard Time", data);
		(new NSTimeZone()).initWithNameData("Eastern Daylight Time", data);
				
		g_initialized = true;
	}
	
	private static function buildBoundaryDate(month:Number, day:Number):NSDate {
		return NSCalendarDate.dateWithYearMonthDayHourMinuteSecondTimeZone(
				1970,
				month,
				0,
				0,
				0,
				0,
				systemTimeZone());
	}
}