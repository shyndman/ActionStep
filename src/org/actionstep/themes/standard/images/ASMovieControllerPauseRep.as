/* See LICENSE for copyright and terms of use */

import org.actionstep.NSSize;
import org.actionstep.NSImageRep;
import org.actionstep.ASDraw;

/**
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASMovieControllerPauseRep extends NSImageRep {
	public function ASMovieControllerPauseRep() {
		m_size = new NSSize(9,14);
	}
	
	public function description():String {
		return "ASMovieControllerPauseRep";
	}
	
	public function draw() {
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var width:Number = m_drawRect.size.width;
		var height:Number = m_drawRect.size.height;
		var barWidth:Number = (width + 1) / 3;
		
		ASDraw.fillRect(m_drawClip, x, y, barWidth, height, 0x3F3F3F, 100);
		ASDraw.fillRect(m_drawClip, x + width - barWidth, y, barWidth, height, 0x3F3F3F, 100);
	}
}