/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.constants.NSCellType;
import org.actionstep.NSArray;
import org.actionstep.NSButton;
import org.actionstep.NSButtonCell;
import org.actionstep.NSCell;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSMenu;
import org.actionstep.NSMenuItem;
import org.actionstep.NSNotification;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSToolbar;
import org.actionstep.NSToolbarItem;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASThemeImageNames;
import org.actionstep.toolbar.items.ASToolbarItemBackViewProtocol;
import org.actionstep.themes.ASTheme;

/**
 * Displays a button that when pressed displays a menu of all clipped toolbar
 * items with menu representations.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.toolbar.ASToolbarOverflowButton 
		extends NSButton implements ASToolbarItemBackViewProtocol {
	
	//******************************************************
	//*                   Members
	//******************************************************
	
	private static var g_cellClass:Function = org.actionstep.NSButtonCell;
	
	private var m_toolbar:NSToolbar;
	private var m_toolbarItem:NSToolbarItem;
	
	//******************************************************
	//*                 Construction
	//******************************************************
	
	/**
	 * Initializes the overflow button.
	 */
	public function init():ASToolbarOverflowButton {
		//
		// Get image and build rect
		//
		var img:NSImage = NSImage.imageNamed(ASThemeImageNames.NSToolbarOverflowImage);
		var rect:NSRect = new NSRect(0, 0, img.size().width, 50);
		
		//
		// Initialize
		//
		super.initWithFrame(rect);
		
		//
		// Set properties
		//
		setBordered(false);
		cell().setBezeled(false);
		NSButtonCell(cell()).setHighlightsBy(
			NSCell.NSChangeGrayCellMask | NSCell.NSChangeBackgroundCellMask);
		img.setScalesWhenResized(true);
		setImage(img);
		setImagePosition(NSCellImagePosition.NSImageOnly);
		
		//
		// Build item
		//
		m_toolbarItem = (new NSToolbarItem());
		m_toolbarItem["constructBackView"] = null;
		m_toolbarItem.initWithItemIdentifier(NSToolbarItem.ASToolbarOverflowItemIdentifier);
		m_toolbarItem["m_backView"] = this;
		
		return this;
	}
	
	//******************************************************
	//*             Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the ASToolbarOverflowButton instance.
	 */
	public function description():String {
		return "ASToolbarOverflowButton()";
	}
	
	//******************************************************
	//*              Setting the toolbar
	//******************************************************
	
	/**
	 * Sets the overflow button's toolbar.
	 */
	public function setToolbar(bar:NSToolbar):Void {
		m_toolbar = bar;
		m_toolbarItem.__setToolbar(m_toolbar);
	}
	
	//******************************************************
	//*            Getting the overflow menu
	//******************************************************
	
	/**
	 * Returns the overflow menu containing all the clipped items from this
	 * button's toolbar.
	 */
	private function overflowMenu():NSMenu {
		var menu:NSMenu = (new NSMenu()).initWithTitle("");
		var menuItem:NSMenuItem;
		var visibleItems:NSArray = m_toolbar.visibleItems();
		var items:Array = m_toolbar.items().internalList();
		var item:NSToolbarItem;
		var len:Number = items.length;
		
		//
		// Add all invisible items with menu representations
		//
		for (var i:Number = 0; i < len; i++) {
			if (visibleItems.containsObject(items[i])) {
				continue;
			}
			
			item = NSToolbarItem(items[i]);
			menuItem = item.menuFormRepresentation();
			if (menuItem == null) {
				menuItem = item.__defaultMenuFormRepresentation();
			} 
			
			if (menuItem != null) {
				menu.addItem(menuItem);
			}
		}
		
		//
		// Add events
		//
		m_notificationCenter.addObserverSelectorNameObject(
			this, "menuDidEndTracking",
			NSMenu.NSMenuDidEndTrackingNotification,
			menu);
		
		return menu;
	}
	
	//******************************************************
	//*                    Events
	//******************************************************
	
	/**
	 * Shows the overflow menu on a left click
	 */
	public function mouseDown(event:NSEvent):Void {
		var m:NSMenu = menuForEvent(event);
		
		if (m != null) {
			//
			// Display the menu
			//
			var w:NSWindow = m.window();
			m.display();
			
			//
			// Position menu window
			//
			var btnFrm:NSRect = bounds();
			var menuOrigin:NSPoint = new NSPoint(btnFrm.maxX(), btnFrm.origin.y);
			menuOrigin = convertPointToView(menuOrigin, null);
		
			var wndFrm:NSRect = w.frame();
			wndFrm.origin = menuOrigin;
			if (wndFrm.maxX() > Stage.width) {
				wndFrm.origin.x = Stage.width - wndFrm.size.width - 10;
			}
		
			w.setFrameOrigin(wndFrm.origin);
		
			//
			// Begin mouse tracking
			//
			var origType:Number = event.type;
			event.type = NSEvent.NSMouseMoved;
			m.menuRepresentation().mouseDown(event);
			event.type = origType;
		}
	}
	
	/**
	 * Invoked when the menu finishes tracking
	 */
	private function menuDidEndTracking(ntf:NSNotification):Void {
		var m:NSMenu = NSMenu(ntf.object);
		m.window().hide();
		m_notificationCenter.removeObserverNameObject(this,
			NSMenu.NSMenuDidEndTrackingNotification, m);
	}
	
	/**
	 * Returns the overflow menu on a left click
	 */
	public function menuForEvent(event:NSEvent):NSMenu {
		if (event.type == NSEvent.NSLeftMouseDown) {
			return overflowMenu();
		}
		
		return null;
	}
	
	//******************************************************
	//*             Backview implementation
	//******************************************************
	
	/**
	 * Does nothing.
	 */
	public function layout():Void {
		var h:Number = ASTheme.current().toolbarHeightForToolbar(m_toolbar);
		setFrameHeight(h);
	}

	/**
	 * Returns null.
	 */
	public function toolbarItem():NSToolbarItem {
		return m_toolbarItem;
	}
	
	//******************************************************
	//*              Required by NSControl
	//******************************************************
	
	public static function cellClass():Function {
		return g_cellClass;
	}
}