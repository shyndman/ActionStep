/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColoredView;
import org.actionstep.ASUtils;
import org.actionstep.layout.ASHBox;
import org.actionstep.layout.ASVBox;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSBox;
import org.actionstep.NSButton;
import org.actionstep.NSColor;
import org.actionstep.NSComboBox;
import org.actionstep.NSControl;
import org.actionstep.NSDictionary;
import org.actionstep.NSPoint;
import org.actionstep.NSPredicate;
import org.actionstep.NSRect;
import org.actionstep.NSScrollView;
import org.actionstep.NSSize;
import org.actionstep.NSTextField;
import org.actionstep.NSView;
import org.bugtracker.view.TicketFilterElementView;

/**
 * @author Scott Hyndman
 */
class org.bugtracker.view.TicketFilterView extends NSView {

	//******************************************************
	//*                   Constants
	//******************************************************

	private static var ELEMENT_HEIGHT:Number = 24;
	private static var ELEMENT_WIDTH:Number;

	private static var TYPE_NUMBER:Number 	= 1;
	private static var TYPE_STRING:Number 	= 2;
	private static var TYPE_ARRAY:Number 	= 3;

	//******************************************************
	//*                    Members
	//******************************************************

	private var m_member:NSComboBox;
	private var m_operator:NSComboBox;
	private var m_valueCombo:NSComboBox;
	private var m_valueTxt:NSTextField;
	private var m_currentValueCtrl:NSControl;
	private var m_addButton:NSButton;

	private var m_target:Object;
	private var m_action:String;

	private var m_members:NSDictionary;

	private var m_filters:NSArray;
	private var m_filterParent:ASColoredView;
	private var m_scrollSize:NSSize;

	//******************************************************
	//*                  Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>TicketFilterView</code> class.
	 */
	public function TicketFilterView() {
		m_members = NSDictionary.dictionary();
		m_filters = NSArray.array();
	}

	/**
	 * Initializes the view with a frame of <code>frame</code>.
	 */
	public function initWithFrame(frame:NSRect):TicketFilterView {
		super.initWithFrame(frame);

		var box:NSBox = (new NSBox()).initWithFrame(
			NSRect.withOriginSize(NSPoint.ZeroPoint, frame.size));
		box.setTitle("Filter");
		addSubview(box);
		var cnt:NSView = box.contentView();

		//
		// Create VBox for layout
		//
		var vbox:ASVBox = (new ASVBox()).init();
		cnt.addSubview(vbox);

		//
		// Build comparison predicate mini-form
		//
		var compBox:ASHBox = (new ASHBox()).init();

		//
		// Member combobox
		//
		m_member = new NSComboBox();
		m_member.initWithFrame(new NSRect(0,0,100,22));
		m_member.setEditable(false);
		m_member.setTarget(this);
		m_member.setAction("member_change");
		compBox.addView(m_member);

		//
		// Operator combobox
		//
		m_operator = new NSComboBox();
		m_operator.initWithFrame(new NSRect(0,0,50,22));
		m_operator.setEditable(false);
		compBox.addViewWithMinXMargin(m_operator, 4);

		//
		// Value operand combobox
		//
		m_valueCombo = new NSComboBox();
		m_valueCombo.initWithFrame(new NSRect(0,0,88,22));
		m_valueCombo.setEditable(false);

		//
		// Value operand textfield
		//
		m_currentValueCtrl = m_valueTxt = new NSTextField();
		m_valueTxt.initWithFrame(new NSRect(0,0,88,22));
		compBox.addViewWithMinXMargin(m_valueTxt, 4);

		//
		// Add button
		//
		m_addButton = new NSButton();
		m_addButton.initWithFrame(new NSRect(0,0,80,22));
		m_addButton.setTitle("Add");
		m_addButton.setTarget(this);
		m_addButton.setAction("add_click");
		compBox.addViewWithMinXMargin(m_addButton, 4);

		vbox.addView(compBox);

		//
		// Create predicate list
		//
		var scroll:NSScrollView = (new NSScrollView()).initWithFrame(
			NSRect.withOriginSize(
				NSPoint.ZeroPoint,
				frame.size.subtractSize(new NSSize(10, 54))));
		scroll.setHasHorizontalScroller(false);
		scroll.setHasVerticalScroller(true);
		scroll.setAutohidesScrollers(true);
		vbox.addViewWithMinYMargin(scroll, 4);

		m_scrollSize = scroll.contentSize();
		m_filterParent = new ASColoredView();
		m_filterParent.initWithFrame(
			NSRect.withOriginSize(NSPoint.ZeroPoint, m_scrollSize));
		m_filterParent.setBackgroundColor(new NSColor(0xCCCCCC));
		m_filterParent.setBorderColor(new NSColor(0x333333));
		scroll.setDocumentView(m_filterParent);

		//
		// FIXME Kind of stupid to set a constant in an instance method
		//
		ELEMENT_WIDTH = scroll.contentSize().width;

		//
		// Register the default members
		//
		registerDefaultMembers();
		m_member.selectItemAtIndex(0);
		member_change(m_member);

		return this;
	}

	//******************************************************
	//*                Getting the predicate
	//******************************************************

	/**
	 * Returns the predicate as built by this view.
	 */
	public function predicate():NSPredicate {
		if (m_filters.count() == 0) {
			return null;
		}

		var format:String = "";
		var arr:Array = m_filters.internalList();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			format += TicketFilterElementView(arr[i]).predicateFormat();

			if (i + 1 < len) {
				format += " AND ";
			}
		}

		return NSPredicate.predicateWithFormat(format);
	}

	//******************************************************
	//*              Managing the filter list
	//******************************************************

	public function addFilterElementWithNameOperatorStringValue(name:String,
			operator:String, str:String, value:Object):Void {
		//
		// Build the element
		//
		var displayText:String = name + " " + operator + " " + str;
		var predFormat:String = name + " " + operator + " " + value;
		var yPosition:Number = m_filters.count() * ELEMENT_HEIGHT;

		var element:TicketFilterElementView = (new TicketFilterElementView())
			.initWithFramePredicateFormatDisplayText(
			new NSRect(0, yPosition, ELEMENT_WIDTH, ELEMENT_HEIGHT),
			predFormat,
			displayText);
		element.setTarget(this);
		element.setAction("remove_click");
		m_filterParent.addSubview(element);

		//
		// Size parent if necessary
		//
		var parFrame:NSRect = m_filterParent.frame();
		if (element.frame().maxY() > parFrame.maxY()) {
			m_filterParent.setFrameSize(
				new NSSize(parFrame.width(), element.frame().maxY()));
		}

		//
		// Add the filter
		//
		m_filters.addObject(element);

		//
		// Send out an action message
		//
		NSApplication.sharedApplication().sendActionToFrom(m_action, m_target,
			this);
	}

	/**
	 * Removes <code>element</code> from the list of filters and repositions the
	 * list.
	 */
	public function removeFilterElement(element:TicketFilterElementView):Void {
		var idx:Number;
		if ((idx = m_filters.indexOfObject(element)) == NSNotFound) {
			return;
		}

		m_filters.removeObjectAtIndex(idx);
		element.removeFromSuperview();

		//
		// Shift down other filter element views
		//
		var arr:Array = m_filters.internalList();
		var len:Number = arr.length;
		for (var i:Number = idx; i < len; i++) {
			var e:TicketFilterElementView = TicketFilterElementView(arr[i]);
			var loc:NSPoint = e.frame().origin;
			e.setFrameOrigin(loc.subtractPoint(new NSPoint(0, ELEMENT_HEIGHT)));
		}

		//
		// Size parent if necessary
		//
		var last:TicketFilterElementView = TicketFilterElementView(
			m_filters.lastObject());
		var parFrame:NSRect = m_filterParent.frame();
		if (last.frame().maxY() < parFrame.maxY()) {
			var newHeight:Number = last.frame().maxY();

			if (newHeight < m_scrollSize.height) {
				newHeight = m_scrollSize.height;
			}

			m_filterParent.setFrameSize(
				new NSSize(parFrame.width(), newHeight));
		}

		//
		// Send out an action message
		//
		NSApplication.sharedApplication().sendActionToFrom(m_action, m_target,
			this);
	}

	//******************************************************
	//*                   Target-action
	//******************************************************

	/**
	 * Sets the object that will receive messages when the filters change.
	 */
	public function setTarget(target:Object):Void {
		m_target = target;
	}

	/**
	 * Sets the method that will be called on <code>#target()</code> when the
	 * filters change.
	 */
	public function setAction(selector:String):Void {
		m_action = selector;
	}

	//******************************************************
	//*                  Action Handlers
	//******************************************************

	/**
	 * Removes <code>element</code> from the list.
	 */
	private function remove_click(element:TicketFilterElementView):Void {
		removeFilterElement(element);
	}

	/**
	 * Fired when the add button is clicked
	 */
	private function add_click(btn:NSButton):Void {
		//
		// Get the member and operator in question
		//
		var name:String = m_member.objectValueOfSelectedItem().toString();
		var member:Object
			= m_members.objectForKey(name);
		var op:String = m_operator.objectValueOfSelectedItem().toString();

		//
		// Extract the string and value
		//
		var str:String;
		var val:Object;

		if (m_currentValueCtrl == m_valueCombo) {
			str = m_valueCombo.objectValueOfSelectedItem().toString();
			val = NSArray(member.elements).filteredArrayUsingPredicate(
				NSPredicate.predicateWithFormat("display == \"" + str + "\""))
				.objectAtIndex(0).data;
		} else {
			val = str = m_valueTxt.stringValue();
		}

		//
		// Validation
		//
		if (ASUtils.trimString(str).length == 0) {
			// TODO Show alert
			return;
		}

		//
		// Format value (and string if necessary)
		//
		if (member.type == TYPE_STRING) {
			val = str = "\"" + val + "\"";
		}
		else if (member.type == TYPE_NUMBER) {
			val = Number(val);
		}

		//
		// Add the filter element
		//
		addFilterElementWithNameOperatorStringValue(name, op, str, val);
	}

	/**
	 * Fired when the selected member changes
	 */
	private function member_change(cmbo:NSComboBox):Void {
		var member:Object
			= m_members.objectForKey(cmbo.objectValueOfSelectedItem().toString());
		displayOperatorsForType(member.type);

		//
		// Set up value box
		//
		if (member.elements != null) {
			//
			// replace view if necessary
			//
			if (m_currentValueCtrl != m_valueCombo) {
				m_currentValueCtrl.superview().replaceSubviewWith(
					m_currentValueCtrl,
					m_valueCombo);
				m_currentValueCtrl = m_valueCombo;
			}

			m_valueCombo.removeAllItems();
			var arr:Array = member.elements.internalList();
			var len:Number = arr.length;
			for (var i:Number = 0; i < len; i++) {
				m_valueCombo.addItemWithObjectValue(arr[i].display);
			}

			m_valueCombo.selectItemAtIndex(0);
		} else {
			//
			// replace view if necessary
			//
			if (m_currentValueCtrl != m_valueTxt) {
				m_currentValueCtrl.superview().replaceSubviewWith(
					m_currentValueCtrl,
					m_valueTxt);
				m_currentValueCtrl = m_valueTxt;
			}

			m_valueTxt.setStringValue("");
		}

		m_currentValueCtrl.setNeedsDisplay(true);
	}

	//******************************************************
	//*                   Operators
	//******************************************************

	/**
	 * Fills the operator dropdown with the values appropriate for
	 * <code>type</code>.
	 */
	private function displayOperatorsForType(type:Number):Void {
		var curOp:String = m_operator.objectValueOfSelectedItem().toString();

		m_operator.removeAllItems();
		var ops:Array = [
			"==",
			"!=",
			">",
			">=",
			"<",
			"<="];

		m_operator.addItemsWithObjectValues(NSArray.arrayWithArray(ops));

		if (type == TYPE_STRING) {
			m_operator.addItemsWithObjectValues(NSArray.arrayWithArray([
				"LIKE",
				"BEGINSWITH",
				"ENDSWITH"]));
		}
		else if (type == TYPE_ARRAY) {
			m_operator.addItemWithObjectValue("IN");
		}

		if (m_operator.indexOfItemWithObjectValue(curOp) != NSNotFound) {
			m_operator.selectItemWithObjectValue(curOp);
		} else {
			m_operator.selectItemAtIndex(0);
		}

		m_operator.setNeedsDisplay(true);
	}

	//******************************************************
	//*                    Members
	//******************************************************

	/**
	 * Adds a member named <code>name</code> of type <code>type</code>.
	 *
	 * The optional <code>elements</code> argument specifies a list of elements
	 * to display in a combobox, and their true values. Each object in the
	 * array should be as follows:
	 * <code>{display:String, data:Object}</code>
	 */
	private function addMemberWithNameTypeElements(name:String, type:Number,
			elements:NSArray):Void {
		m_members.setObjectForKey({type: type, elements: elements}, name);
		m_member.addItemWithObjectValue(name);
	}

	/**
	 * Registers the default members for the application.
	 */
	private function registerDefaultMembers():Void {
		addMemberWithNameTypeElements("ticketNumber", TYPE_NUMBER);
		addMemberWithNameTypeElements("status", TYPE_NUMBER,
			NSArray.arrayWithObjects(
				{display: "New", data: 1},
				{display: "Assigned", data: 2},
				{display: "Closed", data: 3})
			);
		addMemberWithNameTypeElements("type", TYPE_NUMBER,
			NSArray.arrayWithObjects(
				{display: "Defect", data: 1},
				{display: "Enhancement", data: 2},
				{display: "Task", data: 3})
			);
		addMemberWithNameTypeElements("priority", TYPE_NUMBER,
			NSArray.arrayWithObjects(
				{display: "Lowest", data: 1},
				{display: "Low", data: 2},
				{display: "Normal", data: 3},
				{display: "High", data: 4},
				{display: "Highest", data: 5})
			);
		addMemberWithNameTypeElements("severity", TYPE_NUMBER,
			NSArray.arrayWithObjects(
				{display: "Trivial", data: 1},
				{display: "Minor", data: 2},
				{display: "Normal", data: 3},
				{display: "Major", data: 4},
				{display: "Critical", data: 5},
				{display: "Blocker", data: 6})
			);
		addMemberWithNameTypeElements("reportedBy", TYPE_STRING);
		addMemberWithNameTypeElements("assignedTo", TYPE_STRING);
	}
}