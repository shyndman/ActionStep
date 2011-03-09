/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.NSButton;
import org.actionstep.NSImage;
import org.actionstep.NSMenuItem;
import org.actionstep.NSSize;
import org.actionstep.NSToolbarItem;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeImageNames;
import org.actionstep.toolbar.items.ASToolbarItemBackView;
import org.actionstep.toolbar.items.ASToolbarItemButton;

/**
 * A toolbar item separator.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.toolbar.items.ASToolbarSeparatorItem extends NSToolbarItem {
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASToolbarSeparatorItem</code> class.
	 */
	public function ASToolbarSeparatorItem() {
	}
	
	public function initWithItemIdentifier(identifier:String):ASToolbarSeparatorItem {
		return ASToolbarSeparatorItem(super.initWithItemIdentifier(identifier));
	}
	
	private function constructBackView():Void {
		super.constructBackView();
				
		m_image = NSImage.imageNamed(ASThemeImageNames.NSToolbarSeparatorItemImage);
		m_image.setScalesWhenResized(true);
		ASToolbarItemButton(m_backView).setImage(m_image);
		ASToolbarItemButton(m_backView).setImagePosition(NSCellImagePosition.NSImageOnly);
		ASToolbarItemButton(m_backView).setEnabled(false);
	}
	
	//******************************************************
	//*              Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the ASToolbarSeparatorItem instance.
	 */
	public function description():String {
		return "ASToolbarSeparatorItem()";
	}
	
	//******************************************************
	//*                     Menus
	//******************************************************
	
	/**
	 * Returns a separator menu item.
	 */
	public function __defaultMenuFormRepresentation():NSMenuItem {
		return NSMenuItem.separatorItem();	
	}
	
	//******************************************************
	//*                Layout management
	//******************************************************
	
	public function __layout():Void {
		var h:Number = ASTheme.current().toolbarHeightForToolbar(m_toolbar);
				
		m_image.setSize(new NSSize(m_image.bestRepresentationForDevice().size().width, h - 8));
		m_backView.setFrameSize(new NSSize(16, h));
		m_backView.setNeedsDisplay(true);
	}
}