/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.ASFieldEditor;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSCellAttribute;
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.constants.NSCellType;
import org.actionstep.constants.NSComparisonResult;
import org.actionstep.constants.NSControlSize;
import org.actionstep.constants.NSLineBreakMode;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.formatter.ASFormatResult;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSAttributedString;
import org.actionstep.NSColor;
import org.actionstep.NSControl;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSFont;
import org.actionstep.NSFormatter;
import org.actionstep.NSImage;
import org.actionstep.NSMenu;
import org.actionstep.NSNumber;
import org.actionstep.NSObject;
import org.actionstep.NSPoint;
import org.actionstep.NSRange;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTimer;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSNotification;
import org.actionstep.NSActionCell;

/**
 * <p>
 * The <code>NSCell</code> class provides a mechanism for displaying text or
 * images in an <code>NSView</code> object without the overhead of a full
 * <code>NSView</code> subclass.
 * </p>
 *
 * <h3>About Cells</h3>
 * <p>
 * NSCell is used heavily by most of the NSControl classes to implement their
 * internal workings. For example, NSSlider uses an NSSliderCell, NSTextField
 * uses an NSTextFieldCell, and NSBrowser uses an NSBrowserCell. Sending a
 * message to the NSControl is often simpler than dealing directly with the
 * corresponding NSCell. For instance, NSControls typically invoke
 * {@link #updateCell()} (causing the cell to be displayed) after changing a
 * cell attribute; whereas if you directly call the corresponding method of the
 * NSCell, the NSCell might not automatically display itself again.
 * </p>
 * <p>
 * Some subclasses of NSControl (notably NSMatrix) group NSCells in an
 * arrangement where they act together in some cooperative manner. Thus, with an
 * NSMatrix, you can implement a uniformly sized group of radio buttons without
 * needing an NSView for each button.
 * </p>
 *
 * <h3>How Controls and Cells Interact</h3>
 * <p>
 * Controls are usually associated with one or more cells—instances of a
 * subclass of the abstract class NSCell. A control’s cell (or cells) usually
 * fit just inside the bounds of the control. Cells are objects that can draw
 * themselves and respond to events, but they can do so only indirectly, upon
 * instruction from their control, which acts as a kind of coordinating
 * backdrop.
 * </p>
 * <p>
 * Controls manage the behavior of their cells. By inheritance from NSView,
 * controls derive the ability for responding to user actions and rendering
 * their on-screen representation. When users click on a control, it responds in
 * part by sending {@link #trackMouseInRectOfViewUntilMouseUp()} to the cell
 * that was clicked. Upon receiving this message, the cell tracks the mouse and
 * may have the control send the cell’s action message to its target (either
 * upon mouse-up or continuously, depending on the cell’s attributes). When
 * controls receive a display request, they, in turn, send their cell (or cells)
 * a {@link #drawWithFrameInView()} message to have the cells draw themselves.
 * </p>
 * <p>
 * This relationship of control and cell makes two things possible: A control
 * can manage cells of different types and with different targets and actions,
 * and a single control can manage multiple cells. Most ActionStep controls,
 * like NSButtons and NSTextFields, manage only a single cell. But some
 * controls, notably NSMatrix and NSForm, manage multiple cells (usually of
 * the same size and attributes, and arranged in a regular pattern). Because
 * cells are lighter-weight than controls, in terms of inherited data and
 * behavior, it is more efficient to use a multi-cell control rather than
 * multiple controls.
 * </p>
 *
 * <h3>Additional Information</h3>
 * <p>
 * Additional information about NSCell specifics can be found at
 * <a href="http://developer.apple.com/documentation/Cocoa/Conceptual/ControlCell/index.html">
 * Control and Cell Programming Topics for Cocoa</a>
 * </p>
 *
 * <h3>Implementation notes:</h3>
 * <ul>
 * <li>
 * Cocoa's editWithFrameInViewEditorDelegateEvent() method is called
 * editWithEditorDelegateEvent() in ActionStep.
 * </li>
 * <li>
 * Cocoa's selectWithFrameInViewEditorDelegateStartLength() method is called
 * selectWithEditorDelegateStartLength() in ActionStep.
 * </li>
 * </ul>
 *
 * @author Richard Kilmer
 */
class org.actionstep.NSCell extends NSObject {

  //******************************************************
  //*                 State constants
  //******************************************************

  /** The corresponding feature is in effect nowhere. */
  public static var NSOffState:Number = 0;

  /** The corresponding feature is in effect everywhere. */
  public static var NSOnState:Number = 1;

  /** The corresponding feature is in effect somewhere. */
  public static var NSMixedState:Number = -1;

  //******************************************************
  //*           Constants used by NSButtonCell
  //******************************************************

  //
  // These constants specify what happens when a button is pressed or is
  // displaying its alternate state.
  //
  /** The button cell doesn't change. */
  public static var NSNoCellMask:Number = 0;

  /** The button cell pushes in if it has a border. */
  public static var NSPushInCellMask:Number = 1;

  /** The button cell displays its alternate title and image. */
  public static var NSContentsCellMask:Number = 2;

  /** The button cell swaps the control color with white pixels. NOT SUPPORTED. */
  public static var NSChangeGrayCellMask:Number = 4;

  /** Same as NSChangeGrayCellMask, only the background pixels are swapped. */
  public static var NSChangeBackgroundCellMask:Number = 8;

  //******************************************************
  //*                 Member variables
  //******************************************************

  private var m_stringValue:Object;
  private var m_objectValue:Object;
  private var m_hasValidObjectValue:Boolean;

  private var m_image:NSImage;
  private var m_imagePosition:NSCellImagePosition;
  private var m_type:NSCellType;
  private var m_state:Number;
  private var m_allowsMixedState:Boolean;
  private var m_formatter:NSFormatter;
  private var m_font:NSFont;
  private var m_fontColor:NSColor;
  private var m_editable:Boolean;
  private var m_selectable:Boolean;
  private var m_lastSelectable:Boolean;
  private var m_scrollable:Boolean;
  private var m_alignment:NSTextAlignment;
  private var m_wraps:Boolean;
  private var m_enabled:Boolean;
  private var m_bezeled:Boolean;
  private var m_bordered:Boolean;
  private var m_actionMask:Number;
  private var m_refusesFirstResponder:Boolean;
  private var m_showsFirstResponder:Boolean;
  private var m_sendsActionOnEndEditing:Boolean;
  private var m_mouseDownFlags:Number;
  private var m_highlighted:Boolean;
  private var m_controlSize:NSControlSize;
  private var m_controlView:NSView;
  private var m_app:NSApplication;
  private var m_periodicInterval:Number;
  private var m_periodicDelay:Number;
  private var m_allowsUndo:Boolean;
  private var m_isTruncated:Boolean;
  private var m_lineBreakMode:NSLineBreakMode;
  private var m_representedObject:Object;
  private var m_menu:NSMenu;

  // An AS method cannot block, so a callback is needed for tracking mouse events
  private var m_trackingCallback:Object;
  private var m_trackingCallbackSelector:String;
  private var m_trackingData:Object;

  //******************************************************
  //*                    Construction
  //******************************************************

  /**
   * Creates a new instance of <code>NSCell</code>.
   *
   * This must be followed by an initialization method.
   */
  public function NSCell() {
    m_trackingData = null;
    m_stringValue = null;
    m_objectValue = null;
    m_hasValidObjectValue = false;
    m_type = NSCellType.NSNullCellType;
    m_state = NSOffState;
    m_allowsMixedState = false;
    m_editable = true;
    m_selectable = true;
    m_lastSelectable = true;
    m_scrollable = true;
    m_alignment = NSTextAlignment.NSLeftTextAlignment;
    m_wraps = false;
    m_enabled = true;
    m_bezeled = false;
    m_allowsUndo = false;
    m_isTruncated = false;
    m_actionMask = 0;
    m_refusesFirstResponder = false;
    m_showsFirstResponder = false;
    m_sendsActionOnEndEditing = false;
    m_mouseDownFlags = 0;
    m_trackingData = null;
    m_controlSize = NSControlSize.NSRegularControlSize;
    m_lineBreakMode = NSLineBreakMode.NSDefaultLineBreak;
    
    m_controlView = null;
    m_app = NSApplication.sharedApplication();
    m_menu = getClass().defaultMenu();
  }

  /**
   * Initializes the cell as a text cell with an empty string.
   */
  public function init():NSCell {
    return initTextCell("");
  }

  /**
   * Initializes the cell as an image cell with an image of <code>image</code>.
   */
  public function initImageCell(image:NSImage):NSCell {
    m_type = NSCellType.NSImageCellType;
    m_image = image;
    m_imagePosition = NSCellImagePosition.NSImageOnly;
    m_font = ASTheme.current().systemFontOfSize(0);
    m_fontColor = ASTheme.current().systemFontColor(); // TODO add to theme
    m_actionMask = NSEvent.NSLeftMouseUpMask;
    return this;
  }

  /**
   * Initializes a text cell with the text <code>text</code>.
   */
  public function initTextCell(text:String):NSCell {
    m_type = NSCellType.NSTextCellType;
    m_imagePosition = NSCellImagePosition.NSNoImage;
    m_stringValue = text;
    m_font = ASTheme.current().systemFontOfSize(0);
    m_fontColor = ASTheme.current().systemFontColor(); // TODO add to theme
    m_actionMask = NSEvent.NSLeftMouseUpMask;
    return this;
  }

  /*
   * Overridden by subclasses to clean up cell resources
   */
  public function release():Boolean {
    return super.release();
  }
  
  //******************************************************
  //*                Copying a cell
  //******************************************************
  
  /**
   * Returns a copy of the receiving cell.
   */
  public function copyWithZone():NSCell {
    var res:Object = {};
    
    //
    // Set the class
    //
    var constructor:Function = getClass();
    res.__proto__ = constructor.prototype;
    res.__constructor__ = constructor;
    constructor.apply(res);
    
    //
    // Copy the properties
    //
    var cell:NSCell = NSCell(res);
    cell.m_stringValue = m_stringValue;
    if (ASUtils.respondsToSelector(m_objectValue, "copyWithZone")) {
      cell.m_objectValue = m_objectValue.copy();
    } else {
      cell.m_objectValue = m_objectValue;
    }
    cell.m_hasValidObjectValue = m_hasValidObjectValue;
    cell.m_image = NSImage(m_image.copyWithZone());
    cell.m_imagePosition = m_imagePosition;
    cell.m_type = m_type;
    cell.m_state = m_state;
    cell.m_allowsMixedState = m_allowsMixedState;
    cell.m_formatter = m_formatter; //! TODO clone formatter
    cell.m_font = m_font.copyWithZone();
    cell.m_fontColor = NSColor(m_fontColor.copyWithZone());
    cell.m_editable = m_editable;
    cell.m_selectable = m_selectable;;
    cell.m_lastSelectable = m_lastSelectable;
    cell.m_scrollable = m_scrollable;
    cell.m_alignment = m_alignment;
    cell.m_wraps = m_wraps;
    cell.m_enabled = m_enabled;
    cell.m_bezeled = m_bezeled;
    cell.m_bordered = m_bordered;
    cell.m_actionMask = m_actionMask;
    cell.m_refusesFirstResponder = m_refusesFirstResponder;
    cell.m_showsFirstResponder = m_showsFirstResponder;
    cell.m_sendsActionOnEndEditing = m_sendsActionOnEndEditing;
    cell.m_mouseDownFlags = m_mouseDownFlags;
    cell.m_highlighted = m_highlighted;
    cell.m_controlSize = m_controlSize;
    cell.m_controlView = m_controlView;
    cell.m_app = m_app;
    cell.m_periodicInterval = m_periodicInterval;
    cell.m_periodicDelay = m_periodicDelay;
    cell.m_allowsUndo = m_allowsUndo;
    cell.m_isTruncated = m_isTruncated;
    cell.m_lineBreakMode = m_lineBreakMode;
    cell.m_representedObject = m_representedObject;
    cell.m_menu = m_menu;
    
    return cell;
  }

  //******************************************************
  //*         Setting and getting cell values
  //******************************************************

  /**
   * Returns whether the object associated with the cell has a valid object
   * value.
   *
   * A valid object value is one that the cell’s formatter can "understand".
   * Objects are always assumed to be valid unless they are rejected by the
   * formatter.
   */
  public function hasValidObjectValue():Boolean {
    return m_hasValidObjectValue;
  }

  /**
   * Sets the cell's object value to <code>value</code>.
   */
  public function setObjectValue(value:Object) {
    m_objectValue = value;
    var contents:String = null;

    //
    // Build string from formatter if possible
    //
    if (m_formatter != null) {
    	contents = m_formatter.stringForObjectValue(m_objectValue);
    }

    //
    // Perform operations depending on the success of the formatting
    //
    if (contents == null) {
      if ((m_formatter == null) && (ASUtils.isString(value))) {
        contents = String(m_objectValue);
        m_hasValidObjectValue = true;
      } else {
        contents = m_objectValue.toString();
        m_hasValidObjectValue = false;
      }
    } else {
      m_hasValidObjectValue = true;
    }
    m_stringValue = contents;
  }

  /**
   * Returns the cell's object value unless if it is valid, otherwise
   * <code>null</code>.
   */
  public function objectValue():Object {
    if (m_hasValidObjectValue) {
      return m_objectValue;
    } else {
      return null;
    }
  }

  /**
   * Sets the value of the cell to an object <code>value</code>, representing
   * an integer value.
   */
  public function setIntValue(value:Number) {
    setObjectValue(NSNumber.numberWithInt(value));
  }

  /**
   * Returns the cell’s value as an int.
   */
  public function intValue():Number {
    if (m_objectValue != null && (typeof(m_objectValue["intValue"]) == "function")) {
      return m_objectValue.intValue();
    } else {
      return Number(stringValue());
    }
  }

  /**
   * Sets the value of the cell to an object <code>value</code>, representing
   * a double value.
   */
  public function setDoubleValue(value:Number) {
    setObjectValue(NSNumber.numberWithDouble(value));
  }

  /**
   * Returns the cell’s value as a double.
   */
  public function doubleValue():Number {
    if (m_objectValue != null && (typeof(m_objectValue["doubleValue"]) == "function")) {
      return m_objectValue.doubleValue();
    } else {
      return Number(stringValue());
    }
  }

  /**
   * Sets the value of the cell to an object <code>value</code>, representing
   * a float value.
   */
  public function setFloatValue(value:Number) {
    setObjectValue(NSNumber.numberWithFloat(value));
  }

  /**
   * Returns the cell’s value as a float.
   */
  public function floatValue():Number {
    if (m_objectValue != null && (typeof(m_objectValue["floatValue"]) == "function")) {
      return m_objectValue.floatValue();
    } else {
      return Number(stringValue());
    }
  }

  /**
   * Sets the value of the cell to an object <code>value</code>, representing
   * a string value.
   *
   * The default implementation invokes <code>#setObjectValue()</code>.
   */
  public function setStringValue(string:String) {
    if (m_type != NSCellType.NSTextCellType) {
      setType(NSCellType.NSTextCellType);
    }
    if (m_formatter == null) {
      m_stringValue = string;
      m_objectValue = null;
    } else {
      var obj:ASFormatResult = m_formatter.getObjectValueForString(string);
      if (obj.success()) {
        m_objectValue = obj.objectValue();
      } else {
        var cv:NSView = controlView();
        var del:Object;
        if (cv.respondsToSelector("delegate")
            && (del = Object(cv).delegate()) != null
            && ASUtils.respondsToSelector(del, "controlDidFailToFormatStringErrorDescription")) {
          if (del.controlDidFailToFormatStringErrorDescription(
              cv, string, obj.errorDescription())) {
            m_stringValue = string;
            m_objectValue = null;
          }
        } else {
          m_stringValue = string;
          m_objectValue = null;
        }
      }
    }
  }

  /**
   * Returns the value of the cell as a string.
   */
  public function stringValue():String {
    if (m_stringValue instanceof NSAttributedString) {
      return NSAttributedString(m_stringValue).string();
    } else {
      return String(m_stringValue);
    }
  }

  //******************************************************
  //*         Setting and getting cell attributes
  //******************************************************

  /**
   * <p>Sets a cell attribute identified by <code>attribute</code> such as the
   * receiver's state and whether it's disabled, editable, or highlighted
   * to <code>value</code>.</p>
   *
   * @see #cellAttribute()
   */
  public function setCellAttributeTo(attribute:NSCellAttribute, value:Number) {
    var boolVal:Boolean = value != 0;

    switch (attribute) {
      case NSCellAttribute.NSCellAllowsMixedState:
        setAllowsMixedState(boolVal);
        break;

//      case NSCellAttribute.NSChangeBackgroundCell:
//        break;
//      case NSCellAttribute.NSCellChangesContents:
//        break;
//      case NSCellAttribute.NSChangeGrayCell:
//        break;

      case NSCellAttribute.NSCellDisabled:
        setEnabled(!boolVal);
        break;

      case NSCellAttribute.NSCellEditable:
        setEditable(boolVal);
        break;

      case NSCellAttribute.NSCellHasImageHorizontal:
        var pos:NSCellImagePosition = imagePosition();
        if (boolVal) {
          if (pos != NSCellImagePosition.NSImageLeft
              && pos != NSCellImagePosition.NSImageRight) {
            setImagePosition(NSCellImagePosition.NSImageLeft);
          }
        } else {
          if (pos == NSCellImagePosition.NSImageLeft) {
            setImagePosition(NSCellImagePosition.NSImageAbove);
          }
          else if (pos != NSCellImagePosition.NSImageRight) {
            setImagePosition(NSCellImagePosition.NSImageBelow);
          }
        }
        break;

      case NSCellAttribute.NSCellHasImageOnLeftOrBottom:
        var pos:NSCellImagePosition = imagePosition();
        if (boolVal) {
          if (pos == NSCellImagePosition.NSImageAbove) {
            setImagePosition(NSCellImagePosition.NSImageBelow);
          } else {
            setImagePosition(NSCellImagePosition.NSImageLeft);
          }
        } else {
          if (pos == NSCellImagePosition.NSImageBelow) {
            setImagePosition(NSCellImagePosition.NSImageAbove);
          } else {
            setImagePosition(NSCellImagePosition.NSImageRight);
          }
        }
        break;

      case NSCellAttribute.NSCellHasOverlappingImage:
        if (boolVal) {
          setImagePosition(NSCellImagePosition.NSImageOverlaps);
        }
        else if (imagePosition() == NSCellImagePosition.NSImageOverlaps) {
          setImagePosition(NSCellImagePosition.NSImageLeft);
        }
        break;

      case NSCellAttribute.NSCellHighlighted:
        setHighlighted(boolVal);
        break;

      case NSCellAttribute.NSCellIsBordered:
        setBordered(boolVal);
        break;

//      case NSCellAttribute.NSCellIsInsetButton:
//        break;
//      case NSCellAttribute.NSCellLightsByBackground:
//        break;
//      case NSCellAttribute.NSCellLightsByContents:
//        break;
//      case NSCellAttribute.NSCellLightsByGray:
//        break;
//      case NSCellAttribute.NSPushInCell:
//        break;

      case NSCellAttribute.NSCellState:
        setState(value);
        break;

      default:
        trace(asWarning("cell attribute " + attribute.value + " not supported"));
        break;
    }
  }

  /**
   * <p>Returns the value for the specified cell attribute.</p>
   */
  public function cellAttribute(attribute:NSCellAttribute):Number {
    switch (attribute) {
      case NSCellAttribute.NSCellAllowsMixedState:
        return allowsMixedState() ? 1 : 0;

//      case NSCellAttribute.NSChangeBackgroundCell:
//        break;
//      case NSCellAttribute.NSCellChangesContents:
//        break;
//      case NSCellAttribute.NSChangeGrayCell:
//        break;

      case NSCellAttribute.NSCellDisabled:
        return isEnabled() ? 0 : 1;

      case NSCellAttribute.NSCellEditable:
        return isEditable() ? 1 : 0;

      case NSCellAttribute.NSCellHasImageHorizontal:
        var pos:NSCellImagePosition = imagePosition();
        return pos == NSCellImagePosition.NSImageLeft
          || pos == NSCellImagePosition.NSImageRight ? 1 : 0;

      case NSCellAttribute.NSCellHasImageOnLeftOrBottom:
        var pos:NSCellImagePosition = imagePosition();
        return pos == NSCellImagePosition.NSImageLeft
          || pos == NSCellImagePosition.NSImageBelow ? 1 : 0;

      case NSCellAttribute.NSCellHasOverlappingImage:
        return imagePosition() == NSCellImagePosition.NSImageOverlaps ? 1 : 0;

      case NSCellAttribute.NSCellHighlighted:
        return isHighlighted() ? 1 : 0;

      case NSCellAttribute.NSCellIsBordered:
        return isBordered() ? 1 : 0;

//      case NSCellAttribute.NSCellIsInsetButton:
//        break;
//      case NSCellAttribute.NSCellLightsByBackground:
//        break;
//      case NSCellAttribute.NSCellLightsByContents:
//        break;
//      case NSCellAttribute.NSCellLightsByGray:
//        break;
//      case NSCellAttribute.NSPushInCell:
//        break;

      case NSCellAttribute.NSCellState:
        return state();

      default:
        trace(asWarning("cell attribute " + attribute.value + " not supported"));
        break;
    }

    return null;
  }

  /**
   * <p>Sets the type of the cell, changing it to a text cell, image cell, or
   * null cell.</p>
   *
   * <p>If the cell is already the same type as the one specified in the
   * <code>value</code> parameter, this method does nothing.</p>
   *
   * <p>If <code>value</code> is {@link NSCellType#NSTextCellType}, this method
   * converts the receiver to a cell of that type, giving it a default title and
   * setting the font to the system font at the default size. If
   * <code>value</code> is {@link NSCellType#NSImageCellType}, the cell type is
   * not changed until you set a new non-null image.</p>
   *
   * @see #type()
   */
  public function setType(value:NSCellType):Void {
  	if (m_type == value) {
      return;
    }

    if (value == NSCellType.NSImageCellType && m_image == null) {
      return; // this will get recalled when an image is set
    }

    m_type = value;
  }

  /**
   * Returns the type of the receiver
   */
  public function type():NSCellType {
    return m_type;
  }

  /**
   * <p>Sets whether the receiver is enabled or disabled.</p>
   *
   * <p>The text of disabled cells is changed to gray. If a cell is disabled,
   * it cannot be highlighted, does not support mouse tracking (and thus cannot
   * participate in target/action functionality), and cannot be edited. However,
   * you can still alter many attributes of a disabled cell programmatically.
   * (The {@link #setStateTo()} method, for instance, still works.)</p>
   *
   * @see #isEnabled()
   */
  public function setEnabled(value:Boolean):Void {
    m_enabled = value;
  }

  /**
   * <p>Returns <code>true</code> if the receiver is enabled, or <code>false</code>
   * otherwise.</p>
   *
   * @see #setEnabled()
   */
  public function isEnabled():Boolean {
    return m_enabled;
  }

  /**
   * <p>Sets whether the receiver draws itself with a bezeled border, depending
   * on the Boolean value <code>flag</code>. The {@link #setBezeled()} and
   * {@link #setBordered()} methods are mutually exclusive (that is, a border
   * can be only plain or bezeled).</p>
   *
   * <p>Invoking this method automatically removes any border that had already
   * been set, regardless of the value in the <code>flag</code> parameter.</p>
   */
  public function setBezeled(flag:Boolean) {
    m_bezeled = flag;
    m_bordered = false;
  }

  /**
   * Returns whether the receiver has a bezeled border.
   *
   * @see #setBezeled()
   */
  public function isBezeled():Boolean {
    return m_bezeled;
  }

  /**
   * <p>Sets whether the receiver draws itself outlined with a plain border,
   * depending on the Boolean value <code>flag</code>. The {@link #setBezeled()}
   * and {@link #setBordered()} methods are mutually exclusive (that is, a
   * border can be only plain or bezeled).</p>
   *
   * <p>Invoking this method automatically removes any bezel that had already
   * been set, regardless of the value in the <code>flag</code> parameter.</p>
   *
   * @see #isBordered()
   */
  public function setBordered(flag:Boolean) {
    m_bordered = flag;
    if (m_bordered) {
      m_bezeled = false;
    }
  }

  /**
   * Returns whether the receiver has a plain border.
   *
   * @see #setBordered()
   */
  public function isBordered():Boolean {
    return m_bordered;
  }

  /**
   * Returns whether the receiver is opaque (nontransparent).
   */
  public function isOpaque():Boolean {
    return false;
  }

  /**
   * <p>
   * Returns a Boolean value indicating whether the cell assumes responsibility
   * for undo operations.
   * </p>
   * <p>
   * Returns <code>true</code> if the cell handles undo operations; otherwise,
   * <code>false</code>.
   * </p>
   *
   * @see #setAllowsUndo()
   */
  public function allowsUndo():Boolean {
    return m_allowsUndo;
  }

  /**
   * <p>
   * Sets whether the receiver assumes responsibility for undo operations within
   * the cell.
   * </p>
   * <p>
   * If <code>allowsUndo</code> is <code>true</code>, the cell handles undo
   * operations; otherwise, if <code>false</code>, the application's custom undo
   * manager handles undo operations.
   * </p>
   * <p>
   * Subclasses invoke this method to indicate their preference for handling
   * undo operations; otherwise, you should not need to call this method
   * directly.
   * </p>
   *
   * TODO figure out how this integrates into the framework
   *
   * @see #allowsUndo()
   */
  public function setAllowsUndo(allowsUndo:Boolean):Void {
    m_allowsUndo = allowsUndo;
  }

  /**
   * <p>For internal use.</p>
   *
   * <p>Returns <code>true</code> if the text displayed by this cell has been
   * truncated.</p>
   */
  public function isTruncated():Boolean {
    return m_isTruncated;
  }

  //******************************************************
  //*                Setting the state
  //******************************************************

  /**
   * Returns <code>true</code> if the cell allows three states:
   * on, off and mixed.
   */
  public function allowsMixedState():Boolean {
    return m_allowsMixedState;
  }

  /**
   * Returns the cell's next state.
   *
   * If the cell has three states, it cycles through them in the order of
   * on, off, mixed, on, off, mixed and so on.
   */
  public function nextState():Number {
    switch(m_state) {
      case NSOnState:
        return NSOffState;
        break;
      case NSOffState:
        if(m_allowsMixedState) {
          return NSMixedState;
        } else {
          return NSOnState;
        }
        break;
      case NSMixedState:
        return NSOnState;
        break;
      default:
        return NSOnState;
        break;
    }
  }

  /**
   * If <code>value</code> is <code>true</code>, the cell will have three
   * states, on, off and mixed. Otherwise it will only have on and off.
   */
  public function setAllowsMixedState(value:Boolean) {
    m_allowsMixedState = value;
  }

  /**
   * Sets the cell's state to its next state.
   *
   * @see #nextState()
   */
  public function setNextState() {
    setState(nextState());
  }

  /**
   * Returns the cell's current state.
   */
  public function state():Number {
    return m_state;
  }

  /**
   * Sets the cell's state to <code>value</code>.
   *
   * If <code>value</code> is <code>NSMixedState</code> and the cell does not
   * allow mixed state, this method sets the state to <code>NSOnState</code>.
   */
  public function setState(value:Number):Void {
    if (value == NSMixedState && !allowsMixedState()) {
      value = NSOnState;
    }
    m_state = value;
  }

  //******************************************************
  //*        Modifying textual attributes of cells
  //******************************************************

  /**
   * Sets whether this cell is editable to <code>value</code>.
   */
  public function setEditable(value:Boolean):Void {
    if (m_editable == value) {
      return;
    }

    m_editable = value;

    if (m_editable) {
      m_lastSelectable = m_selectable;
      m_selectable = true;
    } else {
      m_selectable = m_lastSelectable;
    }
  }

  /**
   * Returns whether this cell is editable.
   */
  public function isEditable():Boolean {
    return m_editable;
  }

  /**
   * Sets whether this cell is selectable to <code>value</code>.
   */
  public function setSelectable(value:Boolean) {
    m_selectable = value;
    if (!m_selectable) {
      m_editable = false;
    }
  }

  /**
   * Returns whether this cell is selectable.
   */
  public function isSelectable():Boolean {
    return m_enabled && (m_selectable || m_editable);
  }

  /**
   * <p>Sets whether excess text in the receiver is scrolled past the cell’s
   * bounds.</p>
   *
   * <p>If <code>value</code> is <code>true</code>, text can be scrolled past
   * the cell's bounds; otherwise, if <code>false</code>, the text wrapping
   * is enabled.</p>
   *
   * @see #isScrollable()
   */
  public function setScrollable(value:Boolean) {
    m_scrollable = value;
    m_wraps = !value;
  }

  /**
   * <p>Returns a Boolean value indicating whether the receiver scrolls excess
   * text past the cell’s bounds.</p>
   *
   * <p>Returns <code>true</code> if excess text scrolls past the cell's bounds
   * or <code>false</code> if text wrapping is enabled.</p>
   */
  public function isScrollable():Boolean {
    return m_scrollable;
  }

  /**
   * Sets this cell's text alignment to <code>value</code>.
   */
  public function setAlignment(value:NSTextAlignment) {
    m_alignment = value;
  }

  /**
   * <p>Returns this cell's text alignment.</p>
   *
   * <p>The default is {@link NSTextAlignment#NSLeftTextAlignment}.</p>
   */
  public function alignment():NSTextAlignment {

    return m_alignment;
  }

  /**
   * Returns this cell's font.
   */
  public function font():NSFont {
    return m_font;
  }

  /**
   * Sets this cell's font to <code>value</code>.
   */
  public function setFont(value:NSFont) {
    m_font = value;
  }

  /**
   * Sets this cell's font color to <code>color</code>.
   */
  public function setFontColor(color:NSColor) {
    m_fontColor = color;
  }

  /**
   * Returns this cell's font color.
   */
  public function fontColor():NSColor {
    return m_fontColor;
  }

  /**
   * Sets how this cell should truncate its text to <code>type</code>. If
   * <code>type</code> is <code>null</code>, no truncating will occur.
   */
  public function setLineBreakMode(type:NSLineBreakMode):Void {
    m_lineBreakMode = type;
  }

  /**
   * Returns an object describing how this cell should truncate its text, or
   * <code>null</code> if no truncating will occur.
   */
  public function lineBreakMode():NSLineBreakMode {
    return m_lineBreakMode;
  }

  /**
   * <p>Sets whether the text in this cell wraps when it exceeds the frame of
   * the cell. If <code>value</code> is <code>true</code> then the cell is also
   * set to be non-scrollable.</p>
   *
   * <p>When <code>value</code> is <code>true</code>, a truncating type can also
   * be specified using <code>#setTruncatingType()</code>.</p>
   *
   * @see #wraps()
   */
  public function setWraps(value:Boolean) {
    m_wraps = value;
    if (m_wraps) {
      m_scrollable = false;
    }
  }

  /**
   * <p>Returns a Boolean value indicating whether the receiver wraps its text
   * when the text exceeds the borders of the cell.</p>
   *
   * <p><code>true</code> if the receiver wraps text; otherwise,
   * <code>false</code>.</p>
   *
   * @see #setWraps()
   */
  public function wraps():Boolean {
    return m_wraps;
  }

  /**
   * <p>Sets the value of the receiver’s cell using an attributed string.</p>
   *
   * <p>If a formatter is set for the receiver, but the formatter does not
   * understand the attributed string, it marks <code>value</code> as an invalid
   * object. If the receiver is not a text-type cell, it is converted to one
   * before the value is set.</p>
   *
   * @see #attributedStringValue()
   */
  public function setAttributedStringValue(value:NSAttributedString) {
    if (m_formatter != null) {
      //! What do we do with the attributed string values and the formatter?
    }
    if (type() != NSCellType.NSTextCellType) {
      setType(NSCellType.NSTextCellType);
    }

    m_stringValue = value;
  }

  /**
   * <p>Returns the value of the receiver’s cell as an attributed string using
   * the receiver's formatter object (if one exists).</p>
   */
  public function attributedStringValue():NSAttributedString {
    if (m_stringValue instanceof NSAttributedString) {
      return NSAttributedString(m_stringValue);
    }
    if (m_formatter != null) {
      //! generate NSAttributedString?
    }
    return (new NSAttributedString()).initWithString(String(m_stringValue));
  }

  /**
   * Returns the receiver's title. By default it returns the cell's string
   * value. Subclasses, such as NSButtonCell, may override this method to
   * return a different value.
   */
  public function title():String {
    return stringValue();
  }

  /**
   * Sets the title of the receiver to aString.
   */
  public function setTitle(aString:String) {
    setStringValue(aString);
  }

  //******************************************************
  //*           Setting the target and action
  //******************************************************

  /**
   * Sets the action of this cell to <code>selector</code>.
   *
   * The action is the name of the method on the <code>#target</code> that will
   * be called when the cell's action is fired. The method should take a single
   * parameter; the reference to the sender.
   */
  public function setAction(selector:String) {
    var e:NSException = NSException.exceptionWithNameReasonUserInfo(
      "NSInternalInconsistencyException",
      "Must be overridden by subclasses.",
      null);
    trace(e);
    throw e;
  }

  /**
   * Returns the action of this cell.
   */
  public function action():String {
    return null;
  }

  /**
   * Sets the target of this cell to <code>object</code>.
   *
   * The target's <code>#action</code> method is called whenever the cell's
   * action message is triggered.
   */
  public function setTarget(object:Object) {
    var e:NSException = NSException.exceptionWithNameReasonUserInfo(
      "NSInternalInconsistencyException",
      "Must be overridden by subclasses.",
      null);
    trace(e);
    throw e;
  }

  /**
   * Returns this cell's target.
   */
  public function target():Object {
    return null;
  }

  /**
   * Sets whether the receiver continuously sends its action message to its
   * target while it tracks the mouse, depending on the Boolean value flag. In
   * practice, the continuous setting has meaning only for instances of
   * NSActionCell and its subclasses, which implement the target/action mechanism.
   * Some NSControl subclasses, notably NSMatrix, send a default action to a
   * default target when a cell doesn't provide a target or action.
   */
  public function setContinuous(value:Boolean) {
    if(value) {
      m_actionMask |= NSEvent.NSPeriodicMask;
    } else {
      m_actionMask &= ~NSEvent.NSPeriodicMask;
    }
  }

  /**
   * Returns whether the receiver sends its action message continuously on mouse down.
   */
  public function isContinuous():Boolean {
    return (m_actionMask & NSEvent.NSPeriodicMask)!=0;
  }

  /**
   * <p>
   * Sets the conditions on which the receiver sends action messages to its
   * target.
   * </p>
   * <p>
   * <code>mask</code> is a bit mask containing the conditions for sending the
   * action. The only conditions that are actually checked are associated with
   * the {@link NSEvent#NSLeftMouseDownMask}, {@link NSEvent#NSLeftMouseUpMask},
   * {@link NSEvent#NSLeftMouseDraggedMask}, and {@link NSEvent#NSPeriodicMask}
   * bits.
   * </p>
   * <p>
   * The previous action mask is returned.
   * </p>
   *
   * @see #action()
   */
  public function sendActionOn(mask:Number):Number {
    var oldMask:Number = m_actionMask;
    m_actionMask = mask;
    return oldMask;
  }

  //******************************************************
  //*            Setting and getting an image
  //******************************************************

  /**
   * <p>Sets the image to be displayed by the receiver.</p>
   *
   * <p><code>value</code> is the image to display in the cell.</p>
   *
   * <p>If the receiver is not an image-type cell, the method converts it to
   * that type of cell. If the receiver is an image-type cell and image is
   * <code>null</code> or different from the current one, the image currently
   * held by the receiver is discarded.</p>
   *
   * @see #image()
   * @see #setType()
   */
  public function setImage(value:NSImage) {
    if (value == m_image) {
      return;
    }
    
  	var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
    
    //
    // Stop observing old image
    //
    if (m_image != null) {
      nc.removeObserverNameObject(this, NSImage.NSImageDidLoadNotification, m_image);
    }
    
    m_image = value; // must be before setType()
    if (type()!=NSCellType.NSImageCellType) {
      setType(NSCellType.NSImageCellType);
    }
    
    //
    // Begin observing new image
    //
    if (m_image != null && !m_image.isRepresentationLoaded()) {
      nc.addObserverSelectorNameObject(this, "imageDidLoad", 
        NSImage.NSImageDidLoadNotification, m_image);
    }
    else if (!(this instanceof NSActionCell)) {
      m_controlView.setNeedsDisplay(true);
    }
    
    
  }

  /**
   * <p>
   * Returns the image displayed by the receiver (if any).
   * </p>
   * <p>
   * The image displayed by the receiver, or <code>null</code> if the receiver
   * is not an image-type cell.
   * </p>
   *
   * @see #setImage()
   */
  public function image():NSImage {
    if (type() != NSCellType.NSImageCellType) {
      return null;
    }
    return m_image;
  }

  /**
   * Sets the position of the image within the cell to <code>value</code>.
   */
  private function setImagePosition(value:NSCellImagePosition) {
    m_imagePosition = value;
  }

  /**
   * Returns the position of the image within this cell.
   */
  private function imagePosition():NSCellImagePosition {
    return m_imagePosition;
  }

  /**
   * Calls setImage() with the newly loaded image. The observer will be removed,
   * and <code>ActionCell</code> subclasses will tell their controls to update.
   */
  private function imageDidLoad(ntf:NSNotification):Void {  	
    setImage(m_image);
  }

  //******************************************************
  //*                  Assigning a tag
  //******************************************************

  /**
   * <p>Sets the tag of the receiver.</p>
   *
   * <p>The NSCell implementation of this method raises an exception. The
   * <code>NSActionCell</code> implementation sets the receiver's tag to
   * <code>value</code>.</p>
   *
   * <p>Tags allow you to identify particular cells. Tag values are not used
   * internally; they are only changed by external invocations of
   * {@link #setTag()}.</p>
   *
   * @see #tag()
   */
  public function setTag(value:Number) {
    var e:NSException = NSException.exceptionWithNameReasonUserInfo(
      NSException.NSInternalInconsistency,
      "Must be overridden by subclasses.",
      null);
    trace(e);
    throw e;
  }

  /**
   * <p>Returns the tag identifying the receiver.</p>
   *
   * <p>The NSCell implementation of this method returns <code>-1</code>.</p>
   *
   * <p>Tags allow you to identify particular cells. Tag values are not used
   * internally; they are only changed by external invocations of
   * {@link #setTag()}.</p>
   *
   * @see #setTag()
   */
  public function tag():Number {
    return -1;
  }

  //******************************************************
  //*           Formatting and validating data
  //******************************************************

  /**
   * Returns the formatter object (a kind of <code>NSFormatter</code>)
   * associated with the cell.
   *
   * This object is responsible for translating an object's onscreen (text)
   * representation back and forth between its object value.
   */
  public function formatter():NSFormatter {
    return m_formatter;
  }

  /**
   * Sets the formatter object used to format the textual representation of the
   * cell’s object value and to validate cell input and convert it to that
   * object value.
   */
  public function setFormatter(value:NSFormatter) {
    if (null == value.stringForObjectValue(objectValue())) {
      setStringValue(value.toString());
    }

    m_formatter = value;
  }

  //******************************************************
  //*            Managing menus for cells
  //******************************************************

  /**
   * <p>Returns the default menu for instances of the receiver.</p>
   *
   * <p>The NSCell implementation of this method returns <code>null</code>.</p>
   *
   * @see #menu()
   * @see #setMenu()
   */
  public static function defaultMenu():NSMenu {
    return null;
  }

  /**
   * <p>Returns the cell's contextual menu, or <code>null</code> is no
   * menu is assigned.</p>
   *
   * <p>Upon construction, the cell's menu is set to the value returned by the
   * cell class' {@link #defaultMenu()} method.</p>
   *
   * @see #menuForEventInRectOfView()
   * @see #setMenu()
   * @see #defaultMenu()
   */
  public function menu():NSMenu {
    return m_menu;
  }

  /**
   * <p>Sets the contextual menu for the cell.</p>
   *
   * <p>Upon construction, the cell's menu is set to the value returned by the
   * cell class' {@link #defaultMenu()} method.</p>
   *
   * @see #setMenu()
   */
  public function setMenu(aMenu:NSMenu):Void {
    m_menu = aMenu;
  }

  /**
   * <p>Returns the menu associated with the receiver and related to the
   * specified event and frame.</p>
   *
   * <p>This method is usually invoked by the {@link org.actionstep.NSControl}
   * object (<code>aView</code>) managing the receiver. The default
   * implementation simply invokes {@link #menu()} and returns <code>null</code>
   * if no menu has been set. Subclasses can override to customize the returned
   * menu according to the event received and the area in which the mouse event
   * occurs.</p>
   *
   * @see #menu()
   * @see #setMenu()
   */
  public function menuForEventInRectOfView(anEvent:NSEvent, cellFrame:NSRect,
      aView:NSView):NSMenu {
    return menu();
  }

  //******************************************************
  //*                 Comparing cells
  //******************************************************

  /**
   * <p>Compares the string values of the cell and <code>otherObject</code> (which
   * must be a kind of <code>NSCell</code>), disregarding case.</p>
   *
   * <p>Raises exception if <code>otherObject</code> is not of the
   * <code>NSCell</code> class.</p>
   */
  public function compare(otherObject:Object):NSComparisonResult {
    if (!(otherObject instanceof NSCell)) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
        NSException.NSBadComparisonException,
        "Cannot compare a cell with a non-cell.",
        null);
      trace(e);
      throw e;
    }

    var str1:String = stringValue().toLowerCase();
    var str2:String = NSCell(otherObject).stringValue().toLowerCase();

    if (str1 < str2) {
      return NSComparisonResult.NSOrderedAscending;
    }
    else if (str1 > str2) {
      return NSComparisonResult.NSOrderedDescending;
    }

    return NSComparisonResult.NSOrderedSame;
  }

  //******************************************************
  //*       Making cells respond to keyboard events
  //******************************************************

  /**
   * <p>Returns a Boolean value indicating whether the receiver accepts first
   * responder status.</p>
   *
   * <p><code>true</code> if the receiver can become the first responder;
   * otherwise, <code>false</code>. The default value is <code>true</code> if
   * the receiver is enabled. Subclasses may override this method to return a
   * different value.</p>
   */
  public function acceptsFirstResponder():Boolean {
    return m_enabled && !m_refusesFirstResponder;
  }

  /**
   * <p>
   * Sets whether the receiver should not become the first responder.
   * </p>
   * <p>
   * If <code>flag</code> is <code>true</code>, the receiver should never
   * become the first responder; otherwise, it may become the first
   * responder.
   * </p>
   *
   * @see #refusesFirstResponder()
   */
  public function setRefusesFirstResponder(flag:Boolean) {
    m_refusesFirstResponder = flag;
  }

  /**
   * <p>
   * Returns a Boolean value indicating whether the receiver should not become
   * the first responder.
   * </p>
   *
   * <p><code>true</code> if the receiver should never become the first
   * responder; otherwise, <code>false</code> if the receiver can become the
   * first responder.</p>
   *
   * <p>
   * To find out whether the receiver can become first responder at this time,
   * use the method {@link #acceptsFirstResponder()}.
   * </p>
   *
   * @see #setRefusesFirstResponder()
   */
  public function refusesFirstResponder():Boolean {
    return m_refusesFirstResponder;
  }

  /**
   * <p>
   * Sets whether the receiver should draw some indication of its first
   * responder status.
   * </p>
   * <p>
   * If <code>flag</code> is <code>true</code> the receiver should draw an
   * indication of first responder status.
   * </p>
   *
   * @see #showsFirstResponder()
   */
  public function setShowsFirstResponder(flag:Boolean) {
    m_showsFirstResponder = flag;
  }

  /**
   * <p>
   * Returns a Boolean value indicating whether the receiver should draw some
   * indication of its first responder status.
   * </p>
   * <p>
   * Returns <code>true</code> if the receiver should draw an indication of
   * first responder status, or <code>false</code> otherwise.
   * </p>
   * <p>
   * The NSCell class itself does not draw a first-responder indicator.
   * Subclasses may use the returned value to determine whether or not they
   * should draw one, however.
   * </p>
   *
   * @see #setShowsFirstResponder()
   */
  public function showsFirstResponder():Boolean {
    return m_showsFirstResponder;
  }

  //! TODO - (void)setTitleWithMnemonic:(NSString *)aString
  //! TODO - (NSString *)mnemonic
  //! TODO - (void)setMnemonicLocation:(unsigned)location

  /**
   * <p>Simulates a single mouse click on the receiver.</p>
   *
   * @param sender The object to use as the sender of the event (if the
   * 		receiver's control view is not valid). This object must be a
   * 		subclass of <code>NSView</code>.
   *
   * <p>This method performs the receiver's action on its target. The receiver
   * must be enabled to perform the action. If the receiver's control view is
   * valid, that view is used as the sender; otherwise, the value in sender is
   * used.</p>
   *
   * @see #controlView()
   */
  public function performClick(sender:Object) {
    var cview:NSView = controlView();
    if (cview != null) {
      performClickWithFrameInView(cview.bounds(), cview);
    }
    else if (sender instanceof NSView) {
      var v:NSView = NSView(sender);
      performClickWithFrameInView(v.bounds(), v);
    }
  }

  /**
   * <p>Called by {@link NSControl#performClick()} and {@link #performClick()}
   * to simulate a single mouse click on the receiver.</p>
   *
   * @see #performClick()
   */
  public function performClickWithFrameInView(frame:NSRect, view:NSView) {
    if (!m_enabled) {
      return;
    }
    if(view != null) {
      setHighlighted(true);
      drawWithFrameInView(frame, view);
      NSTimer.scheduledTimerWithTimeIntervalTargetSelectorUserInfoRepeats(.1, this, "__performClickCallback", {frame:frame, view:view}, false);
    } else {
      setNextState();
      NSApplication.sharedApplication().sendActionToFrom(action(), target(), this);
    }
  }

  private function __performClickCallback(timer:NSTimer) {
    var info:Object = timer.userInfo();
    setHighlighted(false);
    drawWithFrameInView(info.frame, info.view);
    setNextState();
    NSControl(info.view).sendActionTo(action(), target());
  }

  //******************************************************
  //*         Deriving values from other cells
  //******************************************************

  /**
   * <p>Sets the value of the receiver’s cell to the object value obtained from
   * the specified object.</p>
   *
   * @param sender The object from which to take the value. This object must
   * 		implement an <code>objectValue()</code> method.
   *
   * @see #setObjectValue()
   */
  public function takeObjectValueFrom(sender:Object):Void {
    if (ASUtils.respondsToSelector(sender, "objectValue")) {
      setObjectValue(sender.objectValue());
    }
  }

  /**
   * <p>Sets the value of the receiver’s cell to an integer value obtained from
   * the specified object.</p>
   *
   * @param sender The object from which to take the value. This object must
   * 		implement an <code>intValue()</code> method.
   *
   * <p>
   * The following example shows this method being used to write the value
   * taken from a slider (sender) to a text field cell:
   * </p>
   * <pre>
   * 	public function sliderMoved(sender:NSSlider):Void {
   * 		valueField.cell().takeIntValueFrom(sender.cell());
   * 		valueField.display();
   * 	}
   * </pre>
   *
   * @see #setIntValue()
   */
  public function takeIntValueFrom(sender:Object):Void {
    if (ASUtils.respondsToSelector(sender, "intValue")) {
      setIntValue(sender.intValue());
    }
  }

  /**
   * <p>Sets the value of the receiver’s cell to the string value obtained from
   * the specified object.</p>
   *
   * @param sender The object from which to take the value. This object must
   * 		implement a <code>stringValue()</code> method.
   *
   * @see #setStringValue()
   */
  public function takeStringValueFrom(sender:Object):Void {
    if (ASUtils.respondsToSelector(sender, "stringValue")) {
      setStringValue(sender.stringValue());
    }
  }

  /**
   * <p>Sets the value of the receiver’s cell to the double value obtained from
   * the specified object.</p>
   *
   * @param sender The object from which to take the value. This object must
   * 		implement an <code>doubleValue()</code> method.
   *
   * @see #setDoubleValue()
   */
  public function takeDoubleValueFrom(sender:Object):Void {
    if (ASUtils.respondsToSelector(sender, "doubleValue")) {
      setDoubleValue(sender.doubleValue());
    }
  }

  /**
   * <p>Sets the value of the receiver’s cell to the float value obtained from
   * the specified object.</p>
   *
   * @param sender The object from which to take the value. This object must
   * 		implement an <code>floatValue()</code> method.
   *
   * @see #setFloatValue()
   */
  public function takeFloatValueFrom(sender:Object):Void {
    if (ASUtils.respondsToSelector(sender, "floatValue")) {
      setFloatValue(sender.floatValue());
    }
  }

  //******************************************************
  //*         Representing an object with a cell
  //******************************************************

  /**
   * Sets the object represented by the cell to <code>anObject</code>.
   */
  public function setRepresentedObject(anObject:Object):Void {
    m_representedObject = anObject;
  }

  /**
   * Returns the object the cell represents.
   *
   * For example, you could have a pop-up list of color names, and the
   * represented objects could be the appropriate <code>NSColor</code> objects.
   */
  public function representedObject():Object {
    return m_representedObject;
  }

  //******************************************************
  //*                Tracking the mouse
  //******************************************************

  /**
   * <p>Sets the object and method that will be called when a mouse tracking
   * operation is completed.</p>
   *
   * <p>The callback method's signature should be as follows:
   * <code>function methodName(mouseUp:Boolean, isPeriodic:Boolean):Void</code>
   * </p>
   *
   * <p>The <code>mouseUp</code> argument is <code>true</code> if mouse tracking
   * ended as a result of a mouse up event. <code>isPeriodic</code> is
   * <code>true</code> if the cell is setup to send continuous action
   * messages to its target while the mouse is down.</p>
   *
   * <p>Read the documentation for {@link #trackMouseInRectOfViewUntilMouseUp()}
   * to understand exactly under what conditions the callback will be
   * invoked.</p>
   *
   * <p>This method is ActionStep only. It is necessary because of
   * ActionScript's lack of multithreading.</p>
   */
  public function setTrackingCallbackSelector(callback:Object, selector:String) {
    m_trackingCallback = callback;
    m_trackingCallbackSelector = selector;
  }

  /**
   * <p>Called by {@link #trackMouseInRectOfViewUntilMouseUp()} to determine
   * under what conditions the cell should be notified about mouse tracking
   * events.</p>
   */
  private function trackingEventMask():Number {
    return NSEvent.NSLeftMouseDownMask
      | NSEvent.NSLeftMouseUpMask
      | NSEvent.NSLeftMouseDraggedMask
      | NSEvent.NSMouseMovedMask
      | NSEvent.NSOtherMouseDraggedMask
      | NSEvent.NSRightMouseDraggedMask;
  }

  /**
   * <p>Returns a boolean value indicating whether tracking stops when the
   * cursor leaves the cell.</p>
   *
   * <p>Returns <code>true</code> if tracking stops when the mouse leaves the
   * cell, or <code>false</code> otherwise.</p>
   *
   * <p>The default implementation returns <code>false</code>.</p>
   *
   * @see #trackMouseInRectOfViewUntilMouseUp()
   */
  public static function prefersTrackingUntilMouseUp():Boolean {
    return false;
  }

  /**
   * <p>Initiates the mouse tracking behavior in a cell.</p>
   *
   * @param event The event that caused the mouse tracking to occur.
   * @param rect The cell's frame rectangle.
   * @param view The view containing the cell.
   * @param untilMouseUp <code>true</code> if tracking continues until the
   * 			user releases the mouse button.
   *
   * <p>
   * This method is generally not overridden because the default
   * implementation invokes other NSCell methods that can be overridden to
   * handle specific events in a dragging session. This method’s callback value
   * depends on the <code>untilMouseUp</code> flag. If <code>untilMouseUp</code>
   * is set to <code>true</code>, this method calls the tracking callback
   * with a value of <code>true</code> if the mouse button goes up while the
   * cursor is anywhere; <code>false</code>, otherwise. If
   * <code>untilMouseUp</code> is set to <code>false</code>, this method
   * calls the tracking callback with a value of <code>true</code> if the mouse
   * button goes up while the cursor is within <code>rect</code>;
   * <code>false</code>, otherwise.
   * </p>
   *
   * <p>
   * This method first invokes {@link #startTrackingAtInView()}. If that method
   * returns <code>true</code>, then as mouse-dragged events are intercepted,
   * {@link #continueTrackingAtInView()} is invoked until either the method
   * returns <code>false</code> or the mouse is released. Finally,
   * {@link #stopTrackingAtInViewMouseIsUp()} is invoked if the mouse is
   * released. If <code>untilMouseUp</code> is <code>true</code>, it’s invoked
   * when the mouse button goes up while the cursor is anywhere. If
   * <code>untilMouseUp</code> is <code>false</code>, it’s invoked when the
   * mouse button goes up while the cursor is within <code>rect</code>. (If
   * <code>rect</code> is <code>null</code>, then the bounds are considered
   * infinitely large.) You usually override one or more of these methods to
   * respond to specific mouse events.
   * </p>
   *
   * <p>
   * This method normally returns a boolean, but we have to support a callback
   * mechanism. When the cell finishes tracking the mouse, the tracking
   * callback object gets called with a single boolean argument that represents
   * the value that would be returned from this function if ActionScript
   * supported thread blocking. The callback object can be set with the
   * {@link #setTrackingCallbackSelector()} method.
   * </p>
   *
   * @see #setTrackingCallbackSelector()
   * @see #startTrackingAtInView()
   * @see #continueTrackingAtInView()
   * @see #stopTrackingAtInViewMouseIsUp()
   */
  public function trackMouseInRectOfViewUntilMouseUp(event:NSEvent, rect:NSRect,
      view:NSView, untilMouseUp:Boolean):Void {
    var location:NSPoint = event.mouseLocation;
    var point:NSPoint = location.clone();
    var periodic:Boolean = false;
    var mc:MovieClip;
    
    try {
      mc = view.mcBounds();
    } catch (e:Error) {
      return;
    }
    
    mc.globalToLocal(point);
    
    if(!startTrackingAtInView(point, view)) {
      m_trackingCallback[m_trackingCallbackSelector].call(m_trackingCallback,
        false, periodic);
      return;
    }
    if((m_actionMask & NSEvent.NSLeftMouseDownMask)
        && event.type == NSEvent.NSLeftMouseDown) {
      NSControl(controlView()).sendActionTo(action(), target());
    }

    m_trackingData = {
      location: location,
      untilMouseUp: untilMouseUp,
      action: action(),
      target: target(),
      view: view,
      lastPoint: point,
      eventMask: trackingEventMask(),
      bounds: rect.clone()
    };

    if(m_actionMask & NSEvent.NSPeriodicMask) {
      var times:Object = getPeriodicDelayInterval();
      NSEvent.startPeriodicEventsAfterDelayWithPeriod(times.delay, times.interval);
      m_trackingData.eventMask |= NSEvent.NSPeriodicMask;
      periodic = true;
    }

    m_app.callObjectSelectorWithNextEventMatchingMaskDequeue(this,
      "mouseTrackingCallback", m_trackingData.eventMask, true);
  }

  /**
   * This is the method that actually performs the mouse tracking. It is called
   * by the application every time an event is processed matching the cell's
   * {@link #trackingEventMask()}.
   */
  public function mouseTrackingCallback(event:NSEvent):Void {
    var point:NSPoint = event.mouseLocation.clone();

    //
    // optional cast -- apparently, mtasc's && returns last value
    //
    var periodic:Boolean = Boolean((event.type == NSEvent.NSPeriodic)
      && (m_actionMask & NSEvent.NSPeriodicMask));
    var dragged:Boolean = Boolean((event.type == NSEvent.NSLeftMouseDragged)
      && (m_actionMask & NSEvent.NSLeftMouseDraggedMask));
    var mc:MovieClip;
    
    try {
      mc = m_trackingData.view.mcBounds();
    } catch (e:Error) {
      return;
    }
    
    mc.globalToLocal(point);
   
    if(!m_trackingData.untilMouseUp
        && (event.view != m_trackingData.view
        || !NSRect(m_trackingData.bounds).pointInRect(point))) { //moved out of view
      stopTrackingAtInViewMouseIsUp(m_trackingData.lastPoint, point,
        controlView(), false);

      //
      // Stop sending periodic when mouse up **very impt**
      //
      if (m_actionMask & NSEvent.NSPeriodicMask) {
        NSEvent.stopPeriodicEvents();
      }
      
      //
      // Stimulate mouseUp
      //
      m_trackingCallback[m_trackingCallbackSelector].call(m_trackingCallback,
        false, periodic);

     
    } else { // still in view
      if (event.type == NSEvent.NSLeftMouseUp) { // mouse up?
        stopTrackingAtInViewMouseIsUp(m_trackingData.lastPoint, point,
          controlView(), true);
        //
        // Stop sending periodic when mouse up **very impt**
        //
        if (m_actionMask & NSEvent.NSPeriodicMask) {
          NSEvent.stopPeriodicEvents();
        }
        
        m_trackingCallback[m_trackingCallbackSelector].call(m_trackingCallback,
          true, periodic);

        setNextState();
        if(m_actionMask & NSEvent.NSLeftMouseUpMask) {
          m_trackingData.view.sendActionTo(m_trackingData.action,
            m_trackingData.target);
        }

        
      } else { // no mouse up
        if (periodic || dragged) { //! Dragged too?
          m_trackingData.view.sendActionTo(m_trackingData.action,
            m_trackingData.target);
        }

        if (continueTrackingAtInView(m_trackingData.lastPoint, point,
            controlView())) {
          m_trackingData.lastPoint = point;
//          m_trackingCallback[m_trackingCallbackSelector].call(
//            m_trackingCallback, false, periodic);

          m_app.callObjectSelectorWithNextEventMatchingMaskDequeue(this,
            "mouseTrackingCallback", m_trackingData.eventMask, true);
        } else { // don't continue...no mouse up
          if (m_actionMask & NSEvent.NSPeriodicMask) {
            NSEvent.stopPeriodicEvents();
          }
          stopTrackingAtInViewMouseIsUp(m_trackingData.lastPoint, point,
            controlView(), false);
          m_trackingCallback[m_trackingCallbackSelector].call(
            m_trackingCallback, false, periodic);

          
        }
      }
    }
  }

  /**
   * Returns an object with delay and interval properties
   */
  public function getPeriodicDelayInterval():Object {
    return {delay:.1, interval:.1};
  }

  /**
   * <p>Begins tracking mouse events within the receiver.</p>
   *
   * @param startPoint The initial location of the cursor.
   * @param controlView The <code>NSControl</code> object managing this cell.
   *
   * <p>This method returns <code>true</code> if the receiver is set to respond
   * continuously or set to respond when the mouse is dragged; otherwise,
   * <code>false</code>.</p>
   *
   * <p>
   * The NSCell implementation of {@link #trackMouseInRectOfViewUntilMouseUp()}
   * invokes this method when tracking begins. Subclasses can override this
   * method to implement special mouse-tracking behavior at the beginning of
   * mouse tracking—for example, displaying a special cursor.
   * </p>
   *
   * @see #continueTrackingAtInView()
   * @see #stopTrackingAtInViewMouseIsUp()
   */
  public function startTrackingAtInView(startPoint:NSPoint,
    controlView:NSView):Boolean {
    return true;
  }

  /**
   * <p>
   * Returns a Boolean value indicating whether mouse tracking should continue
   * in the receiving cell.
   * </p>
   *
   * @param lastPoint Contains either the initial location of the cursor when
   * 			tracking began or the previous current point.
   * @param currentPoint The current location of the cursor.
   * @param controlView The <code>NSControl</code> object managing the receiver.
   *
   * <p>
   * This method returns <code>true</code> if tracking should continue, or
   * <code>false</code> otherwise.
   * </p>
   *
   * <p>
   * This method is invoked in {@link #trackMouseInRectOfViewUntilMouseUp()}.
   * The default implementation returns <code>true</code> if the cell is set to
   * continuously send action messages to its target when the mouse button is
   * down or the mouse is being dragged. Subclasses can override this method to
   * provide more sophisticated tracking behavior.
   * </p>
   *
   * @see #startTrackingAtInView()
   * @see #stopTrackingAtInView()
   */
  public function continueTrackingAtInView(lastPoint:NSPoint, currentPoint:NSPoint,
    controlView:NSView):Boolean {
    return true;
  }

  /**
   * <p>Ends tracking mouse events within the receiver.</p>
   *
   * @param lastPoint Contains the previous position of the cursor.
   * @param stopPoint The current location of the cursor.
   * @param controlView The <code>NSControl</code> object managing the receiver.
   * @param mouseIsUp If <code>true</code>, this method was invoked because the
   * 			user released the mouse button; otherwise, if
   * 			<code>false</code>, the cursor left the designated tracking
   * 			rectangle.
   *
   * <p>This method is invoked in {@link #trackMouseInRectOfViewUntilMouseUp()}
   * when the cursor has left the bounds of the receiver or the mouse button
   * goes up. The default NSCell implementation of this method does nothing.
   * Subclasses often override this method to provide customized tracking
   * behavior. The following example increments the state of a tristate cell
   * when the mouse button is clicked:</p>
   *
   * <pre>
   * 	public function stopTrackingAtInViewMouseIsUp(lastPoint:NSPoint,
   * 			stopPoint:NSPoint, controlView:NSView, mouseIsUp:Boolean):Void {
   * 		super.stopTrackingAtInViewMouseIsUp(lastPoint, stopPoint,
   * 			controlView, mouseIsUp);
   *
   * 		if (mouseIsUp) { // increment tristate
   * 			setTriState(triState() + 1);
   * 		}
   * 	}
   * </pre>
   */
  public function stopTrackingAtInViewMouseIsUp(lastPoint:NSPoint,
      stopPoint:NSPoint, controlView:NSView, mouseIsUp:Boolean):Void {
    //
    // if mouseUp, this would have been done by control
    //
    if(!mouseIsUp) {
      setHighlighted(false);
    }
  }

  public function mouseDownFlags():Number {
    return m_mouseDownFlags;
  }

  //******************************************************
  //*            Handling keyboard alternatives
  //******************************************************

  /**
   * Implemented by subclasses to return a key equivalent to clicking the cell.
   *
   * The default implementation returns an empty string.
   */
  public function keyEquivalent():String {
    return "";
  }

  //******************************************************
  //*               Determining cell sizes
  //******************************************************

  /**
   * <p>Recalculates cell geometry.</p>
   *
   * <p>NOTE: May be useful for optimization.</p>
   */
  // TODO - (void)calcDrawInfo:(NSRect)aRect

  /**
   * <p>Returns the minimum size needed to display the receiver.</p>
   *
   * <p>Returns the size of the cell, or the size (10000, 10000) if the receiver
   * is not a text or image cell. If the cell is an image cell but no image has
   * been set, this method returns {@link NSSize#ZeroSize}.</p>
   *
   * <p>This method takes into account of the size of the image or text within a
   * certain offset determined by the border type of the cell.</p>
   *
   * @see #drawingRectForBounds()
   */
  public function cellSize():NSSize {
    var borderSize:NSSize;
    var csize:NSSize;
    if (m_bordered) {
      borderSize = NSBorderType.NSLineBorder.size;
    } else if(m_bezeled) {
      borderSize = NSBorderType.NSBezelBorder.size;;
    } else {
      borderSize = NSSize.ZeroSize;
    }
    switch(m_type.value) {
      case NSCellType.NSTextCellType.value:
        var text:NSAttributedString = attributedStringValue();
        if (text.string() == null || text.string().length == 0) {
          csize = font().getTextExtent("M");
        } else {
          csize = font().getTextExtent(text.string());
          //FIXME account for multiline wrapped text
        }
        break;
      case NSCellType.NSImageCellType.value:
        if (m_image == null) {
          csize = NSSize.ZeroSize;
        } else {
          csize = m_image.size();
        }
        break;
      case NSCellType.NSNullCellType.value:
        csize = new NSSize(10000, 10000);
        break;
    }

    csize.width += (borderSize.width * 2);
    csize.height += (borderSize.height * 2);
    return csize;
  }

  /**
   * <p>Returns the minimum size needed to display the receiver, constraining it
   * to the specified rectangle.</p>
   *
   * <p>This method takes into account of the size of the image or text within
   * a certain offset determined by the border type of the cell. If the receiver
   * is of text type, the text is resized to fit within <code>aRect</code> (as
   * much as <code>aRect</code> is within the bounds of the cell).</p>
   *
   * @see #drawingRectForBounds()
   */
  public function cellSizeForBounds(aRect:NSRect):NSSize {
    if (m_type == NSCellType.NSTextCellType) {
      // var availRect:NSRect = aRect.intersectionRect() What are cell bounds?
      //! TODO Resize text to fit into supplied rect
    }
    return cellSize();
  }

  /**
   * <p>Returns the rectangle within which the receiver draws itself where
   * <code>theRect</code> is the bounding rectangle of the receiver.</p>
   *
   * <p>Returns the rectangle in which the receiver draws itself. This rectangle
   * is slightly inset from the one in <code>theRect</code>.</p>
   *
   * @see NSControl#calcSize()
   */
  public function drawingRectForBounds(theRect:NSRect):NSRect {
  	// FIXME account for theme
    var borderSize:NSSize;
    if (m_bordered) {
      borderSize = NSBorderType.NSLineBorder.size;
    } else if(m_bezeled) {
      borderSize = NSBorderType.NSBezelBorder.size;;
    } else {
      borderSize = NSSize.ZeroSize;
    }
    return theRect.insetRect(borderSize.width, borderSize.height);
  }

  /**
   * <p>Returns the rectangle in which the receiver draws its image where
   * <code>theRect</code> is the bounding rectangle of the cell.</p>
   *
   * <p>Returns the rectangle in which the receiver draws its image. This
   * rectangle is slightly offset from the one in <code>theRect</code>.</p>
   *
   * @see #cellSizeForBounds()
   * @see #drawingRectForBounds()
   */
  public function imageRectForBounds(theRect:NSRect):NSRect {
    return drawingRectForBounds(theRect);
  }

  /**
   * <p>Returns the rectangle in which the receiver draws its text where
   * <code>theRect</code> is the bounding rectangle of the cell.</p>
   *
   * <p>If the receiver is a text-type cell, this method resizes the drawing
   * rectangle for the title (<code>theRect</code>) inward by a small offset to
   * accommodate the cell border. If the receiver is not a text-type cell, the
   * method does nothing.</p>
   *
   * @see #imageRectForBounds()
   */
  public function titleRectForBounds(theRect:NSRect):NSRect {
    if (m_type == NSCellType.NSTextCellType) {
      var frame:NSRect = drawingRectForBounds(theRect);
      if (m_bordered || m_bezeled) {
        return frame.insetRect(3,1);
      }
    } else {
      return theRect.clone();
    }
  }

  /**
   * <p>Returns the size of the receiver.</p>
   *
   * @see #setControlSize()
   */
  public function controlSize():NSControlSize {
    return m_controlSize;
  }

  /**
   * <p>Sets the size of the receiver.</p>
   *
   * <p>Changing the cell’s control size does not change the font of the cell. Use
   * the {@link org.actionstep.ASTheme} class method
   * {@link org.actionstep.ASTheme#systemFontSizeForControlSize} to obtain the
   * system font based on the new control size and set it.</p>
   *
   * @see #controlSize()
   */
  public function setControlSize(csize:NSControlSize) {
    m_controlSize = csize;
  }

  //******************************************************
  //*          Drawing and highlighting cells
  //******************************************************

  /**
   * Draws the receiver’s regular or bezeled border (if those attributes are
   * set) and then draws the interior of the cell by invoking
   * {@link #drawInteriorWithFrameInView()}.
   *
   * @see #drawInteriorWithFrameInView()
   */
  public function drawWithFrameInView(cellFrame:NSRect, inView:NSView) {
    if (cellFrame.isEmptyRect() || inView.window()==null) {
      return;
    }
    
    //
    // Set the control view
    //
    setControlView(inView);
    var x:Number = cellFrame.origin.x;
    var y:Number = cellFrame.origin.y;
    var width:Number = cellFrame.size.width;
    var height:Number = cellFrame.size.height;
    var mc:MovieClip;
    
    try {
      mc = inView.mcBounds();
    } catch (e) {
      return;
    }
    
    if(m_bordered) {
      ASDraw.drawRectWithRect(mc, cellFrame, 0x696E79);
    } else if (m_bezeled) {
      ASDraw.outlineRectWithRect(mc, cellFrame,
        [
          0xF6F8F9,
          0x696E79,
          0x696E79,
          0xF6F8F9
        ], [100, 100, 100, 100]);
    }
    drawInteriorWithFrameInView(cellFrame, inView);
  }

  /**
   * <p>Draws the “inside” of the receiver—including the image or text within the
   * receiver’s frame in <code>controlView</code> (usually the cell’s
   * {@link NSControl}) but excluding the border.</p>
   *
   * <p><code>cellFrame</code> is the frame of the <code>NSCell</code> or, in
   * some cases, a portion of it. Text-type <code>NSCell</code>s display their
   * contents in a rectangle slightly inset from <code>cellFrame</code>.
   * Image-type <code>NSCell</code>s display their contents centered within
   * <code>cellFrame</code>. If the proper attributes are set, it also displays
   * the colored rectangle to indicate first responder and highlights the cell.
   * This method is invoked from <code>NSControl</code>’s
   * {@link NSControl#drawCellInside()} to visually update what the
   * <code>NSCell</code> displays when its contents change. This drawing is
   * minimal and becomes more complex in objects such as
   * {@link org.actionstep.NSButtonCell} and
   * {@link org.actionstep.NSSliderCell}.</p>
   *
   * <p>Subclasses often override this method to provide more sophisticated
   * drawing of cell contents. Because {@link #drawWithFrameInView} invokes
   * {@link #drawInteriorWithFrameInView} after it draws the
   * <code>NSCell</code>’s border, don’t invoke {@link #drawWithFrameInView} in
   * your override implementation.</p>
   *
   * @see #isHighlighted()
   * @see #showsFirstResponder()
   */
  public function drawInteriorWithFrameInView(cellFrame:NSRect, inView:NSView) {
    if (inView.window() == null) {
      return;
    }
    cellFrame = drawingRectForBounds(cellFrame);
    if (m_bordered || m_bezeled) { // inset a bit more
      cellFrame = cellFrame.insetRect(3,1);
    }
    if(m_type == NSCellType.NSTextCellType) {
      //! draw attributedStringValue();
    } else if (m_type == NSCellType.NSImageCellType) {
      var size:NSSize = m_image.size();
      var position:NSPoint = new NSPoint(cellFrame.midX() - (size.width/2), cellFrame.midY() - (size.height/2));
      if (position.x < 0) {
        position.x = 0;
      }
      if (position.y < 0) {
        position.y = 0;
      }
      
      var mc:MovieClip;
    
      try {
        mc = inView.mcBounds();
      } catch (e) {
        return;
      }
      m_image.lockFocus(mc);
      m_image.drawAtPoint(position);
      m_image.unlockFocus();
    }
  }

  /**
   * <p>Sets the receiver’s control view.</p>
   *
   * <p>The control view represents the control currently being rendered by the
   * cell.</p>
   *
   * @see #controlView()
   */
  public function setControlView(view:NSView) {
    m_controlView = view;
  }

  /**
   * Implemented by subclasses to return the <code>NSView</code> last drawn in
   * (normally an {@link NSControl}).
   */
  public function controlView():NSView {
    return m_controlView;
  }

  /**
   * If the receiver’s highlight status is different from <code>flag</code>,
   * sets that status to <code>flag</code> and, if <code>flag</code> is
   * <code>true</code>, highlights the rectangle <code>cellFrame</code> in the
   * {@link NSControl} (<code>controlView</code>).
   *
   * @see #isHighlighted()
   * @see #drawWithFrameInView()
   */
  public function highlightWithFrameInView(flag:Boolean, cellFrame:NSRect, controlView:NSView) {
    if (isHighlighted() != flag) {
      setHighlighted(flag);
    }
    drawWithFrameInView(cellFrame, controlView);
  }

  /**
   * <p>Sets whether the receiver has a highlighted appearance, depending on the
   * Boolean value <code>flag</code>.</p>
   */
  public function setHighlighted(value:Boolean) {
    m_highlighted = value;
  }

  /**
   * Returns whether the receiver is highlighted.
   */
  public function isHighlighted():Boolean {
    return m_highlighted;
  }

  //******************************************************
  //*           Editing and selecting cell text
  //******************************************************

  /**
   * Begins editing of the cell’s text using the field editor
   * <code>editor</code>.
   *
   * This method is usually invoked in response to a mouse-down event. theEvent
   * is the <code>NSLeftMouseDown</code> event. <code>anObject</code> is made
   * the delegate of <code>editor</code> and so will receive various delegation
   * and notification messages.
   *
   * If the cell isn’t a text-type <code>NSCell</code>, no editing is performed.
   *
   * This is ActionStep's version of
   * <code>#editWithFrameInViewEditorDelegateEvent</code>.
   */
  public function editWithEditorDelegateEvent(editor:ASFieldEditor,
      anObject:Object, event:NSEvent):Void {
    //
    // Don't do anything on non text type.
    //
    if (type() != NSCellType.NSTextCellType || editor == null) {
      return;
    }

    editor.startInstanceEdit(this, anObject, textField());
  }

  /**
   * Uses the field editor <code>editor</code> to select text in a range marked
   * by <code>start</code> and <code>length</code>, which will be highlighted
   * and selected as though the user had dragged the cursor over it.
   *
   * This is ActionStep's version of
   * <code>#selectWithFrameInViewEditorDelegateStartLength</code>.
   */
  public function selectWithEditorDelegateStartLength(editor:ASFieldEditor,
      anObject:Object, start:Number, length:Number):Void {
    //
    // Don't do anything on non text type.
    //
    if (type() != NSCellType.NSTextCellType || editor == null) {
      return;
    }

    editor.startInstanceEdit(this, anObject, textField());
    if (start == null) {
      editor.select();
    } else {
      editor.setSelectedRange(new NSRange(start, length));
    }
  }

  /**
   * Ends any editing of text, using the field editor <code>editor</code>.
   */
  public function endEditing(editor:ASFieldEditor):Void {
    if (editor.cell() != this) {
      return;
    }

    editor.endInstanceEdit();
  }

  /**
   * Sets whether the cell’s <code>NSControl</code> object sends its action
   * message whenever the user finishes editing the cell’s text.
   *
   * If <code>flag</code> is <code>true</code>, the cell’s
   * <code>NSControl</code> object sends its action message when the user does
   * one of the following:
   *   - Presses the Return key
   *   - Presses the Tab key to move out of the field
   *   - Clicks another text field
   *
   * If <code>flag</code> is <code>false</code>, the cell’s
   * <code>NSControl</code> object sends its action message only when the user
   * presses the Return key.
   */
  public function setSendsActionOnEndEditing(value:Boolean) {
    m_sendsActionOnEndEditing = value;
  }

  /**
   * Returns whether the cell’s <code>NSControl</code> object sends its action
   * message whenever the user finishes editing the cell’s text.
   *
   * If it returns <code>true</code>, the cell’s <code>NSControl</code> object
   * sends its action message when the user does one of the following:
   *   - Presses the Return key
   *   - Presses the Tab key to move out of the field
   *   - Clicks another text field
   *
   * If it returns <code>false</code>, the cell’s <code>NSControl</code> object
   * sends its action message only when the user presses the Return key.
   */
  public function sendsActionOnEndEditing():Boolean {
    return m_sendsActionOnEndEditing;
  }

  //******************************************************
  //*          Text editing related methods
  //******************************************************

  /**
   * To be overridden in subclasses that support text editing.
   */
  private function textField():TextField {
    var e:NSException = NSException.exceptionWithNameReasonUserInfo(
      "NSAbstractMethodException",
      "textField() should be implemented in subclasses.",
      null);
    trace(e);
    throw e;
    return null;
  }

  //******************************************************
  //*             Describing the object
  //******************************************************

  /**
   * Returns a string representation of the cell.
   */
  public function description():String {
    return "NSCell()";
  }

  //******************************************************
  //*           Helper methods for truncation
  //******************************************************

  /**
   * Returns <code>str</code> truncated to fit within <code>width</code>
   * with a leading ellipsis.
   */
  private function truncateTextWithMiddleEllipsis(str:String, width:Number)
      :String {
    if (m_font.getTextExtent(str).width < width) {
      return str;
    }
    var range:NSRange = findMiddleEllipsisRange(str, width);
    return str.substring(0, range.location) + "..." +
      str.substr(range.location + range.length);
  }

  /**
   * Returns <code>str</code> truncated to fit within <code>width</code>
   * with a leading ellipsis.
   */
  private function truncateTextWithTrailingEllipsis(str:String, width:Number)
      :String {
    if (m_font.getTextExtent(str).width < width) {
      return str;
    }
    var ellipsisPos:Number = findTrailingEllipsisPosition(str, width);
    return str.substring(0, ellipsisPos) + "...";
  }

  /**
   * Returns <code>str</code> truncated to fit within <code>width</code>
   * with a leading ellipsis.
   */
  private function truncateTextWithLeadingEllipsis(str:String, width:Number)
      :String {
    if (m_font.getTextExtent(str).width < width) {
      return str;
    }
    var ellipsisPos:Number = findLeadingEllipsisPosition(str, width);
    return "..." + str.substr(ellipsisPos);
  }

  /**
   * Returns a number representing the index from which all characters in
   * <code>str</code> will be replaced with an ellipsis so that the string
   * will fit within <code>width</code> for the cell's current font.
   */
  private function findTrailingEllipsisPosition(str:String, width:Number):Number {
    if (m_font.getTextExtent("...").width > width) {
      return 0;
    }

    var midPoint:Number = Math.round(str.length / 2);
    var range:Number = midPoint;
    var lengthToChar:Number = m_font.getTextExtent(str.substring(0, midPoint)
      + "...").width;
    var eleSet:NSArray = NSArray.array();

    while (true) {
      range = Math.round(range / 2);

      if (width > lengthToChar)  {
        midPoint = midPoint + range;
      }
      else if (width < lengthToChar) {
        midPoint = midPoint - range;
      } else {
        return midPoint;
      }

      lengthToChar = m_font.getTextExtent(str.substring(0, midPoint) + "...").width;

      if ((width - lengthToChar <= 2 && width - lengthToChar >= 0)
          || eleSet.containsObject(midPoint)) {
        return midPoint;
      }

      if (lengthToChar < width) {
        eleSet.addObject(midPoint);
      }
    }
  }

  /**
   * Returns a number representing the ending index that will replace the
   * characters in <code>str</code> from position 0 to the ending index with
   * an ellipsis so that the string will fit within <code>width</code> with
   * the current font.
   */
  private function findLeadingEllipsisPosition(str:String, width:Number):Number {
    if (m_font.getTextExtent("...").width > width) {
      return str.length - 1;
    }
    var midPoint:Number = Math.round(str.length / 2);
    var range:Number = midPoint;
    var lengthToChar:Number = m_font.getTextExtent("..."
      + str.substr(midPoint)).width;
    var eleSet:NSArray = NSArray.array();

    while (true) {
      range = Math.round(range / 2);

      if (width > lengthToChar) {
        midPoint = midPoint - range;
      }
      else if (width < lengthToChar) {
        midPoint = midPoint + range;
      } else {
        return midPoint;
      }

      lengthToChar = m_font.getTextExtent("..." + str.substr(midPoint)).width;

      if ((width - lengthToChar <= 2 && width - lengthToChar >= 0) ||
          eleSet.containsObject(midPoint)) {
        return midPoint;
      }

      if (lengthToChar < width) {
         eleSet.addObject(midPoint);
      }
    }
  }

  /**
   * Returns a range representing the characters in <code>str</code> that
   * will be replaced by an ellipsis when constrained to a width of
   * <code>width</code> using the cell's current font.
   */
  private function findMiddleEllipsisRange(str:String, width:Number):NSRange {
    if (m_font.getTextExtent("...").width > width) {
      return new NSRange(0, str.length);
    }
    var midPoint:Number = Math.round(str.length / 2);
    var start:Number = midPoint;
    var end:Number = midPoint;

    while (true) {
      start--;

      var lengthToChar:Number = m_font.getTextExtent(str.substring(0, start)
        + "..." + str.substr(end)).width;

      if (lengthToChar < width) {
        return new NSRange(start, end - start);
      }

      end++;

      lengthToChar = m_font.getTextExtent(str.substring(0, start)
        + "..." + str.substr(end)).width;

      if (lengthToChar < width) {
        return new NSRange(start, end - start);
      }
    }
  }

}
