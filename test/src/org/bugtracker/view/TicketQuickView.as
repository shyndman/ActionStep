/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.ASLabel;
import org.actionstep.ASTextRenderer;
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSLineBreakMode;
import org.actionstep.constants.NSTitlePosition;
import org.actionstep.layout.ASGrid;
import org.actionstep.layout.ASHBox;
import org.actionstep.layout.ASVBox;
import org.actionstep.NSBox;
import org.actionstep.NSColor;
import org.actionstep.NSFont;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.bugtracker.common.Ticket;

/**
 * Displays the properties of a <code>Ticket</code> instance.
 * 
 * @author Scott Hyndman
 */
class org.bugtracker.view.TicketQuickView extends NSView {
	
	//******************************************************															 
	//*                   Constants
	//******************************************************
	
	public static var VIEW_WIDTH:Number = 340;
	public static var VIEW_HEIGHT:Number = 265;
	
	private static var SUMMARY_TO_TS_RATIO:Number = 0.57;
	
	//******************************************************															 
	//*                Member variables
	//******************************************************
	
	private var m_ticket:Ticket;
	private var m_textColor:NSColor;
	private var m_summary:ASLabel;
	private var m_creationDate:ASLabel;
	private var m_modifiedDate:ASLabel;
	private var m_status:ASLabel;
	private var m_reportedBy:ASLabel;
	private var m_assignedTo:ASLabel;
	private var m_severity:ASLabel;
	private var m_priority:ASLabel;
	private var m_keywords:ASLabel;
	private var m_number:ASLabel;
	private var m_comment:ASTextRenderer;
	
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	/**
	 * Constructs a new <code>TicketQuickView</code>.
	 */
	public function TicketQuickView() {
		m_textColor = new NSColor(0x99997D);
	}
	
	/**
	 * Initializes the instance with a frame size of <code>frame</code>.
	 */
	public function initWithFrame(frame:NSRect):TicketQuickView {
		super.initWithFrame(frame);
		
		//
		// Create child components
		//
		var vbox:ASVBox = (new ASVBox()).init();
		vbox.setBorder(5);
		addSubview(vbox);
		var cFrm:NSRect = frame.insetRect(10, 10);
		
		//
		// Create summary and timestamp line
		//
		var hboxSum:ASHBox = (new ASHBox()).init();
		var sumFont:NSFont = NSFont.fontWithNameSize("Verdana", 16);
		var sumHeight:Number = sumFont.getTextExtent("Sample Summary").height;
		var tsFont:NSFont = NSFont.fontWithNameSize("Verdana", 9);
		var tsLineHeight:Number = tsFont.getTextExtent("Opened on 1990").height;
				
		m_summary = new ASLabel();
		m_summary.initWithFrame(new NSRect(0,0,
			cFrm.width() * SUMMARY_TO_TS_RATIO, sumHeight + 4));
		m_summary.setFont(sumFont);
		hboxSum.addView(m_summary);
		
		var boxWidth:Number = cFrm.width() * (1 - SUMMARY_TO_TS_RATIO);
		var tsHolder:NSBox = new NSBox();
		tsHolder.initWithFrame(new NSRect(0,0,
			boxWidth, sumHeight + 4));
		tsHolder.setContentViewMargins(new NSSize(0, 0));
		tsHolder.setBorderType(NSBorderType.NSNoBorder);
		tsHolder.setTitlePosition(NSTitlePosition.NSNoTitle);
		var tsCnt:NSView = tsHolder.contentView();
		
		m_creationDate = new ASLabel();
		m_creationDate.initWithFrame(new NSRect(0,0,boxWidth,tsLineHeight));
		m_creationDate.setTextColor(m_textColor);
		m_creationDate.setFont(tsFont);
		tsCnt.addSubview(m_creationDate);

		m_modifiedDate = new ASLabel();
		m_modifiedDate.initWithFrame(new NSRect(0,tsLineHeight - 2,boxWidth,
			tsLineHeight));
		m_modifiedDate.setTextColor(m_textColor);
		m_modifiedDate.setFont(tsFont);
		tsCnt.addSubview(m_modifiedDate);		
				  
		hboxSum.addView(tsHolder);
		vbox.addView(hboxSum);
		
		//
		// Status line
		//
		var statusFont:NSFont = NSFont.fontWithNameSize("Verdana", 12);
		var statusHeight:Number = statusFont.getTextExtent("Test test").height;
		
		m_status = new ASLabel();
		m_status.initWithFrame(new NSRect(0,0,cFrm.width(), statusHeight));
		m_status.setFont(statusFont);
		m_status.setTextColor(m_textColor);
		vbox.addView(m_status);
		
		//
		// Additional properties (in a box)
		//
		var propBox:NSBox = createPropertiesBox(cFrm);
		vbox.addViewWithMinYMargin(propBox, 10);
		
		//
		// Comments
		//
		m_comment = new ASTextRenderer();
		m_comment.initWithFrame(new NSRect(0,0,cFrm.width(), 140));
		m_comment.setDrawsBackground(false);
		m_comment.setText("");
		m_comment.setWordWrap(true);
		m_comment.setStyleCSS(
			"comment { \n" +
			"font-size: 12px; \n" +
			"font-family: Verdana; \n" +
			"}"
			);
		vbox.addView(m_comment);
				
		return this;
	}
	
	private function createPropertiesBox(rect:NSRect):NSBox {
		var propBox:NSBox = new NSBox();
		propBox.initWithFrame(new NSRect(0,0,rect.width(), 60));
		propBox.setTitlePosition(NSTitlePosition.NSNoTitle);
		var cnt:NSView = propBox.contentView();
		
		//
		// Create grid
		//
		var grid:ASGrid = (new ASGrid()).initWithNumberOfRowsNumberOfColumns(
			3, 4);
		cnt.addSubview(grid);
		
		//
		// Properties for labels
		//
		var font:NSFont = NSFont.fontWithNameSize("Verdana", 9);
		var lblWidth:Number = Math.round((rect.width() - 6) / 4);
		var lblHeight:Number = font.getTextExtent("Test pesq test").height;
		
		//
		// Reported by
		//
		var lbl:ASLabel = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, lblWidth - 10, lblHeight));
		lbl.setFont(font);
		lbl.setTextColor(m_textColor);
		lbl.setStringValue("Reported by:");
		grid.putViewAtRowColumn(lbl, 0, 0);
		
		lbl = m_reportedBy = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, lblWidth + 10, lblHeight));
		lbl.setFont(font);
		lbl.cell().setLineBreakMode(NSLineBreakMode.NSLineBreakByTruncatingTail);
		grid.putViewAtRowColumn(lbl, 0, 1);

		//
		// Assigned to
		//
		lbl = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, lblWidth - 10, lblHeight));
		lbl.setFont(font);
		lbl.setTextColor(m_textColor);
		lbl.setStringValue("Assigned to:");
		grid.putViewAtRowColumn(lbl, 0, 2);
		
		lbl = m_assignedTo = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, lblWidth + 10, lblHeight));
		lbl.setFont(font);
		lbl.cell().setLineBreakMode(NSLineBreakMode.NSLineBreakByTruncatingTail);
		grid.putViewAtRowColumn(lbl, 0, 3);
		
		//
		// Priority
		//
		lbl = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, lblWidth - 10, lblHeight));
		lbl.setFont(font);
		lbl.setTextColor(m_textColor);
		lbl.setStringValue("Priority:");
		grid.putViewAtRowColumn(lbl, 1, 0);
		
		lbl = m_priority = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, lblWidth + 10, lblHeight));
		lbl.setFont(font);
		lbl.cell().setLineBreakMode(NSLineBreakMode.NSLineBreakByTruncatingTail);
		grid.putViewAtRowColumn(lbl, 1, 1);

		//
		// Severity
		//
		lbl = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, lblWidth - 10, lblHeight));
		lbl.setFont(font);
		lbl.setTextColor(m_textColor);
		lbl.setStringValue("Severity:");
		grid.putViewAtRowColumn(lbl, 1, 2);
		
		lbl = m_severity = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, lblWidth + 10, lblHeight));
		lbl.setFont(font);
		lbl.cell().setLineBreakMode(NSLineBreakMode.NSLineBreakByTruncatingTail);
		grid.putViewAtRowColumn(lbl, 1, 3);
		
		//
		// Keywords
		//
		lbl = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, lblWidth - 10, lblHeight));
		lbl.setFont(font);
		lbl.setTextColor(m_textColor);
		lbl.setStringValue("Keywords:");
		grid.putViewAtRowColumn(lbl, 2, 0);
		
		lbl = m_keywords = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, lblWidth + 10, lblHeight));
		lbl.setFont(font);
		lbl.cell().setLineBreakMode(NSLineBreakMode.NSLineBreakByTruncatingTail);
		grid.putViewAtRowColumn(lbl, 2, 1);
				
		//
		// Keywords
		//
		lbl = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, lblWidth - 10, lblHeight));
		lbl.setFont(font);
		lbl.setTextColor(m_textColor);
		lbl.setStringValue("Ticket #:");
		grid.putViewAtRowColumn(lbl, 2, 2);
		
		lbl = m_number = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, lblWidth + 10, lblHeight));
		lbl.setFont(font);
		lbl.cell().setLineBreakMode(NSLineBreakMode.NSLineBreakByTruncatingTail);
		grid.putViewAtRowColumn(lbl, 2, 3);
		
		return propBox;
	}
	
	//******************************************************															 
	//*           Setting / getting the ticket
	//******************************************************
	
	/**
	 * Returns the ticket being shown by this view, or <code>null</code> if
	 * none is being shown.
	 */
	public function ticket():Ticket {
		return m_ticket;
	}
	
	/**
	 * Sets the ticket being shown by this view to <code>ticket</code>.
	 */
	public function setTicket(ticket:Ticket):Void {
		if (ticket.isEqual(m_ticket)) {
			return;
		}
		
		m_ticket = ticket;
		updateTicketProperties();
	}
	
	/**
	 * Clears the form.
	 */
	public function clear():Void {
		m_summary.setStringValue("");
		m_summary.setNeedsDisplay(true);
			
		m_creationDate.setStringValue("");
		m_creationDate.setNeedsDisplay(true);
	
		m_modifiedDate.setStringValue("");
		m_modifiedDate.setNeedsDisplay(true);
		
		m_status.setStringValue("");
		m_status.setNeedsDisplay(true);
	
		m_priority.setStringValue("");
		m_priority.setNeedsDisplay(true);
		
		m_severity.setStringValue("");
		m_severity.setNeedsDisplay(true);
		
		m_reportedBy.setStringValue("");
		m_reportedBy.setNeedsDisplay(true);
		m_reportedBy.setToolTip("");

		m_assignedTo.setStringValue("");
		m_assignedTo.setNeedsDisplay(true);
		m_assignedTo.setToolTip("");
	
		m_keywords.setStringValue("");
		m_keywords.setNeedsDisplay(true);
		
		m_number.setStringValue("");
		m_number.setNeedsDisplay(true);

		m_comment.setText("");
	}
	
	/**
	 * Updates the form controls with the contents of ticket.
	 */
	private function updateTicketProperties():Void {
		if (m_ticket == null) {
			clear();
			m_summary.setStringValue("No selection");
			m_summary.setNeedsDisplay(true);
			return;
		}
		
		//
		// Summary
		//
		m_summary.setStringValue(m_ticket.summary());
		m_summary.setNeedsDisplay(true);
		
		//
		// Creation date
		//
		var dateStr:String = m_ticket.creationTimestamp(
			).descriptionWithCalendarFormat("%b %d, %Y");
		m_creationDate.setStringValue("Created: " + dateStr);
		m_creationDate.setNeedsDisplay(true);
		
		//
		// Modified date
		//
		if (m_ticket.isModified()) {
			dateStr = m_ticket.modifiedTimestamp(
				).descriptionWithCalendarFormat("%b %d, %Y");
			m_modifiedDate.setStringValue("Mod: " + dateStr);
		} else {
			m_modifiedDate.setStringValue("");
		}
		m_modifiedDate.setNeedsDisplay(true);
		
		//
		// Status
		//
		m_status.setStringValue("Status: " + m_ticket.statusAsString());
		m_status.setNeedsDisplay(true);
		
		//
		// Reported by
		//
		m_reportedBy.setStringValue(m_ticket.reportedBy());
		m_reportedBy.setNeedsDisplay(true);
		m_reportedBy.setToolTip(m_ticket.reportedBy());

		//
		// Assigned to
		//
		m_assignedTo.setStringValue(m_ticket.assignedTo());
		m_assignedTo.setNeedsDisplay(true);
		m_assignedTo.setToolTip(m_ticket.assignedTo());
		
		//
		// Priority
		//
		m_priority.setStringValue(m_ticket.priorityAsString());
		m_priority.setNeedsDisplay(true);
		
		//
		// Severity
		//
		m_severity.setStringValue(m_ticket.severityAsString());
		m_severity.setNeedsDisplay(true);
		
		//
		// Keywords
		//
		m_keywords.setStringValue(m_ticket.keywords().internalList().join(", "));
		m_keywords.setNeedsDisplay(true);
		
		//
		// Ticket #
		//
		m_number.setStringValue(m_ticket.ticketNumber().toString());
		m_number.setNeedsDisplay(true);
		
		//
		// Comment
		//
		m_comment.setText("<comment>" + m_ticket.comment() + "</comment>");
	}
	
	//******************************************************															 
	//*               Drawing the view
	//******************************************************
	
	/**
	 * Draws the view in the area defined by <code>rect</code>.
	 */
	public function drawRect(rect:NSRect):Void {
		
		var mc:MovieClip = mcBounds();
		ASDraw.drawRectWithRect(mc, rect, 0x000000, 100);
		ASDraw.fillRectWithRect(mc, rect.insetRect(1, 1), 0xFFFFE1, 80);
	}
}