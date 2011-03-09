/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSObject;
import org.actionstep.NSCalendarDate;

/**
 * A Ticket represents a single issue in the bug tracker system.
 * 
 * @author Scott Hyndman
 */
class org.bugtracker.common.Ticket extends NSObject {
	
	//******************************************************															 
	//*                    Constants
	//******************************************************
	
	public static var STATUS_MAX:Number = 4;
	public static var STATUS_CLOSED:Number = 3;
	public static var STATUS_ASSIGNED:Number = 2;
	public static var STATUS_NEW:Number = 1;
	public static var STATUS_MIN:Number = 0;
	
	public static var STATUS_STRINGS:Array = [
		"New", 
		"Assigned", 
		"Closed"
		];
	
	public static var TYPE_MAX:Number = 4;
	public static var TYPE_TASK:Number = 3;
	public static var TYPE_ENHANCEMENT:Number = 2;
	public static var TYPE_DEFECT:Number = 1;
	public static var TYPE_MIN:Number = 0;
	
	public static var TYPE_STRINGS:Array = [
		"Defect", 
		"Enhancement", 
		"Task"
		];
	
	public static var PRIOR_MAX:Number = 6;
	public static var PRIOR_HIGHEST:Number = 5;
	public static var PRIOR_HIGH:Number = 4;
	public static var PRIOR_NORMAL:Number = 3;
	public static var PRIOR_LOW:Number = 2;
	public static var PRIOR_LOWEST:Number = 1;
	public static var PRIOR_MIN:Number = 0;
	
	public static var PRIOR_STRINGS:Array = [
		"Lowest",
		"Low",
		"Normal",
		"High",
		"Highest"
		];
	
	public static var SEV_MAX:Number = 7;
	public static var SEV_BLOCKER:Number = 6;
	public static var SEV_CRITICAL:Number = 5;
	public static var SEV_MAJOR:Number = 4;
	public static var SEV_NORMAL:Number = 3;
	public static var SEV_MINOR:Number = 2;
	public static var SEV_TRIVIAL:Number = 1;
	public static var SEV_MIN:Number = 0;
	
	public static var SEV_STRINGS:Array = [
		"Trivial",
		"Minor",
		"Normal",
		"Major",
		"Critical",
		"Blocker"
		];
	
	//******************************************************															 
	//*                  Class members
	//******************************************************
	
	private static var g_counter:Number = 1;
	
	//******************************************************															 
	//*                 Member variables
	//******************************************************
	
	private var m_ticketNo:Number;
	private var m_status:Number;
	private var m_type:Number;
	private var m_priority:Number;
	private var m_severity:Number;
	private var m_componentId:Number;
	private var m_reportedBy:String;
	private var m_assignedTo:String;
	private var m_summary:String;
	private var m_comment:String;
	private var m_createTs:NSCalendarDate;
	private var m_modifiedTs:NSCalendarDate;
	private var m_keywords:NSArray;
	
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	public function Ticket() {
		m_ticketNo = g_counter++;
		m_status = STATUS_NEW;
		m_keywords = new NSArray();
		m_createTs = (new NSCalendarDate()).initWithDate(new Date());
		m_modifiedTs = null;
		m_type = TYPE_DEFECT;
		m_priority = PRIOR_NORMAL;
		m_severity = SEV_NORMAL;
		m_reportedBy = "";
		m_assignedTo = "";
		m_summary = "";
		m_comment = "";
	}
	
	//******************************************************															 
	//*                  Properties
	//******************************************************
	
	public function ticketNumber():Number {
		return m_ticketNo;
	}
		
	public function status():Number {
		return m_status;
	}
	
	public function setStatus(status:Number) {
		m_status = status;
	}
	
	public function statusAsString():String {
		return STATUS_STRINGS[m_status - 1];
	}
	
	public function type():Number {
		return m_type;
	}
	
	public function setType(type:Number):Void {
		m_type = type;
	}
	
	public function typeAsString():String {
		return TYPE_STRINGS[m_type - 1];
	}
	
	public function priority():Number {
		return m_priority;
	}
	
	public function setPriority(priority:Number):Void {
		m_priority = priority;
	}
	
	public function priorityAsString():String {
		return PRIOR_STRINGS[m_priority - 1];
	}
	
	public function severity():Number {
		return m_severity;
	}
	
	public function setSeverity(severity:Number):Void {
		m_severity = severity;
	}
	
	public function severityAsString():String {
		return SEV_STRINGS[m_severity - 1];
	}
	
	//******************************************************															 
	//*                Ticket description
	//******************************************************
	
	public function summary():String {
		return m_summary;
	}
	
	public function setSummary(summary:String):Void {
		m_summary = summary;
	}
	
	public function comment():String {
		return m_comment;
	}
	
	public function setComment(comment:String):Void {
		m_comment = comment;
	}
	
	//******************************************************															 
	//*                    Keywords
	//******************************************************
	
	public function keywords():NSArray {
		return NSArray(m_keywords.copyWithZone());
	}
	
	public function addKeyword(keyword:String):Void {
		if (!m_keywords.containsObject(keyword)) {
			m_keywords.addObject(keyword);
		}
	}
	
	public function removeKeyword(keyword:String):Void {
		m_keywords.removeObject(keyword);
	}
	
	public function clearKeywords():Void {
		m_keywords.removeAllObjects();
	}
	
	//******************************************************															 
	//*        People associated with this ticket
	//******************************************************
	
	public function reportedBy():String {
		return m_reportedBy;
	}
	
	public function setReportedBy(email:String):Void {
		m_reportedBy = email;
	}
	
	public function assignedTo():String {
		return m_assignedTo;
	}
	
	public function setAssignedTo(email:String):Void {
		m_assignedTo = email;
	}
	
	//******************************************************															 
	//*                   Timestamps
	//******************************************************
	
	/**
	 * Returns the timestamp of the ticket's creation.
	 */
	public function creationTimestamp():NSCalendarDate {
		return m_createTs;
	}
	
	/**
	 * Returns the timestamp of the last time this ticket was modified or 
	 * <code>null</code> if the ticket has never been modified.
	 */
	public function modifiedTimestamp():NSCalendarDate {
		return m_modifiedTs;
	}
	
	/**
	 * Returns <code>true</code> if the ticket has been modified since its
	 * creation, or false otherwise.
	 */
	public function isModified():Boolean {
		return m_modifiedTs != null;
	}
	
	/**
	 * Will set the ticket's modified timestamp to now.
	 */
	public function markAsModified():Void {
		m_modifiedTs = (new NSCalendarDate()).initWithDate(new Date());
	}
	
	//******************************************************															 
	//*               Comparing tickets
	//******************************************************
	
	public function isEqual(other:Ticket):Boolean {
		return m_ticketNo == other.ticketNumber();
	}
	
	//******************************************************															 
	//*               Creating a ticket
	//******************************************************
	
	/**
	 * Creates a new ticket.
	 */
	public static function createNewTicket(
			status:Number, type:Number, priority:Number, severity:Number, 
			summary:String,	comment:String, reportedBy:String, 
			assignedTo:String, keywords:NSArray):Ticket {
		var ret:Ticket = new Ticket();
		ret.setStatus(status);
		ret.setType(type);
		ret.setPriority(priority);
		ret.setSeverity(severity);
		ret.setSummary(summary);
		ret.setComment(comment);
		ret.setReportedBy(reportedBy);
		ret.setAssignedTo(assignedTo);
		
		if (null != keywords) {
			var arr:Array = keywords.internalList();
			var len:Number = arr.length;
			
			for (var i:Number = 0; i < len; i++) {
				ret.addKeyword(arr[i].toString());
			}
		}
		
		return ret;		
	}
	
	/**
	 * Creates a ticket from an existing record.
	 */
	public static function createExistingTicket(
			ticketNo:Number, createTs:NSCalendarDate, modTs:NSCalendarDate,
			status:Number, type:Number, priority:Number, severity:Number, 
			summary:String,	comment:String, reportedBy:String, 
			assignedTo:String, keywords:NSArray):Ticket {
		
		var ret:Ticket = createNewTicket(status, type, priority, severity,
			summary, comment, reportedBy, assignedTo, keywords);
		ret.m_ticketNo = ticketNo;
		g_counter--;
		
		ret.m_createTs = createTs;
		ret.m_modifiedTs = modTs;
		
		return ret;
	}
}