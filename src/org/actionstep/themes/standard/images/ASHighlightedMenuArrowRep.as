/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * This class draws a white vertical arrow pointing to the right for menu items
 * to indicated the presence of submenus.
 *
 * It is used by <code>org.actionstep.NSMenuItemCell</code>, when in the
 * highlighted state.
 *
 * @author Rich Kilmer
 */

class org.actionstep.themes.standard.images.ASHighlightedMenuArrowRep extends NSImageRep {

	public function ASHighlightedMenuArrowRep() {
		m_size = new NSSize(16,16);
	}

	public function description():String {
		return "ASHighlightedMenuArrowRep";
	}

	public function draw():Void {
		var x:Number = m_drawPoint.x;
		var y:Number = m_drawPoint.y;
		var w:Number = m_size.width;
		var h:Number = m_size.height;

		with(m_drawClip) {
		 	beginFill(0xffffff, 100);
			lineStyle(0, 0xffffff, 0, true, "none");
			moveTo(x+4, y+3);
			lineTo(x+4, y+13);
			lineTo(x+11, y+8);
			lineTo(x+4, y+3);
			endFill();
		}
	}
}