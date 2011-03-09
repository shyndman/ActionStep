/* See LICENSE for copyright and terms of use */

import org.actionstep.NSWindow;
import org.actionstep.NSEvent;
import org.actionstep.NSRect;

/**
 * <p>The <code>NSPanel</code> class is the base class for a special kind of 
 * window. Panels are typically lightweight and reused across an application.</p>
 * 
 * <p>Examples of panel subclasses include the 
 * <code>org.actionstep.ASAlertPanel</code>, the 
 * <code>org.actionstep.NSFontPanel</code> and the 
 * <code>org.actionstep.NSColorPanel</code>.</p>
 * 
 * @author Tay Ray Chuan.
 */
class org.actionstep.NSPanel extends NSWindow {
  private var m_isFloatingPanel:Boolean;
  private var m_worksWhenModal:Boolean;
  private var m_becomesKeyOnlyIfNeeded:Boolean;
  
  //Style Mask
  public static var NSUtilityWindowMask:Number = 16;
  public static var NSDocModalWindowMask:Number = 32;
  
  /*
  //
  // New alert interface of Mac OS X
  //
  public static function NSBeginAlertSheet
  (title:String, msg:String, defaultButton:String, alternateButton:String, otherButton:String, 
  docWindow:NSWindow, modalDelegate:Object, willEndSelector:String, didEndSelector:String, 
  contextInfo, msg:String):Void
  
  public static function NSBeginCriticalAlertSheet
  (title:String, msg:String, defaultButton:String, alternateButton:String, otherButton:String, 
  docWindow:NSWindow, modalDelegate:Object, willEndSelector:String, didEndSelector:String, 
  contextInfo, msg:String):Void
  
  public static function NSBeginInformationalAlertSheet
  (title:String, msg:String, defaultButton:String, alternateButton:String, otherButton:String, 
  docWindow:NSWindow, modalDelegate:Object, willEndSelector:String, didEndSelector:String, 
  contextInfo, msg:String):Void
  */
  
  //******************************************************															 
  //*                   Construction
  //******************************************************
  
  /**
   * Creates a new instance of the <code>NSPanel</code> class.
   */
  public function NSPanel() {
  }
  
  /**
   * Initializes the panel.
   */
  public function init():NSPanel {
    var style:Number =  NSTitledWindowMask;// | NSClosableWindowMask;
    initWithContentRectStyleMask(new NSRect(0, 0, 100, 100), style);
    
    //setReleasedWhenClosed(false);
    //setHidesOnDeactivate(true);
    //setExcludedFromWindowsMenu(true);
    //return initWithContentRectStyleMaskBackingDefer
    
    return this;
  }
  
  //******************************************************															 
  //*               Describing the object
  //******************************************************
  
  /**
   * Returns a string representation of the panel.
   */
  public function description():String {
    return "NSPanel()";
  }
  
  //******************************************************															 
  //*           Configuring panel behaviour
  //******************************************************
    
  /**
   * Sets whether this panel floats above other windows to <code>flag</code>.
   */
  public function setFloatingPanel(flag:Boolean):Void {
    if (m_isFloatingPanel != flag) {
      m_isFloatingPanel = flag;
      if (flag)
        setLevel(NSWindow.NSFloatingWindowLevel);
      else
        setLevel(NSWindow.NSNormalWindowLevel);
    }
  }
 
  /**
   * Returns <code>true</code> if the panel is floating (floats above normal
   * windows), or <code>false</code> otherwise.
   */
  public function isFloatingPanel():Boolean {
    return m_isFloatingPanel;
  }
  
  /**
   * Sets whether the panel becomes the key window only when a user clicks a
   * view that edits text to <code>flag</code>.
   */
  public function setBecomesKeyOnlyIfNeeded(flag:Boolean):Void {
    m_becomesKeyOnlyIfNeeded = flag;
  }
  
  /**
   * Returns <code>true</code> if this panel only becomes key window when a view
   * is clicked that edits text, of <code>false</code> otherwise.
   */
  public function becomesKeyOnlyIfNeeded():Boolean {
    return m_becomesKeyOnlyIfNeeded;
  }
  
  /**
   * Sets whether this panel is able to recieve keyboard and mouse events
   * even when another window is being run modally to <code>flag</code>.
   */
  public function setWorksWhenModal(flag:Boolean):Void {
    m_worksWhenModal = flag;
  }
  
  /**
   * Returns <code>true</code> if the panel is able to recieve keyboard and
   * mouse events even when another window is being run modally, otherwise
   * <code>false</code>.
   */
  public function worksWhenModal():Boolean {
    return m_worksWhenModal;
  }
  
  //******************************************************															 
  //*              Overridden from NSWindow
  //******************************************************
    
  public function canBecomeKeyWindow():Boolean {
    return true;
  }
  
  public function canBecomeMainWindow():Boolean {
    return false;
  }
  
  public function sendEvent(theEvent:NSEvent):Void {
    __sendEventBecomesKeyOnlyIfNeeded(theEvent, m_becomesKeyOnlyIfNeeded);
  }
}