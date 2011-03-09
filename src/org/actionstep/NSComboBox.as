/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSComboBoxCell;
import org.actionstep.NSComboBoxCellDataSource;
import org.actionstep.NSEvent;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTextField;
import org.actionstep.ASUtils;

/**
 * <p>
 * An <code>NSComboBox</code> is a kind of <code>NSControl</code> that allows 
 * you to either enter text directly (as you would with an 
 * <code>NSTextField</code>) or click the attached arrow at the right of the 
 * combo box and select from a displayed (“pop-up”) list of items.
 * </p>
 * <p>
 * The NSComboBox class uses {@link NSComboBoxCell} to implement its user 
 * interface.
 * </p>
 * <p>
 * Also see the {@link NSComboBoxDataSource} informal protocol, which declares 
 * the methods that an NSComboBox uses to access the contents of its data source
 * object.
 * </p>
 * <p>
 * If you intend to use a delegate with the combobox, be sure to examine
 * <code>org.actionstep.comboBox.ASComboBoxDelegate</code> for available 
 * delegate methods.
 * </p>
 *
 * @author Richard Kilmer 
 * @author Scott Hyndman
 */
class org.actionstep.NSComboBox extends NSTextField {

  //******************************************************
  //*                 Notifications
  //******************************************************
  
  /**
   * <p>
   * Posted after the pop-up list selection of the NSComboBox changes.
   * </p>
   * <p>
   * The notification object is the NSComboBox whose selection changed. This 
   * notification does not contain a userInfo dictionary.
   * </p>
   */
  public static var NSComboBoxSelectionDidChangeNotification:Number
    = ASUtils.intern("NSComboBoxSelectionDidChangeNotification");
    
  /**
   * <p>
   * Posted whenever the pop-up list selection of the NSComboBox is changing.
   * </p>
   * <p>
   * The notification object is the NSComboBox whose selection changed. This 
   * notification does not contain a userInfo dictionary.
   * </p>
   */
  public static var NSComboBoxSelectionIsChangingNotification:Number
    = ASUtils.intern("NSComboBoxSelectionIsChangingNotification");

  /**
   * <p>
   * Posted whenever the pop-up list of the NSComboBox is about to be dismissed.
   * </p>
   * <p>
   * The notification object is the NSComboBox whose selection changed. This 
   * notification does not contain a userInfo dictionary.
   * </p>
   */    
  public static var NSComboBoxWillDismissNotification:Number
    = ASUtils.intern("NSComboBoxWillDismissNotification");

  /**
   * <p>
   * Posted whenever the pop-up list of the NSComboBox is going to be displayed.
   * </p>
   * <p>
   * The notification object is the NSComboBox whose selection changed. This 
   * notification does not contain a userInfo dictionary.
   * </p>
   */    
  public static var NSComboBoxWillPopUpNotification:Number
    = ASUtils.intern("NSComboBoxWillPopUpNotification");

  //******************************************************
  //*                  Class members
  //******************************************************

  /**
   * Cell class used by the combobox.
   */
  private static var g_cellClass:Function = NSComboBoxCell;

  //******************************************************
  //*                  Construction
  //******************************************************
  
  /**
   * Creates a new instance of NSComboBox.
   */
  public function NSComboBox() {
  }
  
  /**
   * Initializes the combobox with a frame rectangle of <code>rect</code>.
   */
  public function initWithFrame(rect:NSRect):NSComboBox {
    super.initWithFrame(rect);
    return this;
  }
  
  //******************************************************
  //*             Setting display attributes
  //******************************************************
  
  /**
   * Returns a Boolean value indicating whether the receiver will display a 
   * vertical scroller.
   * 
   * @see #numberOfItems()
   * @see #numberOfVisibleItems()
   */
  public function hasVerticalScroller():Boolean {
    return NSComboBoxCell(m_cell).hasVerticalScroller();
  }
  
  /**
   * Returns the horizontal and vertical spacing between cells in the receiver’s
   * pop-up list.
   * 
   * @see #itemHeight()
   * @see #numberOfVisibleItems()
   */
  public function intercellSpacing():NSSize {
    return NSComboBoxCell(m_cell).intercellSpacing();
  }
  
  /**
   * Returns whether the combo box button is set to display a border.
   * 
   * @see #setButtonBordered()
   */
  public function isButtonBordered():Boolean {
    return NSComboBoxCell(m_cell).isButtonBordered();
  }
  
  /**
   * Returns the height of each item in the receiver’s pop-up list.
   * 
   * @see #intercellSpacing()
   * @see #numberOfVisibleItems()
   */
  public function itemHeight():Number {
    return NSComboBoxCell(m_cell).itemHeight();
  }
  
  /**
   * Returns the maximum number of items visible in the pop-up list.
   * 
   * @see #numberOfItems()
   */
  public function numberOfVisibleItems():Number {
    return NSComboBoxCell(m_cell).numberOfVisibleItems();
  }
  
  /**
   * Determines whether the button in the combo box is displayed with a border.
   * 
   * @see #isButtonBordered()
   */
  public function setButtonBordered(value:Boolean) {
    NSComboBoxCell(m_cell).setButtonBordered(value);
    setNeedsDisplay(true);
  }
  
  /**
   * <p>
   * Determines whether the receiver displays a vertical scroller.
   * </p>
   * <p>
   * If <code>flag</code> is <code>false</code> and the combo box has more list 
   * items (either in its internal item list or from its data source) than are 
   * allowed by {@link #numberOfVisibleItems()}, only a subset are displayed. 
   * The NSComboBox class' scroll... methods can be used to position this subset
   * within the pop-up list.
   * </p>
   * 
   * @see #numberOfItems()
   * @see #scrollItemAtIndexToTop()
   * @see #scrollItemAtIndexToVisible()
   */
  public function setHasVerticalScroller(flag:Boolean) {
    NSComboBoxCell(m_cell).setHasVerticalScroller(flag);
  }
  
  /**
   * <p>
   * Sets the spacing between pop-up list items.
   * </p>
   * <p>
   * <code>spacing</code> is the new width and height between pop-up list items.
   * The default intercell spacing is <code>(3.0, 2.0)</code>.
   * </p>
   * 
   * @see #setItemHeight()
   * @see #setNumberOfVisibleItems()
   */
  public function setIntercellSpacing(spacing:NSSize) {
    NSComboBoxCell(m_cell).setIntercellSpacing(spacing);
  }
  
  /**
   * Sets the height for items.
   * 
   * @see #setIntercellSpacing()
   * @see #setNumberOfVisibleItems()
   */
  public function setItemHeight(height:Number) {
    NSComboBoxCell(m_cell).setItemHeight(height);
  }
  
  /**
   * Sets the maximum number of items that are visible in the receiver’s pop-up 
   * list.
   * 
   * @see #numberOfItems()
   * @see #setItemHeight()
   * @see #setIntercellSpacing()
   */
  public function setNumberOfVisibleItems(value:Number) {
    NSComboBoxCell(m_cell).setNumberOfVisibleItems(value);
  }
  
  //******************************************************
  //*             Setting a data source
  //******************************************************
  
  public function dataSource():NSComboBoxCellDataSource {
    return NSComboBoxCell(m_cell).dataSource();
  } 
  
  public function setDataSource(object:NSComboBoxCellDataSource) {
    NSComboBoxCell(m_cell).setDataSource(object);
  }
  
  public function setUsesDataSource(value:Boolean) {
    NSComboBoxCell(m_cell).setUsesDataSource(value);
  }
  
  public function usesDataSource():Boolean {
    return NSComboBoxCell(m_cell).usesDataSource();
  }
  
  //******************************************************
  //*           Working with an internal list
  //******************************************************
  
  public function addItemsWithObjectValues(objects:NSArray) {
    NSComboBoxCell(m_cell).addItemsWithObjectValues(objects);
  }
  
  public function addItemWithObjectValue(object:Object) {
    NSComboBoxCell(m_cell).addItemWithObjectValue(object);
  }
  
  public function insertItemWithObjectValueAtIndex(object:Object, index:Number) {
    NSComboBoxCell(m_cell).insertItemWithObjectValueAtIndex(object, index);
  }
  
  public function objectValues():NSArray {
    return NSComboBoxCell(m_cell).objectValues();
  }
  
  public function removeAllItems() {
    NSComboBoxCell(m_cell).removeAllItems();
  }
  
  public function removeItemAtIndex(index:Number) {
    NSComboBoxCell(m_cell).removeItemAtIndex(index);
  }
  
  public function removeItemWithObjectValue(object:Object) {
    NSComboBoxCell(m_cell).removeItemWithObjectValue(object);
  }
  
  public function numberOfItems():Number {
    return NSComboBoxCell(m_cell).numberOfItems();
  }
  
  //******************************************************
  //*           Manipulating the displayed list
  //******************************************************
  
  public function indexOfItemWithObjectValue(object:Object):Number {
    return NSComboBoxCell(m_cell).indexOfItemWithObjectValue(object);
  }
  
  public function itemObjectValueAtIndex(index:Number):Object {
    return NSComboBoxCell(m_cell).itemObjectValueAtIndex(index);
  }
  
  public function noteNumberOfItemsChanged() {
    NSComboBoxCell(m_cell).noteNumberOfItemsChanged();
  }
  
  public function reloadData() {
    NSComboBoxCell(m_cell).reloadData();
  }
  
  public function scrollItemAtIndexToTop(index:Number) {
    NSComboBoxCell(m_cell).scrollItemAtIndexToTop(index);
  }
  
  public function scrollItemAtIndexToVisible(index:Number) {
    NSComboBoxCell(m_cell).scrollItemAtIndexToVisible(index);
  }
  
  //******************************************************
  //*            Manipulating the selection
  //******************************************************
  
  public function deselectItemAtIndex(index:Number) {
    NSComboBoxCell(m_cell).deselectItemAtIndex(index);
  }
  
  public function indexOfSelectedItem():Number {
    return NSComboBoxCell(m_cell).indexOfSelectedItem();
  }
  
  public function objectValueOfSelectedItem():Object {
    return NSComboBoxCell(m_cell).objectValueOfSelectedItem();
  }
  
  public function selectItemAtIndex(index:Number) {
    NSComboBoxCell(m_cell).selectItemAtIndex(index);
  }
  
  public function selectItemWithObjectValue(object:Object) {
    NSComboBoxCell(m_cell).selectItemWithObjectValue(object);
  }
  
  //******************************************************
  //*             Completing the text field
  //******************************************************
  
  /**
   * <p>
   * Returns a Boolean value indicating whether the receiver tries to complete 
   * what the user types in the text field.
   * </p>
   * 
   * @see #setCompletes()
   */
  public function completes():Boolean {
    return NSComboBoxCell(m_cell).completes();
  }
  
  /**
   * <p>
   * Sets whether the receiver tries to complete what the user types in the 
   * text field.
   * </p>
   * <p>
   * If {@link NSComboBoxCell#completedString()} returns a string that’s longer 
   * than the existing string, the combo box replaces the existing string with 
   * the returned string and selects the additional characters. If the user is 
   * deleting characters or adds characters somewhere besides the end of the 
   * string, the combo box does not try to complete it.
   * </p>
   */
  public function setCompletes(value:Boolean) {
    NSComboBoxCell(m_cell).setCompletes(value);
  }
  
  //******************************************************
  //*               Setting the delegate
  //******************************************************

  /**
   * <p>
   * Sets the combobox delegate.
   * </p>
   * <p>
   * The delegate can also respond to textfield delegate methods.
   * </p>
   * <p>
   * Be sure to examine <code>org.actionstep.comboBox.ASComboBoxDelegate</code> 
   * for available delegate methods.
   * </p>
   */
  public function setDelegate(delegate:Object):Void {
    super.setDelegate(delegate); // removes the old delegate
    
    mapComboBoxDelegateNotification("SelectionDidChange");
    mapComboBoxDelegateNotification("SelectionIsChanging");
    mapComboBoxDelegateNotification("WillPopUp");
    mapComboBoxDelegateNotification("WillDismiss");
  }

  /**
   * Maps a notification to a delegate method.
   */
  private function mapComboBoxDelegateNotification(name:String) {
    if (typeof(m_delegate["comboBox" + name]) == "function") {
      m_notificationCenter.addObserverSelectorNameObject(m_delegate, 
        "comboBox" + name, 
        ASUtils.intern("NSComboBox" + name + "Notification"), 
        this);
    }
  }
  
  //******************************************************
  //*                  Handle events
  //******************************************************

  public function mouseDown(event:NSEvent) {
  	if (!isEnabled()) {
  	  return;
  	}
    
    m_window.makeFirstResponder(this);
    var location:NSPoint = event.mouseLocation;
    location = convertPointFromView(location, null);
    if (NSComboBoxCell(m_cell).isPointInDropDownButton(location)) {
      NSComboBoxCell(m_cell).showListWindow();
    } else {
      super.mouseDown(event);
      return;
    }
  }

  public function keyDown(event:NSEvent) {
    var mods:Number = event.modifierFlags;
    var char:Number = event.keyCode;

    switch (char) {
      case NSUpArrowFunctionKey:
      case NSDownArrowFunctionKey:
        NSComboBoxCell(m_cell).showListWindow();
        return;
    }
    super.keyDown(event);
  }

  //******************************************************
  //*              Required by NSControl
  //******************************************************

  public static function cellClass():Function {
    return g_cellClass;
  }

  public static function setCellClass(cellClass:Function) {
    if (cellClass == null) {
      g_cellClass = NSComboBoxCell;
    } else {
      g_cellClass = cellClass;
    }
  }
}