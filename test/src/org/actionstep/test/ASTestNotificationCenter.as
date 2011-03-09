/* See LICENSE for copyright and terms of use */
 
import org.actionstep.ASUtils;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;

/**
 * Test for the <code>org.actionstep.NSNotificationCenter</code> class.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.test.ASTestNotificationCenter {
  
  public var name:String;
  
  public function ASTestNotificationCenter(theName:String) {
    this.name = theName;
  }
  
  public function processEvent(notification:NSNotification) {
    trace(name+ " sees "+notification.object.name+" message "+notification.nameAsString());
  }

  public static function test() {
    var as:ASTestNotificationCenter = new ASTestNotificationCenter("one");
    var as2:ASTestNotificationCenter = new ASTestNotificationCenter("two");
    var as3:ASTestNotificationCenter = new ASTestNotificationCenter("three");
    var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
    nc.addObserverSelectorNameObject(as, "processEvent", ASUtils.intern("NSTestMessage"), as2);
    nc.addObserverSelectorNameObject(as, "processEvent", ASUtils.intern("NSTestMessage2"), as2);
    nc.addObserverSelectorNameObject(as2, "processEvent", ASUtils.intern("NSTestMessage"));
    nc.postNotificationWithNameObject(ASUtils.intern("NSTestMessage"), as2);
    nc.postNotificationWithNameObject(ASUtils.intern("NSTestMessage2"), as2);
    nc.postNotificationWithNameObject(ASUtils.intern("NSTestMessage"), as3);
    trace("removing observer");
    nc.removeObserverNameObject(as, null, as2);
    nc.postNotificationWithNameObject(ASUtils.intern("NSTestMessage"), as2);
    nc.postNotificationWithNameObject(ASUtils.intern("NSTestMessage2"), as2);
    nc.postNotificationWithNameObject(ASUtils.intern("NSTestMessage"), as3);
  }
}