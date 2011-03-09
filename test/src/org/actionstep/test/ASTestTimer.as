/* See LICENSE for copyright and terms of use */
 
import org.actionstep.NSTimer;

/**
 * Tests the <code>NSTimer</code> class.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.test.ASTestTimer {
  
  public static function test() {
    var tmp:ASTestTimer = new ASTestTimer();
  }
  
  public function ASTestTimer() {
    var startDate:Date = new Date();
    startDate.setTime(startDate.getTime()+6000);
    NSTimer.scheduledTimerWithTimeIntervalTargetSelectorUserInfoRepeats(5, 
      this, "once", {foo:"bar"}, false);
    (new NSTimer()).initWithFireDateIntervalTargetSelectorUserInfoRepeats(
      startDate, 1, this, "repeater", {count:0}, true);
  }
  
  public function once(timer:NSTimer) {
    trace(timer.userInfo().foo);
  }
  
  public function repeater(timer:NSTimer) {
    trace(timer.userInfo().count);
    timer.userInfo().count++;
    if (timer.userInfo().count == 4) {
      timer.invalidate();
    }
  }
}