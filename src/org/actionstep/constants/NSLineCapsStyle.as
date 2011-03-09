/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * <p>Describes the types of caps at the ends of a line.</p>
 * 
 * <p>Used by the {@link org.actionstep.ASGraphics} class when drawing lines.</p>
 * 
 * @see org.actionstep.ASGraphics#setCapsStyle()
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSLineCapsStyle extends ASConstantValue {
	
	/**
	 * Does not use a caps style.
	 */
	public static var NSNoLineCapsStyle:NSLineCapsStyle 
		= new NSLineCapsStyle(1, "none");
		
	/**
	 * Draws rounded off line caps.
	 */
	public static var NSRoundLineCapsStyle:NSLineCapsStyle 
		= new NSLineCapsStyle(2, "round");
		
	/**
	 * Draws squared off line caps.
	 */
	public static var NSSquareLineCapsStyle:NSLineCapsStyle 
		= new NSLineCapsStyle(3, "square");
	
	/**
	 * <p>The string value used when passing data to the 
	 * {@link MovieClip#lineStyle()} method.</p>
	 * 
	 * <p>Used internally. You should never modify this value.</p>
	 */
	public var argValue:String;
	
	/**
	 * Creates a new instance of the <code>NSLineCapsStyle</code> class.
	 */
	private function NSLineCapsStyle(value:Number, argValue:String) {
		super(value);
		this.argValue = argValue;
	}
}