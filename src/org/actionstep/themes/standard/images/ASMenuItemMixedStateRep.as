/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * This class draws the image for the on state for the
 * <code>org.actionstep.menu.NSMenuItemCell</code> class.
 *
 * A horizontal dash is drawn on the extreme left.
 *
 * @author Richard Kilmer
 */
class org.actionstep.themes.standard.images.ASMenuItemMixedStateRep extends NSImageRep {

  public function ASMenuItemMixedStateRep() {
    m_size = new NSSize(16,16);
  }

  public function description():String {
    return "ASMenuItemMixedStateRep";
  }

  public function draw() {
    var x:Number = m_drawPoint.x;
    var y:Number = m_drawPoint.y;
    var w:Number = m_drawRect.size.width;
    var h:Number = m_drawRect.size.height;
    m_drawClip.lineStyle(2, 0x232831, 100);
    m_drawClip.moveTo(x+3, y+8);
    m_drawClip.lineTo(x+w-3, y+8);
  }
}