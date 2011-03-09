/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * This class draws the left resizing cursor. 
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASResizeLeftCursorRep extends NSImageRep 
{
	public function ASResizeLeftCursorRep() 
	{
		m_size = new NSSize(18,8);
		super();
	}

	public function description():String 
	{
		return "ASResizeLeftCursorRep(size=" + size() + ")";
	}
	
	public function draw():Void
	{
		var mc:MovieClip = m_drawClip;
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var w:Number = size().width;
		var h:Number = size().height;
		var capOffset:Number = w / 4;
		var barWidth:Number = h / 6;
		
		mc.lineStyle(.5, 0xDDDDDD, 100);
		mc.beginFill(0x000000);
		mc.moveTo(x, y + h / 2);
		mc.lineTo(x + capOffset, y);
		mc.lineTo(x + capOffset, y + h / 2 - barWidth);
		mc.lineTo(x + w, y + h / 2 - barWidth);
		mc.lineTo(x + w, y + h / 2 + barWidth);
		mc.lineTo(x + capOffset, y + h/ 2 + barWidth);
		mc.lineTo(x + capOffset, y + h);
		mc.lineTo(x, y + h / 2);
		mc.endFill();
	}
	
}