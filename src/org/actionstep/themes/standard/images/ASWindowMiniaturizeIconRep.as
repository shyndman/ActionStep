/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * The window's miniaturize icon.
 * 
 * Used by the <code>org.actionstep.NSWindow.ASRootWindowView</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASWindowMiniaturizeIconRep extends NSImageRep 
{
	public function ASWindowMiniaturizeIconRep()
	{
		super();
		m_size = new NSSize(8, 10);
	}
	
	public function description():String 
	{
		return "ASWindowMiniaturizeIconRep(size=" + size() + ")";
	}
	
	public function draw():Void
	{
		var mc:MovieClip = m_drawClip;
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var w:Number = size().width;
		var h:Number = size().height;
		var barw:Number = h / 6;
		
		//mc.lineStyle(.5, 0x000000, 100);
		mc.beginFill(0x000000, 100);
		mc.moveTo(x, y + h);
		mc.lineTo(x + w, y + h);
		mc.lineTo(x + w, y + h - barw);
		mc.lineTo(x, y + h - barw);
		mc.endFill();
	}
}