/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;

/**
 * This class draws the image for the off state for the
 * <code>org.actionstep.menu.NSMenuItemCell</code> class.
 *
 * Nothing is drawn.
 *
 * @author Richard Kilmer
 */
class org.actionstep.themes.standard.images.ASMenuItemOffStateRep extends NSImageRep {

  public function ASMenuItemOffStateRep() {
    m_size = new NSSize(16,16);
  }

  public function description():String {
    return "ASMenuItemOffStateRep";
  }
}