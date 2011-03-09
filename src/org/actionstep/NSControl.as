/* See LICENSE for copyright and terms of use */

import org.actionstep.ASFieldEditor;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSApplication;
import org.actionstep.NSAttributedString;
import org.actionstep.NSCell;
import org.actionstep.NSColor;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSFont;
import org.actionstep.NSFormatter;
import org.actionstep.NSRect;
import org.actionstep.NSView;

/**
 * <p>
 * <code>NSControl</code> is an abstract base class for implementing user 
 * interfaces and provides fundamental features such as drawing on the screen, 
 * handling user events and sending action messages. It works alongside the 
 * <code>NSCell</code> class to share responsibilities.
 * </p>
 * 
 * <h3>About NSControl</h3>
 * <p>
 * NSControl is an abstract superclass that provides three fundamental features 
 * for implementing user-interface devices. First, as a subclass of NSView, 
 * NSControl draws, or coordinates the drawing of, the on-screen representation 
 * of the control. Second, it receives and responds to user-generated events 
 * within its bounds by overriding NSResponder’s {@link #mouseDown()} method and 
 * providing a position in the responder chain. Third, it implements the 
 * {@link #sendActionTo()} method to send an action message to the NSControl’s 
 * target object. Subclasses of NSControl defined in ActionStep are NSBrowser, 
 * NSButton (and its subclass NSPopUpButton), NSColorWell, NSImageView, NSMatrix 
 * (and its subclass NSForm), NSScroller, NSSlider, NSTableView, and 
 * NSTextField. Instances of concrete NSControl subclasses are often referred to 
 * as, simply, controls.
 * </p>
 * 
 * <h3>How Controls and Cells Interact</h3>
 * <p>
 * Many methods of NSControl—particularly methods that set or obtain values and 
 * attributes—have corresponding methods in NSCell. Sending a message to the 
 * control causes it to be forwarded to the control’s cell or (if a multi-cell 
 * control) its selected cell. However, many NSControl methods are effective 
 * only in controls with single cells (these are noted in the method 
 * descriptions).
 * </p>
 * <p>
 * An NSControl subclass doesn’t have to use an NSCell subclass to implement 
 * itself—NSScroller and NSColorWell are examples of NSControls that don’t. 
 * However, such subclasses have to take care of details NSCell would otherwise 
 * handle. Specifically, they have to override methods designed to work with a 
 * cell. What’s more, the lack of a cell means you can’t make use of NSMatrix 
 * capability for managing multi-cell arrays such as radio buttons.
 * </p>
 * 
 * <h3>Additional Information</h3>
 * <p>
 * Additional information about NSControl specifics can be found at
 * <a href="http://developer.apple.com/documentation/Cocoa/Conceptual/ControlCell/index.html">
 * Control and Cell Programming Topics for Cocoa</a>
 * </p>
 * 
 * <h3>Subclassing notes:</h3>
 * <ul>
 * <li>
 * {@link #setCellClass()} and {@link #cellClass()} must be overridden in 
 * subclasses.
 * </li>
 * </ul>
 *     
 * @author Richard Kilmer
 */
class org.actionstep.NSControl extends NSView {
  
  //******************************************************                               
  //*                  Class members
  //******************************************************  
  
  private static var g_cellClass:Function;
  private static var g_actionCellClass:Function;

  //******************************************************                               
  //*                 Member variables
  //******************************************************
  
  private var m_trackingData:Object;
  private var m_app:NSApplication;
  private var m_target:Object; // for subclasses  
  private var m_cell:NSCell;
  private var m_tag:Number;
  private var m_ignoresMultiClick:Boolean;
  private var m_enabled:Boolean;
  
  //******************************************************                               
  //*                  Construction
  //******************************************************
  
  /**
   * Creates a new instance of the <code>NSControl</code> class.
   */
  public function NSControl() {
    m_enabled = true;
  }
  
  public function initWithFrame(theFrame:NSRect):NSControl {
    super.initWithFrame(theFrame);
    //doesn't work if in declaration
    m_app = NSApplication.sharedApplication();
    m_cell = new (this.getClass().cellClass())();
    m_cell.init();
    return this;
  }
  
  //******************************************************
  //*          Releasing the object from memory
  //******************************************************
  
  /**
   * Clears all references to external objects.
   */
  public function release():Boolean {
    setTarget(null);
    return super.release();
  }
  
  //******************************************************                               
  //*                 Managing the cell
  //******************************************************
  
  /**
   * Returns the control's cell.
   */
  public function cell():NSCell {
    return m_cell;
  }
  
  /**
   * Sets the control's cell to <code>newCell</code>.
   * 
   * If <code>newCell</code> is not an instance of <code>NSCell</code>, an
   * exception will be raised.
   */
  public function setCell(newCell:NSCell):Void {
    if (!(newCell instanceof org.actionstep.NSCell)) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        "NSTypeMismatchException",
        "Provided cell is not an instance of the cell class",
        null);
      trace(e);
      throw e;
    }
    m_cell = newCell;
  }
  
  //******************************************************                               
  //*         Enabling and disabling the control
  //******************************************************
  
  /**
   * Sets whether the control’s cell—or if there is no associated cell, the 
   * <code>NSControl</code> itself—is active (that is, whether it tracks the 
   * mouse and sends its action to its target).
   */
  public function setEnabled(value:Boolean):Void {
  	var cell:NSCell = selectedCell();
  	if (cell != null) {
      selectedCell().setEnabled(value);
      if (!value) {
        abortEditing();
      }
  	}
  	
  	m_enabled = value;
    setNeedsDisplay(true);
  }
  
  /**
   * Returns whether the receiver reacts to mouse events.
   */
  public function isEnabled():Boolean {
  	var cell:NSCell = selectedCell();
  	if (cell != null) {
  	  return cell.isEnabled();
  	}
  	
    return m_enabled;
  }
  
  //******************************************************                               
  //*            Identifying the selected cell
  //******************************************************
  
  /**
   * Returns the control’s selected cell.
   * 
   * The default implementation for <code>NSControl</code> simply returns the 
   * associated cell (or <code>null</code> if no cell has been set). Subclasses 
   * of <code>NSControl</code> that manage multiple cells (such as 
   * <code>NSMatrix</code> and <code>NSForm</code>) override this method to 
   * return the cell selected by users.
   */
  public function selectedCell():NSCell {
    return m_cell;
  }
  
  /**
   * Returns the tag integer of the control’s selected cell or –1 if there is no
   * selected cell.
   */
  public function selectedTag():Number {
    var cell:NSCell = selectedCell();
    if (cell == null) {
      return -1;
    }
    return cell.tag();
  }
  
  //******************************************************                               
  //*            Setting the control’s value
  //******************************************************
  
  /**
   * Returns the double value of the control's cell.
   */
  public function doubleValue():Number {
    return selectedCell().doubleValue();
  }

  /**
   * Sets the value of the control’s selected cell to <code>value</code>.
   */
  public function setDoubleValue(value:Number):Void {
    abortEditing();
    selectedCell().setDoubleValue(value);
    if(!(selectedCell() instanceof actionCellClass())) {
      setNeedsDisplay(true);
    }
  }

  /**
   * Returns the float value of the control's cell.
   */
  public function floatValue():Number {
    return selectedCell().floatValue();
  }

  /**
   * Sets the value of the control’s selected cell to <code>value</code>.
   */
  public function setFloatValue(value:Number):Void {
    abortEditing();
    selectedCell().setFloatValue(value);
    if(!(selectedCell() instanceof actionCellClass())) {
      setNeedsDisplay(true);
    }
  }

  /**
   * Returns the int value of the control's cell.
   */
  public function intValue():Number {
    return selectedCell().intValue();
  }

  /**
   * Sets the value of the control’s selected cell to <code>value</code>.
   */
  public function setIntValue(value:Number):Void {
    abortEditing();
    selectedCell().setIntValue(value);
    if(!(selectedCell() instanceof actionCellClass())) {
      setNeedsDisplay(true);
    }
  }

  /**
   * Returns the string value of the control's cell.
   */
  public function stringValue():String {
    return selectedCell().stringValue();
  }

  /**
   * Sets the value of the control’s selected cell to <code>value</code>.
   */
  public function setStringValue(value:String):Void {
    abortEditing();
    selectedCell().setStringValue(value);
    if(!(selectedCell() instanceof actionCellClass())) {
      setNeedsDisplay(true);
    }
  }
  
  /**
   * Returns the object value of the control's cell.
   */
  public function objectValue():String {
    //! FIXME This should return an object.
    return String(selectedCell().objectValue());
  }

  /**
   * Sets the value of the control’s selected cell to <code>value</code>.
   */
  public function setObjectValue(value:String):Void {
    //! FIXME argument shouldn't be a string
    abortEditing();
    selectedCell().setObjectValue(value);
    if(!(selectedCell() instanceof actionCellClass())) {
      setNeedsDisplay(true);
    }
  }
  
  //******************************************************                               
  //*          Interacting with other controls
  //******************************************************
  
  /**
   * Sets the double-precision floating-point value of the control’s selected 
   * cell to the value obtained by sending a <code>#doubleValue</code> message 
   * to <code>sender</code>.
   */
  public function takeDoubleValueFrom(sender:Object):Void {
    selectedCell().takeDoubleValueFrom(sender);
    setNeedsDisplay(true);
  }

  /**
   * Sets the double-precision floating-point value of the control’s selected 
   * cell to the value obtained by sending a <code>#floatValue</code> message 
   * to <code>sender</code>.
   */
  public function takeFloatValueFrom(sender:Object):Void {
    selectedCell().takeFloatValueFrom(sender);
    setNeedsDisplay(true);
  }

  /**
   * Sets the double-precision floating-point value of the control’s selected 
   * cell to the value obtained by sending a <code>#intValue</code> message 
   * to <code>sender</code>.
   */
  public function takeIntValueFrom(sender:Object):Void {
    selectedCell().takeIntValueFrom(sender);
    setNeedsDisplay(true);
  }

  /**
   * Sets the double-precision floating-point value of the control’s selected 
   * cell to the value obtained by sending a <code>#objectValue</code> message 
   * to <code>sender</code>.
   */
  public function takeObjectValueFrom(sender:Object):Void {
    selectedCell().takeObjectValueFrom(sender);
    setNeedsDisplay(true);
  }
  
  /**
   * Sets the double-precision floating-point value of the control’s selected 
   * cell to the value obtained by sending a <code>#stringValue</code> message 
   * to <code>sender</code>.
   */
  public function takeStringValueFrom(sender:Object):Void {
    selectedCell().takeStringValueFrom(sender);
    setNeedsDisplay(true);
  }
  
  //******************************************************                               
  //*               Formatting text
  //******************************************************
  
  /**
   * Returns the alignment mode of the text in the receiver’s cell.
   */
  public function alignment():NSTextAlignment {
    var cell:NSCell = selectedCell();
    if (cell != null) {
      return cell.alignment();
    } else {
      return NSTextAlignment.NSNaturalTextAlignment;
    }
  }
  
  /**
   * Sets the alignment of text in the receiver’s cell and, if the cell is being
   * edited, aborts editing and updates the cell.
   */
  public function setAlignment(value:NSTextAlignment):Void {
    var cell:NSCell = selectedCell();
    if (cell != null) {
      abortEditing();
      cell.setAlignment(value);
      if(!(cell instanceof actionCellClass())) {
        updateCell();
      }
    }

  }
  
  /**
   * Returns the NSFont used to draw text in the receiver’s cell.
   */
  public function font():NSFont {
    var cell:NSCell = selectedCell();
    if (cell != null) {
      return cell.font();
    } else {
      return null;
    }
  }
  
  /**
   * Sets the font used to draw text in the receiver’s cell to 
   * <code>value</code>.
   */
  public function setFont(value:NSFont):Void {
// FIXME var currentEditor:ASFieldEditor = currentEditor();
	var currentEditor:Object = currentEditor();
    var cell:NSCell = selectedCell();
    if (cell != null) {
      if (currentEditor != null) { 
        currentEditor.setFont(value); 
      }
      cell.setFont(value);
    }
  }
  
  /**
   * Returns this cell's font color.
   */
  public function fontColor():NSColor {
    var cell:NSCell = selectedCell();
    if (cell != null) {
      return cell.fontColor();
    } else {
      return null;
    }
  }
  
  /**
   * Sets this cell's font color to <code>color</code>.
   */
  public function setFontColor(color:NSColor) {
    var cell:NSCell = selectedCell();
    if (cell != null) {
      abortEditing();
      cell.setFontColor(color);
      if(!(cell instanceof actionCellClass())) {
        updateCell();
      }
    }
  }
  
  /**
   * Returns the receiver’s formatter.
   */
  public function formatter():NSFormatter {
    return selectedCell().formatter();
  }
  
  /**
   * Sets the receiver’s formatter to <code>value</code>.
   */
  public function setFormatter(value:NSFormatter):Void {
    var cell:NSCell = selectedCell();
    if (cell != null) {
      cell.setFormatter(value);
      if (!(cell instanceof g_actionCellClass)) {
        setNeedsDisplay(true);
      }
    }
  }
  
  //******************************************************                               
  //*             Managing the field editor
  //******************************************************
  
  /**
   * Terminates and discards any editing of text displayed by the receiver and 
   * removes the field editor’s delegate.
   * 
   * Returns <code>true</code> if there was a field editor associated with the 
   * control, <code>false</code> otherwise.
   */
  public function abortEditing():Boolean {
  	// FIXME
//    var editor:ASFieldEditor = currentEditor();
//    if (editor == null) {
//      return false;
//    }
//    
//    editor.setDelegate(null);
//    editor.endInstanceEdit();
    return false;
  }

  /**
   * If the receiver is being edited—that is, it has a field editor and is the 
   * first responder of its <code>NSWindow</code>—this method returns the field 
   * editor; otherwise, it returns <code>null</code>.
   */
  public function currentEditor():ASFieldEditor {
//    var fe:ASFieldEditor = ASFieldEditor.instance();    
//    if (fe.cell() == selectedCell()) {
//      return fe;
//    }
//    
    return null;
  }
  
  /**
   * Validates the user’s changes to text in a cell of the receiving control.
   * 
   * Validation sets the object value of the cell to the current contents of the
   * cell’s editor, storing it as a string or an attributed string object based 
   * on the attributes of the editor.
   */
  public function validateEditing():Void {
    var editor:ASFieldEditor = currentEditor();
    if (editor == null) {
      return;
    }
    
    setStringValue(editor.string());
  }
  
  //******************************************************                               
  //*               Resizing the control
  //******************************************************
  
  /**
   * Recomputes any internal sizing information for the receiver.
   */
  public function calcSize():Void {
    var e:NSException = NSException.exceptionWithNameReasonUserInfo(
      NSException.NSGeneric,
      "Method not implemented.",
      null);
    trace(e);
    throw e; 
  }

  /**
   * Changes the width and the height of the receiver’s frame so they are the 
   * minimum needed to contain its cell.
   */
  public function sizeToFit() { 
    setFrameSize(m_cell.cellSize());
  }
  
  //******************************************************                               
  //*                 Displaying a cell
  //******************************************************
  
  /**
   * Selects <code>cell</code> (by setting its state to 
   * <code>NSCell.NSOnState</code>) and redraws the <code>NSControl</code> if 
   * <code>cell</code> is a cell of the receiver and is unselected.
   */
  public function selectCell(cell:NSCell) {
    if (cell == m_cell) {
      m_cell.setState(NSCell.NSOnState);
      setNeedsDisplay(true);
    }
  }
  
  /**
   * If <code>cell</code> is the cell used to implement the receiver, then the 
   * receiver is displayed.
   */
  public function drawCell(cell:NSCell) {
    if (cell == m_cell) {
      mcBounds().clear();
      m_cell.drawWithFrameInView(m_bounds, this);
    }
  }
  
  /**
   * Draws the inside of the receiver’s cell (the area within a bezel or border)
   * specified by <code>cell</code>.
   */
  public function drawCellInside(cell:NSCell) {
    if (cell == m_cell) {
      m_cell.drawInteriorWithFrameInView(m_bounds, this);
    }
  }

  /**
   * Redisplays <code>cell</code> or marks it for redisplay.
   */
  public function updateCell(cell:NSCell) {
    setNeedsDisplay(true);
  }

  /**
   * Redisplays the inside of <code>cell</code> or marks it for redisplay.
   */
  public function updateCellInside(cell:NSCell) {
    setNeedsDisplay(true);
  }
  
  //******************************************************                               
  //*     Implementing the target/action mechanism
  //******************************************************
  
  /**
   * Returns the action-message selector (the method name of the method that 
   * will be called on <code>#target()</code>) of the receiver’s cell.
   */
  public function action():String {
    return m_cell.action();
  }
  
  /**
   * Sets the receiver’s action method to <code>value</code>.
   */
  public function setAction(value:String) {
    m_cell.setAction(value);
  }
  
  /**
   * Returns the target object of the receiver’s cell.
   */
  public function target():Object {
    return m_target;
  }
  
  /**
   * Sets the target object for the action message of the receiver’s cell to
   * <code>target</code>.
   */
  public function setTarget(target:Object) {
    m_target = target;
    m_cell.setTarget(target);
  }
  
  /**
   * Tells the NSApplication to trigger theAction in theTarget.
   *
   * If theAction is null, the call to sendActionTo is ignored. If theTarget
   * is null, NSApplication searches the responder chain for an object that 
   * can respond to the message.
   *
   * This method returns TRUE if a target responds to the message, and FALSE
   * otherwise.
   */
  public function sendActionTo(theAction:String, theTarget:Object):Boolean {
    if (theAction == null) {
      return false;
    }
    return m_app.sendActionToFrom(theAction, theTarget, this);
  }
  
  /**
   * Returns whether the receiver’s <code>NSCell</code> continuously sends its 
   * action message to its target during mouse tracking.
   */
  public function isContinuous():Boolean {
    return m_cell.isContinuous();
  }

  /**
   * Sets whether the receiver’s cell continuously sends its action message to 
   * its target as it tracks the mouse, depending on the Boolean value 
   * <code>flag</code>.
   */
  public function setContinuous(flag:Boolean) {
    m_cell.setContinuous(flag);
  }
  
  /**
   * Sets the conditions on which the receiver sends action messages to its 
   * target and returns a bit mask with which to detect the previous settings.
   */
  public function sendActionOn(mask:Number):Number {
    return m_cell.sendActionOn(mask);
  }
  
  //******************************************************                               
  //*    Getting and setting attributed string values
  //******************************************************
  
  public function setAttributedStringValue(
      attributedStringValue:NSAttributedString):Void {
    var sel:NSCell = selectedCell();
    abortEditing();
    sel.setAttributedStringValue(attributedStringValue);
    if (!(m_cell instanceof g_actionCellClass)) {
      setNeedsDisplay(true);
    }    
  }
  
  public function attributedString():NSAttributedString {
    var sel:NSCell = selectedCell();
    if (sel != null) {
      validateEditing();
      return sel.attributedStringValue();
    } else {
      return new NSAttributedString();
    }
  }

  //******************************************************                               
  //*        Setting and getting cell attributes
  //******************************************************

  /**
   * Sets the tag of the receiver to <code>value</code>.
   */
  public function setTag(value:Number) {
    m_tag = value;
  }

  /**
   * Returns the tag identifying the receiver (not the tag of the receiver’s 
   * cell).
   */
  public function tag():Number {
    return m_tag;
  }
  
  //******************************************************                               
  //*           Activating from the keyboard
  //******************************************************
  
  /**
   * Can be used to simulate a single mouse click on the receiver.
   */
  public function performClick() {
    m_cell.performClickWithFrameInView(bounds(), this);
  }
  
  /**
   * Returns whether the receiver refuses first responder status.
   */
  public function refusesFirstResponder():Boolean {
    return selectedCell().refusesFirstResponder();
  }
  
  /**
   * Sets whether the receiver refuses first responder status, depending on the 
   * Boolean value <code>flag</code>.
   */
  public function setRefusesFirstResponder(flag:Boolean) {
    selectedCell().setRefusesFirstResponder(flag);
  }
  
  public function acceptsFirstResponder():Boolean {
    return selectedCell().acceptsFirstResponder();
  }
  
  //******************************************************                               
  //*              Tracking the mouse
  //******************************************************
  
  /**
   * Returns the rectangle within which the mouse is tracked.
   */
  private function cellTrackingRect():NSRect {
    return m_bounds;
  }
  
  public function mouseDown(event:NSEvent) {
    if (!isEnabled()) {
      return;
    }
    if (m_ignoresMultiClick && event.clickCount > 1) {
      super.mouseDown(event);
      return;
    }
    // This is necessary because of the async requirements of Flash
    m_cell.setTrackingCallbackSelector(this, "cellTrackingCallback");
    m_trackingData = { 
      mouseDown: true, 
      //actionMask: (m_cell.isContinuous() ? m_cell.sendActionOn(NSEvent.NSPeriodicMask) : m_cell.sendActionOn(0)),
      eventMask: NSEvent.NSLeftMouseDownMask 
        | NSEvent.NSLeftMouseUpMask 
        | NSEvent.NSLeftMouseDraggedMask
        | NSEvent.NSMouseMovedMask  
        | NSEvent.NSOtherMouseDraggedMask 
        | NSEvent.NSRightMouseDraggedMask,
      mouseUp: false, 
      complete: false,
      bounds: cellTrackingRect()
    };
    mouseTrackingCallback(event);
  }
  
  public function cellTrackingCallback(mouseUp:Boolean) {
  	//trace("NSControl.cellTrackingCallback(mouseUp)");
    //change--set highlight iff mouseUp
    setNeedsDisplay(true);
    if(mouseUp) {
      m_cell.setHighlighted(false);
      //m_cell.sendActionOn(m_trackingData.actionMask);  
      m_cell.setTrackingCallbackSelector(null, null);
    } else {
      m_app.callObjectSelectorWithNextEventMatchingMaskDequeue(this, 
        "mouseTrackingCallback", m_trackingData.eventMask, true);
    }
  }
  
  public function mouseTrackingCallback(event:NSEvent) {
  	//trace("NSControl.mouseTrackingCallback(event)");
    if (event.type == NSEvent.NSLeftMouseUp) {
      m_cell.setHighlighted(false);
      setNeedsDisplay(true);
      //m_cell.sendActionOn(m_trackingData.actionMask);
      m_cell.setTrackingCallbackSelector(null, null);
      m_cell.mouseTrackingCallback(event);
      return;
    }
    if(event.view == this && cellTrackingRect().pointInRect(
        convertPointFromView(event.mouseLocation, null))) {
      m_cell.setHighlighted(true);
      setNeedsDisplay(true);
      m_cell.trackMouseInRectOfViewUntilMouseUp(event, m_trackingData.bounds, 
        this, m_cell.getClass().prefersTrackingUntilMouseUp());
      return;
    }
    m_app.callObjectSelectorWithNextEventMatchingMaskDequeue(this, 
      "mouseTrackingCallback", m_trackingData.eventMask, true);
  }
  
  /**
   * Sets whether the receiver ignores multiple clicks made in rapid succession,
   * depending on the Boolean value <code>flag</code>.
   */
  public function setIgnoresMultiClick(flag:Boolean) {
    m_ignoresMultiClick = flag;
  }
  
  /**
   * Returns whether the receiver ignores multiple clicks made in rapid 
   * succession.
   * 
   * By default, controls treat double clicks as two distinct clicks, triple 
   * clicks as three distinct clicks, and so on. However, when an 
   * <code>NSControl</code> returning <code>true</code> to this method receives 
   * multiple clicks (within a predetermined interval), each mouseDown event 
   * after the first is passed on to super.
   */
  public function ignoresMultiClick():Boolean {
    return m_ignoresMultiClick;
  }
 
  //******************************************************
  //*              Drawing the control
  //******************************************************
  
  public function drawRect(rect:NSRect) {
    drawCell(m_cell);
  }
  
  //******************************************************                               
  //*             Setting the cell class
  //******************************************************
  
  /**
   * <p>Sets the cell class to <code>klass</code> (must be a subclass of
   * {@link NSCell}). An instance of the cell class is instantiated for
   * every new control.</p>
   *
   * <p><strong>NOTE:</strong> Must be overridden in subclasses.</p>
   */
  public static function setCellClass(klass:Function) {
    g_cellClass = klass;
  }

  /**
   * <p>Returns the cell class.</p>
   *
   * <p><strong>NOTE:</strong> Must be overridden in subclasses.</p>
   */  
  public static function cellClass():Function {
    if (g_cellClass == undefined) {
      g_cellClass = org.actionstep.NSCell;
    }
    return g_cellClass;
  }

  public static function setActionCellClass(klass:Function) {
    g_actionCellClass = klass;
  }

  public static function actionCellClass():Function {
    if (g_actionCellClass == undefined) {
      g_actionCellClass = org.actionstep.NSActionCell;
    }
    return g_actionCellClass;
  }
  
  //******************************************************                               
  //*                 Notifications
  //******************************************************
  
  public static var NSControlTextDidBeginEditingNotification:Number 
    = ASUtils.intern("NSControlTextDidBeginEditingNotification");
  public static var NSControlTextDidChangeNotification:Number 
    = ASUtils.intern("NSControlTextDidChangeNotification");
  public static var NSControlTextDidEndEditingNotification:Number 
    = ASUtils.intern("NSControlTextDidEndEditingNotification");
}