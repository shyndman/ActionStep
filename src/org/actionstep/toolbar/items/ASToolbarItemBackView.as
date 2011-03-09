/* See LICENSE for copyright and terms of use */

import org.actionstep.NSToolbarItem;
import org.actionstep.NSView;
import org.actionstep.toolbar.items.ASToolbarItemBackViewProtocol;

/**
 * Used as the background for custom views.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.toolbar.items.ASToolbarItemBackView extends NSView
		implements ASToolbarItemBackViewProtocol {
	
	public static var ASDefaultHeight:Number = 36;
	public static var ASDefaultWidth:Number = 5;
	
	private var m_item:NSToolbarItem;
	
	/**
	 * Creates a new instance of the <code>ASToolbarItemBackView</code> class.
	 */
	public function ASToolbarItemBackView() {
	}
	
	/**
	 * Initializes the toolbar item backview with a toolbar item.
	 */
	public function initWithToolbarItem(item:NSToolbarItem):ASToolbarItemBackView {
		//TODO super.initWithFrame()
		m_item = item;
		return this;
	}
	
	//******************************************************
	//*           ASToolbarItemBackViewProtocol
	//******************************************************
	
	public function layout():Void {
		
	}
	
	public function toolbarItem():NSToolbarItem {
		return m_item;
	}
}