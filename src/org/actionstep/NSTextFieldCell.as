/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.ASFieldEditingProtocol;
import org.actionstep.ASFieldEditor;
import org.actionstep.constants.NSLineBreakMode;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.constants.NSTextFieldBezelStyle;
import org.actionstep.NSActionCell;
import org.actionstep.NSColor;
import org.actionstep.NSControl;
import org.actionstep.NSEvent;
import org.actionstep.NSFont;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.ASColors;

/**
 * Draws an NSTextField.
 *
 * @author Rich Kilmer
 */
class org.actionstep.NSTextFieldCell extends NSActionCell
  implements ASFieldEditingProtocol {

  private var m_bezelStyle:NSTextFieldBezelStyle;
  private var m_textColor:NSColor;
  private var m_backgroundColor:NSColor;
  private var m_borderColor:NSColor;
  private var m_drawsBackground:Boolean;
  private var m_beingEditedBy:Object;

  // Flash Text Field
  private var m_textField:TextField;
  private var m_textFormat:TextFormat;
  private var m_actionMask:Number;

  //******************************************************
  //*                  Construction
  //******************************************************
  
  public function NSTextFieldCell() {
    m_drawsBackground = false;
    m_beingEditedBy = null;
    m_textField = null;
    m_textFormat = null;
    m_textColor = ASTheme.current().systemFontColor();
    m_actionMask = NSEvent.NSKeyUpMask | NSEvent.NSKeyDownMask;
    m_bezelStyle = NSTextFieldBezelStyle.NSTextFieldSquareBezel;
    m_bezeled = true;
    m_bordered = false;
  }

  public function init():NSTextFieldCell {
    initTextCell("");
    return this;
  }

  public function initTextCell(string:String):NSTextFieldCell {
    super.initTextCell(string);
    m_drawsBackground = false;
    return this;
  }

  //******************************************************
  //*          Releasing the object from memory
  //******************************************************
  
  public function release():Boolean {
    if (m_textField != null) {
      m_textField.removeTextField();
      m_textField = null;
    }

    return super.release();
  }
  
  //******************************************************
  //*                  Copying a cell
  //******************************************************
  
  public function copyWithZone():NSTextFieldCell {
    var ret:NSTextFieldCell = NSTextFieldCell(super.copyWithZone());
    ret.m_bezelStyle = m_bezelStyle;
    ret.m_textColor = m_textColor.copyWithZone();
    ret.m_backgroundColor = m_backgroundColor.copyWithZone();
    ret.m_borderColor = m_borderColor.copyWithZone();
    ret.m_drawsBackground = m_drawsBackground;
    ret.m_actionMask = m_actionMask;
    return ret;
  }
  
  //******************************************************
  //*                  Flash specific
  //******************************************************
  
  /**
   * Returns the cell's textfield. Will build if necessary.
   */
  public function textField():TextField {
    if (m_textField == null || m_textField._parent == undefined) {
      //
      // Build the text format and textfield
      //
      m_textField = m_controlView.createBoundsTextField();
      m_textFormat = m_font.textFormatWithAlignment(m_alignment);
      m_textFormat.color = m_textColor.value;
      m_textField.self = this;
      m_textField.text = stringValue();
      m_textField.embedFonts = m_font.isEmbedded();
      m_textField.selectable = false;
      m_textField.type = "dynamic";
      m_textField.antiAliasType = "advanced";
      
      //
      // Assign the textformat.
      //
      m_textField.setTextFormat(m_textFormat);
    }

    return m_textField;
  }
  
  private function validateTextField(cellFrame:NSRect) {
    //
    // Get the textfield and its text. Will be built if necessary.
    //
    var tf:TextField = textField();
    var text:String = stringValue();

    //
    // Set the wrapping value
    //
    m_textField.wordWrap = m_wraps;

    //
    // Determine antialiasing based on the alignment
    //
    if (m_font.pointSize() > 20) {
    	tf.gridFitType = "none";
    } else {
	    tf.gridFitType = m_alignment == NSTextAlignment.NSLeftTextAlignment ? 
	    	"pixel" : "subpixel";
    }
        
    //
    // Truncate the string value if necessary.
    //
    if (m_font.getTextExtent(text).width + tf._x > cellFrame.maxX()) {
	  switch (m_lineBreakMode) {
	    case NSLineBreakMode.NSDefaultLineBreak:
	      break;

	    case NSLineBreakMode.NSLineBreakByTruncatingHead:
	      text = truncateTextWithLeadingEllipsis(text, tf._width);
	      break;

	    case NSLineBreakMode.NSLineBreakByTruncatingMiddle:
	      text = truncateTextWithMiddleEllipsis(text, tf._width);
	      break;

	    case NSLineBreakMode.NSLineBreakByTruncatingTail:
	      text = truncateTextWithTrailingEllipsis(text, tf._width);
	      break;
	  }
	  m_isTruncated = true;
    } else {
      m_isTruncated = false;
    }

    //
    // Set the font and text format if necessary.
    //
    if (tf.text != text) {
      tf.text = text;
    }

    if (tf.getTextFormat() != m_textFormat) {
      tf.setTextFormat(m_textFormat);
    }
  }

  private function validateTextFormat():Boolean {
    var updated:Boolean = false;
    if (m_textFormat == null) {
      m_textFormat = m_font.textFormat();
      updated = true;
    }
    var color:Number = m_enabled ? m_textColor.value : ASTheme.current(
    	).colorWithName(ASThemeColorNames.ASDisabledText).value;
    if (m_textFormat.color != color) {
      m_textFormat.color = color;
      updated = true;
    }
    switch(m_alignment) {
      case NSTextAlignment.NSRightTextAlignment:
        if (m_textFormat.align != "right") {
	        m_textFormat.align = "right";
	        updated = true;
	      }
        break;
      case NSTextAlignment.NSCenterTextAlignment:
        if (m_textFormat.align != "center") {
          m_textFormat.align = "center";
          updated = true;
        }
        break;
      case NSTextAlignment.NSLeftTextAlignment:
        default:
        if (m_textFormat.align != "left") {
	        m_textFormat.align = "left";
	        updated = true;
	      }
        break;
    }
    return updated;
  }

  //******************************************************                               
  //*        Modifying textual attributes of cells
  //******************************************************
  
  public function setEditable(value:Boolean) {
    super.setEditable(value);
  }

  public function setSelectable(value:Boolean) {
    super.setSelectable(value);
  }

  public function setTextColor(value:NSColor) {
    m_textColor = value;
    m_textFormat.color = m_textColor.value;
    if (m_controlView && (m_controlView instanceof NSControl)) {
      NSControl(m_controlView).updateCell(this);
    }
  }

  public function textColor():NSColor {
    return m_textColor;
  }

  public function setFont(font:NSFont) {
    super.setFont(font);
    m_textFormat = m_font.textFormat();
    m_textFormat.color = m_textColor.value;
    if (m_textField != null) {
      m_textField.embedFonts = m_font.isEmbedded();
    }
  }
  
  /**
   * Wraps around {@link #setTextColor()}
   */
  public function setFontColor(color:NSColor) {
    setTextColor(color);
  }
  
  /**
   * Returns {@link #textColor()}
   */
  public function fontColor():NSColor {
    return textColor();
  }

  public function setBackgroundColor(value:NSColor) {
    m_backgroundColor = value;
    if (m_controlView && (m_controlView instanceof NSControl)) {
      NSControl(m_controlView).updateCell(this);
    }
  }

  public function backgroundColor():NSColor {
    return m_backgroundColor;
  }

  public function setBorderColor(color:NSColor) {
    m_borderColor = color;
    if (m_controlView && (m_controlView instanceof NSControl)) {
      NSControl(m_controlView).updateCell(this);
    }
  }

  public function borderColor():NSColor {
    return m_borderColor;
  }

  public function setDrawsBackground(value:Boolean) {
    m_drawsBackground = value;
    if (m_controlView && (m_controlView instanceof NSControl)) {
      NSControl(m_controlView).updateCell(this);
    }
  }

  public function drawsBackground():Boolean {
    return m_drawsBackground;
  }

  public function setBezelStyle(value:NSTextFieldBezelStyle) {
    m_bezelStyle = value;
  }

  public function bezelStyle():NSTextFieldBezelStyle {
    return m_bezelStyle;
  }
  
  //******************************************************
  //*               Field editor handlers
  //******************************************************
  
  public function beginEditingWithDelegate(delegate:Object):ASFieldEditor {
    if (!isSelectable()) {
      return null;
    }
    if (m_textField != null && m_textField._parent != undefined) {
      m_textField.text = stringValue();
      var editor:ASFieldEditor = ASFieldEditor.startEditing(this, delegate, m_textField);
      return editor;
    }
    return null;
  }

  public function endEditingWithDelegate(delegate:Object):Void {
    ASFieldEditor.endEditing();
    m_textField.setTextFormat(m_textFormat);
  }
  
  //******************************************************                               
  //*               Determining cell sizes          
  //******************************************************
  
  public function titleRectForBounds(theRect:NSRect):NSRect {
    var drawBg:Boolean = m_drawsBackground || m_backgroundColor != null;
    var fontHeight:Number = m_font.getTextExtent("Why").height;
    var x:Number = theRect.origin.x;
    var y:Number = theRect.origin.y;
    var w:Number = theRect.size.width - 1;
    var h:Number = theRect.size.height - 1;
    var ret:NSRect = NSRect.ZeroRect;
    
    ret.origin.x = x + (drawBg ? 3 : 0);
    ret.origin.y = y + (drawBg && !m_wraps ? (h - fontHeight) / 2 : 0);
    ret.size.width = w - 1;
    
    if (m_wraps) {
    	ret.size.height = h - 1;
    } else {
    	ret.size.height = fontHeight;
    }
    
    return ret;
  }
  
  private function setInternalTextFieldFrame(aRect:NSRect):Void {
    var tf:TextField = textField();
    tf._x = aRect.origin.x;
    tf._y = aRect.origin.y;
    tf._width = aRect.size.width;
    tf._height = aRect.size.height;
  }
   
  //******************************************************
  //*                      Drawing
  //******************************************************
  
  public function drawWithFrameInView(cellFrame:NSRect, inView:NSView) {
    if (m_controlView != inView) {
      m_controlView = inView;
    }
    if (m_drawsBackground) {
      ASTheme.current().drawTextFieldCellInRectOfView(this, cellFrame, inView);
	} else {
      if (m_backgroundColor) {
	      ASDraw.fillRectWithRect(m_controlView.mcBounds(), cellFrame, m_backgroundColor.value, m_backgroundColor.alphaValue);
	    }
	    if (m_borderColor) {
	      ASDraw.drawRectWithRect(m_controlView.mcBounds(), cellFrame.sizeRectLeftRightTopBottom(0,1,0,1), m_borderColor.value, m_borderColor.alphaValue);
	    }
	  }
    if (m_showsFirstResponder) {
      ASTheme.current().drawFirstResponderWithRectInView(cellFrame, inView);
    }
    
    drawInteriorWithFrameInView(cellFrame, inView);
  }
  
  public function drawInteriorWithFrameInView(cellFrame:NSRect, inView:NSView):Void {
    validateTextFormat();
    setInternalTextFieldFrame(titleRectForBounds(cellFrame));
    if (ASFieldEditor.instance().cell() != this) {
      validateTextField(cellFrame);
    }
  }
}
