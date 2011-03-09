/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Describes progress indicator styles.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSProgressIndicatorStyle extends ASConstantValue 
{
	/**
	 * A rectangular indicator that can be determinate or indeterminate.
	 */
	public static var NSProgressIndicatorBarStyle:NSProgressIndicatorStyle 
		= new NSProgressIndicatorStyle(0);
		
	/**
	 * A small square indicator that can be indeterminate only.
	 */
	public static var NSProgressIndicatorSpinningStyle:NSProgressIndicatorStyle
		= new NSProgressIndicatorStyle(1);
	
	/**
	 * Creates a new instance of NSProgressIndicatorStyle.
	 */
	private function NSProgressIndicatorStyle(value:Number)
	{
		super(value);
	}
}