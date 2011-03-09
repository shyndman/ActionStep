/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * This class draws the glyph associated with the Control modifier.
 *
 * @see org.actionstep.NSEvent#NSControlModifierMask
 * @author Tay Ray Chuan
 */
class org.actionstep.themes.standard.images.glyphs.ASControlRep extends NSImageRep {

	public function ASControlRep() {
		m_size = new NSSize(16,16);
	}

	public function description():String {
		return "ASControlRep";
	}

	public function draw():Void {
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var w:Number = m_size.width;
		var h:Number = m_size.height;

		with(m_drawClip) {
			lineStyle(0, 0xFF0000, 100);
			moveTo(x, y);
			lineTo(x, y+h);
			lineTo(x+w, y+h);
			lineTo(x+w, y);
			lineTo(x, y);
			endFill();
		}
	}
}