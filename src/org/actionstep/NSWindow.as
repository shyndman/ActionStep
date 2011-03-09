/* See LICENSE for copyright and terms of use */

import org.actionstep.ASAnimation;
import org.actionstep.ASFieldEditor;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSAnimationCurve;
import org.actionstep.constants.NSDragOperation;
import org.actionstep.constants.NSDrawerState;
import org.actionstep.constants.NSSelectionDirection;
import org.actionstep.constants.NSWindowOrderingMode;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSButton;
import org.actionstep.NSButtonCell;
import org.actionstep.NSColor;
import org.actionstep.NSDictionary;
import org.actionstep.NSDraggingDestination;
import org.actionstep.NSDraggingInfo;
import org.actionstep.NSDraggingSource;
import org.actionstep.NSDrawer;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSImage;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPasteboard;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSResponder;
import org.actionstep.NSSize;
import org.actionstep.NSToolbar;
import org.actionstep.NSUndoManager;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.window.ASRootWindowView;

/**
 * <p>
 * An <code>NSWindow</code> represents an on-screen window. It manages its
 * views, display and event handling.
 * </p>
 * <p>
 * The <code>NSWindow</code> class defines objects that manage and coordinate 
 * the windows an application displays on the screen. A single 
 * <code>NSWindow</code> object corresponds to at most one onscreen window. The 
 * two principal functions of a window are to provide an area in which views can 
 * be placed and to accept and distribute, to the appropriate views, events the 
 * user instigates through actions with the mouse and keyboard.
 * </p>
 *
 * @author Richard Kilmer
 * @author Tay Ray Chuan
 * @author Scott Hyndman
 */
class org.actionstep.NSWindow extends NSResponder {

  //******************************************************
  //*                     Styles
  //******************************************************

  /** Bit mask for a window without a border */
  public static var NSBorderlessWindowMask:Number = 0;
  
  /** Bit mask for a window with a title bar */
  public static var NSTitledWindowMask:Number = 1;
  
  /** Bit mask for a window with a close button */
  public static var NSClosableWindowMask:Number = 2;
  
  /** Bit mask for a window with a miniaturize button */
  public static var NSMiniaturizableWindowMask:Number = 4;
  
  /** Bit mask for a resizable window */
  public static var NSResizableWindowMask:Number = 8;
  
  /** Bit mask for a non-resizable window with a title bar and all buttons */
  private static var ASAllButResizable:Number = 7;

  /** This is used internally. */
  public static var NSNotDraggableWindowMask:Number = 16;

  //******************************************************
  //*                 Window Levels
  //******************************************************

  /** GNUstep addition	*/
  public static var	NSDesktopWindowLevel:Number = -1000;

  /**  default level for NSWindow objects. */
  public static var	NSNormalWindowLevel:Number = 0;

  /** Useful for floating palettes. */
  public static var NSFloatingWindowLevel:Number = 3;

  /**
   * Reserved for submenus. Synonymous with NSTornOffMenuWindowLevel,
   * which is preferred.
   */
  public static var NSSubmenuWindowLevel:Number = 3;

  /** The level for a torn-off menu. Synonymous with NSSubmenuWindowLevel. */
  public static var NSTornOffMenuWindowLevel:Number = 3;

  /** Reserved for the applications main menu. */
  public static var NSMainMenuWindowLevel:Number = 20;
  
  /** The level for status windows */
  public static var NSStatusWindowLevel:Number = 21;
  
  /** The level for modal panels */
  public static var NSModalPanelWindowLevel:Number = 100;
  
  /** The level for popup windows */
  public static var NSPopUpMenuWindowLevel:Number = 101;
  
  /** The level for screensavers (not used, obviously) */
  public static var NSScreenSaverWindowLevel:Number = 1000;

  //******************************************************
  //                 Notifications
  //******************************************************

  /** Posted when the content swf of a window is loaded. */
  public static var ASWindowContentSwfDidLoad:Number
    = ASUtils.intern("ASWindowContentSwfDidLoad");

  /** Posted whenever an NSWindow is about to close. */
  public static var NSWindowWillCloseNotification:Number
    = ASUtils.intern("NSWindowWillCloseNotification");

  /** Posted when a window becomes the key window. */
  public static var NSWindowDidBecomeKeyNotification:Number
    = ASUtils.intern("NSWindowDidBecomeKeyNotification");

  /** Posted when a window becomes the main window. */
  public static var NSWindowDidBecomeMainNotification:Number
    = ASUtils.intern("NSWindowDidBecomeMainNotification");

  /** Posted when a window resigns its key status. */
  public static var NSWindowDidResignKeyNotification:Number
    = ASUtils.intern("NSWindowDidResignKeyNotification");

  /** Posted when a window resigns its main status. */
  public static var NSWindowDidResignMainNotification:Number
    = ASUtils.intern("NSWindowDidResignMainNotification");

  /** Posted when a window displays. */
  public static var NSWindowDidDisplayNotification:Number
    = ASUtils.intern("NSWindowDidDisplayNotification");

  /** Posted whenever an NSWindow’s size changes. */
  public static var NSWindowDidResizeNotification:Number
    = ASUtils.intern("NSWindowDidResizeNotification");

  /** Posted whenever an NSWindow is about to move. */
  public static var NSWindowWillMoveNotification:Number
    = ASUtils.intern("NSWindowWillMoveNotification");

  /** Posted whenever an NSWindow is moved. */
  public static var NSWindowDidMoveNotification:Number
    = ASUtils.intern("NSWindowDidMoveNotification");

  /** Posted whenever an NSWindow is about to be miniaturized. */
  public static var NSWindowWillMiniaturizeNotification:Number
    = ASUtils.intern("NSWindowWillMiniaturizeNotification");

  /** Posted whenever an NSWindow is miniaturized. */
  public static var NSWindowDidMiniaturizeNotification:Number
    = ASUtils.intern("NSWindowDidMiniaturizeNotification");

  /** Posted whenever an NSWindow is deminiaturized. */
  public static var NSWindowDidDeminiaturizeNotification:Number
    = ASUtils.intern("NSWindowDidDeminiaturizeNotification");

  //******************************************************
  //*                Class members
  //******************************************************

  /** The default stage width */
  private static var g_defaultStageWidth:Number = 550;
  
  /** The default stage height */
  private static var g_defaultStageHeight:Number = 400;

  /** An array of all window instances in the application */
  private static var g_instances:Array = new Array();

  /** <code>true</code> if a drag and drop operation is in process */
  private static var g_isDragging:Boolean;
  
  /** The current drag and drop information object */
  private static var g_currentDragInfo:NSDraggingInfo;
  
  /** The starting point of the drag and drop operation */
  private static var g_dragStartPt:NSPoint;
  
  /** The last view under the mouse during the current drag and drop operation */
  private static var g_lastDragView:NSView;

  //******************************************************
  //*               Member Variables
  //******************************************************

  private var m_app:NSApplication;
  private var m_notificationCenter:NSNotificationCenter;
  private var m_windowNumber:Number;
  private var m_delegate:Object;
  private var m_frameRect:NSRect;
  private var m_contentRect:NSRect;
  private var m_contentOrigin:NSPoint;
  private var m_firstResponder:NSResponder;
  private var m_initialFirstResponder:NSView;
  private var m_rootView:ASRootWindowView;
  private var m_contentView:NSView;
  private var m_styleMask:Number;
  private var m_viewsNeedDisplay:Boolean;
  private var m_fieldEditor:ASFieldEditor;
  private var m_rootSwfURL:String;
  private var m_title:String;
  private var m_isKey:Boolean;
  private var m_isMain:Boolean;
  private var m_isVisible:Boolean;
  private var m_canHide:Boolean;
  private var m_lastEventView:NSView;
  private var m_level:Number;
  private var m_acceptsMouseMoved:Boolean;
  private var m_lastPoint:NSPoint;
  private var m_lastView:NSView;
  private var m_cursorRectsEnabled:Boolean;
  private var m_defButtonCell:NSButtonCell;
  private var m_keyEquivForDefButton:Boolean;
  private var m_selectionDirection:NSSelectionDirection;
  private var m_backgroundColor:NSColor;
  private var m_minFrameSize:NSSize;
  private var m_maxFrameSize:NSSize;
  private var m_isMini:Boolean;
  private var m_preminiSize:NSSize;
  private var m_preminiStyle:Number;
  private var m_preminiResizeInd:Boolean;
  private var m_undoManager:NSUndoManager;
  private var m_backgroundMovable:Boolean;
  private var m_registeredDraggedTypes:NSDictionary;
  private var m_icon:NSImage;
  private var m_viewClass:Function;
  private var m_parentWindow:NSWindow;
  private var m_childWindows:NSArray;
  private var m_drawers:NSArray;
  private var m_toolbar:NSToolbar;
  private var m_releasedWhenClosed:Boolean;
  private var m_makeMainAndKey:Boolean;
  
  //
  // Animation
  //
  private var m_isAnimating:Boolean;
  private var m_xAnimator:ASAnimation;
  private var m_yAnimator:ASAnimation;
  private var m_wAnimator:ASAnimation;
  private var m_hAnimator:ASAnimation;
  private var m_displayViewsAfterAnimate:Boolean;

  //******************************************************
  //*                   Construction
  //******************************************************

  /**
   * Constructs a new instance of the <code>NSWindow</code> class.
   *
   * Should be followed by a call to one of the initializer methods.
   */
  public function NSWindow() {
	m_app = NSApplication.sharedApplication();
    m_viewsNeedDisplay = true;
    m_fieldEditor= ASFieldEditor.instance();
    m_title = "";
    m_isKey = false;
    m_isMain = false;
    m_isVisible = true;
    m_canHide = true;
    m_acceptsMouseMoved = false;
    m_cursorRectsEnabled = true;
    m_releasedWhenClosed = true;
    m_keyEquivForDefButton = true;
    m_backgroundMovable = false;
    m_isMini = false;
    m_level = NSNormalWindowLevel;
    m_registeredDraggedTypes = NSDictionary.dictionary();
    m_backgroundColor = null;//NSColor.windowBackgroundColor();
    m_icon = null;
	m_windowNumber = g_instances.push(this)-1;
	m_selectionDirection = NSSelectionDirection.NSDirectSelection;
	m_minFrameSize = new NSSize(1,1);
	m_maxFrameSize = new NSSize(10000, 10000);
	m_drawers = NSArray.array();
	m_childWindows = NSArray.array();
	
    m_isAnimating = false;
    m_displayViewsAfterAnimate = false;
  }

  /**
   * Initializes a borderless window with a content rect of
   * {@link NSRect#ZeroRect}.
   */
  public function init():NSWindow {
    return initWithContentRectStyleMaskSwf(NSRect.ZeroRect, NSBorderlessWindowMask, null);
  }

  /**
   * Initializes a borderless window with a frame of {@link NSRect#ZeroRect}
   * and begins loading its contents using the swf at <code>swf</code>.
   */
  public function initWithSwf(swf:String):NSWindow {
    return  initWithContentRectStyleMaskSwf(NSRect.ZeroRect, NSBorderlessWindowMask, swf);
  }

  /**
   * Initializes a borderless window with a content rect of
   * <code>contentRect</code>.
   */
  public function initWithContentRect(contentRect:NSRect):NSWindow {
    return initWithContentRectStyleMaskSwf(contentRect, NSBorderlessWindowMask, null);
  }

  /**
   * Initializes the window with a content rect of <code>contentRect</code>
   * and a view class of <code>viewClass</code>.
   *
   * <code>viewClass</code> must be a subclass of ASRootWindowView. If it is
   * not, and NSException is raised.
   */
  public function initWithContentRectViewClass(contentRect:NSRect,
      viewClass:Function):NSWindow {
  	return initWithContentRectStyleMaskSwfViewClass(contentRect,
  	  NSBorderlessWindowMask,
  	  null,
  	  viewClass);
  }

  public function initWithContentRectSwf(contentRect:NSRect, swf:String):NSWindow {
    return initWithContentRectStyleMaskSwf(contentRect, NSBorderlessWindowMask, swf);
  }

  public function initWithContentRectStyleMask(contentRect:NSRect, styleMask:Number):NSWindow {
    return initWithContentRectStyleMaskSwf(contentRect, styleMask, null);
  }

  /**
   * Initializes a window with a content rect of <code>contentRect</code>,
   * using <code>styleMask</code> to define it's styles.
   *
   * <code>viewClass</code> is the class used to render the window. It must be
   * a subclass of <code>ASRootWindowView</code>. If it is <code>null</code>,
   * <code>ASRootWindowView</code> will be used. If <code>viewClass</code> is
   * provided and is not a subclass of <code>ASRootWindowView</code>, an
   * exception is raised.
   */
  public function initWithContentRectStyleMaskViewClass(contentRect:NSRect,
      styleMask:Number, viewClass:Function):NSWindow {
    return initWithContentRectStyleMaskSwfViewClass(contentRect, styleMask,
    	null, viewClass);
  }

  public function initWithContentRectStyleMaskSwf(contentRect:NSRect, styleMask:Number, swf:String):NSWindow {
    return initWithContentRectStyleMaskSwfViewClass(
      contentRect, styleMask, swf, null);
  }

  /**
   * Initializes a window with a content rect of <code>contentRect</code>,
   * using <code>styleMask</code> to define it's styles.
   *
   * <code>swf</code> is loaded in as the window's base swf so that assets will
   * be available for use. If <code>swf</code> is null, none is used.
   *
   * <code>viewClass</code> is the class used to render the window. It must be
   * a subclass of <code>ASRootWindowView</code>. If it is <code>null</code>,
   * <code>ASRootWindowView</code> will be used. If <code>viewClass</code> is
   * provided and is not a subclass of <code>ASRootWindowView</code>, an
   * exception is raised.
   */
  public function initWithContentRectStyleMaskSwfViewClass(contentRect:NSRect,
      styleMask:Number, swf:String, viewClass:Function):NSWindow {
    super.init();

    //
    // Use the provided view class if one has been provided.
    //
    if (null != viewClass) {
      m_viewClass = viewClass;
    }

	m_rootSwfURL = swf;
    m_rootView = ASRootWindowView(ASUtils.createInstanceOf(this.viewClass()));
    m_rootView.initWithFrameWindow(NSRect.ZeroRect, this);
    
    //
    // Throw an exception if viewClass is not a subclass of ASRootWindowView.
    //
    if (m_rootView == null) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        "NSInvalidTypeException",
        "The passed view class is not a subclass of ASRootWindowView",
        null);
      trace(e);
      throw e;
    }

    m_notificationCenter = NSNotificationCenter.defaultCenter();
    m_styleMask = styleMask;
    m_contentRect = contentRect.clone();
    m_frameRect = frameRectForContentRect();
    m_rootView.setFrame(m_frameRect);
    m_contentOrigin = convertScreenToBase(contentRect.origin.clone());    

    setContentView((new NSView()).initWithFrame(NSRect.withOriginSize(
    	convertScreenToBase(m_contentRect.origin), m_contentRect.size)));
    return this;
  }

  //******************************************************
  //*               Describing the object
  //******************************************************

  /**
   * Returns a string representation of the window.
   */
  public function description():String {
    return "NSWindow(number="+m_windowNumber+", view="+m_rootView+")";
  }

  //******************************************************
  //*             Getting the window number
  //******************************************************

  /**
   * Returns the window's window number.
   */
  public function windowNumber():Number {
    return m_windowNumber;
  }

  //******************************************************
  //*             Getting the root view
  //******************************************************

  /**
   * <p>Returns the view actually used to display the window.</p>
   *
   * The class of the view the window uses can be set using the
   * {@link #initWithContentRectStyleMaskSwfViewClass()} and
   * {@link #initWithContentRectViewClass()} initializers.
   *
   * <p>This method is ActionStep-specific.</p>
   */
  public function rootView():ASRootWindowView {
    return m_rootView;
  }

  //******************************************************
  //*             Getting the root swf
  //******************************************************

  /**
   * <p>Returns this window's swf URL.</p>
   *
   * <p>This is the swf that the window is created within. The window, and all
   * of its views, have full access to the library of swf.</p>
   */
  public function swf():String {
    return m_rootSwfURL;
  }

  //******************************************************
  //*               Calculating layout
  //******************************************************

  public static function contentRectForFrameRectStyleMask(frameRect:NSRect, styleMask:Number):NSRect {
    return contentRectForWindowFrameRectStyleMask(null, frameRect, styleMask);
  }

  public static function contentRectForWindowFrameRectStyleMask(wnd:NSWindow, frameRect:NSRect, styleMask:Number):NSRect {
    var rect:NSRect = frameRect.clone();
    if (styleMask == NSBorderlessWindowMask) {
      return rect;
    }
    if (styleMask & NSTitledWindowMask) {
      var titleHeight:Number = wnd != null ? wnd.rootView().titleRect().size.height :
      	ASTheme.current().windowTitleBarHeight();
      rect.origin.y += titleHeight + 1;
      rect.size.height -= (titleHeight + 2);
      rect.origin.x += 1;
      rect.size.width -= 2;
    }
    return rect;
  }

  public static function frameRectForContentRectStyleMask(frameRect:NSRect, styleMask:Number):NSRect {
    return frameRectForWindowContentRectStyleMask(null, frameRect, styleMask);
  }

  public static function frameRectForWindowContentRectStyleMask(wnd:NSWindow, contentRect:NSRect, styleMask:Number):NSRect {
    var rect:NSRect = contentRect.clone();
    if (styleMask == NSBorderlessWindowMask) {
      return rect;
    }
    /*
    public static var NSBorderlessWindowMask = 0
    public static var NSTitledWindowMask = 1
    public static var NSClosableWindowMask = 2
    public static var NSMiniaturizableWindowMask = 4
    public static var NSResizableWindowMask = 8
    */
    //! Based on style masks reshape?
    if (styleMask & NSTitledWindowMask) {
      var titleHeight:Number = wnd != null ? wnd.rootView().titleRect().size.height :
      	ASTheme.current().windowTitleBarHeight();
      rect.origin.y -= (titleHeight + 1);
      rect.size.height += titleHeight + 2;
      rect.origin.x -= 1;
      rect.size.width += 2;
    }
    return rect;
  }

  public function contentRectForFrameRect():NSRect {
    var rect:NSRect = NSWindow.contentRectForWindowFrameRectStyleMask(this, m_frameRect, m_styleMask);
    if (m_toolbar != null && m_toolbar.isVisible()) {
      var tbHeight:Number = ASTheme.current().toolbarHeightForToolbar(m_toolbar);
      rect.origin.y += tbHeight;
      rect.size.height -= tbHeight;
    }
    
    return rect;
  }

  public function frameRectForContentRect():NSRect {
    var frm:NSRect = NSWindow.frameRectForWindowContentRectStyleMask(this, m_contentRect, m_styleMask);

    if (m_toolbar != null && m_toolbar.isVisible()) {
      var tbHeight:Number = ASTheme.current().toolbarHeightForToolbar(m_toolbar);
      frm.origin.y -= tbHeight;
      frm.size.height += tbHeight;
    }

    if (m_frameRect != null) {
      frm.origin = m_frameRect.origin.clone();      
    }

    return frm;
  }

  //******************************************************
  //*              Converting coordinates
  //******************************************************

  /**
   * <p>
   * Converts a given point from the screen coordinate system to the receiver’s 
   * base coordinate system.
   * </p>
   * 
   * @see #convertBaseToScreen()
   */
  public function convertScreenToBase(point:NSPoint):NSPoint {
    return new NSPoint(point.x - m_frameRect.origin.x, point.y - m_frameRect.origin.y);
  }

  /**
   * <p>
   * Converts a given point from the receiver’s base coordinate system to the 
   * screen coordinate system.
   * </p>
   * 
   * @see #convertScreenToBase()
   */
  public function convertBaseToScreen(point:NSPoint):NSPoint {
    return new NSPoint(m_frameRect.origin.x +point.x, m_frameRect.origin.y + point.y);
  }

  //******************************************************
  //*                Moving and resizing
  //******************************************************

  /**
   * <p>Returns the receiver’s frame rectangle.</p>
   */
  public function frame():NSRect {
    return m_frameRect.clone();
  }

  /**
   * <p>
   * Sets the window's frame to <code>frame</code>, positioning and sizing
   * the content and decorators appropriately.
   * </p>
   * <p>
   * If the window is current smooth-resizing, the animation will be cancelled.
   * </p>
   * 
   * @see #setFrameDisplay()
   * @see #setFrameDisplayAnimate()
   */
  public function setFrame(frame:NSRect):Void {
    setFrameWithNotifications(frame, true);

    //
    // Reset cursor rects
    //
    resetCursorRects();
  }

  /**
   * <p>
   * Sets the frame or the window to <code>frame</code>, and only dispatches
   * notifications if <code>flag</code> is <code>true</code>.
   * </p>
   * <p>
   * If the window is current smooth-resizing and <code>animate</code> is
   * <code>false</code> or omitted, the animation will be cancelled.
   * </p>
   * <p>
   * Intended for internal use only.
   * </p>
   */
  public function setFrameWithNotifications(frame:NSRect, flag:Boolean,
      animate:Boolean):Void {
    if (!animate) {
  	  cancelAnimation();
    }
  	
    frame = constrainFrameRect(frame.clone());
    
    var sizeChange:Boolean = !frame.size.isEqual(m_frameRect.size);
    var locChange:Boolean = !frame.origin.isEqual(m_frameRect.origin);
    
    //
    // Size change
    //
    if (sizeChange) { // Resize
      if (m_delegate != null && typeof(m_delegate["windowWillResizeToSize"]) == "function") {
        frame.size = m_delegate["windowWillResizeToSize"].call(m_delegate, this, frame.size);
      }
    }
    else if (!locChange) {
      return; // Same shape;
    }
    
    //
    // Origin change
    //
    if (locChange) {
      if (flag) {
        m_notificationCenter.postNotificationWithNameObject(NSWindowWillMoveNotification, this);
      }
      m_rootView.setFrameOrigin(frame.origin);
      if (flag) {
        m_notificationCenter.postNotificationWithNameObject(NSWindowDidMoveNotification, this);
      }
    }
    
    //
    // Set the frame rect
    //
    m_frameRect = frame;

    //
    // Resize content
    //
    var cRect:NSRect = contentRectForFrameRect();
    cRect.origin.x -= frame.origin.x;
    cRect.origin.y -= frame.origin.y;
    if (!m_contentRect.isEqual(cRect) || !m_rootView.isResizing()) {
      m_contentView.setFrame(cRect);
      m_contentView.setNeedsDisplay(true);
      m_contentRect = cRect;
    }
    
    if (sizeChange) {
      m_rootView.setFrameSize(frame.size);
      if (flag) {
        m_notificationCenter.postNotificationWithNameObject(NSWindowDidResizeNotification, this);
      }
      m_rootView.setNeedsDisplay(true);
    }
  }

  /**
   * <p>
   * Sets the origin and size of the receiver’s frame rectangle according to a 
   * given frame rectangle, thereby setting its position and size onscreen.
   * </p>
   * <p>
   * <code>displayViews</code> specifies whether the window redraws the views 
   * that need to be displayed. When <code>true</code> the window sends a 
   * <code>NSView#displayIfNeeded</code> message down its view hierarchy, thus 
   * redrawing all views.
   * </p>
   * <p>
   * If the window is current smooth-resizing, the animation will be cancelled.
   * </p>
   * 
   * @see #setFrame()
   * @see #setFrameOrigin()
   * @see #setFrameDisplayAnimate()
   */
  public function setFrameDisplay(rect:NSRect, displayViews:Boolean):Void {
    setFrameDisplayAnimate(rect, displayViews, false);
  }
  
  /**
   * <p>
   * Sets the origin and size of the receiver’s frame rectangle, with optional 
   * animation, according to a given frame rectangle, thereby setting its 
   * position and size onscreen.
   * </p>
   * <p>
   * <code>displayViews</code> specifies whether the window redraws the views 
   * that need to be displayed. When <code>true</code> the window sends a 
   * <code>NSView#displayIfNeeded</code> message down its view hierarchy, thus 
   * redrawing all views.
   * </p>
   * <p>
   * <code>performAnimation</code> specifies whether the window performs a
   * smooth resize.
   * </p>
   * <p>
   * If the window is current smooth-resizing, the animation will be cancelled.
   * </p>
   * 
   * @see #setFrame()
   * @see #setFrameOrigin()
   * @see #setFrameDisplayAnimate()
   */
  public function setFrameDisplayAnimate(rect:NSRect, displayViews:Boolean,
      performAnimation:Boolean):Void {
    if (!performAnimation) {
      setFrame(rect);
      
      if (displayViews) {
        m_rootView.displayIfNeeded();
      }
    } else {
      if (m_isAnimating) {
        cancelAnimation();
      }
      
      var duration:Number = animationResizeTime();
      var curve:NSAnimationCurve = animationCurve();
      
      //
      // Create animators
      //
      m_xAnimator = (new ASAnimation()).initWithDurationAnimationCurve(
      	duration, curve);
      m_yAnimator = (new ASAnimation()).initWithDurationAnimationCurve(
      	duration, curve);
      m_wAnimator = (new ASAnimation()).initWithDurationAnimationCurve(
      	duration, curve);
      m_hAnimator = (new ASAnimation()).initWithDurationAnimationCurve(
      	duration, curve);
      	
      //
      // Set endpoints
      //
      constrainFrameRect(rect);
      
      m_xAnimator.setEndPoints(m_frameRect.origin.x, rect.origin.x);
      m_yAnimator.setEndPoints(m_frameRect.origin.y, rect.origin.y);
      m_wAnimator.setEndPoints(m_frameRect.size.width, rect.size.width);
      m_hAnimator.setEndPoints(m_frameRect.size.height, rect.size.height);
      
      //
      // Create delegates
      //
      var self:NSWindow = this;
      var aniRect:NSRect = NSRect.ZeroRect;
      var xSet:Boolean = false, ySet:Boolean = false, wSet:Boolean = false, hSet:Boolean = false;
      
      //
      // X delegate (has stop methods)
      //
      var xDel:Object = {};
      xDel.animationDidAdvance = function(ani:ASAnimation, val:Number):Void {
        aniRect.origin.x = val;
        if (xSet && ySet && wSet && hSet) {
          self.setFrameWithNotifications(aniRect, false, true);
          xSet = ySet = wSet = hSet = false;
        } else {
          xSet = true;
        }
      };
      xDel.animationDidStop = function(ani:ASAnimation):Void {
        self.setFrame(aniRect);
      };
      xDel.animationDidEnd = xDel.animationDidStop;
      m_xAnimator.setDelegate(xDel);
      
      //
      // Y delegate
      //
      var yDel:Object = {};
      yDel.animationDidAdvance = function(ani:ASAnimation, val:Number):Void {
        aniRect.origin.y = val;
        if (xSet && ySet && wSet && hSet) {
          self.setFrameWithNotifications(aniRect, false, true);
          xSet = ySet = wSet = hSet = false;
        } else {
          ySet = true;
        }
      };
      m_yAnimator.setDelegate(yDel);
      
      //
      // Width delegate
      //
      var wDel:Object = {};
      wDel.animationDidAdvance = function(ani:ASAnimation, val:Number):Void {
        aniRect.size.width = val;
        if (xSet && ySet && wSet && hSet) {
          self.setFrameWithNotifications(aniRect, false, true);
          xSet = ySet = wSet = hSet = false;
        } else {
          wSet = true;
        }
      };
      m_wAnimator.setDelegate(wDel);
      
      //
      // Height delegate
      //
      var hDel:Object = {};
      hDel.animationDidAdvance = function(ani:ASAnimation, val:Number):Void {
        aniRect.size.height = val;
        if (xSet && ySet && wSet && hSet) {
          self.setFrameWithNotifications(aniRect, false, true);
          xSet = ySet = wSet = hSet = false;
        } else {
          hSet = true;
        }
      };
      m_hAnimator.setDelegate(hDel);
      
      //
      // Start animation
      //
      m_xAnimator.startAnimation();
      m_yAnimator.startAnimation();
      m_wAnimator.startAnimation();
      m_hAnimator.startAnimation();
      
      m_displayViewsAfterAnimate = displayViews;
    }
  }
  
  /**
   * <p>
   * Returns the duration (in seconds) of a smooth frame-size change.
   * </p>
   * <p>
   * This value is obtained from the current theme's 
   * <code>ASThemeProtocol#windowAnimationResizeTime()</code> method.
   * </p>
   * 
   * @see #setFrameDisplayAnimate()
   */
  public function animationResizeTime():Number {
    return ASTheme.current().windowAnimationResizeTime(this);
  }
  
  /**
   * <p>
   * Returns the animation curve of a smooth frame-size change.
   * </p>
   * <p>
   * This value is obtained from the current theme's 
   * <code>ASThemeProtocol#windowAnimationResizeCurve()</code> method.
   * </p>
   * 
   * @see #setFrameDisplayAnimate()
   */
  public function animationCurve():NSAnimationCurve {
    return ASTheme.current().windowAnimationResizeCurve(this);
  }

  /**
   * <p>
   * Positions the top-left corner of the receiver’s frame rectangle at a given 
   * point in screen coordinates.
   * </p>
   * <p>
   * This differs from the Cocoa implementation by positioning the window
   * using the top-left corner of the frame, not the bottom-left.
   * </p>
   * 
   * @see #setFrame()
   * @see #setFrameDisplay()
   */
  public function setFrameOrigin(point:NSPoint):Void {
    var oldOrigin:NSPoint = m_frameRect.origin;
    var f:NSRect = m_frameRect.clone();
    f.origin = point;
    setFrame(f);

    //
    // Deal with child windows
    //
    if (m_childWindows.count() == 0 || oldOrigin.isEqual(m_frameRect.origin)) {
      return;
    }

    var delta:NSPoint = oldOrigin.pointDistanceToPoint(m_frameRect.origin);
    var arr:Array = m_childWindows.internalList();
    var len:Number = arr.length;
    for (var i:Number = 0; i < len; i++) {
      var win:NSWindow = NSWindow(arr[i]);
      win.setFrameOrigin(win.m_frameRect.origin.addPoint(delta));
    }
  }

  /**
   * <p>
   * Returns the size of this window's content.
   * </p>
   * 
   * @see #setContentSize()
   */
  public function contentSize():NSSize {
  	return contentRectForFrameRect().size;
  }

  /**
   * <p>
   * Sets the size of the receiver’s content view to a given size, which is 
   * expressed in the receiver’s base coordinate system.
   * </p>
   * <p>
   * This size in turn alters the size of the <code>NSWindow</code> object 
   * itself, taking into account the size of the frame decorations and any
   * window decorators. Note that window sizes are limited to 10,000; if 
   * necessary, be sure to limit <code>size</code> relative to the frame 
   * rectangle.
   * </p>
   * 
   * @see #contentSize()
   */
  public function setContentSize(size:NSSize):Void {
    m_contentRect.size.width = size.width;
    m_contentRect.size.height = size.height;
    sizeToFitContents();
  }

  /**
   * <p>
   * Positions the receiver's top left to <code>pt</code> and returns a
   * point shifted by the height of the window's title bar. The return value
   * can be passed to subsequent invocations of 
   * <code>#cascadeTopLeftFromPoint()</code> on other windows so all title
   * bars are visible.
   * </p>
   */
  public function cascadeTopLeftFromPoint(pt:NSPoint):NSPoint {
  	var titleHeight:Number = this.rootView().titleRect().size.height;
  	setFrameOrigin(pt);
    return pt.addSize(new NSSize(titleHeight + 2, titleHeight + 2));
  }

  /**
   * <p>Sets the receiver’s location to the center of the screen.</p>
   */
  public function center():Void {
		var w:Number = Stage.width == 0 ? g_defaultStageWidth : Stage.width;
		var h:Number = Stage.height == 0 ? g_defaultStageHeight : Stage.height;
    setFrameOrigin(new NSPoint((w - m_frameRect.size.width)/2,
    	(h - m_frameRect.size.height)/2 - 10));
  }

  /**
   * Returns whether the receiver’s resize indicator is visible.
   *
   * @see #setShowsResizeIndicator()
   */
  public function showsResizeIndicator():Boolean {
    return m_rootView.showsResizeIndicator();
  }

  /**
   * <p>Sets whether the receiver’s resize indicator is visible to show.</p>
   *
   * <p>This method does not affect whether the receiver is resizable.</p>
   *
   * @see #showsResizeIndicator()
   */
  public function setShowsResizeIndicator(value:Boolean):Void {
    m_rootView.setShowsResizeIndicator(value);
  }

  /**
   * <p>
   * Returns a Boolean value that indicates whether the receiver is movable by 
   * clicking and dragging anywhere in its background.
   * </p>
   * <p>
   * The default is <code>false</code>.
   * </p>
   * 
   * @see #setMovableByWindowBackground()
   */
  public function isMovableByWindowBackground():Boolean {
    return m_backgroundMovable;
  }
  
  /**
   * <p>
   * Sets whether the receiver is movable by clicking and dragging anywhere in 
   * its background.
   * </p>
   * <p>
   * <code>flag</code> is <code>true</code> to specify that the window is 
   * movable by background, <code>false</code> to specify that the window is not
   * movable by background.
   * </p>
   * 
   * @see #isMovableByWindowBackground()
   */
  public function setMovableByWindowBackground(flag:Boolean):Void {
    m_backgroundMovable = flag;
  }
  
  /**
   * Called after a content size change, or when a decorator is added or 
   * removed from the window.
   */
  private function sizeToFitContents():Void {
    m_frameRect = frameRectForContentRect();
    m_rootView.setFrame(m_frameRect);
    m_contentView.setFrame(NSRect.withOriginSize(m_contentOrigin, m_contentRect.size));
  }

  /**
   * Used to ensure the window frame is does not exceed minimums and maximums
   * and is big enough to accommodate the title bar.
   */
  private function constrainFrameRect(rect:NSRect):NSRect {
    //
    // Min max constraint
    //
    if (rect.size.width < m_minFrameSize.width) {
      rect.size.width = m_minFrameSize.width;
    }
    if (rect.size.height < m_minFrameSize.height) {
      rect.size.height = m_minFrameSize.height;
    }
    if (rect.size.width > m_maxFrameSize.width) {
      rect.size.width = m_maxFrameSize.width;
    }
    if (rect.size.height > m_maxFrameSize.height) {
      rect.size.height = m_maxFrameSize.height;
    }
    
    if (m_styleMask & NSTitledWindowMask) {
      //
      // Titlebar constraint
      //
      if (rect.size.width < 100) {
        rect.size.width = 100;
      }
    
      var titleHeight:Number = this.rootView().titleRect().size.height;
      if (rect.size.height < titleHeight + 2) {
        rect.size.height = titleHeight + 2;
      }
    }
    
    return rect;
  }
  
  /**
   * Cancels a smoothe resize animation.
   */
  private function cancelAnimation():Void {
  	if (!m_isAnimating) {
  	  return;
  	}
  	m_isAnimating = false;
  	
    m_xAnimator.release();
    m_yAnimator.release();
    m_wAnimator.release();
    m_hAnimator.release();
    
    m_xAnimator = null;
    m_yAnimator = null;
    m_wAnimator = null;
    m_hAnimator = null;
    
    m_displayViewsAfterAnimate = false;
  }
  
  //******************************************************
  //*             Constraining window size
  //******************************************************

  /**
   * Returns the maximum size to which this window's frame can be sized.
   */
  public function maxSize():NSSize {
    return m_maxFrameSize;
  }

  /**
   * Returns the minimum size to which this window's frame can be sized.
   */
  public function minSize():NSSize {
    return m_minFrameSize;
  }

  /**
   * Sets the maximum size to which this window's frame can be sized to
   * <code>size</code>.
   */
  public function setMaxSize(size:NSSize):Void {
    if (size.width > 10000) {
      size.width = 10000;
    }
    if (size.height > 10000) {
      size.height = 10000;
    }
    m_maxFrameSize = size;
  }

  /**
   * Sets the minimum size to which this window's frame can be sized to
   * <code>size</code>.
   */
  public function setMinSize(size:NSSize):Void {
    if (size.width < 1) {
      size.width = 1;
    }
    if (size.height < 1) {
      size.height = 1;
    }
    m_minFrameSize = size;
  }

  /**
   * This is a helper method. It uses {@link #setMinSize}.
   */
  public function setMinWidth(width:Number):Void {
    setMinSize(new NSSize(width, m_minFrameSize.height));
  }

  /**
   * This is a helper method. It uses {@link #setMaxSize}.
   */
  public function setMaxWidth(width:Number):Void {
    setMaxSize(new NSSize(width, m_maxFrameSize.height));
  }

  /**
   * This is a helper method. It uses {@link #setMinSize}.
   */
  public function setMinHeight(height:Number):Void {
    setMinSize(new NSSize(m_minFrameSize.width, height));
  }

  /**
   * This is a helper method. It uses {@link #setMaxSize}.
   */
  public function setMaxHeight(height:Number):Void {
    setMaxSize(new NSSize(m_maxFrameSize.width, height));
  }

  // TODO setAspectRatio:
  // TODO aspectRatio
  // TODO resizeIncrements
  // TODO setResizeIncrements:
  // TODO constrainFrameRect:toScreen:


  
  //******************************************************
  //*              Managing content size
  //******************************************************

  // TODO setContentAspectRatio:
  // TODO contentAspectRatio
  // TODO setContentResizeIncrements:
  // TODO contentResizeIncrements
  // TODO setContentMaxSize:
  // TODO contentMaxSize
  // TODO setContentMinSize:
  // TODO contentMinSize

  // TODO Entire "Saving the frame to user defaults" section

  //******************************************************
  //*               Ordering Windows
  //******************************************************

  public function orderBack(sender:Object):Void {
    m_rootView.extractView();
    m_rootView.lowestViewOfLevel().setLowerView(m_rootView);
    m_rootView.matchDepth();
  }

  public function orderFront(sender:Object):Void {
    m_rootView.extractView();
    m_rootView.setLowerView(m_rootView.highestViewOfLevel());
    m_rootView.matchDepth();
  }

  public function orderFrontRegardless(sender:Object):Void {
    orderFront();
  }

  public function orderOut(sender:Object):Void {
    //! How to handle this?
  }

  public function orderWindowRelativeTo(positioned:NSWindowOrderingMode,
      windowNumber:Number):Void {
    var windowRoot:ASRootWindowView = g_instances[windowNumber].rootView();
    switch(positioned) {
    case NSWindowOrderingMode.NSWindowAbove:
      m_rootView.extractView();
      m_rootView.setLowerView(windowRoot);
      m_rootView.matchDepth();
      break;
    case NSWindowOrderingMode.NSWindowBelow:
      m_rootView.extractView();
      windowRoot.setLowerView(m_rootView);
      m_rootView.matchDepth();
      break;
    case NSWindowOrderingMode.NSWindowOut:
      //! How to handle this?
      break;
    }
  }

  public function setLevel(newLevel:Number):Void {
    m_level = newLevel;
    orderFront();
  }

  public function level():Number {
    return m_level;
  }

  public function isVisible():Boolean {
    return m_isVisible;
  }

  //******************************************************
  //*                Attached windows
  //******************************************************

  /**
   * <p><code>childWin</code> is ordered either above (
   * {@link NSWindowOrderingMode#NSWindowAbove}) or below
   * ({@link NSWindowOrderingMode#NSWindowBelow}) the receiver, and maintained
   * in that relative place for subsequent ordering operations involving either
   * window.</p>
   *
   * <p>While this attachment is active, moving <code>childWin</code> will not
   * cause the receiver to move (as in sliding a drawer in or out), but moving
   * the receiver will cause <code>childWin</code> to move.</p>
   *
   * <p>Note that you should not create cycles between parent and child windows.
   * For example, you should not add window B as child of window A, then add
   * window A as a child of window B.</p>
   *
   * @see #removeChildWindow()
   * @see #childWindows()
   * @see #parentWindow()
   * @see #setParentWindow()
   */
  public function addChildWindowOrdered(childWin:NSWindow,
      place:NSWindowOrderingMode):Void {
    if (!m_childWindows.containsObject(childWin)) {
      m_childWindows.addObject(childWin);
    }

    childWin.setParentWindow(this);
    // FIXME childWin.orderWindowRelativeTo(place, windowNumber());
    // FIXME account for depth changes
  }

  /**
   * Detaches <code>childWin</code> from the receiver.
   *
   * @see #addChildWindowOrdered()
   * @see #childWindows()
   * @see #parentWindow()
   * @see #setParentWindow()
   */
  public function removeChildWindow(childWin:NSWindow):Void {
    if (childWin.parentWindow() != this) {
      return;
    }

    m_childWindows.removeObject(childWin);
    childWin.setParentWindow(null);
  }

  /**
   * Returns an array of the receiver’s attached child windows.
   *
   * @see #addChildWindowOrdered()
   * @see #removeChildWindow()
   * @see #parentWindow()
   * @see #setParentWindow()
   */
  public function childWindows():NSArray {
    return (new NSArray()).initWithArrayCopyItems(m_childWindows, false);
  }

  /**
   * Returns the parent window to which the receiver is attached as a child.
   *
   * @see #addChildWindowOrdered()
   * @see #removeChildWindow()
   * @see #childWindows()
   * @see #setParentWindow()
   */
  public function parentWindow():NSWindow {
    return m_parentWindow;
  }

  /**
   * For use by subclasses when setting the parent window in the receiver.
   *
   * @see #addChildWindowOrdered()
   * @see #removeChildWindow()
   * @see #childWindows()
   * @see #parentWindow()
   */
  public function setParentWindow(window:NSWindow):Void {
    // TODO consider removing from old parent, LOOP WARNING
    m_parentWindow = window;
  }

  //******************************************************
  //*            Making key and main windows
  //******************************************************

  public function becomeKeyWindow():Void {
    if (!m_isKey) {
      m_isKey = true;
      m_rootView.setNeedsDisplay(true);
      if (m_firstResponder == null || m_firstResponder == this) {
        if (m_initialFirstResponder != null) {
          makeFirstResponder(m_initialFirstResponder);
        }
      }
      m_firstResponder.becomeFirstResponder();
      if (m_firstResponder != this) {
        Object(m_firstResponder).becomeKeyWindow();
      }
      m_notificationCenter.postNotificationWithNameObject(NSWindowDidBecomeKeyNotification, this);
    }
  }

  public function canBecomeKeyWindow():Boolean {
    return true;
  }

  public function isKeyWindow():Boolean {
    return m_isKey;
  }

  public function makeKeyAndOrderFront():Void {
    makeKeyWindow();
    orderFront(this);
  }

  public function makeKeyWindow():Void {
    if (!m_isKey && m_isVisible && canBecomeKeyWindow()) {
      m_app.keyWindow().resignKeyWindow();
      becomeKeyWindow();
    }
  }

  public function resignKeyWindow():Void {
    if (m_isKey) {
      if (m_firstResponder != this) {
        Object(m_firstResponder).resignKeyWindow();
      }
      m_isKey = false;
      m_rootView.setNeedsDisplay(true);
      m_notificationCenter.postNotificationWithNameObject(NSWindowDidResignKeyNotification, this);
    }
  }

  /**
   * <p>Informs this window that it has become the main window.</p>
   *
   * <p>This method should never be called directly.</p>
   *
   * <p>This method posts a {@link #NSWindowDidBecomeMainNotification} to the
   * notification center.</p>
   *
   * @see #makeMainWindow
   * @see #isMainWindow
   */
  public function becomeMainWindow():Void {
    if (!isMainWindow()) {
      m_isMain = true;
      m_notificationCenter.postNotificationWithNameObject(NSWindowDidBecomeMainNotification, this);
    }
  }

  public function canBecomeMainWindow():Boolean {
    return m_isVisible;
  }

  /**
   * Returns <code>true</code> if this window is the application's main window,
   * or <code>false</code> otherwise.
   */
  public function isMainWindow():Boolean {
    return m_isMain;
  }

  /**
   * Makes this window the main window. The main window is the standard window
   * where the user is currently working. The main window is not always the key
   * window.
   *
   * @see #becomeMainWindow
   * @see #isMainWindow
   */
  public function makeMainWindow():Void {
    if (m_isVisible && !m_isMain && canBecomeMainWindow()) {
//      trace(ASUtils.findMatch([NSWindow, org.actionstep.NSMenu, org.actionstep.test.ASTestMenu, NSApplication], arguments.caller, "prototype"));
      m_app.mainWindow().resignMainWindow();
      becomeMainWindow();
    }
  }

  public function resignMainWindow():Void {
    if (m_isMain) {
      m_isMain = false;
      m_notificationCenter.postNotificationWithNameObject(NSWindowDidResignMainNotification, this);
    }
  }

  public function setMakeMainAndKey(f:Boolean):Void {
  	m_makeMainAndKey = f;
  }

  public function makeMainAndKey():Boolean {
  	return m_makeMainAndKey;
  }

  public function hide():Void {
    if (m_isVisible && m_canHide) {
      m_isVisible = false;
      m_rootView.setHidden(true);
    }
  }

  public function show():Void {
    if (!m_isVisible) {
      m_isVisible = true;
      m_rootView.setHidden(false);
    }
  }

  //******************************************************
  //*               Default push button
  //******************************************************

  /**
   * Returns the button cell that will act as if it is clicked when the window
   * recieves an Enter keyDown event.
   *
   * @see #setDefaultButtonCell
   */
  public function defaultButtonCell():NSButtonCell {
    return m_defButtonCell;
  }

  /**
   * Sets the button cell that will act as if it is clicked when the window
   * recieves an Enter keyDown event.
   *
   * TODO The button should have some visual indication that it is the
   * default push button.
   */
  public function setDefaultButtonCell(cell:NSButtonCell):Void {
  	m_defButtonCell = cell;
  }

  /**
   * Enables the default button cell's key equivalent. That is, when Enter is
   * pressed, the button cell's click will be performed.
   *
   * @see #disableKeyEquivalentForDefaultButtonCell
   */
  public function enableKeyEquivalentForDefaultButtonCell():Void {
    m_keyEquivForDefButton = true;
  }

  /**
   * Disables the default button cell's key equivalent.
   *
   * @see #enableKeyEquivalentForDefaultButtonCell
   */
  public function disableKeyEquivalentForDefaultButtonCell():Void {
    m_keyEquivForDefButton = false;
  }

  //******************************************************
  //*              Display and drawing
  //******************************************************

  /**
   * <p>Passes a display message down the receiver’s view hierarchy, thus
   * redrawing all NSViews within the receiver, including the frame view that
   * draws the border, title bar, and other peripheral elements.</p>
   *
   * <p>You rarely need to invoke this method. NSWindows normally record which
   * of their NSViews need display and display them automatically on each
   * pass through the event loop.</p>
   *
   * @see #displayIfNeeded()
   * @see NSView#display()
   */
  public function display():Void {
    m_viewsNeedDisplay = false;
    
    try {
      m_rootView.display();
    } catch (e:Error) {
      trace(e.toString());
    }
  }

  /**
   * <p>Passes a displayIfNeeded message down the receiver’s view hierarchy,
   * thus redrawing all NSViews that need to be displayed, including the frame
   * view that draws the border, title bar, and other peripheral elements.</p>
   *
   * <p>This method is useful when you want to modify some number of NSViews
   * and then display only the ones that were modified.</p>
   *
   * <p>You rarely need to invoke this method. NSWindows normally record which
   * of their NSViews need display and display them automatically on each pass
   * through the event loop.</p>
   *
   * @see #display()
   * @see NSView#displayIfNeeded()
   * @see NSView#setNeedsDisplay()
   */
  public function displayIfNeeded():Void {
    if (m_viewsNeedDisplay) {
      m_viewsNeedDisplay = false;
      try {
        m_rootView.displayIfNeeded();
      } catch (e:Error) {
        trace(e.toString());
      }
    }
  }

  public function setViewsNeedDisplay(value:Boolean):Void {
    m_viewsNeedDisplay = value;
  }

  public function viewsNeedDisplay():Boolean {
    return m_viewsNeedDisplay;
  }

  // TODO update

  /**
   * <p>Posts a {@link #NSWindowDidDisplayNotification} to the default notification
   * center.</p>
   *
   * <p>This method is ActionStep-specific.</p>
   */
  public function windowDidDisplay():Void {
    m_notificationCenter.postNotificationWithNameObject(NSWindowDidDisplayNotification, this);
  }

  //******************************************************
  //*          Working with the responder chain
  //******************************************************

  public function firstResponder():NSResponder {
    return m_firstResponder;
  }

  /**
   * <p>
   * Attempts to make <code>aResponder</code> the first responder for the 
   * receiver.
   * </p>
   * <p>
   * If <code>aResponder</code> isn’t already the first responder, this method 
   * first sends a <code>NSResponder#resignFirstResponder()</code> message to 
   * the object that is. If that object refuses to resign, it remains the first 
   * responder, and this method immediately returns <code>false</code>. If it 
   * returns <code>true</code>, this method sends an 
   * <code>NSResponder#becomeFirstResponder()</code> message to 
   * <code>aResponder</code>. If <code>aResponder</code> accepts first responder
   * status, this method returns <code>true</code>. If it refuses, this method 
   * returns <code>false</code>, and the NSWindow object becomes first 
   * responder.
   * </p>
   * <p>
   * If <code>aResponder</code> is <code>null</code>, this method still sends 
   * <code>NSResponder#resignFirstResponder()</code> to the current first 
   * responder. If the current first responder refuses to resign, it remains the
   * first responder and this method immediately returns <code>false</code>. If 
   * the current first responder returns <code>true</code>, the receiver is made
   * its own first responder and this method returns <code>true</code>.
   * </p>
   * <p>
   * Use <code>#setInitialFirstResponder()</code> to the set the first responder
   * to be used when the window is brought onscreen for the first time.
   * </p>
   */
  public function makeFirstResponder(aResponder:NSResponder):Boolean {
    if(m_app.isRunningModal() && m_app.modalWindow()!=this) {
      return false;
    }
    if (m_firstResponder == aResponder) {
      return true;
    }
    if ((!(aResponder instanceof NSResponder) || !aResponder.acceptsFirstResponder()) && aResponder != null) {
      return false;
    }
    if (m_firstResponder != null && !m_firstResponder.resignFirstResponder()) {
      return false;
    }
    m_firstResponder = aResponder;
    if (m_firstResponder == null || !m_firstResponder.becomeFirstResponder()) {
      m_firstResponder = this;
      m_firstResponder.becomeFirstResponder();
      return aResponder == null;
    }
    return true;
  }

  public function acceptsFirstResponder():Boolean {
    return true;
  }

  //******************************************************
  //*                 Event handling
  //******************************************************

  /**
   * Returns <code>true</code> if this window accepts and redistributes mouseMoved
   * events among its responders.
   *
   * By default, this is set to <code>false</code>.
   */
  public function acceptsMouseMovedEvents():Boolean {
    return m_acceptsMouseMoved;
  }

  /**
   * Sets whether this window accepts and redistributes mouseMoved events among
   * its responders. If <code>flag</code> is <code>true</code>, then it does.
   *
   * By default, this is set to <code>false</code>.
   */
  public function setAcceptsMouseMovedEvents(flag:Boolean):Void {
    m_acceptsMouseMoved = flag;
  }

  public function currentEvent():NSEvent {
    return m_app.currentEvent();
  }

  public function postEventAtStart(event:NSEvent, atStart:Boolean):Void {
    m_app.postEventAtStart(event, atStart);
  }

  public function sendEvent(event:NSEvent):Void {
  	__sendEventBecomesKeyOnlyIfNeeded(event, false);
  }

  public function performKeyEquivalent(event:NSEvent):Boolean {
    return m_rootView.performKeyEquivalent(event);
  }

  private function __sendEventBecomesKeyOnlyIfNeeded(event:NSEvent,
      becomesKeyOnlyIfNeeded:Boolean):Void {
    var wasKey:Boolean = m_isKey;
    switch(event.type) {
    case NSEvent.NSLeftMouseDown:
      if (!wasKey && m_level != NSDesktopWindowLevel) {
        if (!becomesKeyOnlyIfNeeded || event.view.needsPanelToBecomeKey()) {
          makeKeyAndOrderFront();
          if(makeMainAndKey) {
          	makeMainWindow();
          }
        }
      }
//      if (m_firstResponder != event.view) {
//        makeFirstResponder(event.view);
//      }
      if (null != m_lastEventView) {
        m_lastEventView = null;
      }

      if (wasKey || event.view.acceptsFirstMouse(event)) {
        m_lastEventView = event.view;
        event.view.mouseDown(event);
      }
      m_lastPoint = event.locationInWindow.clone();
      break;
    case NSEvent.NSLeftMouseUp:
      //
      // If we're dragging, let's do our thing.
      //
      if (g_isDragging) {
		//
		// Update the dest window
		//
		if (g_currentDragInfo.draggingDestinationWindow() != this) {
			g_currentDragInfo.setDraggingDestinationWindow(this);
		}

		//
		// Get destination
		//
        var dest:NSDraggingDestination = NSDraggingDestination(event.view);
        var dragOp:NSDragOperation;
        
        //
        // Check if dragging is accepted by this destination, and that
        // the operation is allowed.
        //
        if (g_currentDragInfo.doesViewHandleTypes(event.view)
            && null != (dragOp = dest.draggingUpdated(g_currentDragInfo))
            && g_currentDragInfo.draggingSourceOperationMask()
            & dest.draggingUpdated(g_currentDragInfo).valueOf()
            != NSDragOperation.NSDragOperationNone.valueOf()) {
          if (dest.prepareForDragOperation(g_currentDragInfo)) {
            if (dest.performDragOperation(g_currentDragInfo)) {
              dest.concludeDragOperation(g_currentDragInfo);
              g_currentDragInfo.draggingSource().draggedImageEndedAtOperation(
                g_currentDragInfo.draggedImage(), event.mouseLocation, 
                dragOp);
            } else {
              g_currentDragInfo.draggingSource().draggedImageEndedAtOperation(
                g_currentDragInfo.draggedImage(), event.mouseLocation, 
                NSDragOperation.NSDragOperationNone);
            }
          } else {
            g_currentDragInfo.draggingSource().draggedImageEndedAtOperation(
              g_currentDragInfo.draggedImage(), event.mouseLocation, 
              NSDragOperation.NSDragOperationNone);
          }

          NSApplication.sharedApplication().draggingClip().clear();
        } else {
          //
          // End the sequence, slide back if necessary.
          //
          if (g_currentDragInfo.slideBack()) {
            g_currentDragInfo.slideDraggedImageTo(g_dragStartPt);
          } else {
            NSApplication.sharedApplication().draggingClip().clear();
          }
          
          g_currentDragInfo.draggingSource().draggedImageEndedAtOperation(
            g_currentDragInfo.draggedImage(), event.mouseLocation, 
            NSDragOperation.NSDragOperationNone);
        }


        g_isDragging = false;
        g_currentDragInfo = null;
      }

      //
      // Send mouse up to the view that got mouse down
      //
      m_lastEventView.mouseUp(event);
      m_lastPoint = event.locationInWindow.clone();
      break;
    case NSEvent.NSKeyDown:
      //
      // Check for default push button
      //
      var char:Number = event.keyCode;
      if ((char ==  NSNewlineCharacter
          || char == NSEnterCharacter
          || char == NSCarriageReturnCharacter)
          && m_keyEquivForDefButton
          && defaultButtonCell() != null) {
        defaultButtonCell().performClick();
      } else {
        m_firstResponder.keyDown(event);
      }
      break;
    case NSEvent.NSKeyUp:
      m_firstResponder.keyUp(event);
      break;
	case NSEvent.NSScrollWheel:
	  event.view.scrollWheel(event);
	  break;
    case NSEvent.NSMouseMoved:
    case NSEvent.NSLeftMouseDragged:
      //
      // If we're dragging, deal with it.
      //
      if (g_isDragging) {
		//
		// Update the dest window
		//
		if (g_currentDragInfo.draggingDestinationWindow() != this) {
			g_currentDragInfo.setDraggingDestinationWindow(this);
		}

      	//
      	// Inform source of movement.
      	//
        g_currentDragInfo.draggingSource().draggedImageMovedTo(
        	g_currentDragInfo.draggedImage(), event.mouseLocation.clone());

        //
        // Send any draggingEntered, draggingUpdated or draggingExited
        // messages.
        //
        var lastView:NSView = g_lastDragView;

        if (lastView != event.view) {
          if (g_currentDragInfo.doesViewHandleTypes(lastView)) {
            lastView.draggingExited(g_currentDragInfo);
          }
          if (g_currentDragInfo.doesViewHandleTypes(event.view)) {
            event.view.draggingEntered(g_currentDragInfo);
          }
          
          g_lastDragView = event.view;
        } else {
          if (g_currentDragInfo.doesViewHandleTypes(event.view)) {
            event.view.draggingUpdated(g_currentDragInfo);
          }
        }
      }
    case NSEvent.NSRightMouseDragged:
    case NSEvent.NSOtherMouseDragged:
      switch (event.type) {
      case NSEvent.NSLeftMouseDragged:
        m_lastEventView.mouseDragged(event);
        break;
      case NSEvent.NSRightMouseDown:
        m_lastEventView.rightMouseDragged(event);
        break;
      case NSEvent.NSOtherMouseDown:
        m_lastEventView.otherMouseDragged(event);
        break;
      default:
        break;
      }

      //
      // Cycle through all views and determine if any have tracking rects, and
      // if so, send them the appropriate mouseEntered or mouseExited events.
      //
	  checkTrackingAndCursorRects(event.view, event);

	  if (event.view != m_lastView) {
		  checkTrackingForLastView(event);
		  m_lastView = event.view;
	  }

	  m_lastPoint = event.locationInWindow.clone();

      break;

    case NSEvent.NSOtherMouseDown:
      event.view.otherMouseDown(event);
      //! TODO does anything else need to be done here?
      break;

    case NSEvent.NSOtherMouseUp:
      event.view.otherMouseUp(event);
      //! TODO does anything else need to be done here?
      break;
    }

  }

  /**
   * Called by NSApplication.
   */
  public function checkTrackingForLastView(event:NSEvent):Void {
  	checkTrackingAndCursorRects(m_lastView, event);
  }

  /**
   * Dispatches mouseEntered and mouseExited events amoung tracking, tool tip
   * and cursor rectangles.
   */
  private function checkTrackingAndCursorRects(aView:NSView, event:NSEvent):Void {
  	//
  	// Do nothing if there isn't a view.
  	//
    if (null == aView || aView.window() == null) {
      return;
    }

    //
    // Remember the original mouse type
    //
    var origType:Number = event.type;
    var origUserData:Object = event.userData;

  	//
  	// Check tracking rectangles on aView.
  	//
  	if (aView["m_hasTrackingRects"]
  	    || aView["m_hasCursorRects"]
  	    || aView["m_hasToolTips"]
  	    || aView["m_hasCursorAncestors"]
  	    || aView["m_hasTrackingAncestors"]) {
  	  var rects:Array = [];
      var cnt:Number;

      //
      // Check the tracking rects of ancestors if flagged
      //
      if (m_isKey && m_cursorRectsEnabled && aView["m_hasCursorAncestors"]) {
        var ancestors:Array = NSArray(aView["m_cursorAncestors"]).internalList();
        var len:Number = ancestors.length;
        for (var i:Number = 0; i < len; i++) {
          var ancRects:Array = NSArray(ancestors[i]["m_cursorRects"]).internalList();

          var len2:Number = ancRects.length;
          for (var j:Number = 0; j < len2; j++) {
            ancRects[j].view = ancestors[i];
          }

          rects = rects.concat(ancRects);
        }
      }

      if (aView["m_hasTrackingAncestors"]) {
        var ancestors:Array = NSArray(aView["m_trackingAncestors"]).internalList();
        var len:Number = ancestors.length;
        for (var i:Number = 0; i < len; i++) {
          var ancRects:Array = NSArray(ancestors[i]["m_trackingRects"]).internalList();

          var len2:Number = ancRects.length;
          for (var j:Number = 0; j < len2; j++) {
            ancRects[j].view = ancestors[i];
          }

          rects = rects.concat(ancRects);
        }
      }
      
      //
      // Check for tracking rects
      //
      if (aView["m_hasTrackingRects"]) {
        var tRects:Array = NSArray(aView["m_trackingRects"]).internalList();
        
        if (aView["m_isTrackingAncestor"]) {
          var len:Number = tRects.length;
          for (var i:Number = 0; i < len; i++) {
            tRects[i].view = aView;
          }
        }
        
        rects = rects.concat(tRects);
      }

      //
      // Check for cursor rects.
      //
      if (m_isKey && m_cursorRectsEnabled && aView["m_hasCursorRects"]) {
      	rects = rects.concat(NSArray(aView["m_cursorRects"]).internalList());
      }

      //
      // Check for tooltips.
      //
      if (aView["m_hasToolTips"]) {
        rects = rects.concat(NSArray(aView["m_toolTipRects"]).internalList());
      }

      cnt = rects.length;

      var isViewDefault:Boolean;
      var isView:Boolean = isViewDefault = aView == event.view;
      var thisPt:NSPoint = m_rootView.convertPointToView(event.locationInWindow,
      	aView);
      var lastPt:NSPoint = m_rootView.convertPointToView(m_lastPoint, aView);

      //
      // Loop through the rects and hitTest against the mouse location.
      //
  	  for (var i:Number = 0; i < cnt; i++) {
  	    var then:Boolean, now:Boolean;
  	    isView = isViewDefault;
  	    var r:Object = rects[i];
  	    var curRect:NSRect = r.rect;
  	    event.userData = r.userData;

  	    //
  	    // Convert to the local coordinate system if required
  	    //
  	    if (r.view != null) {
  	      curRect = aView.convertRectFromView(curRect, NSView(r.view));
  	      isView = true;
  	    }

  	    now = curRect.pointInRect(thisPt);
  	    then = curRect.pointInRect(lastPt);

  	    //
  	    // Determine whether the mouse has entered the rect, exited the rect
  	    // or is just moving within the rect.
  	    //
  	    if (now && !r.hasEntered && isView) {
  	      event.type = NSEvent.NSMouseEntered;

  	      if (ASUtils.respondsToSelector(r.owner, "mouseEntered")) {
            r.owner.mouseEntered(event);
  	      }

          r.hasEntered = true;
  	    }
  	    else if ((then && !now && r.hasEntered) || !isView) {
  	      event.type = NSEvent.NSMouseExited;

  	      if (ASUtils.respondsToSelector(r.owner, "mouseExited")) {
  	        r.owner.mouseExited(event);
  	      }
  	      r.hasEntered = false;
  	    }
  	    else if (now && ASUtils.respondsToSelector(r.owner, "mouseMoved")) {
  	      r.owner.mouseMoved(event);
  	    }
  	  }

  	  //
  	  // Reset event type
  	  //
  	  event.type = origType;
  	}

  	//
  	// Reset event user data
  	//
  	event.userData = origUserData;
  }

  public function keyDown(event:NSEvent):Void {
    if (event.keyCode == NSTabCharacter) {
      if (event.modifierFlags & NSEvent.NSShiftKeyMask) {
        selectPreviousKeyView(this);
      } else {
        selectNextKeyView(this);
      }
      return;
    }
    if (event.keyCode == Key.ESCAPE) {
      if (m_app.modalWindow() == this) {
        m_app.stopModal(); //! Should be abortModal()?
      }
      return;
    }

    var char:Number = event.keyCode;
    if ((char ==  NSNewlineCharacter
      	|| char == NSEnterCharacter
      	|| char == NSCarriageReturnCharacter)
        && m_keyEquivForDefButton
        && defaultButtonCell() != null) {
      defaultButtonCell().performClick();
    }
    //! performKeyEquivalent
  }

  /**
   * Overridden for background movement.
   */
  public function mouseDown(event:NSEvent):Void {
    if (isMovableByWindowBackground()) {
      m_rootView.mouseDown(event);
    } else {
      super.mouseDown(event);
    }
  }

  //******************************************************
  //*           Working with the field editor
  //******************************************************

  // TODO fieldEditor:forObject:
  // TODO endEditingFor:

  //******************************************************
  //*             Keyboard interface control
  //******************************************************

  /**
   * <p>
   * Sets <code>view</code> as the NSView that’s made first responder (also
   * called the key view) the first time the receiver is placed onscreen.
   * </p>
   *
   * @see #initialFirstResponder()
   */
  public function setInitialFirstResponder(view:NSView):Void {
    if (view instanceof NSView) {
      m_initialFirstResponder = view;
    }
  }

  /**
   * <p>
   * Returns the NSView that’s made first responder the first time the receiver
   * is placed onscreen.
   * </p>
   *
   * @see #setInitialFirstResponder()
   * @see NSView#setNextKeyView()
   */
  public function initialFirstResponder():NSView {
    return m_initialFirstResponder;
  }

  /**
   * <p>
   * Sends the NSView message {@link NSView#nextValidKeyView()} to
   * <code>view</code>, and if that message returns an NSView, invokes
   * {@link #makeFirstResponder()} with the returned NSView.
   * </p>
   *
   * @see #selectKeyViewPrecedingView()
   */
  public function selectKeyViewFollowingView(view:NSView):Void {
    var fView:NSView;
    if (view instanceof NSView) {
      fView = view.nextValidKeyView();
      if (fView != null) {
        makeFirstResponder(fView);
        if (fView.respondsToSelector("selectText")) {
          m_selectionDirection = NSSelectionDirection.NSSelectingNext;
          Object(fView).selectText(this);
          m_selectionDirection = NSSelectionDirection.NSDirectSelection;
        }
      }
    }
  }

  /**
   * <p>
   * Sends the NSView message {@link NSView#previousValidKeyView()} to
   * <code>view</code>, and if that message returns an NSView, invokes
   * {@link #makeFirstResponder()} with the returned NSView.
   * </p>
   *
   * @see #selectKeyViewFollowingView()
   */
  public function selectKeyViewPrecedingView(view:NSView):Void {
    var pView:NSView;
    if (view instanceof NSView) {
      pView = view.previousValidKeyView();
      if (pView != null) {
        makeFirstResponder(pView);
        if (pView.respondsToSelector("selectText")) {
          m_selectionDirection = NSSelectionDirection.NSSelectingPrevious;
          Object(pView).selectText(this);
          m_selectionDirection = NSSelectionDirection.NSDirectSelection;
        }
      }
    }
  }

  /**
   * <p>
   * This action method searches for a candidate key view and, if it finds one,
   * invokes {@link #makeFirstResponder()} to establish it as the first
   * responder.
   * </p>
   * <p>
   * The candidate is one of the following (searched for in this order):
   * </p>
   * <ul>
   * <li>
   * The current first responder’s next valid key view, as returned by
   * NSView’s {@link NSView#nextValidKeyView()} method.
   * </li>
   * <li>
   * The object designated as the receiver’s initial first responder (using
   * {@link #setInitialFirstResponder()}) if it returns <code>true</code> to an
   * {@link #acceptsFirstResponder()} message.
   * </li>
   * <li>
   * Otherwise, the initial first responder’s next valid key view, which may end
   * up being <code>null</code>.
   * </li>
   * </ul>
   *
   * @see #selectPreviousKeyView()
   * @see #selectKeyViewFollowingView()
   */
  public function selectNextKeyView(sender:Object):Void {
    var result:NSView = null;
    if (m_firstResponder instanceof NSView) {
      result = NSView(m_firstResponder).nextValidKeyView();
    }
    if (result == null && m_initialFirstResponder != null) {
      if (m_initialFirstResponder.acceptsFirstResponder()) {
        result = m_initialFirstResponder;
      } else {
        result = m_initialFirstResponder.nextValidKeyView();
      }
    }
    if (result != null) {
      makeFirstResponder(result);
      if (result.respondsToSelector("selectText")) {
        m_selectionDirection = NSSelectionDirection.NSSelectingNext;
        Object(result).selectText(this);
        m_selectionDirection = NSSelectionDirection.NSDirectSelection;
      }
    }
  }

  /**
   * <p>
   * This action method searches for a candidate key view and, if it finds one,
   * invokes {@link #makeFirstResponder()} to establish it as the first
   * responder.
   * </p>
   * <p>
   * The candidate is one of the following (searched for in this order):
   * </p>
   * <ul>
   * <li>
   * The current first responder’s previous valid key view, as returned by
   * NSView’s {@link NSView#previousValidKeyView()} method.
   * </li>
   * <li>
   * The object designated as the receiver’s initial first responder (using
   * {@link #setInitialFirstResponder()}) if it returns <code>true</code> to an
   * {@link #acceptsFirstResponder()} message.
   * </li>
   * <li>
   * Otherwise, the initial first responder’s previous valid key view, which may
   * end up being <code>null</code>.
   * </li>
   * </ul>
   *
   * @see #selectNextKeyView()
   * @see #selectKeyViewPrecedingView()
   */
  public function selectPreviousKeyView(sender:Object):Void {
    var result:NSView = null;
    if (m_firstResponder instanceof NSView) {
      result = NSView(m_firstResponder).previousValidKeyView();
    }
    if (result == null && m_initialFirstResponder != null) {
      if (m_initialFirstResponder.acceptsFirstResponder()) {
        result = m_initialFirstResponder;
      } else {
        result = m_initialFirstResponder.previousValidKeyView();
      }
    }
    if (result != null) {
      makeFirstResponder(result);
      if (result.respondsToSelector("selectText")) {
        m_selectionDirection = NSSelectionDirection.NSSelectingPrevious;
        Object(result).selectText(this);
        m_selectionDirection = NSSelectionDirection.NSDirectSelection;
      }
    }
  }

  /**
   * <p>
   * Returns the direction the receiver is currently using to change the key
   * view.
   * </p>
   *
   * @see #selectNextKeyView()
   * @see #selectPreviousKeyView()
   */
  public function keyViewSelectionDirection():NSSelectionDirection {
    return m_selectionDirection;
  }

  //******************************************************
  //*           Setting the title and filename
  //******************************************************

  /**
   * Sets the text in this window's title bar to <code>aString</code>. If the
   * window doesn't have a title bar, this text is not visible.
   */
  public function setTitle(aString:String):Void {
    m_title = aString;
    m_rootView.setNeedsDisplay(true);
    //!display
  }

  /**
   * Returns the text that is shown in this window's title bar.
   */
  public function title():String {
    return m_title;
  }

  //******************************************************
  //*                 Closing the window
  //******************************************************

  /**
   * First posts an <code>NSWindowWillCloseNotification</code> notification
   * to the default notification center, then closes the window.
   *
   * This method does not ask the delegate whether the window should close,
   * nor does it simulate a button press on the close button. If you desire
   * this functionality, use {@link #performClose} instead.
   */
  public function close():Void {
    m_notificationCenter.postNotificationWithNameObject(
    	NSWindowWillCloseNotification, this);
    hide();

    if (isReleasedWhenClosed()) {
      release();
    }
    // m_nsapp.removeWindowsItem(); ???
    // order out ???
  }

  /**
   * Simulates a close as if the window pressed the close button. The close
   * button is momentarily highlighted, then a <code>windowShouldClose</code>
   * message is sent to the delegate. If the delegate returns <code>true</code>
   * then the window is closed using {@link #close()}. If the delegate
   * returns <code>false</code>, then the window remains open.
   */
  public function performClose(sender:Object):Void {
  	//
  	// Beep if there is no close button.
  	//
  	if (!(styleMask() & NSWindow.NSClosableWindowMask)) {
      beep();
      return;
  	}

  	//
  	// Highlight the button.
  	//
  	if (sender != m_rootView.closeButton()) {
  	  m_rootView.closeButton().performClick();
  	  return;
  	}

  	var closeWnd:Boolean = true;
  	if (ASUtils.respondsToSelector(m_delegate, "windowShouldClose")) {
  	  closeWnd = m_delegate.windowShouldClose(this);
  	}

  	if (closeWnd) {
  	  close();
  	} else {
  	  beep();
  	}
  }

  /**
   * <p>Sets whether the receiver is merely hidden (<code>false</code>) or hidden
   * and then released (<code>true</code>) when it receives a close message.</p>
   *
   * <p>The default is <code>true</code>.</p>
   *
   * @see #isReleasedWhenClosed()
   */
  public function setReleasedWhenClosed(flag:Boolean):Void {
  	m_releasedWhenClosed = flag;
  }

  /**
   * Returns <code>true</code> if the receiver is automatically released after
   * being closed, <code>false</code> if it’s simply removed from the screen.
   *
   * @see #setReleasedWhenClosed()
   */
  public function isReleasedWhenClosed():Boolean {
  	return m_releasedWhenClosed;
  }

  //******************************************************
  //*        Miniaturizing and miniaturized windows
  //******************************************************

  /**
   * This method miniaturizes the window so that only the title bar is showing.
   *
   * This differs from the Cocoa implementation.
   */
  public function miniaturize(sender:Object):Void {
    if (m_isMini) {
      return;
    }

    m_notificationCenter.postNotificationWithNameObject(
      NSWindowWillMiniaturizeNotification, this);

    m_preminiSize = contentSize();
    m_preminiStyle = styleMask();
    m_preminiResizeInd = m_rootView.showsResizeIndicator();
    m_styleMask = ASAllButResizable & m_preminiStyle;
    m_rootView.setShowsResizeIndicator(false);
    setContentSize(new NSSize(m_frameRect.size.width, 0));
    m_rootView.setNeedsDisplay(true);
    m_isMini = true;

    //
    // Hide drawers
    //
    var drawers:Array = m_drawers.internalList();
    var len:Number = drawers.length;
    for (var i:Number = 0; i < len; i++) {
      var drawer:NSDrawer = NSDrawer(drawers[i]);
      if (drawer.state() == NSDrawerState.NSDrawerOpenState
          || drawer.state() == NSDrawerState.NSDrawerOpeningState) {
        drawer.drawerWindow().hide();
      }
    }

    var btn:NSButton = m_rootView.miniaturizeButton();
    btn.setImage(NSImage.imageNamed("NSWindowRestoreIconRep"));
    btn.setToolTip("Restore");
    btn.setAction("deminiaturizeWindow");

    m_notificationCenter.postNotificationWithNameObject(
      NSWindowDidMiniaturizeNotification, this);
  }

  /**
   * Simulates a click on the miniaturize button. If this window has no
   * miniaturize button, the system will beep.
   */
  public function performMiniaturize(sender:Object):Void {
  	//
  	// Beep if there is no miniaturize button.
  	//
  	if (!(styleMask() & NSWindow.NSMiniaturizableWindowMask)) {
      beep();
      return;
  	}

  	//
  	// Highlight the button.
  	//
  	if (sender != m_rootView.miniaturizeButton()) {
  	  m_rootView.miniaturizeButton().performClick();
  	  return;
  	}

  	//
  	// Miniaturize the window
  	//
  	miniaturize(this);
  }

  /**
   * This method deminiaturizes this window.
   */
  public function deminiaturize(sender:Object):Void {
    if (!m_isMini) {
      return;
    }

    m_styleMask = m_preminiStyle;
    m_rootView.setShowsResizeIndicator(m_preminiResizeInd);
    setContentSize(m_preminiSize);
    m_rootView.setNeedsDisplay(true);

    m_isMini = false;

    //
    // Show drawers
    //
    var drawers:Array = m_drawers.internalList();
    var len:Number = drawers.length;
    for (var i:Number = 0; i < len; i++) {
      var drawer:NSDrawer = NSDrawer(drawers[i]);
      if (drawer.state() == NSDrawerState.NSDrawerOpenState
          || drawer.state() == NSDrawerState.NSDrawerOpeningState) {
        drawer.drawerWindow().show();
      }
    }

    var btn:NSButton = m_rootView.miniaturizeButton();
    btn.setImage(NSImage.imageNamed("NSWindowMiniaturizeIconRep"));
    btn.setToolTip("Miniaturize");
    btn.setAction("miniaturizeWindow");

    m_notificationCenter.postNotificationWithNameObject(
      NSWindowDidDeminiaturizeNotification, this);
  }

  /**
   * Returns <code>true</code> if the window is miniaturized, or
   * <code>false</code> otherwise.
   */
  public function isMiniaturized():Boolean {
    return m_isMini;
  }

  //******************************************************
  //*             Dealing with cursor rects
  //******************************************************

  /**
   * Enables the ability for views inside this window to have cursor rectangles.
   *
   * @see #disableCursorRects
   */
  public function enableCursorRects():Void {
    m_cursorRectsEnabled = true;
  }

  /**
   * Disables the ability for views inside this window to have cursor rects.
   *
   * @see #enableCursorRects
   */
  public function disableCursorRects():Void {
    m_cursorRectsEnabled = false;
  }

  /**
   * Calls {@code #discardCursorRects}, then calls
   * {@code NSView#resetCursorRects} for every view in the view hierarchy.
   */
  public function resetCursorRects():Void {
    discardCursorRects();
    resetCursorRectsForTree(m_rootView);
  }

  /**
   * Recursive function that will call {@code #invalidateCursorRectsForView} for
   * <code>aView</code> and all of its subviews.
   */
  private function resetCursorRectsForTree(aView:NSView):Void {
  	invalidateCursorRectsForView(aView);

  	var svs:Array = aView.subviews();
  	var cnt:Number = svs.length;

  	for (var i:Number = 0; i < cnt; i++) {
  	  resetCursorRectsForTree(NSView(svs[i]));
  	}
  }

  /**
   * Invalidates all cursor rects in the window.
   *
   * Do not call this method directly. Instead, override it to provide more
   * specific functionality.
   */
  public function discardCursorRects():Void {
    // do nothing
  }

  /**
   * Marks the cursor rectangles of <code>aView</code> invalid, and recalculates
   * them immediately if this window is the key window.
   */
  public function invalidateCursorRectsForView(aView:NSView):Void {
      aView.discardCursorRects();
      aView.resetCursorRects();
  }

  //******************************************************
  //*                  Dragging
  //******************************************************

  /**
   * This method is the same as
   * <code>NSView.dragImageAtOffsetEventPasteboardSourceSlideBack</code> except
   * <code>imageLoc</code> is expressed in the window's base coordinate system,
   * not the view's.
   */
  public function dragImageAtOffsetEventPasteboardSourceSlideBack(
      image:NSImage, imageLoc:NSPoint, offset:NSSize, event:NSEvent,
      pasteboard:NSPasteboard, source:NSDraggingSource, slideBack:Boolean)
      :Void {

    //
    // We can't drag two things at once.
    //
    if (g_isDragging) {
      return;
    }

    //
    // Create the new dragging info.
    //
    var info:NSDraggingInfo;

    g_currentDragInfo = info = NSDraggingInfo.
  	  draggingInfoWithImageAtOffsetPasteboardSourceSlideBack(
  	  	image, imageLoc, offset, pasteboard, source, slideBack);

    g_isDragging = true;
    g_dragStartPt = event.mouseLocation.clone();

    //
    // Inform the source.
    //
    source.draggedImageBeganAt(image, event.mouseLocation.clone());

    //
    // Draw the image on the drag clip
    //
    var dragClip:MovieClip = NSApplication.sharedApplication().draggingClip();
    dragClip.clear();
    image.lockFocus(dragClip);
    image.drawAtPoint(new NSPoint(offset.width, offset.height));
    image.unlockFocus();
  }

  /**
   * Registers <code>pboardTypes</code> as the types this window will accept
   * as the destination of a dragging session.
   *
   * @see #unregisterDraggedTypes
   */
  public function registerForDraggedTypes(pboardTypes:NSArray):Void {
    rootView().registerForDraggedTypes(pboardTypes);
  }

  /**
   * Unregisters this window as a destination for dragging operations.
   *
   * @see #registerDraggedTypes
   */
  public function unregisterDraggedTypes():Void {
    rootView().unregisterDraggedTypes();
  }

  /**
   * Internal method. Registers a view <code>view</code> with a list of types,
   * <code>pboardTypes</code>.
   */
  public function registerViewForDraggedTypes(view:NSView, pboardTypes:NSArray)
      :Void {
    if (null == m_registeredDraggedTypes) {
      m_registeredDraggedTypes = NSDictionary.dictionary();
    }

    m_registeredDraggedTypes.setObjectForKey(pboardTypes, view.viewNum()
    	.toString());
  }

  /**
   * Internal method. Returns types registered to <code>view</code>.
   */
  public function registeredDraggedTypesForView(view:NSView):NSArray {
    return NSArray(m_registeredDraggedTypes.objectForKey(view.viewNum()
    	.toString()));
  }

  /**
   * Unregisters all types registered with <code>view</code>.
   */
  public function unregisterDraggedTypesForView(view:NSView):Void {
  	m_registeredDraggedTypes.removeObjectForKey(view.viewNum().toString());
  }

  //******************************************************
  //*              Controlling behavior
  //******************************************************
 
  /**
   * Returns a Boolean value that indicates whether the receiver is able to 
   * receive keyboard and mouse events even when some other window is being run 
   * modally.
   */
  public function worksWhenModal():Boolean {
    return false;
  }

  public function canHide():Boolean {
    return m_canHide;
  }

  public function setCanHide(value:Boolean):Void {
    m_canHide = value;
  }

  //******************************************************
  //*       Working with display characteristics
  //******************************************************

  /**
   * Returns this window's contentView, which is the top-most accessible view.
   */
  public function contentView():NSView {
    return m_contentView;
  }

  /**
   * Sets this window's contentView, which is the top-most accessible view.
   */
  public function setContentView(view:NSView):Void {
    if (view == null) {
      view = (new NSView()).initWithFrame(NSRect.withOriginSize(
        convertScreenToBase(m_contentRect.origin), m_contentRect.size));
    }
    if (m_contentView != null) {
      m_contentView.removeFromSuperview();
    }
    m_contentView = view;
    m_rootView.setContentView(m_contentView);
    m_contentView.setFrame(NSRect.withOriginSize(convertScreenToBase(
      m_contentRect.origin), m_contentRect.size));
    m_contentView.setNextResponder(this);
  }
  
  /**
   * Sets this window's background color to <code>aColor</code>.
   */
  public function setBackgroundColor(aColor:NSColor):Void {
    m_backgroundColor = aColor;
    m_rootView.setNeedsDisplay(true);
  }

  /**
   * Returns this window's background color.
   */
  public function backgroundColor():NSColor {
    return m_backgroundColor;
  }
  
  /**
   * Returns the receiver’s style mask, indicating what kinds of control items 
   * it displays.
   */
  public function styleMask():Number {
    return m_styleMask;
  }
  
  /**
   * Sets whether the receiver has a shadow to <code>hasShadow</code>.
   */
  public function setHasShadow(hasShadow:Boolean):Void {
    m_rootView.setHasShadow(hasShadow);
  }
  
  /**
   * Returns <code>true</code> if the window has a shadow; otherwise returns 
   * <code>false</code>.
   */
  public function hasShadow():Boolean {
    return m_rootView.hasShadow();
  }
  
  /**
   * Sets the receiver’s alpha value to <code>windowAlpha</code>.
   */
  public function setAlphaValue(windowAlpha:Number):Void {
  	trace(windowAlpha);
    m_rootView.setAlphaValue(windowAlpha * 100);
  }
  
  /**
   * Returns the receiver’s alpha value.
   */
  public function alphaValue():Number {
    return m_rootView.alphaValue() / 100;
  }

  //******************************************************
  //*              Working with icons
  //******************************************************

  /**
   * Sets the icon of the window to <code>anImage</code>. This icon is resized
   * as a square with side lengths of title bar's height.
   *
   * If <code>anImage</code> is <code>null</code>, the window will not use an
   * icon.
   *
   * This method is actionstep only.
   */
  public function setIcon(anImage:NSImage):Void {
    NSNotificationCenter.defaultCenter().removeObserverNameObject(
      this, NSImage.NSImageDidLoadNotification, icon());
    m_icon = anImage;
    NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
      this, "iconDidLoad", NSImage.NSImageDidLoadNotification, anImage);
  }

  /**
   * Returns the icon used for this window, or <code>null</code> if none exists.
   *
   * This method is actionstep only.
   */
  public function icon():NSImage {
    return m_icon;
  }

  /**
   * Fired when this image view's image loads.
   */
  private function iconDidLoad(ntf:NSNotification):Void {
    rootView().setNeedsDisplay(true);
  }

  //******************************************************
  //*                Undo manager
  //******************************************************

  /**
   * <p>Returns the undo manager for this responder.</p>
   *
   * <p><code>NSResponder</code>’s implementation simply passes this message to
   * the next responder.</p>
   */
  public function undoManager():NSUndoManager {
    if (m_delegate != null && ASUtils.respondsToSelector(m_delegate,
        "windowWillReturnUndoManager")) {
      return NSUndoManager(m_delegate["windowWillReturnUndoManager"](this));
    }

    if (m_undoManager == null) {
      m_undoManager = (new NSUndoManager()).init();
    }

    return m_undoManager;
  }

  //******************************************************
  //*              Sets the window view class
  //******************************************************

  /**
   * Returns the view class used to draw this window.
   */
  public function viewClass():Function {
    if (m_viewClass == undefined) {
      m_viewClass = ASRootWindowView;
    }
    return m_viewClass;
  }

  /**
   * Disposes this window.
   */
  public function release():Boolean {
  	super.release();

    m_rootView.removeFromSuperview();
    m_rootView.release();
    m_drawers.makeObjectsPerformSelectorWithObject("setParentWindow", null);
    m_drawers.removeAllObjects();
    m_childWindows.makeObjectsPerformSelectorWithObject("setParentWindow", null);
    m_childWindows.removeAllObjects();

    delete m_rootView;
    delete m_drawers;
    delete m_childWindows;

    resignKeyWindow();
    resignMainWindow();
    g_instances[m_windowNumber] = null;
    return true;
  }

  public function mouseLocationOutsideOfEventStream():NSPoint {
    return null;
  }

  //******************************************************
  //*                   Field editor
  //******************************************************

/*
  public function fieldEditorCreateFlagForObject(createFlag:Boolean, object):NSText {
    //! should delegate
    if (m_fieldEditor == null && createFlag) {
      m_fieldEditor = new NSTextView();
      m_fieldEditor.setFieldEditor(true);
    }
    return m_fieldEditor;
  }

  public function endEditingForAnObject(object) {
    var editor:NSText = fieldEditorCreateFlagForObject(false, object);
    if (editor != null  && (editor == m_firstResponder)) {
      m_notificationCenter.postNotificationWithNameObject(NSTextView.NSTextDidEndEditingNotification, editor);
      editor.setString("");
      editor.setDelegate(null);
      editor.removeFromSuperview();
      m_firstResponder = this;
      m_firstResponder.becomeFirstResponder();
    }
  }
*/
  //******************************************************
  //*               Setting the delegate
  //******************************************************

  public function delegate():Object {
    return m_delegate;
  }

  public function setDelegate(value:Object):Void {
    if(m_delegate != null) {
      m_notificationCenter.removeObserverNameObject(m_delegate, null, this);
    }
    m_delegate = value;
    if (value == null) {
      return;
    }

    mapDelegateNotification("DidBecomeKey");
    mapDelegateNotification("DidBecomeMain");
    mapDelegateNotification("DidResignKey");
    mapDelegateNotification("DidResignMain");
    mapDelegateNotification("WillMove");
    mapDelegateNotification("DidResize");
    mapDelegateNotification("WillClose");
    mapDelegateNotification("WillMiniaturize");
    mapDelegateNotification("DidMinitiaturize");
    mapDelegateNotification("DidDeminiaturize");
    mapDelegateNotification("DidDisplay");
  }

  private function mapDelegateNotification(name:String):Void {
    if(typeof(m_delegate["window"+name]) == "function") {
      m_notificationCenter.addObserverSelectorNameObject(m_delegate, "window"+name, ASUtils.intern("NSWindow"+name+"Notification"), this);
    }
  }

  //******************************************************
  //*         Getting associated information
  //******************************************************

  /**
   * Returns the collection of drawers associated with the receiver.
   */
  public function drawers():NSArray {
    return (new NSArray()).initWithArrayCopyItems(m_drawers, false);
  }

  /**
   * For internal use only.
   */
  public function addDrawer(drawer:NSDrawer):Void {
    if (m_drawers.containsObject(drawer)) {
      return;
    }

    // FIXME not sure if I should be using the child window array...
    m_drawers.addObject(drawer);
    addChildWindowOrdered(drawer.drawerWindow(), NSWindowOrderingMode.NSWindowBelow);
  }

  /**
   * For internal use only.
   */
  public function removeDrawer(drawer:NSDrawer):Void {
    if (!m_drawers.containsObject(drawer)) {
      return;
    }

    // FIXME not sure if I should be using the child window array...
    m_drawers.removeObject(drawer);
    removeChildWindow(drawer.drawerWindow());
  }

  // TODO setWindowController:
  // TODO windowController

  //******************************************************
  //*               Working with sheets
  //******************************************************

  /**
   * Returns <code>true</code> if the receiver has ever run as a modal sheet.
   * Sheets are created using the <code>NSPanel</code> subclass.
   */
  public function isSheet():Boolean {
    return false;
  }

  // TODO attachedSheet()

  //******************************************************
  //*              Working with toolbars
  //******************************************************

  /**
   * <p>Returns the receiver’s toolbar.</p>
   *
   * @see #setToolbar()
   */
  public function toolbar():NSToolbar {
    return m_toolbar;
  }

  /**
   * <p>Sets the receiver’s toolbar to <code>toolbar</code>.</p>
   *
   * @see #toolbar()
   */
  public function setToolbar(toolbar:NSToolbar):Void {
    if (m_toolbar != null) {
      m_toolbar.__setWindow(null);
    }

    m_toolbar = toolbar;
    m_toolbar.__setWindow(this);
    
    __adjustForToolbar();
  }

  /**
   * Toggles the visibility of this window's toolbar, if one exists.
   */
  public function toggleToolbarShown(sender:Object):Void {
    if (m_toolbar == null) {
      return;
    }

    m_toolbar.setVisible(!m_toolbar.isVisible());
  }
  
  /**
   * <p>
   * Called to adjust the window to accommodate the toolbar (or lack therof).
   * </p>
   * <p>
   * For internal use only.
   * </p> 
   */
  public function __adjustForToolbar():Void {
  	var frm:NSRect = frameRectForContentRect();
  	setFrameWithNotifications(frm, false);
  	m_rootView.setNeedsDisplay(true);
  }
  
  //******************************************************
  //*            Getting all window instances
  //******************************************************

  /**
   * <p>
   * Returns all window instances. This method is intended for internal use
   * only.
   * </p>
   */  
  public static function instances():Array {
    return g_instances;
  }
}
