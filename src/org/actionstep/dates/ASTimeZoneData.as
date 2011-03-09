/* See LICENSE for copyright and terms of use */

import org.actionstep.NSCopying;
import org.actionstep.NSObject;
import org.actionstep.NSDate;
import org.actionstep.NSCalendarDate;
import org.actionstep.constants.NSComparisonResult;

/**
 * Used to initialize instances of {@link org.actionstep.NSTimeZone}.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.dates.ASTimeZoneData extends NSObject implements NSCopying {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_abbreviation:String;
	private var m_abbreviation_dst:String;
	private var m_secondsFromGMT:Number;
	private var m_secondsFromGMT_dst:Number;
	
	//
	// If these guys are null, we are never in daylight savings time.
	//
	private var m_dstStart:NSCalendarDate;
	private var m_dstEnd:NSCalendarDate;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASTimeZoneData</code> class.
	 */
	public function ASTimeZoneData() {
	}
	
	/**
	 * <p>Initializes the time zone data with the abbreviated name 
	 * <code>abbreviation</code>, seconds from GMT <code>seconds</code>. This
	 * time zone will never be in daylight savings time.</p>
	 * 
	 * For time zone data including DST data, use 
	 * {@link #initDSTDataWithAbbreviationSecondsStartDateEndDate}.
	 */
	public function initWithAbbreviationSecondsFromGMT(
			abbreviation:String,
			seconds:Number):ASTimeZoneData {
		m_abbreviation = abbreviation;
		m_secondsFromGMT = seconds;
		m_dstStart = null;
		m_dstEnd = null;
		
		return this;		
	}
	
	/**
	 * Initializes the time zone data with an non-DST abbreviation, a DST
	 * abbreviation, non-DST seconds from GMT, DST seconds from GMT and
	 * two times that define the beginning and end of DST in a year.
	 */
	public function initDSTDataWithAbbreviationSecondsStartDateEndDate(
			abbreviation:String,
			abbreviationDST:String,
			seconds:Number,
			secondsDST:Number,
			startDST:NSDate,
			endDST:NSDate):ASTimeZoneData {
		m_abbreviation = abbreviation;
		m_abbreviation_dst = abbreviationDST;
		m_secondsFromGMT = seconds;
		m_secondsFromGMT_dst = secondsDST;
		
		m_dstStart = NSCalendarDate((new NSCalendarDate())
			.initWithTimeIntervalSinceDate(0, startDST));
		m_dstEnd = NSCalendarDate((new NSCalendarDate())
			.initWithTimeIntervalSinceDate(0, endDST));
		
		return this;		
	}
	
	//******************************************************
	//*       Getting information about the time zone
	//******************************************************
	
	/**
	 * Returns the abbreviated name of this time zone.
	 */
	public function abbreviationForDate(aDate:NSDate):String {		
		if (!isDaylightSavingsTimeForDate(aDate)) {
			return m_abbreviation;
		}
		
		return m_abbreviation_dst;		
	}
	
	/**
	 * Returns the number of seconds this time zone is from GMT.
	 */
	public function secondsFromGMTForDate(aDate:NSDate):Number {
		if (!isDaylightSavingsTimeForDate(aDate)) {
			return m_secondsFromGMT;
		}
		
		return m_secondsFromGMT_dst;
	}
	
	/**
	 * Returns <code>true</code> if this time zone is currently in daylight
	 * savings time.
	 */
	public function isDaylightSavingsTimeForDate(aDate:NSDate):Boolean {
		if (m_dstStart == null || m_dstEnd == null) {
			return false;
		}
		
		var dt:NSCalendarDate = NSCalendarDate((new NSCalendarDate())
			.initWithTimeIntervalSinceDate(0, aDate));
		dt.internalDate().setFullYear(m_dstStart.yearOfCommonEra());
		
		return dt.compare(m_dstStart) == NSComparisonResult.NSOrderedAscending
			&& dt.compare(m_dstEnd) == NSComparisonResult.NSOrderedDescending;
	}
	
	//******************************************************
	//*                Testing for equality
	//******************************************************
	
	/**
	 * Returns <code>true</code> if <code>object</code> is an instance of
	 * <code>ASTimeZoneData</code> and its contents are the same.
	 */
	public function isEqual(object:Object):Boolean {
		if (!(object instanceof ASTimeZoneData)) {
			return false;
		}
		
		var tzd:ASTimeZoneData = ASTimeZoneData(object);
		
		return tzd.m_abbreviation == m_abbreviation
			&& tzd.m_abbreviation_dst == m_abbreviation_dst
			&& tzd.m_secondsFromGMT == m_secondsFromGMT
			&& tzd.m_secondsFromGMT_dst == m_secondsFromGMT_dst
			&& ((tzd.m_dstStart == null && m_dstStart == null)
				|| (tzd.m_dstStart.isEqualToDate(m_dstStart)))
			&& ((tzd.m_dstEnd == null && m_dstEnd == null)
				|| (tzd.m_dstEnd.isEqualToDate(m_dstEnd)));
	}

	//******************************************************
	//*             Copying the time zone data
	//******************************************************
	
	/**
	 * Returns a copy of this time zone data.
	 */
	public function copyWithZone():NSObject {
		return (new ASTimeZoneData())
			.initDSTDataWithAbbreviationSecondsStartDateEndDate(
			m_abbreviation, m_abbreviation_dst,
			m_secondsFromGMT, m_secondsFromGMT_dst,
			m_dstStart, m_dstEnd);
	}
}