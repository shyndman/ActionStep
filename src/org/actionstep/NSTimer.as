/* See LICENSE for copyright and terms of use */

//import org.actionstep.NSException;
import org.actionstep.NSObject;

/**
 * Performs a task after some specific amount of time.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSTimer extends NSObject {
	  
  //******************************************************															 
  //*                Member variables
  //******************************************************
  
  //
  // Intervals (setInterval/clearInterval)
  //
  private var m_initialFireInterval:Number;
  private var m_interval:Number;

  private var m_seconds:Number;
  private var m_userInfo:Object;
  private var m_target:Object;
  private var m_selector:String;
  private var m_repeats:Boolean;
  private var m_fireDate:Date;
  private var m_lastFireDate:Date;
  
  //******************************************************															 
  //*                   Construction
  //******************************************************
  
  /**
   * <p>Initializes a new timer that will be allowed to fire at <code>date</code>
   * and if <code>repeats</code> is <code>true</code>, will fire every
   * <code>seconds</code> seconds after that.</p>
   * 
   * <p>When the timer fires, <code>target.selector</code> will be called with
   * two arguments. The first will be the timer instance, and the second will
   * be <code>userInfo</code>.</p>
   */
  public function initWithFireDateIntervalTargetSelectorUserInfoRepeats(
    date:Date, seconds:Number, target:Object, selector:String, userInfo:Object, repeats:Boolean):NSTimer {
    m_seconds = seconds;
    m_fireDate = date;
    m_target = target;
    m_selector = selector;
    m_userInfo = userInfo;
    m_repeats = repeats;
    scheduleToFire();
    return this;
  }
  
  //******************************************************
  //*                 Destruction
  //******************************************************
  
  /**
   * Releases the timer from memory, and clears all references.
   */
  public function release():Boolean {
    super.release();
    
    invalidate();
    m_target = null;
    m_userInfo = null;
    m_fireDate = null;
    m_lastFireDate = null;
    
    return true;
  }
  
  //******************************************************															 
  //*                Firing a timer
  //******************************************************
  
  /**
   * Calls the selector on the timer's target. If the timer is non-repeating, it
   * is automatically invalidated.
   */
  public function fire():Void {
    if (isValid()) {
      try {
        m_target[m_selector].call(m_target, this, userInfo());
      } catch (e:Error) {
        asError(e + ""); 
      }
      
      if (!m_repeats) {
        invalidate();
      }
    }
  }
  
  //******************************************************															 
  //*               Stopping a timer
  //******************************************************
  
  /**
   * Prevents the timer from firing.
   * 
   * This will cause the timer to release its references to the 
   * <code>target</code> and <code>userInfo</code>.
   */
  public function invalidate():Void {
    if (m_initialFireInterval != null) {
      clearInterval(m_initialFireInterval);
      m_initialFireInterval = null;
    }
    if (m_interval != null) {
      clearInterval(m_interval);
      m_interval = null;
    }
    // NOTE: I comment this out because if you clear these values 
    //       before a timer is accessed, it looses the user info access.
    //m_target = null;
    //m_userInfo = null;
  }
  
  //******************************************************															 
  //*            Information about a timer
  //******************************************************
  
  /**
   * Returns <code>true</code> if the timer is valid, of <code>false</code> 
   * otherwise.
   */
  public function isValid():Boolean {
    return (m_interval != null);
  }
  
  /**
   * Returns the date upon which the time will fire. If the timer is no longer
   * valid, this returns the last date upon which the timer fired.
   */
  public function fireDate():Date {
    var date:Date = m_lastFireDate;
    if (date==null) {
      date = m_fireDate;
    }
    var result:Date = new Date();
    result.setTime(date.getTime()+m_seconds*1000);
    return result;
  }
  
  /**
   * Sets the timer to fire next at <code>date</code>.
   */
  public function setFireDate(date:Date):Void {
    invalidate();
    m_fireDate = date;
    scheduleToFire();
  }
  
  /**
   * Returns the timer's time interval.
   */
  public function timeInterval():Number {
    return m_seconds;
  }
  
  /**
   * Returns the <code>userInfo</code> object, which contains information to be 
   * passed to the target when the timer fires.
   */
  public function userInfo():Object {
    return m_userInfo;
  }

  //******************************************************															 
  //*              Describing the object
  //******************************************************
  
  /**
   * Returns a string representation of this instance.
   */
  public function description():String {
    return "NSTimer(target="+m_target+", selector="+m_selector+")";	
  }
  
  //******************************************************															 
  //*               Static constructors
  //******************************************************
  
  /**
   * Initializes and returns a new <code>NSTimer</code> that will fire after
   * <code>seconds</code> seconds, upon which <code>target.selector</code> will
   * be called with two arguments. The first will be the instance of
   * <code>NSTimer</code> and the second will be <code>userInfo</code>.
   * 
   * The timer will fire <code>repeats</code> times.
   */
  public static function scheduledTimerWithTimeIntervalTargetSelectorUserInfoRepeats(
      seconds:Number, target:Object, selector:String, userInfo:Object, 
      repeats:Boolean):NSTimer {
    var timer:NSTimer = new NSTimer();
    timer.initWithFireDateIntervalTargetSelectorUserInfoRepeats(new Date(), 
      seconds, target, selector, userInfo, repeats);
    return timer;
  }
  
  //******************************************************															 
  //*                 Private methods
  //******************************************************
  
  private function scheduleToFire():Void {
    var startTime:Number = m_fireDate.getTime();
    var currentTime:Number = (new Date()).getTime();
    if (startTime < currentTime) {
      start();
      return;
    }
    m_initialFireInterval = setInterval(this, "start", startTime - currentTime, 
      this);
  }
  
  private function start():Void {
    if (m_initialFireInterval != null) {
      clearInterval(m_initialFireInterval);
      m_initialFireInterval = null;
    }
    m_interval = setInterval(this, "fire", m_seconds*1000, this);
  }
}
