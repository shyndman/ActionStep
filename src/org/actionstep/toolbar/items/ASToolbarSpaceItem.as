/* See LICENSE for copyright and terms of use */

import org.actionstep.NSMenuItem;
import org.actionstep.NSSize;
import org.actionstep.NSToolbarItem;
import org.actionstep.toolbar.items.ASToolbarItemBackView;
import org.actionstep.NSControl;

/**
 * Represents a block of space.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.toolbar.items.ASToolbarSpaceItem extends NSToolbarItem {
	
	public function initWithItemIdentifier(identifier:String):NSToolbarItem {
		super.initWithItemIdentifier(identifier);
		setLabel("");
		return this;
	}
	
	private function constructBackView():Void {
		super.constructBackView();
		
		NSControl(m_backView).setEnabled(false);
		m_backView.setFrameSize(new NSSize(10, 2));
	}
	
	public function menuFormRepresentation():NSMenuItem {
		return null;
	}
	
	/**
	 * For internal use only.
	 */
	public function __layout():Void {
		
	}
	
	/**
	 * Returns null
	 */
	public function __defaultMenuFormRepresentation():NSMenuItem {
		return null;	
	}
}