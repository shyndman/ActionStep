/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * This class draws the unpressed switch for the
 * <code>org.actionstep.NSButton</code> class.
 * 
 * It is used by <code>org.actionstep.NSButtonCell</code>.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.themes.standard.images.ASSwitchRep extends NSImageRep {
  
  public function ASSwitchRep() {
    m_size = new NSSize(16,16);
  }

  public function description():String {
    return "ASSwitchRep";
  }
  
  public function draw() {
    var x:Number = m_drawPoint.x;
    var y:Number = m_drawPoint.y;
    var width:Number = m_drawRect.size.width;
    var height:Number = m_drawRect.size.height;
    m_drawClip.lineStyle(1, 0x696E79, 100);
    m_drawClip.moveTo(x, y);
    m_drawClip.lineTo(x + width, y);
    m_drawClip.lineStyle(1, 0xF6F8F9, 100);
    m_drawClip.lineTo(x + width, y + height);
    m_drawClip.lineTo(x, y + height);
    m_drawClip.lineStyle(1, 0x696E79, 100);
    m_drawClip.lineTo(x, y);
  }
}