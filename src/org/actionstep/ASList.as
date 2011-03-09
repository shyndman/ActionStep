/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.ASListItem;
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSScrollerPart;
import org.actionstep.NSArray;
import org.actionstep.NSColor;
import org.actionstep.NSControl;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSFont;
import org.actionstep.NSImage;
import org.actionstep.NSIndexSet;
import org.actionstep.NSObject;
import org.actionstep.NSPoint;
import org.actionstep.NSRange;
import org.actionstep.NSRect;
import org.actionstep.NSScroller;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeProtocol;

/**
 * Displays a list of items.
 */
class org.actionstep.ASList extends NSControl {
  
  private static var NO_IMAGE_INDENT:Number = 4;
  private static var IMAGE_INDENT:Number = 24;

  private var m_font:NSFont;
  private var m_fontHeight:Number;
  private var m_fontColor:NSColor;
  private var m_items:NSArray;
  private var m_itemHeight:Number;
  private var m_numberOfVisibleItems:Number;
  private var m_textFields:Array;
  private var m_scrollIndex:Number;
  private var m_scroller:NSScroller;
  private var m_scrollPageAmount:Number;
  private var m_maxScrollAmount:Number;
  private var m_hasScroller:Boolean;
  private var m_borderType:NSBorderType;
  private var m_autohidesScrollers:Boolean;
  private var m_showListItemImages:Boolean;
  private var m_showsFirstResponder:Boolean;
  private var m_drawsBackground:Boolean;
  private var m_toggleSelection:Boolean;
  private var m_backgroundColor:NSColor;
  private var m_multipleSelection:Boolean;
  private var m_borderColor:NSColor;
  private var m_indent:Number;
  private var m_sendsActionOnEnterOnly:Boolean;
  private var m_action:String;
  private var m_target:Object;
  private var m_dblAction:String;
  private var m_ignoresMultiClick:Boolean;
  private var m_dottedIndex:Number;
  private var m_pivotPoint:Number;
  private var m_firstSelectedItem:Number;
  private var m_textFormat:TextFormat;
  private var m_enabled:Boolean;

  public function ASList() {
    m_scrollPageAmount = 5;
    m_itemHeight = 20;
    m_scrollIndex = 0;
    m_maxScrollAmount = 0;
    m_numberOfVisibleItems = 0;
    m_hasScroller = true;
    m_autohidesScrollers = true;
    m_showListItemImages = false;
    m_showsFirstResponder = false;
    m_drawsBackground = true;
    m_multipleSelection = false;
    m_sendsActionOnEnterOnly = false;
    m_firstSelectedItem = -1;
    m_indent = NO_IMAGE_INDENT;
    m_enabled = true;
    m_ignoresMultiClick = true;
    m_dottedIndex = 0;
    m_toggleSelection = false;
  }

  public function initWithFrame(rect:NSRect):ASList {
    super.initWithFrame(rect);
    m_items = new NSArray();
    m_font = ASTheme.current().labelFontOfSize(0);
    m_fontHeight = m_font.getTextExtent("Why").height;
    m_textFormat = m_font.textFormat();
    m_fontColor = ASTheme.current().systemFontColor();
    m_borderColor = new NSColor(0x000000);
    m_backgroundColor = new NSColor(0xffffff);

    m_numberOfVisibleItems = Math.floor(m_frame.size.height/m_itemHeight);

    m_scroller = (new NSScroller()).init();
    m_scroller.setAutoresizingMask(NSView.WidthSizable);
    m_scroller.setTarget(this);
    m_scroller.setAction("scrollAction");
    var scrollerWidth:Number = NSScroller.scrollerWidth();
    m_scroller.setFrame(new NSRect(rect.size.width-scrollerWidth-1, 1, scrollerWidth, rect.size.height-2));
    return this;
  }

  public function createMovieClips() {
    super.createMovieClips();
    if (m_mcBounds != null) {
      createTextFields();
      refresh();
    }
  }

  //******************************************************
  //*              Describing the object
  //******************************************************

  /**
  * Returns a string representation of the object.
  */
  public function description():String {
   return "ASList()";
  }

  //******************************************************
  //*                Responder chain
  //******************************************************

  public function becomeFirstResponder():Boolean {
   m_showsFirstResponder = true;
   setNeedsDisplay(true);
   return true;
  }

  public function acceptsFirstResponder():Boolean {
   return true;
  }

  public function resignFirstResponder():Boolean {
   m_showsFirstResponder = false;
   setNeedsDisplay(true);
   return true;
  }

  public function becomeKeyWindow() {
   m_showsFirstResponder = true;
   setNeedsDisplay(true);
  }

  public function resignKeyWindow() {
    m_showsFirstResponder = false;
    setNeedsDisplay(true);
  }

  //******************************************************
  //*              Configuring the display
  //******************************************************

  /**
   * Returns whether the list shows that it is the first responder (the focused
   * view).
   */
  public function setShowsFirstResponder(value:Boolean) {
    m_showsFirstResponder = value;
  }

  /**
   * Sets whether the list should show list item images (images beside lines
   * in the list) to <code>value</code>.
   */
  public function setShowListItemImages(value:Boolean) {
  	if (value == m_showListItemImages) {
  		return;
  	}
  	
    m_showListItemImages = value;
    m_indent = value ? IMAGE_INDENT : NO_IMAGE_INDENT; 
    resetTextFields();
  }

  /**
   * Returns <code>true</code> if the list shows list item images.
   */
  public function showListItemImages():Boolean {
    return m_showListItemImages;
  }

  /**
   * Sets whether the list displays a vertical scroller to <code>value</code>.
   */
  public function setHasVerticalScroller(value:Boolean) {
    m_hasScroller = value;
    refresh();
  }

  /**
   * Returns <code>true</code> if the list displays a vertical scroller.
   */
  public function hasVerticalScroller():Boolean {
    return m_hasScroller;
  }

  /**
   * Sets whether the list hides its scrollers automatically when not needed
   * to <code>value</code>.
   */
  public function setAutohidesScrollers(value:Boolean) {
    m_autohidesScrollers = value;
  }

  /**
   * Returns <code>true</code> if the list automatically hides scrollers when
   * not needed.
   */
  public function autohidesScrollers():Boolean {
    return m_autohidesScrollers;
  }

  /**
   * Sets the list's border type to <code>value</code>.
   */
  public function setBorderType(value:NSBorderType) {
    m_borderType = value;
  }

  /**
   * Returns the list's border type.
   */
  public function borderType():NSBorderType {
  	return m_borderType;
  }

  /**
   * Sets whether the list draws a background of <code>#backgroundColor()</code>
   * to <code>value</code>.
   */
  public function setDrawsBackground(value:Boolean) {
    m_drawsBackground = value;
  }

  /**
   * Returns <code>true</code> if the list draws a background of
   * <code>#backgroundColor()</code>.
   */
  public function drawsBackground():Boolean {
    return m_drawsBackground;
  }

  /**
   * <p>Sets the background color of the list to <code>color</code>.</p>
   *
   * <p>Please note that for the list to draw its background,
   * {@link #drawsBackground()} must return <code>true</code>.</p>
   *
   * @see #backgroundColor()
   * @see #setDrawsBackground()
   */
  public function setBackgroundColor(color:NSColor) {
    m_backgroundColor = color;
  }

  /**
   * Returns the background color of the list.
   */
  public function backgroundColor():NSColor {
    return m_backgroundColor;
  }

  /**
   * Sets the border color of the list to <code>color</code>.
   */
  public function setBorderColor(color:NSColor) {
    m_borderColor = color;
  }

  /**
   * Returns the border color of the list.
   */
  public function borderColor():NSColor {
    return m_borderColor;
  }

  /**
   * Returns the height used for each item in the list.
   */
  public function itemHeight():Number {
    return m_itemHeight;
  }

  public function setFontColor(color:NSColor) {
    m_fontColor = color;
    refresh();
  }

  public function fontColor():NSColor {
    return m_fontColor;
  }

  public function setFont(font:NSFont) {
    m_font = font;
    m_textFormat = m_font.textFormat();
    resetTextFields();
    refresh();
  }

  public function font():NSFont {
    return m_font;
  }

  public function setIndent(value:Number) {
    m_indent = value;
    resetTextFields();
    refresh();
  }

  public function indent():Number {
    return m_indent;
  }

  //******************************************************
  //*                  Managing Items
  //******************************************************

  /**
   * Adds <code>item</code> to the end of the list.
   */
  public function addItem(item:ASListItem):Void {
    m_items.addObject(item);
    computeValues();
    refresh();
  }

  /**
   * Adds a new item to the end of the list with the text of <code>label</code>
   * and data <code>data</code>, and returns the newly created item.
   */
  public function addItemWithLabelData(label:String, data:Object):ASListItem {
    var item:ASListItem = ASListItem.listItemWithLabelData(label, data);
    addItem(item);
    return item;
  }

  /**
   * Adds the contents of <code>items</code> to the end of the list.
   */
  public function addItems(itemList:NSArray):Void {
    var list:Array = itemList.internalList();
    var count:Number = list.length;
    for (var i:Number = 0;i < count;i++) {
      m_items.addObject(list[i]);
    }
    computeValues();
    refresh();
  }

  /**
   * Adds items to the list using the contents of the <code>labels</code> and
   * <code>data</code> arrays.
   *
   * If the arrays do not have the same length, an <code>NSException</code> is
   * thrown.
   */
  public function addItemsWithLabelsData(labels:Array, data:Array):Void {
  	if (labels.length != data.length) { // Validate arguments
  	  var e:NSException = NSException.exceptionWithNameReasonUserInfo(
  	    "NSIllegalArgumentException",
  	    "labels and data arrays must have the same length.",
  	    null);
  	  trace(e);
  	  throw e;
  	}
    var item:ASListItem;
    for (var i:Number = 0;i < labels.length;i++) {
      m_items.addObject(ASListItem.listItemWithLabelData(labels[i], data[i]));
    }
    computeValues();
    refresh();
  }

  /**
   * Inserts the <code>ASListItem</code> <code>item</code> into the list at
   * <code>index</code>.
   *
   * This method throws an <code>NSException</code> if <code>index</code> is
   * out of range.
   */
  public function insertItemAtIndex(item:ASListItem, index:Number):Void {
    m_items.insertObjectAtIndex(item, index);
    computeValues();
    refresh();
  }

  /**
   * Inserts a new item with display text of <code>label</code> and data of
   * <code>data</code> into the list at <code>index</code>.
   *
   * This method throws an <code>NSException</code> if <code>index</code> is
   * out of range.
   */
  public function insertItemWithLabelDataAtIndex(label:String, data:Object,
      index:Number):ASListItem {
    var item:ASListItem = ASListItem.listItemWithLabelData(label, data);
    insertItemAtIndex(item, index);
    return item;
  }

  /**
   * Returns the <code>ASListItem</code> with an index in the list of
   * <code>index</code>.
   *
   * This method throws an <code>NSException</code> if <code>index</code> is
   * out of range.
   */
  public function itemAtIndex(index:Number):ASListItem {
    return ASListItem(m_items.objectAtIndex(index));
  }

  /**
   * Returns the index of <code>item</code> in the list, or
   * <code>NSObject.NSNotFound</code> if <code>item</code> is not in the list.
   */
  public function indexOfItem(item:ASListItem):Number {
    return m_items.indexOfObject(item);
  }

  /**
   * Returns the first <code>ASListItem</code> found containing the data
   * <code>data</code>.
   */
  public function itemWithData(data:Object):ASListItem {
    var list:Array = m_items.internalList();
    var length:Number = list.length;
    for(var i:Number = 0;i < length;i++) {
      if (list[i].data() == data) {
        return ASListItem(list[i]);
      }
    }
    return null;
  }

  /**
   * Returns the internal data structure used by the list.
   */
  public function items():NSArray {
    return m_items;
  }

  public function setItems(items:NSArray) {
    m_items = items;
    m_scrollIndex = 0;
    computeValues();
    refresh();
  }

  /**
   * Removes all the items from the list.
   *
   */
  public function removeAllItems():Void {
    var list:Array = m_items.internalList();
    var length:Number = list.length;
    for(var i:Number = 0;i < length;i++) {
      if (list[i].isSelected()) {
        list[i].setSelected(false);
      }
    }
    m_items.removeAllObjects();
    computeValues();
    refresh();
  }

  /**
   * <p>Removes the object at position index from the list.</p>
   *
   * <p>Throws an {@link NSException} if <code>index</code> is out of range.</p>
   */
  public function removeItemAtIndex(index:Number):Void {
    m_items.removeObjectAtIndex(index);
    computeValues();
    refresh();
  }

  /**
   * Removes <code>item</code> from the list.
   */
  public function removeItem(item:ASListItem):Void {
    m_items.removeObject(item);
    if (item.isSelected()) {
      item.setSelected(false);
    }
    computeValues();
    refresh();
  }

  /**
   * <p>Removes the items that fall in the range <code>aRange</code> from the
   * list.</p>
   *
   * If <code>aRange</code> is out of bounds, an {@link NSException} is thrown.
   */
  public function removeItemsInRange(aRange:NSRange):Void {
    var items:Array = m_items.subarrayWithRange(aRange).internalList();
    var len:Number = items.length;

    for (var i:Number = 0; i < len; i++) {
      var item:ASListItem = ASListItem(items[i]);
      if (item.isSelected()) {
        item.setSelected(false);
      }
    }

    m_items.removeObjectsInRange(aRange);
    computeValues();
    refresh();
  }

  /**
   * <p>Removes the items found at the indexes <code>indexes</code>.</p>
   *
   * <p>An exception is thrown if any of the indexes is out of range.</p>
   */
  public function removeItemsAtIndexes(indexes:NSIndexSet):Void {
    var arr:Array = (indexes.getIndexes()).internalList();
    var len:Number = arr.length;
    for (var i:Number = 0; i < len; i++) {
      ASListItem(arr[i]).setSelected(false);
    }

    m_items.removeObjectsAtIndexes(indexes);
    computeValues();
    refresh();
  }

  /**
   * Returns the number of items in the list.
   */
  public function numberOfItems():Number {
    return m_items.count();
  }

  //******************************************************
  //*                   Selection
  //******************************************************

  /**
   * Selects <code>item</code> in the list.
   */
  public function selectItem(item:ASListItem):Void {
    var list:Array = m_items.internalList();
    var length:Number = list.length;
    var index:Number = NSNotFound;
    for(var i:Number = 0;i < length;i++) {
      if (list[i] == item) {
        index = i;
        break;
      }
    }
    if (index != NSNotFound) {
      selectItemAtIndex(index);
      refresh();
    }
  }

  /**
   * Selects all the items in the range <code>aRange</code>, or throws an
   * exception if <code>aRange</code> is out of bounds.
   */
  public function selectItemsInRange(aRange:NSRange):Void {
    var min:Number = aRange.location;
    var max:Number = aRange.location + aRange.length;
    var cnt:Number = m_items.count();

    //
    // Bounds check
    //
    if (min < 0 || min >= cnt || max < 0 || max > cnt) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
      	NSException.NSRange,
      	"Cannot select items that do not exist. Range used: " + aRange.toString(),
      	null);
      trace(e);
      throw e;
    }

    //
    // We can't select a range if we're not in multisel mode.
    //
    if (!multipleSelection()) {
      selectItemAtIndex(max - 1);
    }

    //
    // Select the items
    //
    for (var i:Number = min; i <= max; i++) {
      ASListItem(m_items.objectAtIndex(i)).setSelected(true);
    }

    refresh();
  }

  /**
   * Selects all the items from the index at <code>pivot</code> to the index
   * at <code>start + delta</code>. If <code>start + delta</code> ends up
   * crossing the pivot point during the selection, any items that had
   * previously been selected will become deselected.
   */
  public function selectItemsFromPivotStartDelta(pivot:Number, start:Number,
      delta:Number):Void {
    var deselI:Number;
    var deselF:Number;
    var selI:Number;
    var selF:Number;

    if (start <= pivot && delta >= 0) {
      deselI = start;
      if (start + delta > pivot) {
      	deselF = pivot;
      	selI = pivot;
      	selF = start + delta;
      } else {
      	deselF = start + delta;
      	selI = start + delta;
      	selF = pivot;
      }
    }
    else if (start > pivot && delta > 0) {
      selI = pivot;
      selF = start + delta;
    }
    else if (start <= pivot && delta < 0) {
      selI = start + delta;
      selF = pivot;
    }
    else if (start > pivot && delta <= 0) {
      deselF = start;
      if (start + delta < pivot) {
      	deselI = pivot;
        selI = start + delta;
        selF = pivot;
      } else {
      	deselI = start + delta;
        selI = pivot;
        selF = start + delta;
      }
    }

    //
    // Deselect
    //
    if (deselI != undefined && deselF != undefined) {
      for (var i:Number = deselI; i <= deselF; i++) {
        var item:ASListItem = ASListItem(m_items.objectAtIndex(i));
        item.setSelected(false);
      }
    }

    //
    // Select
    //
    if (selI != undefined && selF != undefined) {
      for (var i:Number = selI; i <= selF; i++) {
        var item:ASListItem = ASListItem(m_items.objectAtIndex(i));
        item.setSelected(true);
      }
    }

    if (!scrollItemAtIndexToVisible(start + delta)) {
      refresh();
    }
  }

  /**
   * Selects the item and index <code>index</code>.
   */
  public function selectItemAtIndex(index:Number) {
    if (index < 0) {
      deselectAllItems();
      return;
    } else if (index > m_items.count()-1) {
      deselectAllItems();
      return;
    }

    if (!multipleSelection()) {
      deselectAllItems(false);
    }

  	m_firstSelectedItem = index;
  	m_items.objectAtIndex(index).setSelected(true);
  	if (!scrollItemAtIndexToVisible(index)) {
  	  refresh();
  	}
  }

  public function deselectAllItems(shouldRefresh:Boolean) {
    if (m_firstSelectedItem == -1) {
      return;
    }
    if (shouldRefresh == undefined) {
      shouldRefresh = true;
    }
    var list:Array = m_items.internalList();
    for(var i:Number = 0;i<list.length;i++) {
      list[i].setSelected(false);
    }
    if(shouldRefresh) {
      refresh();
    }
    m_firstSelectedItem = -1;
  }

  /**
   * Returns the list's selected item.
   *
   * A warning is logged if the list has multiple selection enabled. For a
   * list with multiple selection enabled, use <code>#selectedItems</code>
   * instead.
   *
   * @see #selectedItems()
   */
  public function selectedItem():ASListItem {
    if (m_multipleSelection) {
      trace(asWarning("ASList allows mutliple selections but single item " +
      "selection requested."));
    }
    var list:Array = m_items.internalList();
    var length:Number = list.length;
    for(var i:Number = 0;i < length;i++) {
      if (list[i].isSelected()) {
        return ASListItem(list[i]);
      }
    }
    return null;
  }

  /**
   * Returns the list's selected items.
   *
   * A warning is logged if the list has multiple selection disabled. For a
   * list with multiple selection disabled, use <code>#selectedItem</code>
   * instead.
   *
   * @see #selectedItem()
   *
   */
  public function selectedItems():NSArray {
    if (!m_multipleSelection) {
      trace(asWarning("ASList does not allow mutliple selections but " +
      "multiple item selections requested."));
    }
    var result:Array = new Array();
    var list:Array = m_items.internalList();
    var length:Number = list.length;
    for(var i:Number = 0;i < length;i++) {
      if (list[i].isSelected()) {
        result.push(list[i]);
      }
    }
    return (new NSArray()).initWithArray(result);
  }
  
  /**
   * Returns the indices of the list's selected items.
   */
  public function selectedIndexes():NSIndexSet {
    if (!m_multipleSelection) {
      trace(asWarning("ASList does not allow mutliple selections but " +
      "multiple item selections requested."));
    }
    
    var result:NSIndexSet = NSIndexSet.indexSet();
    var list:Array = m_items.internalList();
    var length:Number = list.length;
    for(var i:Number = 0;i < length;i++) {
      if (list[i].isSelected()) {
        result.addIndex(i);
      }
    }
    return result;
  }

  //******************************************************
  //*                Scroller methods
  //******************************************************


  private function scrollAction(scroller:NSScroller) {
    var floatValue:Number = scroller.floatValue();
    var hitPart:NSScrollerPart = scroller.hitPart();
    var amount:Number = 0;

    var knobMoved:Boolean = false;
    switch(scroller.hitPart()) {
      case NSScrollerPart.NSScrollerKnob:
      case NSScrollerPart.NSScrollerKnobSlot:
        knobMoved = true;
        break;
      case NSScrollerPart.NSScrollerIncrementPage:
        amount = m_scrollPageAmount;
        break;
      case NSScrollerPart.NSScrollerIncrementLine:
        amount = 1;
        break;
      case NSScrollerPart.NSScrollerDecrementPage:
        amount = -m_scrollPageAmount;
        break;
      case NSScrollerPart.NSScrollerDecrementLine:
        amount = -1;
        break;
      default:
        return;
    }
    if (!knobMoved) {
      m_scrollIndex += amount;
      if (m_scrollIndex < 0) {
        m_scrollIndex = 0;
      } else if (m_scrollIndex > m_maxScrollAmount) {
        m_scrollIndex = m_maxScrollAmount;
      }
    } else {
      m_scrollIndex = Math.round(floatValue * m_maxScrollAmount);
    }
    refresh();
  }

  private function reflectScrolledValues() {
    m_scroller.setFloatValueKnobProportion(m_scrollIndex/m_maxScrollAmount, m_numberOfVisibleItems/m_items.count());
    m_scroller.setNeedsDisplay(true);
  }

  // Items drawing methods

  private function computeValues() {
    var list:Array = m_items.internalList();
    var listCount:Number = m_items.count();
    var autohides:Boolean = autohidesScrollers();
    var updateTxtWidths:Boolean = false;
    
    //
    // Show or hide the scroller if necessary
    //
    if(listCount > m_numberOfVisibleItems || !autohides) {
      if (m_scroller.superview()) {
        m_scroller.removeFromSuperview();
      }
      addSubview(m_scroller);
      updateTxtWidths = true;
    }
    else if (autohides) {
      m_scroller.removeFromSuperview();
      updateTxtWidths = true;
    }
    
    //
    // Limit scrolling
    //
    if (m_scrollIndex > m_maxScrollAmount) {
      if (m_maxScrollAmount >= 0) {
        m_scrollIndex = m_maxScrollAmount;
      }
    }
    m_maxScrollAmount = Math.max(listCount - m_numberOfVisibleItems, 0);

    
    //
    // Update txt widths if necessary
    //
    if (updateTxtWidths) {
      updateTextFieldWidths();
    }
  }

  public function refresh() {
    if (m_mcBounds == null) {
      return;
    }
    var list:Array = m_items.internalList();
    var count:Number = list.length - m_scrollIndex;
    for(var i:Number = 0;i<m_numberOfVisibleItems;i++) {
      m_textFields[i].text = i < count ? list[i+m_scrollIndex].label() : "";
      m_textFields[i].setTextFormat(m_textFormat);
      m_textFields[i].textColor = list[i+m_scrollIndex].isSelected() ? 0xffffff : (m_enabled ? m_fontColor.value : m_fontColor.adjustColorBrightnessByDelta(.4).value);
    }
    setNeedsDisplay(true);
    reflectScrolledValues();
  }

  public function setEnabled(value:Boolean) {
    m_enabled = value;
    refresh();
  }

  public function enabled():Boolean {
    return m_enabled;
  }

  public function resetTextFields() {
    if (m_mcBounds == null) {
      return;
    }
    for(var i:Number = 0;i<m_textFields.length;i++) {
      m_textFields[i].removeTextField();
    }
    m_textFields = null;
    m_fontHeight = m_font.getTextExtent("Why").height;
    createTextFields();
  }

  public function createTextFields() {
    if (m_textFields == null) {
      m_textFields = new Array();
      var offset:Number = (m_itemHeight-m_fontHeight)/2;
      var tf:TextField;
      var fmt:TextFormat = m_font.textFormat();
      for (var i:Number = 0;i<m_numberOfVisibleItems;i++) {
        // TODO consider something global for textfield creation
        tf = createBoundsTextField();
        tf._x = m_indent;
        tf._y = i*m_itemHeight+offset;
        tf._width = m_frame.size.width;
        tf._height = m_fontHeight;
        tf.border = false;
        tf.wordWrap = false;
        tf.multiline = true;
        tf.autoSize = false;
        tf.editable = false;
        tf.selectable = false;
        tf.antiAliasType = "advanced";
        tf.gridFitType = "pixel";
        
        
        m_textFields.push(tf);
      }
      computeValues();
      refresh();
    }
  }

  private function updateTextFieldWidths():Void {
  	//
  	// Determine width
  	//
    var width:Number = frame().size.width;
    if (m_scroller.superview() == this) {
      width -= ASTheme.current().scrollerWidth();
    }
    
    //
    // Set widths
    //
    var len:Number = m_textFields.length;
    for (var i:Number = 0; i < len; i++) {
      TextField(m_textFields[i])._width = width;
    }
  }
  
  //******************************************************
  //*                Event handling
  //******************************************************

  public function mouseDown(event:NSEvent):Void {
    if (!m_enabled) {
      return;
    }
    var location:NSPoint = event.mouseLocation;
    location = convertPointFromView(location);
    m_window.makeFirstResponder(this);

    //
    // Get the clicked item
    //
    var idx:Number = getItemIndexForPoint(location);

    if (event.clickCount == 2 && !ignoresMultiClick()) {
      sendActionTo(doubleAction(), target());
      return;
    }
	
    //
    // Select or deselect item
    //
    if (!multipleSelection()) {
      m_dottedIndex = idx;
      //deselectAllItems(false); don't need this...its done in selectItemAtIndex
      selectItemAtIndex(idx);
      m_pivotPoint = null;
      return;
    }

    var item:ASListItem = itemAtIndex(idx);
    //
    // Depending on the modifier keys, do special multiselection stuff.
    //
    var mods:Number = event.modifierFlags;
    var addToSelection:Boolean = Boolean(mods & NSEvent.NSControlKeyMask) 
      || m_toggleSelection;
    var selectRange:Boolean = Boolean(mods & NSEvent.NSShiftKeyMask);

    if (addToSelection && selectRange) {
      //
      // Add to the range to the selection.
      //
      if (m_pivotPoint == null) {
        m_pivotPoint = m_dottedIndex;
      }

      selectItemsFromPivotStartDelta(m_pivotPoint, idx, 0);
      m_dottedIndex = idx;
    }
    else if (addToSelection) {
      //
      // Toggle the selection state of the clicked item
      //
      m_dottedIndex = idx;
      item.setSelected(!item.isSelected());
      m_pivotPoint = m_dottedIndex;
      refresh();
    }
    else if (selectRange) {
      //
      // Deselect current items, then select the range.
      //
      deselectAllItems(false);
      if (m_pivotPoint == null) {
        m_pivotPoint = m_dottedIndex;
      }

      selectItemsFromPivotStartDelta(m_pivotPoint, idx, 0);
      m_dottedIndex = idx;
      //scrollItemAtIndexToVisible(m_dottedIndex);
    } else {
      m_dottedIndex = idx;
      deselectAllItems(false);
      m_pivotPoint = null;
      selectItemAtIndex(idx);
    }
  }

  public function mouseUp(event:NSEvent) {
    if (!m_enabled) {
      return;
    }
    sendActionTo(action(), target());
  }

  public function keyDown(event:NSEvent) {
    if (!m_enabled) {
      return;
    }
    var char:Number = event.keyCode;
    var mods:Number = event.modifierFlags;
    var selectRange:Boolean = Boolean(mods & NSEvent.NSShiftKeyMask)
      && multipleSelection();

    //
    // Perform an action based on the character pressed
    //
    switch (char) {
      //
      // Selection movement
      //
      case NSUpArrowFunctionKey:
      case NSDownArrowFunctionKey:
      case Key.PGDN:
      case Key.PGUP:
      case Key.HOME:
      case Key.END:
        //
        // Determine jump amount
        //
        var selectionDelta:Number;
        if (char == Key.PGDN || char == Key.PGUP) {
          selectionDelta = (char == Key.PGUP) ? -m_numberOfVisibleItems : m_numberOfVisibleItems;
        }
        else if (char == Key.HOME || char == Key.END) {
          selectionDelta = (char == Key.HOME) ? -m_dottedIndex :
            m_items.count() - m_dottedIndex - 1;
        } else { // (char == NSUpArrowFunctionKey || char == NSDownArrowFunctionKey)
          selectionDelta = (char == NSUpArrowFunctionKey) ? -1 : 1;
        }

        //
        // Limit jump to bounds
        //
        if (m_dottedIndex + selectionDelta < 0) {
          selectionDelta = -m_dottedIndex;
        }
        else if (m_dottedIndex + selectionDelta >= m_items.count()) {
          selectionDelta = m_items.count() - m_dottedIndex - 1;
        }

        //
        // Only deselect if we're not selecting a range
        //
        if (!selectRange) {
          deselectAllItems(false);
          selectItemAtIndex(m_dottedIndex + selectionDelta);
          m_pivotPoint = null;
        } else {
          if (m_pivotPoint == null) {
            m_pivotPoint = m_dottedIndex;
          }
          selectItemsFromPivotStartDelta(m_pivotPoint, m_dottedIndex, selectionDelta);
        }

        //
        // Change the dotted index
        //
        m_dottedIndex += selectionDelta;

        //
        // Send an action if necessary
        //
        if (!m_sendsActionOnEnterOnly) {
          sendActionTo(action(), target());
        }

        return;

      case NSNewlineCharacter:
      case NSEnterCharacter:
      case NSCarriageReturnCharacter:
        sendActionTo(action(), target());
        return;
      case NSEscapeCharacter:
        deselectAllItems();
        sendActionTo(action(), target());
        return;
    }
    super.keyDown(event);
  }

  public function scrollWheel(event:NSEvent):Void {
    m_scrollIndex -= event.deltaY > 0 ? 1 : -1;
    if (m_scrollIndex < 0) {
      m_scrollIndex = 0;
    } else if (m_scrollIndex > m_maxScrollAmount) {
      m_scrollIndex = m_maxScrollAmount;
    }
    
    refresh();
  }
  
  //******************************************************
  //*                   Scrolling
  //******************************************************

  /**
   * Scrolls the list so that the item at <code>index</code> is visible.
   */
  public function scrollItemAtIndexToVisible(index:Number):Boolean {
    if (index < 0) {
      index = 0;
    } else if (index > (m_items.count()-1)) {
      index = m_items.count()-1;
    }
    if (index < m_scrollIndex) {
      m_scrollIndex = index;
      refresh();
      return true;
    } else if (index + 1 >= (m_scrollIndex + m_numberOfVisibleItems)) {
      m_scrollIndex = index - m_numberOfVisibleItems + 2;
      if (m_scrollIndex > m_maxScrollAmount) {
        m_scrollIndex = m_maxScrollAmount;
      }
      refresh();
      return true;
    }
    return false;
  }

  /**
   * Scrolls the list so that the item at <code>index</code> is at the top
   * of the visible items.
   */
  public function scrollItemAtIndexToTop(index:Number):Void {
    if (index < 0) {
      index = 0;
    } else if (index > m_maxScrollAmount) {
      index = m_maxScrollAmount;
    }
    m_scrollIndex = index;
    refresh();
  }

  /**
   * Returns <code>true</code> if the item <code>item</code> is visible
   * or <code>false</code> if it is not.
   */
  public function isItemVisible(item:ASListItem):Boolean {
    var idx:Number = indexOfItem(item);
    if (idx == NSObject.NSNotFound) {
      return false;
    }

    return isItemAtIndexVisible(idx);
  }

  /**
   * Returns <code>true</code> if the item at <code>itemIdx</code> is visible
   * or <code>false</code> if it is not.
   */
  public function isItemAtIndexVisible(itemIdx:Number):Boolean {
    return itemIdx >= 0
        && itemIdx < m_items.count()
        && itemIdx >= m_scrollIndex
        && itemIdx < m_scrollIndex + m_numberOfVisibleItems;
  }

  //******************************************************
  //*               Setting the frame
  //******************************************************

  public function setFrame(rect:NSRect) {
  	super.setFrame(rect);
    var scrollerWidth:Number = NSScroller.scrollerWidth();
    m_scroller.setFrame(new NSRect(m_frame.size.width-scrollerWidth-1, 1, scrollerWidth, m_frame.size.height-2));
    m_numberOfVisibleItems = Math.floor(m_frame.size.height/m_itemHeight);
  	resetTextFields();
    computeValues();
  	refresh();
  }

  public function setFrameSize(size:NSSize) {
  	super.setFrameSize(size);
    var scrollerWidth:Number = NSScroller.scrollerWidth();
    m_scroller.setFrame(new NSRect(m_frame.size.width-scrollerWidth-1, 1, scrollerWidth, m_frame.size.height-2));
    m_numberOfVisibleItems = Math.floor(m_frame.size.height/m_itemHeight);
  	resetTextFields();
    computeValues();
  	refresh();
  }

  //******************************************************
  //*       Getting an item based on mouse position
  //******************************************************

  /**
   * <p>Returns the index of the item at the point <code>aPoint</code>.</p>
   *
   * <p>If no item can be found, {@link #NSNotFound} is returned.</p>
   *
   * <p><code>aPoint</code> must be expressed in the coordinate system of the
   * list.</p>
   */
  public function getItemIndexForPoint(aPoint:NSPoint):Number {
    if (!bounds().pointInRect(aPoint)) {
      return NSObject.NSNotFound;
    }

    var idx:Number = m_scrollIndex + Math.floor(aPoint.y / m_itemHeight);
    if (idx > m_items.count() || idx < 0) {
      return NSObject.NSNotFound;
    }

    return idx;
  }

  /**
   * <p>Returns the the item at the point <code>aPoint</code>.</p>
   *
   * <p>If no item can be found, <code>null</code> is returned.</p>
   *
   * <p><code>aPoint</code> must be expressed in the coordinate system of the
   * list.</p>
   */
  public function getItemForPoint(aPoint:NSPoint):ASListItem {
    var idx:Number = getItemIndexForPoint(aPoint);
    if (idx == NSObject.NSNotFound) {
      return null;
    }

    return itemAtIndex(idx);
  }

  //******************************************************
  //*                Multiple selection
  //******************************************************

  /**
   * Returns whether multiple selection is supported by the list.
   * <code>true</code> is multiple selection, <code>false</code> is single
   * selection.
   *
   * The default value is <code>false</code>.
   */
  public function multipleSelection():Boolean {
    return m_multipleSelection;
  }

  /**
   * Sets whether multiple selection is supported by the list. <code>true</code>
   * allows multiple selection, <code>false</code> is single selection only.
   *
   * The default value is <code>false</code>.
   */
  public function setMultipleSelection(flag:Boolean):Void {
    m_multipleSelection = flag;
  }
  
  /**
   * Returns whether adding to a selection is triggered by ctrl+clicking (false)
   * or just clicking (true).
   */
  public function toggleSelection():Boolean {
    return m_toggleSelection;
  }
  
  /**
   * Sets whether adding to a selection is triggered by ctrl+clicking (false)
   * or just clicking (true).
   */
  public function setToggleSelection(flag:Boolean):Void {
    m_toggleSelection = flag;
  }
  
  //******************************************************
  //*                   Drawing
  //******************************************************

  public function drawRect(rect:NSRect) {
    m_mcBounds.clear();
    
    var theme:ASThemeProtocol = ASTheme.current();
    if (m_drawsBackground) {
      theme.drawListWithRectInView(rect, this);
    } else {
      if (m_backgroundColor) {
        ASDraw.fillRectWithRect(m_mcBounds, rect, m_backgroundColor.value, m_backgroundColor.alphaComponent()*100);
      }
      if (m_borderColor) {
        ASDraw.drawRectWithRect(m_mcBounds, new NSRect(0,0,rect.size.width-1, rect.size.height-1), m_borderColor.value, m_borderColor.alphaComponent()*100);
      }
    }

    //
    // Draw selection where necessary
    //
    for(var i:Number = 0;i<m_numberOfVisibleItems;i++) {
      if (m_textFields[i].textColor == 0xffffff) {
        theme.drawListSelectionWithRectInView(
          new NSRect(0,i*m_itemHeight,rect.size.width-1, m_itemHeight), this);
        //ASDraw.fillRectWithRect(m_mcBounds, new NSRect(0,i*m_itemHeight,rect.size.width-1, m_itemHeight), 0x000000);
      }
    }
    
    //
    // Draw images if applicable
    //
    if (m_showListItemImages) {
    	var pt:NSPoint = new NSPoint(8, 0);
    	var arr:Array = m_items.internalList();
    	var len:Number = arr.length;
    	var first:Number = m_scrollIndex;
    	for (var i:Number = 0; i < m_numberOfVisibleItems; i++) {
    		var idx:Number = i + first;
    		if (idx >= len) {
    			break;
    		}
    		
    		pt.y = m_textFields[i]._y;
    		var item:ASListItem = ASListItem(arr[idx]); 
    		var img:NSImage = item.image();
    		if (img == null) {
    			continue;
    		}
    		img.lockFocus(m_mcBounds);
    		img.drawAtPoint(pt);
    		img.unlockFocus();
    	}
    }

    if (m_showsFirstResponder) {
      theme.drawFirstResponderWithRectInView(rect, this);
// showing the dotted item
//      if (isItemAtIndexVisible(m_dottedIndex)) {
//      	m_mcBounds.lineStyle(2, 0xCCCCCC, 100);
//        ASDraw.drawDashedRectWithRect(m_mcBounds,
//          (new NSRect(0,(m_dottedIndex - m_scrollIndex) * m_itemHeight, rect.size.width - 1, m_itemHeight)).insetRect(2, 2),
//          .3, 5);
//        m_mcBounds.lineStyle(undefined);
//      }
    }
  }

  //******************************************************
  //*      Implementing the target/action mechanism
  //******************************************************

  /**
   * Returns the name of the method that will be called on {@link #target()}
   * when selection changes.
   */
  public function action():String {
    return m_action;
  }

  /**
   * Sets the action that will be called on {@link #target()} when
   * selection changes to <code>action</code>.
   */
  public function setAction(action:String):Void {
    m_action = action;
  }

  /**
   * Returns the object that will have its {@link #action} method called
   * when selection changes.
   */
  public function target():Object {
    return m_target;
  }

  /**
   * Sets the object that will have its {@link #action} method called
   * when selection changes to <code>target</code>.
   */
  public function setTarget(target:Object):Void {
    m_target = target;
  }
  
  /**
   * Returns the name of the method that will be called on {@link #target}
   * when a list item is double clicked.
   */
  public function doubleAction():String {
    return m_dblAction;
  }

  /**
   * Sets the action that will be called on {@link #target} when
   * selection changes to <code>action</code>.
   */
  public function setDoubleAction(action:String):Void {
    m_dblAction = action;
  }
  
  public function setSendsActionOnEnterOnly(value:Boolean):Void {
    m_sendsActionOnEnterOnly = value;
  }

  public function sendsActionOnEnterOnly():Boolean {
    return m_sendsActionOnEnterOnly;
  }

  //******************************************************
  //*             MovieClip (ActionStep-only)
  //******************************************************
  
  private function requiresMask():Boolean {
    return false;
  }
}