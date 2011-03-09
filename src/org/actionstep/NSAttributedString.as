/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSArray;
import org.actionstep.NSColor;
import org.actionstep.NSCopying;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSFont;
import org.actionstep.NSObject;
import org.actionstep.NSParagraphStyle;
import org.actionstep.NSRange;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeProtocol;

/**
 * <p>In a nutshell, <code>NSAttributedString</code> represents a formatted
 * string.</p>
 * 
 * <p><code>NSAttributedString</code> objects manage character strings and 
 * associated sets of attributes (for example, font and kerning) that apply to 
 * individual characters or ranges of characters in the string. An association 
 * of characters and their attributes is called an attributed string.</p>
 * 
 * <p>It is not yet used extensively.</p>
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSAttributedString extends NSObject implements NSCopying {
	
	//******************************************************
	//*                    Constants
	//******************************************************
	
	/**
	 * <p>Key name of the font attribute (NSFont)</p>
	 * 
	 * <p>This attribute's value represents the font of the text.</p>
	 * 
	 * <p>The default is the current theme's systemFont.</p>
	 * 
	 * @see org.actionstep.ASThemeProtocol#systemFontOfSize()
	 * @see org.actionstep.ASThemeProtocol#systemFontSize()
	 */
	public static var NSFontAttributeName:String = "font";
	
	/**
	 * <p>Key name of the foreground color attribute (NSColor)</p>
	 * 
	 * <p>This attribute's value represents the color of the text.</p>
	 * 
	 * <p>The default is black.</p>
	 */
	public static var NSForegroundColorAttributeName:String = "foregroundColor";
	
	/**
	 * <p>Key name of the kerning attribute (Boolean).</p>
	 * 
	 * <p>Specifies whether kerning should be used. Kerning is only supported
	 * by embedded fonts in Windows. Some fonts do not support kerning.</p>
	 * 
	 * <p>The default is <code>false</code>.</p>
	 */
	public static var NSKernAttributeName:String = "kerning";
	
	/**
	 * <p>Key name of the letter spacing attribute (Number).</p>
	 * 
	 * <p>This attribute's value represents the amount of space inbetween 
	 * letters in the text.</p>
	 * 
	 * <p>The default is 0.</p>
	 * 
	 * <p>This is an actionstep specific constant.</p>
	 */	
	public static var NSLetterSpacingAttributeName:String = "letterSpacing";
	
	/**
	 * <p>
	 * Key name of the link attribute (String URL or Object)
	 * </p>
	 * 
	 * <p>
	 * If the value of this attribute is an object, the object will be passed to
	 * the <code>NSTextView</code> method  
	 * {@link org.actionstep.NSTextView#clickedOnLinkAtIndex()}. The text view's
	 * delegate can implement <code>textViewClickedOnLinkAtIndex()</code> or
	 * <code>textViewClickedOnLink()</code> (described in 
	 * {@link org.actionstep.text.ASTextViewDelegate}) to process the link
	 * object.
	 * </p>
	 * 
	 * <p>
	 * The default implementation calls <code>toString()</code> on the link 
	 * object and attempts to navigate to that URL.
	 * </p>
	 */
	public static var NSLinkAttributeName:String = "link";
	
	/**
	 * <p>Key name of the paragraph style attribute (NSParagraphStyle).</p>
	 * 
	 * <p>The default is the value returned from the theme's
	 * <code>defaultParagraphStyle()</code> method.</p>
	 * 
	 * @see org.actionstep.ASThemeProtocol#defaultParagraphStyle()
	 */
	public static var NSParagraphStyleAttributeName:String = "paragraphStyle";
		
	/**
	 * <p>Key name of the underline attribute (Boolean).</p>
	 * 
	 * <p>This attribute's value represents whether or not the text is
	 * underlined.</p>
	 * 
	 * <p>The default is <code>false</code>.</p>
	 */
	public static var NSUnderlineStyleAttributeName:String = "underline";
	
	/**
	 * <p>This is the key name of a special attribute included with the 
	 * attributes dictionary when using {@link #attributesAtIndexEffectiveRange()}
	 * and {@link #attributesAtIndexLongestEffectiveRangeInRange()} when the
	 * <code>effectiveRange</code> argument is set to <code>true</code>.</p>
	 * 
	 * <p>The value of the entry is an NSRange instance representing a 
	 * sequential range of characters over which the returned string styling 
	 * attributes are applied.</p>
	 */
	public static var ASEffectiveRangeAttributeName:String = "__effectiveRange";
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_string:String;
	private var m_htmlString:String;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * <p>Constructs a new instance of the NSAttributedString class.</p>
	 * 
	 * <p>After construction, the instance must be initialized by using either the
	 * {@link #initWithString()}, {@link #initWithHTML()}, 
	 * {@link #initWithAttributedString()} or {@link #initWithStringAttributes()}
	 * methods.</p>
	 */
	public function NSAttributedString() {
		m_string = null;
		m_htmlString = null;
	}
	
	/**
	 * <p>Returns an <code>NSAttributedString</code> object initialized with 
	 * the characters of a given string and no attribute information.</p>
	 */
	public function initWithString(string:String):NSAttributedString {
		m_string = string;
		return this;
	}
	
	/**
	 * <p>Returns an <code>NSAttributedString</code> object initialized with 
	 * the characters and attributes of another given attributed string.</p>
	 */
	public function initWithAttributedString(string:NSAttributedString):NSAttributedString {
		m_string = string.m_string;
		m_htmlString = string.m_htmlString;
		return this;
	}
	
	/**
	 * <p>Returns an <code>NSAttributedString</code> object initialized with a 
	 * given string and attributes.</p>
	 */
	public function initWithStringAttributes(string:String, 
			attributes:NSDictionary):NSAttributedString {
		m_string = m_htmlString = string;
				
		return this;
	}
	
	/**
	 * <p>Initializes and returns a new <code>NSAttributedString</code> object 
	 * from HTML contained in the given string.</p>
	 */
	public function initWithHTML(html:String):NSDictionary {
		m_htmlString = html;
		return null;
	}
	
	//******************************************************
	//*               Describing the object	
	//******************************************************
	
	/**
	 * Returns a string representation of the attributed string.
	 */
	public function description():String {
		return "NSAttributedString(value=" + htmlString()
			+ ", formatted=" + isFormatted() + ")";
	} 
	
	//******************************************************
	//*                 Copying the string
	//******************************************************
	
	/**
	 * Returns a copy of the attributed string.
	 */
	public function copyWithZone():NSObject {
		return (new NSAttributedString()).initWithAttributedString(this);
	}
	
	//******************************************************
	//*           Retrieving character information
	//******************************************************
	
	/**
	 * <p>Returns the character contents of the receiver as a String object.</p>
	 */
	public function string():String {
		if (m_string == null) {
			return _getNonHTMLText();
		}
		return m_string;
	}
	
	/**
	 * Returns the formatted (ie, HTML) representation of this attributed
	 * string.
	 */
	public function htmlString():String {
		if (m_string==null) {
			return m_htmlString;
		} else {
			return m_string;
		}
	}
	
	/**
	 * Returns the length of the receiver’s string object.
	 */
	public function length():Number {
		return m_string.length;
	}
	
	/**
	 * Returns <code>true</code> if this string has been formatted, or
	 * <code>false</code> otherwise.
	 */
	public function isFormatted():Boolean {
		return m_htmlString != null ? true:false;
	}	

	//******************************************************
	//*          Retrieving attribute information
	//******************************************************
	
	/**
	 * <p>Returns the attributes for the character at a given index.</p>
	 * 
	 * <p>If <code>calculateRange</code> is <code>true</code>, the attribute
	 * dictionary will contain an additional entry with a key of
	 * {@link #ASEffectiveRangeAttributeName}. The entry's value is an
	 * <code>NSRange</code> instance representing the sequential string of
	 * text to which the string styling attributes at <code>index</code>
	 * apply.</p>
	 * 
	 * <p>Raises an exception if <code>index</code> is out of bounds.</p>
	 * 
	 * <p>Please note that this method differs from Cocoa because it returns
	 * the effective range as part of the attributes dictionary instead of
	 * assigning the range value to a pointer argument.</p>
	 * 
	 * @see #attributeAtIndex()
	 */
	public function attributesAtIndexEffectiveRange(index:Number,
			calculateRange:Boolean):NSDictionary {
		return attributesAtIndexLongestEffectiveRangeInRange(index, 
			calculateRange, null);
	}

	/**
	 * <p>Returns the attributes for the character at a given index.</p>
	 * 
	 * <p>If <code>calculateRange</code> is <code>true</code>, the attribute
	 * dictionary will contain an additional entry with a key of
	 * {@link #ASEffectiveRangeAttributeName}. The entry's value is an
	 * <code>NSRange</code> instance representing the sequential string of
	 * text to which the string styling attributes at <code>index</code>
	 * apply.</p>
	 * 
	 * <p><code>rangeLimit</code> is the range over which to search for 
	 * continuous presence of the attributes at <code>index</code>. This value 
	 * must not exceed the bounds of the receiver. This argument has no
	 * effect if <code>calculateRange</code> is <code>false</code> or
	 * <code>null</code>.</p>
	 * 
	 * <p>If <code>rangeLimit</code> is <code>null</code>, the entire length
	 * of the string will be searched.</p>
	 * 
	 * <p>Raises an exception if <code>index</code> or <code>rangeLimit</code> 
	 * is out of bounds.</p>
	 * 
	 * <p>Please note that this method differs from Cocoa because it returns
	 * the effective range as part of the attributes dictionary instead of
	 * assigning the range value to a pointer argument.</p>
	 * 
	 * @see #attributeAtIndex()
	 */
	public function attributesAtIndexLongestEffectiveRangeInRange(
			index:Number, calculateRange:Boolean, rangeLimit:NSRange):NSDictionary {
		//
		// Default arguments
		//
		if (calculateRange == null) {
			calculateRange = false;
		}
		
		//
		// Get the textfield
		//
		var tf:TextField = _getWorkerTextField();
		tf.htmlText = m_htmlString;
		var strlen:Number = tf.text.length;
		
		//
		// Range check
		//
		if (index < 0 || index >= strlen) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSRange,
				"index at " + index + " is beyond the string length " + strlen,
				null);
			trace(e);
			throw e;
		}
		
		//
		// Get attributes
		//
		var format:TextFormat = tf.getTextFormat(index);
		var atts:NSDictionary = attributesFromTextFormat(format);
		
		//
		// Calculate range if necessary
		//
		if (calculateRange) {
			if (rangeLimit == null) {
				rangeLimit = new NSRange(0, strlen); 
			} else {
				//
				// Ensure range limit is in range
				//
				if (rangeLimit.location < 0 || rangeLimit.location >= strlen
						|| rangeLimit.upperBound() >= strlen) {
					var e:NSException = NSException.exceptionWithNameReasonUserInfo(
						NSException.NSRange,
						"rangeLimit argument (" + rangeLimit + ") is out of bounds",
						null);
					trace(e);
					throw e;
				}
			}
			
			// TODO calc range
		}
				
		return atts;	
	}
	
	/**
	 * <p>Returns the value for an attribute with a given name of the character 
	 * at a given index.</p>
	 * 
	 * <p>Raises an exception if <code>index</code> is out of bounds.</p>
	 * 
	 * @see #attributesAtIndexEffectiveRange()
	 */
	public function attributeAtIndex(attributeName:String, index:Number):Object {
		return attributesAtIndexEffectiveRange(index, false).objectForKey(
			attributeName);
	}
	
	//******************************************************
	//*               Changing attributes
	//******************************************************
	
	/**
	 * <p>Sets the attributes for the characters in the specified range to the 
	 * specified attributes.</p>
	 * 
	 * <p>Raises an exception if <code>range</code> is out of bounds or if
	 * <code>attributes</code> is <code>null</code>.</p>
	 * 
	 * @see #addAttributesRange()
	 * @see #removeAttributeRange()
	 */
	public function setAttributesRange(attributes:NSDictionary, range:NSRange):Void {
		// TODO figure out how to clear existing formats in range
		addAttributesRange(attributes, range);
	}
	
	/**
	 * <p>Adds an attribute with the given name and value to the characters in 
	 * the specified range.</p>
	 * 
	 * <p>Raises an exception if <code>range</code> is out of bounds or if
	 * <code>name</code> or <code>value</code> is <code>null</code>.</p>
	 * 
	 * @see #addAttributesRange()
	 * @see #removeAttributeRange()
	 */
	public function addAttributeValueRange(name:String, value:Object,
			range:NSRange):Void {
		//
		// Validate args
		//
		if (name == null || value == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"name and value arguments cannot be null",
				null);
			trace(e);
			throw e;			
		}
		addAttributesRange(
			NSDictionary.dictionaryWithObjectForKey(value, name), range);
	}
	
	/**
	 * <p>Adds the given collection of attributes to the characters in the 
	 * specified range.</p>
	 * 
	 * <p>Raises an exception if <code>range</code> is out of bounds or if
	 * <code>attributes</code> is <code>null</code>.</p>
	 * 
	 * @see #setAttributesRange()
	 * @see #removeAttributeRange()
	 */
	public function addAttributesRange(attributes:NSDictionary, range:NSRange):Void {
		var tf:TextField = _getWorkerTextField();
		tf.htmlText = m_htmlString;
		var strlen:Number = tf.text.length;
		
		//
		// Validate args
		//
		if (attributes == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"attributes argument cannot be null",
				null);
			trace(e);
			throw e;			
		}
		
		if (range.location < 0 || range.location >= strlen
				|| range.upperBound() >= strlen) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSRange,
				"range argument (" + range + ") is out of bounds",
				null);
			trace(e);
			throw e;
		}
		
		//
		// Generate and apply text format
		//
		var format:TextFormat = textFormatFromAttributes(attributes);
		tf.setTextFormat(range.location, range.location + range.length, format);
	}
	
	/**
	 * <p>Removes the named attribute from the characters in the specified 
	 * range.</p>
	 * 
	 * <p>Raises an exception if any part of <code>range</code> lies beyond the
	 * end of the receiver’s characters.</p>
	 * 
	 * @see #addAttributeValueRange()
	 * @see #addAttributesRange()
	 */
	public function removeAttributeRange(name:String, range:NSRange):Void {
		// TODO
	}
	
	//******************************************************
	//*           Comparing attributed strings
	//******************************************************
	
	/**
	 * <p>Returns a Boolean value that indicates whether the receiver is equal 
	 * to another given attributed string.</p>
	 * 
	 * <p>Returns <code>true</code> if the strings are equal, or 
	 * <code>false</code> otherwise.</p>
	 * 
	 * @see #isEqual()
	 */
	public function isEqualToAttributedString(other:NSAttributedString):Boolean {
		return m_htmlString == other.m_htmlString;
	}
	
	/**
	 * <p>If <code>obj</code> is an attributed string, this method calls
	 * {@link #isEqualToAttributedString()} internally. Otherwise, 
	 * <code>false</code> is returned.</p>
	 * 
	 * @see #isEqualToAttributedString()
	 */
	public function isEqual(obj:NSObject):Boolean {
		return (obj instanceof NSAttributedString) 
			? isEqualToAttributedString(NSAttributedString(obj)) 
			: false;
	}
	
	//******************************************************
	//*                Helper methods
	//******************************************************
	
	/**
	 * Returns the non-html text of the attributed string.
	 */
	private function _getNonHTMLText():String {
		var tf:TextField = _getWorkerTextField();
		tf.htmlText = m_htmlString;
		return tf.text;
	}

	/**
	 * Returns the attributed string worker textfield, which is used to
	 * move back and forth between HTML and attribute dictionary 
	 * representations.
	 */
	private function _getWorkerTextField():TextField {
		var tf:TextField = _root.m_attributedString;

		if (tf == undefined) {
			_root.createTextField("m_attributedString", -16383, 0, 0, 1000, 100);
			tf = _root.m_attributedString;
			tf._visible = false;
			tf.html = true;
		}
		
		return tf;		
	}
	
	public static function attributedStringWithHTML(html:String):NSAttributedString {
		var result:NSAttributedString = new NSAttributedString();
		result.initWithHTML(html);
		return result;
	}
	
	//******************************************************
	//*         Textformat-Attributes conversion
	//******************************************************
	
	/**
	 * <p>Converts a dictionary of string attributes into an equivalent text 
	 * format object.</p>
	 * 
	 * <p>The entries that are converted are those mentioned in this class'
	 * constants section.</p>
	 */
	public static function textFormatFromAttributes(attributes:NSDictionary):TextFormat {
		//
		// Extract attributes
		//
		var theme:ASThemeProtocol = ASTheme.current();
		var format:TextFormat = null;
		var font:NSFont = NSFont(attributes.objectForKey(NSFontAttributeName));
		var color:NSColor = NSColor(attributes.objectForKey(NSForegroundColorAttributeName));
		var kernObj:Object = attributes.objectForKey(NSKernAttributeName);
		var kern:Boolean = kernObj != null ? Boolean(kernObj) : null;
		var letSpace:Number = Number(attributes.objectForKey(NSLetterSpacingAttributeName));
		var link:Object = attributes.objectForKey(NSLinkAttributeName);
		var para:NSParagraphStyle = NSParagraphStyle(attributes.objectForKey(NSParagraphStyleAttributeName));
		var underlineObj:Object = attributes.objectForKey(NSUnderlineStyleAttributeName);
		var underline:Boolean = underlineObj != null ? Boolean(underlineObj) : null;
		
		//
		// Generate default values if necessary
		//
		if (font == null) {
			font = theme.systemFontOfSize(0); // theme font, default size
		}
		if (color == null) {
			color = ASColors.blackColor();
		}
		if (kern == null) {
			kern = false;
		}
		if (isNaN(letSpace)) {
			letSpace = 0;
		}
		if (para == null) {
			para = theme.defaultParagraphStyle();
		}
		if (underline == null) {
			underline = false;
		}
		
		//
		// Create the text format
		//
		format = font.textFormatWithAlignment(para.alignment());
		format.color = color.value;
		format.kerning = kern;
		format.letterSpacing = letSpace;
		format.underline = underline;
		format.indent = para.firstLineHeadIndent();
		format.leading = para.lineSpacing();
		format.tabStops = para.tabStops().internalList();
		
		// TODO alpha
		// TODO italics
		// TODO links
		// TODO line break style
		
		return format;
	}
	
	/**
	 * <p>Converts a text format object into an equivalent dictionary of string 
	 * attributes.</p>
	 * 
	 * <p>The entries that are converted are those mentioned in this class'
	 * constants section.</p>
	 */
	public static function attributesFromTextFormat(format:TextFormat):NSDictionary {
		//
		// Build dictionary
		//
		var atts:NSDictionary = NSDictionary.dictionary();
		
		//
		// Font
		//
		if (format.font != null && format.size != null && format.bold != null) {
			var fnt:NSFont = NSFont.fontWithNameSizeBold(format.font, format.size, format.bold);
			atts.setObjectForKey(fnt, NSFontAttributeName);
		}
		
		//
		// Color
		//
		if (format.color != null) {
			atts.setObjectForKey(new NSColor(format.color), NSForegroundColorAttributeName);
		}
		
		//
		// Kerning
		//
		if (format.kerning != null) {
			atts.setObjectForKey(format.kerning, NSKernAttributeName);
		}
		
		//
		// Letter spacing
		//
		if (format.letterSpacing != null) {
			atts.setObjectForKey(format.letterSpacing, NSLetterSpacingAttributeName);
		}
		
		//
		// Underlines
		//
		if (format.underline != null) {
			atts.setObjectForKey(format.underline, NSUnderlineStyleAttributeName);
		}
		
		//
		// Paragraph
		//
		if (format.align != null 
				&& format.indent != null 
				&& format.tabStops != null 
				&& format.leading != null) {
			atts.setObjectForKey(new NSParagraphStyle(
				NSTextAlignment.constantForString(format.align),
				format.indent,
				NSArray.arrayWithArray(format.tabStops),
				format.leading,
				null), // FIXME this shouldn't be null
				NSParagraphStyleAttributeName
			);
		}
		
		// TODO alpha
		// TODO italics
		// TODO links
		// TODO line break style
		
		return atts;
	}
	
	//******************************************************
	//*             Unsupported attributes
	//******************************************************
	
	//! NOT SUPPORTED NSAttachmentAttributeName
	//! NOT SUPPORTED NSBackgroundColorAttributeName
	//! NOT SUPPORTED NSBaselineOffsetAttributeName
	//! NOT SUPPORTED NSCursorAttributeName
	//! NOT SUPPORTED NSExpansionAttributeName
	//! NOT SUPPORTED NSLigatureAttributeName
	//! NOT SUPPORTED NSObliquenessAttributeName
	//! NOT SUPPORTED NSShadowAttributeName
	//! NOT SUPPORTED NSStrikethroughColorAttributeName
	//! NOT SUPPORTED NSStrikethroughStyleAttributeName
	//! NOT SUPPORTED NSStrokeColorAttributeName
	//! NOT SUPPORTED NSStrokeWidthAttributeName
	//! NOT SUPPORTED NSSuperscriptAttributeName
	//! NOT SUPPORTED NSToolTipAttributeName
	//! NOT SUPPORTED NSUnderlineColorAttributeName
}