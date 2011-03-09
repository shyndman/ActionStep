/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Represents the load state of an image.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSImageLoadStatus extends ASConstantValue 
{
	/**
	 * Enough data has been provided to completely decompress the image.
	 */
	public static var NSImageLoadStatusCompleted:NSImageLoadStatus =
		new NSImageLoadStatus(0);
		
	/**
	 * The image could not be found or another read error was encountered.
	 */
	public static var NSImageLoadStatusReadError:NSImageLoadStatus =
		new NSImageLoadStatus(1);
	
	/**
	 * Constructs a new instance of NSImageLoadStatus.
	 */	
	private function NSImageLoadStatus(value:Number)
	{
		super(value);
	}
}