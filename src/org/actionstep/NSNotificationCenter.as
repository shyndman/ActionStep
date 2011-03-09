/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.NSException;
import org.actionstep.NSNotification;
import org.actionstep.NSObject;
import org.actionstep.NSDictionary;

/**
 * The <code>NSNotificationCenter</code> allows object that don't know about 
 * each other to communicate. It forwards notification objects about specific 
 * events to all interested observer objects.
 *
 * @author Richard Kilmer
 */
class org.actionstep.NSNotificationCenter extends NSObject {
  
  private static var NULL_KEY:Number = ASUtils.intern("__NULL__");
  private static var g_defaultCenter:NSNotificationCenter;
  
  /**
   * Returns the current notification center.
   */
  public static function defaultCenter():NSNotificationCenter {
    if (g_defaultCenter == null) {
      g_defaultCenter = new NSNotificationCenter();
    }
    return g_defaultCenter;
  }

  private var m_objectObservers:Array;
  private var m_notificationObservers:Array;
  private var m_objectMap:Array;

  /**
   * Constructs a new instance of <code>NSNotificationCenter</code>.
   */
  public function NSNotificationCenter() {
    m_objectObservers = new Array();
    m_notificationObservers = new Array();
    m_objectMap = new Array();
  }
  
  /**
   * <p>Check the map for <code>object</code>, and if found, return the index at 
   * which it was found.</p>
   *
   * <p>If not found, the <code>create</code> flag will result in the object being 
   * added to the map.</p>
   */
  private function map(object:Object, create:Boolean):Number {
    var i:Number;
    
    if(create == null) 
      create = true;
    
    //
    // don't map more than once
    //  
    for(i = 0; i < m_objectMap.length; i++) {
      if (m_objectMap[i] == object) 
        return i;
    }
    
    //
    // Push the object onto the map if requested, otherwise return null.
    //
    if (create)
      return m_objectMap.push(object) - 1;
    else
      return null;
  }
  
  /**
   * <p>Posts a notification for all observers to view.</p>
   *
   * <p>An exception is raised if notification is <code>null</code>.</p>
   */
  public function postNotification(notification:NSNotification) {
  	if (notification == null)
  	{
	  throw NSException.exceptionWithNameReasonUserInfo("Exception", 
	    "NSNotificationCenter::postNotification - notification cannot " +
	    "be null.", null);
  	}
  	
    var ref:Object;
    var list:Array;
    var i:Number;
    var o:Object;
    ref = m_objectObservers[map(notification.object, false)];
    if (ref != null) {
      list = ref[notification.name];
      if (list != null) {
        for(i = 0;i<list.length;i++) {
          o = list[i];
          o.observer[o.selector].call(o.observer, notification);
        }
      }
      list = ref[NULL_KEY];
      if (list != null) {
        for(i = 0;i<list.length;i++) {
          o = list[i];
          o.observer[o.selector].call(o.observer, notification);
        }
      }
    }
    list = m_notificationObservers[notification.name];
    if (list != null) {
      for(i = 0;i<list.length;i++) {
        o = list[i];
        o.observer[o.selector].call(o.observer, notification);
      }
    }
  }
  
  public function postNotificationWithNameObject(name:Number, object:Object)
      :Void {
    this.postNotification(NSNotification.withNameObject(name, object));
  }

  public function postNotificationWithNameObjectUserInfo(name:Number, 
      object:Object, userInfo:NSDictionary):Void {
    this.postNotification(NSNotification.withNameObjectUserInfo(name, object, 
      userInfo));
  }

  /**
   * <p>Registers <code>anObserver</code> to recieve notifications named 
   * <code>notificationName</code>. When a notification named 
   * <code>notificationName</code> is posted from <code>anObject</code>, 
   * <code>anObserver</code>'s method <code>aSelector</code> will be called with
   * the notification as its single argument.</p>
   *
   * <p>If <code>anObject</code> is <code>null</code>, <code>anObserver</code> will
   * recieve a message whenever any object posting a notification named 
   * <code>notificationName</code>.</p>
   *
   * <p>If <code>notificationName</code> is <code>null</code>, 
   * <code>anObserver</code> will recieve a message when <code>anObject</code> 
   * posts any notification.</p>
   */
  public function addObserverSelectorNameObject(anObserver:Object, aSelector:String, notificationName:Number, anObject:Object) {
    var ref:Object;
    if (anObject != null) {
      var anObjectIndex:Number = map(anObject);
      ref = m_objectObservers[anObjectIndex];
      if (ref == null) {
        ref = new Array();
        m_objectObservers[anObjectIndex] = ref;
      }
      if (notificationName == null) {
        notificationName = NULL_KEY;
      }
      var observers:Array = ref[notificationName];
      if (observers == null) {
        observers = new Array();
        ref[notificationName] = observers;
      }
      observers.push({observer: anObserver, selector: aSelector});
    } else if (notificationName != null) {
      ref = m_notificationObservers[notificationName];
      if (ref == null) {
        ref = new Array();
        m_notificationObservers[notificationName] = ref;
      }
      ref.push({observer: anObserver, selector: aSelector});
    } else {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        "NSInvalidArgumentException",
        "Must specify notificationName or anObject",
        null);
      trace(e);
      throw e;
    }
  }


  /**
   * Unregisters <code>anObserver</code> from recieving all notifications.
   */
  public function removeObserver(anObserver:Object) {
    var i:Number, j:Number, k:Number, names:Array;
    
    // Clean up notification observers
    for(j=0;j<m_notificationObservers.length;j++) {
      removeObserverFromList(anObserver, m_notificationObservers[j]);
    }

    // Clean up object observers
    for(j=0;j<m_objectObservers.length;j++) {
      names = m_objectObservers[j];
      if(names != undefined) { 
        for(k=0;k<names.length;k++) {
          removeObserverFromList(anObserver, names[k]);
        }
      }
    }
  }
  
  /**
   * <p>Unregisters <code>anObserver</code> from recieving all notifications named 
   * <code>notificationName</code> from <code>anObject</code>.</p>
   *
   * <p>If <code>anObject</code> is <code>null</code>, <code>anObserver</code> 
   * will be unregistered from all notifications named 
   * <code>notificationName</code>.</p>
   *
   * <p>If <code>notificationName</code> is <code>null</code>, 
   * <code>anObserver</code> will be unregistered from all notifications from 
   * <code>anObject</code>.</p>
   */
  public function removeObserverNameObject(anObserver:Object, notificationName:Number, anObject:Object) {
    var i:Number, j:Number, k:Number, names:Array;
    
    if (notificationName == null && anObject == null) { // Both null
      removeObserver(anObserver);
      return;
    }

    // Clean up notification observers
    if (notificationName == null) {
      for(j=0;j<m_notificationObservers.length;j++) {
        removeObserverFromList(anObserver, m_notificationObservers[j]);
      }
    } else { // provided notification name
      removeObserverFromList(anObserver, m_notificationObservers[notificationName]);
    }
    
    // Clean up object observers
    if (anObject == null) { //no object, must have notification name
      for(j=0;j<m_objectObservers.length;j++) {
        names = m_objectObservers[j];
        if(names != undefined) { 
          removeObserverFromList(anObserver, names[notificationName]);
        }
      }
    } else { // has an object
      names = m_objectObservers[map(anObject)];
      if(names != undefined) { 
        if (notificationName == null) { // object with no notification name
          for(k=0;k<names.length;k++) {
            removeObserverFromList(anObserver, names[k]);
          }
        } else { // object + notification name
          removeObserverFromList(anObserver, names[notificationName]);
        }
      }
    }

  }

  private function removeObserverFromList(anObserver:Object, observerList:Array) {
    var list:Array, i:Number;
    if(observerList != undefined) { 
      list = [];
      for(i = 0;i<observerList.length;i++) {
        if (observerList[i].observer == anObserver) {
          list.unshift(i);
        }
      }
      while(list.length > 0) {
        observerList.splice(Number(list.pop()), 1);
      }
    }
  }

}
