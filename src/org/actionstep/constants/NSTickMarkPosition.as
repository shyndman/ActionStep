/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Used to specify where tick marks appear on an <code>NSSlider</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSTickMarkPosition extends ASConstantValue {
	
	/**
	 * Tick marks below (for horizontal sliders); the default for horizontal 
	 * sliders.
	 */
	public static var NSTickMarkBelow:NSTickMarkPosition
		= new NSTickMarkPosition(0);
		
	/**
	 * Tick marks above (for horizontal sliders).
	 */
	public static var NSTickMarkAbove:NSTickMarkPosition
		= new NSTickMarkPosition(1);
		
	/**
	 * Tick marks to the left (for vertical sliders); the default. for vertical 
	 * sliders
	 */
	public static var NSTickMarkLeft:NSTickMarkPosition
		= NSTickMarkBelow;
		
	/**
	 * Tick marks to the right (for vertical sliders).
	 */
	public static var NSTickMarkRight:NSTickMarkPosition
		= NSTickMarkAbove;
	
	/**
	 * Constructs a new instance of the <code>NSTickMarkPosition</code> class.
	 */
	private function NSTickMarkPosition(value:Number) {
		super(value);
	}
}