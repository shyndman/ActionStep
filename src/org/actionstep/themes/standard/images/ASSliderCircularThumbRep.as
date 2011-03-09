/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.NSImageRep;
import org.actionstep.NSRect;
import org.actionstep.NSSize;

/**
 * Draws a circular slider thumb.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASSliderCircularThumbRep extends NSImageRep {
	
	/**
	 * Creates a new instance of the <code>ASSliderCircularThumbRep</code> class.
	 */
	public function ASSliderCircularThumbRep() {
		super();
		m_size = new NSSize(20, 20);
	}
	
	/**
	 * Returns a string representation of the image rep.
	 */
	public function description():String
	{
		return "ASSliderCircularThumbRep(size=" + size() + ")";
	}
	
	/**
	 * Draws the image rep.
	 */
	public function draw():Boolean
	{
		var mc:MovieClip = m_drawClip;
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var w:Number = size().width - 1;
		var h:Number = size().height - 1;
		var aRect:NSRect = new NSRect(x, y, w, h);
		trace(aRect);
		
		ASDraw.gradientEllipseWithRect(mc, aRect, 
			[0xAAAAAA, 0xAAAAAA],
			[0, 255]);
		
		var highlightRect:NSRect = new NSRect(aRect.midX() - aRect.size.width / 2.6,
		aRect.origin.y, aRect.size.width / 1.3, aRect.height() / 2);
		ASDraw.gradientEllipseWithRect(mc, highlightRect, 
			[0x222222, 0x222222],
			[0, 255]);
		return true;
	
	}
}