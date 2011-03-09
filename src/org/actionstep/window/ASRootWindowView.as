/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.constants.NSLineBreakMode;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSColor;
import org.actionstep.NSCursor;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSFont;
import org.actionstep.NSImage;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSTextFieldCell;
import org.actionstep.NSToolbar;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeProtocol;

import flash.filters.DropShadowFilter;
import org.actionstep.graphics.ASGradient;
import org.actionstep.graphics.ASGraphics;

class org.actionstep.window.ASRootWindowView extends NSView {

  //******************************************************
  //*                    Constants
  //******************************************************

  private static var WINDOW_CLIP:MovieClip = _root;
  private static var BUTTON_SIDE_LENGTH:Number = 16;
  private static var BUTTON_SPACING:Number = 4;

  //******************************************************
  //*                  Class members
  //******************************************************

  private static var g_lowestView:ASRootWindowView = null;

  //******************************************************
  //*                Member variables
  //******************************************************

  private var m_contentView:NSView;
  private var m_swfLoading:Boolean;
  private var m_swfLoaded:Boolean;
  private var m_window:NSWindow;
  private var m_titleRect:NSRect;
  private var m_resizeRect:NSRect;
  private var m_trackingData:Object;

  private var m_lowerView:ASRootWindowView;
  private var m_higherView:ASRootWindowView;
  private var m_targetDepth:Number;

  private var m_titleCell:NSTextFieldCell;
  private var m_titleToolTipTag:Number;
  private var m_titleFont:NSFont;
  private var m_titleKeyFontColor:NSColor;
  private var m_titleFontColor:NSColor;

  private var m_childTree:NSView;
  private var m_isResizing:Boolean;
  private var m_resizeClip:MovieClip;
  private var m_showsResizeIndicator:Boolean;
  private var m_hasShadow:Boolean;

  private var m_closeBtn:NSButton;
  private var m_miniBtn:NSButton;

  private var m_toolbarView:NSView;
  
  private var m_alpha:Number;

  //
  // For Flash 8
  //
  private var m_mcBase:MovieClip;
  private var m_shadowFilter:DropShadowFilter;

  //******************************************************
  //*                   Construction
  //******************************************************

  public function ASRootWindowView() {
    m_hasShadow = false;
    m_swfLoading = false;
    m_swfLoaded = false;
    m_showsResizeIndicator = true;
    m_resizeRect = new NSRect(-11,-11,11,11);
    m_isResizing = false;
    m_alpha = 100;

    //
    // Create title cell
    //
  	m_titleCell = new NSTextFieldCell();
  	m_titleCell.initTextCell("");
  	m_titleCell.setDrawsBackground(false);
  	m_titleCell.setSelectable(false);
  	m_titleCell.setEditable(false);
  	m_titleCell.setLineBreakMode(NSLineBreakMode.NSLineBreakByTruncatingTail);

    //
    // Create buttons
    //
    m_closeBtn = new NSButton();
  	m_closeBtn.initWithFrame(new NSRect(0, 0, BUTTON_SIDE_LENGTH, BUTTON_SIDE_LENGTH));
  	m_closeBtn.setImage(NSImage.imageNamed("NSWindowCloseIconRep"));
  	m_closeBtn.setToolTip("Close");
  	m_closeBtn.setImagePosition(NSCellImagePosition.NSImageOnly);
  	m_closeBtn.setAutoresizingMask(NSView.MinXMargin);
  	m_closeBtn.setTarget(this);
  	m_closeBtn.setAction("closeWindow");

    m_miniBtn = new NSButton();
  	m_miniBtn.initWithFrame(new NSRect(0, 0, BUTTON_SIDE_LENGTH, BUTTON_SIDE_LENGTH));
  	m_miniBtn.setImage(NSImage.imageNamed("NSWindowMiniaturizeIconRep"));
  	m_miniBtn.setToolTip("Miniaturize");
  	m_miniBtn.setImagePosition(NSCellImagePosition.NSImageOnly);
  	m_miniBtn.setAutoresizingMask(NSView.MinXMargin);
  	m_miniBtn.setTarget(this);
  	m_miniBtn.setAction("miniaturizeWindow");

  	//
  	// Create toolbar view
  	//
    m_toolbarView = (new NSView()).init();
  }

  public function initWithFrameWindow(frame:NSRect, window:NSWindow):ASRootWindowView {
    initWithFrame(frame);

    var theme:ASThemeProtocol = ASTheme.current();
    m_titleRect = new NSRect(0,0,0, theme.windowTitleBarHeight());
    m_titleKeyFontColor = theme.systemFontColor();
    m_titleFontColor = new NSColor(0x666666);
    m_titleFont = theme.titleBarFontOfSize(12); // TODO add 12 to theme
    m_titleCell.setTextColor(m_titleKeyFontColor);

    viewWillMoveToWindow(window);
    viewDidMoveToWindow();

    setLowerView(highestViewOfLevel());
    return this;
  }

  //******************************************************
  //*         Releasing the object from memory
  //******************************************************

  public function release():Boolean {
  	super.release();
//  	super.removeFromSuperview();
//  	m_window = null;
    return true;
  }

  //******************************************************
  //*                MovieClip methods
  //******************************************************

  public function mcBase():MovieClip {
  	if (m_mcBase == undefined) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        "NSException",
        "Cannot access base movieclip until NSView is inserted into view hierarchy.",
        null);
      trace(e);
      throw e;
    }
    return m_mcBase;
  }

  public function createMovieClips():Boolean {
    if (m_mcFrame != null)
    {
       //return if already created
       return true;
    }
    
    if (!super.createMovieClips()) {
    	return false;
    }

    if (m_mcBounds != null) {
      if (m_window.styleMask() & NSWindow.NSResizableWindowMask) {

        m_resizeClip = m_mcBounds.createEmptyMovieClip("ResizeClip", 1000000);
        drawResizeClip();
        m_resizeClip.view = this;
        m_resizeClip._x = m_frame.size.width-12;
        m_resizeClip._y = m_frame.size.height-12;
        m_resizeRect.origin.x = m_resizeClip._x;
        m_resizeRect.origin.y = m_resizeClip._y;
      }
    } else {
    	return false;
    }

    return true;
  }
  
  private function createFrameMovieClip():MovieClip {
    var self:ASRootWindowView = this;
    var depth:Number = m_targetDepth;
    if (WINDOW_CLIP.getInstanceAtDepth(depth) != null) {
      depth = m_window.windowNumber()+100;
    }
    //interim fix
    m_mcBase  = WINDOW_CLIP.createEmptyMovieClip("ASRootWindowView"+m_window.windowNumber(), WINDOW_CLIP.getNextHighestDepth());
        
    m_mcBase.view = this;
    WINDOW_CLIP["ASRootWindowView"+m_window.windowNumber()].window = m_window;
    m_mcFrame = m_mcBase.createEmptyMovieClip("MCFRAME", 1);
    m_mcFrame.window = m_window;
    m_mcFrame.view = this;
    matchDepth();

    //
    // This is what actually causes views to update if they are marked as
    // needing it.
    //
    m_mcFrame.onEnterFrame = function() {
      self.window().displayIfNeeded();
    };
    return m_mcFrame;
  }
  
  private function initializeBoundsMovieClip():Void {
    if (m_window.swf() != null) {
      if(m_swfLoading) {
        return;
      } else {
        m_swfLoading = true;
        loadSwf();
        return;
      }
    }
    super.initializeBoundsMovieClip();
  }
  
  private function updateFrameMovieClipSize():Void {
    super.updateFrameMovieClipSize();
    if (m_mcBase != null) {
      m_resizeClip._x = m_frame.size.width-12;
      m_resizeClip._y = m_frame.size.height-12;
      m_resizeRect.origin.x = m_resizeClip._x;
      m_resizeRect.origin.y = m_resizeClip._y;
      //m_titleTextField._x = (m_frame.size.width - (m_titleTextField.textWidth+2))/2;
    }
  }

  private function updateFrameMovieClipPosition():Void {
    if (m_mcBase == null) {
      return;
    }
    m_mcBase._x = m_frame.origin.x;
    m_mcBase._y = m_frame.origin.y;
  }

  private function updateFrameMovieClipPerspective():Void {
    if (m_mcBase == null) {
      return;
    }
    m_mcBase._rotation = m_frameRotation;
    if (m_mcBase._visible != !m_hidden) {
      m_mcBase._visible = !m_hidden;
      if (m_hidden) {
        m_mcBase._x = 4000;
        m_mcBase._y = 4000;
      } else {
        m_mcBase._x = m_frame.origin.x;
        m_mcBase._y = m_frame.origin.y;
      }
    }
    
    m_mcBase._alpha = m_alpha;
  }
  
  public function removeFromSuperview() {
    removeMovieClips();
  }

  public function removeMovieClips():Void {
    super.removeMovieClips();
    m_mcBase.removeMovieClip();
    m_mcBase = null;
  }
  
  //******************************************************
  //*            Loading the root swf
  //******************************************************

  private function loadSwf() {
    m_mcBounds = m_mcFrame.createEmptyMovieClip("m_mcBounds", 2);
    m_graphics.setClip(m_mcBounds);
    var image_mcl:MovieClipLoader = new MovieClipLoader();
    image_mcl.addListener(this);
    m_mcBounds._lockroot = true;
    image_mcl.loadClip(m_window.swf(), m_mcBounds);
  }
  
  public function onLoadInit(target_mc:MovieClip) {
    //trace(">>>> Got load init for "+m_window.swf());
    m_swfLoading = false;
    m_swfLoaded = true;
    m_mcBounds.view = this;
    initializeBoundsMovieClip();
    display();

    m_notificationCenter.postNotificationWithNameObject(
      NSWindow.ASWindowContentSwfDidLoad, window());
  }

  public function onLoadError(target_mc:MovieClip, code:String, status:Number) {
    trace(">>>> Got load error for "+m_window.swf()+" [code="+code+", status="+status+"]");
  }

  public function onLoadComplete(target_mc:MovieClip, status:Number) {
    //trace(">>>> Got load complete for "+m_window.swf()+" [status="+status+"]");
  }
  
  //******************************************************
  //*                 Visual methods
  //******************************************************

  private function drawResizeClip() {
    with(m_resizeClip) {
      clear();
      beginFill(0xFFFFFF, 1);
      lineStyle(0, 0xFFFFFF, 1);
      moveTo(0,0);
      lineTo(10,0);
      lineTo(10,10);
      lineTo(0,10);
      lineTo(0,0);
      endFill();
    }
    if (m_showsResizeIndicator) {
      with(m_resizeClip) {
        //da 87 e8 ff
        lineStyle(1.5, 0xdadada, 100);
        moveTo(0,10);
        lineTo(10,0);
        lineStyle(1.5, 0x878787, 100);
        moveTo(1,10);
        lineTo(10,1);
        lineStyle(1.5, 0xe8e8e8, 100);
        moveTo(2,10);
        lineTo(10,2);

        lineStyle(1.5, 0xdadada, 100);
        moveTo(4,10);
        lineTo(10,4);
        lineStyle(1.5, 0x878787, 100);
        moveTo(5,10);
        lineTo(10,5);
        lineStyle(1.5, 0xe8e8e8, 100);
        moveTo(6,10);
        lineTo(10,6);

        lineStyle(1.5, 0xdadada, 100);
        moveTo(8,10);
        lineTo(10,8);
        lineStyle(1.5, 0x878787, 100);
        moveTo(9,10);
        lineTo(10,9);
        lineStyle(1.5, 0xe8e8e8, 100);
        moveTo(10,10);
        lineTo(10,10);
      }
    }
  }

  public function hasShadow():Boolean {
    return m_hasShadow;
  }

  public function setHasShadow(value:Boolean) {
    m_hasShadow = value;
    if (m_hasShadow) {
      m_shadowFilter = new DropShadowFilter();
      m_shadowFilter.blurX = 20;
      m_shadowFilter.blurY = 20;
      m_shadowFilter.alpha = .6;
      m_shadowFilter.strength = .7;
      m_shadowFilter.angle = 90;
      m_mcBase.filters = [m_shadowFilter];
    } else {
      m_shadowFilter = null;
      m_mcBase.filters = [];
    }
  }

  public function alphaValue():Number {
    return m_mcBase._alpha;
  }

  public function setAlphaValue(level:Number) {
  	m_alpha = level;
    updateFrameMovieClipPerspective();
  }

  public static function lowestView():ASRootWindowView {
    return g_lowestView;
  }

  public function dump(view:ASRootWindowView) {
    if(view == null) view = g_lowestView;
    trace(view.lowerView().window().windowNumber()+" - "+view.window().windowNumber()+" - "+view.higherView().window().windowNumber());
    if(view.higherView() != null) {
      dump(view.higherView());
    } else {
      trace("---");
    }
  }

  public function highestViewOfLevel():ASRootWindowView {
    var view:ASRootWindowView = g_lowestView;
    while(view.higherView() != null && view.higherView().level()<=level()) {
      view = view.higherView();
    }
    if (view.level() > level()) {
      view = null;
    }
    return view;
  }

  public function lowestViewOfLevel():ASRootWindowView {
    var view:ASRootWindowView = g_lowestView;
    while(view != null && view.level()>=level()) {
      view = view.higherView();
    }
    return view;
  }

  public function level():Number {
    return m_window.level();
  }

  public function setHigherView(view:ASRootWindowView) {
    m_higherView = view;
  }

  public function higherView():ASRootWindowView {
    return m_higherView;
  }

  public function setLowerView(view:ASRootWindowView) {
    if (view == null) {
      if (g_lowestView != null) {
        g_lowestView.setLowerView(this);
      }
      m_lowerView = view;
      g_lowestView = this;
    } else {
      if (view != m_lowerView) {
        m_lowerView = view;
        view.higherView().setLowerView(this);
        view.setHigherView(this);
      }
    }
    setTargetDepths();
  }

  public function setTargetDepths() {
    var view:ASRootWindowView = g_lowestView;
    var i:Number = 100;
    view.setTargetDepth(i++);
    while(view.higherView() != null) {
      view.higherView().setTargetDepth(i++);
      view = view.higherView();
    }
  }

  public function setTargetDepth(depth:Number) {
    m_targetDepth = depth;
  }

  public function extractView() {
    var lower:ASRootWindowView = m_lowerView;
    var higher:ASRootWindowView = m_higherView;
    m_higherView = null;
    m_lowerView = null;
    if (g_lowestView == this) {
      g_lowestView = higher;
      higher.m_lowerView = null;
      return;
    }
    higher.m_lowerView = lower;
    lower.m_higherView = higher;
  }

  public function lowerView():ASRootWindowView {
    return m_lowerView;
  }

  public function matchDepth() {
    if (m_mcBase == null) {
      return;
    }
    var oldDepth:Number = m_mcBase.getDepth();
    if (m_targetDepth != oldDepth) {
      m_mcBase.swapDepths(m_targetDepth);
      WINDOW_CLIP.getInstanceAtDepth(oldDepth).view.matchDepth();
    }
  }

  public function setContentView(view:NSView) {
    var contentView:NSView = subviews()[0];
    if (contentView != null) {
      contentView.removeFromSuperview();
    }
    
    addSubview(view);
    
    if (m_toolbarView.superview() == null) {
      addSubview(m_toolbarView);
    }
  }

  public function acceptsFirstMouse(event:NSEvent):Boolean {
    return true;
  }

  public function display() {
    if(m_mcBase == undefined) {
      createMovieClips();
    }
    if(m_mcBounds.view != undefined) {
      super.display();
      m_window.windowDidDisplay();
    }
  }

  public function displayIfNeeded() {
    if(m_mcBase == undefined) {
      createMovieClips();
    }
    if (m_mcBounds.view != undefined) {
      super._displayIfNeeded();
    }
  }

  //******************************************************
  //*                    Buttons
  //******************************************************

  /**
   * Returns this window's close button.
   */
  public function closeButton():NSButton {
    return m_closeBtn;
  }

  /**
   * Returns this window's miniaturize button.
   */
  public function miniaturizeButton():NSButton {
    return m_miniBtn;
  }

  //******************************************************
  //*                     Cursors
  //******************************************************

  public function resetCursorRects():Void {
    if (m_window.styleMask() & NSWindow.NSResizableWindowMask) {
      addCursorRectCursor(new NSRect(m_resizeClip._x, m_resizeClip._y,
        m_resizeClip._width, m_resizeClip._height),
        NSCursor.resizeDiagonalDownCursor());
    }
  }

  //******************************************************
  //*                  Event handling
  //******************************************************

  public function mouseDown(event:NSEvent) {
    var wndStyle:Number = m_window.styleMask();
    if (wndStyle == NSWindow.NSBorderlessWindowMask) {
      return;
    }

    var location:NSPoint = event.mouseLocation;
    location = convertPointFromView(location);

    if(m_resizeRect.pointInRect(location)
    	&& wndStyle & NSWindow.NSResizableWindowMask) {
      resizeWindow(event);
    }
    else if((m_titleRect.pointInRect(location) || m_window.isMovableByWindowBackground())
    	&& wndStyle & NSWindow.NSTitledWindowMask
    	&& wndStyle & NSWindow.NSNotDraggableWindowMask == 0) {
      dragWindow(event);
    }
  }

  private function dragWindow(event:NSEvent) {
    m_mcBase.cacheAsBitmap=true;
    var point:NSPoint = convertPointFromView(event.mouseLocation, null);
    m_trackingData = {
      offsetX: point.x,
      offsetY: point.y,
      mouseDown: true,
      eventMask: NSEvent.NSLeftMouseDownMask | NSEvent.NSLeftMouseUpMask | NSEvent.NSLeftMouseDraggedMask
        | NSEvent.NSMouseMovedMask  | NSEvent.NSOtherMouseDraggedMask | NSEvent.NSRightMouseDraggedMask,
      complete: false
    };
    //m_mcBase._alpha = 80;
    dragWindowCallback(event);
  }

  public function dragWindowCallback(event:NSEvent) {
    if (event.type == NSEvent.NSLeftMouseUp) {
      //m_mcBase._alpha = 100;
      m_mcBase.cacheAsBitmap=false;
      return;
    }
    m_window.setFrameOrigin(new NSPoint(event.mouseLocation.x - m_trackingData.offsetX, event.mouseLocation.y - m_trackingData.offsetY));
    NSApplication.sharedApplication().callObjectSelectorWithNextEventMatchingMaskDequeue(this, "dragWindowCallback", m_trackingData.eventMask, true);
  }

  //******************************************************
  //*                    Resizing
  //******************************************************

  /**
   * Returns <code>true</code> if the root view is resizing, or
   * <code>false</code> otherwise.
   */
  public function isResizing():Boolean {
    return m_isResizing;
  }

  /**
   * Begins resizing the window.
   */
  private function resizeWindow(event:NSEvent) {
  	m_isResizing = true;
  	NSView(subviews()[0]).setHidden(true);
  	m_toolbarView.setHidden(true);
  	m_mcBase.filters = [];
    var frame:NSRect = frame();
    m_trackingData = {
      origin: frame.origin,
      offsetX: frame.origin.x + frame.size.width - event.mouseLocation.x,
      offsetY: frame.origin.y + frame.size.height - event.mouseLocation.y,
      mouseDown: true,
      eventMask: NSEvent.NSLeftMouseDownMask | NSEvent.NSLeftMouseUpMask | NSEvent.NSLeftMouseDraggedMask
        | NSEvent.NSMouseMovedMask  | NSEvent.NSOtherMouseDraggedMask | NSEvent.NSRightMouseDraggedMask,
      complete: false
    };
    display();
    resizeWindowCallback(event);
  }

  /**
   * Called on every matching event during the resize.
   */
  public function resizeWindowCallback(event:NSEvent) {
    var width:Number = event.mouseLocation.x - m_trackingData.origin.x + m_trackingData.offsetX;
    var height:Number = event.mouseLocation.y - m_trackingData.origin.y + m_trackingData.offsetY;

    m_isResizing = event.type != NSEvent.NSLeftMouseUp;

    var frmRect:NSRect = new NSRect(m_trackingData.origin.x, m_trackingData.origin.y, width, height);
    m_window.setFrameWithNotifications(frmRect, !m_isResizing);

    if (!m_isResizing) {
      m_notificationCenter.postNotificationWithNameObject(
        NSWindow.NSWindowDidResizeNotification, m_window);
      var content:NSView = NSView(subviews()[0]);
      content.setHidden(false);
      content.setFrameSize(m_window.contentRectForFrameRect().size);
      content.setNeedsDisplay(true);
      
      var tb:NSToolbar = m_window.toolbar();
      m_toolbarView.setHidden(tb == null || !tb.isVisible());
      setNeedsDisplay(true);
      NSCursor.pop();
      m_window.resetCursorRects();
      return;
    } else {
    	resetCursorRects();
    }

    NSApplication.sharedApplication().callObjectSelectorWithNextEventMatchingMaskDequeue(this, "resizeWindowCallback", m_trackingData.eventMask, true);
  }

  /**
   * Closes the window. This is the handler for a "close" button click.
   */
  private function closeWindow(sender:Object):Void {
    m_window.performClose(sender);
  }

  /**
   * Miniaturizes the window. This is the handler for a "mini" button click.
   */
  private function miniaturizeWindow(sender:Object):Void {
    m_window.performMiniaturize(sender);
  }

  /**
   * Deminiaturizes the window. This is the handler for a "restore" button
   * click.
   */
  private function deminiaturizeWindow(sender:Object):Void {
    m_window.deminiaturize(sender);
  }

  //******************************************************
  //*                 Visual Properties
  //******************************************************

  public function showsResizeIndicator():Boolean {
    return m_showsResizeIndicator;
  }

  public function setShowsResizeIndicator(value:Boolean) {
    if (m_showsResizeIndicator != value) {
      m_showsResizeIndicator = value;
      drawResizeClip();
    }
  }

  //******************************************************
  //*                     Drawing
  //******************************************************

  public function drawRect(rect:NSRect) {
  	m_mcBounds.clear();

    var styleMask:Number = m_window.styleMask();
    var isKey:Boolean = m_window.isKeyWindow();
    if (m_hasShadow) {
      if (isKey) {
        /** IF Flash8 */
        m_shadowFilter.blurX = 20;
        m_shadowFilter.blurY = 15;
        m_shadowFilter.alpha = .6;
        m_shadowFilter.strength = .7;
        m_shadowFilter.angle = 90;
        m_mcBase.filters = [m_shadowFilter];
        /** ENDIF */
      } else {
        /** IF Flash8 */
        m_shadowFilter.blurX = 10;
        m_shadowFilter.blurY = 4;
        m_shadowFilter.alpha = .4;
        m_shadowFilter.strength = .3;
        m_shadowFilter.angle = 90;
        m_mcBase.filters = [m_shadowFilter];
        /** ENDIF */
      }
    }

    var x:Number = rect.origin.x;
    var y:Number = rect.origin.y;
    var width:Number = rect.size.width-1;
    var height:Number = m_titleRect.size.height;
    m_titleRect.size.width = width;
    var totalHeight:Number = rect.size.height-1;
    var theme:ASThemeProtocol = ASTheme.current();
    var titleFrame:NSRect = new NSRect(x, y, width, height);
    
    //
    // Only draw title and icon if the styleMask says we should.
    //
    var icon:NSImage = m_window.icon();
    var iconRect:NSRect;
    var hasIcon:Boolean = false;

    if (styleMask & NSWindow.NSTitledWindowMask) {
      drawTitleBarInRectIsKey(titleFrame, isKey);
      
      if (icon != null) {
      	iconRect = drawIconInTitleBarRect(icon, titleFrame);
      	hasIcon = true; 
      }
    } else {
      height = 0;
    }

    //
    // If we have no background color and the window is being resized, we'll
    // draw a filler rect instead.
    //
    if (m_isResizing && m_window.backgroundColor() == null) {
      drawResizingBackgroundInRect(new NSRect(x, y + height, width, totalHeight - height));   
      return;
    }

    //
    // Draw the background
    //
    drawBackgroundInRectStyleMask(new NSRect(x, y + height, width, totalHeight - height), styleMask);

    //
    // Deal with toolbar
    //
    var tb:NSToolbar = m_window.toolbar();

    //
    // If we're borderless, stop now.
    //
    if (styleMask == NSWindow.NSBorderlessWindowMask) {
      if (tb == null || !tb.isVisible()) {
      	m_toolbarView.setHidden(true);
      } else {
      	m_toolbarView.setHidden(false);
      	var tbHeight:Number = theme.toolbarHeightForToolbar(tb);
      	m_toolbarView.setFrame(new NSRect(1, 1, width - 2, tbHeight));
      }

      return;
    }

    //
    // Size toolbar
    //
    if (tb == null || !tb.isVisible()) {
      m_toolbarView.setHidden(true);
    } else {
      m_toolbarView.setHidden(false);
      var tbHeight:Number = theme.toolbarHeightForToolbar(tb);      
      m_toolbarView.setFrame(new NSRect(1, m_titleRect.maxY() + 1, width - 2, tbHeight));
    }

    //
    // Tile buttons
    //    
    var lastButton:NSButton = tileButtonsInTitleRectStyleMask(titleFrame, styleMask);

    //
    // Draw the title.
    //
    if (styleMask & NSWindow.NSTitledWindowMask) {
      var titleRect:NSRect = m_titleRect.clone();
      if (lastButton != null) {
        titleRect.size.width = lastButton.frame().origin.x;
      }
      if (hasIcon) {
        titleRect.origin.x = iconRect.maxX() + 1;
        titleRect.size.width -= iconRect.maxX();
      }
      
      drawTitleInRectIsKey(titleRect, isKey);
    } else {
      height = 0;
    }
  }
  
  /**
   * Draws the title bar.
   */
  public function drawTitleBarInRectIsKey(rect:NSRect, isKey:Boolean):Void {
    ASTheme.current().drawWindowTitleBarWithRectInViewIsKey(rect, this, isKey);
  }
  
  /**
   * Draws the title
   */
  private function drawTitleInRectIsKey(titleRect:NSRect, isKey:Boolean):Void {
	m_titleCell.setTextColor(isKey ? m_titleKeyFontColor : m_titleFontColor);
	m_titleCell.setFont(m_titleFont);
	m_titleCell.setStringValue(m_window.title());   
	
	titleRect = titleRect.insetRect(3, 2);
	
	m_titleCell.drawWithFrameInView(titleRect, this);
	
	//
	// If the cell has been truncated, set up a tooltip
	//
	removeToolTip(m_titleToolTipTag);
	if (m_titleCell.isTruncated()) {
	m_titleToolTipTag = addToolTipRectOwnerUserData(titleRect, m_window.title(), null);
	}
  }
  
  /**
   * Draws the window icon in the specified title bar rect.
   */
  private function drawIconInTitleBarRect(icon:NSImage, rect:NSRect):NSRect {
    var iconRect:NSRect = new NSRect(2, 2, rect.size.height - 4, rect.size.height - 4);
    icon.bestRepresentationForDevice("").setSize(iconRect.size);
    icon.lockFocus(m_mcBounds);
    icon.drawAtPoint(iconRect.origin);
    icon.unlockFocus();
        
    return iconRect;
  }

  /**
   * Draws the background for a resizing window.
   */
  private function drawResizingBackgroundInRect(rect:NSRect):Void {
    ASTheme.current().drawResizingWindowWithRectInView(rect, this);
  }
  
  /**
   * Draws the standard window background.
   */
  private function drawBackgroundInRectStyleMask(rect:NSRect, styleMask:Number):Void {
  	var bgcolor:NSColor = m_window.backgroundColor();
    var bordered:Boolean = !(styleMask == NSWindow.NSBorderlessWindowMask);
    var g:ASGraphics = graphics();
    
    if (null != bgcolor) {
      g.brushDownWithBrush(bgcolor);
    }
        
    if (bordered) {
      g.drawRectWithRect(rect, new NSColor(0x8E8E8E), 1, 100);
    } else {
      g.drawRectWithRect(rect);
    }
    
    if (null != bgcolor) {
      g.brushUp();
    }
  }

  /**
   * Tiles the buttons.
   */
  private function tileButtonsInTitleRectStyleMask(rect:NSRect, mask:Number):NSButton {
    //
    // Button stuff
    //
    var btnx:Number = rect.origin.x + rect.size.width - 4 / 2 - BUTTON_SIDE_LENGTH;
    var btny:Number = rect.origin.y + (rect.size.height - BUTTON_SIDE_LENGTH) / 2 + 1;
    var btnCnt:Number = 0;
    var lastButton:NSButton = null; // used for title sizing

    //
    // Close button
    //
    if (mask & NSWindow.NSTitledWindowMask
        && mask & NSWindow.NSClosableWindowMask) {
      if (m_closeBtn.superview() == null) {
        addSubview(m_closeBtn);
        m_closeBtn.setFrameOrigin(new NSPoint(btnx, btny));
      }

      lastButton = m_closeBtn;
      btnCnt++;
      btnx -= (BUTTON_SIDE_LENGTH + BUTTON_SPACING);
    } else {
      m_closeBtn.removeFromSuperview();
    }

    //
    // Miniaturize button
    //
    if (mask & NSWindow.NSTitledWindowMask
        && mask & NSWindow.NSMiniaturizableWindowMask) {
      if (m_miniBtn.superview() == null) {
        addSubview(m_miniBtn);
        m_miniBtn.setFrameOrigin(new NSPoint(btnx, btny));
      }

      lastButton = m_miniBtn;
      btnCnt++;
    } else {
      m_miniBtn.removeFromSuperview();
    }
    
    return lastButton;
  }
  
  /**
   * The rectangle the title occupies
   */
  public function titleRect():NSRect {
  	return m_titleRect.clone();
  }

  //******************************************************
  //*                  Toolbar view
  //******************************************************

  /**
   * For internal use only.
   */
  public function toolbarView():NSView {
    return m_toolbarView;
  }
  
  //******************************************************
  //*              Setting the root swf
  //******************************************************
  
  /**
   * Sets the clip that all windows are created within to <code>mc</code>.
   */
  public static function setWindowClip(mc:MovieClip):Void {
    WINDOW_CLIP = mc;
  }
  
  /**
   * Returns the movieclip all windows are created within. 
   */
  public static function windowClip():MovieClip {
    return WINDOW_CLIP;
  }
}