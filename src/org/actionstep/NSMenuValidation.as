/* See LICENSE for copyright and terms of use */

import org.actionstep.NSMenuItem;

/**
 * This informal protocol allows your application to update the enabled or 
 * disabled status of an {@link NSMenuItem} object. It declares only one method,
 * {@link #validateMenuItem()}.
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.NSMenuValidation {
	
	/**
	 * <p>
	 * Implemented to override the default action of enabling or disabling a 
	 * specific menu item.
	 * </p>
	 * <p>
	 * Returns <code>true</code> to enable <code>menuItem</code> or
	 * <code>false</code> to disable it.
	 * </p>
	 * <p>
	 * The object implementing this method must be the target of 
	 * <code>menuItem</code>. You can determine which menu item 
	 * <code>menuItem</code> is by querying it for its tag or action.
	 * </p>
	 */
	public function validateMenuItem(menuItem:NSMenuItem):Boolean;
}