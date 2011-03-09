/* See LICENSE for copyright and terms of use */

import org.actionstep.NSMenu;
import org.actionstep.NSMenuItem;
import org.actionstep.NSEvent;

/**
 * <p>This is not an interface that you actually need to implement. Rather, these
 * are the method signitures that the menu will expect on its delegate</p>
 * 
 * <p>You can implement as few or as many of these methods as you like, and the
 * menu will accomodate the delegate as required.</p>
 * 
 * @see NSMenu
 * @see NSMenu#setDelegate()
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.menu.ASMenuDelegate {
	
	/**
	 * <p>Called to let you update a menu item before it is displayed.</p>
	 * 
	 * <p>If your {@link #numberOfItemsInMenu()} delegate method returns a 
	 * positive value, then your {@link #menuUpdateItemAtIndexShouldCancel()} 
	 * method is called for each item in the menu. You can then update the menu 
	 * title, image, and so forth for the menu item. Return <code>true</code> to
	 * continue the process. If you return <code>false</code>, your 
	 * {@link #menuUpdateItemAtIndexShouldCancel()} is not called again. In that
	 * case, it is your responsibility to trim any extra items from the menu.</p>
	 * 
	 * <p>The <code>shouldCancel</code> parameter is set to <code>true</code> 
	 * when your delegate is called if, due to some user action, the menu no 
	 * longer needs to be displayed before all the menu items have been 
	 * updated. You can ignore this flag, return <code>true</code>, and 
	 * continue; or you can save your work (to save time the next time your 
	 * delegate is called) and return <code>false</code> to stop the updating.</p> 
	 */
	public function menuUpdateItemAtIndexShouldCancel(menu:NSMenu, 
		item:NSMenuItem, index:Number, shouldCancel:Boolean):Boolean;
		
	/**
	 * <p>Called to allow the delegate to return the target and action for a 
	 * key down event.</p>
	 * 
	 * <p>This method should return an object structured as follows:<br/>
	 * <code>{hasEquivalent:Boolean, target:Object, action:String}</code>
	 * </p>
	 * 
	 * <p>If there is a valid and enabled menu item that corresponds to this 
	 * key down even, return an object marking <code>hasEquivalent</code> as 
	 * <code>true</code> and specifying the target and action. (Specify 
	 * <code>null</code> to invoke the menu's target and action). Return 
	 * an object marking <code>hasEquivalent</code> as <code>false</code> if 
	 * there are no items with that key equivalent or if the item is disabled. 
	 * If the delegate does not define this method, the menu is populated to 
	 * find out if any items have a matching key equivalent.</p>
	 */
	public function menuHasKeyEquivalentForEvent(menu:NSMenu, event:NSEvent):Object;
	
	/**
	 * <p>Called when a menu is about to be displayed at the start of a 
	 * tracking session so the delegate can modify the menu.</p>
	 * 
	 * <p>You can change the menu by adding, removing or modifying menu items. 
	 * Be sure to set the proper enable state for any new menu items. If 
	 * populating the menu will take a long time, implement 
	 * {@link #numberOfItemsInMenu()} and 
	 * {@link #menuUpdateItemAtIndexShouldCancel()} instead.</p>
	 */
	public function menuNeedsUpdate(menu:NSMenu):Void;
	
	/**
	 * <p>Called when a menu is about to be displayed at the start of a 
	 * tracking session so the delegate can specify the number of items in the 
	 * menu.</p>
	 * 
	 * <p>If you return a positive value, the menu is resized by either removing
	 * or adding items. Newly created items are blank. After the menu is 
	 * resized, your {@link #menuUpdateItemAtIndexShouldCancel()} method is 
	 * called for each item. If you return a negative value, the number of items
	 * is left unchanged and {@link #menuUpdateItemAtIndexShouldCancel()} is not
	 * called. If you can populate the menu quickly, you can implement 
	 * {@link #menuNeedsUpdate()} instead of {@link #numberOfItemsInMenu()} and 
	 * {@link #menuUpdateItemAtIndexShouldCancel()}.</p>
	 */
	public function numberOfItemsInMenu(menu:NSMenu):Number;
}