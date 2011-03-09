/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.constants.NSWritingDirection;
import org.actionstep.NSColor;
import org.actionstep.NSException;
import org.actionstep.NSFont;
import org.actionstep.NSRange;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTextView;
import org.actionstep.NSView;

/**
 * <p>NSText declares the most general programmatic interface for objects that 
 * manage text. You usually use instances of its subclass, 
 * {@link NSTextView}.</p>
 * 
 * <p>{@link NSTextView} extends the interface declared by NSText and provides 
 * much more sophisticated functionality than that declared in NSText.</p>
 * 
 * <p>NSText initialization creates an instance of a concrete subclass, such as 
 * {@link NSTextView}. Instances of any of these classes are generically called
 * text objects.</p>
 * 
 * <p>TODO Think about undo support.</p>
 * 
 * @author Rich Kilmer
 * @author Scott Hyndman
 */
class org.actionstep.NSText extends NSView {
  
	//******************************************************
	//*                 Construction
	//******************************************************
  
	/**
	 * Creates a new instance of the <code>NSText</code> class.
	 */
	public function NSText() {
	}
	
	/**
	 * <p>Initializes NSText with a frame of <code>aRect</code>.</p>
	 * 
	 * <p>If this method is called directly (and not by a subclass), a concrete
	 * NSText implementation is returned.</p>
	 */
	public function initWithFrame(aRect:NSRect):NSText {
		if (getClass() != NSText) {
			super.initWithFrame(aRect);
			return this;
		} else {
			return (new NSTextView()).initWithFrame(aRect);
		}
	}
		
	//******************************************************															 
	//*               Getting the characters
	//******************************************************

	/**
	 * Returns the characters of the receiver’s text.
	 * 
	 * @see #setString()
	 */
	public function string():String {
		var e:NSException = makeException(); trace(e); e.raise();
		return null;
	}

	//******************************************************															 
	//*           Setting graphics attributes
	//******************************************************

	/**
	 * Sets the receiver’s background color to <code>aColor</code>.
	 * 
	 * @see #backgroundColor()
	 * @see #setDrawsBackground()
	 */
	public function setBackgroundColor(aColor:NSColor) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	/**
	 * Returns the receiver’s background color.
	 * 
	 * @see #setBackgroundColor()
	 * @see #drawsBackgroundColor()
	 */
	public function backgroundColor():NSColor {
		var e:NSException = makeException(); trace(e); e.raise();
		return null;
	}

	/**
	 * <p>Controls whether the receiver draws its background.</p>
	 * 
	 * <p>If <code>flag</code> is <code>true</code>, the receiver fills its
	 * background with the background color.</p>
	 * 
	 * @see #drawsBackground()
	 */
	public function setDrawsBackground(flag:Boolean) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	/**
	 * <p>Returns <code>true</code> if the receiver draws its background, 
	 * <code>false</code> if it doesn’t.</p>
	 * 
	 * @see #setDrawsBackground()
	 */
	public function drawsBackground():Boolean {
		var e:NSException = makeException(); trace(e); e.raise();
		return false;
	}

	//******************************************************															 
	//*           Setting behavioral attributes
	//******************************************************

	/**
	 * <p>Controls whether the receiver allows the user to edit its text.</p>
	 * 
	 * <p>If <code>flag</code> is <code>true</code>, the receiver allows the 
	 * user to edit text and attributes; if <code>flag</code> is 
	 * <code>false</code>, it doesn’t. You can change the receiver’s text 
	 * programmatically regardless of this setting. If the receiver is made 
	 * editable, it’s also made selectable. NSText objects are by default 
	 * editable.</p>
	 * 
	 * @see #isEditable()
	 * @see #setSelectable()
	 */
	public function setEditable(flag:Boolean) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	/**
	 * <p>Returns <code>true</code> if the receiver allows the user to edit text,
	 * <code>false</code> if it doesn’t.</p>
	 * 
	 * <p>You can change the receiver’s text programmatically regardless of this 
	 * setting.</p>
	 * 
	 * <p>If the receiver is editable, it’s also selectable.</p>
	 * 
	 * @see #setEditable()
	 * @see #isSelectable()
	 */
	public function isEditable():Boolean {
		var e:NSException = makeException(); trace(e); e.raise();
		return false;
	}

	/**
	 * <p>Controls whether the receiver allows the user to select its text.</p>
	 * 
	 * <p>If <code>flag</code> is <code>true</code>, the receiver allows the 
	 * user to select text; if <code>flag</code> is <code>false</code>, it 
	 * doesn’t. You can set selections programmatically regardless of this 
	 * setting. If the receiver is made not selectable, it’s also made not 
	 * editable. NSText objects are by default editable and selectable.</p>
	 * 
	 * @see #isSelectable()
	 * @see #setEditable()
	 */
	public function setSelectable(flag:Boolean) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	/**
	 * <p>Returns <code>true</code> if the receiver allows the user to select 
	 * text, <code>false</code> if it doesn’t.</p>
	 * 
	 * @see #setSelectable()
	 * @see #isEditable()
	 */
	public function isSelectable():Boolean {
		var e:NSException = makeException(); trace(e); e.raise();
		return false;
	}

	/**
	 * <p>Controls whether the receiver interprets Tab, Shift-Tab, and Return 
	 * (Enter) as cues to end editing and possibly to change the first 
	 * responder.</p>
	 * 
	 * <p>If <code>flag</code> is <code>true</code>, it does; if 
	 * <code>flag</code> is <code>false</code>, it doesn’t, instead accepting 
	 * these characters as text input. See the {@link org.actionstep.NSWindow}
	 * class specification for more information on field editors. By default, 
	 * NSText objects don’t behave as field editors.</p>
	 * 
	 * @see #isFieldEditor()
	 */
	public function setFieldEditor(flag:Boolean) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	/**
	 * <p>Returns <code>true</code> if the receiver interprets Tab, Shift-Tab, 
	 * and Return (Enter) as cues to end editing and possibly to change the 
	 * first responder; <code>false</code> if it accepts them as text input.</p>
	 * 
	 * @see #setFieldEditor()
	 */
	public function isFieldEditor():Boolean {
		var e:NSException = makeException(); trace(e); e.raise();
		return false;
	}

	public function setRichText(value:Boolean) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function isRichText():Boolean {
		var e:NSException = makeException(); trace(e); e.raise();
		return false;
	}
	
	public function setImportsGraphics(value:Boolean) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function importsGraphics():Boolean {
		var e:NSException = makeException(); trace(e); e.raise();
		return false;
	}
	
	//******************************************************															 
	//*            Using the Font panel and menu
	//******************************************************
	
	public function setUsesFontPanel(value:Boolean) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function usesFontPanel():Boolean {
		var e:NSException = makeException(); trace(e); e.raise();
		return false;
	}
	
	//******************************************************															 
	//*                  Using the ruler
	//******************************************************
	
	public function toggleRuler(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function isRulerVisible():Boolean {
		var e:NSException = makeException(); trace(e); e.raise();
		return false;
	}
	
	//******************************************************															 
	//*              Changing the selection
	//******************************************************
	
	public function setSelectedRange(value:NSRange) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	public function selectedRange():NSRange {
		var e:NSException = makeException(); trace(e); e.raise();
		return NSRange.NotFoundRange;
	}
	
	//******************************************************															 
	//*                 Replacing text
	//******************************************************
	
	public function replaceCharactersInRangeWithString(range:NSRange, string:String) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	public function setString(string:String) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	//******************************************************															 
	//*            Action methods for editing
	//******************************************************
	
	public function selectAll(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function copy(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function cut(sender:Object) {
		copy(sender);
		clear(sender);
	}
	
	public function paste(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function copyFont(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function pasteFont(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function copyRuler(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function pasteRuler(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	/**
	* Remove all text from the text editor but do not place it on the clipboard
	* NOTE: Changed from the Cocoa delete method because delete is a keyword in ActionScript
	*
	*/
	public function clear(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	//******************************************************															 
	//*                Changing the font
	//******************************************************
	
	public function changeFont(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function setFont(value:NSFont) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	public function font():NSFont {
		var e:NSException = makeException(); trace(e); e.raise();
		return null;
	}

	public function setFontRange(value:NSFont, range:NSRange) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	//******************************************************															 
	//*              Setting text alignment
	//******************************************************
	
	public function setAlignment(value:NSTextAlignment) {
		var e:NSException = makeException(); trace(e); e.raise();
		
	}
	
	public function alignCenter(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function alignLeft(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	public function alignRight(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	public function alignment():NSTextAlignment {
		var e:NSException = makeException(); trace(e); e.raise();
		return NSTextAlignment.NSLeftTextAlignment;
	}
	
	//******************************************************															 
	//*                Setting text color
	//******************************************************
	
	public function setTextColor(value:NSColor) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function setTextColorRange(value:NSColor, range:NSRange) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	public function textColor():NSColor {
		var e:NSException = makeException(); trace(e); e.raise();
		return null;
	}

	//******************************************************															 
	//*                Writing direction
	//******************************************************
	
	public function writingDirection():NSWritingDirection {
		var e:NSException = makeException(); trace(e); e.raise();
		return NSWritingDirection.NSWritingDirectionNatural;
	}

	public function setWritingDirection(direction:NSWritingDirection) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	//******************************************************															 
	//*      Setting superscripting and subscripting
	//******************************************************
	
	public function superscript(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function subscript(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function unscript(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	//******************************************************															 
	//*                 Underlining text
	//******************************************************

	public function underline(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	//******************************************************															 
	//*                 Constraining size
	//******************************************************
	
	public function setMaxSize(size:NSSize) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	public function maxSize():NSSize {
		var e:NSException = makeException(); trace(e); e.raise();
		return NSSize.ZeroSize;
	}

	public function setMinSize(size:NSSize) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function minSize():NSSize {
		var e:NSException = makeException(); trace(e); e.raise();
		return NSSize.ZeroSize;
	}

	public function setVerticallyResizable(value:Boolean) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function isVerticallyResizable():Boolean {
		var e:NSException = makeException(); trace(e); e.raise();
		return false;
	}	

	public function setHorizontallyResizable(value:Boolean) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function isHorizontallyResizable():Boolean {
		var e:NSException = makeException(); trace(e); e.raise();
		return false;
	}	

	public function sizeToFit() {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	//******************************************************															 
	//*               Checking spelling
	//******************************************************
	
	public function checkSpelling(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}

	public function showGuessPanel(sender:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	//******************************************************															 
	//*                  Scrolling
	//******************************************************
	
	public function scrollRangeToVisible(range:NSRange) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	//******************************************************															 
	//*              Setting the delegate
	//******************************************************
	
	/**
	 * <p>For information on what methods a text delegate can implement, see the
	 * {@link org.actionstep.text.ASTextDelegate} interface.</p>
	 */
	public function setDelegate(delegate:Object) {
		var e:NSException = makeException(); trace(e); e.raise();
	}
	
	/**
	 * <p>For information on what methods a text delegate can implement, see the
	 * {@link org.actionstep.text.ASTextDelegate} interface.</p>
	 */
	public function delegate():Object {
		var e:NSException = makeException(); trace(e); e.raise();
		return null;
	}
	
	//******************************************************
	//*               Throwing exceptions
	//******************************************************
	
	private function makeException():NSException {
		return NSException.exceptionWithNameReasonUserInfo("SubclassResponsibility", 
			"Subclass must implement", null);
	}
	
	//******************************************************
	//*                 Notifications
	//******************************************************
	
	public static var NSTextDidBeginEditingNotification:Number 
		= ASUtils.intern("NSTextDidBeginEditingNotification");
	public static var NSTextDidEndEditingNotification:Number 
		= ASUtils.intern("NSTextDidEndEditingNotification");
	public static var NSTextDidChangeNotification:Number 
		= ASUtils.intern("NSTextDidChangeNotification");
}