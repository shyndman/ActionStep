/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * The mute image.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASMuteImageRep extends NSImageRep {
	
	public function ASMuteImageRep() {
		m_size = new NSSize(16, 16);
	}
	
	public function draw():Boolean {
		var mc:MovieClip = m_drawClip;
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var w:Number = m_drawRect.size.width - 1;
		var h:Number = m_drawRect.size.height - 1;
    
    	var baseH:Number = h / 2;
    	var baseW:Number = w / 5;
    	
    	mc.moveTo(x, y + baseH / 2);
    	mc.lineTo(x, y + h - baseH / 2);
    	mc.lineTo(x + baseW, y + h - baseH / 2);
    	
    	
		return true;
	}
}