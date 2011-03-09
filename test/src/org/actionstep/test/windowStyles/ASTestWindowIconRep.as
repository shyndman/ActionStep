/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.NSImageRep;

/**
 * An icon image for a window.
 * 
 * Used by <code>org.actionstep.test.ASTestWindowStyles</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.windowStyles.ASTestWindowIconRep 
	extends NSImageRep {

	public function ASTestWindowIconRep() 
	{
		super();
	}

	public function description():String 
	{
		return "ASTestWindowIconRep(size=" + size() + ")";
	}
	
	public function draw():Void
	{
		var mc:MovieClip = m_drawClip;
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var sp:Number = 2;
		var rectWidth:Number = (size().width - sp * 3) / 2;
		var rectHeight:Number = (size().height - sp * 3) / 2;
		
		ASDraw.fillRect(mc, x, y, size().width, size().height, 0xB3C1DA);
		ASDraw.fillRect(mc, x + sp, y + sp, rectWidth, rectHeight, 0xD6EBF3);
		ASDraw.fillRect(mc, x + rectWidth + 2*sp, y + sp, rectWidth, rectHeight, 0xE4F4F7);
		ASDraw.fillRect(mc, x + sp, y + rectHeight + 2*sp, rectWidth, rectHeight, 0xE0F1F6);
	}
}