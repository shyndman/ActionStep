/* See LICENSE for copyright and terms of use */

import org.actionstep.NSWindow;

/**
 * A window that cannot become main.
 * 
 * @author Scott Hyndman
 */
class org.aib.ui.ToolWindow extends NSWindow {
	
	public function canBecomeMainWindow():Boolean {
		return false;
	}
}