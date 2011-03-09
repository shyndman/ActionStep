/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSInterfaceStyle;
import org.actionstep.NSArray;
import org.actionstep.NSBeep;
import org.actionstep.NSEvent;
import org.actionstep.NSMenu;
import org.actionstep.NSObject;
import org.actionstep.NSUndoManager;
import org.actionstep.events.ASKeyBindingsTable;
import org.actionstep.events.ASKeyBinding;

class org.actionstep.NSResponder extends NSObject {
  
  private var m_nextResponder:NSResponder;
  private var m_menu:NSMenu;
  private var m_interfaceStyle:NSInterfaceStyle;
  
  private function beep():Void {
    NSBeep.beep();
  }
  
  //******************************************************															 
  //*           Changing the first responder
  //******************************************************
  
  /**
   * <p>Overridden by subclasses to return <code>true</code> if the receiver can 
   * handle key events and action messages sent up the responder chain.</p>
   * 
   * <p>NSResponder’s implementation returns <code>false</code>, indicating that 
   * by default a responder object doesn’t agree to become first responder. 
   * Objects that aren’t first responder can receive mouse-down messages, but 
   * no other event or action messages.</p>
   * 
   * @see #becameFirstResponder()
   * @see #resignFirstResponder()
   */
  public function acceptsFirstResponder():Boolean {
    return false;
  }
  
  /**
   * <p>Notifies the receiver that it’s about to become first responder in its 
   * <code>NSWindow</code>.</p>
   * 
   * <p>NSResponder’s implementation returns <code>true</code>, accepting first 
   * responder status. Subclasses can override this method to update state or 
   * perform some action such as highlighting the selection, or to return 
   * <code>false</code>, refusing first responder status.</p>
   * 
   * <p>Use NSWindow’s {@link org.actionstep.NSWindow#makeFirstResponder()}, not 
   * this method, to make an object the first responder. Never invoke this 
   * method directly.</p>
   * 
   * @see #acceptsFirstResponder()
   * @see #resignFirstResponder()
   */
  public function becomeFirstResponder():Boolean {
    return true;
  }
  
  /**
   * Notifies the receiver that it’s been asked to relinquish its status as 
   * first responder in its <code>NSWindow</code>.
   * 
   * <p>NSResponder’s implementation returns <code>true</code>, resigning first 
   * responder status. Subclasses can override this method to update state or 
   * perform some action such as unhighlighting the selection, or to return 
   * <code>false</code>, refusing to relinquish first responder status.</p>
   * 
   * @see #acceptsFirstResponder()
   * @see #becomeFirstResponder()
   */
  public function resignFirstResponder():Boolean {
    return true;
  }
  
  //******************************************************															 
  //*            Setting the next responder
  //******************************************************

  /**
   * Sets the receiver’s next responder to <code>responder</code>.
   * 
   * @see #nextResponder()
   */
  public function setNextResponder(responder:NSResponder):Void {
    m_nextResponder = responder;
  }
  
  /**
   * Returns the receiver’s next responder, or <code>null</code> if it has none.
   * 
   * @see #setNextResponder()
   * @see #noResponderFor()
   */
  public function nextResponder():NSResponder {
    return m_nextResponder;
  }
  
  //******************************************************															 
  //*                 Event methods
  //******************************************************

  /**
   * <p>Informs the receiver that the user has pressed the left mouse button 
   * specified by <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function mouseDown(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.mouseDown(event);
    } else {
      noResponderFor("mouseDown");
    }
  }
  
  /**
   * <p>Informs the receiver that the user has moved the mouse with the left 
   * button pressed specified by <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function mouseDragged(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.mouseDragged(event);
    } else {
      noResponderFor("mouseDragged");
    }
  }
  
  /**
   * <p>Informs the receiver that the user has released the left mouse button 
   * specified by <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function mouseUp(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.mouseUp(event);
    } else {
      noResponderFor("mouseUp");
    }
  }
  
  /**
   * <p>Informs the receiver that the mouse has moved specified by 
   * <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function mouseMoved(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.mouseMoved(event);
    } else {
      noResponderFor("mouseMoved");
    }
  }
  
  /**
   * <p>Informs the receiver that the cursor has entered a tracking rectangle 
   * specified by <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function mouseEntered(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.mouseEntered(event);
    } else {
      noResponderFor("mouseEntered");
    }
  }
  
  /**
   * <p>Informs the receiver that the cursor has exited a tracking rectangle.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function mouseExited(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.mouseExited(event);
    } else {
      noResponderFor("mouseExited");
    }
  }
  
  /**
   * <p>Informs the receiver that the user has pressed the right mouse button 
   * specified by <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function rightMouseDown(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.rightMouseDown(event);
    } else {
      noResponderFor("rightMouseDown");
    }
  }
  
  /**
   * <p>Informs the receiver that the user has moved the mouse with the right 
   * button pressed specified by <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function rightMouseDragged(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.rightMouseDragged(event);
    } else {
      noResponderFor("rightMouseDragged");
    }
  }
  
  /**
   * <p>Informs the receiver that the user has released the right mouse button 
   * specified by <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function rightMouseUp(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.rightMouseUp(event);
    } else {
      noResponderFor("rightMouseUp");
    }
  }
  
  /**
   * <p>Informs the receiver that the user has pressed a mouse button other 
   * than left or right specified by <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function otherMouseDown(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.otherMouseDown(event);
    } else {
      noResponderFor("otherMouseDown");
    }
  }
  
  /**
   * <p>Informs the receiver that the user has moved the mouse with a button 
   * other than the left or right button pressed specified by 
   * <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function otherMouseDragged(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.otherMouseDragged(event);
    } else {
      noResponderFor("otherMouseDragged");
    }
  }
  
  /**
   * <p>Informs the receiver that the user has released a mouse button other 
   * than the left or right specified by <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function otherMouseUp(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.otherMouseUp(event);
    } else {
      noResponderFor("otherMouseUp");
    }
  }
  
  /**
   * <p>Informs the receiver that the mouse’s scroll wheel has moved specified 
   * by <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function scrollWheel(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.scrollWheel(event);
    } else {
      noResponderFor("scrollWheel");
    }
  }
  
  /**
   * <p>Informs the receiver that the user has pressed a key.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function keyDown(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.keyDown(event);
    } else {
      noResponderFor("keyDown");
    }
  }
  
  /**
   * <p>Informs the receiver that the user has released a key event specified 
   * by <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function keyUp(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.keyUp(event);
    } else {
      noResponderFor("keyUp");
    }
  }
  
  /**
   * <p>Informs the receiver that the user has pressed or released a modifier 
   * key (Shift, Control, and so on) specified by <code>event</code>.</p>
   * 
   * <p>NSResponder’s implementation simply passes this message to the next 
   * responder.</p>
   */
  public function flagsChanged(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.flagsChanged(event);
    } else {
      noResponderFor("flagsChanged");
    }
  }
  
  /**
   * <p>Displays context-sensitive help for the receiver if such exists; 
   * otherwise passes this message to the next responder.</p>
   * 
   * <p>NSWindow invokes this method automatically when the user clicks for 
   * help—while processing <code>event</code>. Subclasses need not override 
   * this method, and application code shouldn’t directly invoke it.</p>
   * 
   * @see #showContextHelp()
   */
  public function helpRequested(event:NSEvent):Void {
    if(m_nextResponder!=undefined) {
      m_nextResponder.helpRequested(event);
    } else {
      noResponderFor("helpRequested");
    }
  }
  
  //******************************************************															 
  //*            Special key event methods
  //******************************************************
  
  /**
   * <p>Invoked to handle a series of key events contained by
   * <code>eventArray</code>.</p>
   * 
   * <p>This method attempts to match the character input in eventArray to the 
   * default bindings {@link org.actionstep.events.ASKeyBindingTable#defaultBindings()}
   * for interpretation as text to insert or commands to 
   * perform. Subclasses shouldn’t override this method.</p>
   */
  public function interpretKeyEvents(eventArray:NSArray):Void {
    
    // FIXME the implementation of this method is probably a bit simplistic
    
    var bindings:ASKeyBindingsTable = ASKeyBindingsTable.defaultBindings();
    
    var arr:Array = eventArray.internalList();
    var len:Number = arr.length;
    var b:ASKeyBinding;
    for (var i:Number = 0; i < len; i++) {
      var e:NSEvent = arr[i];
      b = bindings.keyBindingForCodeModifiers(e.keyCode, 
      	e.modifierFlags);
      if (b == null) {
        return;
      }
      if (b.table != null) {
        bindings = b.table;
      }
    }
    
    b.performActionWithObject(this);
  }
  
  /**
   * <p>Overridden by subclasses to perform a key equivalent. If the character
   * code or codes in <code>event</code> match the responder's key equivalent,
   * the responder should respond to the event and return <code>true</code>.</p>
   * 
   * <p>The default implementation always returns <code>false</code>.</p>
   */
  public function performKeyEquivalent(event:NSEvent):Boolean {
    return false;
  }
  
  /**
   * <p>Overridden by subclasses to perform a mneumonic. If the character code
   * or codes in <code>string</code> match the responder's mneumonic, the 
   * responder should perform the mneumonic and return <code>true</code>.</p>
   * 
   * <p>The default implementation always returns <code>false</code>.</p>
   */
  public function performMneumonic(string:String):Boolean {
    return false;
  }
  
  //******************************************************															 
  //*              Clearing key events
  //******************************************************
  
  public function flushBufferedKeyEvent():Void { }
  
  //******************************************************															 
  //*                Action methods
  //******************************************************
  
  public function cancelOperation(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to capitalize the word or words surrounding 
   * the insertion point or selection, expanding the selection if necessary.</p>
   * 
   * <p>If either end of the selection partially covers a word, that entire 
   * word is made lowercase. The sender argument is typically the object that 
   * invoked this method. NSResponder declares but doesn’t implement this 
   * method.</p>
   * 
   * @see #lowercaseWord()
   * @see #uppercaseWord()
   * @see #changeCaseOfLetter()
   */
  public function capitalizeWord(sender:Object):Void { }
  
  public function centerSelectionInVisibleArea(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to change the case of a letter or letters in 
   * the selection, perhaps by opening a panel with capitalization options or by 
   * cycling through possible case combinations.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   * 
   * @see #capitalizeWord()
   * @see #lowercaseWord()
   * @see #uppercaseWord()
   */
  public function changeCaseOfLetter(sender:Object):Void { }
  public function complete(sender:Object):Void { }
  public function deleteBackward(sender:Object):Void { }
  public function deleteBackwardByDecomposingPreviousCharacter(sender:Object):Void { }
  public function deleteForward(sender:Object):Void { }
  public function deleteToBeginningOfLine(sender:Object):Void { }
  public function deleteToBeginningOfParagraph(sender:Object):Void { }
  public function deleteToEndOfLine(sender:Object):Void { }
  public function deleteToEndOfParagraph(sender:Object):Void { }
  public function deleteToMark(sender:Object):Void { }
  public function deleteWordBackward(sender:Object):Void { }
  public function deleteWordForward(sender:Object):Void { }
  public function indent(sender:Object):Void { }
  public function insertBacktab(sender:Object):Void { }
  public function insertNewline(sender:Object):Void { }
  public function insertNewlineIgnoringFieldEditor(sender:Object):Void { }
  public function insertParagraphSeparator(sender:Object):Void { }
  public function insertTab(sender:Object):Void { }
  public function insertTabIgnoringFieldEditor(sender:Object):Void { }
  
  /**
   * <p>Overridden by subclasses to insert the supplied string at the insertion 
   * point or selection, deleting the selection if there is one.</p>
   * 
   * <p>The NSResponder implementation simply passes this message to the next 
   * responder, or beeps if there is no next responder.</p>
   */
  public function insertText(sender:Object):Void { 
    if (m_nextResponder != undefined) {
      m_nextResponder.insertText(sender);
    }
    else { 
      beep(); 
    }
  }
  
  /**
   * <p>Implemented by subclasses to make lowercase every letter in the word or 
   * words surrounding the insertion point or selection, expanding the selection 
   * if necessary.</p>
   * 
   * <p>If either end of the selection partially covers a word, that entire 
   * word is made lowercase. NSResponder declares, but doesn’t implement this 
   * method.</p>
   * 
   * @see #uppercaseWord()
   * @see #capitalizeWord()
   * @see #changeCaseOfLetter()
   */
  public function lowercaseWord(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to move the selection or insertion point one 
   * element or character backward.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function moveBackward(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to expand or reduce either end of the 
   * selection backward by one element or character.</p>
   * 
   * <p>If the end being modified is the backward end, this method expands the 
   * selection; if the end being modified is the forward end, it reduces the 
   * selection. The first {@link #moveBackwardAndModifySelection} or 
   * {@link #moveForwardAndModifySelection} method in a series determines the 
   * end being modified by always expanding. Hence, this method results in the 
   * backward end becoming the mobile one if invoked first. By default, 
   * {@link #moveLeftAndModifySelection} is bound to the left arrow key.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function moveBackwardAndModifySelection(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to move the selection or insertion point one 
   * element or character down.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function moveDown(sender:Object):Void { }
  

  public function moveDownAndModifySelection(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to move the selection or insertion point one 
   * element or character forward.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function moveForward(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to expand or reduce either end of the 
   * selection forward by one element or character.</p>
   * 
   * <p>If the end being modified is the backward end, this method expands the 
   * selection; if the end being modified is the forward end, it reduces the 
   * selection. The first {@link #moveBackwardAndModifySelection} or 
   * {@link #moveForwardAndModifySelection} method in a series determines the 
   * end being modified by always expanding. Hence, this method results in the 
   * backward end becoming the mobile one if invoked first. By default, 
   * {@link #moveLeftAndModifySelection} is bound to the left arrow key.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function moveForwardAndModifySelection(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to move the selection or insertion point one 
   * element or character left.</p> 
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function moveLeft(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to expand or reduce either end of the 
   * selection to the left (display order) by one element or character.</p>
   * 
   * <p>If the end being modified is the left end, this method expands the 
   * selection; if the end being modified is the right end, it reduces the 
   * selection. The first {@link #moveLeftAndModifySelection} or 
   * {@link #moveRightAndModifySelection} method in a series determines the end 
   * being modified by always expanding. Hence, this method results in the left 
   * end becoming the mobile one if invoked first. By default, this method is 
   * bound to the left arrow key.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   * 
   * <p>The essential difference between this method and the corresponding 
   * {@link #moveBackwardAndModifySelection()} is that the latter method moves 
   * in logical order, which can differ in bidirectional text, whereas this 
   * method moves in display order.</p>
   */
  public function moveLeftAndModifySelection(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to move the selection or insertion point one 
   * element or character right.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function moveRight(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to expand or reduce either end of the 
   * selection to the right (display order) by one element or character.</p>
   * 
   * <p>If the end being modified is the left end, this method expands the 
   * selection; if the end being modified is the right end, it reduces the 
   * selection. The first {@link #moveLeftAndModifySelection} or 
   * {@link #moveRightAndModifySelection} method in a series determines the end 
   * being modified by always expanding. Hence, this method results in the left 
   * end becoming the mobile one if invoked first. By default, this method is 
   * bound to the left arrow key.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   * 
   * <p>The essential difference between this method and the corresponding 
   * {@link #moveForwardAndModifySelection()} is that the latter method moves 
   * in logical order, which can differ in bidirectional text, whereas this 
   * method moves in display order.</p>
   */
  public function moveRightAndModifySelection(sender:Object):Void { }
  
  public function moveToBeginningOfDocument(sender:Object):Void { }
  public function moveToBeginningOfLine(sender:Object):Void { }
  public function moveToBeginningOfParagraph(sender:Object):Void { }
  public function moveToEndOfDocument(sender:Object):Void { }
  public function moveToEndOfLine(sender:Object):Void { }
  public function moveToEndOfParagraph(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to move the selection or insertion point one 
   * element or character up.</p>
   */
  public function moveUp(sender:Object):Void { }
  
  public function moveUpAndModifySelection(sender:Object):Void { }
  public function moveWordBackward(sender:Object):Void { }
  public function moveWordBackwardAndModifySelection(sender:Object):Void { }
  public function moveWordForward(sender:Object):Void { }
  public function moveWordForwardAndModifySelection(sender:Object):Void { }
  public function moveWordLeft(sender:Object):Void { }
  public function moveWordRight(sender:Object):Void { }
  public function moveWordRightAndModifySelection(sender:Object):Void { }
  public function moveWordLeftAndModifySelection(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to scroll the receiver down (or back) one 
   * page in its scroll view, also moving the insertion point to the bottom of 
   * the newly displayed page.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   * 
   * @see #pageUp()
   * @see #scrollPageUp()
   * @see #scrollPageDown()
   */
  public function pageDown(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to scroll the receiver up (or forward) one 
   * page in its scroll view, also moving the insertion point to the top of 
   * the newly displayed page.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   * 
   * @see #pageDown()
   * @see #scrollPageUp()
   * @see #scrollPageDown()
   */
  public function pageUp(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to scroll the receiver one line down in its 
   * scroll view, without changing the selection.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function scrollLineDown(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to scroll the receiver one line up in its 
   * scroll view, without changing the selection.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function scrollLineUp(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to scroll the receiver one page down in its 
   * scroll view, without changing the selection.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function scrollPageDown(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to scroll the receiver one page up in its 
   * scroll view, without changing the selection.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function scrollPageUp(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to select all selectable elements.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function selectAll(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to select all elements in the line or lines 
   * containing the selection or insertion point.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function selectLine(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to select all paragraphs containing the 
   * selection or insertion point.</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function selectParagraph(sender:Object):Void { }
  
  public function selectToMark(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to extend the selection to the nearest word 
   * boundaries outside it (up to, but not including, word delimiters).</p>
   * 
   * <p>NSResponder declares but doesn’t implement this method.</p>
   */
  public function selectWord(sender:Object):Void { }
  
  public function setMark(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to invoke the help system, displaying 
   * information relevant to the receiver and its current state.</p>
   * 
   * @see #helpRequested()
   */
  public function showContextHelp(sender:Object):Void { }
  
  public function swapWithMark(sender:Object):Void { }
  public function transpose(sender:Object):Void { }
  public function transposeWords(sender:Object):Void { }
  
  /**
   * <p>Implemented by subclasses to make uppercase every letter in the word or 
   * words surrounding the insertion point or selection, expanding the selection 
   * if necessary.</p>
   * 
   * <p>If either end of the selection partially covers a word, that entire word 
   * is made uppercase. NSResponder declares but doesn’t implement this 
   * method.</p>
   * 
   * @see #lowercaseWord()
   * @see #capitalizeWord()
   * @see #changeCaseOfLetter()
   */
  public function uppercaseWord(sender:Object):Void { }
  public function yank(sender:Object):Void { }
  
  //******************************************************															 
  //*                Dispatch methods
  //******************************************************
  
  /**
   * <p>Attempts to perform the indicated method.</p>
   * 
   * <p>If the receiver responds to <code>selector</code>, it invokes the method 
   * with <code>null</code> as the argument. If the receiver doesn’t respond, 
   * it sends this message to its next responder with the same selector. 
   * NSWindow and NSApplication also send the message to their delegates. If the 
   * receiver has no next responder or delegate, it beeps.</p>
   * 
   * @see #tryToPerformWith()
   */
  public function doCommandBySelector(selector:String):Void {
    var result:Boolean = tryToPerformWith(selector, null);
    if (!result) {
      beep();
    }
  }
  
  /**
   * <p>Attempts to perform the action indicated method with a specified 
   * argument.</p>
   * 
   * <p>Returns <code>true</code> if a responder is found that responds to the
   * action, or <code>false</code> otherwise.</p>
   * 
   * <p>If the receiver responds to <code>selector</code>, it invokes the method 
   * with <code>anObject</code> as the argument and returns <code>true</code>. 
   * If the receiver doesn’t respond, it sends this message to its next 
   * responder with the same selector and object.</p>
   */
  public function tryToPerformWith(selector:String, anObject:Object):Boolean {
    if(typeof(this[selector]) == "function") {
      this[selector].call(this, anObject);
      return true;
    } else {
      if(m_nextResponder!=undefined) {
        return m_nextResponder.tryToPerformWith(selector, anObject);
      } else {
        return false;
      }
    }
  }
  
  //******************************************************															 
  //*         Terminating the responder chain
  //******************************************************
  
  /**
   * <p>Handles the case where an event or action message falls off the end of 
   * the responder chain.</p>
   * 
   * <p><code>selector</code> is a string identifying the event or action 
   * message.</p>
   * 
   * <p>The default implementation beeps if <code>selector</code> is 
   * <code>"keyDown"</code></p>
   */
  public function noResponderFor(selector:String):Void {
    if(selector=="keyDown") {
      beep();
    }
  }
  
  //******************************************************															 
  //*                Setting the menu
  //******************************************************
  
  /**
   * <p>Sets the receiver’s menu.</p>
   * 
   * <p>For {@link org.actionstep.NSApplication} this method sets the main
   * menu using {@link #setMainMenu()}.</p>
   * 
   * @see #menu()
   */
  public function setMenu(menu:NSMenu):Void {
    m_menu = menu;
  }
  
  /**
   * <p>Returns the receiver’s menu.</p>
   * 
   * <p>For {@link org.actionstep.NSApplication} this menu is the same as the 
   * menu returned by its {@link #mainMenu()} method.</p>
   * 
   * @see #setMenu()
   * @see org.actionstep.NSView#menuForEvent()
   * @see org.actionstep.NSView#defaultMenu()
   */
  public function menu():NSMenu {
    return m_menu;
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
    if(m_nextResponder!=undefined) {
      return m_nextResponder.undoManager();
    }
    
    noResponderFor("undoManager");
    return null;
  }
  
  //******************************************************
  //*   Presenting and customizing error information
  //******************************************************
  
  // TODO - (BOOL)presentError:(NSError *)anError
  // TODO - (void)presentError:(NSError *)error modalForWindow:(NSWindow *)aWindow delegate:(id)delegate didPresentSelector:(SEL)didPresentSelector contextInfo:(void *)contextInfo
  // TODO - (NSError *)willPresentError:(NSError *)anError
  
}