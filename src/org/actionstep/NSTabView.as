/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.constants.NSControlSize;
import org.actionstep.constants.NSControlTint;
import org.actionstep.constants.NSTabState;
import org.actionstep.constants.NSTabViewType;
import org.actionstep.NSArray;
import org.actionstep.NSButton;
import org.actionstep.NSColor;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSFont;
import org.actionstep.NSImage;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTabViewItem;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeImageNames;

/**
 * A tab view is a way of displaying multiple pages of data. These pages are
 * represented by {@link NSTabViewItem}s.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSTabView extends NSView {

  private var m_delegate:Object;
  private var m_selected:NSTabViewItem;
  private var m_selectedItem:Number;
  private var m_items:NSArray;
  private var m_font:NSFont;
  private var m_fontColor:NSColor;
  private var m_tabViewType:NSTabViewType;
  private var m_controlTint:NSControlTint;
  private var m_drawsBackground:Boolean;
  private var m_controlSize:NSControlSize;
  private var m_allowsTruncatedLabels:Boolean;
  
  private var m_scrollIndex:Number;
  private var m_visibleTabs:Number;
  private var m_isScrollable:Boolean;
  private var m_scrollLeft:NSButton;
  private var m_scrollRight:NSButton;
  private var m_scrollTabItem:NSTabViewItem;
  private var m_scrollTabItemSize:NSSize;
  private var m_buttonSize:Number;
  private var m_tabSpacing:Number;
  
  //******************************************************															 
  //*                  Construction
  //******************************************************
  
  /**
   * Creates a new instance of the <code>NSTabView</code> class.
   * 
   * Construction should be followed by either <code>#initWithFrame</code> or 
   * <code>#init</code>.
   */
  public function NSTabView() {
    m_items = new NSArray();
    m_font = ASTheme.current().messageFontOfSize(0);
    m_fontColor = ASTheme.current().systemFontColor();
    m_drawsBackground = true;
    m_controlSize = NSControlSize.NSRegularControlSize;
    m_tabViewType = NSTabViewType.NSTopTabsBezelBorder;
    m_allowsTruncatedLabels = false;
    m_isScrollable = false;
    m_scrollIndex = 0;
    m_tabSpacing = 3;
  }
  
  /**
   * Initializes the tab view with an origin of <code>point</code> and a
   * frame will completely display any content of <code>contentSize</code>. 
   */
  public function initWithOriginContentSize(point:NSPoint, contentSize:NSSize):NSTabView {
  	var frm:NSRect = NSRect.ZeroRect;
  	frm.origin = point;
  	frm.size = frameSizeForContentSize(contentSize);
  	
    return NSTabView(super.initWithFrame(frm));
  }
  
  //******************************************************															 
  //*             Adding and removing tabs
  //******************************************************
  
  /**
   * Adds the tab view item <code>item</code> to the right of all existing
   * tabs in this tab view.
   */
  public function addTabViewItem(item:NSTabViewItem):Void {
    insertTabViewItemAtIndex(item, m_items.count());
  }
  
  /**
   * Inserts the tab view item <code>item</code> into this tab view at
   * <code>index</code>.
   */
  public function insertTabViewItemAtIndex(item:NSTabViewItem, index:Number)
      :Void {
    item.setTabView(this);
    m_items.insertObjectAtIndex(item, index);
    addSubview(item.view());
    item.view().setHidden(true);
    if (m_delegate != null) {
      if(typeof(m_delegate["tabViewDidChangeNumberOfTabViewItems"]) == "function") {
        m_delegate["tabViewDidChangeNumberOfTabViewItems"].call(m_delegate, this);
      }
    }
  }
  
  /**
   * Removes the tab view item <code>item</code> from the tab view.
   */
  public function removeTabViewItem(item:NSTabViewItem):Void {
    var loc:Number = m_items.indexOfObject(item);
    
    if (loc == NSNotFound) {
      return;
    }
    if (item == m_selected) {
      if (m_selectedItem > 0) {
        selectTabViewItemAtIndex(m_selectedItem - 1);
      } else if (m_selectedItem < (m_items.count() -1)) {
        selectTabViewItemAtIndex(m_selectedItem + 1);
      } else {
        m_selected.setTabState(NSTabState.NSBackgroundTab);
        //m_selected.view().removeFromSuperview();
        m_selected = null;
        m_selectedItem = -1;
      }
    }
    item.view().removeFromSuperview();
    item.removeTextField();
    item.setTabView(null);
    m_items.removeObjectAtIndex(loc);
    if (m_delegate != null) {
      if(typeof(m_delegate["tabViewDidChangeNumberOfTabViewItems"]) == "function") {
        m_delegate["tabViewDidChangeNumberOfTabViewItems"].call(m_delegate, this);
      }
    }    
  }
  
  //******************************************************															 
  //*                Accessing tabs
  //******************************************************
  
  /**
   * Returns the index of the tab view item <code>item</code>, or 
   * <code>NSObject#NSNotFound</code> if <code>item</code> was not found.
   */
  public function indexOfTabViewItem(item:NSTabViewItem):Number {
    return m_items.indexOfObject(item);
  }
  
  /**
   * Returns the index of the tab view item with an identifier of 
   * <code>id</code>, or <code>NSObject#NSNotFound</code> if no item was found.
   * 
   * @see NSTabViewItem#identifier
   */
  public function indexOfTabViewItemWithIdentifier(id:Object):Number {
    var element:NSTabViewItem;
    var i:Number = 0;
    while ((element = NSTabViewItem(m_items.objectAtIndex(i)))!= null) {
      if (element.identifier() == id) {
        return i;
      }
      i++;
    }
    return NSNotFound;
  }
  
  /**
   * Returns the number of tab view items in this tab view.
   */
  public function numberOfTabViewItems():Number {
    return m_items.count();
  }
  
  /**
   * Returns the tab view item that can be found at <code>index</code>.
   */
  public function tabViewItemAtIndex(index:Number):NSTabViewItem {
    return NSTabViewItem(m_items.objectAtIndex(index));
  }
  
  /**
   * <p>Returns the receiver’s array of tab view items.</p>
   * 
   * <p>A tab view keeps an array containing one tab view item for each tab in 
   * the view.</p>
   */
  public function tabViewItems():NSArray {
    return m_items;
  }
  
  /**
   * Selects the first tab view item.
   */
  public function selectFirstTabViewItem(sender:Object) {
    selectTabViewItemAtIndex(0);
  }
  
  /**
   * Selects the last tab view item.
   */
  public function selectLastTabViewItem(sender:Object) {
    selectTabViewItem(NSTabViewItem(m_items.lastObject()));
  }
  
  /**
   * Selects the next tab view item (the one to the right of the currently 
   * selected item) if one exists.
   */
  public function selectNextTabViewItem(sender:Object) {
    if ((m_selectedItem+1) < m_items.count()) {
      selectTabViewItemAtIndex(m_selectedItem + 1);
    }
  }

  /**
   * Selects the previous tab view item (the one to the left of the currently 
   * selected item) if one exists.
   */
  public function selectPreviousTabViewItem(sender:Object) {
    if (m_selectedItem > 0) {
      selectTabViewItemAtIndex(m_selectedItem - 1);
    }
  }
  
  /**
   * Selects the tab view item <code>item</code>.
   */
  public function selectTabViewItem(item:NSTabViewItem) {
    if (m_delegate != null) {
      if(typeof(m_delegate["tabViewShouldSelectTabViewItem"]) == "function") {
        if (!m_delegate["tabViewShouldSelectTabViewItem"].call(m_delegate, this, item)) {
          return;
        }
      }
    }
    if (m_selected != null) {
      m_selected.setTabState(NSTabState.NSBackgroundTab);
      m_selected.view().setHidden(true);//.removeFromSuperview();
      m_selected.view().setNeedsDisplay(true);
    }
    
    m_selected = item;
    
    if(typeof(m_delegate["tabViewWillSelectTabViewItem"]) == "function") {
      m_delegate["tabViewWillSelectTabViewItem"].call(m_delegate, this, m_selected);
    }
    if (m_selected != null) {
      m_selectedItem = m_items.indexOfObject(m_selected);
      m_selected.setTabState(NSTabState.NSSelectedTab);
      var selectedView:NSView = m_selected.view();
      if (selectedView != null) {
        selectedView.setHidden(false);
        //addSubview(selectedView);
        selectedView.setFrame(contentRect());
        m_window.makeFirstResponder(m_selected.initialFirstResponder());
      }
    }
    setNeedsDisplay(true);
    
    if(typeof(m_delegate["tabViewDidSelectTabViewItem"]) == "function") {
      m_delegate["tabViewDidSelectTabViewItem"].call(m_delegate, this, m_selected);
    }
  }
  
  /**
   * Selects the tab view item at position <code>index</code>.
   */
  public function selectTabViewItemAtIndex(index:Number) {
    if (index < 0) {
      selectTabViewItem(null);
    } else {
      selectTabViewItem(NSTabViewItem(m_items.objectAtIndex(index)));
    }
  }
  
  /**
   * Returns the currently selected tab view item, or <code>null</code> if none
   * is selected.
   */
  public function selectedTabViewItem():NSTabViewItem {
    return m_selected;
  }
  
  //******************************************************															 
  //*           Modifying the frame rectangle
  //******************************************************
  
  public function setFrame(rect:NSRect) {
    super.setFrame(rect);
    var list:Array = m_items.internalList();
    for(var i:Number = 0;i<list.length;i++) {
      var v:NSView = NSTabViewItem(list[i]).view();
      v.setFrame(contentRect());
      v.setNeedsDisplay(true);
    }
  }

  public function setFrameSize(size:NSSize) {
    super.setFrameSize(size);
    var list:Array = m_items.internalList();
    for(var i:Number = 0;i<list.length;i++) {
      var v:NSView = NSTabViewItem(list[i]).view();
      v.setFrame(contentRect());
      v.setNeedsDisplay(true);
    }
  }
  
  //******************************************************															 
  //*                Setting the font
  //******************************************************
  
  /**
   * Sets the font used by tab item labels to <code>font</code>.
   */
  public function setFont(font:NSFont) {
    m_font = font;
  }
  
  /**
   * Returns the font used by tab item labels.
   */
  public function font():NSFont {
    return m_font;
  }
  
  /*
   * Sets the font color of the tab item labels to <code>color</code>.
   */
  public function setFontColor(color:NSColor) {
    m_fontColor = color;
  }
  
  /*
   * Returns the color used by the tab item labels.
   */
  public function fontColor():NSColor {
    return m_fontColor;
  }
  
  //******************************************************
  //*                Setting scrolling
  //******************************************************
  
  public function isScrollable():Boolean {
    return m_isScrollable;
  }
  
  public function setScrollable(flag:Boolean):Void {
    if (m_isScrollable == flag) {
      return;
    }
    
    m_isScrollable = flag;
    m_scrollIndex = 0;
    
    if (!m_isScrollable) {
      m_scrollLeft.removeFromSuperview();
      m_scrollRight.removeFromSuperview();
      m_scrollLeft.release();
      m_scrollRight.release();
      m_scrollLeft = null;
      m_scrollRight = null;
    } else {      
      m_buttonSize = ASTheme.current().tabHeight() - 1;
            
      m_scrollRight = (new NSButton()).initWithFrame(new NSRect(
        m_frame.size.width - m_buttonSize, 1,
        m_buttonSize, m_buttonSize));
      m_scrollRight.setAutoresizingMask(NSView.MinXMargin);
      m_scrollRight.setImage(NSImage.imageNamed(ASThemeImageNames.NSScrollerRightArrowImage));
      m_scrollRight.setImagePosition(NSCellImagePosition.NSImageOnly);
      m_scrollRight.setEnabled(false);
      m_scrollRight.setTarget(this);
      m_scrollRight.setAction("scrollRight");
      addSubview(m_scrollRight);
      
      m_scrollLeft = (new NSButton()).initWithFrame(new NSRect(
        m_scrollRight.frame().origin.x - m_buttonSize + 1, 1,
        m_buttonSize, m_buttonSize));
      m_scrollLeft.setAutoresizingMask(NSView.MinXMargin);
      m_scrollLeft.setImage(NSImage.imageNamed(ASThemeImageNames.NSScrollerLeftArrowImage));
      m_scrollLeft.setImagePosition(NSCellImagePosition.NSImageOnly);
      m_scrollLeft.setEnabled(false);
      m_scrollLeft.setTarget(this);
      m_scrollLeft.setAction("scrollLeft");
      addSubview(m_scrollLeft);
      
      m_scrollTabItem = (new NSTabViewItem()).initWithIdentifier("__scrollTab");
      m_scrollTabItem.setTabState(NSTabState.NSSelectedTab);
      m_scrollTabItemSize = new NSSize(m_buttonSize * 2 + 4, m_buttonSize + 2);
    }
  }
  
  /**
   * Scrolls the tabs to the left.
   */
  public function scrollLeft(sender:Object):Void {
    if (!m_isScrollable || m_scrollIndex == 0) {
      return;
    }
    
    m_scrollIndex--;
    setNeedsDisplay(true);
  }
  
  /**
   * Scrolls the tabs to the left.
   */
  public function scrollRight(sender:Object):Void {
    if (!m_isScrollable || m_scrollIndex + m_visibleTabs > m_items.count()) {
      return;
    }
    
    m_scrollIndex++;
    setNeedsDisplay(true);
  }
  
  //******************************************************															 
  //*              Modifying the tab type
  //******************************************************
  
  /**
   * Sets the type of this tab view to <code>type</code>. Types specify where
   * the tab items should be drawn and the border style.
   */
  public function setTabViewType(type:NSTabViewType) {
    m_tabViewType = type;
    setNeedsDisplay(true);
  }
  
  /**
   * Returns the type of this tab view.
   */
  public function tabViewType():NSTabViewType {
    return m_tabViewType;
  }
  
  //******************************************************															 
  //*             Manipulating the background
  //******************************************************
  
  /**
   * Returns <code>true</code> if the tab view draws a background, or
   * <code>false</code> otherwise.
   */
  public function drawsBackground():Boolean {
    return m_drawsBackground;
  }
  
  /**
   * Sets whether the tab view should draw a background. If <code>value</code>
   * is <code>true</code> a background will be drawn.
   */
  public function setDrawsBackground(value:Boolean) {
    m_drawsBackground = value;
  }
  
  //******************************************************															 
  //*               Determining the size
  //******************************************************
  
  public function minimumSize():NSSize {
    return NSSize.ZeroSize;
  }
  
  public function contentRect():NSRect {
  	var tabHeight:Number = ASTheme.current().tabHeight();
    var rect:NSRect = bounds();
    switch(m_tabViewType) {
    case NSTabViewType.NSBottomTabsBezelBorder:
    case NSTabViewType.NSTopTabsBezelBorder:
      rect.origin.y+=tabHeight+5;
      rect.size.height-=(tabHeight+10);
      rect.origin.x+=5;
      rect.size.width-=10;
      break;
    case NSTabViewType.NSNoTabsBezelBorder:
      rect.origin.y+=5;
      rect.size.height-=10;
      rect.origin.x+=5;
      rect.size.width-=10;
      break;
    case NSTabViewType.NSNoTabsLineBorder:
      rect.origin.y+=1;
      rect.size.height-=2;
      rect.origin.x+=1;
      rect.size.width-=2;
      break;
    case NSTabViewType.NSNoTabsNoBorder:
      break;
    }
    return rect;
  }
  
  public function controlSize():NSControlSize {
    return m_controlSize;
  }

  public function setControlSize(controlSize:NSControlSize) {
    m_controlSize = controlSize;
  }
  
  public function frameSizeForContentSize(contentSize:NSSize):NSSize {
    var tabHeight:Number = ASTheme.current().tabHeight();
    var ret:NSSize = contentSize.clone();
    switch(m_tabViewType) {
    case NSTabViewType.NSBottomTabsBezelBorder:
    case NSTabViewType.NSTopTabsBezelBorder:
      ret.height += (tabHeight+10);
      ret.width += 10;
      break;
    case NSTabViewType.NSNoTabsBezelBorder:
      ret.height += 10;
      ret.width += 10;
      break;
    case NSTabViewType.NSNoTabsLineBorder:
      ret.height += 2;
      ret.width += 2;
      break;
    case NSTabViewType.NSNoTabsNoBorder:
      break;
    }
    return ret;
  }
  
  //******************************************************															 
  //*               Truncating tab labels
  //******************************************************
  
  /**
   * Returns <code>true</code> if tab view item labels will be truncated if
   * they do not fit into their alloted width, or <code>false</code> otherwise.
   */
  public function allowsTruncatedLabels():Boolean {
    return m_allowsTruncatedLabels;
  }
  
  /**
   * Sets whether tab view item labels can be truncated if their width's
   * exceed that which is available. If <code>value</code> is <code>true</code>
   * they will be truncated as required.
   */
  public function setAllowsTruncatedLabels(value:Boolean) {
    m_allowsTruncatedLabels = value;
  }
  
  public function isOpaque():Boolean {
    return false;
  }
  
  //******************************************************															 
  //*               Assigning a delegate
  //******************************************************
  
  /**
   * Sets this tab view's delegate to <code>delegate</code>.
   */
  public function setDelegate(delegate:Object) {
    m_delegate = delegate;
  }
  
  /**
   * Returns the delegate associated with this tab view.
   */
  public function delegate():Object {
    return m_delegate;
  }
  
  //******************************************************															 
  //*                  Event handling
  //******************************************************
  
  /**
   * Returns the tab view item located at <code>point</code>, or 
   * <code>null</code> if no tab view item could be found at the point.
   * 
   * <code>point</code> should be expressed in the coordinate system of the
   * tab view. 
   */
  public function tabViewItemAtPoint(point:NSPoint):NSTabViewItem {  	
    var i:Number = m_scrollIndex;
    var tabViewItem:NSTabViewItem;
    while ( (tabViewItem=tabViewItemAtIndex(i)) != null) {
      if (tabViewItem.pointInTabItem(point)) {
        return tabViewItem;
      }
      i++;
    }
    return null;
  }

  /**
   * Responds to a mouse event, and selects a tab item if one has been pressed.
   */
  public function mouseDown(event:NSEvent) {
    var location:NSPoint = convertPointFromView(event.mouseLocation.clone(), null);
    var item:NSTabViewItem = tabViewItemAtPoint(location);
    if (item != null && item != m_selected) {
      selectTabViewItem(item);
    }
  }

  //******************************************************															 
  //*                    Drawing
  //******************************************************
  
  /**
   * Draws the tab view in the rectangle <code>rect</code>.
   */
  public function drawRect(rect:NSRect) {
    
    var i:Number = m_scrollIndex;
    var tabViewItem:NSTabViewItem;
    var tx:Number = 5;
    var tabWidth:Number;
    var tabHeight:Number = ASTheme.current().tabHeight();
    var selectedRect:NSRect;
    var tabRect:NSRect = null;
    var fillColor:Number = 0xC6C6C6;
    var x:Number = rect.origin.x;
    var y:Number = rect.origin.y;
    var width:Number = rect.size.width-1;
    var availWidth:Number = width - m_buttonSize * 2 - 10;
    var height:Number = rect.size.height-1;
    
    m_mcBounds.clear();
    if (m_tabViewType == NSTabViewType.NSNoTabsNoBorder) {
      return;
    } else if (m_tabViewType == NSTabViewType.NSNoTabsLineBorder) {
      with (m_mcBounds) {
        lineStyle(1, 0, 100); 
        moveTo(x, y);
        lineTo(x+width, y);
        lineTo(x+width, y+height);
        lineTo(x, y+height);
        lineTo(x,y);
        endFill();
      }
      return;
    }
    
    //! FIXME Add support for all tab types
    if (m_tabViewType != NSTabViewType.NSTopTabsBezelBorder) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        NSException.NSGeneric,
        "Not all tab types currently supported.",
        null);
      trace(e);
      throw e;
    }
    
    var overflow:Boolean = false;
    m_visibleTabs = 0;
    
    while ( (tabViewItem=tabViewItemAtIndex(i)) != null) {
      tabWidth = widthOfTabViewItem(tabViewItem);
      
      //
      // Check for overflow
      //
      if (m_isScrollable && (tx >= availWidth || (tx + tabWidth) >= availWidth)) {
        overflow = true;
        break;
      }
			
      tabRect = new NSRect(x + tx, y, tabWidth, tabHeight);
      if (tabViewItem.tabState() == NSTabState.NSSelectedTab) {
        selectedRect = tabRect;
      }
      drawTabViewItemInRect(tabViewItem, tabRect);
      tx += tabWidth + m_tabSpacing;
      i++;
      m_visibleTabs++;
    }

    //
    // Deal with overflow
    //
    if (m_isScrollable) {
      m_scrollRight.setEnabled(overflow);
      m_scrollLeft.setEnabled(m_scrollIndex > 0);
      
      for (var j:Number = 0; j < m_scrollIndex; j++) {
        tabViewItem = tabViewItemAtIndex(j);
        tabViewItem.removeTextField();
      }
        
      if (overflow) {        
        while ( (tabViewItem=tabViewItemAtIndex(i)) != null) {
          tabViewItem.removeTextField();
          i++;
        }
      }
      
//      m_scrollTabItemSize.width = (m_frame.size.width - tx - 3);
//      ASTheme.current().drawTabViewItemInRectWithView(
//        m_scrollTabItem, NSRect.withOriginSize(
//          new NSPoint(tx + 3, 0),
//          m_scrollTabItemSize), this);
    }
    
    with (m_mcBounds) {
      if (m_drawsBackground) {
        beginFill(fillColor, 100);
      }
      lineStyle(1, 0x8E8E8E, 100); 
      moveTo(x, y+tabHeight);
      if (selectedRect != null) {
        lineTo(selectedRect.origin.x, y+tabHeight);
        lineStyle(undefined, 0, 100); 
        lineTo(selectedRect.origin.x+selectedRect.size.width, y+tabHeight);
        lineStyle(1, 0x8E8E8E, 100); 
      }
      lineTo(x+width, y+tabHeight);
      lineTo(x+width, y+height);
      lineTo(x, y+height);
      lineTo(x,y+tabHeight);
      
      if (m_drawsBackground) {
        endFill();
      }
    }
  }

  //******************************************************															 
  //*                Helper methods
  //******************************************************
  
  /**
   * Draws the tab view item <code>item</code> in <code>rect</code>.
   */
  private function drawTabViewItemInRect(item:NSTabViewItem, rect:NSRect) {
    ASTheme.current().drawTabViewItemInRectWithView(item, rect, this);
    item.drawLabelInRect(m_allowsTruncatedLabels, rect);
  }
  
  /**
   * Returns the width of the specified tab view item.
   */
  private function widthOfTabViewItem(item:NSTabViewItem):Number {
    return item.sizeOfLabel().width + 14;
  } 
}