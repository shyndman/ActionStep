/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * <p>Describes the stroke scaling of a line.</p>
 * 
 * <p>Used by the {@link org.actionstep.ASGraphics} class when drawing lines.</p>
 * 
 * @see org.actionstep.ASGraphics#setStrokeScaling()
 * @author Scott Hyndman
 */
class org.actionstep.constants.ASStrokeScaling extends ASConstantValue {
	
	/**
	 * Always scales the thickness.
	 */
	public static var ASNormalStrokeScaling:ASStrokeScaling 
		= new ASStrokeScaling(1, "normal");
		
	/**
	 * Never scales the thickness.
	 */
	public static var ASNoStrokeScaling:ASStrokeScaling 
		= new ASStrokeScaling(2, "none");
		
	/**
	 * Do not scale the thickness if object is scaled vertically.
	 */
	public static var ASVerticalStrokeScaling:ASStrokeScaling 
		= new ASStrokeScaling(3, "vertical");
		
	/**
	 * Do not scale the thickness if object is scaled horizontally.
	 */
	public static var ASHorizontalStrokeScaling:ASStrokeScaling 
		= new ASStrokeScaling(4, "horizontal");
	
	/**
	 * <p>The string value used when passing data to the 
	 * {@link MovieClip#lineStyle()} method.</p>
	 * 
	 * <p>Used internally. You should never modify this value.</p>
	 */
	public var argValue:String;
	
	/**
	 * Creates a new instance of the <code>ASStrokeScaling</code> class.
	 */
	private function ASStrokeScaling(value:Number, argValue:String) {
		super(value);
		this.argValue = argValue;
	}
}