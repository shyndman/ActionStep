/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * This constants represents types of <code>NSSlider</code>s.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSSliderType extends ASConstantValue {
	
	/** A bar-shaped slider. */
	public static var NSLinearSlider:NSSliderType = new NSSliderType(1);
	
	/** A circular slider; that is, a dial. */
	public static var NSCircularSlider:NSSliderType = new NSSliderType(2);
	
	/**
	 * Constructs a new instance of the <code>NSSliderType</code> class.
	 */
	private function NSSliderType(value:Number) {
		super(value);
	}
}