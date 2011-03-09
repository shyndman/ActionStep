/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * This class draws the highlighted (pressed) left arrow for the
 * <code>org.actionstep.NSScroller</code> class.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.themes.standard.images.ASHighlightedScrollerLeftArrowRep extends NSImageRep {
  
  public function ASHighlightedScrollerLeftArrowRep() {
    m_size = new NSSize(9,9);
  }

  public function description():String {
    return "ASHighlightedScrollerLeftArrowRep";
  }
  
  public function draw() {
    var x:Number = m_drawPoint.x;
    var y:Number = m_drawPoint.y;
    var width:Number = m_drawRect.size.width;
    var height:Number = m_drawRect.size.height;
    m_drawClip.beginFill(0x4B4F57, 100);
    m_drawClip.lineStyle(1, 0x696E79, 100);
    m_drawClip.moveTo(x, y + height/2);
    m_drawClip.lineTo(x + width, y);
    m_drawClip.lineStyle(1, 0xF6F8F9, 100);
    m_drawClip.lineTo(x + width, y+height);
    m_drawClip.lineTo(x, y + height/2);
    m_drawClip.endFill();
  }
}