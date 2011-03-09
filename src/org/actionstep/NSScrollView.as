/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSRectEdge;
import org.actionstep.constants.NSScrollerPart;
import org.actionstep.NSClipView;
import org.actionstep.NSColor;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSScroller;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;

/**
 * <p>A view that displays scrollbars to scroll through a view.</p>
 * 
 * <p>For an example of this class' usage, please see
 * {@link org.actionstep.test.ASTestScrollView}.</p>
 * 
 * <p>Uses
 * {@link org.actionstep.ASThemeProtocol#drawScrollViewBorderInRectWithViewBorderType}
 * to draw its border.</p>
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSScrollView extends NSView {
  
  private var m_contentView:NSClipView;
  private var m_borderType:NSBorderType;
  private var m_horizontalScroller:NSScroller;
  private var m_verticalScroller:NSScroller;
  private var m_hasHorizontalScroller:Boolean;
  private var m_hasVerticalScroller:Boolean;
  private var m_autohidesScrollers:Boolean;
  private var m_scrollsDynamically:Boolean;
  private var m_horizontalLineScroll:Number;
  private var m_verticalLineScroll:Number;
  private var m_horizontalPageScroll:Number;
  private var m_verticalPageScroll:Number;
  private var m_knobMoved:Boolean;
  private var m_onlyIncrements:Boolean;
  private var m_ignoreNextUpdate:Boolean;
  
  //
  // Header and corner views.
  //
  private var m_hasHeaderView:Boolean;
  private var m_headerClipView:NSClipView;
  private var m_hasCornerView:Boolean;
  private var m_cornerView:NSView;
  
  //******************************************************
  //*                  Construction
  //******************************************************  
  
  /**
   * Initializes and returns the scroll view with a frame of 
   * {@link NSRect#ZeroRect}.
   */  
  public function init():NSScrollView {
    m_ignoreNextUpdate = false;
    return initWithFrame(NSRect.ZeroRect);
  }
  
  /**
   * Initializes and returns the scroll view with a frame of <code>rect</code>.
   */
  public function initWithFrame(rect:NSRect):NSScrollView {
    super.initWithFrame(rect);
    m_borderType = NSBorderType.NSNoBorder;
    m_autohidesScrollers = false;
    m_horizontalLineScroll = 10;
    m_verticalLineScroll = 10;
    m_horizontalPageScroll = 100;
    m_verticalPageScroll = 100;
    m_scrollsDynamically = true;
    m_hasHeaderView = false;
    m_hasCornerView = false;
    m_onlyIncrements = false;
    setContentView((new NSClipView()).init()); // this results in a tile
    return this;
  }
  
  //******************************************************
  //*              Describing the object
  //******************************************************
  
  /**
   * Returns a string representation of the NSScrollView instance.
   */
  public function description():String {
  	return "NSScrollView(contentSize=" + contentSize() 
  	  + ", drawsBackground=" + drawsBackground() + ")";
  }
  
  //******************************************************
  //*            Determining component sizes
  //******************************************************
  
  /**
   * Returns the size of the content view.
   */
  public function contentSize():NSSize {
    return m_contentView.bounds().size;
  }
  
  /**
   * Returns the rectangle of the document view that is currently visible, in
   * its own coordinate system. 
   */
  public function documentVisibleRect():NSRect {
    return m_contentView.documentVisibleRect();
  }
  
  //******************************************************
  //*           Managing graphics attributes
  //******************************************************
  
  /**
   * <p>Sets the background color of the scrollview to <code>color</code>.</p>
   * 
   * <p>This color is used to draw the portions of the content view that are not
   * covered by the document view.</p>
   */
  public function setBackgroundColor(color:NSColor):Void {
    m_contentView.setBackgroundColor(color);
  }
  
  /**
   * Returns the background color of the scroll view.
   */
  public function backgroundColor():NSColor {
    return m_contentView.backgroundColor();
  }
  
  /**
   * Returns <code>true</code> if the scrollview draws its background color.
   * 
   * @see #backgroundColor
   */
  public function drawsBackground():Boolean {
    return m_contentView.drawsBackground();
  }

  /**
   * Sets whether the scroll view draws its background color.
   */
  public function setDrawsBackground(value:Boolean):Void {
    m_contentView.setDrawsBackground(value);
  }
  
  /**
   * Sets the border type of the scroll view to <code>value</code>.
   */
  public function setBorderType(value:NSBorderType):Void {
    m_borderType = value;
    tile();
  }
  
  /**
   * Returns the border type of the scroll view.
   */
  public function borderType():NSBorderType {
    return m_borderType;
  }
  
  //******************************************************
  //*           Managing the scrolled views
  //******************************************************
  
  /**
   * <p>Sets the content of the <code>NSScrollView</code>, which is the view 
   * that clips the document view. If view has a document view, it becomes the 
   * scrollview's {@link #documentView}.</p>
   * 
   * <p>This is set to an {@link NSClipView} by default.</p>
   * 
   * @see #contentView
   * @see #documentView
   */
  public function setContentView(view:NSClipView):Void {
    if (view == null || !(view instanceof NSView)) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        "NSInvalidArgumentException",
        "You cannot set a content view to anything other than an NSView",
        null);
      trace(e);
      throw e;
    }
    if (view != m_contentView) {
      var docView:NSView = view.documentView();
      m_contentView.removeFromSuperview();
      m_contentView = view;
      addSubview(m_contentView);
      if (docView != null) {
        setDocumentView(docView);
      }
    }
    m_contentView.setAutoresizingMask(
      NSView.WidthSizable 
      | NSView.HeightSizable);
    tile();
  }
  
  /**
   * <p>Returns the content of the <code>NSScrollView</code>, which is the view 
   * that clips the document view.</p>
   * 
   * <p>This is set to an {@link NSClipView} by default.</p>
   * 
   * @see #setContentView
   */
  public function contentView():NSClipView {
    return m_contentView;
  }
  
  /**
   * Sets the view that is scrolled within the <code>NSScrollView</code>.
   * 
   * @see #documentView
   */
  public function setDocumentView(view:NSView):Void {
    m_contentView.setDocumentView(view);
    tile();
  }
  
  /**
   * Returns the view that is scrolled within the <code>NSScrollView</code>.
   * 
   * @see #setDocumentView
   */
  public function documentView():NSView {
    return m_contentView.documentView();
  }

  //******************************************************
  //*                Managing scrollers
  //******************************************************

  /**
   * Sets the horizontal scroller to <code>scroller</code> and establishes the
   * necessary target actions.
   */
  public function setHorizontalScroller(scroller:NSScroller):Void {
    if (m_horizontalScroller != null) {
      m_horizontalScroller.removeFromSuperview();
    }
    m_horizontalScroller = scroller;
    if (m_horizontalScroller != null) {
      m_horizontalScroller.setAutoresizingMask(NSView.WidthSizable);
      m_horizontalScroller.setTarget(this);
      m_horizontalScroller.setAction("scrollAction");
      m_horizontalScroller.setDelegate(this);
    }  
  }
  
  /**
   * Returns the horizontal scroller used by the scroll view.
   */
  public function horizontalScroller():NSScroller {
    return m_horizontalScroller;
  }
  
  /**
   * Sets whether the scroll view displays a horizontal scroller to
   * <code>value</code>.
   */
  public function setHasHorizontalScroller(value:Boolean):Void {
    if (m_hasHorizontalScroller == value) {
      return;
    }
    m_hasHorizontalScroller = value;
    if (m_hasHorizontalScroller) {
      if (m_horizontalScroller == null) {
        setHorizontalScroller((new NSScroller()).init());
      }
      addSubview(m_horizontalScroller);
    } else {
      m_horizontalScroller.removeFromSuperview();
    }
    tile();
  }
  
  /**
   * Returns <code>true</code> if the scroll view has a horizontal scroller.
   */
  public function hasHorizontalScroller():Boolean {
    return m_hasHorizontalScroller;
  }

  /**
   * Sets the vertical scroller to <code>scroller</code> and establishes the
   * necessary target actions.
   */
  public function setVerticalScroller(scroller:NSScroller):Void {
    if (m_verticalScroller != null) {
      m_verticalScroller.removeFromSuperview();
    }
    m_verticalScroller = scroller;
    if (m_verticalScroller != null) {
      m_verticalScroller.setAutoresizingMask(NSView.WidthSizable);
      m_verticalScroller.setTarget(this);
      m_verticalScroller.setAction("scrollAction");
      m_verticalScroller.setDelegate(this);
    }  
  }

  /**
   * Returns the vertical scroller used by the scroll view.
   */
  public function verticalScroller():NSScroller {
    return m_verticalScroller;
  }

  /**
   * Sets whether the scroll view has a vertical scroller to <code>value</code>.
   */
  public function setHasVerticalScroller(value:Boolean):Void {
    if (m_hasVerticalScroller == value) {
      return;
    }
    m_hasVerticalScroller = value;
    if (m_hasVerticalScroller) {
      if (m_verticalScroller == null) {
        setVerticalScroller((new NSScroller()).init());
      }
      addSubview(m_verticalScroller);
    } else {
      m_verticalScroller.removeFromSuperview();
    }
    tile();
  }

  /**
   * Returns <code>true</code> if the scroll view displays a vertical scroller.
   */
  public function hasVerticalScroller():Boolean {
    return m_hasVerticalScroller;
  }
  
  /**
   * Sets whether the scroll view hides the scrollers when not necessary.
   */
  public function setAutohidesScrollers(value:Boolean):Void {
    if (m_autohidesScrollers == value) {
      return;
    }
    m_autohidesScrollers = value;
    tile();
  }
  
  /**
   * Returns <code>true</code> if the scroll view hides the scrollers when they
   * are not necessary.
   */
  public function autohidesScrollers():Boolean {
    return m_autohidesScrollers;
  }
  
  //******************************************************
  //*                 Managing rulers
  //******************************************************
  
  //! TODO + (void)setRulerViewClass:(Class)aClass
  //! TODO + (Class)rulerViewClass
  //! TODO - (void)setHasHorizontalRuler:(BOOL)flag
  //! TODO - (BOOL)hasHorizontalRuler
  //! TODO - (void)setHorizontalRulerView:(NSRulerView *)aRulerView
  //! TODO - (NSRulerView *)horizontalRulerView
  //! TODO - (void)setHasVerticalRuler:(BOOL)flag
  //! TODO - (BOOL)hasVerticalRuler
  //! TODO - (void)setVerticalRulerView:(NSRulerView *)aRulerView
  //! TODO - (NSRulerView *)verticalRulerView
  //! TODO - (void)setRulersVisible:(BOOL)flag
  //! TODO - (BOOL)rulersVisible
  
  //******************************************************
  //*             Setting scrolling behavior
  //******************************************************
  
  /**
   * <p>Sets whether bitmap caching is used on the document view while scrolling
   * to <code>value</code>.</p>
   * 
   * <p>This has been known to cause problems when the document view contains
   * textfields with un-embedded fonts.</p>
   * 
   * <p>This method is ActionStep-only.</p>
   * 
   * @see #smoothScrollingEnabled
   */
  public function setSmoothScrollingEnabled(value:Boolean):Void {
    m_contentView.setSmoothScrollingEnabled(value);
  }
  
  /**
   * Returns <code>true</code> if bitmap caching is used on the document view
   * while scrolling.
   * 
   * @see #setSmoothScrollingEnabled
   */
  public function smoothScrollingEnabled():Boolean {
    return m_contentView.smoothScrollingEnabled();
  }
  
  /**
   * <p>Sets whether the scroll view only scrolls by increments of
   * {@link #lineScroll()}.</p>
   */
  public function setScrollsByLineIncrementsOnly(flag:Boolean):Void {
    m_onlyIncrements = flag;
  }
  
  /**
   * <p>Returns whether the scroll view only scrolls by increments of
   * {@link #lineScroll()}.</p>
   */
  public function scrollByLineIncrementsOnly():Boolean {
    return m_onlyIncrements;
  }
  
  /**
   * <p>Sets the horizontal and vertical line scroll amounts to <code>value</code>.</p>
   * 
   * <p>A line scroll is the amount the scroll view scrolls the document view by
   * when the user clicks a scroll arrow without any modifier keys pressed.</p>
   * 
   * @see #lineScroll
   */
  public function setLineScroll(value:Number):Void {
    m_horizontalLineScroll = value;
    m_verticalLineScroll = value;
  }
  
  /**
   * <p>Returns the line scroll amount.</p>
   * 
   * <p>This method throws an {@link NSException} if the horizontal and 
   * vertical line scroll amounts differ. Use {@link #horizontalLineScroll}
   * or {@link #verticalLineScroll} to access the values independently.</p>
   * 
   * @see #setLineScroll
   */
  public function lineScroll():Number {
    if (m_horizontalLineScroll != m_verticalLineScroll) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        NSException.NSGeneric,
        "Horizontal and vertical line scroll values are not the same",
        null);
      trace(e);
      throw e;
    }
    return m_horizontalLineScroll;
  }
  
  /**
   * <p>Sets the horizontal line scroll amounts to <code>value</code>.</p>
   * 
   * <p>A line scroll is the amount the scroll view scrolls the document view by
   * when the user clicks a scroll arrow without any modifier keys pressed.</p>
   * 
   * @see #horizontalLineScroll
   */
  public function setHorizontalLineScroll(value:Number):Void {
    m_horizontalLineScroll = value;
  }
  
  /**
   * Returns the horizontal line scroll amount.
   * 
   * @see #setHorizontalLineScroll
   */
  public function horizontalLineScroll():Number {
    return m_horizontalLineScroll;
  }
  
  /**
   * <p>Sets the vertical line scroll amounts to <code>value</code>.</p>
   * 
   * <p>A line scroll is the amount the scroll view scrolls the document view by
   * when the user clicks a scroll arrow without any modifier keys pressed.</p>
   * 
   * @see #verticalLineScroll
   */
  public function setVerticalLineScroll(value:Number):Void {
    m_verticalLineScroll = value;
  }
  
  /**
   * Returns the vertical line scroll amount.
   * 
   * @see #setVerticalLineScroll
   */
  public function verticalLineScroll():Number {
    return m_verticalLineScroll;
  }

  /**
   * <p>Sets the horizontal and vertical page scroll amounts to <code>value</code>.</p>
   * 
   * <p>The page scroll is the amount the scroll view scrolls the document view by
   * when the user clicks a scroll arrow with the Ctrl key held (Option on Mac).</p>
   * 
   * @see #pageScroll
   */
  public function setPageScroll(value:Number):Void {
    m_horizontalPageScroll = value;
    m_verticalPageScroll = value;
  }

  /**
   * <p>Returns the page scroll amount.</p>
   * 
   * <p>This method throws an {@link NSException} if the horizontal and 
   * vertical page scroll amounts differ. Use {@link #horizontalPageScroll}
   * or {@link #verticalPageScroll} to access the values independently.</p>
   * 
   * @see #setPageScroll
   */
  public function pageScroll():Number {
    if (m_horizontalPageScroll != m_verticalPageScroll) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        NSException.NSGeneric,
        "Horizontal and vertical page scroll values are not the same",
        null);
      trace(e);
      throw e;
    }
    return m_horizontalPageScroll;
  }

  /**
   * <p>Sets the horizontal page scroll amounts to <code>value</code>.</p>
   * 
   * <p>The page scroll is the amount the scroll view scrolls the document view by
   * when the user clicks a scroll arrow with the Ctrl key held (Option on Mac).</p>
   * 
   * @see #horizontalPageScroll
   */
  public function setHorizontalPageScroll(value:Number):Void {
    m_horizontalPageScroll = value;
  }

  /**
   * Returns the horizontal page scroll amount.
   * 
   * @see #setHorizontalPageScroll
   */
  public function horizontalPageScroll():Number {
    return m_horizontalPageScroll;
  }

  /**
   * <p>Sets the vertical page scroll amounts to <code>value</code>.</p>
   * 
   * <p>The page scroll is the amount the scroll view scrolls the document view by
   * when the user clicks a scroll arrow with the Ctrl key held (Option on Mac).</p>
   * 
   * @see #verticalPageScroll
   */
  public function setVerticalPageScroll(value:Number):Void {
    m_verticalPageScroll = value;
  }

  /**
   * Returns the vertical page scroll amount.
   * 
   * @see #setVerticalPageScroll
   */
  public function verticalPageScroll():Number {
    return m_verticalPageScroll;
  }
  
  /**
   * Determines whether the receiver redraws its document view while 
   * scrolling continuously. 
   */
  public function setScrollsDynamically(value:Boolean):Void {
    if (m_scrollsDynamically == value) {
      return;
    }
    m_scrollsDynamically = value;
  }
  
  /**
   * Returns <code>true</code> if the receiver redraws its document view while 
   * tracking the knob, <code>false</code> if it redraws only when the scroller 
   * knob is released.
   */
  public function scrollsDynamically():Boolean {
    return m_scrollsDynamically;
  }
  
  //******************************************************
  //*        Determining whether we are scrolling
  //******************************************************
  
  /**
   * Returns true if the scroll view is scrolling.
   */
  public function isScrolling():Boolean {
    return (m_hasVerticalScroller && m_verticalScroller.isScrolling()) 
    	|| (m_hasVerticalScroller && m_horizontalScroller.isScrolling());
  }
  
  //******************************************************
  //*           Working with the NSScrollers
  //******************************************************
  
  /**
   * Called by the scroller when a knob scroll begins. 
   */
  private function scrollerBeginKnobScroll(scroller:NSScroller):Void {
    m_contentView.setCachingEnabled(true);
  }

  /**
   * Called by the scroller when knob scrolling ends.
   */
  private function scrollerEndKnobScroll(scroller:NSScroller):Void {
    m_contentView.setCachingEnabled(false);
  }
  
  /**
   * Callback from NSScroller in target/action
   */
  private function scrollAction(scroller:NSScroller):Void {
    var floatValue:Number = scroller.floatValue();
    var hitPart:NSScrollerPart = scroller.hitPart();
    var clipViewBounds:NSRect;
    var documentRect:NSRect;
    var amount:Number = 0;
    var point:NSPoint;
    
    if (m_contentView == null) {
      clipViewBounds = NSRect.ZeroRect;
      documentRect = NSRect.ZeroRect;
    } else {
      clipViewBounds = m_contentView.bounds();
      documentRect = m_contentView.documentRect();
    }
    point = clipViewBounds.origin.clone();
    
    if (scroller != m_verticalScroller && scroller != m_horizontalScroller) {
      //Unknown scroller
      return; 
    }
    
    m_knobMoved = false;
    switch(hitPart) {
      case NSScrollerPart.NSScrollerKnob:
      case NSScrollerPart.NSScrollerKnobSlot:
        m_knobMoved = true;
        break;
      case NSScrollerPart.NSScrollerIncrementPage:
        if (scroller == m_horizontalScroller) {
          amount = m_horizontalPageScroll;
        } else {
          amount = m_verticalPageScroll;
        }
        break;
      case NSScrollerPart.NSScrollerIncrementLine:
        if (scroller == m_horizontalScroller) {
          amount = m_horizontalLineScroll;
        } else {
          amount = m_verticalLineScroll;
        }
        break;
      case NSScrollerPart.NSScrollerDecrementPage:
        if (scroller == m_horizontalScroller) {
          amount = -m_horizontalPageScroll;
        } else {
          amount = -m_verticalPageScroll;
        }
        break;
      case NSScrollerPart.NSScrollerDecrementLine:
        if (scroller == m_horizontalScroller) {
          amount = -m_horizontalLineScroll;
        } else {
          amount = -m_verticalLineScroll;
        }
        break;
      default:
        return;
    }
    if (!m_knobMoved) {
      if (scroller == m_horizontalScroller) {
        point.x = clipViewBounds.origin.x + amount;
      } else {
        point.y = clipViewBounds.origin.y + amount;
      }
    } else {
      if (scroller == m_horizontalScroller) {
        point.x = floatValue * (documentRect.size.width - clipViewBounds.size.width);
        point.x += documentRect.origin.x;
      } else {
        point.y = floatValue * (documentRect.size.height - clipViewBounds.size.height);
        point.y += documentRect.origin.y;
      }
    }
    
    if (m_onlyIncrements) {
      var yLines:Number = Math.floor(point.y / m_verticalLineScroll);
      var yRem:Number = point.y % m_verticalLineScroll;
      if ((yRem / (m_verticalLineScroll / 2)) > 1) {
        point.y = (yLines + 1) * m_verticalLineScroll;
      } else {
        point.y = yLines * m_verticalLineScroll;
      }
      
      var xLines:Number = Math.floor(point.x / m_horizontalLineScroll);
      var xRem:Number = point.x % m_horizontalLineScroll;
      if ((xRem / (m_horizontalLineScroll / 2)) > 1) {
        point.x = (xLines + 1) * m_horizontalLineScroll;
      } else {
        point.x = xLines * m_horizontalLineScroll;
      }
    }
    
    m_ignoreNextUpdate = m_knobMoved;
    m_contentView.scrollToPoint(point);
    m_ignoreNextUpdate = true;
    m_headerClipView.scrollToPoint(new NSPoint(point.x, 0));
  }
   
  //******************************************************
  //*          Updating display after scrolling
  //******************************************************
  
  /**
   * <p>If <code>view</code> is the scroll view’s content view, adjusts the 
   * scrollers to reflect the size and positioning of its document view. 
   * Does nothing if <code>view</code> is any other view object (in particular, 
   * if it’s an {@link NSClipView} that isn’t the content view).</p>
   * 
   * <p>Called automatically during scroll operations.</p>
   */
  public function reflectScrolledClipView(view:NSView):Void {
  	if (m_ignoreNextUpdate) {
  		m_ignoreNextUpdate = false;
  		return;
  	}
  	
    var documentFrame:NSRect = NSRect.ZeroRect;
    var headerFrame:NSRect = NSRect.ZeroRect;
    var clipViewBounds:NSRect = NSRect.ZeroRect;
    var headerViewBounds:NSRect = NSRect.ZeroRect;
    var floatValue:Number = 0;
    var knobProportion:Number = 0;
    var documentView:NSView;
    var headerView:NSView;
    
    if (view != m_contentView && view != m_headerClipView) {
      return;
    }
    
    if (m_contentView != null) {
      clipViewBounds = m_contentView.bounds();
      documentView = m_contentView.documentView();
    }
    
    if (m_headerClipView != null) {
      headerViewBounds = m_headerClipView.bounds();
      headerView = m_headerClipView.documentView();
    }
        
    if (documentView != null) {
      documentFrame = m_contentView.documentRect();
    }
    
    if (headerView != null) {
      headerFrame = headerView.frame();
    }
    
    if (m_hasVerticalScroller) {
      if (documentFrame.size.height <= clipViewBounds.size.height) {
        m_verticalScroller.setEnabled(false);
      } else {
        m_verticalScroller.setEnabled(true);
        knobProportion = clipViewBounds.size.height / documentFrame.size.height;
        floatValue = (clipViewBounds.origin.y - documentFrame.origin.y) /
                     (documentFrame.size.height - clipViewBounds.size.height);
        m_verticalScroller.setFloatValueKnobProportion(floatValue, knobProportion);   
        m_verticalScroller.setNeedsDisplay(true);
      }
    }
    if (m_hasHorizontalScroller) {      
      if (headerFrame.size.width > headerViewBounds.size.width 
          && headerFrame.size.width >= documentFrame.size.width) {
        m_horizontalScroller.setEnabled(true);
        knobProportion = headerViewBounds.size.width / headerFrame.size.width;
        floatValue = (headerViewBounds.origin.x - headerFrame.origin.x) /
                     (headerFrame.size.width - headerViewBounds.size.width);
        m_horizontalScroller.setFloatValueKnobProportion(floatValue, knobProportion);          
        m_horizontalScroller.setNeedsDisplay(true);
      }
      else if (documentFrame.size.width > clipViewBounds.size.width 
          && documentFrame.size.width > headerFrame.size.width) {
        m_horizontalScroller.setEnabled(true);
        knobProportion = clipViewBounds.size.width / documentFrame.size.width;
        floatValue = (clipViewBounds.origin.x - documentFrame.origin.x) /
                     (documentFrame.size.width - clipViewBounds.size.width);
        m_horizontalScroller.setFloatValueKnobProportion(floatValue, knobProportion);          
        m_horizontalScroller.setNeedsDisplay(true);
      } else {
        m_horizontalScroller.setEnabled(false);
      }
    }
    
    m_window.invalidateCursorRectsForView(m_contentView.documentView());
    m_window.invalidateCursorRectsForView(m_headerClipView.documentView());
  }
  
  //******************************************************
  //*                Arranging components
  //******************************************************
  
  /**
   * Lays out the children of the scroll view.
   */
  public function tile():Void {  	  	
    var contentRect:NSRect;
    var vScrollerRect:NSRect;
    var hScrollerRect:NSRect;
    var headerRect:NSRect = NSRect.ZeroRect;
    var topEdge:NSRectEdge = NSRectEdge.NSMinYEdge;
    var bottomEdge:NSRectEdge = NSRectEdge.NSMaxYEdge;
    var headerViewHeight:Number = 0;
    var scrollerWidth:Number = NSScroller.scrollerWidth();
        
    //
    // Inset for the borders
    //      
    contentRect = m_bounds.insetRect(m_borderType.size.width, 
      m_borderType.size.height);
    
    //
    // Deal with header / corner views
    //
    synchronizeHeaderAndCornerView();
    
    if (m_hasHeaderView) {
      headerViewHeight = m_headerClipView.documentView().frame().size.height;
    }
    
    if (m_hasCornerView) {
      if (headerViewHeight == 0) {
        headerViewHeight = m_cornerView.frame().size.height;
      }
    }
        
    //
    // Determine the respective sizes of the content and header views
    //
    NSRect.divideRect(contentRect, headerRect, contentRect, headerViewHeight,
      topEdge);
        
    //
    // Position scrollers
    //
    if (m_hasVerticalScroller) {
      if (m_hasHorizontalScroller) {
        vScrollerRect = new NSRect(contentRect.maxX() - scrollerWidth, 
          headerRect.minY(), scrollerWidth, 
          contentRect.size.height + headerRect.size.height - scrollerWidth);
        hScrollerRect = new NSRect(contentRect.minX(), 
          contentRect.maxY() - scrollerWidth, 
          contentRect.size.width - scrollerWidth, scrollerWidth);
        m_verticalScroller.setFrame(vScrollerRect);
        m_horizontalScroller.setFrame(hScrollerRect);
      } else {
        vScrollerRect = new NSRect(contentRect.maxX() - scrollerWidth, 
          contentRect.minY(), scrollerWidth, contentRect.size.height);
        m_verticalScroller.setFrame(vScrollerRect);
      }
    } else if (m_hasHorizontalScroller) {
      hScrollerRect = new NSRect(contentRect.minX(), 
        contentRect.maxY() - scrollerWidth, contentRect.size.width, 
        scrollerWidth);
      m_horizontalScroller.setFrame(hScrollerRect);
    }
    if (m_hasVerticalScroller) {
      contentRect.size.width  -= (vScrollerRect.size.width);
    }
    if (m_hasHorizontalScroller) {
      contentRect.size.height -= (hScrollerRect.size.height);
    }
    
    //
    // Position header and corner views
    //
    if (m_hasHeaderView) {
      var rect:NSRect = headerRect.clone();
      rect.origin.x = contentRect.origin.x;
      rect.size.width = contentRect.size.width - NSScroller.scrollerWidth();
      
      //
      // Make it wider if there isn't a corner view.
      //
      if (!m_hasCornerView) {
        rect.size.width += NSScroller.scrollerWidth();
      }
      
      m_headerClipView.setFrame(rect);
    }
    
    if (m_hasCornerView) {
      m_cornerView.setFrame(NSRect.withOriginSize(
      	headerRect.origin.translate(contentRect.size.width, 0),
      	new NSSize(vScrollerRect.size.width, headerViewHeight)));
    }
    
    m_contentView.setFrame(contentRect);
    setNeedsDisplay(true);
  }
  
  //******************************************************
  //*                  Action methods
  //******************************************************
  
  /**
   * <p>Implemented by subclasses to scroll the receiver one line down in its 
   * scroll view, without changing the selection.</p>
   */
  public function scrollLineDown(sender:Object):Void {
    scrollVerticallyByAmount(m_verticalLineScroll);
  }
  
  /**
   * <p>Implemented by subclasses to scroll the receiver one line up in its 
   * scroll view, without changing the selection.</p>
   */
  public function scrollLineUp(sender:Object):Void {
    scrollVerticallyByAmount(-m_verticalLineScroll);
  }
  
  /**
   * <p>Implemented by subclasses to scroll the receiver one page down in its 
   * scroll view, without changing the selection.</p>
   */
  public function scrollPageDown(sender:Object):Void {
    scrollVerticallyByAmount(m_verticalPageScroll);
  }
  
  /**
   * <p>Implemented by subclasses to scroll the receiver one page up in its 
   * scroll view, without changing the selection.</p>
   */
  public function scrollPageUp(sender:Object):Void {
    scrollVerticallyByAmount(-m_verticalPageScroll);
  }
  
  /**
   * <p>Calls {@link #scrollPageDown()} internally.</p>
   */
  public function pageDown(sender:Object):Void {
    // FIXME this should change selection
    scrollPageDown(sender);
  }
  
  /**
   * <p>Calls {@link #scrollPageUp()} internally.</p>
   */
  public function pageUp(sender:Object):Void {
    // FIXME this should change selection
    scrollPageUp(sender);
  }
 
  //******************************************************
  //*              Working with events
  //******************************************************
  
  /**
   * Responds to a scroll wheel event.
   */
  public function scrollWheel(event:NSEvent):Void {
    scrollVerticallyByAmount(-event.deltaY*m_verticalLineScroll);
  }
  
  /**
   * Responds to a key down event.
   */
  public function keyDown(event:NSEvent):Void {
    switch (event.keyCode) {
      case Key.PGUP:
        scrollPageUp(this);
        return;
        
      case Key.PGDN:
        scrollPageDown(this);
        return;
        
      case Key.UP:
        scrollLineUp(this);
        return;
        
      case Key.DOWN:
        scrollLineDown(this);
        return;
        
      case Key.LEFT:
      
        return;
        
      case Key.RIGHT:
        
        return;
    }
    
    super.keyDown(event);
  }
  
  //******************************************************
  //*                  Helper methods
  //******************************************************
  
  /**
   * Sets up or removes the header and corner views.
   */
  private function synchronizeHeaderAndCornerView():Void {
  	  	
    var hadHeaderView:Boolean = m_hasHeaderView;
    var hadCornerView:Boolean = m_hasCornerView;
    var aView:NSView = null;

    //
    // Deal with header view
    //    
    m_hasHeaderView = documentView().respondsToSelector("headerView") &&
      null != (aView = documentView()["headerView"]());
	
    if (m_hasHeaderView) {
      if (!hadHeaderView) { // Create header clip view if needed
        m_headerClipView = (new NSClipView()).init();
        addSubview(m_headerClipView);
      }
      
      m_headerClipView.setDocumentView(aView);
    }
    else if (hadHeaderView) { // Remove header clip view
      m_headerClipView.removeFromSuperview();
      m_headerClipView = null;
    }
    
    //
    // Deal with corner view
    //
    if (m_hasVerticalScroller) { // corner views appear above the vert scroller
      aView = null;
      m_hasCornerView = documentView().respondsToSelector("cornerView") &&
        null != (aView = documentView()["cornerView"]());
      
      if (aView == m_cornerView) { // no change, so return
        return;
      }
      
      if (m_hasCornerView) { // Add (or replace) the corner view
        if (!hadCornerView) {
          addSubview(aView);
        } else {
          replaceSubviewWith(m_cornerView, aView);
        }
      }
      else if (hadCornerView) { // Remove the current corner view
        m_cornerView.removeFromSuperview();
      }
      
      m_cornerView = aView;
    }
    else if (m_cornerView != null) { // no place to put it, so remove it
      m_cornerView.removeFromSuperview();
      m_cornerView = null;
      m_hasCornerView = false;
    }
  }
  
  /**
   * Scrolls the view vertically by the specified amount.
   */
  private function scrollVerticallyByAmount(amount:Number):Void {
    var clipViewBounds:NSRect;
    var documentRect:NSRect;
    var point:NSPoint;
    
    if (m_contentView == null) {
      clipViewBounds = NSRect.ZeroRect;
      documentRect = NSRect.ZeroRect;
    } else {
      clipViewBounds = m_contentView.bounds();
      documentRect = m_contentView.documentRect();
    }
    
    //
    // Calculate the point
    //
    point = clipViewBounds.origin.clone();
    point.y = clipViewBounds.origin.y + amount;
    
    //
    // Scroll the view
    //
    m_contentView.scrollToPoint(point);
  }
  
  /**
   * Scrolls the view horizontally by the specified amount.
   */
  private function scrollHorizontallyByAmount(amount:Number):Void {
    var clipViewBounds:NSRect;
    var documentRect:NSRect;
    var point:NSPoint;
    
    if (m_contentView == null) {
      clipViewBounds = NSRect.ZeroRect;
      documentRect = NSRect.ZeroRect;
    } else {
      clipViewBounds = m_contentView.bounds();
      documentRect = m_contentView.documentRect();
    }
    
    //
    // Calculate the point
    //
    point = clipViewBounds.origin.clone();
    point.x = clipViewBounds.origin.x + amount;
    
    //
    // Scroll the view
    //
    m_contentView.scrollToPoint(point);
  }
  
  //******************************************************
  //*                Overridden functions
  //******************************************************
  
  public function drawRect(rect:NSRect):Void {
    m_mcBounds.clear();
    
    ASTheme.current().drawScrollViewBorderInRectWithViewBorderType(rect, this,
      borderType());
  }
  
  public function willRemoveSubview(view:NSView):Void {
    if (view == m_contentView) {
      m_contentView = null;
    }
  }
  
  public function setFrame(rect:NSRect):Void {
    super.setFrame(rect);
    tile();
  }
  
  public function setFrameSize(size:NSSize):Void {
    super.setFrameSize(size);
    tile();
  }
  
  public function resizeSubviewsWithOldSize(size:NSSize):Void {
    super.resizeSubviewsWithOldSize(size);
    tile();
  }
  
  public function isOpaque():Boolean {
    return true;
  }
  
}