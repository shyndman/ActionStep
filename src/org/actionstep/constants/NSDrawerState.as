/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Represents the current state of an {@link org.actionstep.NSDrawer} instance.
 * 
 * @see org.actionstep.NSDrawer#state()
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSDrawerState extends ASConstantValue {
	
	/**
	 * The drawer is closed (not visible onscreen).
	 */
	public static var NSDrawerClosedState:NSDrawerState 
		= new NSDrawerState(1);
		
	/**
	 * The drawer is in the process of opening.
	 */
	public static var NSDrawerOpeningState:NSDrawerState 
		= new NSDrawerState(2);
		
	/**
	 * The drawer is open (visible onscreen).
	 */
	public static var NSDrawerOpenState:NSDrawerState 
		= new NSDrawerState(3);
		
	/**
	 * The drawer is in the process of closing.
	 */
	public static var NSDrawerClosingState:NSDrawerState 
		= new NSDrawerState(4);
		
	/**
	 * Creates a new instance of the <code>NSDrawerState</code> class.
	 */
	private function NSDrawerState(value:Number) {
		super(value);
	}
}