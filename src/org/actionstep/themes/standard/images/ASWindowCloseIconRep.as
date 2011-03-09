/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * The window's close icon.
 * 
 * Used by the <code>org.actionstep.NSWindow.ASRootWindowView</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASWindowCloseIconRep extends NSImageRep 
{
	public function ASWindowCloseIconRep()
	{
		super();
		m_size = new NSSize(7, 7);
	}
	
	public function description():String 
	{
		return "ASWindowCloseIconRep(size=" + size() + ")";
	}
	
	public function draw():Void
	{
		var mc:MovieClip = m_drawClip;
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var w:Number = size().width;
		var h:Number = size().height;
		
		mc.lineStyle(1.3, 0x000000, 100);
		mc.moveTo(x, y);
		mc.lineTo(x + w, y + h);
		mc.moveTo(x, y + h);
		mc.lineTo(x + w, y);
	}
}