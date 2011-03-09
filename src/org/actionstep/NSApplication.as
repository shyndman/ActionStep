/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.ASFieldEditor;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSRunResponse;
import org.actionstep.events.ASEventMonitor;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSInvocation;
import org.actionstep.NSMenu;
import org.actionstep.NSModalSession;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPanel;
import org.actionstep.NSResponder;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;
//import org.actionstep.toolTip.ASToolTip;

/**
 * <p>This class manages the application's event loop, windows and its main menu.</p>
 *
 * <p>The application can be accessed using the {@link #sharedApplication()}
 * method.</p>
 *
 * <h2>IMPORTANT</h2>
 * <p>
 * Some features in the framework will not operator properly before {@link #run}
 * has been called.
 * </p>
 * 
 * <h2>NOTES ON MODAL WINDOWS</h2>
 * <p>
 * The order of the event loop when a modal session is active is as follows:
 * 1. modalSendEvent():		
 * 			Receives the event from the event monitor, which determines whether 
 * 			the event should be handled, handles it, then calls a modal callback
 * 			function (modalWindowEventCallback()).
 * 			 
 * 2. modalWindowEventCallback()
 * 			Determines whether the modal session should continue by checking its
 * 			first argument, which is the current session's run state
 * 			(NSModalSession#runState). If it is anything other than
 * 			NSRunResponse#NSContinues, #endModalSession() is called.
 * 
 * 3. endModalSession()
 * 			Ends the session passed to it as an argument, and restores any
 * 			previous sessions to focus. If there are no previous sessions,
 * 			the non-modal sendEvent is restored, and the session restores the
 * 			key and main windows prior to its creation. This method also calls
 * 			the callback.
 * 			
 * </p>
 * 
 * @author Rich Kilmer
 */
class org.actionstep.NSApplication extends NSResponder {

  //******************************************************
  //*                  Notifications
  //******************************************************

  public static var NSApplicationDidBecomeActiveNotification:Number
    = ASUtils.intern("NSApplicationDidBecomeActiveNotification");
  public static var NSApplicationDidChangeScreenParametersNotification:Number
    = ASUtils.intern("NSApplicationDidChangeScreenParametersNotification");
  public static var NSApplicationDidFinishLaunchingNotification:Number
    = ASUtils.intern("NSApplicationDidFinishLaunchingNotification");
  public static var NSApplicationDidHideNotification:Number
    = ASUtils.intern("NSApplicationDidHideNotification");
  public static var NSApplicationDidResignActiveNotification:Number
    = ASUtils.intern("NSApplicationDidResignActiveNotification");
  public static var NSApplicationDidUnhideNotification:Number
    = ASUtils.intern("NSApplicationDidUnhideNotification");
  public static var NSApplicationDidUpdateNotification:Number
    = ASUtils.intern("NSApplicationDidUpdateNotification");
  public static var NSApplicationWillBecomeActiveNotification:Number
    = ASUtils.intern("NSApplicationWillBecomeActiveNotification");
  public static var NSApplicationWillFinishLaunchingNotification:Number
    = ASUtils.intern("NSApplicationWillFinishLaunchingNotification");
  public static var NSApplicationWillHideNotification:Number
    = ASUtils.intern("NSApplicationWillHideNotification");
  public static var NSApplicationWillResignActiveNotification:Number
    = ASUtils.intern("NSApplicationWillResignActiveNotification");
  public static var NSApplicationWillTerminateNotification:Number
    = ASUtils.intern("NSApplicationWillTerminateNotification");
  public static var NSApplicationWillUnhideNotification:Number
    = ASUtils.intern("NSApplicationWillUnhideNotification");
  public static var NSApplicationWillUpdateNotification:Number
    = ASUtils.intern("NSApplicationWillUpdateNotification");

  /**
   * <p>Dispatched when the stage resizes.</p>
   *
   * <p>The userInfo dictionary contains the following:
   * <ul>
   * <li>"ASOldSize": The old size of the stage. ({@link NSSize})</li>
   * <li>"ASNewSize": The new size of the stage. ({@link NSSize})</li>
   * </ul>
   * </p>
   */
  public static var ASStageDidResizeNotification:Number
    = ASUtils.intern("ASStageDidResizeNotification");

  //******************************************************
  //*                 Class variables
  //******************************************************

  private static var g_sharedApplication:NSApplication;
  private static var libraryCount:Number = 0;

  //******************************************************
  //*                 Member variables
  //******************************************************

  private var m_active:Boolean;
  private var m_isRunning:Boolean;
  private var m_keyWindow:NSWindow;
  private var m_lastMouseWindow:NSWindow;
  private var m_mainWindow:NSWindow;
  private var m_currentEvent:NSEvent;
  private var m_eventFilter:Object;
  private var m_delegate:Object;
  private var m_notificationCenter:NSNotificationCenter;
  private var m_windowsNeedDisplay:Boolean;
  private var m_menu:NSMenu;

  private var m_modalSession:NSModalSession;
  private var m_modalCallback:Object;
  private var m_modalSelector:String;

  private var m_currentSheetCallback:NSInvocation;
  private var m_sheetCallbacks:Object;

  //******************************************************
  //*                  Construction
  //******************************************************

  /**
   * <p>Creates a new instance of the <code>NSApplication</code> class.</p>
   *
   * <p>This is never called. Use {@link #sharedApplication()} to access
   * the current application.</p>
   */
  private function NSApplication() {
    m_windowsNeedDisplay = true;
    m_isRunning = false;
    m_active = true;
    m_eventFilter = null;

    m_sheetCallbacks = {};
  }

  /**
   * Initializes the application.
   */
  public function init():NSApplication {
    m_notificationCenter = NSNotificationCenter.defaultCenter();
    m_notificationCenter.addObserverSelectorNameObject(this,
      "__windowWillClose", NSWindow.NSWindowWillCloseNotification, null);
    m_notificationCenter.addObserverSelectorNameObject(this,
      "__windowDidBecomeKey", NSWindow.NSWindowDidBecomeKeyNotification, null);
    m_notificationCenter.addObserverSelectorNameObject(this,
      "__windowDidBecomeMain", NSWindow.NSWindowDidBecomeMainNotification, null);
    m_notificationCenter.addObserverSelectorNameObject(this,
      "__windowDidResignKey", NSWindow.NSWindowDidResignKeyNotification, null);
    m_notificationCenter.addObserverSelectorNameObject(this,
      "__windowDidResignMain", NSWindow.NSWindowDidResignMainNotification, null);

    m_active = true;

    //
    // Initialize classes
    //
    ASUtils.initializeClassesWithPackage(_global.org.actionstep,
      "org.actionstep");

    return this;
  }

  //******************************************************
  //*             Describing the object
  //******************************************************

  public function description():String {
    return "NSApplication()";
  }

  //******************************************************
  //*               Top level movieclips
  //******************************************************

  /**
   * <p>Returns the clip on which cursors are drawn.</p>
   *
   * <p>This method is ActionStep only.</p>
   */
  public function cursorClip():MovieClip
  {
    return ASEventMonitor.instance().cursorClip();
  }

  /**
   * <p>Returns the clip on which dragging images are drawn.</p>
   *
   * <p>This method is ActionStep only.</p>
   */
  public function draggingClip():MovieClip
  {
    return ASEventMonitor.instance().draggingClip();
  }

  /**
   * <p>Returns the clip upon which slideback drag images are drawn.</p>
   *
   * <p>This method is ActionStep only, and is intended for internal use.</p>
   */
  public function draggingSlideBackClip():MovieClip {
    return ASEventMonitor.instance().draggingSlideBackClip();
  }

  //******************************************************
  //*           Changing the active application
  //******************************************************

  /**
   * <p>Returns <code>true</code> if this is the active application.</p>
   *
   * <p>ActionSteps implementation will always return <code>true</code>, because
   * there is only ever one active application.</p>
   */
  public function isActive():Boolean {
    return m_active;
  }

  //******************************************************
  //*       Getting, removing, and posting events
  //******************************************************

  public function currentEvent():NSEvent {
    return m_currentEvent;
  }

  public function postEventAtStart(event:NSEvent, atStart:Boolean) {
    //Sync for now...
    sendEvent(event);
  }

  public function nextEventMatchingMaskUntilDateInModeDequeue(mask:Number,
      until:Date, mode:String, dequeue:Boolean) {
    //! TODO implement
  }

  public function callObjectSelectorWithNextEventMatchingMaskDequeue(callback:Object, selector:String, mask:Number, dequeue:Boolean):Void {
    m_eventFilter = {object: callback, selector: selector, mask: mask, dequeue: dequeue};
  }

  /**
   * <p>Used to hold {@link #sendEvent} function during modal event processing.</p>
   * <p>Defined here for type checking reasons.</p>
   */
  private function originalSendEvent(event:NSEvent) {}

  public function sendEvent(event:NSEvent) {
    m_currentEvent = event;
    if (m_eventFilter && m_currentEvent.matchesMask(m_eventFilter.mask)) {
      var object:Object = m_eventFilter.object;
      var selector:String = m_eventFilter.selector;
      var dequeue:Boolean = m_eventFilter.dequeue;
      m_eventFilter = null;

      try {
        object[selector].call(object, m_currentEvent);
      } catch (e:Error) {
        trace(asFatal(e.message));
      }

      if (dequeue) {
        if (event.type == NSEvent.NSLeftMouseUp && ASFieldEditor.instance().isEditing()) {
          ASFieldEditor.instance().regainFocus();
        }
        return;
      }
    }
    //! What else to do here?
    switch(event.type) {
    case NSEvent.NSKeyDown:
      try {
      	var keyEquiv:Boolean = false;
        if (!(m_currentEvent.modifierFlags & NSEvent.NSShiftKeyMask != 0
            && m_currentEvent.keyCode == NSTabCharacter)
            && m_currentEvent.modifierFlags != 0
            && m_currentEvent.charactersIgnoringModifiers!="") {
          //
          // Attempt to perform key equivalent.
          //
          if (!m_keyWindow.performKeyEquivalent(event)) {
          	keyEquiv = mainMenu().performKeyEquivalent(event);
          } else {
            keyEquiv = true;
          }
        }

        if (!keyEquiv) {
          m_keyWindow.sendEvent(m_currentEvent);
        }
      } catch (e:Error) {
        trace(asFatal(e.message));
      }
      break;
    case NSEvent.NSKeyUp:
      try {
        m_keyWindow.sendEvent(m_currentEvent);
      } catch (e:Error) {
        trace(asFatal(e.message));
      }
      break;
    default:
      try {
        m_currentEvent.window.sendEvent(m_currentEvent);

        if (m_currentEvent.window != m_lastMouseWindow) {
          if (m_lastMouseWindow != null) {
            m_lastMouseWindow.checkTrackingForLastView(m_currentEvent);
          }
          m_lastMouseWindow = m_currentEvent.window;
        }
      } catch (e:Error) {
        trace(asFatal(e.message));
      }
    }
    if (event.type == NSEvent.NSLeftMouseUp && ASFieldEditor.instance().isEditing()) {
      ASFieldEditor.instance().regainFocus();
    }

    updateAfterEvent();
  }

  //******************************************************
  //*               Running the event loop
  //******************************************************

  /**
   * Starts the main event loop.
   */
  public function run() {
    //
    // Display all the windows.
    //
    var wins:Array = this.windows();
    for (var x:Number = 0; x < wins.length; x++) {
      NSWindow(wins[x]).display();
    }

    //
    // Start tracking mouse, keyboard and stage events
    //
    var em:ASEventMonitor = ASEventMonitor.instance();
    em.trackMouseEvents();
    em.trackKeyboardEvents();
    em.trackStageEvents();

    //
    // Make window zero key and main
    //
    NSWindow(wins[0]).makeKeyWindow();
    NSWindow(wins[0]).makeMainWindow();

    //! What else should we do in run?
    m_isRunning = true;
  }

  /**
   * Returns <code>true</code> if the application is running, or
   * <code>false</code> otherwise.
   */
  public function isRunning():Boolean {
    return m_isRunning;
  }

  /**
   * <p>Sets up a modal session with the <code>NSWindow</code> <code>win</code>
   * and returns an {@link NSModalSession} structure representing the session.</p>
   *
   * <p><code>win</code> is the window that will receive events in place of
   * <code>docWin</code>.</p>
   *
   * <p>This method is deprecated.</p>
   *
   * @see #beginSheetModalForWindowModalDelegateDidEndSelectorContextInfo
   */
  public function beginModalSessionForWindow(win:NSWindow, call:Object,
      sel:String, docWin:NSWindow):NSModalSession {
    //store a ref to it, since its going to be overwritten

    var prev:NSModalSession = m_modalSession;
    
    m_modalSession = new NSModalSession(NSRunResponse.NSContinues);
    m_modalSession.window = win;
    m_modalSession.setSheet(docWin);
    m_modalSession.previous = prev;

    m_modalSession.keyWindow = m_keyWindow;
    m_modalSession.mainWindow = m_mainWindow;

    m_keyWindow.resignKeyWindow();
    m_mainWindow.resignMainWindow();

    m_modalSession.setCallbackSelector(call, sel);

    if (win instanceof NSPanel) {
      win.center();
      win.setLevel(NSWindow.NSModalPanelWindowLevel);
    }
    win.orderFrontRegardless();
    if (isActive()) {
      if (win.canBecomeKeyWindow()) {
        win.makeKeyWindow();
      } else if (win.canBecomeMainWindow()) {
        win.makeMainWindow();
      }
    }
    return m_modalSession;
  }

  /**
   * Finishes a modal session.
   *
   * @param sess  Return value from a previous invocation of
   *     {@link #beginModalSessionForWindow()}
   */
  public function endModalSession(session:NSModalSession):Void {
//  	trace("NSApplication.endModalSession(session)");
  	
    var curr:NSModalSession = m_modalSession;

    //
    // Check for null
    //
    if (session == null) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        NSException.NSInvalidArgument,
        "null pointer passed to endModalSession()",
        null);
      trace(e);
      e.raise();
    }

    if (curr == null) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        NSException.NSInternalInconsistency,
        "not in modal session",
        null);
      trace(e);
      e.raise();
    }

   	if(session!=curr) {
   		// search for the session ahead
   		var tmp:NSModalSession = curr;
   		while(tmp) {
   			if(tmp.previous==session) {
   				break;
   			}
   			tmp = tmp.previous;
   		}
   		// re-link the sessions
   		tmp.previous = session.previous;
   		session.previous = null;
   	} else {
   		// curr and session can be used interchangeably
   		if(session.previous==null) {
   			m_modalSession = null;
				session.window.setLevel(session.entryLevel);
				//
				// Return key and main status to the windows that had them before this
				// session began.
				//
				session.keyWindow.makeKeyWindow();
				session.mainWindow.makeMainWindow();
				session.window.setLevel(session.entryLevel);
				//
				// End posing
				//
				sendEvent = originalSendEvent;
	   	} else {
	   		m_modalSession = m_modalSession.previous;
   		}
   	}

    if(session.isSheet) {
    	// only allow the sheetCallback to start when the session has ended
    	m_currentSheetCallback = m_sheetCallbacks[session.window.windowNumber()];
    } else {
    	m_currentSheetCallback = null;
    }

    //
    // Send callback with result, set lastrun to true
    //
    var sessCallback:Object = session.callback;
//    trace("calling " + sessCallback.className() + "." + session.selector + "()");
    sessCallback[session.selector].call(sessCallback, session.runState, true);
	
    // TODO deal with sheetDidEndReturnCodeContextInfo() and sheetDidDismissReturnCodeContextInfo()
  }

  /**
   * Runs a modal session.
   *
   * @param sess  Return value from a previous invocation of
   *     {@link #beginModalSessionForWindow()}.
   */
  public function runModalSession(session:NSModalSession):Void {
    //
    // Make sure we're dealing with the right session
    //
    if (session != m_modalSession) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        NSException.NSInvalidArgument,
        "session argument must be the return value from the last invocation " +
        "of NSApplication.beginModalSessionForWindow()",
        null);
      trace(e);
      e.raise();
    }

    //
    // Send the session's window to the front
    //
    var win:NSWindow = session.window;
    win.orderFrontRegardless();

    //
    // Set the window to key and main if it supports it
    //
    if(win.canBecomeKeyWindow()) {
      win.makeKeyWindow();
    } else if (win.canBecomeMainWindow()) {
      win.makeMainWindow();
    }

    //
    // Start using modalSendEvent instead of sendEvent
    //
    if(sendEvent!=modalSendEvent) {
    	originalSendEvent = sendEvent;
    	sendEvent = modalSendEvent;
    }
  }

  /**
   * <p>Starts a modal loop for window, encapsulating beginning and running
   * it.</p>
   *
   * <p>This method differs from the spec because ActionScript is single
   * threaded and does not support blocking on specific threads.</p>
   *
   * <p>Because of this, 3 additional parameters are provided.
   * <code>callbackObject</code> is an object that gets it's method named
   * <code>aSelector</code> called when the modal session finishes.
   * <code>docWindow</code> specifies the window that is beginning the
   * modal loop.</p>
   */
  public function runModalForWindow(win:NSWindow, callbackObject:Object,
      aSelector:String, docWin:NSWindow):Void {
    runModalForWindowIsSheet(win, callbackObject, aSelector, docWin, false);
  }

  /**
   * Used internally by <code>#runModalForWindow()</code> to specify whether
   * we're running modal for a sheet or not.
   */
  private function runModalForWindowIsSheet(win:NSWindow, callbackObject:Object,
      aSelector:String, docWin:NSWindow, isSheet:Boolean):Void {
    var sess:NSModalSession = beginModalSessionForWindow(win,
      this, "modalWindowEventCallback", docWin);
    sess.isSheet = isSheet;
    runModalSession(sess);
    
    m_modalCallback = callbackObject;
    m_modalSelector = aSelector;
  }

  /**
   * <p>Stops a modal event loop.</p>
   *
   * <p>Calls {@link #stopModalWithCode()} internally with an
   * {@link NSRunResponse#NSStopped} argument.</p>
   */
  public function stopModal() {
//    trace("NSApplication.stopModal()");
    stopModalWithCode(NSRunResponse.NSStopped);
  }

  /**
   * <code>ret</code> can be both {@link NSRunResponse} or
   * {@link NSAlertReturn}.
   */
  public function stopModalWithCode(ret:NSRunResponse):Void {
//    trace("NSApplication.stopModalWithCode(ret)");
    if(m_modalSession == null) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo
      ("NSInvalidArgumentException", "not in a modal session", null);
      trace(e);
      e.raise();
    }
    m_modalSession.runState = ret;
    endModalSession(m_modalSession);
  }

  /**
   * Returns the window of the current modal session, or <code>null</code> if
   * there is no current modal session.
   */
  public function modalWindow():NSWindow {
    return m_modalSession.window;
  }

  /**
   * <p>Returns <code>true</code> if the application has a modal session
   * running.</p>
   *
   * <p>This is an ActionStep only method.</p>
   */
  public function isRunningModal():Boolean {
    return !(m_modalSession==null);
  }

  /**
   * Returns the current modal session, or <code>null</code> if there is none.
   */
  public function modalSession():NSModalSession {
    return m_modalSession;
  }

  /**
   * Called by the modal send event method to check whether the current modal
   * session should end. If it should, this method is responsible for calling
   * <code>#endModalSession()</code>.
   */
  private function modalWindowEventCallback(ret:Object, lastrun) {
  	if(lastrun == null) {
      lastrun = false;
    }

    if (!lastrun && ret != NSRunResponse.NSContinues) {
//      trace("NSApplication.modalWindowEventCallback(ret, lastrun)");
      endModalSession(m_modalSession);
    } else {
      m_modalCallback[m_modalSelector].call(m_modalCallback, ret);
    }

    // FIXME is this required?
//    var sess = m_modalSession;
//    if(sess.window instanceof ASAlertPanel) {
//      var win:ASAlertPanel = ASAlertPanel(sess.window);
//      var sel = win.didEndSelector();
//      trace(o);
//      trace(sel);
//      o[sel].call(win, sess.runState, null);
//      sel = win.didDismissSelector();
//      o[sel].call(win, sess.runState, null);
//    }
  }

  /**
   * This method is used to replace {@link #sendEvent()} when a modal session
   * is in progress.
   * 
   * <code>#modalWindowEventCallback()</code> is called on each iteration of the
   * event loop to determine whether the modal session should end.
   * 
   * @see #modalWindowEventCallback()
   */
  private function modalSendEvent(event:NSEvent):Void {
    var done:Boolean = false;
    var session:NSModalSession = m_modalSession;
    
    //
    // Process the event
    //
    if (event != null) {
      var eventWindow:NSWindow = event.window;
      if (event.type == NSEvent.NSKeyDown || event.type == NSEvent.NSKeyUp) {
        eventWindow = m_keyWindow;
      }

      //
      // We handle events for the session window, events for any
      // window which works when modal, and any window management
      // events.  All others are ignored/discarded.
      //
      if (!session.isSheet) {
      	if(!(eventWindow == session.window
      		|| eventWindow.worksWhenModal()
      		|| event.type == NSEvent.NSAppKitDefined)) {
        	event = null;
      	}
      } else {
      	var sess:NSModalSession = session;
      	while(sess) {
      		if(sess.docWin == eventWindow) {
      			event = null;
      			break;
      		} else {
      			sess = sess.previous;
      		}
      	}
      }
    }

    //
    // Invoke the callback
    //
    try {
      session.callback[session.selector].call(session.callback, session.runState);
    } catch (e:Error) {
      trace(e.toString());
    }
    
    //
    // Call the original sendEvent() method if we still have an event to
    // process
    //
    if (event != null) {
      originalSendEvent(event);
    }
  }

  //******************************************************
  //*                 Managing sheets
  //******************************************************

  /**
   * <p>Starts a document modal session.</p>
   * 
   * The <code>didEndSelector</code> argument is optional. If implemented by the
   * modalDelegate, this method is invoked after the modal session has ended and
   * is passed a return code and <code>contextInfo</code>. 
   * <code>didEndSelector</code> should have the following signature:
   * 
   * function sheetDidEnd(sheet:NSWindow, returnCode:NSRunResponse, contextInfo:Object):Void
   */
  public function beginSheetModalForWindowModalDelegateDidEndSelectorContextInfo(
      sheet:NSWindow, docWin:NSWindow, 
      delegate:Object, didEndSelector:String, contextInfo:Object):Void {
		// store the arguments
    m_sheetCallbacks[sheet.windowNumber()] = NSInvocation.invocationWithTargetSelectorArguments(
      delegate, didEndSelector, sheet, null, contextInfo);
    runModalForWindowIsSheet(sheet, this, "sheetCallback", docWin, true);
  }

  private function sheetCallback(ret:NSRunResponse) {
    if(ret==NSRunResponse.NSContinues)  return;
    
//    trace("NSApplication.sheetCallback(ret)");
    m_currentSheetCallback.setArgumentAtIndex(ret, 1);
    m_currentSheetCallback.invoke();
  }

  public function endSheet(sheet:NSWindow):Void {
    stopModal();
  }

  public function endSheetReturnCode(sheet:NSWindow,
      returnCode:NSRunResponse):Void {
    stopModalWithCode(returnCode);
  }

  //******************************************************
  //*                  Managing windows
  //******************************************************

  public function keyWindow():NSWindow {
    return m_keyWindow;
  }

  public function mainWindow():NSWindow {
    return m_mainWindow;
  }

  public function windows():Array {
    return NSWindow.instances();
  }

  public function updateWindowsIfNeeded() {
    var wins:Array = windows();
    for (var i:Number = 0;i < wins.length;i++) {
        NSWindow(wins[i]).displayIfNeeded();
    }
    updateAfterEvent();
  }

  public function setWindowsNeedDisplay(value:Boolean) {
    m_windowsNeedDisplay = value;
  }

  public function windowsNeedDisplay():Boolean {
    return m_windowsNeedDisplay;
  }

  //******************************************************
  //*             Getting the main menu
  //******************************************************

  public function mainMenu():NSMenu {
    return m_menu;
  }

  public function setMainMenu(m:NSMenu):Void {
    if (m_menu != null && m_menu != m) {
      m_menu.close();
      m_menu.window().setLevel(NSWindow.NSSubmenuWindowLevel);
      m_menu.setRoot(false, this);
    }

    m_menu = m;

    // Set the title of the window.
    // This won't be displayed, but the window manager may need it.
    m_menu.window().setTitle("NSApp");
    m_menu.window().setLevel(NSWindow.NSMainMenuWindowLevel);
    m_menu.setGeometry();
    m_menu.setRoot(true, this);
  }

  public function menu():NSMenu {
    return mainMenu();
  }

  public function setMenu(m:NSMenu):Void {
    setMainMenu(m);
  }

  //******************************************************
  //*             Sending action messages
  //******************************************************

  public function sendActionToFrom(action:String, to:Object, from:Object):Boolean {
    if (action == null) {
      return false;
    }
    if (to != null) {
      return dispatchFunction(to, action, from);
    }

    // attempt key window responder chain
    var responder:NSResponder = m_keyWindow.firstResponder();
    while(responder != null) {
      if (dispatchFunction(responder, action, from)) {
        return true;
      }
      responder = responder.nextResponder();
    }
    // attempt key window delegate
    if (dispatchFunction(m_keyWindow.delegate(), action, from)) {
        return true;
    }

    if (m_keyWindow != m_mainWindow) {
      // attempt main window responder chain
      responder = m_mainWindow.firstResponder();
      while(responder != null) {
        if (dispatchFunction(responder, action, from)) {
          return true;
        }
        responder = responder.nextResponder();
      }
      // attempt main window delegate
      if (dispatchFunction(m_mainWindow.delegate(), action, from)) {
        return true;
      }
    }

    // attempt this application
    if (dispatchFunction(this, action, from)) return true;
    // attempt this application's delegate
    if (dispatchFunction(this.delegate(), action, from)) return true;
    return false;
  }

  public function targetForActionToFrom(sel:String, targ:Object,
      sender:Object):Object {
    if(targ!=null) {
      return targ;
    }
    return targetForAction(sel);
  }

  /**
   * Somewhat similar in searching behaviour as {@link #sendActionToFrom()}.
   */
  public function targetForAction(sel:String):Object {
    if(sel==null) {
      return null;
    }

    // attempt key window responder chain
    var candidate:NSResponder = m_keyWindow.firstResponder();
    while(candidate != null) {
      if(ASUtils.respondsToSelector(candidate, sel)) {
        return candidate;
      }
      candidate = candidate.nextResponder();
    }

    // attempt key window delegate
    if(ASUtils.respondsToSelector(m_keyWindow.delegate(), sel)) {
      return candidate;
    }

    if (m_keyWindow != m_mainWindow) {
      // attempt main window responder chain
      candidate = m_mainWindow.firstResponder();
      while(candidate != null) {
        if(ASUtils.respondsToSelector(candidate, sel)) {
          return candidate;
        }
        candidate = candidate.nextResponder();
      }
      // attempt main window delegate
      if(ASUtils.respondsToSelector(m_mainWindow.delegate(), sel)) {
        return candidate;
      }
    }

    // attempt this application
    if (respondsToSelector(sel)) {
      return this;
    }
    // attempt this application's delegate
    if (ASUtils.respondsToSelector(delegate(), sel)) {
      return this;
    }
    return null;
  }

  private function dispatchFunction(to:Object, func:String,
      from:Object):Boolean {
    if (to == null) return false;
    if (typeof(to[func])=="function") {
      try {
        to[func].call(to, from);
      } catch(e:Error) {
        trace(asFatal(e.message));
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  //******************************************************
  //*               Assigning a delegate
  //******************************************************

  public function delegate():Object {
    return m_delegate;
  }

  public function setDelegate(value:Object) {
    if(m_delegate != null) {
      m_notificationCenter.removeObserverNameObject(m_delegate, null, this);
    }
    m_delegate = value;
    if (value == null) {
      return;
    }

    mapDelegateNotification("DidBecomeActive");
    mapDelegateNotification("DidChangeScreenParameters");
    mapDelegateNotification("DidFinishLaunching");
    mapDelegateNotification("DidHide");
    mapDelegateNotification("DidResignActive");
    mapDelegateNotification("DidUnhide");
    mapDelegateNotification("DidUpdate");
    mapDelegateNotification("WillBecomeActive");
    mapDelegateNotification("WillFinishLaunching");
    mapDelegateNotification("WillHide");
    mapDelegateNotification("WillResignActive");
    mapDelegateNotification("WillTerminate");
    mapDelegateNotification("WillUnhide");
    mapDelegateNotification("WillUpdate");
  }

  private function mapDelegateNotification(name:String) {
    if(typeof(m_delegate["application"+name]) == "function") {
      m_notificationCenter.addObserverSelectorNameObject(m_delegate, "application"+name, ASUtils.intern("NSApplication"+name+"Notification"), this);
    }
  }

  //******************************************************
  //*              NSWindows notifications
  //******************************************************

  private function __windowWillClose(notification:NSNotification) {
  	var window:NSWindow = NSWindow(notification.object);
    var windowList:Array = this.windows();
    var targetList:Array = new Array();
    var count:Number = windowList.length;
    var wasKey:Boolean = window.isKeyWindow();
    var wasMain:Boolean = window.isMainWindow();
    var i:Number;
    for (i = 0;i<count;i++) {
      if (windowList[i].canBecomeKeyWindow() && windowList[i].isVisible() && (windowList[i]!=window)) {
        targetList.push(windowList);
      }
    }
    count = targetList.length;
    if (wasMain && (count == 0)) {
      //terminate after delegate call to applicationShouldTerminateAfterLastWindowClosed
    }
    if (wasMain) {
      window.resignMainWindow();
    }
    if (wasKey) {
      window.resignKeyWindow();
    }

    window = mainWindow();
    if (window != null && window.canBecomeKeyWindow()) {
      window.makeKeyAndOrderFront(this);
    } else if (window != null) {
      for (i = 0;i<count;i++) {
        window = NSWindow(targetList[i]);
        if (window.canBecomeKeyWindow()) {
          window.makeKeyAndOrderFront(this);
        }
      }
    } else {
      for (i = 0;i<count;i++) {
        window = NSWindow(targetList[i]);
        if (window.canBecomeMainWindow()) {
          window.makeMainWindow(this);
          break;
        }
      }
      for (i = 0;i<count;i++) {
        window = NSWindow(targetList[i]);
        if (window.canBecomeKeyWindow()) {
          window.makeKeyAndOrderFront(this);
          break;
        }
      }

    }
  }

  private function __windowDidBecomeKey(notification:NSNotification) {
    if (m_keyWindow == null && (notification.object instanceof NSWindow)) {
      m_keyWindow = NSWindow(notification.object);
    } else {
      trace("Non-NSWindow tried to become key: "+notification.object);
      trace("Key window: "+m_keyWindow);
    }
  }

  private function __windowDidBecomeMain(notification:NSNotification) {
    if (m_mainWindow == null && (notification.object instanceof NSWindow)) {
      m_mainWindow = NSWindow(notification.object);
    } else {
      trace("Non-NSWindow tried to become main: "+notification.object);
      trace("Key window: "+m_mainWindow);
    }
  }

  private function __windowDidResignKey(notification:NSNotification) {
    if (m_keyWindow == notification.object) {
      m_keyWindow = null;
    } else {
      trace("Window resigned key but was not key "+notification.object);
    }
  }

  private function __windowDidResignMain(notification:NSNotification) {
    if (m_mainWindow == notification.object) {
      m_mainWindow = null;
    }  else {
      trace("Window resigned main but was not main "+notification.object);
    }
  }

  //******************************************************
  //*            Accessing the application
  //******************************************************

  public static function sharedApplication():NSApplication {
    if (g_sharedApplication == null) {
      ASTheme.current().registerDefaultImages();
      g_sharedApplication = (new NSApplication());
      g_sharedApplication.init(); // MUST BE A SEPARATE CALL

    }
    return g_sharedApplication;
  }

  //******************************************************
  //*            Loading external libraries
  //******************************************************

  /**
   * <p>Loads an external class library from the url <code>swfURL</code>.</p>
   *
   * <p>When the loading has finished, the method named <code>selector</code> will
   * be called on <code>callback</code> with a two arguments. The first
   * is <code>data</code>. The second is a <code>Boolean</code> value specifying
   * whether or not the load succeed.</p>
   */
  public static function loadLibraryWithCallbackSelectorData(swfURL:String,
      callback:Object, selector:String, data:Object):Void {
    var baseClip:MovieClip = _root.__ACTIONSTEP_LIBRARIES__;
    if (baseClip == undefined) {
      baseClip = _root.createEmptyMovieClip("__ACTIONSTEP_LIBRARIES__", -15894);
      baseClip._x = -1000;
      baseClip._y = -1000;
    }
    libraryCount++;
    var loaderClip:MovieClip = baseClip.createEmptyMovieClip(
      "Library"+libraryCount, libraryCount);
    var monitor:Object = new Object();
    var swfToLoad:String = swfURL;
    var objectToCall:Object = callback;
    var selectorToCall:String = selector;
    var dataToPass:Object = data;
    monitor.onLoadInit = function(target_mc:MovieClip) {
      objectToCall[selectorToCall].call(objectToCall, dataToPass, true);
      NSApplication.sharedApplication().updateWindowsIfNeeded();
    };
    monitor.onLoadError = function(target_mc:MovieClip, errorCode:String,
        httpStatus:Number) {
      trace(ASDebugger.error("Error while loading " + swfURL + ". Error code: " + errorCode));
      objectToCall[selectorToCall].call(objectToCall, dataToPass, false);
    };

    var image_mcl:MovieClipLoader = new MovieClipLoader();
    image_mcl.addListener(monitor);
    image_mcl.loadClip(swfToLoad, loaderClip);
  }



}