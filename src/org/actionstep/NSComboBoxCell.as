/* See LICENSE for copyright and terms of use */

import org.actionstep.ASList;
import org.actionstep.ASListItem;
import org.actionstep.constants.NSBezelStyle;
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.NSArray;
import org.actionstep.NSButtonCell;
import org.actionstep.NSComboBox;
import org.actionstep.NSComboBoxCellDataSource;
import org.actionstep.NSControl;
import org.actionstep.NSImage;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSObject;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTextFieldCell;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;

class org.actionstep.NSComboBoxCell extends NSTextFieldCell {

  private var m_hasVerticalScroller:Boolean;
  private var m_intercellSpacing:NSSize;
  private var m_isButtonBordered:Boolean;
  private var m_itemHeight:Number;
  private var m_numberOfVisibleItems:Number;
  private var m_dataSource:NSComboBoxCellDataSource;
  private var m_usesDataSource:Boolean;
  private var m_internalList:NSArray;

  private var m_indexToMakeTop:Number;
  private var m_indexToMakeVisible:Number;
  private var m_completes:Boolean;

  public var m_popupWindow:NSWindow;

  private var m_buttonCell:NSButtonCell;

  public function NSComboBoxCell() {
    m_hasVerticalScroller = true;
    m_intercellSpacing = new NSSize(3,2);
    m_isButtonBordered = true;
    m_itemHeight = 14;
    m_numberOfVisibleItems = 5;
    m_usesDataSource = false;
    m_internalList = new NSArray();
    m_indexToMakeTop = -1;
    m_indexToMakeVisible = -1;
    m_completes = false;

    makeButtonCell();
  }

  private function makeButtonCell() {
    m_buttonCell = new NSButtonCell();
    m_buttonCell.setHighlightsBy(NSPushInCellMask | NSChangeGrayCellMask);
    m_buttonCell.setShowsStateBy(NSChangeBackgroundCellMask);
    m_buttonCell.setImageDimsWhenDisabled(true);


    //m_buttonCell.setHighlightsBy(NSChangeBackgroundCellMask | NSContentsCellMask);
    m_buttonCell.setImage(NSImage.imageNamed("NSComboBoxDownArrow"));
    m_buttonCell.setAlternateImage(NSImage.imageNamed("NSHighlightedComboBoxDownArrow"));
    m_buttonCell.setImagePosition(NSCellImagePosition.NSImageOnly);
    m_buttonCell.setBezelStyle(NSBezelStyle.NSShadowlessSquareBezelStyle);
    m_buttonCell.setBezeled(true);
  }

  public function setEnabled(value:Boolean) {
    super.setEnabled(value);
    m_buttonCell.setEnabled(value);
  }

  // Setting display attributes

  public function hasVerticalScroller():Boolean {
    return m_hasVerticalScroller;
  }

  public function intercellSpacing():NSSize {
    return m_intercellSpacing;
  }

  public function isButtonBordered():Boolean {
    return m_isButtonBordered;
  }

  public function itemHeight():Number {
    return m_itemHeight;
  }

  public function numberOfVisibleItems():Number {
    return m_numberOfVisibleItems;
  }

  public function setButtonBordered(value:Boolean) {
    m_isButtonBordered = value;
    if (m_isButtonBordered) {
      m_buttonCell.setBezeled(true);
    } else {
      m_buttonCell.setBezeled(false);
    }
  }

  public function setHasVerticalScroller(value:Boolean) {
    m_hasVerticalScroller = value;
  }

  public function setIntercellSpacing(spacing:NSSize) {
    m_intercellSpacing = spacing;
  }

  public function setItemHeight(height:Number) {
    m_itemHeight = height;
  }

  public function setNumberOfVisibleItems(value:Number) {
    m_numberOfVisibleItems = value;
  }

  // Setting a data source

  public function dataSource():NSComboBoxCellDataSource {
    return m_dataSource;
  }

  public function setDataSource(object:NSComboBoxCellDataSource) {
    m_dataSource = object;
  }

  public function setUsesDataSource(value:Boolean) {
    m_usesDataSource = value;
  }

  public function usesDataSource():Boolean {
    return m_usesDataSource;
  }

  // Working with an internal list

  public function addItemsWithObjectValues(objects:NSArray) {
    var list:Array = objects.internalList();
    var size:Number = list.length;
    for(var i:Number = 0;i < size; i++) {
      m_internalList.addObject(list[i]);
    }
  }

  public function addItemWithObjectValue(object:Object) {
    m_internalList.addObject(object);
  }

  public function insertItemWithObjectValueAtIndex(object:Object, index:Number) {
    m_internalList.insertObjectAtIndex(object, index);
  }

  public function objectValues():NSArray {
    return NSArray.arrayWithNSArray(m_internalList);
  }

  public function removeAllItems() {
    m_internalList.removeAllObjects();
    deselectItemAtIndex(0);
  }

  public function removeItemAtIndex(index:Number) {
    m_internalList.removeObjectAtIndex(index);
  }

  public function removeItemWithObjectValue(object:Object) {
    m_internalList.removeObjectAtIndex(indexOfItemWithObjectValue(object));
  }

  public function numberOfItems():Number {
    return m_internalList.count();
  }

  // Manipulating the displayed list

  public function indexOfItemWithObjectValue(object:Object):Number {
    return m_internalList.indexOfObjectWithCompareFunction(object,
    function(val:Object, search:Object):Boolean {
    	return (val == search);
    });
  }

  public function indexOfItemWithStringValue():Number {
    return m_internalList.indexOfObjectWithCompareFunction(stringValue(),
    function(val:Object, search:Object):Boolean {
    	return (val.toString() == search);
    });
  }

  public function indexOfSelectedItem():Number {
    return indexOfItemWithStringValue();
  }

  public function itemObjectValueAtIndex(index:Number):Object {
    return m_internalList.objectAtIndex(index);
  }

  public function noteNumberOfItemsChanged() {
    // update ?
  }

  public function reloadData() {
    // reload ?
  }

  public function scrollItemAtIndexToTop(index:Number) {
    m_indexToMakeTop = index;
  }

  public function scrollItemAtIndexToVisible(index:Number) {
    m_indexToMakeVisible = index;
  }

  // Manipulating the selection

  public function deselectItemAtIndex(index:Number) {
    setStringValue("");
  }

  public function objectValueOfSelectedItem():Object {
    return itemObjectValueAtIndex(indexOfSelectedItem());
  }

  public function selectItemAtIndex(index:Number) {
    setStringValue(itemObjectValueAtIndex(index).toString());
  }

  public function selectItemWithObjectValue(object:Object) {
    if (indexOfItemWithObjectValue(object) == NSNotFound) {
      return;
    }
    setStringValue(object.toString());
  }

  // Completing the text field

  public function completes():Boolean {
    return m_completes;
  }

  public function setCompletes(value:Boolean) {
    m_completes = value;
  }

  // Drawing

  public function titleRectForBounds(theRect:NSRect):NSRect {
    var drawBg:Boolean = m_drawsBackground || m_backgroundColor != null;
    var fontHeight:Number = m_font.getTextExtent("Why").height;
    var x:Number = theRect.origin.x;
    var y:Number = theRect.origin.y;
    var w:Number = theRect.size.width - 1;
    var h:Number = theRect.size.height - 1;
    var ret:NSRect = NSRect.ZeroRect;
    
    ret.origin.x = x + (drawBg ? 3 : 0);
    ret.origin.y = y + (h - fontHeight) / 2;
    ret.size.width = w - 1;
    
    if (m_wraps) {
    	ret.size.height = h - 1;
    } else {
    	ret.size.height = fontHeight;
    }
    
    return ret;
  }

  private var m_buttonCellFrame:NSRect;

  public function drawWithFrameInView(cellFrame:NSRect, inView:NSView) {
    if (m_controlView != inView) {
      m_controlView = inView;
    }
    if (m_drawsBackground) {
      ASTheme.current().drawTextFieldCellInRectOfView(this, cellFrame, inView);
    }
    validateTextField(cellFrame);
    m_textField._y = cellFrame.origin.y + (cellFrame.size.height - m_font.getTextExtent("Why").height)/2;
    m_textField._width = cellFrame.size.width - cellFrame.size.height + 4 - m_textField._x;
    m_buttonCellFrame = new NSRect(m_textField._width, 1, cellFrame.size.height-2, cellFrame.size.height-2);
    m_buttonCell.drawWithFrameInView(m_buttonCellFrame, inView);
    if (m_showsFirstResponder || (m_popupWindow != null)) {
      ASTheme.current().drawFirstResponderWithRectInView(cellFrame, inView);
    }
    drawInteriorWithFrameInView(cellFrame, inView);
    m_textField._y = cellFrame.origin.y + (cellFrame.size.height - m_font.getTextExtent("Why").height)/2;
    m_textField._width = cellFrame.size.width - cellFrame.size.height + 4 - m_textField._x;
  }

  // Event handling

  public function isPointInDropDownButton(point:NSPoint):Boolean {
    return m_buttonCellFrame.pointInRect(point);
  }

  public function showListWindow() {
  	//
  	// Build window
  	//    
    m_popupWindow = new NSWindow();
    var window:NSWindow = m_popupWindow;
    var cbFrame:NSRect = m_controlView.frame();
    var origin:NSPoint = m_controlView.superview().convertPointToView(cbFrame.origin, null);
    origin = origin.translate(0, cbFrame.size.height);
    window.initWithContentRectSwf(new NSRect(origin.x, origin.y, cbFrame.size.width, 200), m_controlView.window().swf());
    window.setReleasedWhenClosed(true);
    
    //
    // Build list
    //
    var list:ASList = new ASList();
    list.initWithFrame(new NSRect(0,0,cbFrame.size.width, 200));
    list.setDrawsBackground(false);
    list.setBackgroundColor(new org.actionstep.NSColor(0xD5D7DB));
    list.setBorderColor(new org.actionstep.NSColor(0x494D56));
    list.setHasVerticalScroller(m_hasVerticalScroller);
    var array:Array = m_internalList.internalList();
    var items:Array = new Array();
    var obj:Object;
    for(var i:Number = 0;i<array.length;i++) {
      obj = array[i];
      items.push((new ASListItem()).initWithLabelData(obj.toString(), obj));
    }
    list.setItems((new NSArray()).initWithArray(items));
    list.setSendsActionOnEnterOnly(true);
    
    window.setContentView(list);
    window.setInitialFirstResponder(list);
    
    //
    // Set up delegate methods on the window
    //
    var control:NSControl = NSControl(m_controlView);
    var self:NSComboBoxCell = this;
    var delegate:Object = new Object();
    var isControlCombo:Boolean = control instanceof NSComboBox;
    var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
    
    //
    // Method fired when the pop up window displays
    //
    delegate.windowDidDisplay = function(notification:NSNotification) {
      window.setContentSize(new NSSize(cbFrame.size.width, list.itemHeight()*self.numberOfVisibleItems()));
      window.setLevel(NSWindow.NSModalPanelWindowLevel);
      window.makeKeyWindow();
      window.makeMainWindow();
      list.setShowsFirstResponder(false);
      var index:Number = self.indexOfItemWithStringValue();
      if (index != NSObject.NSNotFound) {
        list.selectItemAtIndex(index);
      }
    };
    
    //
    // Method fired when the window resigns key status
    //
    delegate.windowDidResignKey = function(notification:NSNotification) {
      if (self.m_popupWindow != undefined) {
        self.m_popupWindow = null;
        control.window().makeFirstResponder(control);
        window.close();
      }
    };
    
    //
    // Method fired when the window resigns main status
    //
    delegate.windowDidResignMain = function(notification:NSNotification) {
      if (self.m_popupWindow != undefined) {
        self.m_popupWindow = null;
        control.window().makeFirstResponder(control);
        window.close();
      }
    };
    
    //
    // Method fired when the window is about to close
    //
    delegate.windowWillClose = function (notification:NSNotification):Void {
      if (isControlCombo) {
        nc.postNotificationWithNameObject(
          NSComboBox.NSComboBoxWillDismissNotification,
          control);
      }
    };
    
    window.setDelegate(delegate);
    
    //
    // Dispatch a notification regarding the popup
    //
    if (isControlCombo) {
      nc.postNotificationWithNameObject(
      	NSComboBox.NSComboBoxWillPopUpNotification,
      	control);
    }
    
    //
    // Display the window
    //
    window.display();
    var listTarget:Object = new Object();
    listTarget.selected = function():Void {
      //
      // Dispatch a notification regarding selection changing
      //
      if (isControlCombo) {
        nc.postNotificationWithNameObject(
          NSComboBox.NSComboBoxSelectionIsChangingNotification,
          control);
      }
      
      var item:ASListItem = list.selectedItem();
      if (item != null) {
        control.setStringValue(item.data().toString());
        control.sendActionTo(control.action(), control.target());
      }
      
      //
      // Dispatch a notification regarding selection change
      //
      if (isControlCombo) {
        nc.postNotificationWithNameObject(
          NSComboBox.NSComboBoxSelectionDidChangeNotification,
          control);
      }
      
      //
      // Cleanup
      //
      self.m_popupWindow = null;
      control.setNeedsDisplay(true);
      //control.window().makeKeyWindow();
      //control.window().makeMainWindow();
      control.window().makeFirstResponder(control);
      window.close();
    };
    list.refresh();
    list.setTarget(listTarget);
    list.setAction("selected");
  }

}
