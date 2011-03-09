/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.constants.NSToolbarDisplayMode;
import org.actionstep.constants.NSToolbarSizeMode;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSObject;
import org.actionstep.NSToolbarItem;
import org.actionstep.NSWindow;
import org.actionstep.toolbar.ASToolbarDelegate;
import org.actionstep.toolbar.ASToolbarView;

/**
 * <p>
 * NSToolbar and NSToolbarItem provide the mechanism for a titled window to 
 * display a toolbar just below its title bar.
 * </p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSToolbar extends NSObject {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private static var g_nc:NSNotificationCenter;
	
	private var m_identifier:String;
	private var m_isBuilding:Boolean;
	private var m_displayMode:NSToolbarDisplayMode;
	private var m_sizeMode:NSToolbarSizeMode;
	private var m_showsBaselineSeparator:Boolean;
	private var m_allowsUserCustomization:Boolean;
	private var m_items:NSArray;
	private var m_delegate:ASToolbarDelegate;
	private var m_selItemIdentifier:String;
	private var m_isVisible:Boolean;
	private var m_window:NSWindow;
	private var m_view:ASToolbarView;
	
	//******************************************************
	//*               Creating an NSToolbar
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSToolbar</code> class.
	 */
	public function NSToolbar() {
		m_sizeMode = NSToolbarSizeMode.NSToolbarSizeModeDefault;
		m_displayMode = NSToolbarDisplayMode.NSToolbarDisplayModeDefault;
		m_showsBaselineSeparator = true;
		m_items = NSArray.array();
		m_isVisible = true;
		m_isBuilding = false;
		
		m_view = (new ASToolbarView()).initWithToolbar(this);
	}
	
	/**
	 * <p>Initializes a newly allocated NSToolbar with <code>identifier</code>, 
	 * which is used by the toolbar to identify the kind of the toolbar.</p>
	 */
	public function initWithIdentifier(identifier:String):NSToolbar {
		super.init();
		m_identifier = identifier;
		return this;
	}
	
	//******************************************************
	//*          Releasing the object from memory
	//******************************************************
	
	public function release():Boolean {
		super.release();
		
		g_nc.removeObserverNameObject(m_delegate, null, this);
		g_nc.removeObserver(this);
		
		//m_window.setToolbar(null);
		m_view.release();
		m_view = null;
		
		m_items.makeObjectsPerformSelector("release");
		m_items = null;
		
		return true;
	}
	
	//******************************************************
	//*                Toolbar attributes
	//******************************************************
	
	/**
	 * Returns the receiver’s display mode.
	 * 
	 * @see #setDisplayMode()
	 */
	public function displayMode():NSToolbarDisplayMode {
		return m_displayMode;
	}
	
	/**
	 * Sets the receiver’s display mode.
	 * 
	 * @see #displayMode()
	 */
	public function setDisplayMode(mode:NSToolbarDisplayMode):Void {
		m_displayMode = mode;
		m_view.reload();
		m_window.__adjustForToolbar();
	}
	
	/**
	 * <p>Returns whether the toolbar shows the separator between the toolbar 
	 * and the main window contents.</p>
	 * 
	 * <p>The default is <code>true</code>.</p>
	 * 
	 * @see #setShowsBaselineSeparator()
	 */
	public function showsBaselineSeparator():Boolean {
		return m_showsBaselineSeparator;
	}
	
	/**
	 * <p>Sets whether the toolbar shows the separator between the toolbar and 
	 * the main window contents.</p>
	 * 
	 * <p>If <code>flag</code> is <code>true</code> the baseline is shown. The 
	 * default is <code>true</code>.</p>
	 */
	public function setShowsBaselineSeparator(flag:Boolean):Void {
		m_showsBaselineSeparator = flag;
		m_view.setNeedsDisplay(true);
	}
	
	/**
	 * <p>Returns the receiver’s identifier, which identifies the kind of 
	 * the toolbar.</p>
	 */
	public function identifier():String {
		return m_identifier;
	}
	
	/**
	 * Returns all current items in the receiver, in order.
	 * 
	 * @see #visibleItems()
	 */
	public function items():NSArray {
		return m_items;
	}
	
	/**
	 * Returns the receiver’s currently visible items. An item can be invisible 
	 * if it has spilled over into the overflow menu.
	 * 
	 * @see #items()
	 */
	public function visibleItems():NSArray {
		return m_view.visibleItems();
	}
	
	/**
	 * Returns the receiver’s size mode.
	 * 
	 * @see #setSizeMode()
	 */
	public function sizeMode():NSToolbarSizeMode {
		return m_sizeMode;
	}
	
	/**
	 * <p>Sets the receiver’s size mode.</p>
	 * 
	 * <p>The size can be:</p>
	 * <ul>
	 * 	<li>{@link NSToolbarSizeMode#NSToolbarSizeModeRegular}. The toolbar 
	 * 	uses regular-sized controls and 32 by 32 pixel icons.</li>
	 * 	<li>{@link NSToolbarSizeMode#NSToolbarSizeModeSmall}. The toolbar uses 
	 * 	small-sized controls and 24 by 24 pixel icons.</li>
	 * </ul>
	 * <p>If the toolbar item's icon is not of the appropriate size, it is
	 * scaled.</p>
	 */
	public function setSizeMode(mode:NSToolbarSizeMode):Void {
		m_sizeMode = mode;
		m_view.reload();
		m_window.__adjustForToolbar();
	}
	
	//******************************************************
	//*              Managing the delegate
	//******************************************************
	
	/**
	 * <p>Returns the receiver’s delegate.</p>
	 * 
	 * <p>Every toolbar must have a delegate, which must implement the required 
	 * delegate methods.</p>
	 * 
	 * @see #setDelegate()
	 */
	public function delegate():ASToolbarDelegate {
		return m_delegate;
	}
	
	/**
	 * <p>Sets the receiver’s delegate to <code>anObject</code>.</p>
	 * 
	 * <p>Every toolbar must have a delegate, which must implement the required 
	 * delegate methods.</p>
	 * 
	 * @see #delegate()
	 */
	public function setDelegate(anObject:ASToolbarDelegate):Void {
		if (anObject == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"The delegate cannot be null.",
				null);
			trace(e);
			throw e;
		}
		
		//
		// Remove old delegates 
		//
		if (m_delegate != null) {
			g_nc.removeObserverNameObject(m_delegate, null, this);
		}
		
		m_delegate = anObject;
		
		g_nc.addObserverSelectorNameObject(m_delegate, "toolbarWillAddItem",
			NSToolbarWillAddItemNotification, this);
		g_nc.addObserverSelectorNameObject(m_delegate, "toolbarDidRemoveItem",
			NSToolbarDidRemoveItemNotification, this);
			
		//
		// Build the items
		//
		build();
		m_view.reload();
	}
	
	//******************************************************
	//*           Managing items on the toolbar
	//******************************************************
	
	/**
	 * <p>Inserts the item identified by <code>itemIdentifier</code> at 
	 * <code>index</code>.</p>
	 * 
	 * @see #removeItemAtIndex()
	 */
	public function insertItemWithItemIdentifierAtIndex(itemIdentifier:String,
			index:Number):Void {
		var needsNew:Boolean = true;
		var item:NSToolbarItem;
		
		if (m_delegate == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"A delegate is required to use this method.",
				null);
			trace(e);
			throw e;
		}
		
		//
		// Create the item
		//
		if (needsNew) {
			item = m_delegate.toolbarItemForItemIdentifierWillBeInsertedIntoToolbar(
				this, itemIdentifier, true);
		}
		
		if (item == null) { // item not supported
			return;
		}
				
		insertItemAtIndex(item, index);
	}
	
	/**
	 * Inserts the toolbar item <code>item</code> at <code>index</code>.
	 */
	public function insertItemAtIndex(item:NSToolbarItem, index:Number):Void {
		//
		// Mark as selectable if possible
		//
		var sel:String = "toolbarSelectableItemIdentifiers";
		if (m_delegate != null && ASUtils.respondsToSelector(m_delegate, sel)) {
			var selectableIDs:NSArray = m_delegate[sel](this);
			item.__setSelectable(selectableIDs.containsObject(item.itemIdentifier()));
		}
		
		//
		// Post the notification
		//
		var ui:NSDictionary = NSDictionary.dictionaryWithObjectForKey(
			item, "item");
		g_nc.postNotificationWithNameObjectUserInfo(
			NSToolbarWillAddItemNotification,
			this, ui);
			
		//
		// Add the item
		//
		item.__setToolbar(this);
		m_items.insertObjectAtIndex(item, index);
		
		if (!m_isBuilding) {
			m_view.reload();
		}
		
	}
	
	/**
	 * <p>Removes the item at <code>index</code>.</p>
	 * 
	 * @see #insertItemWithItemIdentifierAtIndex()
	 */
	public function removeItemAtIndex(index:Number):Void {
		var item:NSToolbarItem = NSToolbarItem(m_items.objectAtIndex(
			index));
			
		//
		// If there isn't an item at the index, do nothing
		//
		if (item == null) { 
			return;
		}
		
		m_items.removeObjectAtIndex(index);
		
		//
		// Post the notification
		//
		var ui:NSDictionary = NSDictionary.dictionaryWithObjectForKey(
			item, "item");
		g_nc.postNotificationWithNameObjectUserInfo(
			NSToolbarDidRemoveItemNotification,
			this, ui);
			
		m_view.reload();
	}
	
	/**
	 * <p>Returns the identifier of the receiver’s currently selected item, or 
	 * <code>null</code>.</p>
	 * 
	 * @see #setSelectedItemIdentifier()
	 */
	public function selectedItemIdentifier():String {
		return m_selItemIdentifier;
	}
	
	/**
	 * <p>Sets the receiver's selected item to the toolbar item specified by 
	 * <code>itemIdentifier</code>.</p>
	 * 
	 * <p>Typically, a toolbar will manage the selection of items automatically.
	 * This method can be used to select identifiers of custom view items, or 
	 * to force a selection change. See 
	 * {@link ASToolbarDelegate#toolbarSelectableItemIdentifiers()} for more 
	 * details. If <code>itemIdentifier</code> is not recognized by the 
	 * receiver, the current selected item identifier does not change.</p>
	 * 
	 * <p><code>itemIdentifier</code> may be any identifier returned by 
	 * {@link ASToolbarDelegate#toolbarSelectableItemIdentifiers()}, even if it
	 * is not currently in the toolbar. If the selected item is removed from the
	 * toolbar, the {@link #selectedItemIdentifier()} does not change.</p>
	 */
	public function setSelectedItemIdentifier(itemIdentifier:String):Void {		
		var ids:Array;
		var arr:Array;
		var len:Number;
		var selected:NSArray = NSArray.array();
		var selectables:NSArray;
		var itemsToSelect:NSArray;
		var item:NSToolbarItem;
				
		if (m_delegate == null) {
			return;
		}
		
		//
		// Deselect old items
		//
		ids = NSArray(m_items.valueForKey("itemIdentifier")).internalList();
		len = ids.length;
		for (var i:Number = 0; i < len; i++) {
			if (ids[i] == m_selItemIdentifier) {
				NSToolbarItem(m_items.objectAtIndex(i)).__setSelected(false);
			}
		}
				
		//
		// Get the selectables
		//
		var sel:String = "toolbarSelectableItemIdentifiers";
		if (ASUtils.respondsToSelector(m_delegate, sel)) {
			selectables = m_delegate[sel](this);
		} else {
			return;
		}
		
		//
		// Assign new value
		//
		m_selItemIdentifier = itemIdentifier;
		
		//
		// Return if nothing is selectable
		//
		if (selectables = null || !selectables.containsObject(itemIdentifier)) {
			return;
		}
		
		//
		// Select new items
		//
		len = ids.length;
		for (var i:Number = 0; i < len; i++) {
			if (ids[i] == itemIdentifier) {
				item = NSToolbarItem(m_items.objectAtIndex(i));
				if (!item.__selected()) {
					item.__setSelected(true);
				}
			}
		}
	}
	
	/**
	 * Does the initial building of the toolbar based on the delegate's
	 * information.
	 */
	public function build():Void {
		m_isBuilding = true;
		
		//
		// Add default toolbar items
		//
		var ids:Array = m_delegate.toolbarDefaultItemIdentifiers(this).internalList();
		var len:Number = ids.length;
		for (var i:Number = 0; i < len; i++) {
			var id:String = ids[i];
			insertItemWithItemIdentifierAtIndex(id, m_items.count());
		}
		
		m_isBuilding = false;
	}
	
	//******************************************************
	//*              Displaying the toolbar
	//******************************************************
	
	/**
	 * Returns whether the receiver is visible.
	 * 
	 * @see #setVisible()
	 */
	public function isVisible():Boolean {
		return m_isVisible;
	}
	
	/**
	 * Sets whether the receiver is visible or hidden to <code>flag</code>.
	 * 
	 * @see #visible()
	 */
	public function setVisible(flag:Boolean):Void {
		if (m_isVisible == flag) {
			return;
		}
		
		m_isVisible = flag;
		m_view.setHidden(!flag);
		m_window.__adjustForToolbar();
	}
	
	//******************************************************
	//*               Toolbar customization
	//******************************************************

	// TODO do we need to implement these?
	//! TODO allowsUserCustomization
	//! TODO setAllowsUserCustomization
    // TODO – runCustomizationPalette:
    // TODO – customizationPaletteIsRunning

	//******************************************************
	//*            Autosaving the configuration
	//******************************************************

	// TODO do we need to implement these?
    // TODO – autosavesConfiguration
    // TODO – setAutosavesConfiguration:
    // TODO – configurationDictionary
    // TODO – setConfigurationFromDictionary:
	
	//******************************************************
	//*              Toolbar item validation
	//******************************************************
	
	/**
	 * <p>Called on window updates with the purpose of validating each of the 
	 * visible items.</p>
	 * 
	 * <p>You use this method by overriding it in a subclass; typically you 
	 * should not invoke this method. The toolbar calls this method to iterate 
	 * through the list of visible items, sending each a 
	 * {@link NSToolbarItem#validate()} message. Override it and call super if 
	 * you want to know when this happens.</p>
	 */
	public function validateVisibleItems():Void {
		var arr:Array = visibleItems().internalList();
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var item:NSToolbarItem = NSToolbarItem(arr[i]);
			if (!item.autovalidates()) {
				continue;
			}
			
			item.validate();				
		}
	}
	
	//******************************************************
	//*               Internal properties
	//******************************************************
	
	/**
	 * For internal use only.
	 */
	public function __window():NSWindow {
		return m_window;
	}
	
	/**
	 * For internal use only.
	 */
	public function __setWindow(window:NSWindow):Void {
		m_window = window;
		m_view.setWindow(window);
	}
	
	/**
	 * For internal use only.
	 */
	public function __toolbarView():ASToolbarView {
		return m_view;
	}
	
	//******************************************************
	//*                Class constructor
	//******************************************************
	
	private static function initialize():Void {
		g_nc = NSNotificationCenter.defaultCenter();
	}
	
	//******************************************************
	//*                  Notifications
	//******************************************************
	
	/**
	 * <p>Posted after an item is removed from a toolbar. The notification item 
	 * is the NSToolbar that had an item removed from it. The userInfo 
	 * dictionary contains the following information:</p>
	 * 
	 * <ul>
	 * <li><strong>item</strong> - The NSToolbarItem that was removed.</li>
	 * </ul>
	 */
	public static var NSToolbarDidRemoveItemNotification:Number
		= ASUtils.intern("NSToolbarDidRemoveItemNotification");
		
	/**
	 * <p>Posted before a new item is added to the toolbar. The notification 
	 * item is the NSToolbar having an item added to it. The userInfo 
	 * dictionary contains the following information:</p>
	 * 
	 * 
	 * <ul>
	 * <li><strong>item</strong> - The NSToolbarItem being added.</li>
	 * </ul>
	 */
	public static var NSToolbarWillAddItemNotification:Number
		= ASUtils.intern("NSToolbarWillAddItemNotification");
}