/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * The following constants specify toolbar sizes and are used by 
 * {@link org.actionstep.NSToolbar#sizeMode()} and 
 * {@link org.actionstep.NSToolbar#setSizeMode()}
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSToolbarSizeMode extends ASConstantValue {
		
	/**
	 * The toolbar uses regular-sized controls and 32 by 32 pixel icons.
	 */
	public static var NSToolbarSizeModeRegular:NSToolbarSizeMode 
		= new NSToolbarSizeMode(2);
		
	/**
	 * The toolbar uses small-sized controls and 24 by 24 pixel icons.
	 */
	public static var NSToolbarSizeModeSmall:NSToolbarSizeMode 
		= new NSToolbarSizeMode(3);
	
	/**
	 * The toolbar uses the system-defined default size, which is 
	 * {@link #NSToolbarSizeModeRegular}.
	 */
	public static var NSToolbarSizeModeDefault:NSToolbarSizeMode 
		= NSToolbarSizeModeRegular;
		
	/**
	 * Creates a new instance of the <code>NSToolbarSizeMode</code> class.
	 */
	private function NSToolbarSizeMode(value:Number) {
		super(value);
	}
}