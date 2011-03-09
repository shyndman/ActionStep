/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.NSTabState;
import org.actionstep.NSColor;
import org.actionstep.NSObject;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTabView;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;

/**
 * Represents a single tab in an <code>NSTabView</code>.
 * 
 * The tab view must be initialized using <code>#initWithIdentifier</code>.
 * 
 * The view displayed when this tab item is selected is defined by the
 * <code>#view</code> property, and can be set using <code>#setView</code>.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSTabViewItem extends NSObject {
  
  private var m_tabView:NSTabView;
  private var m_label:String;
  private var m_identifier:Object;
  private var m_tabState:NSTabState;
  private var m_view:NSView;
  private var m_color:NSColor;
  private var m_initialFirstResponder:NSView;
  private var m_textField:TextField;
  private var m_textFormat:TextFormat;
  private var m_rect:NSRect;
  
  //******************************************************															 
  //*                    Construction
  //******************************************************
  
  /**
   * The default initializer for <code>NSTabViewItem</code>.
   * 
   * Initializes the tab view item with the unique identifier 
   * <code>identifier</code>.
   * 
   * @see #identifier
   */
  public function initWithIdentifier(identifier:Object):NSTabViewItem {
    super.init();
    m_identifier = identifier;
    m_color = ASTheme.current().colorWithName(ASThemeColorNames.ASTabViewItem);
    m_tabState = NSTabState.NSBackgroundTab;
    return this;
  }
  
  //******************************************************
  //*          Releasing the object from memory
  //******************************************************
	
  /**
   * Releases the tab item from memory.
   */
  public function release():Boolean {
    super.release();
    m_view = null;
    m_textField.removeTextField();
    return true;
  }
	
  //******************************************************															 
  //*               Describing the object
  //******************************************************
  
  /**
   * Returns a string representation of the object.
   */
  public function description():String {
    return "NSTabViewItem(label="+m_label+")";
  }
  
  //******************************************************															 
  //*               Working with labels
  //******************************************************

  /**
   * Draws this tab item's label in <code>rect</code>. If <code>truncate</code> 
   * is <code>true</code>, the label will truncate if necessary.
   */
  public function drawLabelInRect(truncate:Boolean, rect:NSRect) {
    m_rect = rect;
    var size:NSSize = sizeOfLabel(truncate);
    var tlabel:String = truncatedLabel(truncate);
    if (m_textField == null || m_textField._parent == undefined) {
      m_textField = m_tabView.createBoundsTextField();
      m_textFormat = m_tabView.font().textFormat();
      m_textFormat.color = m_tabView.fontColor().value;
      m_textField.text = tlabel;
      m_textField.autoSize = true;
      m_textField.selectable = false;
      m_textField.type = "dynamic";
      m_textField.embedFonts = m_tabView.font().isEmbedded();
      m_textField.setTextFormat(m_textFormat);
    }

    if (m_textField.text != tlabel) {
      m_textField.text = tlabel;
      m_textField.setTextFormat(m_textFormat);
    }
    
    var x:Number = rect.origin.x;
    var y:Number = rect.origin.y;
    var width:Number = rect.size.width;
    var height:Number = rect.size.height;
    m_textField._x = (rect.size.width - size.width)/2 + rect.origin.x;
    m_textField._y = (rect.size.height - size.height)/2 + rect.origin.y;
  }
  
  /**
   * Returns the label text for this tab item.
   */
  public function label():String {
    return m_label;
  }
  
  /**
   * Sets the label text for this tab item to <code>label</code>.
   */
  public function setLabel(label:String) {
    m_label = label;
  }
  
  /**
   * Calculates and returns the size of the label associated with this
   * tab item.
   */
  public function sizeOfLabel(truncate:Boolean):NSSize {
    return m_tabView.font().getTextExtent(truncatedLabel(truncate));
  }
  
  /**
   * Removes the item's textfield.
   */
  public function removeTextField():Void {
    m_textField.removeTextField();
    m_textField = null;
  }
  
  //******************************************************															 
  //*           Accessing the parent tab view
  //******************************************************
  
  /**
   * Sets the tab view of this tab item to <code>view</code>. Please note that
   * the tabView not the view displayed when this tab item is selected.
   * 
   * @see #tabView
   */
  public function setTabView(view:NSTabView) {
    m_tabView = view;
  }
  
  /**
   * Returns the tab view encompassing this tab item.
   */
  public function tabView():NSTabView {
    return m_tabView;
  }
  
  //******************************************************															 
  //*           Assigning an identifier object
  //******************************************************
  
  /**
   * Sets the unique object used to identify this tab item in the parent tab
   * view to <code>id</code>.
   */
  public function setIdentifier(id:Object) {
    m_identifier = id;
  }
  
  /**
   * Returns the unique object used to identify this tab item in the parent
   * tab view.
   * 
   * @see #setIdentifier
   * @see NSTabView#indexOfTabViewItemWithIdentifier
   * @see NSTabView#selectTabViewItemWithIdentifier
   */
  public function identifier():Object {
    return m_identifier;
  }
  
  //******************************************************															 
  //*                 Setting the color
  //******************************************************
  
  /**
   * Returns the color of this tab view item.
   */
  public function color():NSColor {
    return m_color;
  }
  
  /**
   * Sets the color of this tab view item to <code>color</code>.
   */
  public function setColor(color:NSColor):Void {
    m_color = color;
  }
  
  //******************************************************															 
  //*           Checking the tab display state
  //******************************************************
  
  /**
   * This method is internal to ActionStep. It is not intended for use.
   */
  public function setTabState(state:NSTabState) {
    m_tabState = state;
  }
  
  /**
   * Returns the current display state of this tab.
   */
  public function tabState():NSTabState {
    return m_tabState;
  }
  
  //******************************************************															 
  //*                 Assigning a view
  //******************************************************
  
  /**
   * Returns the view displayed when this tab item is selected.
   */
  public function view():NSView {
    return m_view;
  }
  
  /**
   * Sets the view displayed when this tab item is selected to 
   * <code>view</code>.
   */
  public function setView(view:NSView) {
    m_view = view;
  }
  
  //******************************************************															 
  //*         Setting the initial first responder
  //******************************************************
  
  /**
   * Returns the initial first responder of the view associated with this 
   * tab item.
   */
  public function initialFirstResponder():NSView {
    return m_initialFirstResponder;
  }
  
  /**
   * Sets the initial first responder of the view associated with this 
   * tab item to <code>view</code>.
   */
  public function setInitialFirstResponder(view:NSView) {
    m_initialFirstResponder = view;
  }
  
  //******************************************************															 
  //*                NON-OPENSTEP METHODS
  //******************************************************
  
  public function pointInTabItem(point:NSPoint):Boolean {
    return m_rect == null ? false : m_rect.pointInRect(point);
  }
  
  private function truncatedLabel(truncate:Boolean):String {
  	//! implement
    if (truncate) {
      return m_label;
    } else {
      return m_label;
    }
  }
  
}