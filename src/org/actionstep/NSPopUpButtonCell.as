/* See LICENSE for copyright and terms of use */

import org.actionstep.menu.NSMenuItemCell;
import org.actionstep.NSMenu;
import org.actionstep.constants.NSRectEdge;
import org.actionstep.constants.NSPopUpArrowPosition;
import org.actionstep.NSArray;
import org.actionstep.NSMenuItem;
import org.actionstep.NSCell;
import org.actionstep.NSControl;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.NSNotificationCenter;
import org.actionstep.menu.NSMenuView;
import org.actionstep.NSWindow;
import org.actionstep.ASUtils;
import org.actionstep.NSPopUpButton;
import org.actionstep.NSButtonCell;
import org.actionstep.NSCopying;
import org.actionstep.NSNumber;
import org.actionstep.NSObject;
import org.actionstep.NSImage;
import org.actionstep.NSNotification;
import org.actionstep.NSEvent;
import org.actionstep.NSPoint;

class org.actionstep.NSPopUpButtonCell extends NSMenuItemCell {

	//******************************************************
	//*                  Notifications
	//******************************************************

	public static var NSPopUpButtonCellWillPopUpNotification:Number = ASUtils.intern("NSPopUpButtonCellWillPopUpNotification");

	//******************************************************
	//*                 Class members
	//******************************************************

	private static var g_popup_upCell:NSButtonCell;
	private static var g_popup_downCell:NSButtonCell;
	//private static var g_pulldown_

	//******************************************************
	//*                 Member variables
	//******************************************************

	private var m_menu:NSMenu;
	private var m_selectedItem:NSMenuItem;
	private var m_arrowPosition:NSPopUpArrowPosition;

	private var m_popUpImage:NSImage;
	private var m_pullDownImage:NSImage;

	// Flags
	private var m_pullsDown:Boolean;
	private var m_autoenablesItems:Boolean;
	private var m_preferredEdge:NSRectEdge;
	private var m_usesItemFromMenu:Boolean;
	private var m_altersStateOfSelectedItem:Boolean;

	//******************************************************
	//*                  Construction
	//******************************************************

	public function init():NSPopUpButtonCell {
		return initTextCellPullsDown("", false);
	}

	public function initTextCellPullsDown(itemName:String, f:Boolean):NSPopUpButtonCell {
		super.initTextCell(itemName);
		setPullsDown(f);
		setMenu((new NSMenu()).initWithTitle(""));
		setUsesItemFromMenu(true);

		if(itemName!="") {
			addItemWithTitle(itemName);
		}

		return this;
	}

	//******************************************************
	//*                  Adding Items
	//******************************************************

	public function addItemWithTitle(name:String):Void {
		insertItemWithTitleAtIndex(name, m_menu.numberOfItems());
	}

	public function addItemsWithTitles(arr:NSArray):Void {
		var i:Number = arr.count();
		while(i--) {
			addItemWithTitle(String(arr.objectAtIndex(i)));
		}
	}

	public function insertItemWithTitleAtIndex(title:String, n:Number):Void {
		var i:Number = indexOfItemWithTitle(title);
		if(i!=-1) {
			removeItemAtIndex(i);
		}

		var count:Number = m_menu.numberOfItems();

		if(n<0) {
			n = 0;
		}
		if(n>count) {
			n = count;
		}

		var anItem:NSMenuItem = m_menu.addItemWithTitleActionKeyEquivalent
		(title, null, "", n);

		anItem.setOnStateImage(null);
		anItem.setOffStateImage(null);
		anItem.setMixedStateImage(null);
	}

	//******************************************************
	//*                  Removing Items
	//******************************************************

	public function removeAllItems():Void {
		selectItem(null);
		var i:Number = numberOfItems();
		while(i--) {
			m_menu.removeItemAtIndex(i);
		}
	}

	public function removeItemAtIndex(i:Number):Void {
		if(i==indexOfSelectedItem()) {
			selectItem(null);
		}
		m_menu.removeItemAtIndex(i);
	}

	public function removeItemWithTitle(title:String):Void {
		removeItemAtIndex(indexOfItemWithTitle(title));
	}

	//******************************************************
	//*                  Selecting Items
	//******************************************************

	public function selectedItem():NSMenuItem {
		return m_selectedItem;
	}

	public function selectItem(item:NSMenuItem):Void {
		if(item==m_selectedItem) {
			return;
		}

		if(m_selectedItem!=null && altersStateOfSelectedItem()) {
			m_selectedItem.setState(NSCell.NSOffState);
		}

		m_selectedItem = item;

		if(m_selectedItem!=null) {
			if(altersStateOfSelectedItem()) {
				m_selectedItem.setState(NSCell.NSOnState);
			}
			m_menu.menuRepresentation().setHighlightedItemIndex(m_menu.indexOfItem(item));
		}
	}

	public function selectItemAtIndex(n:Number):Void {
		selectItem(m_menu.itemAtIndex(n));
	}

	public function selectItemWithTag(n:Number):Void {
		selectItem(m_menu.itemWithTag(n));
	}

	public function selectItemWithTitle(title:String):Void {
		selectItem(m_menu.itemWithTitle(title));
	}

	public function titleOfSelectedItem():String {
		return m_selectedItem.title();
	}

	//******************************************************
	//*                  Retrieving Menu Items
	//******************************************************

	public function itemAtIndex(n:Number):NSMenuItem {
		return m_menu.itemAtIndex(n);
	}

	public function indexOfItem(item:NSMenuItem):Number {
		return m_menu.indexOfItem(item);
	}

	public function indexOfItemWithRepresentedObject(obj:Object):Number {
		return m_menu.indexOfItemWithRepresentedObject(obj);
	}

	public function indexOfItemWithTag(tag:Number):Number {
		return m_menu.indexOfItemWithTag(tag);
	}

	public function indexOfItemWithTargetAndAction
	(target:Object, action:String):Number {
		return m_menu.indexOfItemWithTargetAndAction(target, action);
	}

	public function indexOfItemWithTitle(title:String):Number {
		return m_menu.indexOfItemWithTitle(title);
	}

	public function indexOfSelectedItem():Number {
		return m_menu.indexOfItem(m_selectedItem);
	}

	public function itemTitleAtIndex(n:Number):String {
		return itemAtIndex(n).title();
	}

	public function itemTitles():NSArray {
		var x:Number = m_menu.numberOfItems();
		var items:NSArray = m_menu.itemArray();
		while(x--) {
			items.replaceObjectAtIndexWithObject(x, items.objectAtIndex(x).title());
		}

		return items;
	}

	public function itemWithTitle(title:String):NSMenuItem {
		return m_menu.itemWithTitle(title);
	}

	public function lastItem():NSMenuItem {
		return m_menu.itemAtIndex(m_menu.numberOfItems()-1);
	}

	//******************************************************
	//*                  Setting/getting Cell Attributes
	//******************************************************

	public function setMenu(menu:NSMenu):Void {
		if(m_menu == menu) {
			return;
		}
		m_menu.__setOwnedByPopUp(null);
		m_menu = menu;
		if(menu!=null) {
			menu.__setOwnedByPopUp(this);
			setMenuView(menu.menuRepresentation());
		} else {
			setMenuView(null);
		}
	}

	public function menu ():NSMenu {
		return m_menu;
	}

	public function setMenuItem(item:NSMenuItem):Void {
		var img:NSImage;
		if(item == m_menuItem) {
			return;
		}
		if(m_arrowPosition == NSPopUpArrowPosition.NSPopUpArrowAtBottom) {
			img = m_pullDownImage;
		} else if(m_arrowPosition == NSPopUpArrowPosition.NSPopUpArrowAtCenter) {
			img = m_popUpImage;
		} else {
			img = null;
		}
		if(m_menuItem.image() == img) {
			m_menuItem.setImage(null);
		}
		super.setMenuItem(item);
		if(m_menuItem.image() == null) {
			m_menuItem.setImage(img);
		}
	}

	public function setTitle(aString:String):Void{
		var item:NSMenuItem;
		if(m_pullsDown) {
			if(m_menu.numberOfItems()==0) {
				item = null;
			} else {
				item = m_menu.itemAtIndex(0);
			}
		} else {
			item = m_menu.itemAtIndex(0);
			if(item == null) {
				addItemWithTitle(aString);
				item = m_menu.itemWithTitle(aString);
			}
		}
		selectItem(item);
	}

	public function setPullsDown(f:Boolean):Void {
		// store item temporarily
  	var item:NSMenuItem = m_menuItem;
  	setMenuItem(null);
		m_pullsDown = f;
		setAltersStateOfSelectedItem(!f);

		if(!f) {
			// pop up
			setArrowPosition(NSPopUpArrowPosition.NSPopUpArrowAtCenter);
			setPreferredEdge(NSRectEdge.NSMinYEdge);
		} else {
			// pull down
			setArrowPosition(NSPopUpArrowPosition.NSPopUpArrowAtBottom);
			setPreferredEdge(NSRectEdge.NSMaxYEdge);
		}

		setMenuItem(item);
	}

	public function pullsDown():Boolean {
		return m_pullsDown;
	}

	public function setAutoenablesItems(f:Boolean):Void {
		m_autoenablesItems = f;
	}

	public function autoenablesItems():Boolean {
		return m_autoenablesItems;
	}

	public function setUsesItemFromMenu(f:Boolean):Void {
		m_usesItemFromMenu = f;
	}

	public function usesItemFromMenu():Boolean {
		return m_usesItemFromMenu;
	}

	public function setAltersStateOfSelectedItem(f:Boolean):Void {
		var item:NSMenuItem = selectedItem();
		if(f) {
			item.setState(NSOffState);
		} else {
			item.setState(NSOnState);
		}
		m_altersStateOfSelectedItem = f;
	}

	public function altersStateOfSelectedItem():Boolean {
		return m_altersStateOfSelectedItem;
	}

	public function setPreferredEdge(f:NSRectEdge):Void {
		m_preferredEdge = f;
	}

	public function preferredEdge():NSRectEdge {
		return m_preferredEdge;
	}

	public function setArrowPosition(f:NSPopUpArrowPosition):Void {
		m_arrowPosition = f;
	}

	public function arrowPosition():NSPopUpArrowPosition {
		return m_arrowPosition;
	}

	public function itemArray():NSArray {
		return m_menu.itemArray();
	}

	public function numberOfItems():Number {
		return m_menu.numberOfItems();
	}

	/**
	 * Attempts to select the item at an index of <code>object</code> if the receiver responds to
	 * <code>intValue</code> and <code>object</code> is a valid index. Otherwise, the selected
	 * item is cleared.
	 */
	public function setObjectValue(obj:NSObject):Void {
    if(obj.respondsToSelector("intValue")) {
    	var int:Number = obj["intValue"]();
    	selectItemAtIndex(int);
    }
	}

	public function objectValue():NSCopying {
		return NSNumber.numberWithInt(indexOfSelectedItem());
	}

	//******************************************************
	//*                  Synchronizing with NSMenuItem Instances
	//******************************************************

	public function synchronizeTitleAndSelectedItem():Void {
		var index:Number;

		if(!m_usesItemFromMenu) {
			return;
		}
		if(m_menu.numberOfItems() == 0) {
			index = -1;
		} else if (m_pullsDown) {
			index = 0;
		} else {
			index = m_menu.menuRepresentation().highlightedItemIndex();

			if(index<0) {
				index = indexOfSelectedItem();
				index = (index<0) ? 0 : index;
			}
		}

		if((index >=0) && (m_menu.numberOfItems() > index)) {
			setMenuItem(m_menu.itemAtIndex(index));
		} else {
			setMenuItem(null);
		}

		if(m_controlView!=null && (m_controlView instanceof NSControl)) {
			NSControl(m_controlView).updateCell();
		}
	}

	//******************************************************
	//*                  Handling Event and Action Messages
	//******************************************************

	public function attachPopUpWithFrameInView
	(cellFrame:NSRect, view:NSView):Void {
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		var win:NSWindow = m_controlView.window();
		var mv:NSMenuView = m_menu.menuRepresentation();
		var index:Number;

		nc.postNotificationWithNameObject(NSPopUpButtonCellWillPopUpNotification, this);

		nc.postNotificationWithNameObject(NSPopUpButton.NSPopUpButtonWillPopUpNotification,m_controlView);

		cellFrame = m_controlView.convertRectToView(cellFrame);
		cellFrame.origin = win.convertBaseToScreen(cellFrame.origin);

		if(m_pullsDown) {
			index = -1;
		} else {
			index = indexOfSelectedItem();
		}

		if(index>0) {
			mv.setHighlightedItemIndex(index);
		}

		mv.
		setWindowFrameForAttachingToRectOnScreenPreferredEdgePopUpSelectedItem
		(cellFrame, /*TODO what screen! ?*/ m_preferredEdge, index);

		mv.window().orderFrontRegardless();

		nc.addObserverSelectorNameObject
		(this, "notificationHandler", NSMenu.NSMenuDidSendActionNotification, m_menu);
	}

	public function dismissPopUp():Void {
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();

		nc.removeObserverNameObject(this, NSMenu.NSMenuDidSendActionNotification, m_menu);
		m_menu.close();
	}

	private function notificationHandler(n:NSNotification):Void {
		if(n.name == NSMenu.NSMenuDidSendActionNotification) {
			dismissPopUp();
			synchronizeTitleAndSelectedItem();
		}
	}

	public function performClickWithFrameInView(frame:NSRect, view:NSView):Void {
		super.performClickWithFrameInView(frame, view);
		attachPopUpWithFrameInView(frame, view);
	}

	public function trackMouseInRectOfViewUntilMouseUp(event:NSEvent, rect:NSRect,
		view:NSView, untilMouseUp:Boolean):Void {
		var mv:NSMenuView = m_menu.menuRepresentation();
		var wnd:NSWindow = mv.window();
		var p:NSPoint;

		if(!isEnabled()) {
			return;
		}
		if(m_menu.numberOfItems()==0) {
			//! beep
			return;
		}
		// attach this pop up
		attachPopUpWithFrameInView(rect, view);

		p = view.window().convertBaseToScreen(event.locationInWindow);
		p = wnd.convertScreenToBase(p);

		var e:NSEvent = NSEvent(event.copy());
		e.locationInWindow = p;
		e.windowNumber = wnd.windowNumber();
		m_app.sendEvent(e);

		if(m_menu.window().isVisible) {
			dismissPopUp();
		}
	}

	//******************************************************
	//*                  Drawing
	//******************************************************

//	private function drawParts():Void {
//		if (g_upCell != null) {
//			return;
//		}
//		g_upCell = new NSButtonCell();
//		g_upCell.setHighlightsBy(NSCell.NSChangeBackgroundCellMask | NSCell.NSContentsCellMask);
//		g_upCell.setImage(NSImage.imageNamed("NSStepperUpArrow"));
//		g_upCell.setAlternateImage(NSImage.imageNamed("NSHighlightedStepperUpArrow"));
//		g_upCell.setImagePosition(NSCellImagePosition.NSImageOnly);
//		g_upCell.setTrackingCallbackSelector(this, "trackButton");
//
//		g_downCell = new NSButtonCell();
//		g_downCell.setHighlightsBy(NSCell.NSChangeBackgroundCellMask | NSCell.NSContentsCellMask);
//		g_downCell.setImage(NSImage.imageNamed("NSStepperDownArrow"));
//		g_downCell.setAlternateImage(NSImage.imageNamed("NSHighlightedStepperDownArrow"));
//		g_downCell.setImagePosition(NSCellImagePosition.NSImageOnly);
//		g_downCell.setTrackingCallbackSelector(this, "trackButton");
//	}
}
