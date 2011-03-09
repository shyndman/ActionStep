/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.NSApplication;
import org.actionstep.NSColor;
import org.actionstep.NSObject;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.bugtracker.common.Ticket;
import org.bugtracker.view.TicketPropertiesView;
import org.bugtracker.view.TicketsView;

/**
 * @author Scott Hyndman
 */
class org.bugtracker.Application extends NSObject {	
	
	//******************************************************															 
	//*                 Member variables
	//******************************************************
	
	private static var g_ticketsView:TicketsView;	
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new <code>Application</code> instance.
	 */
	public function Application() {
	}
	
	/**
	 * Initializes the application.
	 */
	public function init():Application {
		//
		// Get application
		//
		var app:NSApplication = NSApplication.sharedApplication();
		
		var wnd:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0,0,TicketsView.VIEW_WIDTH,TicketsView.VIEW_HEIGHT));
		wnd.setBackgroundColor(ASColors.lightGrayColor());
			
		//
		// Create tickets view
		//
		g_ticketsView = new TicketsView();
		g_ticketsView.initWithFrame(new NSRect(0,0,TicketsView.VIEW_WIDTH,
			TicketsView.VIEW_HEIGHT));
		wnd.contentView().addSubview(g_ticketsView);
		
		app.run();					
		return this;
	}
	
	/**
	 * Creates a new ticket properties window and populates it with the 
	 * contents of <code>ticket</code>.
	 * 
	 * If <code>newMode</code> is <code>true</code>, the properties window
	 * will create a new ticket. If <code>false</code> it will edit
	 * an existing ticket.
	 */
	public static function createTicketPropertiesWindow(ticket:Ticket,
			newMode:Boolean):Void {
		var wnd:NSWindow = (new NSWindow()).initWithContentRectStyleMask(
			new NSRect(0,0,TicketPropertiesView.VIEW_WIDTH,
			TicketPropertiesView.VIEW_HEIGHT),
			NSWindow.NSTitledWindowMask | NSWindow.NSClosableWindowMask);
		wnd.setBackgroundColor(ASColors.lightGrayColor()
			.adjustColorBrightnessByFactor(1.3));
		wnd.setLevel(NSWindow.NSFloatingWindowLevel);
		
		if (newMode) {
			wnd.setTitle("New Ticket");
		} else {
			wnd.setTitle("Ticket properties - #" + 
				ticket.ticketNumber().toString());
		}
		var cnt:NSView = wnd.contentView();
		
		//
		// Create TicketPropertiesView
		//
		var ticketProps:TicketPropertiesView = new TicketPropertiesView();
		ticketProps.initWithFrameNewMode(new NSRect(0,0,TicketPropertiesView.VIEW_WIDTH,
			TicketPropertiesView.VIEW_HEIGHT), newMode);
		ticketProps.setTicket(ticket);
		cnt.addSubview(ticketProps);
		
		//
		// Display window
		//
		wnd.display();
		wnd.makeKeyWindow();
		wnd.makeMainWindow();
		wnd.center();
	}
	
	/**
	 * Returns the TicketsView used by this application.
	 */
	public static function ticketsView():TicketsView {
		return g_ticketsView;
	}
}