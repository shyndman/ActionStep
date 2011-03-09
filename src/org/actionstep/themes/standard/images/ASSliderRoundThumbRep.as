/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * Draws a round slider thumb.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASSliderRoundThumbRep extends NSImageRep {
	
	/**
	 * Creates a new instance of the <code>ASSliderThumbRep</code> class.
	 */
	public function ASSliderRoundThumbRep() {
		super();
		m_size = new NSSize(20, 20);
	}
	
	/**
	 * Returns a string representation of the image rep.
	 */
	public function description():String
	{
		return "ASSliderRoundThumbRep(size=" + size() + ")";
	}
	
	/**
	 * Draws the image rep.
	 */
	public function draw():Boolean
	{
		//
		// Prepare vars for drawing
		//
		var mc:MovieClip = m_drawClip;
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var w:Number = size().width - 1;
		var h:Number = size().height - 1;
		
		
		
		
		//
		// Draw
		//
		ASDraw.gradientEllipse(mc, x, y, w, h, [0xADD6FF, 0x427BC6], 
			[0, 255]);
		return true;
	}
}