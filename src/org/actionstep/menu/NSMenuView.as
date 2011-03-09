/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSRectEdge;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.menu.NSMenuItemCell;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSEvent;
import org.actionstep.NSFont;
import org.actionstep.NSMenu;
import org.actionstep.NSMenuItem;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeProtocol;

/**
 * <p>
 * This class is used internally by <code>NSMenu</code> to handle its display.
 * </p>
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.menu.NSMenuView extends NSView {
	private static var g_ht:Number;

	//******************************************************
	//*                   Class members
	//******************************************************

	/**
	 * <p>
	 * Defines the bounds which will constrain the entire menu system. The
	 * default dimensions are the <code>Stage</code> dimensions.
	 * </p>
	 * <p>
	 * <code>NSSize</code> instead of <code>NSRect</code> is used, since
	 * co-ordinates are calculated relative to the root menu view.
	 * </p>
	 * <p>
	 * Please note that this value is updated when the stage is resized.
	 * </p>
	 */
	private static var g_bounds:NSSize = new NSSize(Stage.width, Stage.height);

	//******************************************************
	//*                     Members
	//******************************************************

	private var m_horizontal:Boolean;
	private var m_needsSizing:Boolean;

	private var m_highlightedItemIndex:Number;
	private var m_horizontalEdgePad:Number;
	private var m_stateImageOffset:Number;
	private var m_stateImageWidth:Number;

	private var m_imageOffset:Number;
	private var m_imageWidth:Number;
	private var m_titleWidth:Number;
	private var m_titleAndKeyEqOffset:Number;
	private var m_titleAndKeyEqWidth:Number;

	private var m_keyEqImgOffset:Number;
	private var m_keyEqImgWidth:Number;

	private var m_arrowOffset:Number;

	private var m_leftBorderOffset:Number;

	private var m_menu:NSMenu;
	private var m_font:NSFont;
	private var m_itemsLink:NSArray;
	private var m_itemCells:NSArray;
	private var m_cellSize:NSSize;

	private var m_trackingData:Object;
	private var m_app:NSApplication;

	//******************************************************
	//*                  Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>NSMenuView</code> class.
	 */
	public function NSMenuView() {
		super();
	}

	/**
	 * Initializes the menu view with a frame of <code>aFrame</code>.
	 */
	public function initWithFrame(aFrame:NSRect):NSMenuView {
		super.initWithFrame(aFrame);

		//
		// Set up a few variables
		//
		m_app = NSApplication.sharedApplication();
		m_highlightedItemIndex = -1;
		m_horizontalEdgePad = 4.;
		setFont(ASTheme.current().menuFontOfSize(0));

		//
		// Set the necessary offset for the menuView. That is, how many pixels
		// do we need for our left side border line.
		//
		m_leftBorderOffset = 1;

		//
		// Create an array to store our menu item cells.
		//
		m_itemCells = NSArray.array();

		return this;
	}

	//******************************************************
	//*         Releasing the object from memory
	//******************************************************

	/**
	 * Releases the menu view from memory.
	 */
	public function release():Boolean {
		// We must remove the menu view from the menu list of observers.
		if (m_menu != null) {
			NSNotificationCenter.defaultCenter().
			removeObserverNameObject(this, null, m_menu);
		}

		// Clean the pointer to us stored into the m_itemCells.
		m_itemCells.makeObjectsPerformSelectorWithObject("setMenuView", null);

		return super.release();
	}

	//******************************************************
	//*             Describing the object
	//******************************************************

	/**
	 * Returns a string representation of the menu view.
	 */
	public function description():String {
		return "NSMenuView(" + m_menu.title() + ")";
	}

	//******************************************************
	//*      Getting and setting menu view attributes
	//******************************************************

	/**
	 * Returns the height of the menu bar.
	 */
	public static function menuBarHeight():Number {
		if(g_ht==null) {
			g_ht = 0;
		}
		if (g_ht == 0) {
			var font:NSFont = ASTheme.current().menuBarFontOfSize(0);

			g_ht = font.getTextExtent("NSMVp").height + 8;
			if (g_ht < 23) { // Should make up 23 for the default font
				g_ht = 23;
			}
		}

		return g_ht;
	}

	/**
	 * <p>
	 * Sets the menu to be displayed in the receiver.
	 * </p>
	 * <p>
	 * This method invokes the {@link #setNeedsSizing()} method to force the
	 * menu view’s layout to be recalculated before drawing.
	 * </p>
	 * <p>
	 * This method adds the menu view to the new NSMenu object’s list of
	 * observers. The notifications this method establishes notify this menu
	 * view when menu items in the NSMenu object are added, removed, or changed.
	 * This method removes the menu view from its previous NSMenu object’s list
	 * of observers.
	 * </p>
	 *
	 * @see #setNeedsSizing()
	 * @see #itemAdded()
	 * @see #itemRemoved()
	 * @see #itemChanged()
	 */
	public function setMenu(menu:NSMenu):Void {
		var nc:NSNotificationCenter = m_notificationCenter;

		//
		// Remove this menu view from the old menu list of observers.
		//
		if (m_menu != null) {
			nc.removeObserverNameObject(this, null, m_menu);
		}

		m_menu = menu;
		m_itemsLink = m_menu.itemArray();

		//
		// Add this menu view to the menu's list of observers.
		//
		if (m_menu != null) {
			nc.addObserverSelectorNameObject(
				this, "itemChanged",
				NSMenu.NSMenuDidChangeItemNotification, m_menu);

			nc.addObserverSelectorNameObject(
				this, "itemAdded",
				NSMenu.NSMenuDidAddItemNotification, m_menu);

			nc.addObserverSelectorNameObject(
				this, "itemRemoved",
				NSMenu.NSMenuDidRemoveItemNotification, m_menu);
		}

		//
		// Force menu view's layout to be recalculated.
		//
		setNeedsSizing(true);

		update();
	}

	/**
	 * Returns the menu object associated with this menu view.
	 *
	 * @see #setMenu()
	 */
	public function menu():NSMenu {
		return m_menu;
	}

	/**
	 * <p>
	 * Sets the orientation of the menu.
	 * </p>
	 * <p>
	 * If <code>flag</code> is <code>true</code>, the menu’s items are displayed
	 * horizontally; otherwise the menu’s items are displayed vertically.
	 * </p>
	 *
	 * @see #isHorizontal()
	 */
	public function setHorizontal(flag:Boolean):Void {
		m_horizontal = flag;
	}

	/**
	 * <p>
	 * Returns <code>true</code> if this menu is horizontal (like a menu bar)
	 * or <code>false</code> otherwise.
	 * </p>
	 *
	 * @see #setHorizontal()
	 */
	public function isHorizontal():Boolean {
		return m_horizontal;
	}

	/**
	 * Sets the default font to use when drawing the menu text.
	 *
	 * @see #font()
	 */
	public function setFont(font:NSFont):Void {
		m_font = font;
		if (m_font != null) {
			var r:NSSize = m_font.getTextExtent("Hi");

			m_cellSize = r; //new NSSize(r.width * 10, r.height + 6);

			if (m_cellSize.height < 20) {
				m_cellSize.height = 20;
			}

			setNeedsSizing(true);
		} else {
			if (m_menu.isRoot() && isHorizontal()) { // menu bar
				font = NSFont.menuBarFontOfSize(0);
			} else {
				font = NSFont.menuFontOfSize(0);
			}
		}

		m_itemCells.makeObjectsPerformSelectorWithObject("setFont", font);
	}

	/**
	 * <p>Returns the default font used to draw the menu text.</p>
	 * <p>
	 * New items use this font by default, although the item’s menu item cell
	 * can use a different font.
	 * </p>
	 *
	 * @see #setFont()
	 */
	public function font():NSFont {
		return m_font;
	}

	/**
	 * <p>
	 * Highlights the menu item at a specific location.
	 * </p>
	 * <p>
	 * Specify –1 for <code>index</code> to remove all highlighting from the
	 * menu.
	 * </p>
	 *
	 * @see #setNeedsDisplayForItemAtIndex()
	 * @see #highlightedItemIndex()
	 */
	public function setHighlightedItemIndex(index:Number):Void {
		var aCell:NSMenuItemCell;

		if (index == m_highlightedItemIndex) {
			return;
		}

		//
		// Unhighlight old
		//
		if (m_highlightedItemIndex != -1) {
			aCell = NSMenuItemCell(m_itemCells.objectAtIndex(m_highlightedItemIndex));
			aCell.setHighlighted(false);
			setNeedsDisplayForItemAtIndex(m_highlightedItemIndex);
		}

		m_highlightedItemIndex = index;

		//
		// Highlight new
		//
		if (m_highlightedItemIndex != -1) {
			aCell = NSMenuItemCell(m_itemCells.objectAtIndex(m_highlightedItemIndex));
			aCell.setHighlighted(true);
			setNeedsDisplayForItemAtIndex(m_highlightedItemIndex);
		}
	}

	/**
	 * <p>
	 * Returns the index of the currently highlighted menu item, or –1 if no
	 * menu item in the menu is highlighted.
	 * </p>
	 *
	 * @see #setHighlightedItemIndex()
	 */
	public function highlightedItemIndex():Number {
		return m_highlightedItemIndex;
	}

	/**
	 * <p>
	 * Replaces the menu item cell at a specific location.
	 * </p>
	 * <p>
	 * This method does not change the contents of the menu itself; it changes
	 * only the cell used to display the menu item at <code>index</code>. Both
	 * the new cell and the menu view are marked as needing resizing.
	 * </p>
	 *
	 * @see #menuItemCellForItemAtIndex()
	 * @see #setNeedsSizing()
	 */
	public function setMenuItemCellForItemAtIndex(cell:NSMenuItemCell,
			index:Number):Void {
		//
		// Replace the old menu item cell
		//
		var anItem:NSMenuItem = NSMenuItem(m_itemsLink.objectAtIndex(index));
		m_itemCells.replaceObjectAtIndexWithObject(index, cell);
		cell.setMenuItem(anItem);
		cell.setMenuView(this);

		//
		// Highlight the new cell if the item should be highlighted
		//
		if (highlightedItemIndex() == index) {
			cell.setHighlighted(true);
		} else {
			cell.setHighlighted(false);
		}

		//
		// Mark the new cell and the menu view as needing resizing.
		//
		cell.setNeedsSizing(true);
		setNeedsSizing(true);
	}

	/**
	 * <p>Returns the menu item cell at the specified location.</p>
	 *
	 * @see #setMenuItemCellForItemAtIndex()
	 * @see #sizeToFit()
	 */
	public function menuItemCellForItemAtIndex(index:Number):NSMenuItemCell {
		return NSMenuItemCell(m_itemCells.objectAtIndex(index));
	}

	/**
	 * <p>
	 * Returns the menu view associated with the currently visible submenu,
	 * if any.
	 * </p>
	 *
	 * @see #attachedMenu()
	 * @see #detachSubmenu()
	 * @see #isAttached()
	 */
	public function attachedMenuView():NSMenuView {
		return m_menu.attachedMenu().menuRepresentation();
	}

	/**
	 * <p>
	 * Returns the menu object associated with this object’s attached menu view.
	 * </p>
	 * <p>
	 * The attached menu view is the one associated with the currently visible
	 * submenu, if any.
	 * </p>
	 *
	 * @see #attachedMenuView()
	 * @see #isAttached()
	 */
	public function attachedMenu():NSMenu {
		return m_menu.attachedMenu();
	}

	/**
	 * Returns <code>true</code> if this menu is currently attached to its
	 * parent menu, <code>false</code> otherwise.
	 */
	public function isAttached():Boolean {
		return m_menu.isAttached();
	}

	/**
	 * <p>
	 * Returns the amount of horizontal space used for padding menu item
	 * components.
	 * </p>
	 * <p>
	 * The edge padding is added to the sides of each menu item component. This
	 * space is used to provide a visual separation between components of the
	 * menu item.
	 * </p>
	 *
	 * @see #setHorizontalEdgePadding()
	 */
	public function horizontalEdgePadding():Number {
		return m_horizontalEdgePad;
	}

	/**
	 * <p>Sets the horizontal padding for menu item components.</p>
	 *
	 * @see #horizontalEdgePadding()
	 */
	public function setHorizontalEdgePadding(pad:Number):Void {
		m_horizontalEdgePad = pad;
		setNeedsSizing(true);
	}

	//******************************************************
	//*              Notification methods
	//******************************************************

	/**
	 * <p>
	 * Marks the menu view as needing to be resized so changes in size resulting
	 * from a change in the menu will be tracked.
	 * </p>
	 * <p>
	 * This method is registered with the menu view’s associated NSMenu object
	 * for notifications of the type
	 * {@link NSMenu#NSMenuDidChangeItemNotification}. The notification
	 * parameter contains the notification data.
	 * </p>
	 *
	 * @see #setNeedsSizing()
	 */
	public function itemChanged(notification:NSNotification):Void {
		var index:Number = Number(notification.userInfo.objectForKey(
			"NSMenuItemIndex"));
		var aCell:NSMenuItemCell = NSMenuItemCell(m_itemCells.objectAtIndex(index));

		//
		// Enabling of the item may have changed
		//
		aCell.setEnabled(aCell.menuItem().isEnabled());

		//
		// Mark the cell associated with the item as needing resizing.
		//
		aCell.setNeedsSizing(true);
		setNeedsDisplayForItemAtIndex(index);

		//
		// Mark the menu view as needing to be resized.
		//
		setNeedsSizing(true);
	}

	/**
	 * <p>
	 * Creates a new menu item cell for the newly created item and marks the
	 * menu view as needing to be resized.
	 * </p>
	 * <p>
	 * This method is registered with the menu view’s associated NSMenu object
	 * for notifications of the type
	 * {@link NSMenu#NSMenuDidAddItemNotification}. The notification
	 * parameter contains the notification data.
	 * </p>
	 *
	 * @see #setNeedsSizing()
	 */
	public function itemAdded(notification:NSNotification):Void {
		var index:Number = Number(notification.userInfo.objectForKey(
			"NSMenuItemIndex"));
		var anItem:NSMenuItem = NSMenuItem(m_itemsLink.objectAtIndex(index));
		var aCell:NSMenuItemCell = (new NSMenuItemCell()).init();
		var wasHighlighted:Number = m_highlightedItemIndex;

		aCell.setMenuItem(anItem);
		aCell.setMenuView(this);
		aCell.setFont(m_font);

		//
		// Unlight the previous highlighted cell if the index of the highlighted
		// cell will be ruined up by the insertion of the new cell.
		//
		if (wasHighlighted >= index) {
			setHighlightedItemIndex(-1);
		}

		m_itemCells.insertObjectAtIndex(aCell, index);

		//
		// Restore the highlighted cell, with the new index for it.
		//
		if (wasHighlighted >= index) {
			//
			// Please note that if wasHighlighted == -1, it shouldn't be possible
			// to be here.
			//
			setHighlightedItemIndex(++wasHighlighted);
		}

		aCell.setNeedsSizing(true);

		//
		// Mark the menu view as needing to be resized.
		//
		setNeedsSizing(true);
	}

	/**
	 * <p>
	 * Removes the removed item’s menu item cell and marks the menu view as
	 * needing to be resized.
	 * </p>
	 * <p>
	 * This method is registered with the menu view’s associated NSMenu object
	 * for notifications of the type
	 * {@link NSMenu#NSMenuDidRemoveItemNotification}. The notification
	 * parameter contains the notification data.
	 * </p>
	 *
	 * @see #setNeedsSizing()
	 */
	public function itemRemoved(notification:NSNotification):Void {
		var wasHighlighted:Number = highlightedItemIndex();
		var index:Number = Number(notification.userInfo.objectForKey(
			"NSMenuItemIndex"));

		if (index <= wasHighlighted) {
			setHighlightedItemIndex(-1);
		}

		var cell:NSMenuItemCell = NSMenuItemCell(m_itemCells.objectAtIndex(index));
		cell.removeTextField();
		m_itemCells.removeObjectAtIndex(index);

		if (wasHighlighted > index) {
			setHighlightedItemIndex(--wasHighlighted);
		}

		//
		// Mark the menu view as needing to be resized.
		//
		setNeedsSizing(true);
	}

	//******************************************************
	//*             Working with submenus
	//******************************************************

	/**
	 * <p>
	 * Detaches the window associated with the currently visible submenu and
	 * removes any menu item highlights.
	 * </p>
	 * <p>
	 * If the submenu itself displays further submenus, this method detaches the windows
	 * associated with those submenus as well.
	 * </p>
	 * <p>
	 * In other words, recursively kill all attached submenus.
	 * </p>
	 */
	public function detachSubmenu():Void {
		var am:NSMenu = attachedMenu();
		var amv:NSMenuView;

		if (am==null) {
			return;
		}
		amv = attachedMenuView();

		amv.detachSubmenu();
		amv.setHighlightedItemIndex(-1);

		//trace(asDebug("detach submenu: "+am+" from: "+m_menu));

		menu()["setAttachedMenu"](null);
		am.close();
		amv.setHidden(true);
	}

	/**
	 * <p>
	 * Attaches the submenu associated with the menu item at <code>index</code>.
	 * </p>
	 * <p>
	 * This method prepares the submenu for display by positioning its window
	 * and ordering it to the front.
	 * </p>
	 *
	 * @see NSWindow#orderFront()
	 */
	public function attachSubmenuForItemAtIndex(index:Number):Void {
		/*
		 * Transient menus are used for torn-off menus, which are already on the
		 * screen and for sons of transient menus.	As transients disappear as
		 * soon as we release the mouse the user will be able to leave submenus
		 * open on the screen and interact with other menus at the same time.
		 */
		if (index < 0) {
			return;
		}

		var attachableMenu:NSMenu = m_itemsLink.objectAtIndex(index).submenu();

		if(attachableMenu!=null) {
			menu()["setAttachedMenu"](attachableMenu);
		}

		attachableMenu.display();
	}

	//******************************************************
	//*             Calculating Menu Geometry
	//******************************************************

	/**
	 * <p>Asks the associated menu object to update itself.</p>
	 *
	 * This method invokes {@link #sizeToFit()}.
	 *
	 * @see #sizeToFit()
	 * @see #setNeedsSizing()
	 * @see NSMenu#update()
	 */
	public function update():Void {
		//trace(asDebug("update called on menu view"));

		if (!m_menu.__ownedByPopUp()) {
			//! FIXME Add title view. If this menu not owned by popup
		}

		// Resize it anyway.
		sizeToFit();

		// Just quit here if we are a popup.
		if (m_menu.__ownedByPopUp()) {
			return;
		}
	}

	/**
	 * <p>
	 * Sets a flag that indicates whether the layout is invalid and needs
	 * resizing.
	 * </p>
	 * <p>
	 * If <code>flag</code> is <code>true</code>, the menu contents have changed
	 * or the menu appearance has changed. This method is used internally; you
	 * should not need to invoke it directly unless you are implementing a
	 * subclass that can cause the layout to become invalid.
	 * </p>
	 *
	 * @see #sizeToFit()
	 */
	public function setNeedsSizing(flag:Boolean):Void {
		m_needsSizing = flag;
	}

	/**
	 * <p>
	 * Returns whether the menu view needs to be resized.
	 * </p>
	 *
	 * @see #setNeedsSizing()
	 */
	public function needsSizing():Boolean {
		return m_needsSizing;
	}

	/**
	 * <p>
	 * Used internally by the menu view to cache information about the menu
	 * item geometry.
	 * </p>
	 * <p>
	 * This cache is updated as necessary when menu items are added, removed, or
	 * changed.
	 * </p>
	 * <p>
	 * The geometry of each menu item is determined by asking its corresponding
	 * menu item cell. The menu item cell is obtained from the
	 * {@link #menuItemCellForItemAtIndex()} method.
	 * </p>
	 *
	 * @see #setNeedsSizing()
	 * @see #menuItemCellForItemAtIndex()
	 */
	public function sizeToFit():Void {
		var length:Number = m_itemCells.count();
		var wideTitleView:Number = 1;
		var neededImageWidth:Number = 0;
		var neededTitleWidth:Number = 0;
		var neededKeyEqImgWidth:Number = 0;
		var neededKeyEqWidth:Number = 0;
		var neededStateImageWidth:Number = 0;
		var neededHeight:Number = 0;
		var accumulatedOffset:Number = 0;
		var popupImageWidth:Number = 0;
		var cellTabSpacing:Number = NSMenuItemCell.tabSpacing();

		var aStateImageWidth:Number;
		var anImageWidth:Number;
		var aTitleWidth:Number;
		var aKeyEqImgWidth:Number;
		var aKeyEqWidth:Number;
		var needsArrowFlag:Boolean = false;
		var aCell:NSMenuItemCell;

		for (var i:Number = 0; i < length; i++) {
			aCell = menuItemCellForItemAtIndex(i);
			aCell.calcSize();

			// State image area.
			aStateImageWidth = aCell.stateImageWidth();

			// Title and Image area.
			aTitleWidth = aCell.titleWidth();
			anImageWidth = aCell.imageWidth();

			// Key equivalent area.
			aKeyEqImgWidth = aCell.keyEquivalentImageWidth();
			aKeyEqWidth = aCell.keyEquivalentWidth();

			needsArrowFlag = aCell.menuItem().hasSubmenu() && !m_menu.isRoot()
				? true : needsArrowFlag;

			if (aStateImageWidth > neededStateImageWidth) {
				neededStateImageWidth = aStateImageWidth;
			}
			if (anImageWidth > neededImageWidth) {
				neededImageWidth = anImageWidth;
			}
			if (aTitleWidth > neededTitleWidth) {
				neededTitleWidth = aTitleWidth;
			}
			if (aKeyEqImgWidth > neededKeyEqImgWidth) {
				neededKeyEqImgWidth = aKeyEqImgWidth;
			}
			if (aKeyEqWidth > neededKeyEqWidth) {
				neededKeyEqWidth = aKeyEqWidth;
			}

			//
			// Get max height
			//
			if (aCell.menuItemHeight() > neededHeight) {
				neededHeight = aCell.menuItemHeight();
			}
		}

		//
		// Cache the needed widths.
		//
		m_imageWidth = neededImageWidth;
		m_titleWidth = neededTitleWidth;
		m_titleAndKeyEqWidth = neededTitleWidth + (neededKeyEqWidth > 0 ?
			cellTabSpacing + neededKeyEqWidth
				+ m_horizontalEdgePad + neededKeyEqImgWidth
			: 0);
		m_stateImageWidth = neededStateImageWidth;

		accumulatedOffset = m_horizontalEdgePad;

		if (length > 0) {
			//
			// Calculate the offsets and cache them.
			//
			if (neededStateImageWidth > 0) {
				m_stateImageOffset = accumulatedOffset;
				m_stateImageWidth = neededStateImageWidth;
				accumulatedOffset += neededStateImageWidth + m_horizontalEdgePad;
			} else {
			  m_stateImageOffset = 0;
			}

			if (neededImageWidth > 0) {
				m_imageOffset = accumulatedOffset;
				m_imageWidth = neededImageWidth;
				accumulatedOffset += neededImageWidth + m_horizontalEdgePad;
			} else {
				m_imageOffset = 0;
			}

			if (m_titleAndKeyEqWidth > 0) {
				m_titleAndKeyEqOffset = accumulatedOffset;
				accumulatedOffset += m_titleAndKeyEqWidth + m_horizontalEdgePad;
			} else {
				m_titleAndKeyEqOffset = 0;
			}

			if (neededKeyEqImgWidth > 0) {
				m_keyEqImgOffset = m_horizontalEdgePad + m_titleWidth
					+ cellTabSpacing;
				m_keyEqImgWidth = neededKeyEqImgWidth;
				// don't touch accumulatedOffset
			}

			if (needsArrowFlag) {
				m_arrowOffset = accumulatedOffset;
			}
		}

		//
		// Calculate frame size.
		//
		m_cellSize.width = accumulatedOffset + (needsArrowFlag ?
			NSMenuItemCell.arrowWidth() + m_horizontalEdgePad : 0);
		m_cellSize.height = neededHeight;

		var pad:Number = NSMenuItemCell.cellPadding();

		if (!m_horizontal) {
			setFrameSize(new NSSize(
				m_cellSize.width + m_leftBorderOffset +	pad * 2,
				length * m_cellSize.height + (length + 1) * pad));
		} else {
			var w:Number = pad;
			length = m_itemCells.count();
			var item:NSMenuItemCell;
			while(length--) {
				item = menuItemCellForItemAtIndex(length);
				w += item.cellWidth() + pad;
			}

			setFrameSize(new NSSize(
				w, m_cellSize.height + m_leftBorderOffset + pad * 2));
		}

		m_needsSizing = false;
	}

	/**
	 * <p>
	 * Returns the offset to the space reserved for state images of this menu.
	 * </p>
	 * <p>
	 * The offset is used for all menu items of the menu.
	 * </p>
	 * <p>
	 * If any changes have been made to the menu’s contents, this method invokes
	 * {@link #sizeToFit()} to update the menu view information.
	 * </p>
	 *
	 * @see #horizontalEdgePadding()
	 * @see #setHorizontalEdgePadding()
	 * @see #sizeToFit()
	 */
	public function stateImageOffset():Number {
		if (m_needsSizing) {
			sizeToFit();
		}
		return m_stateImageOffset;
	}

	/**
	 * <p>
	 * Returns the maximum width of the state images used by this menu.
	 * </p>
	 * <p>
	 * The width is used for all menu items of the menu.
	 * </p>
	 * <p>
	 * If any changes have been made to the menu’s contents, this method invokes
	 * {@link #sizeToFit()} to update the menu view information.
	 * </p>
	 *
	 * @see #sizeToFit()
	 */
	public function stateImageWidth():Number {
		if (m_needsSizing) {
			sizeToFit();
		}
		return m_stateImageWidth;
	}

	public function imageOffset():Number {
		if (m_needsSizing) {
			sizeToFit();
		}
		return m_imageOffset;
	}

	public function imageWidth():Number {
		if (m_needsSizing) {
			sizeToFit();
		}
		return m_imageWidth;
	}

	public function titleWidth():Number {
		if (m_needsSizing) {
			sizeToFit();
		}
		return m_titleWidth;
	}

	/**
	 * Returns the offset <em>relative</em> to the textfield. In other words,
	 * the origin of the textfield on the x-axis has not be factored in.
	 */
	public function keyEquivalentImageOffset():Number {
		if (m_needsSizing) {
			sizeToFit();
		}
		return m_keyEqImgOffset;
	}

	public function keyEquivalentImageWidth():Number {
		if (m_needsSizing) {
			sizeToFit();
		}
		return m_keyEqImgWidth;
	}

	public function titleAndKeyEquivalentOffset():Number {
		if (m_needsSizing) {
			sizeToFit();
		}
		return m_titleAndKeyEqOffset;
	}

	public function titleAndKeyEquivalentWidth():Number {
		if (m_needsSizing) {
			sizeToFit();
		}
		return m_titleAndKeyEqWidth;
	}

	public function submenuArrowOffset():Number {
		if (m_needsSizing) {
			sizeToFit();
		}
		return m_arrowOffset;
	}

	public function innerRect():NSRect {
		if (m_horizontal == false) {
			return new NSRect(m_bounds.origin.x + m_leftBorderOffset,
			m_bounds.origin.y,
			m_bounds.size.width - m_leftBorderOffset,
			m_bounds.size.height);
		} else {
			return new NSRect (m_bounds.origin.x,
			m_bounds.origin.y + m_leftBorderOffset,
			m_bounds.size.width,
			m_bounds.size.height - m_leftBorderOffset);
		}
	}

	public function rectOfItemAtIndex(index:Number):NSRect {
		var theRect:NSRect = NSRect.ZeroRect;
		var pad:Number = NSMenuItemCell.cellPadding();

		if (m_needsSizing == true) {
			sizeToFit();
		}

		/* Fiddle with the origin so that the item rect is shifted 1 pixel over
		 * so we do not draw on the heavy line at origin.x = 0.
		 */
		theRect.size = NSSize(m_cellSize.copy());

		if (m_horizontal == false) {
			theRect.origin.y = m_cellSize.height * index +
			pad * (index+1);
			theRect.origin.x = m_leftBorderOffset + pad;
		} else {
			theRect.origin.y = pad;
			var cell:NSMenuItemCell = NSMenuItemCell(
			m_itemCells.objectAtIndex(index));
			theRect.size.width = cell.cellWidth();
			theRect.origin.x = pad;
			for (var i : Number = 0; i < index; i++) {
				theRect.origin.x += NSMenuItemCell(m_itemCells.objectAtIndex(i)).
				cellWidth() + pad;
			}
		}

		addLeftBorderOffsetToRect(theRect);

		/* NOTE: This returns the correct NSRect for drawing cells, but nothing
		 * else (unless we are a popup). This rect will have to be modified for
		 * event calculation, etc..
		 */

		return theRect;
	}

	public function indexOfItemAtPoint(point:NSPoint):Number {
		var howMany:Number = m_itemCells.count();
		var i:Number;
		var aRect:NSRect;

		for (i = 0; i < howMany; i++) {
			aRect = paddedRectForIndex(i);

			if (aRect.pointInRect(point)) {
				return i;
			}
		}

		return -1;
	}

	public function setNeedsDisplayForItemAtIndex(index:Number):Void {
		var aRect:NSRect ;

		aRect = rectOfItemAtIndex(index);
		//! NSView.setNeedsDisplayInRect(aRect);
		setNeedsDisplay(true);
	}

	public function locationForSubmenu(aSubmenu:NSMenu ):NSPoint {
		var rect:NSRect = rectOfItemAtIndex(m_highlightedItemIndex);
		var pt:NSPoint = m_window.convertBaseToScreen(rect.origin);
		var frame:NSSize = aSubmenu.menuRepresentation().frame().size;
		var offset:Number = 0;
		var size:NSSize = g_bounds;//.subtractSize(new NSSize(pt.x, pt.y));

		if (m_needsSizing) {
			sizeToFit();
		}

		if(isHorizontal()==false) {
			pt.x += rect.size.width;
			pt.y -= NSMenuItemCell.cellPadding();
			if(pt.x + frame.width > size.width) {
				pt.x -= rect.size.width + frame.width - offset;
				if(pt.x<0) {
					//!TODO looks weird
					pt.x = size.width - frame.width - offset;
				}
			} else {
				pt.x -= offset;
			}
			if(pt.y + frame.height > size.height) {
				pt.y = size.height - frame.height;
			}
		} else {
			pt.y += rect.size.height + NSMenuItemCell.cellPadding();
			if(pt.x + frame.width > size.width) {
				pt.x = size.width - frame.width - offset;
			}
		}
		return pt;
	}

	public function resizeWindowWithMaxHeight(maxHeight:Number):Void {
		//! FIXME set the menuview's window to max height in order to keep on screen?
	}

	//no onScreen, preferredEdge: name unchanged for compatibility
	public function setWindowFrameForAttachingToRectOnScreenPreferredEdgePopUpSelectedItem(
			screenRect:NSRect, /*screen:NSScreen, */edge:NSRectEdge, selectedItemIndex:Number):Void {
		var r:NSRect;
		var cellFrame:NSRect;
		var screenFrame:NSRect;
		var items:Number = m_itemCells.count();

		// Convert the screen rect to our view
		cellFrame.size = screenRect.size;
		cellFrame.origin = m_window.convertScreenToBase(screenRect.origin);
		cellFrame = convertRectFromView(cellFrame, null);

		// Only call update if needed.
		if ((m_cellSize.isEqual(cellFrame.size) == false) || m_needsSizing) {
			trace(cellFrame.size);
			m_cellSize = cellFrame.size;
			update();
		}

		/*
		 * Compute the frame
		 */
		screenFrame = screenRect;
		if (items > 0) {
			var f:Number;

			if (m_horizontal == false) {
				f = screenRect.size.height * (items - 1);
				screenFrame.size.height += f + m_leftBorderOffset;
				screenFrame.origin.y -= f;
				screenFrame.size.width += m_leftBorderOffset;
				screenFrame.origin.x -= m_leftBorderOffset;
				// Compute position for popups, if needed
				if (selectedItemIndex != -1) {
					screenFrame.origin.y += screenRect.size.height * selectedItemIndex;
				}
			} else {
				f = screenRect.size.width * (items - 1);
				screenFrame.size.width += f;
				// Compute position for popups, if needed
				if (selectedItemIndex != -1) {
					screenFrame.origin.x -= screenRect.size.width * selectedItemIndex;
				}
			}
		}

		// Get the frameRect
		r = NSWindow.frameRectForWindowContentRectStyleMask(
			m_window, screenFrame, m_window.styleMask());

		// Update position,if needed, using the preferredEdge;
		//! unsused?

		// Set the window frame
		m_window.setFrame(r);
	}

	/*
	 * Drawing.
	 */
	public function isOpaque():Boolean {
		return true;
	}

	public function drawRect(rect:NSRect):Void {
		var i:Number;
		var howMany:Number = m_itemCells.count();
		var aRect:NSRect;
		var aCell:NSMenuItemCell;
		var g:ASGraphics = graphics();

		//
		// Clear
		//
		g.clear();

		//
		// Draw background
		//
		var theme:ASThemeProtocol = ASTheme.current();
		if (isHorizontal() && m_menu.isRoot()) {
			theme.drawMenuBarBackgroundWithRectInView(rect, this);
		} else {
			theme.drawMenuBackgroundWithRectInView(rect, this);
		}

		//
		// Remove all tooltips
		//
		removeAllToolTips();

		//
		// Draw the menu cells
		//
		for (i = 0; i < howMany; i++) {
			aRect = rectOfItemAtIndex(i);
			if (rect.intersectsRect(aRect) == true) {
				aCell = NSMenuItemCell(m_itemCells.objectAtIndex(i));
				aCell.drawWithFrameInView(aRect, this);
				if (aCell.menuItem().toolTip() != null) {
					//! FIXME this doesn't work
					addToolTipRectOwnerUserData(aRect,
						aCell.menuItem().toolTip(), null);
				}
			}
		}
	}

	public function mouseDown (event:NSEvent):Void {
		m_trackingData = {
			eventMask:
			NSEvent.NSLeftMouseUpMask | NSEvent.NSLeftMouseDraggedMask |
			NSEvent.NSMouseMovedMask | NSEvent.NSLeftMouseDownMask
		};

		mouseTrackingCallback(event);
	}

	private function mouseTrackingCallback(event:NSEvent):Void {
		var location:NSPoint = convertPointFromView(event.mouseLocation);
		var index:Number = indexOfItemAtPoint(location);

		//1 An item with an attached menu in the root menu has been pressed
		if(m_menu.isRoot() && attachedMenu()!=null && event.type==NSEvent.NSLeftMouseDown) {
			trackingDone();
			return;
		}

		//2 The mouse has moved out of the menu
		if (index == -1) {
			//in global co-ords
			var loc:NSPoint = event.mouseLocation;

			//i) - Check if we enter the attached submenu
			var windowUnderMouse:NSWindow = m_menu.attachedMenu().window();
			if (windowUnderMouse != null
					&& windowUnderMouse.frame().pointInRect(loc)) {
				var v:NSMenuView = attachedMenuView();
				v.mouseDown(event);
				return;
			}

			//ii) I am a submenu, and user moved into my ancestor
			var candidateMenu:NSMenu = m_menu.superMenu();
			while (candidateMenu.superMenu() != null
					&& !candidateMenu.window().frame().pointInRect(loc) // not found yet
					&& candidateMenu.isAttached()) {// has displayed parent
				candidateMenu = candidateMenu.superMenu();
			}

			if (candidateMenu != null
					&& candidateMenu.window().frame().pointInRect(loc)) {
				var v:NSMenuView = candidateMenu.menuRepresentation();
				//! FIXME detach here?
				v.mouseDown(event);

				return;
			}

			//iii) - Don't close the menu unless clicked outside
			if (event.type==NSEvent.NSLeftMouseDown) {
				trackingDone();
				return;
			}
		}
		//3 - User has selected another item
		if(index != m_highlightedItemIndex) {
			//i) don't detach the menu if just attached
			if(m_menu.indexOfItemWithSubmenu(attachedMenu())!=index) {
				detachSubmenu();
			}
			//ii) invoke now since detach will set index to -1
			setHighlightedItemIndex(index);

			//iii) - attach submenu
			if (index >= 0 && (m_itemsLink.objectAtIndex(index).submenu()!=null)) {
				attachSubmenuForItemAtIndex(index);
			}
			setNeedsDisplay(true);
		}

		if(event.type==NSEvent.NSLeftMouseUp) {
			if(m_itemsLink.objectAtIndex(m_highlightedItemIndex).submenu()==null) {
				//since it has no submenus, perform an action
				trackingDone();
				return;
			}
		}

		m_app.callObjectSelectorWithNextEventMatchingMaskDequeue(
			this, "mouseTrackingCallback", m_trackingData.eventMask, true);
	}

	private function trackingDone():Void {
		m_notificationCenter.postNotificationWithNameObject(
		NSMenu.NSMenuDidEndTrackingNotification, m_menu.topMostMenu());
		// We need to store this, because m_highlightedItemIndex
		// will not be valid after we removed this menu from the screen.

		var indexOfActionToExecute:Number = m_highlightedItemIndex;
		//remove transient menus.
		var curr:NSMenu = m_menu;

		while (curr.superMenu()!=null) {
			curr=curr.superMenu();
		}

		curr.menuRepresentation().detachSubmenu();

		if (m_highlightedItemIndex >= 0) {
			setHighlightedItemIndex(-1);
		}

		m_menu.performActionForItemAtIndex(indexOfActionToExecute);
	}

	/*
	 * Event Handling
	 */
	public function performActionWithHighlightingForItemAtIndex(index:Number):Void {
		var candidateMenu:NSMenu = m_menu;
		var targetMenuView:NSMenuView;
		var indexToHighlight:Number = index;
		var oldHighlightedIndex:Number;
		var superMenu:NSMenu;

		for (;;) {
			superMenu = candidateMenu.superMenu();

			if (superMenu == null
			|| candidateMenu.isAttached()) {
				targetMenuView = candidateMenu.menuRepresentation();

				break;
			} else {
				indexToHighlight = superMenu.indexOfItemWithSubmenu(candidateMenu);
				candidateMenu = superMenu;
			}
		}

		oldHighlightedIndex = targetMenuView.highlightedItemIndex();
		targetMenuView.setHighlightedItemIndex(indexToHighlight);

		/* We need to let the run loop run a little so that the fact that
		 * the item is highlighted gets displayed on screen.
		 *
		[NSRunLoop.currentRunLoop()
			runUntilDate: NSDate.dateWithTimeIntervalSinceNow(0.1]);
		*/
		m_menu.performActionForItemAtIndex(index);

		if (!m_menu.__ownedByPopUp()) {
			targetMenuView.setHighlightedItemIndex(oldHighlightedIndex);
		}
	}

	public function performKeyEquivalent(theEvent:NSEvent ):Boolean {
		return m_menu.performKeyEquivalent(theEvent);
	}

	//******************************************************
	//*                NSView overrides
	//******************************************************

	/**
	 * Always returns <code>true</code>.
	 */
	public function acceptsFirstMouse(theEvent:NSEvent):Boolean {
		return true;
	}

	/**
	 * Always returns <code>true</code>.
	 */
	public function acceptsFirstResponder(theEvent:NSEvent):Boolean {
		return true;
	}

	/**
	 * We do not want to popup menus in this menu, so this method returns
	 * <code>null</code>.
	 */
	public function menuForEvent(theEvent:NSEvent):NSMenu {
		return null;
	}

	//******************************************************
	//*                   Boundaries
	//******************************************************

	/**
	 * Returns a reference to the <code>bounds</code>, instead of a copy.
	 */
	public static function bounds():NSSize {
		return g_bounds;
	}

	/**
	 * Sets the <code>bounds</code>.
	 */
	public static function setBounds(size:NSSize):Void {
		if(size==null) {
			g_bounds = new NSSize(Stage.width, Stage.height);
		} else {
			g_bounds = size;
		}
	}

	//******************************************************
	//*                Utility methods
	//******************************************************

	/**
	 * Returns the padded rectangle of the menu item at <code>index</code>.
	 */
	private function paddedRectForIndex(index:Number):NSRect {
		var pad:Number = NSMenuItemCell.cellPadding();
		return rectOfItemAtIndex(index).insetRect(-pad, -pad);
	}

	/**
	 * Reduces the x-origin of the rectangle by one and increases its width
	 * by one.
	 */
	private static function addLeftBorderOffsetToRect(aRect:NSRect):Void {
		aRect.origin.x--;
		aRect.size.width++;
	}
}
