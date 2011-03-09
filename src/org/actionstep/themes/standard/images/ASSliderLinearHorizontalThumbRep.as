/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.NSSize;
import org.actionstep.themes.standard.images.ASSliderLinearThumbRep;

/**
 * Draws a linear, horizontal slider thumb.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASSliderLinearHorizontalThumbRep 
		extends ASSliderLinearThumbRep {
	
	/**
	 * Creates a new instance of the <code>ASSliderThumbRep</code> class.
	 */
	public function ASSliderLinearHorizontalThumbRep() {
		super();
		m_size = new NSSize(20, 20);
	}
	
	/**
	 * Returns a string representation of the image rep.
	 */
	public function description():String
	{
		return "ASSliderLinearHorizontalThumbRep(size=" + size() + ")";
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
		var pointLen:Number = w * 0.3;
		var inset:Number = h * 0.1;
		
		//
		// Draw depending on tick position
		//
		var xy:Array;
		if (!m_flipped) {
			xy = [
				[x, y + pointLen],
				[x + w / 2, y],
				[x + w, y + pointLen],
				[x + w - inset, y + h],
				[x + inset, y + h],
				[x, y + pointLen]];
		} else {
			xy = [
				[x, y + h - pointLen],
				[x + w / 2, y + h ],
				[x + w, y + h - pointLen],
				[x + w - inset, y],
				[x + inset, y],
				[x, y + h - pointLen]];
		}
		
		ASDraw.fillShape(mc, xy, 0xADD6FF);
		ASDraw.drawShape(mc, xy, 0x444444);
			
		return true;
	}
}