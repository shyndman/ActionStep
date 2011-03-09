/* See LICENSE for copyright and terms of use */

import org.actionstep.ASFieldEditingProtocol;
import org.actionstep.ASFieldEditor;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.constants.NSWritingDirection;
import org.actionstep.NSActionCell;
import org.actionstep.NSFont;
import org.actionstep.NSRect;
import org.actionstep.NSTextFieldCell;
import org.actionstep.NSView;

/**
 * The NSFormCell class is used to implement text entry fields in a form. The
 * left part of an NSFormCell is a title. The right part is an editable text
 * entry field.
 *
 * NSFormCell implements the user interface of NSForm.
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSFormCell extends NSActionCell 
		implements ASFieldEditingProtocol {
			
	//******************************************************
	//*                     Constants
	//******************************************************
		
	public static var TITLE_PADDING:Number = 4;
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_titlecell:NSTextFieldCell;
	private var m_inputcell:NSTextFieldCell;
	private var m_titlewidth:Number;
	private var m_shouldCalculateWidth:Boolean;
	private var m_placeholderString:String;
	
	//******************************************************
	//*                     Construction
	//******************************************************
	
	/**
	 * Creates a new instance of <code>NSFormCell</code>.
	 */
	public function NSFormCell() {
		m_selectable = true;
		m_editable = true;
		m_shouldCalculateWidth = true;
		m_placeholderString = null;
	}
	
	/**
	 * Initializes a newly allocated <code>NSFormCell</code>. Its title is set 
	 * to <code>aString</code>. The contents of its text entry field are set to 
	 * the empty string (<code>""</code>). The font for both title and text is 
	 * the user’s chosen system font in 12.0 point, and the text area is drawn 
	 * with a bezel. This method is the designated initializer for 
	 * <code>NSFormCell</code>.
	 *
	 * Returns an initialized object.
	 */
	public function initTextCell(aString:String):NSFormCell {
		//
		// Create child cells
		//
		m_titlecell = (new NSTextFieldCell()).initTextCell("Field:");
		m_titlecell.setEditable(false);
		m_titlecell.setDrawsBackground(false);
		m_titlecell.setAlignment(NSTextAlignment.NSRightTextAlignment);
		m_titlecell.setFont(NSFont.systemFontOfSize(12));
		calculateTitleWidth();
		
		m_inputcell = (new NSTextFieldCell()).initTextCell("");
		m_inputcell.setEditable(true);
		m_inputcell.setDrawsBackground(true);
		m_inputcell.setBezeled(true);
		m_inputcell.setFont(NSFont.systemFontOfSize(12));
		
		//
		// Set title
		//
		if (aString != null) {
			setTitle(aString);
		}
		
		return this;
	}
	
	//******************************************************
	//*                 Releasing the object
	//******************************************************
	
	/**
	 * @see org.actionstep.NSCell#release()
	 */
	public function release():Boolean {
		m_inputcell.release();
		m_titlecell.release();
		return super.release();
	}
	
	//******************************************************
	//*                Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the form cell.
	 */
	public function description():String {
		return "NSFormCell(title=" + title() + ", isBezeled=" + isBezeled() +
			", isBordered=" + isBordered() + ", titleFont=" + titleFont() + ")";
	}
	
	//******************************************************
	//*            Asking about a cell’s title
	//******************************************************
	
	//! TODO attributedTitle
	
	/**
	 * Returns the receiver’s title. The default title is <code>"Field:"</code>.
	 */
	public function title():String {
		return m_titlecell.stringValue();
	}
	
	/**
	 * Returns the alignment of the title. The alignment can be one of the
	 * following: <code>NSLeftTextAlignment</code>, 
	 * <code>NSCenterTextAlignment</code>, or <code>NSRightTextAlignment</code> 
	 * (the default).
	 */
	public function titleAlignment():NSTextAlignment {
		return m_titlecell.alignment();
	}
	
	/**
	 * Returns the default writing direction used to render the form cell’s
	 * title.
	 */
	public function titleBaseWritingDirection():NSWritingDirection {
		//! TODO what should I do here?
		return null;
	}
	
	/**
	 * Returns the font used to draw the receiver’s title.
	 */
	public function titleFont():NSFont {
		return m_titlecell.font();
	}
	
	/**
	 * Returns the width (in pixels) of the title field. If you specified the
	 * width using <code>#setTitleWidth()</code>, this method returns the value 
	 * you chose. Otherwise, it returns the width calculated automatically by 
	 * ActionStep.
	 */
	public function titleWidth():Number {
		return m_titlewidth;
	}
	
	//******************************************************
	//*              Changing the cell’s title
	//******************************************************
	
	//! TODO setAttributedTitle
	
	/**
	 * Sets the receiver’s title to aString.
	 */
	public function setTitle(aString:String):Void {
		m_titlecell.setStringValue(aString);
		
		if (m_shouldCalculateWidth) {
			calculateTitleWidth();
		}
	}
	
	/**
	 * Sets the alignment of the title. alignment can be one of three
	 * constants: NSLeftTextAlignment, NSRightTextAlignment, or
	 * NSCenterTextAlignment.
	 */
	public function setTitleAlignment(alignment:NSTextAlignment):Void {
		m_titlecell.setAlignment(alignment);
	}
	
	/**
	 * Sets the default writing direction used to render the form cell’s title.
	 */
	public function setTitleBaseWritingDirection(
			writingDirection:NSWritingDirection):Void {
		//! TODO What should I do here?
	}
	
	/**
	 * Sets the title’s font to font.
	 */
	public function setTitleFont(font:NSFont):Void {
		m_titlecell.setFont(font);
	}
	
	/**
	 * Sets the width in pixels. You usually won’t need to invoke this method,
	 * because ActionStep automatically sets the title width whenever
	 * the title changes. If, however, the automatic width doesn’t suit your
	 * needs, you can use <code>#setTitleWidth()</code> to set the width 
	 * explicitly.
	 *
	 * Once you have set the width this way, ActionStep stops setting the width 
	 * automatically; you will need to invoke <code>#setTitleWidth()</code> 
	 * every time the title changes. If you want ActionStep to resume
	 * automatic width assignments, invoke <code>#setTitleWidth()</code> with a 
	 * negative width value.
	 */
	public function setTitleWidth(width:Number):Void {
		if (m_titlewidth < 0) {
			m_shouldCalculateWidth = false;
			calculateTitleWidth();
			return;
		}
		
		m_titlewidth = width;
		m_shouldCalculateWidth = true;
	}
	
	//******************************************************
	//*            Setting a keyboard equivalent
	//******************************************************
	
	/**
	 * Sets the cell title and a single mnemonic character. 
	 */ 
	public function setTitleWithMnemonic(titleWithAmpersand:String):Void {
		//
		// Extract mnemonic character
		//
		var mnem:String = titleWithAmpersand.substr(titleWithAmpersand.indexOf("&") + 1, 1);
		
		//! TODO do something here to register mnemonic
		
		//
		// Remove mnemonic character
		//
		titleWithAmpersand = titleWithAmpersand.split("&").join("");
		setTitle(titleWithAmpersand);
	}
	
	//******************************************************
	//*           Asking about placeholder values
	//******************************************************
	
	//! TODO - (NSString*)placeholderAttributedString
	//! TODO - (void)setPlaceholderAttributedString:(NSString*)string
	
	/**
	 * Returns the cell’s plain text placeholder string.
	 */
	public function placeholderString():String {
		return m_placeholderString;
	}
	
	/**
	 * Sets the placeholder text for the cell as a plain text string.
	 */
	public function setPlaceholderString(string:String):Void {
		m_placeholderString = string;
	}	
	
	//******************************************************
	//*               Overridden cell stuff
	//******************************************************
	
	/**
	 * @see org.actionstep.NSCell#setBezeled()
	 */
	public function setBezeled(flag:Boolean) {
		m_inputcell.isBezeled(flag);
	}
  
	/**
	 * @see org.actionstep.NSCell#isBezeled()
	 */
	public function isBezeled():Boolean {
		return m_inputcell.isBezeled();
	}
  
	/**
	 * @see org.actionstep.NSCell#setBordered()
	 */
	public function setBordered(flag:Boolean) { 
		m_inputcell.setBordered(flag);
	}
  
	/**
	 * @see org.actionstep.NSCell#isBordered()
	 */
	public function isBordered():Boolean {
		return m_inputcell.isBordered();
	}
	
	/**
	 * @see org.actionstep.NSCell#setObjectValue()
	 */
	public function setObjectValue(value:Object):Void {
		super.setObjectValue(value);
		m_inputcell.setObjectValue(value);
	}
	
	/**
	 * @see org.actionstep.NSCell#objectValue()
	 */
	public function objectValue():Object {
		return m_inputcell.objectValue();
	}
	
	/**
	 * Returns <code>true</code> if the title is empty and an opaque bezel is 
	 * set, otherwise <code>false</code> is returned.
	 */
	public function isOpaque():Boolean {
		return title().length == 0; //! TODO && opaque bezel
	}
	
	//******************************************************															 
	//*				     Field editing
	//******************************************************

	/**
	 * @see org.actionstep.ASFieldEditingProtocol#beginEditingWithDelegate()
	 */	
	public function beginEditingWithDelegate(delegate:Object):ASFieldEditor {
		trace("begin editing");
		
		if (!isSelectable()) {
			return null;
		}
		
		var tf:TextField = m_inputcell["m_textField"];
		if (tf != null && tf._parent != undefined) {
			tf.text = stringValue();
			var editor:ASFieldEditor = ASFieldEditor.startEditing(this, 
				delegate, tf);
			return editor;
		}
		
		return null;
	}
	
	/**
	 * @see org.actionstep.ASFieldEditingProtocol#endEditingWithDelegate()
	 */
	public function endEditingWithDelegate(delegate:Object):Void {
		trace("end editing");
		
		ASFieldEditor.endEditing(delegate);
	}
	
	//******************************************************
	//*                 Drawing the cell
	//******************************************************
	
	/**
	 * Draws the cell in the view given the frame which defines
	 * the area in which to draw.
	 */
	public function drawWithFrameInView(cellFrame:NSRect, inView:NSView):Void
	{
		var titleFrame:NSRect = cellFrame.clone();
		titleFrame.size.width = m_titlewidth;
		
		var inputFrame:NSRect = cellFrame.clone();
		inputFrame.size.width -= (m_titlewidth + 1);
		inputFrame.origin.x += m_titlewidth;
		
		//
		// Tell the cells to draw in their respective areas
		//
		m_titlecell.drawWithFrameInView(titleFrame, inView);
		m_inputcell.drawWithFrameInView(inputFrame, inView);
	}
  
	//******************************************************
	//*                  Helper methods
	//******************************************************
	
	/**
	 * Calculates and sets the title width based on the current
	 * title string.
	 */
	private function calculateTitleWidth():Void {
		m_titlewidth = m_titlecell.font().getTextExtent(title()).width + TITLE_PADDING;
	}
}
