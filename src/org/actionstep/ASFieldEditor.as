/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.constants.NSTextMovement;
import org.actionstep.events.ASEventMonitor;
import org.actionstep.NSCell;
import org.actionstep.NSDictionary;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSObject;
import org.actionstep.NSRange;
import org.actionstep.NSText;

/**
 * This class is used internally in ActionStep to handle text edits.
 *
 * Unless you're developing components that use text editing, you probably
 * don't have to worry about it.
 */
class org.actionstep.ASFieldEditor extends NSObject {

  //******************************************************
  //*                    Class members
  //******************************************************

  private static var g_instance:ASFieldEditor;
  private static var g_interval:Number = 20;

  //******************************************************
  //*                   Member variables
  //******************************************************

  private var m_cell:NSCell;
  private var m_text:NSText;
  private var m_delegate:Object;
  private var m_textField:TextField;
  private var m_textFormat:TextFormat;
  private var m_string:String;
  private var m_notificationCenter:NSNotificationCenter;
  private var m_interval:Number;
  private var m_lastSelRange:NSRange;
  private var m_editing:Boolean;
  private var m_hasFocus:Boolean;
  private var m_ignoreNextSelect:Boolean;
  private var m_isTextMode:Boolean;
  
  //******************************************************
  //*                   Construction
  //******************************************************

  public function ASFieldEditor() {
    m_notificationCenter = NSNotificationCenter.defaultCenter();
    m_hasFocus = false;
    m_editing = false;
    m_ignoreNextSelect = false;
  }

  //******************************************************
  //*               Describing the object
  //******************************************************

  public function description():String {
    return "ASFieldEditor(textfield="+m_textField+")";
  }

  //******************************************************
  //*              Getting the text of the edit
  //******************************************************

  /**
   * Returns the text contained in the editor's text field.
   */
  public function string():String {
    return m_string;
  }

  //******************************************************
  //*           Getting / setting the textfield
  //******************************************************

  /**
   * Sets the textfield this editor is editing to <code>textField</code>.
   */
  public function setTextField(textField:TextField) {
    var self:ASFieldEditor = this;
    if (m_textField != null) { // reset old TextField
      m_textField.selectable = false;
      m_textField.hscroll = 0;
      m_textField.background = false;
      m_textField.type = "dynamic";
      m_textField.onKillFocus = null;
      m_textField.onSetFocus = null;
      m_textField.onScroller = null;
      m_textField.onChanged = null;
      m_string = m_textField.text;
      Selection.setSelection(m_textField.text.length, m_textField.text.length);
      m_textField.setTextFormat(m_textFormat);
      Key.removeListener(this);
    }
    setEditing(false);
    m_textField = textField;
    if (m_textField != null) { // enable new TextField
      m_textFormat = m_textField.getTextFormat();
      
      m_string = m_textField.text;
      m_textField.selectable = true;
      var propObj:Object;
      if (!m_isTextMode) {
        propObj = m_cell;
        //m_string = m_cell.stringValue();
      } else {
        propObj = m_text;
        //m_string = m_text.string();
      }
      
      m_textField.text = m_string;
      m_textField.type = propObj.isEditable() ? "input" : "dynamic";
      m_textField.tabEnabled = false;
      
      var tform:TextFormat;

      if (propObj.alignment() != undefined) {
        tform = propObj.font().textFormatWithAlignment(propObj.alignment());
        if (propObj.textColor()) {
          tform.color = propObj.textColor().value;
        }
      } else {
        tform = propObj.font().textFormat();
        if (propObj.textColor()) {
          tform.color = propObj.textColor().value;
        }
      }
      
      m_textField.setTextFormat(tform);
      m_textField.setNewTextFormat(tform);
      self.setEditing(true);
      m_textField.onSetFocus = function(oldFocus:Object) {
        self.setHasFocus(true);
      };
      m_textField.onKillFocus = function(newFocus:Object) {
        self.setHasFocus(false);
      };
      var allowScroll:Boolean = !m_isTextMode ? m_cell.isScrollable() : true;
      m_textField.onScroller = function(tf:TextField) {
        if (!allowScroll) {
          tf.scroll = 0;
          tf.hscroll = 0;
        }
      };
      m_textField.onChanged = function(tf:TextField) {
        self.notifyChange();
      };
      Key.addListener(this);
      Selection.setFocus(String(m_textField));
      notifyBeginEditing();
    }
  }

  /**
   * Returns this editor's text field.
   */
  public function textField():TextField {
    return m_textField;
  }

  //******************************************************
  //*              Setting / getting the cell
  //******************************************************

  /**
   * Sets the cell that is being edited to <code>cell</code>.
   */
  public function setCell(cell:NSCell) {
    m_cell = cell;
    m_isTextMode = false;
  }

  /**
   * Returns the cell that is being edited.
   */
  public function cell():NSCell {
    return m_cell;
  }
  
  /**
   * Sets the text object that is being edited to <code>text</code>.
   */
  public function setText(text:NSText):Void {
    m_text = text;
    m_isTextMode = true;
  }
  
  /**
   * Returns the text object that is being edited.
   */
  public function text():NSText {
    return m_text;
  }

  //******************************************************
  //*            Setting / getting the delegate
  //******************************************************

  /**
   * Sets the delegate that will recieve notifications regarding text editing
   * to <code>delegate</code>.
   *
   * See <code>#startEditing</code> for more information on what methods the
   * delegate can implement.
   */
  public function setDelegate(delegate:Object) {
    if(m_delegate != null) {
      m_notificationCenter.removeObserverNameObject(m_delegate, null, this);
    }
    m_delegate = delegate;
    if (m_delegate == null) {
      return;
    }
    mapDelegateNotification("DidBeginEditing");
    mapDelegateNotification("DidEndEditing");
    mapDelegateNotification("DidChange");
  }

  /**
   * Returns the delegate associated with the current edit.
   */
  public function delegate():Object {
    return m_delegate;
  }

  /**
   * Adds the delegate as an observer for a notification named
   * <code>"NSText"+name+"Notification"</code>. The method that will be called
   * on the delegate is called <code>"text"+name</code>.
   */
  private function mapDelegateNotification(name:String) {
    if(typeof(m_delegate["text"+name]) == "function") {
      m_notificationCenter.addObserverSelectorNameObject(m_delegate,
        "text"+name, ASUtils.intern("NSText"+name+"Notification"), this);
    }
  }

  //******************************************************
  //*               Dispatching notifications
  //******************************************************

  /**
   * Dispatches a notification regarding the beginning of an edit.
   */
  public function notifyBeginEditing() {
    m_notificationCenter.postNotificationWithNameObject(
      NSTextDidBeginEditingNotification, this);
  }

  /**
   * Dispatches a notification regarding the end of a text edit.
   */
  public function notifyEndEditing(textMovement:NSTextMovement) {
    if (typeof(m_delegate["textShouldEndEditing"]) != "function"
        || m_delegate.textShouldEndEditing(this)) {
      m_notificationCenter.postNotificationWithNameObjectUserInfo(
        NSTextDidEndEditingNotification,
        this,
        NSDictionary.dictionaryWithObjectForKey(textMovement, "NSTextMovement")
      );
    }
  }

  /**
   * Dispatches a notification regarding a change in the text.
   */
  public function notifyChange() {
    m_string = m_textField.text;
    m_notificationCenter.postNotificationWithNameObject(
      NSTextDidChangeNotification, this);
  }

  //******************************************************
  //*  Setting / getting whether the editor is editing
  //******************************************************

  /**
   * Sets whether the editor is editing to <code>value</code>.
   */
  public function setEditing(value:Boolean) {
    m_editing = value;
  }

  /**
   * Returns <code>true</code> if the editor is editing, or <code>false</code>
   * otherwise.
   */
  public function isEditing():Boolean {
    return m_editing;
  }

  //******************************************************
  //*                Focus and selection
  //******************************************************
  
  /**
   * Sets whether the editor has focus to <code>value</code>.
   */
  public function setHasFocus(value:Boolean) {
    m_hasFocus = value;
    m_lastSelRange = ASEventMonitor.instance().textSelection();
  }

  /**
   * Returns <code>true</code> if the editor has focus, or <code>false</code>
   * otherwise.
   */
  public function hasFocus():Boolean {
    return m_hasFocus;
  }

  /**
   * Sets the editor to ignore the next selection.
   */
  public function ignoreNextSelect() {
    m_ignoreNextSelect = true;
  }

  /**
   * Focuses the editor's textfield.
   */
  public function regainFocus() {
    if (!m_hasFocus) {
      var obj:Object = {focus:true, select:true, range: m_lastSelRange};
      obj.interval = setInterval(this, "focusCallback", g_interval, obj);
    }
  }

  /**
   * Focuses the editor's textfield and selects all of its text.
   */
  public function regainFocusSelect() {
    if (!m_hasFocus) {
      var obj:Object = {focus:true, select:true};
      obj.interval = setInterval(this, "focusCallback", g_interval, obj);
    }
  }

  /**
   * Selects the text in the editor's textfield.
   */
  public function select() {
    var obj:Object = {focus:false, select:true};
    obj.interval = setInterval(this, "focusCallback", g_interval, obj);
  }

  /**
   * Performs the necessary focus and selection changes.
   */
  private function focusCallback(flags:Object) {
    if (flags.focus) {
      Selection.setFocus(String(m_textField));
    }
    if (!m_ignoreNextSelect) {
      if (flags.select) {
        if (flags.range == null) {
          Selection.setSelection(0, m_textField.text.length);
        } else {
          var rng:NSRange = NSRange(flags.range);
          Selection.setSelection(rng.location, rng.location + rng.length);
        }
      } else {
        Selection.setSelection(m_textField.text.length, m_textField.text.length);
      }
    } else {
      m_ignoreNextSelect = false;
    }
    clearInterval(flags.interval);
  }

  /**
   * Selects the text in range in the editor's text field.
   */
  public function setSelectedRange(aRange:NSRange):Void {
    var obj:Object = {focus:false, select:true, range:aRange};
    obj.interval = setInterval(this, "focusCallback", g_interval, obj);
  }
  
  //******************************************************
  //*             Responding to key events
  //******************************************************

  /**
   * Fired when a key is pressed.
   */
  public function onKeyDown() {
    if (Key.getCode() == Key.ENTER) {
      notifyEndEditing(NSTextMovement.NSReturnTextMovement);
    } else if(Key.getCode() == NSTabCharacter) {
      if (Key.isDown(Key.SHIFT)) {
        notifyEndEditing(NSTextMovement.NSBacktabTextMovement);
      } else {
        
        notifyEndEditing(NSTextMovement.NSTabTextMovement);
      }
    }
  }

  //******************************************************
  //*           Beginning and ending the edit
  //******************************************************

  /**
   * Starts the editing of the text in <code>cell</code> with the delegate
   * <code>delegate</code> on the text field <code>textField</code>.
   *
   * The delegate can implement up to 3 methods:
   *   textDidBeginEditing(ASFieldEditor) - Called when text begins editing
   *   textDidEndEditing(ASFieldEditor) - Called when text finishes being edited
   *   textDidChange(ASFieldEditor) - Called when text is changed
   */
  public function startInstanceEdit(cell:NSCell, delegate:Object, 
      textField:TextField):ASFieldEditor {
    if (ASEventMonitor.instance().eventLock()) {
      trace("Event lock!");
      return null;
    }
    if (isEditing()) {
      notifyEndEditing(NSTextMovement.NSIllegalTextMovement);
      if (isEditing()) {
        return null;
      }
      ignoreNextSelect();
    }
    if (typeof(delegate["textShouldBeginEditing"]) != "function"
        || delegate.textShouldBeginEditing(instance)) {
      setCell(cell);
      setDelegate(delegate);
      setTextField(textField);
      return this;
    }
    return null;
  }
  
  /**
   * Starts the editing of the text in <code>text</code> with the delegate
   * <code>delegate</code> on the text field <code>textField</code>.
   *
   * The delegate can implement up to 3 methods:
   *   textDidBeginEditing(ASFieldEditor) - Called when text begins editing
   *   textDidEndEditing(ASFieldEditor) - Called when text finishes being edited
   *   textDidChange(ASFieldEditor) - Called when text is changed
   */
  public function startInstanceEditWithText(text:NSText, delegate:Object,
      textField:TextField):ASFieldEditor {
    if (ASEventMonitor.instance().eventLock()) {
      trace("Event lock!");
      return null;
    }
    if (isEditing()) {
      notifyEndEditing(NSTextMovement.NSIllegalTextMovement);
      if (isEditing()) {
        return null;
      }
      ignoreNextSelect();
    }
    if (typeof(delegate["textShouldBeginEditing"]) != "function"
        || delegate.textShouldBeginEditing(instance)) {
      setText(text);
      setDelegate(delegate);
      setTextField(textField);
      return this;
    }
    return null;
  }
  
  /**
   * Ends the current edit.
   */
  public function endInstanceEdit():Void {
    //! FIXME Should this notify the end of editing
    setDelegate(null);
    setCell(null);
    setText(null);
    setTextField(null);
  }
  
  /**
   * Starts the editing of the text in <code>cell</code> with the delegate
   * <code>delegate</code> on the text field <code>textField</code>.
   *
   * The delegate can implement up to 3 methods:
   *   textDidBeginEditing(ASFieldEditor) - Called when text begins editing
   *   textDidEndEditing(ASFieldEditor) - Called when text finishes being edited
   *   textDidChange(ASFieldEditor) - Called when text is changed
   */
  public static function startEditing(cell:NSCell, delegate:Object,
      textField:TextField):ASFieldEditor {
    return ASFieldEditor.instance().startInstanceEdit(cell, delegate, textField);
  }
  
  /**
   * Starts the editing of the text in <code>text</code> with the delegate
   * <code>delegate</code> on the text field <code>textField</code>.
   *
   * The delegate can implement up to 3 methods:
   *   textDidBeginEditing(ASFieldEditor) - Called when text begins editing
   *   textDidEndEditing(ASFieldEditor) - Called when text finishes being edited
   *   textDidChange(ASFieldEditor) - Called when text is changed
   */
  public static function startEditingWithText(text:NSText, delegate:Object,
      textField:TextField):ASFieldEditor {
    return ASFieldEditor.instance().startInstanceEditWithText(text, delegate,
      textField);
  }
  
  /**
   * Ends the current edit.
   */
  public static function endEditing():Void {
    ASFieldEditor.instance().endInstanceEdit();
  }

  //******************************************************
  //*              Getting the instance
  //******************************************************

  /**
   * Returns the <code>ASFieldEditor</code> instance.
   */
  public static function instance():ASFieldEditor {
    if (g_instance == null) {
      g_instance = new ASFieldEditor();
    }
    return g_instance;
  }

  //******************************************************
  //*                  Notifications
  //******************************************************

  /**
   * Fired when text begins editing.
   */
  public static var NSTextDidBeginEditingNotification:Number
    = ASUtils.intern("NSTextDidBeginEditingNotification");

  /**
   * Fired when the text that was being edited ends editing.
   *
   * The userInfo dicationary contains the following:
   *  -"NSTextMovement" (NSTextMovement) - The movement taken to end the edit
   */
  public static var NSTextDidEndEditingNotification:Number
    = ASUtils.intern("NSTextDidEndEditingNotification");

  /**
   * Fired when the text currently being edited changes.
   */
  public static var NSTextDidChangeNotification:Number
    = ASUtils.intern("NSTextDidChangeNotification");
}