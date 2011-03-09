/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * Draws a linear slider thumb.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASSliderLinearThumbRep extends NSImageRep {
	
	private var m_flipped:Boolean;
	
	/**
	 * Creates a new instance of the <code>ASSliderLinearThumbRep</code> class.
	 */
	public function ASSliderLinearThumbRep() {
		super();
		m_size = new NSSize(20, 20);
		m_flipped = false;
	}
	
	/**
	 * Returns a string representation of the image rep.
	 */
	public function description():String
	{
		return "ASSliderLinearThumbRep(size=" + size() + ")";
	}
	
	/**
	 * Sets whether the image should be drawn flipped.
	 */
	public function setFlipped(flag:Boolean):Void {
		m_flipped = flag;
	}
}