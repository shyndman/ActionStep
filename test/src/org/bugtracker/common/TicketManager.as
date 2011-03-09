/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSObject;
import org.actionstep.NSPredicate;
import org.actionstep.NSRange;
import org.bugtracker.common.Ticket;

/**
 * @author Scott Hyndman
 */
class org.bugtracker.common.TicketManager extends NSObject {
	
	//******************************************************															 
	//*                   Class members
	//******************************************************
	
	private static var g_instance:TicketManager;
	
	//******************************************************															 
	//*                  Member variables
	//******************************************************
	
	private var m_tickets:NSArray;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	private function TicketManager() {
		m_tickets = (new NSArray()).init();
	}
	
	private function init():TicketManager {
		//
		// Generate a bunch of random tickets
		//
		var reporters:Array = [
			"scott@affsys.com",
			"rkilmer@infoether.com",
			"rctay89@gmail.com",
			"foo@bar.com",
			"ilikedogs@gmail.com",
			"newb001@aol.com",
			"testymctest@test.com",
			"developer@code.com"
			];
		var assignees:Array = [
			"scott@affsys.com",
			"rkilmer@infoether.com",
			"rctay89@gmail.com",
			"foo@bar.com",
			"ilikedogs@gmail.com",
			"newb001@aol.com",
			"testymctest@test.com",
			"developer@code.com"
			];
			
		var summaryRange:NSRange = new NSRange(6, 9);
		var comment:String = "This is a sample comment. This is a sample " +
			"comment. This is a sample comment. This is a sample comment. " +
			"This is a sample comment. This is a sample comment. This is a " +
			"sample comment. This is a sample comment.";
		
		for (var i:Number = 0; i < 60; i++) {
			var summary:String = generateRandomString(summaryRange);
			var a:String = assignees[random(assignees.length)];
			var r:String = reporters[random(reporters.length)];
			var t:Number = random(Ticket.TYPE_MAX - 1) + 1;
			var st:Number = random(Ticket.STATUS_MAX - 1) + 1;
			var s:Number = random(Ticket.SEV_MAX - 1) + 1;
			var p:Number = random(Ticket.PRIOR_MAX - 1) + 1;
			
			var ticket:Ticket = Ticket.createNewTicket(
				st, t, p, s, summary, comment, r, a, null);
			m_tickets.addObject(ticket);
		}
		
		return this;
	}
	
	private function generateRandomString(rng:NSRange):String {
		var len:Number = random(rng.length) + rng.location;
		var obj:String = "";
		
		for (var i:Number = 0; i < len; i++) {
			var c:String = String.fromCharCode(random(26) + 65);
			obj += random(2) == 1 ? c : c.toLowerCase();
		}
		
		return obj;
	}
	
	//******************************************************															 
	//*                  Getting tickets
	//******************************************************
	
	/**
	 * Returns all tickets handled by this manager.
	 */
	public function tickets():NSArray {
		return (new NSArray()).initWithArrayCopyItems(m_tickets, false);
	}
	
	/**
	 * Returns a list of tickets that have passed through the filter
	 * <code>filter</code>.
	 */
	public function ticketsWithPredicate(pred:NSPredicate):NSArray {
		if (pred == null) {
			return tickets();
		}
			
		return m_tickets.filteredArrayUsingPredicate(pred);
	}
		
	/**
	 * Returns the ticket with a ticket number of <code>number</code>, or
	 * <code>null</code> if no ticket was found.
	 */
	public function ticketWithTicketNumber(number:Number):Ticket {
		var idx:Number = indexOfTicketWithTicketNumber(number);
		
		if (idx == NSNotFound) {
			return null;
		}
		
		return Ticket(m_tickets.objectAtIndex(idx));
	}
	
	/**
	 * Deletes the ticket with the ticket number <code>number</code>.
	 */
	public function deleteTicketWithTicketNumber(number:Number):Void {
		var idx:Number = indexOfTicketWithTicketNumber(number);
		
		if (idx == NSNotFound) {
			return;
		}
		
		m_tickets.removeObjectAtIndex(idx);
	}
	
	/**
	 * Adds <code>ticket</code> to the collection of tickets.
	 */
	public function addTicket(ticket:Ticket):Void {
		m_tickets.addObject(ticket);
	}
	
	/**
	 * Returns the index of the ticket with the ticket number 
	 * <code>number</code>.
	 */
	private function indexOfTicketWithTicketNumber(number:Number):Number {
		var arr:Array = m_tickets.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			var t:Ticket = Ticket(arr[i]);
			if (t.ticketNumber() == number) {
				return i;
			}
		}
		
		return NSNotFound;
	}
	
	//******************************************************															 
	//*                Getting the instance
	//******************************************************
	
	/**
	 * Returns the ticket manager instance.
	 */
	public static function instance():TicketManager {
		if (null == g_instance) {
			g_instance = (new TicketManager()).init();
		}
		
		return g_instance;
	}
}