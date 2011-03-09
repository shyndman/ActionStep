/* See LICENSE for copyright and terms of use */

import org.actionstep.NSToolbarItem;

/**
 * <p>A toolbar item with a valid target and action is enabled by default. To 
 * allow a toolbar item to be disabled in certain situations, a toolbar item’s 
 * target can implement the {@link #validateToolbarItem()} method.</p>
 * 
 * <p>Note: NSToolbarItem’s {@link #validate()} method calls this method only 
 * if the item’s target has a valid action defined on its target and if the 
 * item is not a custom view item. If you want to validate a custom view item, 
 * then you have to subclass NSToolbarItem and override {@link #validate()}.</p>
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.toolbar.NSToolbarItemValidation {
	
	/**
	 * <p>If this method is implemented and returns <code>false</code>, 
	 * NSToolbar will disable <code>theItem</code>; returning <code>true</code> 
	 * causes <code>theItem</code> to be enabled.</p>
	 * 
	 * <p>Note: {@link #validateToolbarItem()} is called very frequently, so it 
	 * must be efficient.</p>
	 * 
	 * <p>If the receiver is the target for the actions of multiple toolbar 
	 * items, it’s necessary to determine which toolbar item 
	 * <code>theItem</code> refers to by testing the 
	 * {@link NSToolbarItem#itemIdentifier()}.</p>
	 * 
	 * @see org.actionstep.NSToolbar#validateVisibleItems()
	 * @see NSToolbarItem#validate()
	 * @see NSToolbarItem#target()
	 * @see NSToolbarItem#action()
	 */
	public function validateToolbarItem(theItem:NSToolbarItem):Boolean;
}