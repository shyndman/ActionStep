/* See LICENSE for copyright and terms of use */
 
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;

/**
 * Draws multiline uneditable text.
 * 
 * To see an example of this class' usage, please see
 * <code>org.actionstep.test.ASTestTextRenderer</code>.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.ASTextRenderer extends NSView {
  
  private var m_textField:TextField;
  private var m_text:String;
  private var m_style:TextField.StyleSheet;
  private var m_leftMargin:Number;
  private var m_rightMargin:Number;
  private var m_topMargin:Number;
  private var m_bottomMargin:Number;
  private var m_automaticResize:Boolean;
  private var m_wordWrap:Boolean;
  private var m_drawsBackground:Boolean;
  private var m_usesEmbeddedFonts:Boolean;
  private var m_selectable:Boolean;

  public function ASTextRenderer() {
    m_topMargin = 5;
    m_leftMargin = 5;
    m_bottomMargin = 5;
    m_rightMargin = 5;
    m_automaticResize = false;
    m_wordWrap = false;
    m_drawsBackground = true;
    m_usesEmbeddedFonts = false;
    m_selectable = false;
  }
  
  public function initWithFrame(rect:NSRect):ASTextRenderer {
    super.initWithFrame(rect);
    return this;
  }

  public function createMovieClips() {
    super.createMovieClips();
    if (m_mcBounds != null) {
      m_textField = createBoundsTextField();
      m_textField.border = false;
      m_textField.type = "dynamic";
      m_textField.wordWrap = m_wordWrap;
      m_textField.embedFonts = m_usesEmbeddedFonts;
      m_textField.multiline = true;
      m_textField.autoSize = false;
      m_textField.html = true;
      m_textField._x = m_leftMargin;
      m_textField._y = m_topMargin;
      m_textField.editable = false;
      m_textField.selectable = m_selectable;
      m_textField.styleSheet = m_style;
      m_textField.htmlText = m_text;
      m_textField.antiAliasType = "advanced";
      m_textField.gridFitType = "pixel";
      m_textField._width = bounds().size.width - m_leftMargin - m_rightMargin;
      m_textField._height = bounds().size.height - m_topMargin - m_bottomMargin;
      autoSize();
    }
  }

  public function setRightMargin(value:Number) {
    m_rightMargin = value;
  }

  public function rightMargin():Number {
    return m_rightMargin;
  }

  public function setLeftMargin(value:Number) {
    m_leftMargin = value;
    m_textField._x = m_leftMargin;
    autoSize();
  }

  public function leftMargin():Number {
    return m_leftMargin;
  }

  public function setTopMargin(value:Number) {
    m_topMargin = value;
    m_textField._y = m_topMargin;
    autoSize();
  }

  public function topMargin():Number {
    return m_topMargin;
  }

  public function setBottomMargin(value:Number) {
    m_bottomMargin = value;
    autoSize();
  }

  public function bottomMargin():Number {
    return m_bottomMargin;
  }
  
  public function wordWrap():Boolean {
    return m_wordWrap;
  }
  
  public function setWordWrap(value:Boolean) {
    m_wordWrap = value;
    m_textField.wordWrap = m_wordWrap;
    m_textField.styleSheet = m_style;
    m_textField.htmlText = m_text;
    autoSize();
  }
  
  public function setAutomaticResize(value:Boolean) {
    if(m_automaticResize == value) return;
    m_automaticResize = value;
    autoSize();
  }
  
  public function automaticResize():Boolean {
    return m_automaticResize;
  }

  public function setStyleSheet(style:TextField.StyleSheet) {
    m_style = style;
    m_textField.styleSheet = m_style;
    m_textField.htmlText = m_text;
  }

  public function styleSheet():TextField.StyleSheet {
    return m_style;
  }
  
  public function setStyleCSS(css:String):Boolean {
    var style:TextField.StyleSheet =  new TextField.StyleSheet();
    if (style.parseCSS(css)) {
      setStyleSheet(style);
      return true;
    } else {
      return false;
    }
  }
  
  public function setUsesEmbeddedFonts(value:Boolean) {
    m_usesEmbeddedFonts = value;
    if (m_textField != undefined) {
      m_textField.embedFonts = m_usesEmbeddedFonts;
    }
  }

  public function usesEmbeddedFonts():Boolean {
    return m_usesEmbeddedFonts;
  }

  public function setText(text:String) {
    m_text = text;
    if (m_textField != null) {  
      m_textField.htmlText = m_text;
    }
    autoSize();
  }
  
  public function setDrawsBackground(value:Boolean) {
    if (m_drawsBackground == value) return;
    m_drawsBackground = value;
    setNeedsDisplay(true);
  }
  
  public function drawsBackground():Boolean {
    return m_drawsBackground;
  }

  public function text():String {
    return m_text;
  }

  public function drawRect(rect:NSRect) {
    if (m_drawsBackground) {
      m_mcBounds.clear();
      ASTheme.current().drawListWithRectInView(rect, this);
    }
  }
  
  public function setFrame(rect:NSRect) {
    if (m_automaticResize && m_textField != null) {
      rect.size.height = m_textField.textHeight + m_topMargin + m_bottomMargin+10;
      if (!m_wordWrap) {
        rect.size.width = m_textField.textWidth + m_leftMargin + m_rightMargin+10;
      }
    } 
    super.setFrame(rect);
    m_textField._width = rect.size.width  - m_leftMargin - m_rightMargin;
    m_textField._height = rect.size.height - m_topMargin - m_bottomMargin;
  }
  
  public function setFrameSize(size:NSSize) {
    if (m_automaticResize && m_textField != null) {
      size.height = m_textField.textHeight + m_topMargin + m_bottomMargin+10;
      if (!m_wordWrap) {
        size.width = m_textField.textWidth + m_leftMargin + m_rightMargin+10;
      }
    } 
    super.setFrameSize(size);
    m_textField._width = size.width  - m_leftMargin - m_rightMargin;
    m_textField._height = size.height - m_topMargin - m_bottomMargin;
  }
  
  /**
   * Automatically resizes the text renderer if <code>automaticResize</code>
   * is set to <code>true</code>.
   * 
   * This is automatically called after a <code>setText()</code> call.
   */
  public function autoSize() {
    if (!m_automaticResize) return;
    var size:NSSize = new NSSize(0,0);
    if (m_textField != undefined) {
      if (m_wordWrap) {
        size.width = bounds().size.width;
      }
    } else {
      size.width = bounds().size.width;
    }
    setFrameSize(size);
  }
  
  //******************************************************
  //*             MovieClip (ActionStep-only)
  //******************************************************
  
  private function requiresMask():Boolean {
    return false;
  }
}