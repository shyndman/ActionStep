/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSControlSize;
import org.actionstep.constants.NSToolbarDisplayMode;
import org.actionstep.constants.NSToolbarSizeMode;
import org.actionstep.NSButton;
import org.actionstep.NSFont;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSToolbarItem;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeProtocol;
import org.actionstep.toolbar.items.ASToolbarItemBackView;
import org.actionstep.toolbar.items.ASToolbarItemBackViewProtocol;
import org.actionstep.toolbar.items.ASToolbarItemButtonCell;
import org.actionstep.NSToolbar;
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.constants.NSTextAlignment;

/**
 * The default visual representation of an <code>NSToolbarItem</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.toolbar.items.ASToolbarItemButton extends NSButton
		implements ASToolbarItemBackViewProtocol {
	
	private static var g_cellClass:Function = ASToolbarItemButtonCell;
	
	private var m_item:NSToolbarItem;
	private var m_itemAction:String;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASToolbarItemButton</code> class.
	 */
	public function ASToolbarItemButton() {
	}
	
	/**
	 * Initializes the toolbar item button with a toolbar item.
	 */
	public function initWithToolbarItem(item:NSToolbarItem):ASToolbarItemButton {
		super.initWithFrame(new NSRect(0, 0, 
			ASToolbarItemBackView.ASDefaultWidth, 
			ASToolbarItemBackView.ASDefaultHeight));
		m_item = item;
		setAlignment(NSTextAlignment.NSCenterTextAlignment);
		return this;
	}
	
	//******************************************************
	//*                   Properties
	//******************************************************
	
	public function setToolbarItemAction(sel:String):Void {
		m_itemAction = sel;
	}
	
	public function toolbarItemAction():String {
		return m_itemAction;
	}
	
	public function toolbarItem():NSToolbarItem {
		return m_item;
	}
	
	//******************************************************
	//*                 Sending actions
	//******************************************************
	
	public function sendActionTo(theAction:String, theTarget:Object):Boolean {
		if (m_item.__selectable()) {
			m_item.toolbar().setSelectedItemIdentifier(m_item.itemIdentifier());
		}
		
		if (m_itemAction != null) {
			return m_app.sendActionToFrom(m_itemAction, theTarget, m_item);
		}
		
		return false;
	}
  
	//******************************************************
	//*           ASToolbarItemBackViewProtocol
	//******************************************************
	
	public function layout():Void {
		var lW:Number = -1, lH:Number = -1, imgWH:Number;
		var theme:ASThemeProtocol = ASTheme.current();
		var tb:NSToolbar = m_item.toolbar();
		var sizeMode:NSToolbarSizeMode = tb.sizeMode();
		var displayMode:NSToolbarDisplayMode = tb.displayMode();
		
		//
		// Set the font
		//
		var font:NSFont = sizeMode == NSToolbarSizeMode.NSToolbarSizeModeRegular
			? theme.boldSystemFontOfSize(13) // FIXME put constant in theme
			: theme.boldSystemFontOfSize(11); // FIXME put constant in theme
		m_cell.setFont(font);
		
		//
		// Set the image size
		//
		lW = lH = theme.toolbarHeightForToolbar(tb) - 1;
		imgWH = theme.toolbarItemImageSizeForToolbar(tb);;
		m_item.image().setSize(new NSSize(imgWH, imgWH));
		
		//
		// Measure text
		//
		var textSize:NSSize;
		
		if (displayMode != NSToolbarDisplayMode.NSToolbarDisplayModeIconOnly) {
			var lbl:String = m_item.label();
			if (lbl == null || lbl.length == 0) {
				lbl = "Dummy";
			}
			textSize = font.getTextExtent(lbl);
			textSize.width += 6;
			textSize.height -= 2;
			if (textSize.width > lW) {
				lW = textSize.width;
			}
		} else {
			textSize = NSSize.ZeroSize;
		}
		
		//
		// Adjust size and positioning according to display mode
		//
		switch (displayMode) {
			case NSToolbarDisplayMode.NSToolbarDisplayModeIconAndLabel:
				setImagePosition(NSCellImagePosition.NSImageAbove);
				if (imgWH + textSize.height > lH) {
					lH = imgWH + textSize.height;
				}
				break;
				
			case NSToolbarDisplayMode.NSToolbarDisplayModeIconOnly:
				setImagePosition(NSCellImagePosition.NSImageOnly);
				//lH -= textSize.height;
				break;
				
			case NSToolbarDisplayMode.NSToolbarDisplayModeLabelOnly:
				setImagePosition(NSCellImagePosition.NSNoImage);
				lH = textSize.height;
				break;
		}
		
		//
		// Set the size
		//
		setFrameSize(new NSSize(lW, lH));
	}
	
	//******************************************************
	//*              Required by NSControl
	//******************************************************
	
	public static function cellClass():Function {
		return g_cellClass;
	}
	
	public static function setCellClass(cellClass:Function) {
		if (cellClass == null) {
			g_cellClass = ASToolbarItemButtonCell;
		} else {
			g_cellClass = cellClass;
		}
	}


}