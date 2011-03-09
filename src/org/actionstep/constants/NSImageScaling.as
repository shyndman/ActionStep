/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * These constants specify the way an image will be altered to fit the frame.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSImageScaling extends ASConstantValue {
	/** 
	 * If the image is too large, it shrinks to fit inside the frame. The 
	 * proportions of the image are preserved.
	 */
	public static var NSScaleProportionally:NSImageScaling = new NSImageScaling(0);
	/**
	 * The image shrinks or expands, and its proportions distort, until it 
	 * exactly fits the frame.
	 */
	public static var NSScaleToFit:NSImageScaling = new NSImageScaling(1);
	/**
	 * The size and proportions of the image don’t change. If the frame is too 
	 * small to display the whole image, the edges of the image are trimmed off.
	 */
	public static var NSScaleNone:NSImageScaling = new NSImageScaling(2);
	
	/**
	 * Constructs a new instance of <code>NSImageScaling</code> with a value
	 * of <code>value</code>.
	 */
	private function NSImageScaling(value:Number)
	{
		super(value);
	}
}