/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.NSColor;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSScrollView;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.ASUtils;
import org.actionstep.graphics.ASGraphics;

/**
 * This class is used by an <code>NSScrollView</code> to "clip" the document
 * view, and reflect scrolling actions.
 * 
 * @author Rich Kilmer
 */
class org.actionstep.NSClipView extends NSView {
  private var m_documentView:NSView;
  private var m_passiveDocument:Boolean;
  private var m_drawsBackground:Boolean;
  private var m_copiesOnScroll:Boolean;
  private var m_backgroundColor:NSColor;
  private var m_smoothScrollingEnabled:Boolean;
  private var m_activeBounds:NSRect;
  private var m_docRect:NSRect;
  
  //******************************************************
  //*                   Construction
  //******************************************************
  
  public function init():NSClipView {
    super.init();
    setAutoresizesSubviews(true);
    m_copiesOnScroll = true;
    m_drawsBackground = true;
    m_smoothScrollingEnabled = false;
    m_passiveDocument = true;
    m_activeBounds = new NSRect();
    return this;
  }
  
  public function createMovieClips():Void {
    super.createMovieClips();
    if (m_mcBounds) {
      //trace("here");
      //m_mcBounds.cacheAsBitmap = true;
    }
  }
  
  //******************************************************
  //*            Setting the document view
  //******************************************************
  
  public function setDocumentView(view:NSView):Void {
    var nc:NSNotificationCenter;
    if (view == m_documentView) {
      return;
    }
    nc = NSNotificationCenter.defaultCenter();
    if (m_documentView) {
      nc.removeObserverNameObject(this, null, m_documentView);
      m_documentView.removeFromSuperview();
    }
    m_documentView = view;
    m_passiveDocument = true;
    if (m_documentView != null) {
      //
      // Determine if we're dealing with an active document
      //
      if (ASUtils.respondsToSelector(m_documentView, "isActiveScrollDocument")
          && ASUtils.respondsToSelector(m_documentView, "scrollingFrame")) {
        m_passiveDocument = false;
        m_docRect = m_documentView["scrollingFrame"]();
      }
      
      var docFrm:NSRect;
      addSubview(m_documentView);
      docFrm = documentRect();
      setBoundsOrigin(docFrm.origin);
      if (!m_passiveDocument) {
        m_activeBounds.origin = docFrm.origin;
        m_activeBounds.size = m_bounds.size.clone();
      }
      if (typeof(m_documentView["backgroundColor"])=="function") {
        m_backgroundColor = m_documentView["backgroundColor"].call(
          m_documentView);
      }
      if (typeof(m_documentView["drawsBackground"])=="function") {
        m_drawsBackground = m_documentView["drawsBackground"].call(
          m_documentView);
      }
      if (m_passiveDocument) {
        m_documentView.setPostsFrameChangedNotifications(true);
        m_documentView.setPostsBoundsChangedNotifications(true);
      }
      nc.addObserverSelectorNameObject(this, "viewFrameChanged", 
        NSView.NSViewFrameDidChangeNotification, m_documentView);
      nc.addObserverSelectorNameObject(this, "viewBoundsChanged", 
        NSView.NSViewBoundsDidChangeNotification, m_documentView);
    }
    
    NSScrollView(superview()).reflectScrolledClipView(this);
  }
  
  public function documentView():NSView {
    return m_documentView;
  }
  
  //******************************************************
  //*                  Scrolling
  //******************************************************
  
  /**
   * <p>Changes the origin of the receiver’s bounds rectangle to 
   * <code>newOrigin</code>.</p>
   * 
   * @see #contrainScrollPoint()
   */
  public function scrollToPoint(newOrigin:NSPoint):Void {
    newOrigin = constrainScrollPoint(newOrigin);
    setBoundsOrigin(newOrigin);
  }
  
  /**
   * <p>Returns a scroll point adjusted from <code>proposedNewOrigin</code>, if
   * necessary, to guarantee the receiver will still lie within its document
   * view.</p>
   * 
   * <p>For example, if <code>proposedNewOrigin</code>’s y coordinate lies to 
   * the left of the document view’s origin, then the y coordinate returned is
   * set to that of the document view’s origin.</p>
   * 
   * @see #scrollToPoint()
   */
  public function constrainScrollPoint(proposedNewOrigin:NSPoint):NSPoint {
    var newPoint:NSPoint = proposedNewOrigin.clone();
    if (m_documentView == null) {
      return null;
    }
    var documentFrame:NSRect = documentRect();
    var bnds:NSRect = bounds();
    
    if (documentFrame.size.width <= bnds.size.width) {
      newPoint.x = documentFrame.origin.x;
    } else if (proposedNewOrigin.x <= documentFrame.origin.x) {
      newPoint.x = documentFrame.origin.x;
    } else if ((proposedNewOrigin.x + bnds.size.width) >= documentFrame.maxX()) {
      newPoint.x = documentFrame.maxX() - bnds.size.width;
    }
    
    if (documentFrame.size.height <= bnds.size.height) {
      newPoint.y = documentFrame.origin.y;
    } else if (proposedNewOrigin.y <= documentFrame.origin.y) {
      newPoint.y = documentFrame.origin.y;
    } else if ((proposedNewOrigin.y + bnds.size.height) >= documentFrame.maxY()) {
      newPoint.y = documentFrame.maxY() - bnds.size.height;
    }
    
    return newPoint;
  }

  //******************************************************
  //*          Determining scrolling efficiency
  //******************************************************
  
  public function setCopiesOnScroll(value:Boolean):Void {
    m_copiesOnScroll = value;
  }
  
  public function copiesOnScroll():Boolean {
    return m_copiesOnScroll;
  }
  
  public function setSmoothScrollingEnabled(value:Boolean):Void {
    m_smoothScrollingEnabled = value;
  }

  public function smoothScrollingEnabled():Boolean {
    return m_smoothScrollingEnabled;
  }
  
  public function setCachingEnabled(value:Boolean):Void {
    //! FIXME This doesn't work properly with scrolling textfields.
    if (m_smoothScrollingEnabled) {
      m_mcBounds.cacheAsBitmap = value;
    }
  }
  

  //******************************************************
  //*            Getting the visible portion
  //******************************************************
  
  /**
   * <p>
   * Returns the rectangle defining the document view’s frame, adjusted to the 
   * size of the receiver if the document view is smaller.
   * </p>
   * <p>
   * In other words, this rectangle is always at least as large as the 
   * receiver itself.
   * </p>
   * <p>
   * The document rectangle is used in conjunction with an NSClipView’s bounds 
   * rectangle to determine values for the indicators of relative position and 
   * size between the NSClipView and its document view. For example, 
   * NSScrollView uses these rectangles to set the size and position of the 
   * knobs in its scrollers. When the document view is much larger than the 
   * NSClipView, the knob is small; when the document view is near the same 
   * size, the knob is large; and when the document view is the same size or 
   * smaller, there is no knob.
   * </p>
   * 
   * @see #documentVisibleRect()
   */
  public function documentRect():NSRect {
    if (m_documentView == null) {
      return m_bounds;
    }
    var documentFrame:NSRect = m_passiveDocument ? m_documentView.frame() 
    	: m_docRect;
    var bnds:NSRect = bounds();
    return new NSRect(documentFrame.origin.x, documentFrame.origin.y, 
      Math.max(documentFrame.size.width, bnds.size.width), 
      Math.max(documentFrame.size.height, bnds.size.height));
  }
  
  /**
   * <p>
   * Returns the exposed rectangle of the receiver’s document view, in the 
   * document view’s own coordinate system.
   * </p>
   * 
   * @see #documentRect()
   */
  public function documentVisibleRect():NSRect {
    if (m_documentView == null) {
      return NSRect.ZeroRect;
    }
    
    var db:NSRect;
    var cvb:NSRect = m_bounds;
    if (m_passiveDocument) {
      db = m_documentView.bounds();
      cvb = convertRectToView(m_bounds, m_documentView);
    } else {
      db = m_documentView["scrollingBounds"]();
      cvb.origin = m_documentView["convertExternalPointFromView"](m_bounds.origin, this);	
    } 
    
    return db.intersectionRect(cvb);
  }
  
  //******************************************************
  //*               Notification callbacks
  //******************************************************
  
  /**
   * This is fired when the boundary of this clip view's document view is
   * changed.
   */
  public function viewBoundsChanged(notification:NSNotification):Void {
    NSScrollView(superview()).reflectScrolledClipView(this);
  }

  /**
   * This is fired when the frame rectangle of this clip view's document view is
   * changed.
   */  
  public function viewFrameChanged(notification:NSNotification):Void {
  	//! FIXME There is a bug here.
  	if (!m_passiveDocument) {
  		m_activeBounds.origin = m_documentView["scrollPoint"]().clone();
  		m_docRect = m_documentView["scrollingFrame"]();
  	}
  	
  	var pt:NSPoint = constrainScrollPoint(bounds().origin);
    setBoundsOrigin(pt);
//    if (!m_documentView.frame().containsRect(m_bounds)) {
//      setNeedsDisplay();
//    }
    NSScrollView(superview()).reflectScrolledClipView(this);
  }

  //******************************************************
  //*          Working with background color
  //******************************************************
  
  public function drawsBackground():Boolean {
    return m_drawsBackground;
  }
  
  public function setDrawsBackground(value:Boolean):Void {
    if (m_drawsBackground != value) {
      m_drawsBackground = value;
      setNeedsDisplay(true);      
    }
  }
  
  public function setBackgroundColor(color:NSColor):Void {
    m_backgroundColor = color;
    setNeedsDisplay(true);
  }
  
  public function backgroundColor():NSColor {
    return m_backgroundColor;
  }

  //******************************************************
  //*               Overridden functions
  //******************************************************
  
  public function bounds():NSRect {
    if (m_passiveDocument) {
      return super.bounds();
    } else {
      return m_activeBounds;
    }
  }
  
  public function setBoundsOrigin(point:NSPoint):Void {
    if (point.isEqual(bounds().origin) || m_documentView == null) {
      return;
    }
        
    //
    // If we're an active document, move the document to compensate
    //
    if (!m_passiveDocument) {
      m_activeBounds.origin = point;
      var newOrigin:NSPoint = point.clone();
      //trace("table: " + newOrigin);
      m_documentView["scrollToPoint"](newOrigin);
    } else {
      //trace("header: " + point);
      super.setBoundsOrigin(point);
      m_documentView.setNeedsDisplay(true);
    }
    
    NSScrollView(m_superview).reflectScrolledClipView(this);
    
    //
    // This is here to allow the clip view to redraw it's background 
    // appropriately
    //
    if (m_drawsBackground) {
      setNeedsDisplay(true);
    } 
  }

  public function scaleUnitSquareToSize(size:NSSize):Void {
    super.scaleUnitSquareToSize(size);
    NSScrollView(m_superview).reflectScrolledClipView(this);
  }

  public function setBoundsSize(size:NSSize):Void {
    super.setBoundsSize(size);
    if (!m_passiveDocument) {
      m_activeBounds.size = size.clone();
    }
    NSScrollView(m_superview).reflectScrolledClipView(this);
  }

  public function setFrameSize(size:NSSize):Void {
    super.setFrameSize(size);
    if (!m_passiveDocument) {
      m_activeBounds.size = size.clone();
    }
    setBoundsOrigin(constrainScrollPoint(bounds().origin));
    NSScrollView(m_superview).reflectScrolledClipView(this);
  }

  public function setFrameOrigin(origin:NSPoint):Void {
    super.setFrameOrigin(origin);
    setBoundsOrigin(constrainScrollPoint(bounds().origin));
    NSScrollView(m_superview).reflectScrolledClipView(this);
  }

  public function setFrame(rect:NSRect):Void {
    super.setFrame(rect);
    setBoundsOrigin(constrainScrollPoint(bounds().origin));
    if (!m_passiveDocument) {
      m_activeBounds.size = rect.size.clone();
    }
    NSScrollView(m_superview).reflectScrolledClipView(this);
  }

  public function translateOriginToPoint(point:NSPoint):Void {
    super.translateOriginToPoint(point);
    NSScrollView(m_superview).reflectScrolledClipView(this);
  } 

  public function rotateByAngle(angle:Number):Void { 
    // IGNORE 
  } 

  public function setBoundsRotation(angle:Number):Void { 
    // IGNORE 
  } 

  public function setFrameRotation(angle:Number):Void { 
    // IGNORE 
  }

  public function acceptsFirstResponder():Boolean {
    if (m_documentView == null) {
      return false;
    } else {
      return m_documentView.acceptsFirstResponder();
    }
  }

  public function becomeFirstResponder():Boolean {
    if (m_documentView == null) {
      return false;
    } else {
      return m_window.makeFirstResponder(m_documentView);
    }
  }
  
  public function drawRect(rect:NSRect):Void {
    var g:ASGraphics = graphics();
    g.clear();
    if (m_drawsBackground) {
      g.brushDownWithBrush(m_backgroundColor);
      g.drawRectWithRect(rect);
      g.brushUp();
    }
  }

    
}