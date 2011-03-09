/* See LICENSE for copyright and terms of use */

import org.actionstep.NSPoint;
import org.actionstep.NSView;

/**
 * The NSToolTipOwner interface declares a method to provide text to a tooltip.
 * If the method is not implemented, the object's toString() is used instead.
 * 
 * An object implementing this interface can be passed to the 
 * {@link NSView#addToolTipRectOwnerUserData()} method as the 
 * <code>owner</code> parameter.
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.NSToolTipOwner 
{
	/**
	 * Returns the tool tip string to be displayed due to the cursor pausing at 
	 * location <code>point</code> within the tool tip rectangle identified by 
	 * tag in the view <code>view</code>. <code>userData</code> is additional 
	 * information provided by the creator of the tool tip rectangle.
	 * 
	 * If <code>null</code> is returned, no tool tip is displayed.
	 */
	function viewStringForToolTipPointUserData(view:NSView, tag:Number,
		point:NSPoint, userData:Object):String;
}