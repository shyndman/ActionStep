/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * This class draws the up resizing cursor. 
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASResizeUpCursorRep extends NSImageRep 
{
	public function ASResizeUpCursorRep() 
	{
		m_size = new NSSize(8,18);
		super();
	}

	public function description():String 
	{
		return "ASResizeUpCursorRep(size=" + size() + ")";
	}
	
	public function draw():Void
	{
		var mc:MovieClip = m_drawClip;
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var w:Number = size().width;
		var h:Number = size().height;
		var capOffset:Number = h / 4;
		var barWidth:Number = w / 6;
		
		mc.lineStyle(.5, 0xDDDDDD, 100);
		mc.beginFill(0x000000);
		mc.moveTo(x + w / 2, y);
		mc.lineTo(x, y + capOffset);
		mc.lineTo(x + w / 2 - barWidth, y + capOffset);
		mc.lineTo(x + w / 2 - barWidth, y + h);
		mc.lineTo(x + w / 2 + barWidth, y + h);
		mc.lineTo(x + w / 2 + barWidth, y + capOffset);
		mc.lineTo(x + w, y + capOffset);
		mc.lineTo(x + w / 2, y);
		mc.endFill();
	}
	
}