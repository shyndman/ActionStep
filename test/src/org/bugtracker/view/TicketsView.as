/* See LICENSE for copyright and terms of use */

import org.actionstep.alert.ASAlertPanel;
import org.actionstep.ASLabel;
import org.actionstep.ASList;
import org.actionstep.constants.NSAlertReturn;
import org.actionstep.constants.NSAlertStyle;
import org.actionstep.layout.ASHBox;
import org.actionstep.NSAlert;
import org.actionstep.NSArray;
import org.actionstep.NSButton;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.bugtracker.Application;
import org.bugtracker.common.Ticket;
import org.bugtracker.common.TicketManager;
import org.bugtracker.view.TicketFilterView;
import org.bugtracker.view.TicketQuickView;

/**
 * Shows the tickets.
 * 
 * @author Scott Hyndman
 */
class org.bugtracker.view.TicketsView extends NSView {
	
	public static var VIEW_HEIGHT:Number = 500;
	public static var VIEW_WIDTH:Number = 600;
	public static var FILTER_BOX_WIDTH:Number = 340;
	public static var FILTER_BOX_HEIGHT:Number = 160;
	public static var LIST_WIDTH:Number = 230;
	public static var LIST_HEIGHT:Number = 430;
	
	//******************************************************															 
	//*                 Member variables
	//******************************************************
	
	private var m_ticketList:ASList;
	private var m_ticketProperties:TicketQuickView;
	private var m_ticketFilter:TicketFilterView;
	
	private var m_newButton:NSButton;
	private var m_editButton:NSButton;
	private var m_delButton:NSButton;
		
	private var m_selectedTicket:Ticket;
	private var m_selectedTicketIdx:Number;
	
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	public function TicketsView() {
	}
	
	public function initWithFrame(frame:NSRect):TicketsView {
		super.initWithFrame(frame);
		
		//
		// Create tickets label
		//
		var lblTickets:ASLabel = new ASLabel();
		lblTickets.initWithFrame(new NSRect(10, 10, LIST_WIDTH, 22));
		lblTickets.setStringValue("Tickets:");
		addSubview(lblTickets);
		
		createTicketList();
		createTicketButtons();
		createFilterBox();
		createPropertyView();
		
		//
		// Set the tab order
		//
		m_window.setInitialFirstResponder(m_ticketList);
		m_ticketList.setNextKeyView(m_newButton);
		m_newButton.setNextKeyView(m_editButton);
		m_editButton.setNextKeyView(m_delButton);
		m_delButton.setNextKeyView(m_ticketList);
		
		//
		// Fill the list
		//
		reloadData();
		setSelectedTicket(null);
		
		return this;
	}
	
	/**
	 * Creates the property view.
	 */
	private function createPropertyView():Void {
		m_ticketProperties = (new TicketQuickView()).initWithFrame(
			new NSRect(VIEW_WIDTH - FILTER_BOX_WIDTH - 10,
			m_ticketList.frame().minY(),
			TicketQuickView.VIEW_WIDTH, 
			TicketQuickView.VIEW_HEIGHT));
			
		addSubview(m_ticketProperties);
	}
	
	/**
	 * Creates the filter box.
	 */
	private function createFilterBox():Void {
		m_ticketFilter = (new TicketFilterView()).initWithFrame(
			new NSRect(VIEW_WIDTH - FILTER_BOX_WIDTH - 10, 
				m_ticketList.frame().maxY() - FILTER_BOX_HEIGHT,
				FILTER_BOX_WIDTH, FILTER_BOX_HEIGHT));
		
		m_ticketFilter.setTarget(this);
		m_ticketFilter.setAction("filter_change");
		
		addSubview(m_ticketFilter);
	}
	
	/**
	 * Creates the ticket list.
	 */
	private function createTicketList():Void {
		m_ticketList = (new ASList()).initWithFrame(new NSRect(
			10, 30, LIST_WIDTH, LIST_HEIGHT));
		
		m_ticketList.setTarget(this);
		m_ticketList.setAction("tickets_change");
		addSubview(m_ticketList);
	}
	
	/**
	 * Creates New, Edit and Delete buttons.
	 */
	private function createTicketButtons():Void {
		var hbox:ASHBox = (new ASHBox()).init();
		
		m_newButton = (new NSButton()).initWithFrame(
			new NSRect(0,0,85,25));
		m_newButton.setTitle("New");
		m_newButton.setTarget(this);
		m_newButton.setAction("new_click");
		hbox.addView(m_newButton);
		
		m_editButton = (new NSButton()).initWithFrame(
			new NSRect(0,0,85,25));
		m_editButton.setTitle("Edit");
		m_editButton.setTarget(this);
		m_editButton.setAction("edit_click");
		hbox.addView(m_editButton);
		
		m_delButton = (new NSButton()).initWithFrame(
			new NSRect(0,0,90,25));
		m_delButton.setTitle("Delete");
		m_delButton.setTarget(this);
		m_delButton.setAction("delete_click");
		hbox.addView(m_delButton);
		
		addSubview(hbox);
		hbox.setFrameOrigin(new NSPoint(10, m_ticketList.frame().maxY() + 3));
	}
	
	//******************************************************															 
	//*          Reloading from the data source
	//******************************************************
	
	/**
	 * Reloads the data from the data source using the current filter.
	 */
	public function reloadData():Void {
		var tickets:NSArray = TicketManager.instance().ticketsWithPredicate(
			m_ticketFilter.predicate());
		setTickets(tickets);
		setSelectedTicket(null);
		
		m_ticketList.deselectAllItems();
		m_ticketList.setNeedsDisplay(true);
	}
	
	//******************************************************															 
	//*                Setting the tickets
	//******************************************************
	
	/**
	 * Sets the tickets displayed by the list to <code>tickets</code>.
	 */
	public function setTickets(tickets:NSArray):Void {
		m_ticketList.removeAllItems();
		
		var arr:Array = tickets.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			var t:Ticket = Ticket(arr[i]);
			m_ticketList.addItemWithLabelData("#" + t.ticketNumber() 
				+ "\t" + t.summary() + " (" + t.typeAsString().charAt(0) + ")", 
				t);
		}
	}
	
	/**
	 * Sets the selected ticket to <code>ticket</code>.
	 */
	public function setSelectedTicket(ticket:Ticket):Void {
		if (ticket.isEqual(m_selectedTicket)) {
			return;
		}
		
		m_selectedTicket = ticket;
		m_selectedTicketIdx = m_ticketList.indexOfItem(
			m_ticketList.itemWithData(m_selectedTicket));
		m_ticketProperties.setTicket(m_selectedTicket);
		
		var enabled:Boolean = m_selectedTicket != null;
		m_editButton.setEnabled(enabled);
		m_delButton.setEnabled(enabled);
	}
	
	//******************************************************															 
	//*                  Action methods
	//******************************************************
	
	/**
	 * Action for the new button.
	 */
	private function new_click(btn:NSButton):Void {
		Application.createTicketPropertiesWindow(new Ticket(), true);
	}
	
	/**
	 * Action for the edit button.
	 */
	private function edit_click(btn:NSButton):Void {
		Application.createTicketPropertiesWindow(m_selectedTicket, false);
	}
	
	/**
	 * Action for the delete button.
	 */
	private function delete_click(btn:NSButton):Void {
		var alert:NSAlert = (new NSAlert()).init();
		alert.addButtonWithTitle("No");
		alert.addButtonWithTitle("Yes");
		alert.setMessageText("Are you sure you wish to delete ticket #" +
			m_selectedTicket.ticketNumber() + "?");
		alert.setInformativeText("Are you sure?");
		alert.setAlertStyle(NSAlertStyle.NSWarning);
		
		alert.beginSheetModalForWindowModalDelegateDidEndSelectorContextInfo(
			window(), this, "delete_confirm", null);
	}
	
	/**
	 * Called when the user makes a choice the confirmation alert.
	 */
	private function delete_confirm(sheet:ASAlertPanel, ret:NSAlertReturn, 
			ctxt:Object):Void {
				
		if (ret == NSAlertReturn.NSFirstButton) { // No button
			return;
		}
		
		//
		// Perform the deletion
		//
		TicketManager.instance().deleteTicketWithTicketNumber(
			m_selectedTicket.ticketNumber());
			
		//
		// Reload the data and make a new list selection
		//
		reloadData();
		m_ticketList.selectItem(m_ticketList.itemAtIndex(m_selectedTicketIdx));
		tickets_change(m_ticketList);
	}
	
	/**
	 * Called when the selection in the tickets list changes.
	 */
	private function tickets_change(list:ASList):Void {
		setSelectedTicket(Ticket(list.selectedItem().data()));
	}
	
	/**
	 * Results in a filter change.
	 */
	private function filter_change(filter:TicketFilterView):Void {
		reloadData();
	}
}