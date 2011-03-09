/* See LICENSE for copyright and terms of use */

import org.actionstep.NSSize;
import org.actionstep.NSImageRep;

/**
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASMovieControllerPlayRep extends NSImageRep {
	public function ASMovieControllerPlayRep() {
		m_size = new NSSize(6,14);
	}
	
	public function description():String {
		return "ASMovieControllerPlayRep";
	}
	
	public function draw() {
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var width:Number = m_drawRect.size.width;
		var height:Number = m_drawRect.size.height;
		m_drawClip.beginFill(0x3F3F3F, 100);
		m_drawClip.moveTo(x, y+height);
		m_drawClip.lineTo(x, y);
		m_drawClip.lineTo(x + width, y+height/2);
		m_drawClip.lineTo(x, y+height);
		m_drawClip.endFill();
	}
}