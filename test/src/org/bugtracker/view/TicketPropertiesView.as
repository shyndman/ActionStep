/* See LICENSE for copyright and terms of use */

import org.actionstep.ASLabel;
import org.actionstep.layout.ASHBox;
import org.actionstep.layout.ASVBox;
import org.actionstep.NSArray;
import org.actionstep.NSButton;
import org.actionstep.NSComboBox;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSTextField;
import org.actionstep.NSTextView;
import org.actionstep.NSView;
import org.bugtracker.Application;
import org.bugtracker.common.Ticket;
import org.bugtracker.common.TicketManager;
import org.bugtracker.view.TicketsView;

/**
 * This view displays the ui for editing existing tickets and creating new ones.
 * 
 * @author Scott Hyndman
 */
class org.bugtracker.view.TicketPropertiesView extends NSView {
	
	//******************************************************															 
	//*                   Constants
	//******************************************************
	
	public static var VIEW_WIDTH:Number = 420;
	public static var VIEW_HEIGHT:Number = 400;
	
	//******************************************************															 
	//*                Member variables
	//******************************************************
	
	private var m_newMode:Boolean;
	
	private var m_reporter:NSTextField;
	private var m_summary:NSTextField;
	private var m_type:NSComboBox;
	private var m_comment:NSTextView;
	private var m_priority:NSComboBox;
	private var m_severity:NSComboBox;
	private var m_keywords:NSTextField;
	private var m_assignTo:NSTextField;
	
	private var m_ok:NSButton;
	private var m_cancel:NSButton;
	
	private var m_ticket:Ticket;
	
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new <code>TicketPropertiesView</code> instance.
	 */
	public function TicketPropertiesView() {
		trace("hit");
	}
	
	/**
	 * Initializes the view with a frame rect.
	 */
	public function initWithFrameNewMode(frame:NSRect, 
			newMode:Boolean):TicketPropertiesView {
		super.initWithFrame(frame);
		
		m_newMode = newMode;
		
		//
		// Create controls
		//
		var vbox:ASVBox = (new ASVBox()).init();
		vbox.setBorder(5);
		addSubview(vbox);
		
		vbox.addView(createReporterField());
		vbox.addViewWithMinYMargin(createSummaryField(), 5);
		vbox.addViewWithMinYMargin(createTypeField(), 5);
		vbox.addViewWithMinYMargin(createCommentField(), 5);
		vbox.addViewWithMinYMargin(createPriorityField(), 5);
		vbox.addViewWithMinYMargin(createSeverityField(), 5);
		vbox.addViewWithMinYMargin(createKeywordsField(), 5);
		vbox.addViewWithMinYMargin(createAssignToField(), 5);
		
		var windowBtns:NSView = createWindowButtons();
		var btnFrame:NSRect = windowBtns.frame();
		windowBtns.setFrameOrigin(new NSPoint(5, 
			VIEW_HEIGHT - 5 - btnFrame.height()));
		addSubview(windowBtns);
		
		//
		// Set tab order
		//
		m_reporter.setNextKeyView(m_summary);
		m_summary.setNextKeyView(m_type);
		m_type.setNextKeyView(m_comment);
		m_comment.setNextKeyView(m_priority);
		m_priority.setNextKeyView(m_severity);
		m_severity.setNextKeyView(m_keywords);
		m_keywords.setNextKeyView(m_assignTo);
		m_assignTo.setNextKeyView(m_ok);
		m_ok.setNextKeyView(m_cancel);
		m_cancel.setNextKeyView(m_reporter);
		window().setInitialFirstResponder(m_reporter);
		
		return this;
	}
	
	private function createReporterField():NSView {
		var hbox:ASHBox = (new ASHBox()).init();
		
		var lbl:ASLabel = new ASLabel();
		lbl.initWithFrame(new NSRect(0,0,100,22));
		lbl.setStringValue("Your email:");
		hbox.addView(lbl);
		
		m_reporter = new NSTextField();
		m_reporter.initWithFrame(new NSRect(0,0,140,22));
		hbox.addView(m_reporter);
		
		return hbox;
	}
	
	private function createSummaryField():NSView {
		var hbox:ASHBox = (new ASHBox()).init();
		
		var lbl:ASLabel = new ASLabel();
		lbl.initWithFrame(new NSRect(0,0,100,22));
		lbl.setStringValue("Summary:");
		hbox.addView(lbl);
		
		m_summary = new NSTextField();
		m_summary.initWithFrame(new NSRect(0,0,250,22));
		hbox.addView(m_summary);
		
		return hbox;
	}
	
	private function createTypeField():NSView {
		var hbox:ASHBox = (new ASHBox()).init();
		
		var lbl:ASLabel = new ASLabel();
		lbl.initWithFrame(new NSRect(0,0,100,22));
		lbl.setStringValue("Type:");
		hbox.addView(lbl);
		
		m_type = new NSComboBox();
		m_type.initWithFrame(new NSRect(0,0,140,22));
		m_type.setEditable(false);
		m_type.addItemsWithObjectValues(NSArray.arrayWithArray(Ticket.TYPE_STRINGS));
		m_type.selectItemWithObjectValue("Defect");
		hbox.addView(m_type);
		
		return hbox;
	}
	
	private function createCommentField():NSView {
		var vbox:ASVBox = (new ASVBox()).init();
		
		var lbl:ASLabel = new ASLabel();
		lbl.initWithFrame(new NSRect(0,0,100,22));
		lbl.setStringValue("Full description:");
		vbox.addView(lbl);
		
		m_comment = new NSTextView();
		m_comment.initWithFrame(new NSRect(0,0,400,100));
		m_comment.setEditable(true);
		m_comment.setSelectable(true);
		vbox.addViewWithMinYMargin(m_comment, 0);
		
		return vbox;
	}
	
	private function createPriorityField():NSView {
		var hbox:ASHBox = (new ASHBox()).init();
		
		var lbl:ASLabel = new ASLabel();
		lbl.initWithFrame(new NSRect(0,0,100,22));
		lbl.setStringValue("Priority:");
		hbox.addView(lbl);
		
		m_priority = new NSComboBox();
		m_priority.initWithFrame(new NSRect(0,0,140,22));
		m_priority.setEditable(false);
		m_priority.addItemsWithObjectValues(NSArray.arrayWithArray(Ticket.PRIOR_STRINGS));
		m_priority.selectItemWithObjectValue("Normal");
		hbox.addView(m_priority);
		
		return hbox;
	}
	
	private function createSeverityField():NSView {
		var hbox:ASHBox = (new ASHBox()).init();
		
		var lbl:ASLabel = new ASLabel();
		lbl.initWithFrame(new NSRect(0,0,100,22));
		lbl.setStringValue("Severity:");
		hbox.addView(lbl);
		
		m_severity = new NSComboBox();
		m_severity.initWithFrame(new NSRect(0,0,140,22));
		m_severity.setEditable(false);
		m_severity.addItemsWithObjectValues(NSArray.arrayWithArray(Ticket.SEV_STRINGS));
		m_severity.selectItemWithObjectValue("Normal");
		hbox.addView(m_severity);
		
		return hbox;
	}
	
	private function createAssignToField():NSView {
		var hbox:ASHBox = (new ASHBox()).init();
		
		var lbl:ASLabel = new ASLabel();
		lbl.initWithFrame(new NSRect(0,0,100,22));
		lbl.setStringValue("Assign to:");
		hbox.addView(lbl);
		
		m_assignTo = new NSTextField();
		m_assignTo.initWithFrame(new NSRect(0,0,180,22));
		hbox.addView(m_assignTo);
		
		return hbox;
	}
	
	private function createKeywordsField():NSView {
		var hbox:ASHBox = (new ASHBox()).init();
		
		var lbl:ASLabel = new ASLabel();
		lbl.initWithFrame(new NSRect(0,0,100,22));
		lbl.setStringValue("Keywords:");
		hbox.addView(lbl);
		
		m_keywords = new NSTextField();
		m_keywords.initWithFrame(new NSRect(0,0,180,22));
		hbox.addView(m_keywords);
		
		return hbox;
	}
	
	private function createWindowButtons():NSView {
		var hbox:ASHBox = (new ASHBox()).init();
		
		m_ok = new NSButton();
		m_ok.initWithFrame(new NSRect(0,0,100,22));
		m_ok.setTitle("OK");
		m_ok.setTarget(this);
		m_ok.setAction("ok_click");
		hbox.addView(m_ok);
		
		m_cancel = new NSButton();
		m_cancel.initWithFrame(new NSRect(0,0,100,22));
		m_cancel.setTitle("Cancel");
		m_cancel.setTarget(this);
		m_cancel.setAction("cancel_click");
		hbox.addViewWithMinXMargin(m_cancel, 10);
		
		return hbox;
	}
	
	//******************************************************															 
	//*           Getting / setting the ticket
	//******************************************************
	
	/**
	 * Returns the ticket displayed by this form.
	 */
	public function ticket():Ticket {
		return m_ticket;
	}
	
	/**
	 * Sets the ticket displayed by this form to <code>ticket</code>.
	 */
	public function setTicket(ticket:Ticket):Void {
		if (ticket == null || m_ticket.isEqual(ticket)) {
			return;
		}
		
		m_ticket = ticket;
		populateForm();
	}
	
	//******************************************************															 
	//*              Updating the form
	//******************************************************
	
	/**
	 * Populates the form from the ticket data.
	 */
	private function populateForm():Void {
		m_reporter.setStringValue(m_ticket.reportedBy());
		m_reporter.setNeedsDisplay(true);
		
		m_summary.setStringValue(m_ticket.summary());
		m_summary.setNeedsDisplay(true);
		
		m_type.selectItemWithObjectValue(Ticket.TYPE_STRINGS[
			m_ticket.type() - 1]);
			
		m_comment.setString(m_ticket.comment());
		m_comment.setNeedsDisplay(true);
				
		m_priority.selectItemWithObjectValue(Ticket.PRIOR_STRINGS[
			m_ticket.priority() - 1]);
			
		m_severity.selectItemWithObjectValue(Ticket.SEV_STRINGS[
			m_ticket.severity() - 1]);
			
		m_keywords.setStringValue(m_ticket.keywords().internalList().join(","));
		m_keywords.setNeedsDisplay(true);
		
		m_assignTo.setStringValue(m_ticket.assignedTo());
		m_assignTo.setNeedsDisplay(true);	
	}
	
	//******************************************************															 
	//*                  Action handlers
	//******************************************************
	
	/**
	 * Fired when the OK button is pressed.
	 */
	private function ok_click(btn:NSButton):Void {
		//
		// Update the ticket's properties
		//
		m_ticket.setReportedBy(m_reporter.stringValue());
		m_ticket.setSummary(m_summary.stringValue());
		m_ticket.setType(Ticket["TYPE_" 
			+ m_type.objectValueOfSelectedItem().toString().toUpperCase()]);
		m_ticket.setComment(m_comment.string());
		m_ticket.setPriority(Ticket["PRIOR_" 
			+ m_priority.objectValueOfSelectedItem().toString().toUpperCase()]);
		m_ticket.setSeverity(Ticket["SEV_" 
			+ m_severity.objectValueOfSelectedItem().toString().toUpperCase()]);
		m_ticket.setAssignedTo(m_assignTo.stringValue());
		
		//
		// Keywords
		//
		m_ticket.clearKeywords();
		var newKeywords:Array = m_keywords.stringValue().split(",");
		var len:Number = newKeywords.length;
		for (var i:Number = 0; i < len; i++) {
			m_ticket.addKeyword(newKeywords[i]);
		}
		
		//
		// Add the ticket if necessary
		//
		if (m_newMode) {
			TicketManager.instance().addTicket(m_ticket);
		} else {
			m_ticket.markAsModified();
		}
		
		var ticketsView:TicketsView = Application.ticketsView();
		ticketsView.reloadData();
		ticketsView.window().makeKeyWindow();
		ticketsView.window().makeMainWindow();
		m_window.close();
	}
	
	/**
	 * Fired when the cancel button is pressed.
	 */
	private function cancel_click(btn:NSButton):Void {
		var ticketsView:TicketsView = Application.ticketsView();
		ticketsView.reloadData();
		ticketsView.window().makeKeyWindow();
		ticketsView.window().makeMainWindow();
		m_window.close();
	}
}