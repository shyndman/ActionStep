/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.ASUtils;
import org.actionstep.binding.NSKeyValueBindingCreation;
import org.actionstep.binding.NSKeyValueCoding;
import org.actionstep.constants.NSBindingDescription;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSEnumerator;
import org.actionstep.NSException;
import org.actionstep.NSNotificationCenter;

/**
 * <p>The base class for all objects in the ActionStep framework.</p>
 *
 * <p>All objects in ActionStep are created and initialized in the same way.
 * First, an instance is created by calling the class' constructor. Second, an
 * initializer method is called on the class. All objects in the ActionStep
 * framework inherit the {@link #init()} method, which is the default
 * instance initializer. For information on how to initialize other classes,
 * please see the methods under the <code>Construction</code> heading, or look
 * for methods that start with <code>init</code>.</p>
 *
 * <p><strong>Subclassing notes:</strong><br/>
 * When creating an NSObject subclass, there are a few methods that should be
 * overridden:
 * </p>
 * <ul>
 * <li>The {@link #description()} method is used to return a string
 * describing the contents of the class. This is very useful for debugging
 * purposes.</li>
 *
 * <li>The {@link #isEqual()} method is used for determining the equality
 * of two instances. Two instances are considered equal if their contents are
 * equal. This method is used by the collection classes when search for an
 * object.</li>
 * </ul>
 *
 * @author Richard Kilmer
 * @author Scott Hyndman
 */
class org.actionstep.NSObject implements NSKeyValueBindingCreation {

  //******************************************************
  //*                    Constants
  //******************************************************

  /** Returned by methods who have failed to find what was desired. */
  public static var NSNotFound:Number = -1;
  /** The tab character key code. */
  public static var NSTabCharacter:Number = 9;
  /** The newline character key code. */
  public static var NSNewlineCharacter:Number = 13;
  /** The enter character key code. */
  public static var NSEnterCharacter:Number = 13;
  /** The escape character key code. */
  public static var NSEscapeCharacter:Number = 27;
  /** The carriage return key code. */
  public static var NSCarriageReturnCharacter:Number = 13;
  /** The left arrow key's key code. */
  public static var NSLeftArrowFunctionKey:Number = 37;
  /** The up arrow key's key code. */
  public static var NSUpArrowFunctionKey:Number = 38;
  /** The right arrow key's key code. */
  public static var NSRightArrowFunctionKey:Number = 39;
  /** The down arrow key's key code. */
  public static var NSDownArrowFunctionKey:Number = 40;
  
  //******************************************************
  //*                   Notifications
  //******************************************************
  
  /**
   * Posted when an object's release() method is called.
   */
  public static var ASObjectDidReleaseNotification:Number
    = ASUtils.intern("ASObjectDidReleaseNotification");
    
  //******************************************************
  //*                  Members variables
  //******************************************************

  private var m_bindings:NSDictionary;
  private var m_accImpl:Object;
  
  //******************************************************
  //*             Construction and destruction
  //******************************************************

  /**
   * Creates a new instance of the <code>NSDictionary</code> class.
   */
  public function NSObject() {
    m_accImpl = null;
  }

  /**
   * Initializes the <code>NSObject</code> instance.
   */
  public function init():NSObject {
    return this;
  }
  
  /**
   * Performs necessary clean up to remove this <code>NSObject</code> from
   * memory.
   */
  public function release():Boolean {
    var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
    nc.removeObserver(this);
    nc.postNotificationWithNameObject(
    	ASObjectDidReleaseNotification, this);
    return true;
  }

  //******************************************************
  //*              Describing the object
  //******************************************************

  /**
   * <p>Returns a string representation of this object.</p>
   *
   * <p>This method should be overridden in subclasses.</p>
   */
  public function description():String {
    return "NSObject";
  }

  /**
   * Helper function for creating pretty-formatted descriptions, with plenty of whitespace.
   */
  private function buildDescription(/*propertyName, propertyValue, ...*/):String {
  	var a:Array = arguments;
  	var i:Number = Math.ceil(a.length/2);
  	if(i*2>a.length) {
  	  // prevent out-of-bounds error
  	  a.push(null);
  	}
  	var str:String = "";
  	for(var j:Number = 0; j<i; j++) {
  	  str+=a[j*2]+"="+a[j*2+1]+
  	  (j==i-1 ? "" : "\n");
  	}
  	return str;
  }

  /**
   * <p>Returns a string representation of this object.</p>
   *
   * <p>Defaults to calling {@link #description()}.</p>
   */
  public function toString():String {
    return description();
  }

  //******************************************************
  //*                 Comparing objects
  //******************************************************

  /**
   * <p>Returns <code>true</code> if this object is equal to
   * <code>anObject</code>, and <code>false</code> otherwise.</p>
   *
   * <p>To be overridden by subclasses as desired.</p>
   *
   * <p>The default implementation is reference comparison.</p>
   */
  public function isEqual(anObject:Object):Boolean {
    return this == anObject;
  }

  //******************************************************
  //*             Getting class information
  //******************************************************

  /**
   * Returns this object's class.
   */
  public function getClass():Function {
    return Object(this).__constructor__;
  }

  /**
   * Returns this object's super class.
   */
  public function getSuperClass():Function {
    return getClass().prototype.constructor;
  }

  /**
   * <p>Returns the name of this instance's class.</p>
   *
   * <p>This only works after an instance of <code>NSApplication</code> has been
   * created.</p>
   */
  public function className():String {
    return getClass().__className;
  }

  /**
   * <p>Returns the name of this instance's package.</p>
   *
   * <p>This only works after an instance of <code>NSApplication</code> has been
   * created.</p>
   */
  public function packageName():String {
    return getClass().__packageName;
  }

  /**
   * <p>Returns the full class path of this instance's class.</p>
   *
   * <p>This only works after an instance of <code>NSApplication</code> has been
   * created.</p>
   */
  public function classPath():String {
  	var cls:Function = getClass();
  	var package:String = cls.__packageName;

  	if (package.length > 0) {
  	  package += ".";
  	}

    return package + cls.__className;
  }

  /**
   * Cycles through the variables dictionary applying
   * <code>this[key] = dict[key]</code> for each entry.
   */
  public function updateMemberVariables(variables:NSDictionary):Void {
    var itr:NSEnumerator = variables.keyEnumerator();
    var key:String;

    while (null != (key = String(itr.nextObject())))
    {
      this[key] = variables.objectForKey(key);
    }
  }

  //******************************************************
  //*                Copying the object
  //******************************************************

  /**
   * <p>Returns a copy of the object by calling {@link #copyWithZone}.</p>
   *
   * <p>This method throws an {@link NSException} if the object does not
   * implement {@link #copyWithZone()}.</p>
   */
  public function copy():NSObject {
    if (respondsToSelector("copyWithZone")) {
      return this["copyWithZone"].call(this);
    } else {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        NSException.NSGeneric,
        "This object doesn't implement NSCopying. Object: "
        + this.description(),
        null);
      trace(e);
      throw e;
    }
  }

  /**
   * <p>Creates a shallow copy of the object.</p>
   *
   * <p>A shallow copy of an Object is a copy of the Object only. If the Object
   * contains references to other objects, the shallow copy will not create
   * copies of the referred objects. It will refer to the original objects
   * instead.</p>
   */
  public function memberwiseClone():NSObject {
    var res:Object = new Object();

    //
    // Object prototype chain and constructor stuff (important so that further
    // calls to clone will succeed, as well as getClass() use).
    //
    var constructor:Function = getClass();
    res.__proto__ = constructor.prototype;
    res.__constructor__ = constructor;

    //
    // Fire the constructor
    //
    // NOTE:
    // We are not currently storing the arguments as originally passed
    // to the constructor, and this might pose a problem. In any case, it
    // should be fairly easy to do if necessary.
    //
    constructor.apply(res);

    //
    // Copy all the properties
    //
    for (var p:String in this) {
      res[p] = this[p];
    }

    return NSObject(res);
  }

  //******************************************************
  //*                  Accessibility
  //******************************************************
  
  /**
   * <p>Returns the accessibility implementation for this object.</p>
   * 
   * <p>This method is mixed in by the classes in the 
   * <code>org.actionstep.accessibility</code> package.</p>
   */
  public function accessibilityImplementation():Void {
    // does nothing by default
  }
  
  //******************************************************
  //*                   Selectors
  //******************************************************

  /**
   * <p>Returns <code>true</code> if the object implements or inherits a method
   * named <code>sel</code>, or <code>false</code> otherwise.</p>
   *
   * <p>Uses <code>org.actionstep.ASUtils#respondsToSelector</code> internally.
   * </p>
   */
  public function respondsToSelector(sel:String):Boolean {
		return ASUtils.respondsToSelector(this, sel);
  }

  //******************************************************
  //*         Key-value coding - Getting values
  //******************************************************

  /**
   * <p>Returns the value for the property identified by <code>key</code>.</p>
   *
   * <p>If a property named <code>key</code> does not exist,
   * {@link #valueForUndefinedKey} is called to return a value.</p>
   *
   * <p>Uses {@link #valueForKeyPath()} internally.</p>
   */
  public function valueForKey(key:String):Object {
    return valueForKeyPath(key);
  }

  /**
   * <p>Returns the value for the derived property identified by
   * <code>keyPath</code>, or <code>null</code> if the specified key does not
   * exist.</p>
   *
   * <p><code>keyPath</code> should be a dot seperated list of properties to
   * iterate through to return the final value.</p>
   *
   * <p>Uses {@link NSKeyValueCoding#valueWithObjectForKeyPath()}
   * internally.</p>
   */
  public function valueForKeyPath(keyPath:String):Object {
    return NSKeyValueCoding.valueWithObjectForKeyPath(this, keyPath);
  }

  /**
   * Returns a dictionary containing the property values identified by each of
   * <code>keys</code>.
   */
  public function dictionaryWithValuesForKeys(keys:NSArray):NSDictionary {
    return NSKeyValueCoding.dictionaryWithObjectValueForKeys(this, keys);
  }

  /**
   * <p>Called by {@link #valueForKey()} when there is no property found
   * named <code>key</code>.</p>
   *
   * <p>The default implementation throws an {@link NSException} with
   * the user info dictionary containing the object that threw the exception
   * with the key <code>"NSObject"</code>.</p>
   */
  public function valueForUndefinedKey(key:String):Object {
  	var e:NSException = NSException.exceptionWithNameReasonUserInfo(
  		"NSUndefinedKeyException",
  		"A property named " + key + " does not exist on " + this + ".",
  		NSDictionary.dictionaryWithObjectForKey(this, "NSObject"));
  	trace(e);
  	throw e;
    return null;
  }

  //******************************************************
  //*       Key-value coding - Setting values
  //******************************************************

  /**
   * Sets the property identified by <code>keyPath</code> to <code>value</code>.
   */
  public function setValueForKeyPath(value:Object, keyPath:String):Void {
    NSKeyValueCoding.setValueWithObjectForKeyPath(this, value, keyPath);
  }

  /**
   * <p>Sets the property identified by <code>key</code> to <code>value</code>.</p>
   *
   * <p>Uses {@link #setValueForKeyPath} internally.</p>
   */
  public function setValueForKey(value:Object, key:String):Void {
    setValueForKeyPath(value, key);
  }

  /**
   * <p>Invoked by {@link #setValueForKey} when it finds no property binding for
   * <code>key</code>.</p>
   *
   * <p>Subclasses can override this method to handle the request in some other
   * way. The default implementation raises an {@link NSException}.</p>
   */
  public function setValueForUndefinedKey(value:Object, key:String):Void {
    var e:NSException = NSException.exceptionWithNameReasonUserInfo(
      "NSUndefinedKeyException",
      "There is no key on the object " + this + " named " + key,
      null);
      trace(e);
      throw e;
  }

  //******************************************************
  //*           From NSKeyValueBindingCreation
  //******************************************************

  /**
   * Returns an array of bindings exposed by this instance.
   *
   * @see NSKeyValueBindingCreation#exposedBindings
   */
  public function exposedBindings():NSArray {
    return NSArray(NSArray(getClass().exposedBindingsForClass()).copyWithZone());
  }

  /**
   * Returns the value class of the binding named <code>binding</code>.
   *
   * @see NSKeyValueBindingCreation#valueClassForBinding
   */
  public function valueClassForBinding(binding:String):Function {
  	return NSBindingDescription.typeForBinding(binding);
  }

  /**
   * Binds between two objects.
   *
   * @see NSKeyValueBindingCreation#bindToObjectWithKeyPathOptions
   */
  public function bindToObjectWithKeyPathOptions(binding:String, controller:Object,
      keyPath:String, options:NSDictionary):Void {
    if (m_bindings == null) {
       m_bindings = new NSDictionary();
    }

  	//! TODO implement
  }

  /**
   * Returns information related to the binding named <code>binding</code>.
   *
   * @see NSKeyValueBindingCreation#infoForBinding
   */
  public function infoForBinding(binding:String):NSDictionary {
    return NSDictionary(m_bindings.objectForKey(binding));
  }

  /**
   * Breaks the binding with the name <code>binding</code>.
   *
   * @see NSKeyValueBindingCreation#unbind
   */
  public function unbind(binding:String):Void {
  	if (m_bindings == null) {
  	  return;
  	}
  	//! TODO remove observation
    m_bindings.removeObjectForKey(binding);
  }

  //******************************************************
  //*                Debugging methods
  //******************************************************

  /**
   * Traces the string value of <code>object</code> with the level
   * <code>ASDebugger.DEBUG</code>.
   */
  public function asDebug(object:Object):Object {
    return ASDebugger.debug(object);
  }

  /**
   * Traces the string value of <code>object</code> with the level
   * <code>ASDebugger.INFO</code>.
   */
  public function asInfo(object:Object):Object {
    return ASDebugger.info(object);
  }

  /**
   * Traces the string value of <code>object</code> with the level
   * <code>ASDebugger.WARNING</code>.
   */
  public function asWarning(object:Object):Object {
    return ASDebugger.warning(object);
  }

  /**
   * Traces the string value of <code>object</code> with the level
   * <code>ASDebugger.ERROR</code>.
   */
  public function asError(object:Object):Object {
    return ASDebugger.error(object);
  }

  /**
   * Traces the string value of <code>object</code> with the level
   * <code>ASDebugger.FATAL</code>.
   */
  public function asFatal(object:Object):Object {
    return ASDebugger.fatal(object);
  }
}