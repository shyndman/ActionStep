/* See LICENSE for copyright and terms of use */

import org.actionstep.NSButtonCell;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;

/**
 * Handles the display of an <code>org.actionstep.NSStatusItem</code> belonging
 * to an <code>org.actionstep.NSStatusBar</code>.
 * 
 * FIXME For some reason I can't add this to the NSStatusItem namespace.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.statusBar.ASStatusItemCell extends NSButtonCell 
{
		
	//******************************************************															 
	//*              Representing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the ASStatusItemCell instance.
	 */
	public function description():String
	{
		return "ASStatusItemCell()";
	}
	
	//******************************************************															 
	//*                    Drawing
	//******************************************************
	
	/**
	 * Overridden to draw the background differently.
	 */
	private function drawBorderAndBackgroundWithFrameInView(cellFrame:NSRect, 
		inView:NSView, imageLocation:NSPoint, mask:Number):Void 
	{
		ASTheme.current().drawStatusBarBackgroundInRectWithViewHighlight(
			cellFrame, inView, m_enabled && m_highlighted);
	}
}