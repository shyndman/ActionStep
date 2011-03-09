/* See LICENSE for copyright and terms of use */

import org.actionstep.NSPanel;

/**
 * The <code>NSPanel</code> used for menus.
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.menu.NSMenuPanel extends NSPanel {
	public function canBecomeKeyWindow():Boolean {
		//! fix this
		return true;
	  /*
	  if (this == NSMenuPanel(NSApplication.sharedApplication().mainMenu().window())) {
	    return true;
		}
	  return false;*/
	}

	public function description():String {
		return "NSMenuPanel(number="+m_windowNumber+", frame="+frame()+")";
	}
}