/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Represents a source object's type, which determines where it is allowed
 * to be dropped.
 * 
 * @author Scott Hyndman
 */
class org.aib.constants.SourceObjectType extends ASConstantValue {
	
	/**
	 * The source object is a view.
	 */
	public static var AIBView:SourceObjectType 
		= new SourceObjectType(1);
		
	/**
	 * The source object is an object.
	 */
	public static var AIBObject:SourceObjectType 
		= new SourceObjectType(2);
	
	/**
	 * Creates a new instance of the <code>SourceObjectType</code> class.
	 */
	public function SourceObjectType(val:Number) {
		super(val);
	}
}