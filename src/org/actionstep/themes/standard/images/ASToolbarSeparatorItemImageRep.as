/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.ASDraw;
import org.actionstep.NSSize;
import org.actionstep.NSColor;
import org.actionstep.NSRect;
import org.actionstep.ASColors;

/**
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASToolbarSeparatorItemImageRep extends NSImageRep {
	
	private static var g_color1:NSColor;
	private static var g_color2:NSColor;
	
	/**
	 * Creates a new instance of the <code>ASToolbarSeparatorItemImageRep</code> class.
	 */
	public function ASToolbarSeparatorItemImageRep() {
		m_size = new NSSize(10, 32);
	}
		
	public function draw():Boolean {
		var mc:MovieClip = m_drawClip;
		g_graphics.setClip(mc);
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var w:Number = m_size.width;
		var h:Number = m_size.height;
		var drawX:Number = Math.round(w / 2 + x);
		
		g_graphics.brushDownWithBrush(g_color1);
		g_graphics.drawRectWithRect(new NSRect(
			drawX, y, 2, m_size.height));
		g_graphics.brushUp();
		g_graphics.brushDownWithBrush(g_color2);
		g_graphics.drawRectWithRect(new NSRect(
			drawX + 1, y, 1, m_size.height));
		g_graphics.brushUp();
		
		return true;
	}
	
	private static function initialize():Void {
		g_color1 = new NSColor(0x888888);
		g_color2 = new NSColor(0xCCCCCC);
	}
}