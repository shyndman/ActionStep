/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASDraw;
import org.actionstep.ASLabel;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.layout.ASHBox;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSRect;
import org.actionstep.NSView;

/**
 * Represents a single filter in the list displayed by 
 * <code>TicketFilterView</code>.
 * 
 * @author Scott Hyndman
 */
class org.bugtracker.view.TicketFilterElementView extends NSView {
	
	//******************************************************
	//*                   Constants
	//******************************************************
	
	private static var REMOVE_BUTTON_WIDTH:Number = 40;
	private static var PADDING:Number = 4;
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private var m_predicateFormat:String;
	
	private var m_label:ASLabel;
	private var m_removeButton:NSButton;
	
	private var m_target:Object;
	private var m_action:String;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>TicketFilterElementView</code> class.
	 */
	public function TicketFilterElementView() {
	}
	
	/**
	 * Initializes the ticket filter element with a frame of <code>frame</code>
	 * and a predicate format <code>format</code>.
	 * 
	 * The view will display the text <code>displayText</code>.
	 */
	public function initWithFramePredicateFormatDisplayText(frame:NSRect, 
			format:String, displayText:String):TicketFilterElementView {
		super.initWithFrame(frame);
		m_predicateFormat = format;
		
		//
		// Build the UI
		//
		var hbox:ASHBox = (new ASHBox()).init();
		hbox.setBorder(PADDING);
		addSubview(hbox);
		
		//
		// Label
		//
		var labelWidth:Number = frame.width() - REMOVE_BUTTON_WIDTH - PADDING * 2;
		m_label = (new ASLabel()).initWithFrame(
			new NSRect(0, 0, labelWidth, frame.height() - PADDING * 2));
		m_label.setStringValue(displayText);
		hbox.addView(m_label);
		
		//
		// Remove button
		//
		m_removeButton = new NSButton();
		m_removeButton.initWithFrame(
			new NSRect(0, 0, REMOVE_BUTTON_WIDTH, frame.height() - PADDING * 2));
		m_removeButton.setAlignment(NSTextAlignment.NSCenterTextAlignment);
		m_removeButton.setTitle("-");
		m_removeButton.setTarget(this);
		m_removeButton.setAction("remove_click");
		hbox.addView(m_removeButton);
		
		return this;		
	}
	
	//******************************************************
	//*                   Properties
	//******************************************************
	
	public function predicateFormat():String {
		return m_predicateFormat;
	}
	
	//******************************************************
	//*                  Target-action
	//******************************************************
	
	public function setTarget(target:Object):Void {
		m_target = target;
	}
	
	public function setAction(action:String):Void {
		m_action = action;
	}
	
	//******************************************************
	//*                Responding to actions
	//******************************************************
	
	/**
	 * Sends an <code>#action()</code> message to <code>#target()</code>
	 * indicating that it should be removed.
	 */
	private function remove_click(btn:NSButton):Void {
		NSApplication.sharedApplication().sendActionToFrom(m_action,
			m_target, this);
	}
	
	//******************************************************
	//*                   Drawing the view
	//******************************************************
	
	public function drawRect(rect:NSRect):Void {
		var mc:MovieClip = mcBounds();
		mc.clear();
		var dark:Number = ASColors.lightGrayColor().value;
		var light:Number = ASColors.whiteColor().value;
		
		ASDraw.gradientRectWithRect(mc, rect.insetRect(2, 2), 0,
			[light, dark], [0, 255]);
	}
}