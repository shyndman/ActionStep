/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * This class draws the radio button image for the
 * <code>org.actionstep.NSButton</code> class when it is in radio button mode.
 * 
 * It is used by <code>org.actionstep.NSButtonCell</code>.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.themes.standard.images.ASRadioButtonRep extends NSImageRep {
  
  public function ASRadioButtonRep() {
    m_size = new NSSize(16,16);
  }

  public function description():String {
    return "ASRadioButtonRep";
  }
  
  public function draw() {
    var x:Number = m_drawPoint.x + m_drawRect.size.width/2;
    var y:Number = m_drawPoint.y + m_drawRect.size.height/2;
    ASDraw.fillCircle(m_drawClip, 1, 0, 0xC7CAD1, m_drawRect.size.width/2 - 2, x, y);
  }
}