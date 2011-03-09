/* See LICENSE for copyright and terms of use */
 
import org.actionstep.NSImage;
import org.actionstep.NSObject;

/**
 * Represents a row in an <code>org.actionstep.ASList</code>.
 * 
 * A list item contains a label and a data object, accessible through
 * <code>#label()</code> and <code>#data()</code> respectively.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.ASListItem extends NSObject {

  private var m_label:String;
  private var m_data:Object;
  private var m_selected:Boolean;
  private var m_image:NSImage;
  private var m_visible:Boolean;
  
  //******************************************************															 
  //*                   Construction
  //******************************************************
  
  /**
   * Constructs a new instance of the <code>ASListItem</code> class.
   * 
   * Should be followed by a call to <code>#initWithLabelData()</code>.
   */
  public function ASListItem() {
    m_selected = false;
    m_visible = true;
  }
  
  /**
   * Initializes and returns the ASList item with a label of <code>label</code> 
   * and data <code>data</code>.
   */
  public function initWithLabelData(label:String, data:Object):ASListItem {
    m_label = label;
    m_data = data;
    return this;
  }

  /**
   * Initializes and returns the ASList item with a label of <code>label</code>, 
   * data <code>data</code> and image <code>image</code>.
   */  
  public function initWithLabelDataImage(label:String, data:Object, 
      image:NSImage):ASListItem {
    initWithLabelData(label, data);
    m_image = image;
    return this;
  }
  
  /**
   * Creates and returns a new <code>ASListItem</code> with a label of 
   * <code>label</code> and data of <code>data</code>.
   */
  public static function listItemWithLabelData(label:String, 
      data:Object):ASListItem {
    return (new ASListItem()).initWithLabelData(label, data);
  }
  
  //******************************************************															 
  //*               Describing the object
  //******************************************************
  
  /**
   * Returns a string representation of the object.
   */
  public function description():String {
    return "ASListItem(data=" + m_data.toString() + ")";
  }
  
  //******************************************************															 
  //*                    Properties
  //******************************************************
  
  /**
   * Returns <code>true</code> if the item is selected, or <code>false</code>
   * otherwise.
   */
  public function isSelected():Boolean {
    return m_selected;
  }
  
  /**
   * Sets whether the item is selected to <code>value</code>.
   */
  public function setSelected(value:Boolean):Void {
    m_selected = value;
  }
  
  /**
   * Sets the image displayed next to the item to <code>image</code>.
   */
  public function setImage(image:NSImage):Void {
    m_image = image;
  }
  
  /**
   * Returns the image displayed next to the item.
   */
  public function image():NSImage {
    return m_image;
  }
  
  /**
   * Sets the item's data to <code>value</code>.
   */
  public function setData(value:Object):Void {
    m_data = value;
  }
  
  /**
   * Returns the list item's data.
   */
  public function data():Object {
    return m_data;
  }
  
  /**
   * Sets the label of the list item to <code>value</code>.
   */
  public function setLabel(value:String):Void {
    m_label = value;
  }
  
  /**
   * Returns the item's label text.
   */
  public function label():String {
    return m_label;
  }
  
}