/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;
import org.actionstep.NSRect;

/**
 * Holds AIB user preferences.
 * 
 * @author Scott Hyndman
 */
class org.aib.UserPrefs extends NSObject {
	
	public function paletteFrame():NSRect {
		return new NSRect(631, 16, 302, 224);
	}
	
	public function inspectorFrame():NSRect {
		return new NSRect(662, 285, 252, 424);
	}
	
	public function resourcesFrame():NSRect {
		return new NSRect(47, 403, 402, 224);
	}
}