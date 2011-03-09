/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.NSObject;
import org.actionstep.NSDictionary;

/**
 * <p><code>NSNotification</code> objects contain information that is broadcasted 
 * to other objects using the {@link org.actionstep.NSNotificationCenter}.</p>
 * 
 * <p>A notification contains a name, an object and an optional dictionary
 * containing additional information. The name is a unique identifier tag for
 * the notification. The object is an object that the notification poster
 * wants to send to observing objects (typically the object is the poster of
 * the notification). The dictionary stores related objects.</p>
 * 
 * <p>To post a notification, use:<br/>
 * {@link org.actionstep.NSNotificationCenter#postNotificationNameObject}<br/>
 * or<br/>
 * {@link org.actionstep.NSNotificationCenter#postNotificationNameObjectUserInfo}.</p>
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSNotification extends NSObject {
  
  /** The notification type. */
  public var name:Number;
  
  /** The object associated with the notification. */
  public var object:Object;
  
  /** The dictionary of information related to the notification. */
  public var userInfo:NSDictionary;
  
  //******************************************************															 
  //*                  Construction
  //******************************************************
  
  /**
   * <p>Creates a new instance of the <code>NSNotification</code> class.</p>
   * 
   * <p>{@link #withNameObject} or {@link #withNameObjectUserInfo} are
   * more commonly used to create notifications.</p>
   */
  public function NSNotification() {
  }
  
  //******************************************************															 
  //*              Describing the object
  //******************************************************
  
  /**
   * Returns a string representation of the notification. 
   */
  public function description():String {
    return "NSNotification(name=" + nameAsString() + "(" + name + "), object="
      + object + ",userInfo=" + userInfo + ")";
  }
  
  /**
   * Returns the name of the notification as a string.
   */
  public function nameAsString():String {
    return ASUtils.extern(name);
  }

  //******************************************************															 
  //*             Creating a notification
  //******************************************************
  
  /**
   * Creates and returns new instance of <code>NSNotification</code> with a name
   * of <code>name</code> and a related object <code>object</code>.
   */
  public static function withNameObject(name:Number, object:Object)
      :NSNotification {
    var notification:NSNotification = new NSNotification();
    notification.name = name;
    notification.object = object;
    return notification;
  }

  /**
   * Creates and returns new instance of <code>NSNotification</code> with a name
   * of <code>name</code>, a related object <code>object</code> and a dictionary
   * of additional information <code>userInfo</code>.
   */  
  public static function withNameObjectUserInfo(name:Number, object:Object, 
      userInfo:NSDictionary):NSNotification {
    var notification:NSNotification = new NSNotification();
    notification.name = name;
    notification.object = object;
    notification.userInfo = userInfo;
    return notification;
  }
}