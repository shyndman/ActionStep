/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * This class draws the standard arrow cursor. 
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASArrowCursorRep extends NSImageRep 
{
	public function ASArrowCursorRep() 
	{
		m_size = new NSSize(12,20);
		super();
	}

	public function description():String 
	{
		return "ASArrowCursorRep(size=" + size() + ")";
	}
	
	public function draw():Void
	{		
		var mc:MovieClip = m_drawClip;
		
		mc.lineStyle(.5, 0x000000, 100);
		mc.beginFill(0xDDDDDD);
		mc.moveTo(0, 0);
		mc.lineTo(0, 15.6);
		mc.lineTo(4, 13);
		mc.lineTo(7, 20);
		mc.lineTo(9, 19);
		mc.lineTo(6, 12);
		mc.lineTo(11, 11);
		mc.lineTo(0, 0);
		mc.endFill();
	}
	
}