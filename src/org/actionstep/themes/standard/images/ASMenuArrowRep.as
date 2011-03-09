/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * This class draws a vertical arrow pointing to the right for menu items
 * to indicated the presence of submenus.
 *
 * It is used by <code>org.actionstep.NSMenuItemCell</code>, when the item is
 * not highlighted.
 *
 * @author Tay Ray Chuan
 */

class org.actionstep.themes.standard.images.ASMenuArrowRep extends NSImageRep {

	public function ASMenuArrowRep() {
		m_size = new NSSize(16,16);
	}

	public function description():String {
		return "ASMenuArrowRep";
	}

	public function draw():Void {
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var w:Number = m_size.width;
		var h:Number = m_size.height;

		with(m_drawClip) {
			beginFill(0x333333, 100);
			lineStyle(0, 0x333333, 0, true, "none");
			moveTo(x+4, y+3);
			lineTo(x+4, y+13);
			lineTo(x+11, y+8);
			lineTo(x+4, y+3);
			endFill();
		}
	}
}