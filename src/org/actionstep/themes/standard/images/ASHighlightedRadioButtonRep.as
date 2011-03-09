/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;
import org.actionstep.ASDraw;

/**
 * This class draws the highlighted (pressed) radio button image for the
 * <code>org.actionstep.NSButton</code> class when it is in radio button mode.
 * 
 * It is used by <code>org.actionstep.NSButtonCell</code>.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.themes.standard.images.ASHighlightedRadioButtonRep extends NSImageRep {
  
  public function ASHighlightedRadioButtonRep() {
    m_size = new NSSize(16,16);
  }
  
  public function description():String {
    return "ASHighlightedRadioButtonRep(size=" + size() + ")";
  }
  
  public function draw() {
    var x:Number = m_drawPoint.x + m_drawRect.size.width/2;
    var y:Number = m_drawPoint.y + m_drawRect.size.height/2;
    ASDraw.fillCircle(m_drawClip, 1, 0, 0xC7CAD1, m_drawRect.size.width/2 - 2, x, y);
    ASDraw.fillCircle(m_drawClip, 1, 0, 0, m_drawRect.size.width/2 - 4, x, y);
  }
}