/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSButtonCell;
import org.actionstep.NSColor;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.ASThemeProtocol;

/**
 * @author Scott Hyndman
 */
class org.actionstep.toolbar.items.ASToolbarItemButtonCell extends NSButtonCell {
	
	//******************************************************
	//*                    Overrides
	//******************************************************
	
	/**
	 * Overridden to draw the correct colors.
	 */
	private function drawBackgroundWithFrameMaskInView(frame:NSRect, mask:Number, 
			controlView:NSView):Void {
		// FIXME should be in theme
		if (mask & NSChangeBackgroundCellMask) {
			var g:ASGraphics = controlView.graphics();
			var theme:ASThemeProtocol = ASTheme.current();
			var border:NSColor = theme.colorWithName(ASThemeColorNames.ASSelectedToolbarItemBorder);
			var bg:NSColor = theme.colorWithName(ASThemeColorNames.ASSelectedToolbarItemBackground);
			
			g.brushDownWithBrush(border);
			g.drawRectWithRect(frame);
			g.brushUp();
			
			g.brushDownWithBrush(bg);
			g.drawRectWithRect(frame.insetRect(1, 0));
		} else {
			// do nothing
		}
	}
	
	/**
	 * Overridden to position parts
	 */
	private function positionParts(cellFrame:NSRect, imageSize:NSSize,
			titleSize:NSSize):NSPoint {
				
		//
		// Determine border size
		//
		var borderSize:NSSize;
		if (m_bordered) {
			borderSize = new NSSize(2,2);
		} else {
			borderSize = new NSSize(0,0);
		}
		if ((m_bordered && m_imagePosition != NSCellImagePosition.NSImageOnly)
				|| m_bezeled) {
			borderSize.width += 2;
			borderSize.height += 2;
		}
		
		//
		// Set up vars
		//
		var imageLocation:NSPoint = NSPoint.ZeroPoint;
		var x:Number = cellFrame.origin.x;
		var y:Number = cellFrame.origin.y;
		var width:Number = cellFrame.size.width-1;
		var height:Number = cellFrame.size.height-1;
		
		var combinedHeight:Number = imageSize.height+titleSize.height;
		var combinedWidth:Number = imageSize.width+titleSize.width;
		
		//
		// Position textfield and determine image location
		//
		switch (m_imagePosition) {
			case NSCellImagePosition.NSNoImage:
				m_textField._y = int(y + (height - titleSize.height)/2);
				switch(m_alignment) {
					case NSTextAlignment.NSRightTextAlignment:
						m_textField._x = int(x + width - borderSize.width/2 - titleSize.width);
						break;
					case NSTextAlignment.NSLeftTextAlignment:
						m_textField._x = int(borderSize.width/2);
						break;
					case NSTextAlignment.NSCenterTextAlignment :
					default:
						m_textField._x = int(x + (width - titleSize.width)/2);
						break;
				}
				break;
		
			case NSCellImagePosition.NSImageOnly:
				imageLocation.x = x + (width - imageSize.width)/2;
				imageLocation.y = y + (height - imageSize.height)/2;
				break;
		
			case NSCellImagePosition.NSImageAbove:
				imageLocation.x = x + (width - imageSize.width)/2;
				imageLocation.y = y + (height - combinedHeight)/2;
				m_textField._x = x + (width - titleSize.width)/2;
				m_textField._y = y + height - titleSize.height + 1;
				break;
		
			default:
				return super.positionParts(cellFrame, imageSize, titleSize);
		}
		
		return imageLocation;
	}
}