/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASDraw;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSScrollerPart;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSColor;
import org.actionstep.NSEvent;
import org.actionstep.NSFont;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSRange;
import org.actionstep.NSRect;
import org.actionstep.NSScroller;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;

/**
 * A control used for editing multiline text.
 *
 * To see an example of this class in action, please see the
 * <code>org.actionstep.test.ASTestTextEditor</code> class.
 *
 * Notes:
 *  - This class does not currently dispatch methods to the delegate
 *
 * @author Richard Kilmer
 */
class org.actionstep.ASTextEditor extends NSView {

  //******************************************************
  //*                 Member variables
  //******************************************************

  private var m_textField:TextField;
  private var m_textFormat:TextFormat;
  private var m_font:NSFont;
  private var m_textColor:NSColor;
  private var m_alignment:NSTextAlignment;

  private var m_internalString:String;
  private var m_internalStringIsHtml:Boolean;

  private var m_backgroundColor:NSColor;
  private var m_drawsBackground:Boolean;
  private var m_editable:Boolean;
  private var m_selectable:Boolean;
  private var m_selectedRange:NSRange;
  private var m_maxSize:NSSize;
  private var m_minSize:NSSize;
  private var m_delegate:Object;
  private var m_notificationCenter:NSNotificationCenter;

  private var m_horizontalScroller:NSScroller;
  private var m_verticalScroller:NSScroller;
  private var m_hasHorizontalScroller:Boolean;
  private var m_hasVerticalScroller:Boolean;
  private var m_autohidesScrollers:Boolean;

  private var m_borderType:NSBorderType;

  private var m_horizontalLineScroll:Number;
  private var m_verticalLineScroll:Number;
  private var m_horizontalPageScroll:Number;
  private var m_verticalPageScroll:Number;

  private var m_knobMoved:Boolean;
  private var m_caretPosition:Number;

  //******************************************************
  //*                 Construction
  //******************************************************

  public function ASTextEditor() {
    m_caretPosition = 0;
    m_textField = null;
    m_textFormat = null;
    m_borderType = NSBorderType.NSNoBorder;
    m_textColor = ASTheme.current().systemFontColor();
    m_font = ASTheme.current().systemFontOfSize(0);
    m_alignment = NSTextAlignment.NSLeftTextAlignment;
    m_textFormat = m_font.textFormatWithAlignment(m_alignment);
    m_textFormat.color = m_textColor.value;
    m_internalString = "";
    m_internalStringIsHtml = false;
    m_drawsBackground = true;
    m_editable = true;
    m_selectable = true;
    m_maxSize = null;
    m_minSize = null;
    m_hasHorizontalScroller = false;
    m_hasVerticalScroller = false;
    m_autohidesScrollers = false;
    m_autohidesScrollers = false;
    m_horizontalLineScroll = 10;
    m_verticalLineScroll = 1;
    m_horizontalPageScroll = 100;
    m_verticalPageScroll = 5;
    m_backgroundColor = ASColors.whiteColor();
  }

  public function initWithFrame(frame:NSRect):ASTextEditor {
    super.initWithFrame(frame);
    m_notificationCenter = NSNotificationCenter.defaultCenter();
    m_minSize = NSSize.ZeroSize;
    return this;
  }

  private function createMovieClips():Boolean {
    if (!super.createMovieClips()) {
    	return false;
    }
    
    textField();
    
    return true;
  }
  
  /**
   * Removes all movieclips associated with the view.
   *
   * This method should rarely, if ever, be overridden.
   */
  public function removeMovieClips():Void {
    super.removeMovieClips();
    
    m_textField.removeTextField();
    m_textField = null;
  }

  //******************************************************
  //*              Getting the characters
  //******************************************************

  public function string():String {
    return m_internalString;
  }

  //******************************************************
  //*            Setting graphics attributes
  //******************************************************

  public function setBackgroundColor(value:NSColor) {
    if (m_backgroundColor != value) {
      m_backgroundColor = value;
      setNeedsDisplay(true);
    }
  }

  public function backgroundColor():NSColor {
    return m_backgroundColor;
  }

  public function setDrawsBackground(value:Boolean) {
    if (m_drawsBackground != value) {
      m_drawsBackground = value;
      setNeedsDisplay(true);
    }
  }

  public function drawsBackground():Boolean {
    return m_drawsBackground;
  }

  //******************************************************
  //*           Setting behavioral attributes
  //******************************************************

  public function setEditable(value:Boolean) {
    m_editable = value;
    if (m_textField != null && m_textField._parent != undefined) {
      m_textField.type = m_editable ? "input" : "dynamic";
    }
  }

  public function isEditable():Boolean {
    return m_editable;
  }

  public function setSelectable(value:Boolean) {
    m_selectable = value;
    if (!m_selectable) {
      setEditable(false);
    }
    if (m_textField != null && m_textField._parent != undefined) {
      m_textField.selectable = m_selectable;
    }
  }

  public function isSelectable():Boolean {
    return m_selectable || m_editable;
  }

  //******************************************************
  //*              Changing the selection
  //******************************************************

  public function setSelectedRange(range:NSRange) {
    if (m_textField != null && m_textField._parent != undefined) {
      Selection.setFocus(eval(m_textField._target));
      Selection.setSelection(range.location, range.location + range.length);
    }
    m_selectedRange = range;
  }

  public function selectedRange():NSRange {
    if (m_textField != null && m_textField._parent != undefined && Selection.getFocus()==m_textField._target) {
      m_selectedRange = new NSRange(Selection.getBeginIndex(), Selection.getEndIndex() - Selection.getBeginIndex());
    }
    return m_selectedRange;
  }

  //******************************************************
  //*                 Replacing text
  //******************************************************

  public function replaceCharactersInRangeWithString(range:NSRange, string:String) {
    if (m_textField != null && m_textField._parent != undefined) {
      m_textField.replaceText(range.location, range.location + range.length, string);
    } else {
      //! FIXME
    }
  }

  public function setString(string:String) {
  	m_internalStringIsHtml = false;
    m_internalString = string;
    m_caretPosition = 0;
    if (m_textField != null && m_textField._parent != undefined) {
      m_textField.text = string;
      m_textField.setTextFormat(m_textFormat);
      m_textField.setNewTextFormat(m_textFormat);
      m_textField.hscroll = 0;
      m_textField.background = false;
      m_textField.scroll = 1;
    }
    reflectScrolledTextField();
  }

  public function setHtmlString(string:String) {
  	if (!m_internalStringIsHtml) {
  		m_internalStringIsHtml = m_textField.html = true;
  	}
  	
    m_internalString = string;
    m_caretPosition = 0;
    if (m_textField != null && m_textField._parent != undefined) {
      m_textField.htmlText = string;
      m_textField.hscroll = 0;
      m_textField.background = false;
      m_textField.scroll = 1;
    }
    reflectScrolledTextField();
  }

  //******************************************************
  //*           Action methods for editing
  //******************************************************

  public function selectAll(sender:Object) {
    setSelectedRange(new NSRange(0, m_internalString.length));
  }

  public function copy(sender:Object) {
    //! TODO Integrate NSPasteBoard
  }

  public function cut(sender:Object) {
    copy(sender);
    clear(sender);
  }

  public function paste(sender:Object) {
    //! TODO Integrate NSPasteBoard
  }

  public function copyFont(sender:Object) {
    //! TODO Integrate NSPasteBoard
  }

  public function pasteFont(sender:Object) {
    //! TODO Integrate NSPasteBoard
  }

  public function copyRuler(sender:Object) {
    //! TODO Integrate NSPasteBoard
  }

  public function pasteRuler(sender:Object) {
    //! TODO Integrate NSPasteBoard
  }

 /**
  * Remove all text from the text editor but do not place it on the clipboard
  *
  * NOTE: Changed from the Cocoa delete method because delete is a keyword in
  * ActionScript
  */
  public function clear(sender:Object) {
    if (m_textField != null && m_textField._parent != undefined) {// && Selection.getFocus()==m_textField._target) {
      m_textField.text = "";
    }
    m_internalString = "";
  }

  //******************************************************
  //*              Changing the font
  //******************************************************

  public function changeFont(sender:Object) {
    //! FIXME What to do here?
  }

  public function setFont(font:NSFont) {
    m_font = font;
    m_textFormat.font = m_font.fontName();
    m_textFormat.size = m_font.pointSize();
    m_textField.embedFonts = m_font.isEmbedded();
    m_textField.setTextFormat(m_textFormat);
    m_textField.setNewTextFormat(m_textFormat);
  }

  public function font():NSFont {
    return m_font;
  }

  public function setFontRange(font:NSFont, range:NSRange) {
    if (m_textField != null && m_textField._parent != undefined) {
      var format:TextFormat = m_textField.getTextFormat(range.location, range.location + range.length);
      format.font = font.fontName();
      format.size = font.pointSize();
      m_textField.setTextFormat(m_textFormat, range.location, range.location + range.length);
    }
  }

  //******************************************************
  //*              Setting text alignment
  //******************************************************

  public function setAlignment(value:NSTextAlignment) {
    m_alignment = value;
    __setAlignment(value, 0, m_internalString.length);
  }

  public function alignCenter(sender:Object) {
    __setAlignment(NSTextAlignment.NSCenterTextAlignment, 0, m_internalString.length);
  }

  public function alignLeft(sender:Object) {
    __setAlignment(NSTextAlignment.NSLeftTextAlignment, 0, m_internalString.length);
  }

  public function alignRight(sender:Object) {
    __setAlignment(NSTextAlignment.NSRightTextAlignment, 0, m_internalString.length);
  }

  public function alignment():NSTextAlignment {
    return m_alignment;
  }

  private function __setAlignment(value:NSTextAlignment, begin:Number, end:Number) {
    var format:TextFormat = new TextFormat();
    format.align = value.string;
    m_textField.setTextFormat(format, begin, end);
  }

  //******************************************************
  //*              Setting text color
  //******************************************************

  public function setTextColor(color:NSColor) {
    m_textFormat.color = color.value;
    if (m_textField != null && m_textField._parent != undefined) {
      m_textField.setTextFormat(m_textFormat);
      m_textField.setNewTextFormat(m_textFormat);
    }
  }

  public function setTextColorRange(color:NSColor, range:NSRange) {
    if (m_textField != null && m_textField._parent != undefined) {
      var format:TextFormat = m_textField.getTextFormat(range.location, range.location + range.length);
      format.color = color.value;
      m_textField.setTextFormat(m_textFormat, range.location, range.location + range.length);
    }
  }

  public function textColor():NSColor {
    return new NSColor(m_textFormat.color);
  }

  //******************************************************
  //*      Setting superscripting and subscripting
  //******************************************************

  public function superscript(sender:Object) {
    //! What to do here?
  }

  public function subscript(sender:Object) {
    //! What to do here?
  }

  public function unscript(sender:Object) {
    //! What to do here?
  }

  //******************************************************
  //*                Underlining text
  //******************************************************

  public function underline(sender:Object) {
    m_textFormat.underline = true;
    if (m_textField != null && m_textField._parent != undefined) {
      m_textField.setNewTextFormat(m_textFormat);
    }
  }

  //******************************************************
  //*               Constraining size
  //******************************************************

  public function setMaxSize(size:NSSize) {
    m_maxSize = size;
    setNeedsDisplay(true);
  }

  public function maxSize():NSSize {
    return m_maxSize;
  }

  public function setMinSize(size:NSSize) {
    m_minSize = size;
    setNeedsDisplay(true);
  }

  public function minSize():NSSize {
    return m_minSize;
  }

  public function sizeToFit() {
    //! Leave us at our current size
  }

  //******************************************************
  //*                    Scrolling
  //******************************************************

  public function scrollRangeToVisible(range:NSRange) {
    //! What to do here?
  }

  //******************************************************
  //*                Managing scrollers
  //******************************************************

  public function tile() {
    var contentRect:NSRect;
    var vScrollerRect:NSRect;
    var hScrollerRect:NSRect;
    var scrollerWidth:Number = NSScroller.scrollerWidth();
    contentRect = m_bounds.insetRect(m_borderType.size.width, m_borderType.size.height);
    if (m_autohidesScrollers) {
      if (m_hasVerticalScroller) {
        if (m_verticalScroller.isEnabled()) {
          m_verticalScroller.setHidden(false);
        } else {
          m_verticalScroller.setHidden(true);
        }
      }
      if (m_hasHorizontalScroller) {
        if (m_horizontalScroller.isEnabled()) {
          m_horizontalScroller.setHidden(false);
        } else {
          m_horizontalScroller.setHidden(true);
        }
      }
    }
    if (m_hasVerticalScroller && !m_verticalScroller.isHidden()) {
      if (m_hasHorizontalScroller && !m_horizontalScroller.isHidden()) {
        vScrollerRect = new NSRect(contentRect.maxX() - scrollerWidth, contentRect.minY(), scrollerWidth, contentRect.size.height - scrollerWidth);
        hScrollerRect = new NSRect(contentRect.minX(), contentRect.maxY() - scrollerWidth, contentRect.size.width - scrollerWidth, scrollerWidth);
        m_verticalScroller.setFrame(vScrollerRect);
        m_horizontalScroller.setFrame(hScrollerRect);
      } else {
        vScrollerRect = new NSRect(contentRect.maxX() - scrollerWidth, contentRect.minY(), scrollerWidth, contentRect.size.height);
        m_verticalScroller.setFrame(vScrollerRect);
      }
    } else if (m_hasHorizontalScroller && !m_horizontalScroller.isHidden()) {
      hScrollerRect = new NSRect(contentRect.minX(), contentRect.maxY() - scrollerWidth, contentRect.size.width, scrollerWidth);
      m_horizontalScroller.setFrame(hScrollerRect);
    }
    if (m_hasVerticalScroller && !m_verticalScroller.isHidden()) {
      contentRect.size.width  -= (vScrollerRect.size.width);
    }
    if (m_hasHorizontalScroller && !m_horizontalScroller.isHidden()) {
      contentRect.size.height -= (hScrollerRect.size.height);
    }
    m_textField._width = contentRect.size.width;
    m_textField._height = contentRect.size.height;
    setNeedsDisplay(true);
  }

  public function setHorizontalScroller(scroller:NSScroller) {
    if (m_horizontalScroller != null) {
      m_horizontalScroller.removeFromSuperview();
    }
    m_horizontalScroller = scroller;
    if (m_horizontalScroller != null) {
      m_horizontalScroller.setAutoresizingMask(NSView.WidthSizable);
      m_horizontalScroller.setTarget(this);
      m_horizontalScroller.setAction("scrollAction");
    }
  }

  public function horizontalScroller():NSScroller {
    return m_horizontalScroller;
  }

  public function setHasHorizontalScroller(value:Boolean) {
    if (m_hasHorizontalScroller == value) {
      return;
    }
    m_hasHorizontalScroller = value;
    if (m_hasHorizontalScroller) {
      if (m_horizontalScroller == null) {
        setHorizontalScroller((new NSScroller()).init());
      }
      addSubview(m_horizontalScroller);
    } else {
      m_horizontalScroller.removeFromSuperview();
    }
    tile();
  }

  public function hasHorizontalScroller():Boolean {
    return m_hasHorizontalScroller;
  }

  public function setVerticalScroller(scroller:NSScroller) {
    if (m_verticalScroller != null) {
      m_verticalScroller.removeFromSuperview();
    }
    m_verticalScroller = scroller;
    if (m_verticalScroller != null) {
      m_verticalScroller.setAutoresizingMask(NSView.WidthSizable);
      m_verticalScroller.setTarget(this);
      m_verticalScroller.setAction("scrollAction");
    }
  }

  public function verticalScroller():NSScroller {
    return m_verticalScroller;
  }

  public function setHasVerticalScroller(value:Boolean) {
    if (m_hasVerticalScroller == value) {
      return;
    }
    m_hasVerticalScroller = value;
    if (m_hasVerticalScroller) {
      if (m_verticalScroller == null) {
        setVerticalScroller((new NSScroller()).init());
      }
      addSubview(m_verticalScroller);
    } else {
      m_verticalScroller.removeFromSuperview();
    }
    tile();
  }

  public function hasVerticalScroller():Boolean {
    return m_hasVerticalScroller;
  }

  public function setAutohidesScrollers(value:Boolean) {
    if (m_autohidesScrollers == value) {
      return;
    }
    m_autohidesScrollers = value;
    tile();
  }

  public function autohidesScrollers():Boolean {
    return m_autohidesScrollers;
  }


  /**
   * Callback from NSScroller in target/action
   */
  public function scrollAction(scroller:NSScroller) {
    var floatValue:Number = scroller.floatValue();
    var hitPart:NSScrollerPart = scroller.hitPart();
    var amount:Number = 0;

    if (scroller != m_verticalScroller && scroller != m_horizontalScroller) {
      return; //Unknown scroller
    }

    m_knobMoved = false;
    switch(scroller.hitPart()) {
      case NSScrollerPart.NSScrollerKnob:
      case NSScrollerPart.NSScrollerKnobSlot:
        m_knobMoved = true;
        break;
      case NSScrollerPart.NSScrollerIncrementPage:
        if (scroller == m_horizontalScroller) {
          amount = m_horizontalPageScroll;
        } else {
          amount = m_verticalPageScroll;
        }
        break;
      case NSScrollerPart.NSScrollerIncrementLine:
        if (scroller == m_horizontalScroller) {
          amount = m_horizontalLineScroll;
        } else {
          amount = m_verticalLineScroll;
        }
        break;
      case NSScrollerPart.NSScrollerDecrementPage:
        if (scroller == m_horizontalScroller) {
          amount = -m_horizontalPageScroll;
        } else {
          amount = -m_verticalPageScroll;
        }
        break;
      case NSScrollerPart.NSScrollerDecrementLine:
        if (scroller == m_horizontalScroller) {
          amount = -m_horizontalLineScroll;
        } else {
          amount = -m_verticalLineScroll;
        }
        break;
      default:
        return;
    }
    if (!m_knobMoved) {
      if (scroller == m_horizontalScroller) {
        m_textField.hscroll += amount;
        m_textField.background = false;
      } else {
        m_textField.scroll += amount;
      }
    } else {
      if (scroller == m_horizontalScroller) {
        m_textField.hscroll = floatValue * m_textField.maxhscroll;
        m_textField.background = false;
      } else {
        m_textField.scroll = floatValue * m_textField.maxscroll;
      }
    }
  }

  //******************************************************
  //*           Updating display after scrolling
  //******************************************************

  public function reflectScrolledTextField() {
    if (m_textField == null || m_textField._parent == undefined) {
      return;
    }
    var textWidth:Number = m_textField.textWidth;
    var textHeight:Number = m_textField.textHeight;
    var hScroll:Number = m_textField.hscroll;
    var hScrollMax:Number = m_textField.maxhscroll;
    var vScroll:Number = m_textField.scroll;
    var vScrollMax:Number = m_textField.maxscroll;
    var height:Number = m_textField._height;
    var width:Number = m_textField._width;

    var floatValue:Number = 0;
    var knobProportion:Number = 0;

    var needToTile:Boolean = false;

    if (m_hasVerticalScroller) {
      if (textHeight <= height) {
        if (m_verticalScroller.isEnabled()) {
          m_verticalScroller.setEnabled(false);
          needToTile = true;
        }
        m_textField.scroll = 1;
      } else {
        if (!m_verticalScroller.isEnabled()) {
          m_verticalScroller.setEnabled(true);
          needToTile = true;
        }
        knobProportion = height/textHeight;
        if (vScroll == 1) {
          floatValue = 0;
        } else {
          floatValue = vScroll/vScrollMax;
        }
        m_verticalScroller.setFloatValueKnobProportion(floatValue, knobProportion);
        m_verticalScroller.setNeedsDisplay(true);
      }
    }
    if (m_hasHorizontalScroller) {
      if (textWidth <= width) {
        if (m_horizontalScroller.isEnabled()) {
          m_horizontalScroller.setEnabled(false);
          needToTile = true;
        }
      } else {
        if (!m_horizontalScroller.isEnabled()) {
          m_horizontalScroller.setEnabled(true);
          needToTile = true;
        }
        knobProportion = width/textWidth;
        floatValue = hScroll/hScrollMax;
        m_horizontalScroller.setFloatValueKnobProportion(floatValue, knobProportion);
        m_horizontalScroller.setNeedsDisplay(true);
      }
    }
    if (needToTile) {
      tile();
    }
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

    mapDelegateNotification("ViewDidChangeSelection");
    mapDelegateNotification("ViewWillChangeNotifyingTextView");
  }

  private function mapDelegateNotification(name:String) {
    if(typeof(m_delegate["text"+name]) == "function") {
      m_notificationCenter.addObserverSelectorNameObject(m_delegate,
        "text"+name, ASUtils.intern("NSText"+name+"Notification"), this);
    }
  }

  private function textField():TextField {
    if (m_textField == null || m_textField._parent == null) {
      //
      // Build the text format and textfield
      //
      m_textField = createBoundsTextField();
      m_textField.view = this;
      m_textField.type = "dynamic";
      m_textField.selectable = false;
      m_textField.tabEnabled = false;
      m_textField.embedFonts = m_font.isEmbedded();
      m_textField.antiAliasType = "advanced";
      m_textField.gridFitType = "pixel"; // TODO maybe make this none
      m_textField.multiline = true;
      m_textField.wordWrap = !m_hasHorizontalScroller;
      m_textField.html = m_internalStringIsHtml;
      if (m_internalStringIsHtml) {
      	m_textField.setTextFormat(m_textFormat);
        m_textField.setNewTextFormat(m_textFormat);
        m_textField.htmlText = m_internalString;
      } else {
        m_textField.text = m_internalString;
        m_textField.setTextFormat(m_textFormat);
        m_textField.setNewTextFormat(m_textFormat);
      }
      
      m_textField.hscroll = 0;
      m_textField.background = false;
      m_textField.scroll = 1;

      m_textField.addListener(this);
      var func:Function = function() {
        arguments.callee.self.onKillFocus();
      };
      func.self = this;
      m_textField.onKillFocus = func;
      func = function() {
        arguments.callee.self.onSetFocus();
      };
      func.self = this;
      m_textField.onSetFocus = func;
      reflectScrolledTextField();
      tile();
    }
    
    return m_textField;
  }

  //******************************************************
  //*              TextField listener methods
  //******************************************************

  private function onChanged(tf:TextField) {
  	if (m_internalStringIsHtml && m_internalString != tf.htmlText) {
  	  m_internalString = tf.htmlText;
  	  reflectScrolledTextField();	
      m_notificationCenter.postNotificationWithNameObject(
        NSTextDidChangeNotification, this);
  	}
  	else if (!m_internalStringIsHtml && m_internalString != tf.text) {
      m_internalString = tf.text;
      reflectScrolledTextField();
      m_notificationCenter.postNotificationWithNameObject(
        NSTextDidChangeNotification, this);
    }
  }

  private function onScroller(tf:TextField) {
    reflectScrolledTextField();
  }

  private function onSetFocus() {
    m_notificationCenter.postNotificationWithNameObject(
      NSTextDidBeginEditingNotification, this);
  }

  private function onKillFocus() {
  }

  //******************************************************
  //*                Responder chain
  //******************************************************

  public function resignFirstResponder():Boolean {
    m_textField.type = "dynamic";
    m_textField.selectable = false;
    m_textField.html = true;
    m_caretPosition = Selection.getCaretIndex();
    var ret:Boolean = super.resignFirstResponder();
    m_notificationCenter.postNotificationWithNameObject(
      NSTextDidEndEditingNotification, this);
    return ret;
  }

  public function acceptsFirstMouse(event:NSEvent):Boolean {
    return isEditable();
  }

  public function acceptsFirstResponder():Boolean {
    return isSelectable();
  }

  public function becomeFirstResponder():Boolean {
  	var scroll:Number = m_textField.scroll;
    m_textField.type = m_editable ? "input" : "dynamic";
    m_textField.selectable = m_selectable;
    Selection.setFocus(String(m_textField));
    Selection.setSelection(m_caretPosition,m_caretPosition);
    m_textField.scroll = scroll;
    return true;
  }

  //******************************************************
  //*               Responding to events
  //******************************************************

  public function mouseDown(event:NSEvent) {
    if (!isSelectable()) {
      super.mouseDown(event);
      return;
    }
    m_window.makeFirstResponder(this);
  }

  //******************************************************
  //*                Drawing the view
  //******************************************************

  public function drawRect(rect:NSRect) {
    m_mcBounds.clear();
    if (m_drawsBackground) {
      ASTheme.current().drawTextEditorWithRectInView(rect, this);
    }
    var tf:TextField = textField();
    if (m_internalStringIsHtml && tf.htmlText != m_internalString) {
      tf.htmlText = m_internalString;
    }
    else if (!m_internalStringIsHtml && tf.text != m_internalString) {
      tf.text = m_internalString;
      tf.setTextFormat(m_textFormat);
    }

    switch(m_borderType) {
      case NSBorderType.NSNoBorder:
        break;
      case NSBorderType.NSLineBorder:
        ASDraw.drawRectWithRect(m_mcBounds, rect, 0x000000);
        break;
      case NSBorderType.NSBezelBorder:
        ASDraw.drawRectWithRect(m_mcBounds, rect, 0x000000);
        break;
      case NSBorderType.NSGrooveBorder:
        ASDraw.drawRectWithRect(m_mcBounds, rect, 0x000000);
        break;
    }
  }

  //******************************************************
  //*             Frame setting overrides
  //******************************************************

  public function setFrame(aRect:NSRect):Void {
    super.setFrame(aRect);
    tile();
    reflectScrolledTextField();
  }

  public function setFrameSize(aSize:NSSize):Void {
    super.setFrameSize(aSize);
    tile();
    reflectScrolledTextField();
  }

  //******************************************************
  //*              NSResponder overrides
  //******************************************************

  function moveToBeginningOfDocument(sender:Object):Void {
    m_textField.scroll = 0;
    reflectScrolledTextField();
  }

  public function moveToEndOfDocument(sender:Object):Void {
    m_textField.scroll = m_textField.maxscroll;
    reflectScrolledTextField();
  }

  function pageDown(sender:Object):Void {
    m_textField.scroll += m_verticalPageScroll;
    reflectScrolledTextField();
  }

  function pageUp(sender:Object):Void {
    m_textField.scroll -= m_verticalPageScroll;
    reflectScrolledTextField();
  }

  //******************************************************
  //*             MovieClip (ActionStep-only)
  //******************************************************
  
  private function requiresMask():Boolean {
    return false;
  }

  //******************************************************
  //*                 Notifications
  //******************************************************

  /**
   * Dispatched when the text in the editor begins editing.
   */
  public static var NSTextDidBeginEditingNotification:Number
    = ASUtils.intern("NSTextDidBeginEditingNotification");

  /**
   * Dispatched when the text in the ditor ends editing.
   */
  public static var NSTextDidEndEditingNotification:Number
    = ASUtils.intern("NSTextDidEndEditingNotification");

  public static var NSTextDidChangeNotification:Number
    = ASUtils.intern("NSTextDidChangeNotification");

  public static var NSTextViewDidChangeSelectionNotification:Number
    = ASUtils.intern("NSTextViewDidChangeSelectionNotification");

  public static var NSTextViewWillChangeNotifyingTextViewNotification:Number
    = ASUtils.intern("NSTextViewWillChangeNotifyingTextViewNotification");
}