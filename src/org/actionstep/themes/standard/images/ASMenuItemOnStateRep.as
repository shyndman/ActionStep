/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * This class draws the image for the on state for the
 * <code>org.actionstep.menu.NSMenuItemCell</code> class.
 *
 * It draws a checkmark, which will be displayed at the extreme left.
 *
 * @author Richard Kilmer
 */
class org.actionstep.themes.standard.images.ASMenuItemOnStateRep extends NSImageRep {

  public function ASMenuItemOnStateRep() {
    m_size = new NSSize(16,16);
  }

  public function description():String {
    return "ASMenuItemOnStateRep";
  }

  public function draw() {
    var x:Number = m_drawPoint.x;
    var y:Number = m_drawPoint.y;

    m_drawClip.lineStyle(1, 0x232831, 100);
    m_drawClip.beginFill(0x232831);
    m_drawClip.moveTo(x+3, y+8);
    m_drawClip.lineTo(x+7, y+12);
    m_drawClip.lineTo(x+13, y+6);
    m_drawClip.lineTo(x+13, y+5);
    m_drawClip.lineTo(x+12, y+5);
    m_drawClip.lineTo(x+7, y+10);
    m_drawClip.lineTo(x+4, y+7);
    m_drawClip.endFill();
  }
}