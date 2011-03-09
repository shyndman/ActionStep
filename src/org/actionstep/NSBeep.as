/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;

/**
 * A beep sound.
 * 
 * There is currently no sound. A <code>#beep()</code> invocation results
 * in "beep" being traced.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSBeep extends NSObject {
  public static function beep() {
    trace("Beep");
  }
}