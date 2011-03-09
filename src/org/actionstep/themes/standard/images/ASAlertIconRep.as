/* See LICENSE for copyright and terms of use */

import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSColor;
import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * Base class for <code>org.actionstep.NSAlert</code> icons.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASAlertIconRep extends NSImageRep {
  
  private var m_graphic:ASGraphics;
  
  /**
   * Creates a new instance of the <code>ASAlertIconRep</code> class.
   */
  public function ASAlertIconRep() {
    m_size = new NSSize(64,64);
    m_graphic = (new ASGraphics()).init();
  }

  /**
   * Returns a string representation of the image rep.
   */
  public function description():String {
    return "ASAlertIconRep(size=" + size() + ")";
  }
  
  /**
   * Overridden to set the graphic's clip.
   */
  public function setFocus(mc:MovieClip):Void {
    super.setFocus(mc);
    m_graphic.setClip(mc);
  }
  
  /**
   * Draws the image rep.
   */
  public function draw() {
  	//
  	// Drawn at (0,0) to force use of mc:(_x, _y)
  	//
    m_graphic.drawRect(m_drawPoint.x, m_drawPoint.y,
      m_size.width, m_size.height, new NSColor(0xC7CAD1), 0.25);
  }
}