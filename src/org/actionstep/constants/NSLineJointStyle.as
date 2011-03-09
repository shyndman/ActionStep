/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * <p>Describes the joint style of a line.</p>
 * 
 * <p>Used by the {@link org.actionstep.ASGraphics} class when drawing lines.</p>
 * 
 * @see org.actionstep.ASGraphics#setJointStyle()
 * @see org.actionstep.ASGraphics#setMiterLimit()
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSLineJointStyle extends ASConstantValue {
	
	/**
	 * Line joints are rounded off.
	 */
	public static var NSRoundLineJointStyle:NSLineJointStyle 
		= new NSLineJointStyle(1, "round");
	
	/**
	 * Line joints are bevelled.
	 */
	public static var NSBevelLineJointStyle:NSLineJointStyle 
		= new NSLineJointStyle(2, "bevel");
		
	/**
	 * <p>Line joints are mitered.</p>
	 * 
	 * <p>Can be used in conjunction with 
	 * {@link org.actionstep.ASGraphics#setMiterLimit()}</p>
	 */
	public static var NSMiterLineJointStyle:NSLineJointStyle 
		= new NSLineJointStyle(3, "miter");
		
	/**
	 * <p>The string value used when passing data to the 
	 * {@link MovieClip#lineStyle()} method.</p>
	 * 
	 * <p>Used internally. You should never modify this value.</p>
	 */
	public var argValue:String;
	
	/**
	 * Creates a new instance of the <code>ASJointStyle</code> class.
	 */
	private function NSLineJointStyle(value:Number, argValue:String) {
		super(value);
		this.argValue = argValue;
	}
}