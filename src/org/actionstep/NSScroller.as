/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSControlSize;
import org.actionstep.constants.NSScrollArrowPosition;
import org.actionstep.constants.NSScrollerPart;
import org.actionstep.constants.NSUsableScrollerParts;
import org.actionstep.NSApplication;
import org.actionstep.NSButtonCell;
import org.actionstep.NSControl;
import org.actionstep.NSEvent;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.scroller.ASScrollerButtonCell;
import org.actionstep.themes.ASTheme;

/**
 * <p>A horizontal or vertical scrollbar.</p>
 * 
 * <p>Used internally by an {@link org.actionstep.NSScrollView}.</p>
 * 
 * <p>For an example of this class' usage, please see
 * {@link org.actionstep.test.ASTestScrollers}.</p>
 * 
 * <h2>Subclassing Notes</h2>
 * <p>
 * The static methods upCell(), leftCell(), rightCell() and downCell() must
 * be overridden to supply a subclass of org.actionstep.scroller.ASScrollerButtonCell
 * </p>
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSScroller extends NSControl {
  
  private static var g_buttonCellClass:Function = org.actionstep.scroller.ASScrollerButtonCell;
  
  //******************************************************
  //*                   Constants
  //******************************************************
    
  private static var g_upCell:ASScrollerButtonCell;
  private static var g_downCell:ASScrollerButtonCell;
  private static var g_leftCell:ASScrollerButtonCell;
  private static var g_rightCell:ASScrollerButtonCell;

  //******************************************************
  //*                   Members
  //******************************************************
  
  private var m_upCell:NSButtonCell;
  private var m_downCell:NSButtonCell;
  private var m_leftCell:NSButtonCell;
  private var m_rightCell:NSButtonCell;
  
  private var m_hitPart:NSScrollerPart;
  private var m_arrowsPosition:NSScrollArrowPosition;
  private var m_floatValue:Number;
  private var m_usableParts:NSUsableScrollerParts;
  private var m_knobProportion:Number;
  private var m_pendingKnobProportion:Number;
  private var m_target:Object;
  private var m_action:String;
  private var m_enabled:Boolean;
  private var m_cellTrackingRect:NSRect;
  private var m_horizontal:Boolean;
  private var m_scrollerKnobClip:MovieClip;
  private var m_scrollerKnobClipRect:NSRect;
  private var m_delegate:Object;
  private var m_isScrolling:Boolean;
  
  //TODO hackariffica - need better API for this, obviously
  public var m_borderAlphas:Array;
  
  //******************************************************
  //*                   Construction
  //******************************************************
  
  /**
   * Creates a new instance of the <code>NSScroller</code> class. 
   */
  public function NSScroller() {
    m_enabled = true;
    m_pendingKnobProportion = 0;
    m_scrollerKnobClipRect = new NSRect(0,0,0,0);
    m_borderAlphas = [100,100,100,100];
    m_isScrolling = false;
  }
  
  public function init():NSScroller {
    return initWithFrame(NSRect.ZeroRect);
  }
  
  public function initWithFrame(rect:NSRect):NSScroller {
    if (rect.size.width > rect.size.height) {
      m_horizontal = true;
      rect.size.height = scrollerWidth();
    } else {
      m_horizontal = false;
      rect.size.width = scrollerWidth();
    }
    super.initWithFrame(rect);
    m_arrowsPosition = NSScrollArrowPosition.NSScrollerArrowsDefaultSetting;
    if (m_horizontal) {
      m_floatValue = 0.0;
    } else {
      m_floatValue = 1.0;
    }
    m_knobProportion = .5;
    m_hitPart = NSScrollerPart.NSScrollerNoPart;    
    drawParts();
    setEnabled(true);
    checkSpaceForParts();
    return this;
  }
  
  //******************************************************
  //*            Determining NSScroller size
  //******************************************************
  
  /**
   * Returns the width of “normal-sized” instances.
   */
  public static function scrollerWidth():Number {
    return scrollerWidthForControlSize(NSControlSize.NSRegularControlSize);
  }

  /**
   * Returns the width of the scroller based on <code>size</code>.
   */
  public static function scrollerWidthForControlSize(size:NSControlSize):Number {
    return ASTheme.current().scrollerWidth();
  }
  
  /**
   * Sets the size of the scroller to <code>size</code>.
   */
  public function setControlSize(size:NSControlSize):Void {
    //! FIXME How to adjust to this?
  }
  
  /**
   * Returns the size of the scroller.
   */
  public function controlSize():NSControlSize {
    //! FIXME How to adjust to this?
    return NSControlSize.NSRegularControlSize;
  }
  
  //******************************************************
  //*                  Orientation
  //******************************************************
  
  /**
   * Returns true if the scroller is vertical.
   */
  public function isVertical():Boolean {
    return !m_horizontal;
  }
  
  //******************************************************
  //*             Laying out an NSScroller
  //******************************************************
  
  /**
   * Sets the location of the scroll buttons to <code>position</code>.
   */
  public function setArrowsPosition(position:NSScrollArrowPosition):Void {
    if (m_arrowsPosition == position) {
      return;
    }
    m_arrowsPosition = position;
    setNeedsDisplay(true);
  }
  
  /**
   * Returns the position of the scroll buttons.
   */
  public function arrowsPosition():NSScrollArrowPosition {
    return m_arrowsPosition;
  }
    
  //******************************************************
  //*            Setting the knob position
  //******************************************************
  
  public function setFloatValue(value:Number):Void {
  	//! TODO Figure out if this is right. What about the other value setters.
    if (m_floatValue == value) {
      return;
    }
    if (value < 0) {
      value = 0;
    }
    if (value > 1) {
      value = 1;
    }
    m_floatValue = value;
    drawKnob();
  }
  
  public function setFloatValueKnobProportion(value:Number, 
      knobProportion:Number):Void {
    if (m_floatValue == value && m_knobProportion == knobProportion) {
      return;
    }
    if (knobProportion < 0) {
      m_pendingKnobProportion = 0;
    } else if (knobProportion > 1) {
      m_pendingKnobProportion = 1;
    } else {
      m_pendingKnobProportion = knobProportion;
    }
    if (m_hitPart == NSScrollerPart.NSScrollerNoPart) {
      m_knobProportion = m_pendingKnobProportion;
      m_pendingKnobProportion = 0;
    }
    if (m_knobProportion == 1) {
      setEnabled(false);
    } else {
      setEnabled(true);
    }
    if (m_hitPart != NSScrollerPart.NSScrollerKnobSlot 
        && m_hitPart != NSScrollerPart.NSScrollerKnob) {
      m_floatValue = -1;
      setFloatValue(value);
    } 
  }
  
  public function floatValue():Number {
    return m_floatValue;
  }
  
  public function knobProportion():Number {
    return m_knobProportion;
  }
  
  //******************************************************
  //*        Reporting whether we are scrolling
  //******************************************************
  
  public function isScrolling():Boolean {
    return m_isScrolling;
  }
  
  //******************************************************
  //*               Calculating layout
  //******************************************************
  
  public function rectForPart(part:NSScrollerPart):NSRect {
    var scrollerFrame:NSRect = m_frame.clone();
    var x:Number, y:Number, width:Number, height:Number;
    var buttonWidth:Number = ASTheme.current().scrollerButtonWidth();
    x = y = width = height = 0;
    
    var buttonsSize:Number = 2*ASTheme.current().scrollerButtonWidth();
    var usableParts:NSUsableScrollerParts;
    
    if (!m_enabled) {
      usableParts = NSUsableScrollerParts.NSNoScrollerParts;
    } else {
      usableParts = m_usableParts;
    }
    
    // reverse width/height based on orientation
    if (m_horizontal) {
      width = scrollerFrame.size.height - 2;
      height = scrollerFrame.size.width - 2;
    } else {
      width = scrollerFrame.size.width - 2;
      height = scrollerFrame.size.height - 2;
    }
    
    switch(part) {
      case NSScrollerPart.NSScrollerKnob:
        if (usableParts == NSUsableScrollerParts.NSNoScrollerParts ||
            m_arrowsPosition == NSUsableScrollerParts.NSOnlyScrollerArrows) {
          return NSRect.ZeroRect;
        }
        var slotHeight:Number = height - 
          (m_arrowsPosition == NSScrollArrowPosition.NSScrollerArrowsNone ? 0 
            : buttonsSize);
        var knobHeight:Number = Math.floor(m_knobProportion * slotHeight);
        if (knobHeight < buttonWidth) {
          knobHeight = buttonWidth;
        }
        var knobPosition:Number = Math.floor(m_floatValue * (slotHeight 
          - knobHeight));
        if (m_arrowsPosition == NSScrollArrowPosition.NSScrollerArrowsNone) {
          y += knobPosition;
        } else {
          y += knobPosition + buttonWidth;
        }
        height = knobHeight;
        width = buttonWidth;
        x += 1;
        y += 1;
        break;
      case NSScrollerPart.NSScrollerKnobSlot:
        if (usableParts == NSUsableScrollerParts.NSNoScrollerParts ||
            m_arrowsPosition == NSScrollArrowPosition.NSScrollerArrowsNone) {
          break;
        }
        height -= buttonsSize;
        y += buttonWidth+1;
        break;
      case NSScrollerPart.NSScrollerDecrementLine:
      case NSScrollerPart.NSScrollerDecrementPage:
        if (usableParts == NSUsableScrollerParts.NSNoScrollerParts ||
            m_arrowsPosition == NSScrollArrowPosition.NSScrollerArrowsNone) {
          return NSRect.ZeroRect;
        }
        x += 1;
        y += 1;
        width = buttonWidth;
        height = buttonWidth;
        break;
      case NSScrollerPart.NSScrollerIncrementLine:
      case NSScrollerPart.NSScrollerIncrementPage:
        if (usableParts == NSUsableScrollerParts.NSNoScrollerParts ||
            m_arrowsPosition == NSScrollArrowPosition.NSScrollerArrowsNone) {
          return NSRect.ZeroRect;
        }
        x += 1;
        y += (height - buttonWidth+1);
        width = buttonWidth;
        height = buttonWidth;
        break;
      case NSScrollerPart.NSScrollerNoPart:
        return NSRect.ZeroRect;
    }
    // Reverse y/x & height/width based on orientation
    if (m_horizontal) {
      return new NSRect(y,x,height,width);
    } else {
      return new NSRect(x,y,width,height);
    }
  }
  
  public function testPart(point:NSPoint):NSScrollerPart {
    var rect:NSRect;
    point = convertPointFromView(point);
    if (point.x <= 0 || point.x >=m_frame.size.width ||
        point.y <= 0 || point.y >=m_frame.size.height) {
      return NSScrollerPart.NSScrollerNoPart;
    }
    rect = rectForPart(NSScrollerPart.NSScrollerDecrementLine);
    if (rect.pointInRect(point)) {
      return NSScrollerPart.NSScrollerDecrementLine;
    }

    rect = rectForPart(NSScrollerPart.NSScrollerIncrementLine);
    if (rect.pointInRect(point)) {
      return NSScrollerPart.NSScrollerIncrementLine;
    }
    
    rect = rectForPart(NSScrollerPart.NSScrollerKnob);
    if (rect.pointInRect(point)) {
      return NSScrollerPart.NSScrollerKnob;
    }

    rect = rectForPart(NSScrollerPart.NSScrollerIncrementPage);
    if (rect.pointInRect(point)) {
      return NSScrollerPart.NSScrollerIncrementPage;
    }

    rect = rectForPart(NSScrollerPart.NSScrollerDecrementPage);
    if (rect.pointInRect(point)) {
      return NSScrollerPart.NSScrollerDecrementPage;
    }

    rect = rectForPart(NSScrollerPart.NSScrollerKnobSlot);
    if (rect.pointInRect(point)) {
      return NSScrollerPart.NSScrollerKnobSlot;
    }

    return NSScrollerPart.NSScrollerNoPart;
  }
  
  public function checkSpaceForParts():Void {
    var frameSize:NSSize = m_frame.size;
    var size:Number = (m_horizontal ? frameSize.width : frameSize.height);
    var buttonWidth:Number = ASTheme.current().scrollerButtonWidth();
    
    if (m_arrowsPosition == NSScrollArrowPosition.NSScrollerArrowsNone) {
      if (size > buttonWidth + 3) {
        m_usableParts = NSUsableScrollerParts.NSAllScrollerParts;
      } else {
        m_usableParts = NSUsableScrollerParts.NSNoScrollerParts;
      }
    } else {
      if (size >= 5 + buttonWidth * 3) {
        m_usableParts = NSUsableScrollerParts.NSAllScrollerParts;
      } else if (size >= 3 + buttonWidth * 2) {
        m_usableParts = NSUsableScrollerParts.NSOnlyScrollerArrows;
      } else {
         m_usableParts = NSUsableScrollerParts.NSNoScrollerParts;
      }
    }
  }
  
  public function usableParts():NSUsableScrollerParts {
    return m_usableParts;
  }
  
  //******************************************************
  //*                Drawing the parts
  //******************************************************
  
  public function isOpaque():Boolean {
    return true;
  }
  
  public function drawParts():Void {
    
    //
    // Get the cells
    //
    m_upCell = getClass().upCell();
    m_downCell = getClass().downCell();
    m_leftCell = getClass().leftCell();
    m_rightCell = getClass().rightCell();
  }
  
  //******************************************************
  //*                  Event handling
  //******************************************************

  public function hitPart():NSScrollerPart {
    return m_hitPart;
  }
  
  public function acceptsFirstMouse():Boolean {
    return true;
  }

  public function acceptsFirstResponder():Boolean {
    return false;
  }

  public function action():String {
    return m_action;
  }

  public function setAction(value:String):Void {
    m_action = value;
  }

  public function target():Object {
    return m_target;
  }

  public function setTarget(target:Object):Void {
    m_target = target;
  }
  
  public function mouseDown(event:NSEvent):Void {
    if (!m_enabled) {
      return;
    }
    
    //
    // Determine the location of the press
    //
    var location:NSPoint = event.mouseLocation;
    m_hitPart = testPart(location);
    
    //
    // Set the cell targets
    //
    setButtonCellTargets();
    
    //
    // Depending on the part pressed, perform a different action
    //
    switch(m_hitPart) {
      case NSScrollerPart.NSScrollerIncrementPage:
      case NSScrollerPart.NSScrollerIncrementLine:
        m_cell = m_horizontal ? m_rightCell : m_downCell;
        m_cellTrackingRect = rectForPart(NSScrollerPart.NSScrollerIncrementLine);
        m_isScrolling = true;
        super.mouseDown(event);
        return;
        break;
      case NSScrollerPart.NSScrollerDecrementPage:
      case NSScrollerPart.NSScrollerDecrementLine:
        m_cell = m_horizontal ? m_leftCell : m_upCell;
        m_cellTrackingRect = rectForPart(NSScrollerPart.NSScrollerDecrementLine);
        m_isScrolling = true;
        super.mouseDown(event);
        return;
        break;
      case NSScrollerPart.NSScrollerKnob:
        trackKnob(event);
        return;
      case NSScrollerPart.NSScrollerKnobSlot:
//        location = convertPointFromView(location, null);
//        if ((m_horizontal && location.x < m_scrollerKnobClipRect.minX()) || (!m_horizontal && location.y < m_scrollerKnobClipRect.minY())) {
//          m_hitPart = NSScrollerPart.NSScrollerDecrementPage;
//        } else {
//          m_hitPart = NSScrollerPart.NSScrollerIncrementPage;
//        }
//        sendActionTo(m_action, m_target);
//        return;
        var floatValue = floatValueAtPoint(convertPointFromView(location, null));
        if (m_floatValue != floatValue) {
          setFloatValue(floatValue);
          sendActionTo(m_action, m_target);
        }
        trackKnob(event);
        return;
        break;
      case NSScrollerPart.NSScrollerNoPart:
        break;
    }
    m_hitPart = NSScrollerPart.NSScrollerNoPart;
    if (m_pendingKnobProportion != 0) {
      setFloatValueKnobProportion(m_floatValue, m_pendingKnobProportion);
    } else {
      setNeedsDisplay(true);
    }
  }

  private function trackKnob(event:NSEvent):Void {
    if (m_delegate != null) {
      m_delegate.scrollerBeginKnobScroll(this);
    }
    var rectKnob:NSRect = rectForPart(NSScrollerPart.NSScrollerKnob);
    var point:NSPoint = convertPointFromView(event.mouseLocation, null);
    m_trackingData = { 
      offsetY: point.y - rectKnob.origin.y,
      offsetX: point.x - rectKnob.origin.x,
      mouseDown: true, 
      eventMask: NSEvent.NSLeftMouseDownMask | NSEvent.NSLeftMouseUpMask | NSEvent.NSLeftMouseDraggedMask
        | NSEvent.NSMouseMovedMask  | NSEvent.NSOtherMouseDraggedMask | NSEvent.NSRightMouseDraggedMask,
      complete: false
    };
    
    m_isScrolling = true;
    knobTrackingCallback(event);
  }

  public function knobTrackingCallback(event:NSEvent):Void {
    if (event.type == NSEvent.NSLeftMouseUp) {
      m_isScrolling = false;
      m_hitPart = NSScrollerPart.NSScrollerNoPart;
      if (m_delegate != null) {
        m_delegate.scrollerEndKnobScroll(this);
      }
      return;
    }
    var point:NSPoint = convertPointFromView(event.mouseLocation, null);
    if (m_horizontal) {
      point.x -= m_trackingData.offsetX;
    } else {
      point.y -= m_trackingData.offsetY;
    }
    setFloatValue(floatValueAtPoint(point));
    sendActionTo(m_action, m_target);
    NSApplication.sharedApplication().callObjectSelectorWithNextEventMatchingMaskDequeue(this, "knobTrackingCallback", m_trackingData.eventMask, true);
  }
  
  public function cellTrackingCallback(mouseUp:Boolean) {
    if(mouseUp) {
      m_isScrolling = false;
    }
    
    super.cellTrackingCallback(mouseUp);
  }
  
  public function mouseTrackingCallback(event:NSEvent) {
    if (event.type == NSEvent.NSLeftMouseUp) {
      m_isScrolling = false;      
    }
    super.mouseTrackingCallback(event);
  }
  
  /** Drawing the scroller */
  public function drawRect(rect:NSRect):Void {
    m_mcBounds.clear();
    drawScrollerSlotWithRect(rect);
    if (m_enabled) {
      (m_horizontal ? m_leftCell : m_upCell).drawWithFrameInView(rectForPart(NSScrollerPart.NSScrollerDecrementLine), this);
      (m_horizontal ? m_rightCell : m_downCell).drawWithFrameInView(rectForPart(NSScrollerPart.NSScrollerIncrementLine), this);
      drawKnob();
    } else {
      if (m_scrollerKnobClip != null) {
        m_scrollerKnobClip.removeMovieClip();
        m_scrollerKnobClip = null;
        m_scrollerKnobClipRect = new NSRect(0,0,0,0);  
      }
    }
  }
  
  private function drawKnob():Void {
    if (m_mcBounds == null) return;
    if (m_scrollerKnobClip == null || m_scrollerKnobClip._parent == undefined) {
      m_scrollerKnobClip = createBoundsMovieClip();
      m_scrollerKnobClip.view = this;
      m_scrollerKnobClipRect = NSRect.ZeroRect;
    }
    var rectKnob:NSRect = rectForPart(NSScrollerPart.NSScrollerKnob);
    if (m_scrollerKnobClipRect.origin.x != rectKnob.origin.x ||
        m_scrollerKnobClipRect.origin.y != rectKnob.origin.y) {
      m_scrollerKnobClipRect.origin.x = rectKnob.origin.x;
      m_scrollerKnobClipRect.origin.y = rectKnob.origin.y;
      m_scrollerKnobClip._x = rectKnob.origin.x;
      m_scrollerKnobClip._y = rectKnob.origin.y;
    }
    if (m_scrollerKnobClipRect.size.width != rectKnob.size.width ||
        m_scrollerKnobClipRect.size.height != rectKnob.size.height) {
      m_scrollerKnobClipRect.size.width = rectKnob.size.width;
      m_scrollerKnobClipRect.size.height = rectKnob.size.height;
      m_scrollerKnobClip.clear();
      drawScrollerWithRectInClip(new NSRect(0,0,rectKnob.size.width, rectKnob.size.height), m_scrollerKnobClip);
    }
    updateAfterEvent();
  }

  private function drawScrollerSlotWithRect(rect:NSRect):Void {
    ASTheme.current().drawScrollerSlotWithRectInView(rect, this);
  }
  
  private function drawScrollerWithRectInClip(rect:NSRect, mc:MovieClip):Void {
    ASTheme.current().drawScrollerWithRectInClip(rect, mc);
  }
  
  //******************************************************
  //*               Setting the delegate
  //******************************************************
  
  /**
   * <p>Sets the delegate of the scroller to <code>delegate</code>.</p>
   * 
   * <p>The scroll view is typically a scroller's delegate.</p>
   * 
   * @see #delegate
   */
  public function setDelegate(delegate:Object):Void {
    m_delegate = delegate;
  }
  
  /**
   * <p>Returns the delegate of the scroller.</p>
   * 
   * @see #setDelegate
   */
  public function delegate():Object {
    return m_delegate;
  }
  
  //******************************************************
  //*              Overridden functions
  //******************************************************
  
  public function setFrame(rect:NSRect):Void {
    if (rect.size.width > rect.size.height) {
      m_horizontal = true;
      rect.size.height = scrollerWidth();
    } else {
      m_horizontal = false;
      rect.size.width = scrollerWidth();
    }
    super.setFrame(rect);
    if (m_arrowsPosition !=  NSScrollArrowPosition.NSScrollerArrowsNone) {
      m_arrowsPosition = NSScrollArrowPosition.NSScrollerArrowsDefaultSetting;
    }
    m_hitPart = NSScrollerPart.NSScrollerNoPart;    
    setNeedsDisplay(true);
    checkSpaceForParts();
  }
  
  public function setFrameSize(size:NSSize):Void {
    if (size.width > size.height) {
      m_horizontal = true;
      size.height = scrollerWidth();
    } else {
      m_horizontal = false;
      size.width = scrollerWidth();
    }
    super.setFrameSize(size);
    if (m_arrowsPosition !=  NSScrollArrowPosition.NSScrollerArrowsNone) {
      m_arrowsPosition = NSScrollArrowPosition.NSScrollerArrowsDefaultSetting;
    }
    setNeedsDisplay(true);
    checkSpaceForParts();
  }
  
  public function setEnabled(value:Boolean):Void {
    m_enabled = value;
    setNeedsDisplay(true);
  }

  public function isEnabled():Boolean {
    return m_enabled;
  }  
  
  //******************************************************
  //*                 Helper methods
  //******************************************************

  private function cellTrackingRect():NSRect {
    return m_cellTrackingRect;
  }
  
  private function setButtonCellTargets():Void {
    if (m_horizontal) {
      m_leftCell.setTarget(m_target);
      m_leftCell.setAction(m_action);
      m_rightCell.setTarget(m_target);
      m_rightCell.setAction(m_action);
    } else {
      m_upCell.setTarget(m_target);
      m_upCell.setAction(m_action);
      m_downCell.setTarget(m_target);
      m_downCell.setAction(m_action);
    }
  }

  private function floatValueAtPoint(point:NSPoint):Number {
    var knobRect:NSRect = rectForPart(NSScrollerPart.NSScrollerKnob);
    var slotRect:NSRect = rectForPart(NSScrollerPart.NSScrollerKnobSlot);
    var position:Number;
    var min_pos:Number;
    var max_pos:Number;
    
    if (m_horizontal) {
      min_pos = slotRect.minX();
      max_pos = slotRect.maxX() - knobRect.size.width;
      position = point.x;
    } else {
      min_pos = slotRect.minY();
      max_pos = slotRect.maxY() - knobRect.size.height;
      position = point.y;
    }
    if (position <= min_pos) {
      return 0;
    }
    if (position >= max_pos) {
      return 1;
    }
    return (position - min_pos) / (max_pos - min_pos);
  }
  
  //******************************************************
  //*             MovieClip (ActionStep-only)
  //******************************************************
  
  private function requiresMask():Boolean {
    return false;
  }
  
  //******************************************************                               
  //*           Setting the button cell class
  //******************************************************
  
  /**
   * Returns the class' left scroller button cell.
   * 
   * <p><strong>NOTE:</strong> Must be overridden in subclasses.</p>
   */
  private static function leftCell():ASScrollerButtonCell {
  	if (g_leftCell == null) {
  		generateScrollerButtonCells();
  	}
  	
  	return g_leftCell;
  }
  
  /**
   * Returns the class' left scroller button cell.
   * 
   * <p><strong>NOTE:</strong> Must be overridden in subclasses.</p>
   */
  private static function upCell():ASScrollerButtonCell {
    if (g_upCell == null) {
  		generateScrollerButtonCells();
  	}
  	
  	return g_upCell;
  }
 
  /**
   * Returns the class' left scroller button cell.
   * 
   * <p><strong>NOTE:</strong> Must be overridden in subclasses.</p>
   */
  private static function rightCell():ASScrollerButtonCell {
  	if (g_rightCell == null) {
  		generateScrollerButtonCells();
  	}
  	
  	return g_rightCell;
  }
  
  /**
   * Returns the class' left scroller button cell.
   * 
   * <p><strong>NOTE:</strong> Must be overridden in subclasses.</p>
   */
  private static function downCell():ASScrollerButtonCell {
  	if (g_downCell == null) {
  		generateScrollerButtonCells();
  	}
  	
  	return g_downCell;
  }
  
  /**
   * <p>Sets the cell class to <code>klass</code> (must be a subclass of
   * {@link ASScrollerButtonCell}). An instance of the cell class is instantiated for
   * every new scroller.</p>
   */
  public static function setButtonCellClass(klass:Function) {
    g_buttonCellClass = klass;
    generateScrollerButtonCells();
  }

  /**
   * <p>Returns the button cell class (a subclass of ASScrollerButtonCell).</p>
   */  
  public static function buttonCellClass():Function {
    if (g_buttonCellClass == undefined) {
      g_buttonCellClass = org.actionstep.scroller.ASScrollerButtonCell;
    }
    return g_buttonCellClass;
  }
  
  /**
   * Generates the scroller button cells.
   */
  private static function generateScrollerButtonCells():Void {
    g_upCell = new (buttonCellClass())();
    g_upCell.init();
    g_upCell.setButtonRole(ASScrollerButtonCell.ASTopScrollerButton);
    
    g_downCell = new (buttonCellClass())();
    g_downCell.init();
    g_downCell.setButtonRole(ASScrollerButtonCell.ASBottomScrollerButton);
    
    g_leftCell = new (buttonCellClass())();
    g_leftCell.init();
    g_leftCell.setButtonRole(ASScrollerButtonCell.ASLeftScrollerButton);
    
    g_rightCell = new (buttonCellClass())();
    g_rightCell.init();
    g_rightCell.setButtonRole(ASScrollerButtonCell.ASRightScrollerButton);
  }
}