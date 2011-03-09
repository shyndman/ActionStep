/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSException;
import org.actionstep.NSSize;
import org.actionstep.themes.ASTheme;
import org.actionstep.ASUtils;
import flash.display.BitmapData;
import flash.geom.Rectangle;

/**
 * <p>This class represents a font. It provides methods to access and modify
 * a font's characteristics, calculates font metrics and can convert itself
 * into a <code>TextFormat</code> object.</p>
 * 
 * <p>This class differs extensively from the spec.</p> 
 * 
 * @author Scott Hyndman
 * @author Richard Kilmer
 */
class org.actionstep.NSFont extends org.actionstep.NSObject {
  
  //******************************************************															 
  //*                   Constants
  //******************************************************
  
  public static var ASDefaultSystemFontName:String = "Arial";
  public static var ASTextMeasureRoot:MovieClip = _root;
  
  //******************************************************															 
  //*                  Class members
  //******************************************************
  
  private static var g_system_font_name:String;
  private static var g_system_font_embedded:Boolean = false;
  private static var g_system_font_size:Number = 12;
  private static var g_fontMap:Object = {};
  private static var g_creationDel:Object;
  
  //******************************************************															 
  //*                 Member variables
  //******************************************************
  
  private var m_pointSize:Number;
  private var m_fontName:String;
  private var m_isBold:Boolean;
  private var m_isEmbedded:Boolean;
  private var m_key:String;
  
  //******************************************************															 
  //*                   Construction
  //******************************************************
  
  /**
   * Creates a new instance of the <code>NSFont</code> class.
   */
  private function NSFont(name:String, size:Number, bold:Boolean, embedded:Boolean) {
    m_isBold = bold;
    m_isEmbedded = embedded;
    m_fontName = name;
    m_pointSize = size;
    m_key = keyForValues(name, size, bold, embedded);
    
    g_fontMap[m_key] = this;
  }
  
  //******************************************************
  //*                 Copying the font
  //******************************************************
  
  /**
   * Copies the font.
   */
  public function copyWithZone():NSFont {
    return this;
  }
  
  //******************************************************															 
  //*               Describing the object
  //******************************************************
  
  /**
   * Returns a string representation of the font.
   */
  public function description():String {
    return "NSFont(fontName=" + m_fontName + ", pointSize=" + m_pointSize 
      + ", bold=" + m_isBold + ", embedded=" + m_isEmbedded + ")";
  }
  
  //******************************************************															 
  //*               Comparing the object
  //******************************************************
  
  /**
   * Returns <code>true</code> if this font is equal to <code>other</code>,
   * otherwise returns <code>false</code>.
   */
  public function isEqual(other:Object):Boolean {
    if (!(other instanceof NSFont)) {
      return false;
    }
    
    var font:NSFont = NSFont(other);
    return m_fontName == font.fontName()
      && m_isBold == font.isBold()
      && m_pointSize == font.pointSize()
      && m_isEmbedded == font.isEmbedded();
  }
  
  //******************************************************															 
  //*          Setting / getting font names
  //******************************************************
  
  /**
   * Sets the name of the font to <code>value</code>.
   */
  private function _setFontName(value:String) {
    m_fontName = value;
  }
  
  /**
   * Returns the name of the font.
   */
  public function fontName():String {
    return m_fontName;
  }
  
  //******************************************************															 
  //*     Setting / getting display characteristics
  //******************************************************
  
  /**
   * Sets the point size of the font to <code>value</code>.
   */
  private function _setPointSize(value:Number) {
    m_pointSize = value;
  }
  
  /**
   * Returns the point size of the font.
   */
  public function pointSize():Number {
    return m_pointSize;
  }
  
  /**
   * <p>Sets the bold property of the font. If <code>value</code> is 
   * <code>true</code>, the font will be bold. If <code>false</code>, the font
   * will be normal.</p>
   * 
   * <p>This is an ActionStep specific function.</p> 
   */  
  private function _setBold(value:Boolean) {
    m_isBold = value;
  }
  
  /**
   * <p>Returns <code>true</code> if the font is bold, or <code>false</code> if it
   * is not.</p>
   * 
   * <p>This is an ActionStep specific function.</p> 
   */  
  public function isBold():Boolean {
    return m_isBold;    
  }
  
  //******************************************************															 
  //*                 Embedded fonts
  //******************************************************
  
  /**
   * <p>Returns if this font is based on an embedded font (must be a symbol in the 
   * Library)</p>
   * 
   * <p>This method is ActionStep-only.</p>
   */
  public function isEmbedded():Boolean {
    return m_isEmbedded;
  }

  /**
   * <p>Sets if this is based on an embedded font (must be a symbol in the 
   * Library).</p>
   * 
   * <p>This method is ActionStep-only.</p>
   */
  private function _setEmbedded(value:Boolean) {
    m_isEmbedded = value;
  }
  
  //******************************************************															 
  //*            Getting a fonts text format
  //******************************************************
  
  /**
   * <p>Returns the TextFormat object corresponding to this font's properties.</p>
   *
   * <p>This is an ActionStep specific function.</p> 
   */  
  public function textFormat():TextFormat {
    var tf:TextFormat = new TextFormat();
    tf.size = m_pointSize;
    tf.font = m_fontName;
    tf.bold = m_isBold;
    return tf;
  }
  
  /**
   * <p>Returns the TextFormat object corresponding to this font's properties and
   * an alignment object.</p>
   *
   * <p>This is an ActionStep specific function.</p>
   */  
  public function textFormatWithAlignment(alignment:NSTextAlignment):TextFormat
  {
  	var tf:TextFormat = textFormat();
  	var setting:String;
  	
    switch (alignment.value)
    {
      case 0:
        setting = "left";
        break;
    		
      case 1:
        setting = "right";
        break;

      case 2:
        setting = "center";
        break;

      case 4:
      	setting = "left"; //! should be set to localized setting...
      	break;
      	
      default:
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			"UnsupportedOperationException", 
			"NSTextAlignment.NSNaturalTextAlignment" +
			" is not supported.", 
			null);
		trace(e);
		throw e;
        break;
      
    }
    
    tf.align = setting;
    
    return tf;
  }
  
  //******************************************************															 
  //*              Font metric information
  //******************************************************
  
  /**
   * <p>Returns the size of <code>aString</code> when rendered in this font on a 
   * single line.</p>
   *
   * <p>This is an ActionStep specific function.</p> 
   */
  public function getTextExtent(aString:String):NSSize
  {
    var measure:TextField = ASTextMeasureRoot.m_textMeasurer;
    if (measure == undefined || measure._parent != ASTextMeasureRoot)
    {
      ASTextMeasureRoot.createTextField("m_textMeasurer", -16384, 0, 0, 1000, 100);
      measure = ASTextMeasureRoot.m_textMeasurer;
      measure._visible = false;
      measure.multiline = true;
    }
    
    var tf:TextFormat = this.textFormat();
    tf.align = "left";
    measure.text = aString;
    measure.embedFonts = m_isEmbedded;
    measure.setTextFormat(tf);
    
    return new NSSize(measure.textWidth + 4, measure.textHeight + 4);
  }

  /**
   * <p>Returns the size of <code>aString</code> when rendered in this font on a 
   * in an HTML text field.</p>
   *
   * <p>This is an ActionStep specific function.</p> 
   */
  public function getHTMLTextExtent(aString:String):NSSize
  {
    var measure:TextField = ASTextMeasureRoot.m_htmlTextMeasurer;

    if (measure == undefined || measure._parent != ASTextMeasureRoot)
    {
      ASTextMeasureRoot.createTextField("m_htmlTextMeasurer", -16383, 0, 0, 1000, 100);
      measure = ASTextMeasureRoot.m_htmlTextMeasurer;
      measure._visible = false;
      measure.multiline = true;
      measure.html = true;
    }
    
    var tf:TextFormat = this.textFormat();
    tf.align = "left";
    measure.htmlText = aString;
    measure.setTextFormat(tf);
    
    return new NSSize(measure.textWidth + 4, measure.textHeight + 4);
  }
  
  /**
   * <p>Returns the size of <code>aString</code> when rendered in this font 
   * in a multiline HTML text field. The alignment applied is 
   * <code>alignment</code> and is afforded a maximum width of 
   * <code>maxWidth</code> (only if <code>wrap</code> is <code>true</code>).</p>
   *
   * <p>This is an ActionStep specific function.</p> 
   */
  public function getMultilineTextExtent(aString:String, 
      alignment:NSTextAlignment, maxWidth:Number, wrap:Boolean):NSSize {
    var measureMc:MovieClip = ASTextMeasureRoot.__multilineTextMeasurer;
    var measure:TextField = measureMc.__multilineTextMeasurer;
	
    if (measureMc == undefined || measureMc._parent != ASTextMeasureRoot)
    {
      measureMc = ASTextMeasureRoot.createEmptyMovieClip("__multilineTextMeasurer", 1283);
      measureMc.createTextField("__multilineTextMeasurer", -16380, 0, 0, 1000, 100);
      measure = measureMc.__multilineTextMeasurer;
      measure.multiline = true;
      measure.html = true;
    }
     
     
    measure._visible = true;
    measure.htmlText = "";
    measure.autoSize = false;
    measure.wordWrap = wrap;
    measure.embedFonts = m_isEmbedded;
    
    measure._width = maxWidth;
    measure._height = 4;   
    measure.htmlText = aString;
    
    var tf:TextFormat = textFormatWithAlignment(alignment);
    measure.setTextFormat(tf);
    
    switch (alignment) {
      case NSTextAlignment.NSLeftTextAlignment:
        measure.autoSize = "left";
        break;
        
      case NSTextAlignment.NSRightTextAlignment:
        measure.autoSize = "right";
        break;
        
      case NSTextAlignment.NSCenterTextAlignment:
        measure.autoSize = "center";
        break;
    }
    
    var measureBmp:BitmapData = new BitmapData(maxWidth, 500);
    measureBmp.draw(measureMc);
    var cb:Rectangle = measureBmp.getColorBoundsRect (0xFFFFFFFF, 0xFFFFFFFF, false);
    measureBmp.dispose();
    measure._visible = false;
    
    return new NSSize(cb.width + 4, cb.height + 4);
  }
  
  //******************************************************															 
  //*                 Creating a font
  //******************************************************
  
  /**
   * Returns the font with the name <code>name</code> and a pointsize of
   * <code>size</code>. If <code>embedded</code> is <code>true</code>, the
   * swf should contain font outline information. If <code>embedded</code> is
   * <code>false</code> the computer's font is used.
   */
  public static function fontWithNameSizeEmbedded(name:String, size:Number, 
      embedded:Boolean):NSFont {
    return fontWithNameSizeEmbeddedBold(name, size, embedded, false);
  }
  
  /**
   * Returns the font with the name <code>name</code> and a pointsize of
   * <code>size</code>. If <code>embedded</code> is <code>true</code>, the
   * swf should contain font outline information. If <code>embedded</code> is
   * <code>false</code> the computer's font is used.
   */
  public static function fontWithNameSizeEmbeddedBold(name:String, size:Number, 
      embedded:Boolean, bold:Boolean):NSFont {
    var fnt:NSFont = cachedFontWithNameSizeEmbeddedBold(name, size, embedded, bold);
    if (fnt != null) {
      return fnt;
    }
    
    return createFontWithNameSizeEmbeddedBold(name, size, embedded, bold);
  }
  
  /**
   * Returns the font with the name <code>name</code> and a pointsize of
   * <code>size</code>.
   */
  public static function fontWithNameSize(name:String, size:Number):NSFont {
    return fontWithNameSizeEmbedded(name, size, false);
  }
  
  /**
   * Returns the font with the name <code>name</code> and a pointsize of
   * <code>size</code>.
   */
  public static function fontWithNameSizeBold(name:String, size:Number, bold:Boolean):NSFont {
    return fontWithNameSizeEmbeddedBold(name, size, false, bold);
  }
  
  /**
   * Returns the bold version of the specified font.
   */
  public static function boldFontWithFont(font:NSFont):NSFont {
    return fontWithNameSizeEmbeddedBold(font.fontName(), font.pointSize(), 
    	font.isEmbedded(), true);
  }
  
  /**
   * <p>
   * This method calls {@link ASThemeProtocol#systemFontOfSize()} 
   * internally on the current theme.
   * </p>
   * 
   */
  public static function systemFontOfSize(size:Number):NSFont {
    return ASTheme.current().systemFontOfSize(size);
  }
  
  /**
   * <p>
   * This method calls {@link ASThemeProtocol#boldSystemFontOfSize()} 
   * internally on the current theme.
   * </p>
   */
  public static function boldSystemFontOfSize(size:Number):NSFont {
    return ASTheme.current().boldSystemFontOfSize(size);
  }

  /**
   * <p>
   * This method calls {@link ASThemeProtocol#menuFontOfSize()} 
   * internally on the current theme.
   * </p>
   */
  public static function menuFontOfSize(size:Number):NSFont {
    return ASTheme.current().menuFontOfSize(size);
  }
  
  /**
   * <p>
   * This method calls {@link ASThemeProtocol#toolTipsFontOfSize()} 
   * internally on the current theme.
   * </p>
   */
  public static function toolTipsFontOfSize(size:Number):NSFont {
    return ASTheme.current().toolTipsFontOfSize(size);
  }
  
  /**
   * <p>
   * This method calls {@link ASThemeProtocol#controlContentFontOfSize()} 
   * internally on the current theme.
   * </p>
   */
  public static function controlContentFontOfSize(size:Number):NSFont {
    return ASTheme.current().controlContentFontOfSize(size);
  }
  
  /**
   * <p>
   * This method calls {@link ASThemeProtocol#labelFontOfSize()} 
   * internally on the current theme.
   * </p>
   */
  public static function labelFontOfSize(size:Number):NSFont {
    return ASTheme.current().labelFontOfSize(size);
  }
  
  /**
   * <p>
   * This method calls {@link ASThemeProtocol#menuBarFontOfSize()} 
   * internally on the current theme.
   * </p>
   */
  public static function menuBarFontOfSize(size:Number):NSFont {
    return ASTheme.current().menuBarFontOfSize(size);
  }
  
  /**
   * <p>
   * This method calls {@link ASThemeProtocol#messageFontOfSize()} 
   * internally on the current theme.
   * </p>
   */
  public static function messageFontOfSize(size:Number):NSFont {
    return ASTheme.current().messageFontOfSize(size);
  }
  
  /**
   * <p>
   * This method calls {@link ASThemeProtocol#paletteFontOfSize()} 
   * internally on the current theme.
   * </p>
   */
  public static function paletteFontOfSize(size:Number):NSFont {
    return ASTheme.current().paletteFontOfSize(size);
  }
  
  /**
   * <p>
   * This method calls {@link ASThemeProtocol#titleBarFontOfSize()} 
   * internally on the current theme.
   * </p>
   */
  public static function titleBarFontOfSize(size:Number):NSFont {
    return ASTheme.current().titleBarFontOfSize(size);
  }
  
  //******************************************************
  //*              Caching and creation
  //******************************************************
  
  /**
   * Returns a cached font with the specified properties, or null if it doesn't
   * exist.
   */
  private static function cachedFontWithNameSizeEmbeddedBold(name:String, size:Number, 
      embedded:Boolean, bold:Boolean):NSFont {
    return g_fontMap[keyForValues(name, size, bold, embedded)];
  }
  
  /**
   * Creates a font.
   */
  private static function createFontWithNameSizeEmbeddedBold(name:String, size:Number, 
      embedded:Boolean, bold:Boolean):NSFont {
    if (g_creationDel != null && ASUtils.respondsToSelector(g_creationDel, "createFont")) {
      var fnt:NSFont = NSFont(g_creationDel.createFont(name, size, embedded, bold));
      if (fnt != null) {
        return fnt;
      }
    }
    
    return new NSFont(name, size, bold, embedded);
  }
  
  /**
   * Sets an object that is given the opportunity to create fonts instead of
   * the font class.
   */
  public static function setFontCreationDelegate(del:Object):Void {
    g_creationDel = del;
  }
  
  //******************************************************
  //*                Static helpers
  //******************************************************
  
  /**
   * Gets a key for the font map from the specified values.
   */
  private static function keyForValues(name:String, size:Number, bold:Boolean, 
      embedded:Boolean):String {
    return name + ":" + size + ":" + bold + ":" + embedded;
  }
}