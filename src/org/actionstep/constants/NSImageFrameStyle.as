/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Specifies the type of frame that surrounds an image.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSImageFrameStyle extends ASConstantValue
{
	/** An invisible frame. */
	public static var NSImageFrameNone:NSImageFrameStyle = new NSImageFrameStyle(0);
	/** A thin black line and a drop shadow. */
	public static var NSImageFramePhoto:NSImageFrameStyle = new NSImageFrameStyle(1);
	/** A gray, concave bezel that makes the image look sunken. */
	public static var NSImageFrameGrayBezel:NSImageFrameStyle = new NSImageFrameStyle(2);
	/** A thin groove that looks etched around the image. */
	public static var NSImageFrameGroove:NSImageFrameStyle = new NSImageFrameStyle(3);
	/** A convex bezel that makes the image stand out in relief, like a button. */
	public static var NSImageFrameButton:NSImageFrameStyle = new NSImageFrameStyle(4);
   	
	/**
	 * Creates a new instance of NSImageFrameStyle with a value of
	 * <code>value</code>.
	 */
	private function NSImageFrameStyle(value:Number)
	{
		super(value);
	}
}