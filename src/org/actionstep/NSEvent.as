/* See LICENSE for copyright and terms of use */

import org.actionstep.events.ASEventMonitor;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.NSPoint;
import org.actionstep.NSTimer;
import org.actionstep.NSView;
import org.actionstep.NSWindow;

/**
 * <p>Contains information related to user input, such as a keyboard press or a
 * mouse click. Events contain mouse location, the keys currently pressed and
 * modifier information (such as the Control or Alt key being held).</p>
 *
 * <p>These events are passed to windows, which in turn pass the events to the
 * {@link org.actionstep.NSView}s related to the event. In the case of
 * mouse clicks, this will be the view that was clicked. With keyboard events,
 * this will be the first responder.</p>
 *
 * <p>It is important to note that there is only one <code>NSEvent</code> instance
 * in the entire application, so if you need the event's data to persist
 * across multiple events, use the {@link #copy()} method.</p>
 *
 * @see org.actionstep.NSResponder#keyDown(NSEvent)
 * @see org.actionstep.NSResponder#mouseDown(NSEvent)
 * @see org.actionstep.NSResponder#scrollWheel(NSEvent)
 * @author Richard Kilmer
 */
class org.actionstep.NSEvent extends NSObject {

  //******************************************************
  //*                   Constants
  //******************************************************

  public static var NSLeftMouseDown:Number = 0;
  public static var NSLeftMouseUp:Number = 1;
  public static var NSRightMouseDown:Number = 2;
  public static var NSRightMouseUp:Number = 3;
  public static var NSOtherMouseDown:Number = 4;
  public static var NSOtherMouseUp:Number = 5;
  public static var NSMouseMoved:Number = 6;
  public static var NSLeftMouseDragged:Number = 7;
  public static var NSRightMouseDragged:Number = 8;
  public static var NSOtherMouseDragged:Number = 9;
  public static var NSMouseEntered:Number = 10;
  public static var NSMouseExited:Number = 11;
  public static var NSCursorUpdate:Number = 12;
  public static var NSKeyDown:Number = 13;
  public static var NSKeyUp:Number = 14;
  public static var NSFlagsChanged:Number = 15;
  public static var NSAppKitDefined:Number = 16;
  public static var NSSystemDefined:Number = 17;
  public static var NSApplicationDefined:Number = 18;
  public static var NSPeriodic:Number = 19;
  public static var NSScrollWheel:Number = 20;

  public static var NSLeftMouseDownMask:Number = (1 << NSLeftMouseDown);
  public static var NSLeftMouseUpMask:Number = (1 << NSLeftMouseUp);
  public static var NSRightMouseDownMask:Number = (1 << NSRightMouseDownMask);
  public static var NSRightMouseUpMask:Number = (1 << NSRightMouseUp);
  public static var NSOtherMouseDownMask:Number = (1 << NSOtherMouseDown);
  public static var NSOtherMouseUpMask:Number = (1 << NSOtherMouseUp);
  public static var NSMouseMovedMask:Number = (1 << NSMouseMoved);
  public static var NSLeftMouseDraggedMask:Number = (1 << NSLeftMouseDragged);
  public static var NSRightMouseDraggedMask:Number = (1 << NSRightMouseDragged);
  public static var NSOtherMouseDraggedMask:Number = (1 << NSOtherMouseDragged);
  public static var NSMouseEnteredMask:Number = (1 << NSMouseEntered);
  public static var NSMouseExitedMask:Number = (1 << NSMouseExited);
  public static var NSCursorUpdateMask:Number = (1 << NSCursorUpdate);
  public static var NSKeyDownMask:Number = (1 << NSKeyDown);
  public static var NSKeyUpMask:Number = (1 << NSKeyUp);
  public static var NSFlagsChangedMask:Number = (1 << NSFlagsChanged);
  public static var NSAppKitDefinedMask:Number = (1 << NSAppKitDefined);
  public static var NSSystemDefinedMask:Number = (1 << NSSystemDefined);
  public static var NSApplicationDefinedMask:Number = (1 << NSApplicationDefined);
  public static var NSPeriodicMask:Number = (1 << NSPeriodic);
  public static var NSScrollWheelMask:Number = (1 << NSScrollWheel);
  public static var NSAnyEventMask:Number = 0xffffffff;

  public static var NSAlphaShiftKeyMask:Number = 1;
  public static var NSShiftKeyMask:Number = 2;
  public static var NSControlKeyMask:Number = 4;
  public static var NSAlternateKeyMask:Number = 8;
  public static var NSCommandKeyMask:Number = NSControlKeyMask;
  public static var NSNumericPadKeyMask:Number = 32;
  public static var NSHelpKeyMask:Number = 64;
  public static var NSFunctionKeyMask:Number = 128;

  //******************************************************
  //*                   Class members
  //******************************************************

  private static var g_instance:NSEvent;
  private static var g_periodicTimer:NSTimer;

  //******************************************************
  //*                  General members
  //******************************************************

  /** Not used. */
  public var context:Object;

  /** The mouse's location in the coordinate system of the related window. */
  public var locationInWindow:NSPoint;

  /** A bit mask of modifier keys in effect for the event. */
  public var modifierFlags:Number;

  /**
   * The time the event was created represented by milliseconds since the
   * application began.
   */
  public var timestamp:Number;

  /** The type of the event. */
  public var type:Number;

  /** The view related to this event. */
  public var view:NSView;

  /** The window related to this event. */
  public var window:NSWindow;

  /** The identifier of the window associated with this event. */
  public var windowNumber:Number;

  /**
   * The actual flash object the cursor is over. Could be a movieclip or a
   * textfield.
   *
   * This is an ActionStep-only member.
   */
  public var flashObject:Object;

  //******************************************************
  //*                Key event members
  //******************************************************

  /** The characters associated with a key-up or key-down event. */
  public var characters:String;

  /**
   * The characters associated with a key event as if no modifier keys are
   * pressed (except Shift).
   */
  public var charactersIgnoringModifiers:String;

  /**
   * <code>true</code> if the key event is a repeat as a result of the user
   * holding the key down, or <code>false</code> if the event is new.
   */
  public var isARepeat:Boolean;

  /** The key code for the keyboard key associated with the event. */
  public var keyCode:Number;

  //******************************************************
  //*               Mouse event members
  //******************************************************

  /** The mouse location in screen coordinates. */
  public var mouseLocation:NSPoint;

  /** The mouse button number associated with the event. */
  public var buttonNumber:Number;

  /** The number of mouse clicks associated with the mouse event. */
  public var clickCount:Number;

  /** Not used. */
  public var pressure:Number;

  //******************************************************
  //*           Tracking rectangle information
  //******************************************************

  /** The counter value of this event. Every event increments the counter. */
  public var eventNumber:Number;

  /** The identifier of the tracking rectangle associated with this event. */
  public var trackingNumber:Number;

  /** The user data of the tracking rectangle associated with this event. */
  public var userData:Object;

  //******************************************************
  //*              Custom event information
  //******************************************************

  /** Additional data associated with the event. */
  public var data1:Object;

  /** Additional data associated with the event. */
  public var data2:Object;

  /** The subtype of the custom event. */
  public var subtype:Number;

  //******************************************************
  //*              Scrollwheel information
  //******************************************************

  /**
   * Returns the change in x for a scroll wheel, mouse-move, or mouse-drag
   * event.
   */
  public var deltaX:Number;
  public var deltaY:Number;
  public var deltaZ:Number;

  //******************************************************
  //*                  Construction
  //******************************************************

  /**
   * Events are not created directly. Use one of the methods defined under
   * the "Creating Events" section of the code.
   */
  private function NSEvent() {
    deltaX = deltaY = deltaZ = 0;
  }

  /**
   * Initializes the event.
   */
  private function init():NSEvent {
    super.init();
    return this;
  }

  //******************************************************
  //*              Describing the object
  //******************************************************

  /**
   * Returns a string representation of the object.
   */
  public function description():String {
    return "NSEvent(type="+type+",mouseLocation="+mouseLocation+")";
  }

  //******************************************************
  //                Cloning the object
  //******************************************************

  /**
   * Returns a copy of the event.
   */
  public function copyWithZone():NSEvent {
    var clone:NSEvent = NSEvent(memberwiseClone());
    clone.mouseLocation = mouseLocation.clone();
    clone.locationInWindow = locationInWindow.clone();

    return clone;
  }

  //******************************************************
  //*          Matching masks and modifiers
  //******************************************************

  /**
   * <p>Returns <code>true</code> if this event's mask matches the mask
   * defined by <code>mask</code>, or <code>false</code> otherwise.</p>
   *
   * <p>This method is ActionStep-only.</p>
   */
  public function matchesMask(mask:Number):Boolean {
    return (((mask >> type) & 1) == 1);
  }

  /**
   * <p>Returns <code>true</code> if this event's modifier mask matches the mask
   * defined by <code>mask</code>, or <code>false</code> otherwise.</p>
   *
   * <p>This method is ActionStep-only.</p>
   */
  public function matchesModifiers(mask:Number):Boolean {
    return (modifierFlags & mask) == mask;
  }

  /**
   * <p>Returns <code>true</code> if this event's characters (ignoring modifiers)
   * and modifier flags matches the <code>key</code> and <code>mask</code>
   * respectively, or <code>false</code> otherwise.</p>
   *
   * <p>Please note that forcing the strings to be in lowercase is necessary,
   * especially when Caps Lock is turned on, or the Shift key is pressed.</p>
   *
   * <p>This method is ActionStep-only.</p>
   */
  public function matchesKeyEquivalent(key:String, mask:Number):Boolean {
  	return (
  	key!="" &&
  	mask!=0 &&
  	charactersIgnoringModifiers.toLowerCase() == key.toLowerCase() &&
  	modifierFlags == mask);
  }

  //******************************************************
  //*       Requesting and stopping periodic events
  //******************************************************

  /**
   * <p>Begins generating periodic events every <code>period</code> seconds after
   * and initial delay of <code>delay</code>.</p>
   *
   * <p>Raises an {@link NSException} if periodic events are already being
   * generated.</p>
   */
  public static function startPeriodicEventsAfterDelayWithPeriod(delay:Number,
      period:Number):Void {

    //
    // Make sure we're not already generating periodic events. If we are,
    // throw an exception.
    //
    if (g_periodicTimer != null) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        "NSIllegalOperationException",
        "Periodic events are already being generated. If you would like to" +
        " change the period, stop periodic events then start.",
        null);
      trace(e);
      throw e;
    }

    //
    // Begin generating periodic events.
    //
    g_periodicTimer = new NSTimer();
    var startDate:Date = new Date();
    startDate.setTime(startDate.getTime()+(delay*1000));
    g_periodicTimer.initWithFireDateIntervalTargetSelectorUserInfoRepeats(
      startDate, period, ASEventMonitor.instance(), "postPeriodicEvent", {},
      true);
  }

  /**
   * Stops periodic event generation.
   */
  public static function stopPeriodicEvents():Void {
    if (g_periodicTimer != null) {
      g_periodicTimer.invalidate();
      g_periodicTimer = null;
    }
  }

  //******************************************************
  //*                Creating events
  //******************************************************

  public static function keyEventWithType(type:Number, location:NSPoint,
      modifierFlags:Number, timestamp:Number, window:NSWindow, context:Object,
      characters:String, charactersIgnoringModifiers:String, isARepeat:Boolean,
      keyCode:Number):NSEvent {

    setDeltasWithPoint(location);
    g_instance.type = type;
    g_instance.mouseLocation = location;
    g_instance.modifierFlags = modifierFlags;
    g_instance.timestamp = timestamp;
    g_instance.window = window;
    g_instance.locationInWindow = g_instance.window.convertScreenToBase(
      location);
    g_instance.windowNumber = window.windowNumber();
    g_instance.context = context;
    g_instance.characters = characters;
    g_instance.charactersIgnoringModifiers = charactersIgnoringModifiers;
    g_instance.isARepeat = isARepeat;
    g_instance.keyCode = keyCode;

    // Clear our unused data
    g_instance.buttonNumber = 0;
    g_instance.clickCount = 0;
    g_instance.pressure = 0;
    g_instance.eventNumber = -1;
    g_instance.trackingNumber = 0;
    g_instance.userData = null;
    g_instance.data1 = null;
    g_instance.data2 = null;
    g_instance.subtype = 0;

    return g_instance;
  }

  public static function enterExitEventType(type:Number, location:NSPoint,
      modifierFlags:Number, timestamp:Number, view:NSView, context:Object,
      eventNumber:Number, trackingNumber:Number, userData:Object):NSEvent {

    setDeltasWithPoint(location);
    g_instance.type = type;
    g_instance.mouseLocation = location;
    g_instance.modifierFlags = modifierFlags;
    g_instance.timestamp = timestamp;
    g_instance.view = view;
    g_instance.window = view.window();
    g_instance.locationInWindow = g_instance.window.convertScreenToBase(
      location);
    g_instance.windowNumber =  g_instance.window.windowNumber();
    g_instance.context = context;
    g_instance.eventNumber = eventNumber;
    g_instance.trackingNumber = trackingNumber;
    g_instance.userData = userData;

    // Clear our unused data
    g_instance.characters = null;
    g_instance.charactersIgnoringModifiers = null;
    g_instance.isARepeat = false;
    g_instance.keyCode = 0;
    g_instance.buttonNumber = 0;
    g_instance.clickCount = 0;
    g_instance.pressure = 0;
    g_instance.data1 = null;
    g_instance.data2 = null;
    g_instance.subtype = 0;

    return g_instance;
  }

  public static function mouseEventWithType(type:Number, location:NSPoint,
      modifierFlags:Number, timestamp:Number, view:NSView, context:Object,
      eventNumber:Number, clickCount:Number, pressure:Number):NSEvent {

    setDeltasWithPoint(location);
    g_instance.type = type;
    g_instance.mouseLocation = location;
    g_instance.modifierFlags = modifierFlags;
    g_instance.timestamp = timestamp;
    g_instance.view = view;
    g_instance.window = view.window();
    g_instance.locationInWindow = g_instance.window.convertScreenToBase(
      location);
    g_instance.windowNumber =  g_instance.window.windowNumber();
    g_instance.context = context;
    g_instance.eventNumber = eventNumber;
    g_instance.clickCount = clickCount;
    g_instance.pressure = pressure;

    // Clear our unused data
    g_instance.characters = null;
    g_instance.charactersIgnoringModifiers = null;
    g_instance.isARepeat = false;
    g_instance.keyCode = 0;
    g_instance.buttonNumber = 0;
    g_instance.trackingNumber = 0;
    g_instance.userData = null;
    g_instance.data1 = null;
    g_instance.data2 = null;
    g_instance.subtype = 0;

    return g_instance;
  }

  public static function otherEventWithType(type:Number, location:NSPoint,
      modifierFlags:Number, timestamp:Number, view:NSView, context:Object,
      subtype:Number, data1:Object, data2:Object):NSEvent {

    setDeltasWithPoint(location);
    g_instance.type = type;
    g_instance.mouseLocation = location;
    g_instance.modifierFlags = modifierFlags;
    g_instance.timestamp = timestamp;
    g_instance.view = view;
    g_instance.window = view.window();
    g_instance.locationInWindow = g_instance.window.convertScreenToBase(
      location);
    g_instance.windowNumber =  g_instance.window.windowNumber();
    g_instance.context = context;
    g_instance.subtype = subtype;
    g_instance.data1 = data1;
    g_instance.data2 = data2;

    // Clear our unused data
    g_instance.characters = null;
    g_instance.charactersIgnoringModifiers = null;
    g_instance.isARepeat = false;
    g_instance.keyCode = 0;
    g_instance.buttonNumber = 0;
    g_instance.clickCount = 0;
    g_instance.pressure = 0;
    g_instance.eventNumber = -1;
    g_instance.trackingNumber = 0;
    g_instance.userData = null;

    return g_instance;
  }

  private static function setDeltasWithPoint(newLocation:NSPoint):Void {
  	if (null == g_instance.mouseLocation) {
  	  return;
  	}

    g_instance.deltaX = newLocation.x - g_instance.mouseLocation.x;
    g_instance.deltaY = newLocation.y - g_instance.mouseLocation.y;
  }
  
  //******************************************************
  //*                 Static constructor
  //******************************************************
  
  private static var g_initialized:Boolean;
  
  /**
   * Initializes the class. Called by ASEventMonitor.
   */
  public static function initializeEvents():Void {
    if (g_initialized) {
      return;
    }
    
    g_instance = (new NSEvent()).init();
    
    g_initialized = true;
  }
}