/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.NSColor;
import org.actionstep.NSImageRep;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;

/**
 * This class draws a color swatch of the color supplied to the 
 * <code>#setColor()</code> method. This image can be cloned to avoid color
 * changes when in use.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASColorSwatchRep extends NSImageRep {
	
	/** The color to draw */
	private var m_color:NSColor;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASColorSwatchRep</code> class.
	 */
	public function ASColorSwatchRep() {
		m_size = new NSSize(16, 16);
	}
	
	/**
	 * Returns a string representation of the ASColorSwatchRep instance.
	 */
	public function description():String {
		return "ASColorSwatchRep(size=" + size() + ")";
	}
	
	//******************************************************
	//*               Setting the color
	//******************************************************
	
	/**
	 * Sets the color this image will draw to <code>color</code>.
	 */
	public function setColor(color:NSColor):Void {
		m_color = color.copyWithZone();
	}
	
	//******************************************************
	//*                    Drawing
	//******************************************************
	
	/**
	 * Draws the color swatch.
	 */
	public function draw():Void {
		var rect:NSRect = NSRect.withOriginSize(m_drawPoint, size());
		
		//
		// Draw the outlines
		//
		g_graphics.setClip(m_drawClip);
		
		//
		// Dark border
		//
		g_graphics.brushDownWithBrush(new NSColor(0xAAAAAA));
		g_graphics.drawRectWithRect(rect);
		g_graphics.brushUp();
		
		rect = rect.insetRect(1, 1);
		
		//
		// Light border
		//
		g_graphics.brushDownWithBrush(ASColors.whiteColor());
		g_graphics.drawRectWithRect(rect);
		g_graphics.brushUp();
		
		rect = rect.insetRect(1, 1);
		
		//
		// Black triangle
		//
		if (m_color.alphaValue != 100) {
			g_graphics.brushDownWithBrush(ASColors.blackColor());
			g_graphics.drawPolygonWithPoints([
				new NSPoint(rect.minX(), rect.minY()),
				new NSPoint(rect.maxX(), rect.minY()),
				new NSPoint(rect.minX(), rect.maxY())]);
			g_graphics.brushUp();
		}
		
		//
		// Swatch color
		//
		g_graphics.brushDownWithBrush(m_color);
		g_graphics.drawRectWithRect(rect);
		g_graphics.brushUp();
	}
}