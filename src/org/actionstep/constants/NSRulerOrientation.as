/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Specify the orientation of an <code>org.actionstep.NSRulerView</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSRulerOrientation extends ASConstantValue {
	
	/**
	 * Horizontal orientation.
	 */
	public static var NSHorizontalRuler:NSRulerOrientation 
		= new NSRulerOrientation(1);
	
	/**
	 * Vertical orientation.
	 */
	public static var NSVerticalRuler:NSRulerOrientation 
		= new NSRulerOrientation(2);
	
	/**
	 * Creates a new instance of the <code>NSRulerOrientation</code> class.
	 */	
	private function NSRulerOrientation(value:Number) {
		super(value);
	}
}