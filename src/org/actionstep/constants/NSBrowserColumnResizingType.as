/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * The following constants are defined by {@link org.actionstep.NSBrowser} to 
 * describe types of browser column resizing, and are used by 
 * {@link org.actionstep.NSBrowser#setColumnResizingType()} and 
 * {@link org.actionstep.NSBrowser#columnResizingType()}.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSBrowserColumnResizingType extends ASConstantValue {
	
	/**
	 * Neither NSBrowser nor the user can change the column width. The 
	 * developer must explicitly set all column widths.
	 */
	public static var NSBrowserNoColumnResizing:NSBrowserColumnResizingType 
		= new NSBrowserColumnResizingType(0);
	
	/**
	 * All columns have the same width, calculated using a combination of the 
	 * minimum column width and maximum number of visible columns settings. The 
	 * column width changes as the window size changes. The user cannot resize 
	 * columns.
	 */
	public static var NSBrowserAutoColumnResizing:NSBrowserColumnResizingType 
		= new NSBrowserColumnResizingType(1);
		
	/**
	 * The developer chooses the initial column widths, but users can resize 
	 * all columns simultaneously or each column individually.
	 */
	public static var NSBrowserUserColumnResizing:NSBrowserColumnResizingType 
		= new NSBrowserColumnResizingType(2);
		
	/**
	 * Creates a new instance of the <code>NSBrowserColumnResizingType</code> class.
	 */
	private function NSBrowserColumnResizingType(value:Number) {
		super(value);
	}
}