/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * These constants allow you to specify the position of the image in the
 * frame.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSImageAlignment extends ASConstantValue {	
	public static var NSImageAlignCenter:NSImageAlignment = new NSImageAlignment(0);
	public static var NSImageAlignTop:NSImageAlignment = new NSImageAlignment(1);
	public static var NSImageAlignTopLeft:NSImageAlignment = new NSImageAlignment(2);
	public static var NSImageAlignTopRight:NSImageAlignment = new NSImageAlignment(3);
	public static var NSImageAlignLeft:NSImageAlignment = new NSImageAlignment(4);
	public static var NSImageAlignBottom:NSImageAlignment = new NSImageAlignment(5);
	public static var NSImageAlignBottomLeft:NSImageAlignment = new NSImageAlignment(6);
	public static var NSImageAlignBottomRight:NSImageAlignment = new NSImageAlignment(7);
	public static var NSImageAlignRight:NSImageAlignment = new NSImageAlignment(8);
	
	/**
	 * Constructs a new instance of NSImageAlignment with a value of 
	 * <code>value</code>.
	 */
	private function NSImageAlignment(value:Number)
	{
		super(value);
	}
}