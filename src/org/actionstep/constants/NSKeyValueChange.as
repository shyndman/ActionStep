/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * The following constants are returned as the value for a
 * "NSKeyValueChangeKindKey" key in the change dictionary passed to
 * <code>observeValueForKeyPathOfObjectChangeContext, indicating the type of
 * change made.
 * 
 * @author Ray Chuan
 */
class org.actionstep.constants.NSKeyValueChange extends ASConstantValue {
	/**
	 * Indicates that the value of the observed key path was set to a new value.
	 *
	 * This change can occur when observing an attribute of an object, as well
	 * as properties that specify to-one and to-many relationships.
	 */
	public static var NSSetting:NSKeyValueChange	= new NSKeyValueChange(0);

	/**
	 * Indicates that an object has been inserted into the to-many relationship
	 * that is being observed.
	 */
	public static var NSInsertion:NSKeyValueChange	= new NSKeyValueChange(1);

	/**
	 * Indicates that an object has been removed from the to-many relationship
	 * that is being observed.
	 */
	public static var NSRemoval:NSKeyValueChange	= new NSKeyValueChange(2);

	/**
	 * Indicates that an object has been replaced in the to-many relationship
	 * that is being observed.
	 */
	public static var NSReplaced:NSKeyValueChange	= new NSKeyValueChange(3);

	private function NSKeyValueChange(value:Number) {
		super(value);
	}
}
