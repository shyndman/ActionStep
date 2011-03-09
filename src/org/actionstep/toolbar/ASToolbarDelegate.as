/* See LICENSE for copyright and terms of use */

import org.actionstep.NSToolbar;
import org.actionstep.NSToolbarItem;
import org.actionstep.NSNotification;
import org.actionstep.NSArray;

/**
 * Methods required by a toolbar's delegate.
 * 
 * @see NSToolbar#setDelegate()
 * @author Scott Hyndman
 */
interface org.actionstep.toolbar.ASToolbarDelegate {
	
	//******************************************************
	//*              Adding and removing items
	//******************************************************
	
	/**
	 * <p>Posted just before a new item is added to the toolbar.</p>
	 * 
	 * <p>If you need to cache a reference to the toolbar item or need to set 
	 * up some initial state, this is where to do it. The object attribute of 
	 * notification is the toolbar to which the item is being added. The 
	 * notification's userInfo dictionary contains the item being added under 
	 * the key <code>"item"</code>.</p>
	 */
	public function toolbarWillAddItem(notification:NSNotification):Void;
	
	/**
	 * <p>Posted just after an item has been removed from toolbar.</p>
	 * 
	 * <p>This method allows the chance to remove information related to the 
	 * item that may have been cached. The notification's object is the toolbar 
	 * from which the item is being removed. The notification's userInfo 
	 * dictionary contains the item being removed under the key 
	 * <code>"item"</code>.</p>
	 */
	public function toolbarDidRemoveItem(notification:NSNotification):Void;
	
	//******************************************************
	//*            Working with item identifiers
	//******************************************************
	
	/**
	 * <p>Returns a toolbar item of the kind identified by 
	 * <code>itemIdentifier</code> for <code>toolbar</code>.</p>
	 * 
	 * <p>Implement this method to create new toolbar item instances. This 
	 * method is called lazily on behalf of a toolbar instance, which must be 
	 * the sole owner of the toolbar item. A toolbar may ask again for a kind 
	 * of toolbar item already supplied to it, in which case this method can 
	 * and should return the same toolbar item it returned before.</p>
	 * 
	 * <p>If the item is a custom view item, the NSView must be fully formed 
	 * when the item is returned.</p>
	 * 
	 * <p>A <code>null</code> return value tells the toolbar that the identified 
	 * kind of toolbar item is not supported.</p>
	 * 
	 * <p>If <code>flag</code> is <code>true</code>, the returned item will be 
	 * inserted into the toolbar, and you can expect that 
	 * {@link #toolbarWillAddItem()} is about to be called.</p>
	 */
	public function toolbarItemForItemIdentifierWillBeInsertedIntoToolbar(
		toolbar:NSToolbar, itemIdentifier:String, flag:Boolean):NSToolbarItem;
		
	/**
	 * <p>
	 * Sent to discover the default item identifiers for a toolbar.
	 * </p>
	 * <p>
	 * Returns an array of toolbar item identifiers for <code>toolbar</code>, 
	 * specifying the contents and the order of the items in the default toolbar
	 * configuration.
	 * </p>
	 */
	public function toolbarDefaultItemIdentifiers(toolbar:NSToolbar):NSArray;
		
	/**
	 * <p>Returns an array of item identifiers that should indicate selection 
	 * in the specified <code>toolbar</code>.</p>
	 * 
	 * <p>Toolbars that need to indicate item selection should return an array 
	 * containing the identifiers of the selectable toolbar items.</p>
	 * 
	 * <p>Clicking on an item whose identifier is selectable will automatically 
	 * update the toolbars selected item identifier, when possible.</p>
	 * 
	 * @see NSToolbar#setSelectedItemIdentifier()
	 */
	public function toolbarSelectableItemIdentifiers(toolbar:NSToolbar):NSArray;
}