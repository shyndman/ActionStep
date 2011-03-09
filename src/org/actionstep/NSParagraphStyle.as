/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSLineBreakMode;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSArray;
import org.actionstep.NSCopying;
import org.actionstep.NSObject;
import org.actionstep.themes.ASTheme;

/**
 * <p>NSParagraphStyle encapsulates the paragraph or ruler attributes used by 
 * the <code>NSAttributedString</code> classes. Instances of these classes are 
 * often referred to as paragraph style objects or, when no confusion will 
 * result, paragraph styles.</p>
 * 
 * <p>This class also contains the methods that would ordinarily be seen in
 * <code>NSMutableParagraphStyle</code>.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSParagraphStyle extends NSObject implements NSCopying {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_alignment:NSTextAlignment;
	private var m_indent:Number;
	private var m_tabStops:NSArray;
	private var m_lineSpacing:Number;
	private var m_lineBreakMode:NSLineBreakMode;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSParagraphStyle</code> class.
	 */
	public function NSParagraphStyle(
			alignment:NSTextAlignment,
			indent:Number,
			tabStops:NSArray,
			lineSpacing:Number,
			lineBreakMode:NSLineBreakMode) {
		m_alignment = alignment == null ? NSTextAlignment.NSNaturalTextAlignment
			: alignment;
		m_indent = indent == null ? 0 
			: indent;
		m_tabStops = tabStops == null || tabStops.count() == 0 ? null 
			: NSArray(tabStops.copyWithZone());
		m_lineSpacing = lineSpacing == null ? 0 
			: lineSpacing;
		m_lineBreakMode = lineBreakMode == null ? NSLineBreakMode.NSDefaultLineBreak 
			: lineBreakMode;   
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the NSParagraphStyle instance.
	 */
	public function description():String {
		return "NSParagraphStyle("
			+ "alignment=" + alignment() + ", "
			+ "firstLineHeadIndent=" + firstLineHeadIndent() + ", "
			+ "tabStops=" + tabStops() + ", "
			+ "lineSpacing=" + lineSpacing() + ", "
			+ "lineBreakMode=" + lineBreakMode()
			+ ")";
	}
	
	//******************************************************
	//*                    NSCopying
	//******************************************************
	
	/**
	 * Copies the paragraph style.
	 */
	public function copyWithZone():NSObject {
		return new NSParagraphStyle(m_alignment, m_indent, m_tabStops, 
			m_lineSpacing, m_lineBreakMode);
	}

	//******************************************************
	//*            Accessing style information
	//******************************************************
	
	/**
	 * Returns the text alignment of the receiver.
	 * 
	 * @see #setAlignment()
	 */
	public function alignment():NSTextAlignment {
		return m_alignment;
	}
	
	/**
	 * Sets the text alignment of the receiver to <code>alignment</code>.
	 * 
	 * @see #alignment()
	 */
	public function setAlignment(alignment:NSTextAlignment):Void {
		m_alignment = alignment;
	}
	
	/**
	 * <p>Returns the distance in points from the leading margin of a text 
	 * container to the beginning of the paragraph’s first line.</p>
	 * 
	 * <p>This value is always nonnegative.</p>
	 * 
	 * @see #setFirstLineHeadIndent()
	 */
	public function firstLineHeadIndent():Number {
		return m_indent;
	}
	
	/**
	 * <p>Sets the distance in points from the leading margin of a text 
	 * container to the beginning of the paragraph’s first line to 
	 * <code>value</code>.</p>
	 * 
	 * <p>This value must be nonnegative.</p>
	 * 
	 * @see #firstLineHeadIndent()
	 */
	public function setFirstLineHeadIndent(value:Number):Void {
		m_indent = value;
	}
	
	/**
	 * <p>Returns the Number objects, sorted by location, that define the tab 
	 * stops for the paragraph style.</p>
	 * 
	 * @see #setTabStops()
	 * @see #addTabStop()
	 * @see #removeTabStop()
	 */
	public function tabStops():NSArray {
		return m_tabStops;
	}
	
	/**
	 * <p>Replaces the tab stops in the receiver with <code>tabStops</code>.</p>
	 * 
	 * @see #tabStops()
	 * @see #addTabStop()
	 * @see #removeTabStop()
	 */
	public function setTabStops(tabStops:NSArray):Void {
		m_tabStops = NSArray(tabStops.copyWithZone());
		_sortTabStops();
	}
	
	/**
	 * <p>Adds <code>tabStop</code> to the receiver.</p>
	 * 
	 * @see #tabStops()
	 * @see #setTabStops()
	 * @see #removeTabStop() 
	 */
	public function addTabStop(tabStop:Number):Void {
		if (m_tabStops.containsObject(tabStop)) {
			return;
		}
		
		m_tabStops.addObject(tabStop);
		_sortTabStops();
	}
	
	/**
	 * <p>Removes <code>tabStop</code> from the receiver.</p>
	 * 
	 * @see #tabStops()
	 * @see #setTabStops()
	 * @see #addTabStop() 
	 */
	public function removeTabStop(tabStop:Number):Void {
		m_tabStops.removeObject(tabStop);
	}
	
	/**
	 * <p>Returns the space in points added between lines within the paragraph 
	 * (commonly known as leading).</p>
	 * 
	 * <p>This value can be negative.</p>
	 * 
	 * @see #setLineSpacing()
	 */
	public function lineSpacing():Number {
		return m_lineSpacing;
	}
	
	/**
	 * <p>Sets the space in points added between lines within the paragraph to 
	 * <code>value</code>.</p>
	 * 
	 * <p>This value can be negative.</p>
	 * 
	 * @see #lineSpacing()
	 */
	public function setLineSpacing(value:Number):Void {
		m_lineSpacing = value;
	}
	
	//******************************************************
	//*         Getting line breaking information
	//******************************************************
	
	/**
	 * <p>Returns the mode that should be used to break lines when laying out 
	 * the paragraph’s text.</p>
	 * 
	 * @see #setLineBreakMode()
	 */
	public function lineBreakMode():NSLineBreakMode {
		return m_lineBreakMode;
	}
	
	/**
	 * <p>Sets the mode used to break lines in a layout container to 
	 * <code>mode</code>.</p>
	 * 
	 * @see #lineBreakMode()
	 */
	public function setLineBreakMode(mode:NSLineBreakMode):Void {
		m_lineBreakMode = mode;
	}
	
	//******************************************************
	//*                  Helper methods
	//******************************************************
	
	/**
	 * Sorts the tab stops.
	 */
	private function _sortTabStops():Void {
		m_tabStops.internalList().sort(Array.NUMERIC);
	}
	
	//******************************************************
	//*            Creating an NSParagraphStyle
	//******************************************************
	
	/**
	 * <p>Returns the default paragraph style.</p>
	 * 
	 * <p>Calls {@link org.actionstep.ASThemeProtocol#defaultParagraphStyle()}
	 * internally.</p>
	 */
	public static function defaultParagraphStyle():NSParagraphStyle {
		return ASTheme.current().defaultParagraphStyle();
	}
}