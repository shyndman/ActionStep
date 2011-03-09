/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Describes an NSTextField's bezel.
 * 
 * @see org.actionstep.NSTextField#setBezelStyle()
 * @see org.actionstep.NSTextFieldCell#setBezelStyle()
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSTextFieldBezelStyle extends ASConstantValue {
	
	/**
	 * Textfield has square corners.
	 */
	public static var NSTextFieldSquareBezel:NSTextFieldBezelStyle 
		= new NSTextFieldBezelStyle(1);
		
	/**
	 * Textfield has round corners.
	 */
	public static var NSTextFieldRoundedBezel:NSTextFieldBezelStyle 
		= new NSTextFieldBezelStyle(2);
	
	/**
	 * Creates a new instance of the <code>NSTextFieldBezelStyle</code> class.
	 */
	private function NSTextFieldBezelStyle(value:Number) {
		super(value);
	}
}