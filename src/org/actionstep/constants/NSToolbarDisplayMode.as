/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * The following constants toolbar display modes and are used by 
 * {@link org.actionstep.NSToolbar#displayMode()} and 
 * {@link org.actionstep.NSToolbar#setDisplayMode()}.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSToolbarDisplayMode extends ASConstantValue {
			
	/**
	 * The toolbar will display icons and labels.
	 */
	public static var NSToolbarDisplayModeIconAndLabel:NSToolbarDisplayMode 
		= new NSToolbarDisplayMode(2);
		
	/**
	 * The toolbar will display only icons.
	 */
	public static var NSToolbarDisplayModeIconOnly:NSToolbarDisplayMode 
		= new NSToolbarDisplayMode(3);
	
	/**
	 * The toolbar will display only labels.
	 */
	public static var NSToolbarDisplayModeLabelOnly:NSToolbarDisplayMode 
		= new NSToolbarDisplayMode(4);
	
	/**
	 * The default display mode.
	 */
	public static var NSToolbarDisplayModeDefault:NSToolbarDisplayMode 
		= NSToolbarDisplayModeIconOnly;
			
	/**
	 * Creates a new instance of the <code>NSToolbarDisplayMode</code> class.
	 */
	private function NSToolbarDisplayMode(value:Number) {
		super(value);
	}
}