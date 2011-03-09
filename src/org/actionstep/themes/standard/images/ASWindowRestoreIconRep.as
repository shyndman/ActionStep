/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * The window's restore icon.
 * 
 * Used by the <code>org.actionstep.NSWindow.ASRootWindowView</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASWindowRestoreIconRep extends NSImageRep 
{
	public function ASWindowRestoreIconRep()
	{
		super();
		m_size = new NSSize(8, 8);
	}
	
	public function description():String 
	{
		return "ASWindowRestoreIconRep(size=" + size() + ")";
	}
	
	public function draw():Void
	{
		var mc:MovieClip = m_drawClip;
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var w:Number = size().width;
		var h:Number = size().height;
		var wndh:Number = h - h / 3;
		var wndw:Number = w - w / 3;
		
		// TODO make this look better
		
		mc.lineStyle(1.3, 0x000000, 100);
		mc.moveTo(x, y + h - wndh);
		mc.lineTo(x, y + h);
		mc.lineTo(x + wndw, y + h);
		mc.lineTo(x + wndw, y + h - wndh);
		mc.lineTo(x, y + h - wndh);
		
		//
		// Background window
		//
		mc.moveTo(x + w - wndw, y + h - wndh);
		mc.lineTo(x + w - wndw, y);
		mc.lineTo(x + w, y);
		mc.lineTo(x + w, y + wndh);
		mc.lineTo(x + wndw, y + wndh);
	}
}