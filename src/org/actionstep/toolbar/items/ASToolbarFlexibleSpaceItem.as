/* See LICENSE for copyright and terms of use */

import org.actionstep.NSMenuItem;
import org.actionstep.NSSize;
import org.actionstep.NSToolbarItem;

/**
 * @author Scott Hyndman
 */
class org.actionstep.toolbar.items.ASToolbarFlexibleSpaceItem extends NSToolbarItem {
	public function initWithItemIdentifier(identifier:String):NSToolbarItem {
		super.initWithItemIdentifier(identifier);
		setLabel("");
		setVisibilityPriority(200);
		__layout();
		return this;
	}
	
	public function menuFormRepresentation():NSMenuItem {
		return null;
	}
	
	public function __layout():Void {
		m_backView.setFrameSize(new NSSize(0, 2));
	}
	
	/**
	 * Returns null
	 */
	public function __defaultMenuFormRepresentation():NSMenuItem {
		return null;	
	}
}