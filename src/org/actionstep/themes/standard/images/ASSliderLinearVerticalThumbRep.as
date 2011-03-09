/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.NSSize;
import org.actionstep.themes.standard.images.ASSliderLinearThumbRep;

/**
 * Draws a linear vertical slider thumb.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASSliderLinearVerticalThumbRep 
		extends ASSliderLinearThumbRep {
	
	/**
	 * Creates a new instance of the <code>ASSliderThumbRep</code> class.
	 */
	public function ASSliderLinearVerticalThumbRep() {
		super();
		m_size = new NSSize(20, 20);
	}
	
	/**
	 * Returns a string representation of the image rep.
	 */
	public function description():String
	{
		return "ASSliderLinearVerticalThumbRep(size=" + size() + ")";
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
		var pointLen:Number = h * 0.3;
		var inset:Number = w * 0.1;
		
		var xy:Array;
		if (!m_flipped) {
			xy = [
				[x + w - pointLen, y],
				[x + w, y + h / 2],
				[x + w - pointLen, y + h],
				[x, y + h - inset],
				[x, y + inset],
				[x + w - pointLen, y]];
		} else {
			xy = [
				[x + pointLen, y],
				[x, y + h / 2],
				[x + pointLen, y + h],
				[x + w, y + h - inset],
				[x + w, y + inset],
				[x + pointLen, y]];
		}
		
		ASDraw.fillShape(mc, xy, 0xADD6FF);
		ASDraw.drawShape(mc, xy, 0x444444);
			
		return true;
	}
}