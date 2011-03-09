/* See LICENSE for copyright and terms of use */

import org.actionstep.ASFieldEditor;
import org.actionstep.ASUtils;
import org.actionstep.binding.ASDecSetterProps;
import org.actionstep.constants.NSTextFieldBezelStyle;
import org.actionstep.constants.NSTextMovement;
import org.actionstep.NSBeep;
import org.actionstep.NSColor;
import org.actionstep.NSControl;
import org.actionstep.NSCursor;
import org.actionstep.NSDictionary;
import org.actionstep.NSEvent;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSRect;
import org.actionstep.NSTextFieldCell;
import org.actionstep.themes.ASTheme;

/**
 * An editable single line of text.
 *
 * @author Richard Kilmer
 */
class org.actionstep.NSTextField extends NSControl {

  private static var g_cellClass:Function = org.actionstep.NSTextFieldCell;
  
  private var m_editor:ASFieldEditor;
  private var m_delegate:Object;
  private var m_notificationCenter:NSNotificationCenter;
  private var m_needsToSelectText:Boolean;

  //******************************************************
  //*                  Construction
  //******************************************************
  
  public function NSTextField() {
    m_editor = null;
    m_needsToSelectText = false;
  }

  public function initWithFrame(frame:NSRect):NSTextField {
    super.initWithFrame(frame);
    m_notificationCenter = NSNotificationCenter.defaultCenter();
    m_cell.setState(1);
    m_cell.setBezeled(true);
    m_cell.setSelectable(true);
    m_cell.setEnabled(true);
    m_cell.setEditable(true);
    NSTextFieldCell(m_cell).setDrawsBackground(true);
    setFont(ASTheme.current().controlContentFontOfSize(0));
    
    return this;
  }

  public function removeMovieClips():Void {
    validateEditing();
    abortEditing();
    super.removeMovieClips();
  }

  //******************************************************
  //*             Describing the object
  //******************************************************

  /**
   * Returns a string representation of the textfield.
   */
  public function description():String {
    return "NSTextField(string=" + stringValue() + ")";
  }

  //******************************************************
  //*    Controlling editability and selectability
  //******************************************************

  public function setEditable(value:Boolean) {
    m_cell.setEditable(value);
  }

  public function isEditable():Boolean {
    return m_cell.isEditable();
  }

  public function isSelectable():Boolean {
    return m_cell.isSelectable();
  }

  public function setSelectable(value:Boolean) {
    m_cell.setSelectable(value);
  }

  // Controlling rich text behavior

  //! Not dealing with the following
  /*
  – setAllowsEditingTextAttributes:
  – allowsEditingTextAttributes
  – setImportsGraphics:
  – importsGraphics
  */

  //******************************************************
  //*              Setting the text color
  //******************************************************

  public function setTextColor(value:NSColor) {
    NSTextFieldCell(m_cell).setTextColor(value);
  }

  public function textColor():NSColor {
    return NSTextFieldCell(m_cell).textColor();
  }

  //******************************************************
  //*           Controlling the background
  //******************************************************

  public function setBackgroundColor(value:NSColor) {
    NSTextFieldCell(m_cell).setBackgroundColor(value);
  }

  public function backgroundColor():NSColor {
    return NSTextFieldCell(m_cell).backgroundColor();
  }

  public function setBorderColor(color:NSColor) {
    NSTextFieldCell(m_cell).setBorderColor(color);
  }

  public function borderColor():NSColor {
    return NSTextFieldCell(m_cell).borderColor();
  }

  public function setDrawsBackground(value:Boolean) {
    NSTextFieldCell(m_cell).setDrawsBackground(value);
  }

  public function drawsBackground():Boolean {
    return NSTextFieldCell(m_cell).drawsBackground();
  }

  //******************************************************
  //*                Setting a border
  //******************************************************

  public function setBezeled(value:Boolean) {
    m_cell.setBezeled(value);
  }

  public function isBezeled():Boolean {
    return m_cell.isBezeled();
  }

  /**
   * <p>Sets the receiver’s bezel style to be <code>value</code>.</p>
   * 
   * <p>{@link #isBezeled()} must be <code>true</code>.</p>
   * 
   * @see #bezelStyle()
   */
  public function setBezelStyle(value:NSTextFieldBezelStyle) {
    NSTextFieldCell(m_cell).setBezelStyle(value);
  }

  /**
   * <p>Returns the receiver's bezel style.</p>
   * 
   * @see #setBezelStyle()
   */
  public function bezelStyle():NSTextFieldBezelStyle {
    return NSTextFieldCell(m_cell).bezelStyle();
  }

  public function setBordered(value:Boolean) {
    m_cell.setBordered(value);
  }

  public function isBordered():Boolean {
    return m_cell.isBordered();
  }

  //******************************************************
  //*               Selecting the text
  //******************************************************

  public function selectText(sender:Object) {
    if (isSelectable() && superview() != null) {
      if (m_editor == null) {
        var x:ASFieldEditor = NSTextFieldCell(m_cell).beginEditingWithDelegate(this);
        m_editor = x;
        m_cell.setShowsFirstResponder(true);
        setNeedsDisplay(true);
        if (m_editor == null) {
          m_needsToSelectText = true;
          return;
        }
      }
      m_editor.select();
    }
  }

  public function drawRect(rect:NSRect) {
    super.drawRect(rect);
    if (m_needsToSelectText) {
      m_needsToSelectText = false;
      selectText(this);
    }
  }

  //******************************************************
  //*         Working with the responder chain
  //******************************************************

  public function acceptsFirstMouse(event:NSEvent):Boolean {
    return isEditable();
  }

  public function acceptsFirstResponder():Boolean {
    return isEnabled() && isSelectable();
  }

  public function becomeFirstResponder():Boolean {
    if (acceptsFirstResponder()) {
      selectText();
      //if(!m_cell.showsFirstResponder()) {
      //	selectText(this);
      //	m_needsToSelectText = false;
      //}
      if (m_editor != null || m_needsToSelectText) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  public function resignKeyWindow() {
    if (m_editor != null) {
      m_editor.notifyEndEditing(NSTextMovement.NSIllegalTextMovement);
    }
    m_needsToSelectText = false;
  }

  public function resignFirstResponder():Boolean {
    if (m_editor != null) {
      m_editor.notifyEndEditing(NSTextMovement.NSIllegalTextMovement);
    }
    m_needsToSelectText = false;
    return super.resignFirstResponder();
  }

  public function mouseDown(event:NSEvent) {
    if (!isSelectable()) {
      super.mouseDown(event);
      return;
    }
    m_window.makeFirstResponder(this);
    if (m_cell.showsFirstResponder()) {
      if (m_editor == null) {
        selectText();
      }
    }
    NSCursor.hide();
  }

  public function abortEditing():Boolean {
    if (m_editor) {
      m_editor = null;
      NSTextFieldCell(m_cell).endEditingWithDelegate(this);
      return true;
    } else {
      return false;
    }
  }

  public function validateEditing() {
    if (m_editor != null) {
      var old:String = m_cell["m_stringValue"];
      var val:String = m_editor.string();
      m_cell.setStringValue(val);

      // what comes after this are binding-specific and should not affect the behaviour
      // of the control in any way.
      var props:ASDecSetterProps = setStringValue.__props;

      // observer notification should not take place unless a change has taken place
      if(val!=old && props!=null) {
      	props.notifier(old, val, props.kvObservers);
      }
    }
  }

  public function textShouldBeginEditing(editor:Object):Boolean {
    if (!(isEditable() || isSelectable())) {
      return false;
    }
    if (m_delegate != null) {
      if(typeof(m_delegate["controlTextShouldBeginEditing"]) == "function") {
        return m_delegate["controlTextShouldBeginEditing"].call(m_delegate, this, editor);
      }
    }
    return true;
  }

  public function textDidBeginEditing(notification:NSNotification) {
    m_notificationCenter.postNotificationWithNameObjectUserInfo(
      NSControlTextDidBeginEditingNotification,
      this,
      NSDictionary.dictionaryWithObjectForKey(notification.object,"NSFieldEditor")
    );
  }

  public function textDidChange(notification:NSNotification) {
    m_notificationCenter.postNotificationWithNameObjectUserInfo(
      NSControlTextDidChangeNotification,
      this,
      NSDictionary.dictionaryWithObjectForKey(notification.object,"NSFieldEditor")
    );

    //! what else to do here ?
  }

  public function textShouldEndEditing(editor:Object):Boolean {
    //! need to validate that text is acceptable
    //if (m_cell.isEntryAcceptable(editor.text) {
    //}
    if (m_delegate != null) {
      if(typeof(m_delegate["controlTextShouldEndEditing"]) == "function") {
        if (!m_delegate["controlTextShouldEndEditing"].call(m_delegate, this, editor)) {
          NSBeep.beep();
          return false;
        }
      }
    }
    //! check for controlIsValidObject on delegate?
    return true;
  }

  public function textDidEndEditing(notification:NSNotification) {
    validateEditing();
    m_editor = null;
    m_cell.setShowsFirstResponder(false);
    setNeedsDisplay(true);
    NSTextFieldCell(m_cell).endEditingWithDelegate(this);
    var textMovement:NSTextMovement = 
    	NSTextMovement(notification.userInfo.objectForKey("NSTextMovement"));
    m_notificationCenter.postNotificationWithNameObjectUserInfo(
      NSControlTextDidEndEditingNotification,
      this,
      NSDictionary.dictionaryWithObjectsAndKeys(
      	notification.object, "NSFieldEditor",
      	textMovement, "NSTextMovement")
    );

    switch(textMovement) {
      case NSTextMovement.NSReturnTextMovement:
        if (!sendActionTo(action(), target())) {
        	
          selectText(this);
        } else {
          m_window.makeFirstResponder(m_window);
        }
        break;
      case NSTextMovement.NSTabTextMovement:
        sendActionTo(action(), target());
        m_window.selectKeyViewFollowingView(this);
        if (m_window.firstResponder() == m_window) {
          selectText(this);
        }
        break;
      case NSTextMovement.NSBacktabTextMovement:
        sendActionTo(action(), target());
        m_window.selectKeyViewPrecedingView(this);
        if (m_window.firstResponder() == m_window) {
          selectText(this);
        }
        break;
      case NSTextMovement.NSIllegalTextMovement:
        m_window.makeFirstResponder(m_window); // FIXME this is wrong
        break;
    }
  }
  
  public function keyDown(event:NSEvent) {
  }

  public function keyUp(event:NSEvent) {
  }

  //******************************************************
  //*               Setting the delegate
  //******************************************************

  public function delegate():Object {
    return m_delegate;
  }

  public function setDelegate(value:Object) {
    if(m_delegate != null) {
      m_notificationCenter.removeObserverNameObject(m_delegate, null, this);
    }
    m_delegate = value;
    if (value == null) {
      return;
    }
    mapDelegateNotification("DidBeginEditing");
    mapDelegateNotification("DidEndEditing");
    mapDelegateNotification("DidChange");
  }

  private function mapDelegateNotification(name:String) {
    if(typeof(m_delegate["controlText"+name]) == "function") {
      m_notificationCenter.addObserverSelectorNameObject(m_delegate, "controlText"+name, ASUtils.intern("NSControlText"+name+"Notification"), this);
    }
  }
  
  //******************************************************
  //*             MovieClip (ActionStep-only)
  //******************************************************
  
  private function requiresMask():Boolean {
    return false;
  }

  //******************************************************
  //*                   Cell class
  //******************************************************
  
  public static function cellClass():Function {
    return g_cellClass;
  }

  public static function setCellClass(cellClass:Function) {
    if (cellClass == null) {
      g_cellClass = org.actionstep.NSTextFieldCell;
    } else {
      g_cellClass = cellClass;
    }
  }
  
  public static var NSControlTextDidBeginEditingNotification:Number 
    = ASUtils.intern("NSControlTextDidBeginEditingNotification");
  public static var NSControlTextDidEndEditingNotification:Number 
    = ASUtils.intern("NSControlTextDidEndEditingNotification");
  public static var NSControlTextDidChangeNotification:Number 
    = ASUtils.intern("NSControlTextDidChangeNotification");
}