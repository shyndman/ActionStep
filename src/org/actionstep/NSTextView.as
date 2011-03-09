/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASFieldEditor;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSScrollerPart;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.constants.NSTextMovement;
import org.actionstep.constants.NSWritingDirection;
import org.actionstep.NSColor;
import org.actionstep.NSDictionary;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSFont;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSRange;
import org.actionstep.NSRect;
import org.actionstep.NSScroller;
import org.actionstep.NSSize;
import org.actionstep.NSText;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeProtocol;

/**
 * <p>NSTextView is the front-end component of ActionStep's text system. It 
 * displays and manipulates text and adds many features to those defined by its 
 * superclass, {@link NSText}. Many of the methods that you’ll use most 
 * frequently are declared by the superclass; see the NSText class specification
 * for details.</p>
 * 
 * <h1>Class description</h1>
 * 
 * <p>NSTextView is the front-end class to ActionStep's text-handling system. It
 * draws the text and handles user events to select and modify its text. 
 * NSTextView is the principal means to obtain a text object that caters to 
 * almost all needs for displaying and managing text at the user interface 
 * level. While NSTextView is a subclass of {@link NSText}—which declares the 
 * most general Cocoa interface to the text system—NSTextView adds major 
 * features beyond the capabilities of NSText.</p>
 * 
 * <h2>About Delegate Methods</h2>
 * 
 * <p>NSTextView communicates with its delegate through methods declared both by
 * NSTextView and by its superclass, NSText. See the NSText class specification
 * for those other delegate methods. Note that all delegation messages come from
 * the first text view.</p>
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSTextView extends NSText {

	//******************************************************															 
	//*	                 Member variables
	//******************************************************
	
	private var m_textField:TextField;
	private var m_textFormat:TextFormat;
	private var m_editor:ASFieldEditor;
	private var m_font:NSFont;
	private var m_textColor:NSColor;
	private var m_alignment:NSTextAlignment;
	private var m_internalString:String;
	private var m_backgroundColor:NSColor;
	private var m_drawsBackground:Boolean;
	private var m_editable:Boolean;
	private var m_selectable:Boolean;
	private var m_richText:Boolean;
	private var m_importsGraphics:Boolean;
	private var m_usesFontPanel:Boolean;
	private var m_selectedRange:NSRange;
	private var m_writingDirection:NSWritingDirection;
	private var m_maxSize:NSSize;
	private var m_minSize:NSSize;
	private var m_verticallyResizable:Boolean;
	private var m_horizontallyResizable:Boolean;
	private var m_delegate:Object;
	private var m_notificationCenter:NSNotificationCenter;
	private var m_showsFirstResponder:Boolean;
	
	//
	// Stuff to emulate a scrollview
	//
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
	//*	                   Construction
	//******************************************************
	
	/**
	 * Contructs a new instance of <code>NSTextView</code>.
	 */
	public function NSTextView() {
		m_textField = null;
		m_textFormat = null;
		m_textColor = ASColors.blackColor();
		m_font = NSFont.systemFontOfSize();
		m_alignment = NSTextAlignment.NSLeftTextAlignment;
		m_internalString = "";
		m_drawsBackground = true;
		m_backgroundColor = ASColors.whiteColor();
		m_editable = true;
		m_selectable = true;
		m_richText = false;
		m_importsGraphics = false;
		m_usesFontPanel = false;
		m_showsFirstResponder = false;
		m_writingDirection = NSWritingDirection.NSWritingDirectionNatural;
		m_maxSize = null;
		m_minSize = null;
		m_verticallyResizable = true;
		m_horizontallyResizable = false;
		
		//
		// Scroller stuff
		//
		m_borderType = NSBorderType.NSNoBorder;
		m_hasHorizontalScroller = false;
		m_hasVerticalScroller = false;
		m_autohidesScrollers = false;
		m_autohidesScrollers = false;
		m_horizontalLineScroll = 10;
		m_verticalLineScroll = 1;
		m_horizontalPageScroll = 100;
		m_verticalPageScroll = 5;
	}

	/**
	 * Initializes the text view with a frame of <code>frame</code>.
	 */
	public function initWithFrame(frame:NSRect):NSTextView {
		super.initWithFrame(frame);
		m_notificationCenter = NSNotificationCenter.defaultCenter();
		m_minSize = NSSize.ZeroSize;
		//setPostsFrameChangedNotifications(true);
		return this;
	}
	
	//******************************************************															 
	//*	           Getting the characters
	//******************************************************
	
	public function string():String {
		return m_internalString;
	}

	//******************************************************															 
	//*	         Setting graphics attributes
	//******************************************************

	/**
	 * <p>Sets the receiver’s background color to <code>value</code>.</p>
	 * 
	 * <p>For the background color to be shown, {@link #drawsBackground} must
	 * be true.</p>
	 * 
	 * @see #backgroundColor()
	 */
	public function setBackgroundColor(value:NSColor):Void {
		if (m_backgroundColor != value) {
			m_backgroundColor = value;
			setNeedsDisplay(true);
		}
	}

	/**
	 * Returns the receiver’s background color.
	 * 
	 * @see #setBackgroundColor()
	 */
	public function backgroundColor():NSColor {
		return m_backgroundColor;
	}

	/**
	 * Sets whether the receiver draws its background.
	 * 
	 * @see #drawsBackground()
	 */
	public function setDrawsBackground(value:Boolean):Void {
		if (m_drawsBackground != value) {
			m_drawsBackground = value;
			setNeedsDisplay(true);
		}
	}

	/**
	 * Returns whether the receiver draws its background.
	 * 
	 * @see #setDrawsBackground()
	 */
	public function drawsBackground():Boolean {
		return m_drawsBackground;
	}

	/**
	 * Sets the border type of the scroll view to <code>value</code>.
	 */
	public function setBorderType(value:NSBorderType):Void {
		m_borderType = value;
		tile();
	}
	
	/**
	 * Returns the border type of the scroll view.
	 */
	public function borderType():NSBorderType {
		return m_borderType;
	}
	
	//******************************************************
	//*                   Inserting text
	//******************************************************
	
	/**
	 * <p>Inserts <code>aString</code> into the receiver’s text at the insertion
	 * point if there is one, otherwise replacing the selection.</p>
	 * 
	 * <p>The inserted text is assigned the current typing attributes.</p>
	 * 
	 * @see #typingAttributes()
	 */
	public function insertText(aString:String):Void {
		// TODO implement
	}
	
	//******************************************************															 
	//*	          Setting behavioral attributes
	//******************************************************

	//! TODO - (BOOL)allowsUndo
	//! TODO - (void)setAllowsUndo:(BOOL)flag
	
	public function setEditable(value:Boolean):Void {
		m_editable = value;
	}

	public function isEditable():Boolean {
		return m_editable;
	}

	public function setSelectable(value:Boolean):Void {
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

	public function setRichText(value:Boolean):Void {
		m_richText = value;
		// TODO implement
	}

	public function isRichText():Boolean {
		return m_richText;
		// TODO implement
	}

	// TODO - (void)setDefaultParagraphStyle:(NSParagraphStyle *)paragraphStyle
	// TODO - (NSParagraphStyle *)defaultParagraphStyle
	// TODO - (void)outline:(id)sender
	// TODO - (void)underline:(id)sender

	//******************************************************															 
	//*	         Using the Font panel and menu
	//******************************************************

	public function setUsesFontPanel(value:Boolean):Void {
		m_usesFontPanel = value;
	}

	public function usesFontPanel():Boolean {
		return m_usesFontPanel;
	}

	//******************************************************															 
	//*	                Using the ruler
	//******************************************************

	public function toggleRuler(sender:Object):Void {
		//! Need to implement
		makeUnsupportedException("toggleRuler");
	}

	public function isRulerVisible():Boolean {
		//! Need to implement
		
		return false;
	}

	//******************************************************															 
	//*	             Changing the selection
	//******************************************************

	public function setSelectedRange(range:NSRange):Void {
		if (m_textField != null && m_textField._parent != undefined) {
			Selection.setFocus(eval(m_textField._target));
			Selection.setSelection(range.location, range.location + range.length);
		}
		m_selectedRange = range;
	}

	public function selectedRange():NSRange {
		if (m_textField != null && m_textField._parent != undefined 
				&& Selection.getFocus()==m_textField._target) {
			m_selectedRange = new NSRange(Selection.getBeginIndex(), 
				Selection.getEndIndex() - Selection.getBeginIndex());
		}
		return m_selectedRange;
	}

	//******************************************************															 
	//*	                 Replacing text
	//******************************************************

	public function replaceCharactersInRangeWithString(range:NSRange, 
			string:String):Void {
		if (m_textField != null && m_textField._parent != undefined) {
			m_textField.replaceText(range.location, range.location + range.length, string);
		} else {
		}
	}

	public function setString(string:String):Void {
		m_internalString = string;
		if (m_textField != null && m_textField._parent != undefined) {
			m_textField.text = string;
			m_textField.setTextFormat(m_textFormat);
			m_textField.setNewTextFormat(m_textFormat);
		}
	}

	//******************************************************
	//*	           Action methods for editing
	//******************************************************

	public function selectAll(sender:Object):Void {
		setSelectedRange(new NSRange(0, m_internalString.length));
	}

	public function copy(sender:Object):Void {
		//! How to copy?
		makeUnsupportedException("copy");
	}

	public function cut(sender:Object):Void {
		copy(sender);
		clear(sender);
	}

	public function paste(sender:Object):Void {
		//! How to paste?
		makeUnsupportedException("paste");
	}

	public function copyFont(sender:Object):Void {
		//! How to copyFont?
		makeUnsupportedException("copyFont");
	}

	public function pasteFont(sender:Object):Void {
		//! How to pastFont?
		makeUnsupportedException("copyFont");
	}

	public function copyRuler(sender:Object):Void {
		//! What to do here?
		makeUnsupportedException("copyRuler");
	}

	public function pasteRuler(sender:Object):Void {
		//! What to do here?
		makeUnsupportedException("pasteRuler");
	}

	/**
	* Remove all text from the text editor but do not place it on the clipboard
	* NOTE: Changed from the Cocoa delete method because delete is a keyword in ActionScript
	*
	*/
	public function clear(sender:Object):Void {
		if (m_textField != null && m_textField._parent != undefined 
				&& Selection.getFocus()==m_textField._target) {
			m_textField.text = "";
		}	
		m_internalString = "";
	}

	//******************************************************															 
	//*	               Changing the font
	//******************************************************
	
	public function changeFont(sender:Object):Void {
		if (!m_usesFontPanel) {
			return;
		}
		//! What to do here?
	}

	public function setFont(font:NSFont):Void {
		m_textFormat.font = font.fontName();
		m_textFormat.size = font.pointSize();
		if (m_textField != null && m_textField._parent != undefined) {
			m_textField.setTextFormat(m_textFormat);
			m_textField.setNewTextFormat(m_textFormat);
		}
	}

	public function font():NSFont {
		return NSFont.fontWithNameSize(m_textFormat.font, m_textFormat.size);
	}

	public function setFontRange(font:NSFont, range:NSRange):Void {
		if (m_textField != null && m_textField._parent != undefined) {
			var format:TextFormat = m_textField.getTextFormat(range.location, 
				range.location + range.length);
			format.font = font.fontName();
			format.size = font.pointSize();
			m_textField.setTextFormat(m_textFormat, range.location, 
				range.location + range.length);
		}	
	}

	//******************************************************															 
	//*	              Setting text alignment
	//******************************************************

	public function setAlignment(value:NSTextAlignment):Void {
		m_alignment = value;
		__setAlignment(value, 0, m_internalString.length);
	}

	public function alignCenter(sender:Object):Void {
		__setAlignment(NSTextAlignment.NSCenterTextAlignment, 0, m_internalString.length);
	}

	public function alignLeft(sender:Object):Void {
		__setAlignment(NSTextAlignment.NSLeftTextAlignment, 0, m_internalString.length);
	}

	public function alignRight(sender:Object):Void {
		__setAlignment(NSTextAlignment.NSRightTextAlignment, 0, m_internalString.length);
	}

	public function alignment():NSTextAlignment {
		return m_alignment;
	}
	
	private function __setAlignment(value:NSTextAlignment, begin:Number, 
			end:Number):Void {
		var format:TextFormat = new TextFormat();
		format.align = value.string;
		m_textField.setTextFormat(format, begin, end);
	}

	//******************************************************															 
	//*	               Setting text color
	//******************************************************

	public function setTextColor(color:NSColor):Void {
		m_textFormat.color = color.value;
		if (m_textField != null && m_textField._parent != undefined) {
			m_textField.setTextFormat(m_textFormat);
			m_textField.setNewTextFormat(m_textFormat);
		}	
	}

	public function setTextColorRange(color:NSColor, range:NSRange):Void {
		if (m_textField != null && m_textField._parent != undefined) {
			var format:TextFormat = m_textField.getTextFormat(range.location, 
				range.location + range.length);
			format.color = color.value;
			m_textField.setTextFormat(m_textFormat, range.location, range.location 
				+ range.length);
		}		 
	}

	public function textColor():NSColor {
		return new NSColor(m_textFormat.color);
	}

	//******************************************************															 
	//*	               Writing direction
	//******************************************************

	public function writingDirection():NSWritingDirection {
		return m_writingDirection;
	}

	public function setWritingDirection(direction:NSWritingDirection):Void {
		m_writingDirection = direction;
	}

	//******************************************************															 
	//*	     Setting superscripting and subscripting
	//******************************************************

	public function superscript(sender:Object):Void {
		//! What to do here?
		makeUnsupportedException("superscript");
	}

	public function subscript(sender:Object):Void {
		//! What to do here?
		makeUnsupportedException("subscript");
	}

	public function unscript(sender:Object):Void {
		//! What to do here?
		makeUnsupportedException("unscript");
	}

	//******************************************************															 
	//*	               Underlining text
	//******************************************************

	public function underline(sender:Object):Void {
		m_textFormat.underline = true;
		if (m_textField != null && m_textField._parent != undefined) {
			m_textField.setTextFormat(m_textFormat);
			m_textField.setNewTextFormat(m_textFormat);
		}	
	}

	//******************************************************															 
	//*	               Constraining size
	//******************************************************

	public function setMaxSize(size:NSSize):Void {
		m_maxSize = size;
		setNeedsDisplay(true);
	}

	public function maxSize():NSSize {
		return m_maxSize;
	}

	public function setMinSize(size:NSSize):Void {
		m_minSize = size;
		setNeedsDisplay(true);
	}

	public function minSize():NSSize {
		return m_minSize;
	}

	public function setVerticallyResizable(value:Boolean):Void {
		m_verticallyResizable = value;
	}

	public function isVerticallyResizable():Boolean {
		return m_verticallyResizable;
	}	

	public function setHorizontallyResizable(value:Boolean):Void {
		m_horizontallyResizable = value;
		m_textField.wordWrap = !m_horizontallyResizable;
	}

	public function isHorizontallyResizable():Boolean {
		return m_horizontallyResizable;
	}	

	public function sizeToFit():Void {
		//! Leave us at our current size
	}

	//******************************************************															 
	//*	              Checking spelling
	//******************************************************

	public function checkSpelling(sender:Object):Void {
		//! What to do here?
		makeUnsupportedException("checkSpelling");
	}

	public function showGuessPanel(sender:Object):Void {
		//! What to do here?
		makeUnsupportedException("showGuessPanel");
	}

	//******************************************************															 
	//*	                  Scrolling
	//******************************************************

	public function scrollRangeToVisible(range:NSRange):Void {
		//! What to do here?
	}

	//******************************************************															 
	//*	              Setting the delegate
	//******************************************************

	public function delegate():Object {
		return m_delegate;
	}

	public function setDelegate(value:Object):Void {
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
	
	private function mapDelegateNotification(name:String):Void {
		if(typeof(m_delegate["text"+name]) == "function") {
			m_notificationCenter.addObserverSelectorNameObject(m_delegate, "text"+name, ASUtils.intern("NSText"+name+"Notification"), this);
		}
	}

	//******************************************************															 
	//*	              Managing the textfield
	//******************************************************
	
	public function textField():TextField {
		if (m_textField == null || m_textField._parent == undefined) {
			//
			// Build the text format and textfield
			//
			m_textField = createBoundsTextField();
			m_textFormat = m_font.textFormatWithAlignment(m_alignment);
			m_textFormat.color = m_textColor.value;
			m_textField.view = this;
			//m_textField.mouseWheelEnabled = false;
			m_textField.type = "dynamic";
			m_textField.selectable = m_selectable;
			m_textField.text = m_internalString;
			m_textField.embedFonts = m_font.isEmbedded();
			m_textField.multiline = true;
			m_textField.wordWrap = !m_horizontallyResizable;

			//
			// Assign the textformat.
			//
			m_textField.setTextFormat(m_textFormat);
			m_textField.setNewTextFormat(m_textFormat);
			var b:NSRect = bounds();
			m_textField._x = 0;
			m_textField._y = 0;
			m_textField._width = b.size.width;
			m_textField._height = b.size.height;
			m_textField.addListener(this);
		}

		return m_textField;
	}
	
	private function onScroller(tf:TextField):Void {
		reflectScrolledTextField();
	}

	//******************************************************															 
	//*	                 Drawing the view
	//******************************************************
	
	public function drawRect(rect:NSRect):Void {
		var theme:ASThemeProtocol = ASTheme.current();
		var mc:MovieClip = mcBounds();
		mc.clear();
		if (m_drawsBackground) {
			theme.drawTextViewWithRectInView(rect, this);
		}
		if (m_showsFirstResponder) {
			theme.drawFirstResponderWithRectInView(rect, this);
		}
		var tf:TextField = textField();
		if (tf.text != m_internalString) {
			tf.text = m_internalString;
			tf.setTextFormat(m_textFormat);
		}

		theme.drawScrollViewBorderInRectWithViewBorderType(
			rect, this, m_borderType);
	}

	//******************************************************
	//*             Responding to events
	//******************************************************
	
	public function mouseDown(event:NSEvent) {
		if (!isSelectable()) {
			super.mouseDown(event);
			return;
		}
		m_window.makeFirstResponder(this);
		
		beginEditing();
	}
	
	private function beginEditing():Void {
		if (m_editor == null) {
			m_editor = ASFieldEditor.startEditingWithText(this, this, 
				textField());
		}
	}
	
	public function abortEditing():Boolean {
		if (m_editor) {
			m_editor.notifyEndEditing(NSTextMovement.NSIllegalTextMovement);
			m_editor.endInstanceEdit();
			m_editor = null;
			return true;
		} else {
			return false;
		}
	}
	
	public function acceptsFirstMouse(event:NSEvent):Boolean {
		return isEditable();
	}
	
	public function acceptsFirstResponder():Boolean {
		return isEditable() && isSelectable();
	}
  
	public function resignFirstResponder():Boolean {
		if (m_editor != null) {
			m_editor.notifyEndEditing(NSTextMovement.NSIllegalTextMovement);
			m_editor.endInstanceEdit();
		}
		
		return super.resignFirstResponder();
	}
	
	//******************************************************
	//*               Field editor delegate
	//******************************************************
	
	public function textDidBeginEditing(notification:NSNotification) {
		m_notificationCenter.postNotificationWithNameObjectUserInfo(
			NSText.NSTextDidBeginEditingNotification,
			this,
			NSDictionary.dictionaryWithObjectForKey(notification.object,"NSFieldEditor")
		);
	}

	public function textDidChange(notification:NSNotification) {
		m_notificationCenter.postNotificationWithNameObjectUserInfo(
			NSText.NSTextDidChangeNotification,
			this,
			NSDictionary.dictionaryWithObjectForKey(notification.object,"NSFieldEditor")
		);
		
		if (m_internalString != notification.object.string()) {
			m_internalString = notification.object.string();
			reflectScrolledTextField();
			m_notificationCenter.postNotificationWithNameObject(
			NSText.NSTextDidChangeNotification, this);
		}
	}
	
	public function textDidEndEditing(notification:NSNotification) {
		//validateEditing();
		setNeedsDisplay(true);
		m_notificationCenter.postNotificationWithNameObjectUserInfo(
			NSText.NSTextDidEndEditingNotification,
			this,
			NSDictionary.dictionaryWithObjectForKey(notification.object,
			"NSFieldEditor")
		);

		
		switch(notification.userInfo.objectForKey("NSTextMovement")) {
			case NSTextMovement.NSReturnTextMovement:
				//selectText(this);
				return;
				
			case NSTextMovement.NSTabTextMovement:
				m_window.selectKeyViewFollowingView(this);
				if (m_window.firstResponder() == m_window) {
					//selectText(this);
				}
				break;
				
			case NSTextMovement.NSBacktabTextMovement:
				m_window.selectKeyViewPrecedingView(this);
				if (m_window.firstResponder() == m_window) {
					//selectText(this);
				}
				break;
				
			case NSTextMovement.NSIllegalTextMovement:
				m_window.makeFirstResponder(m_window); // FIXME this is wrong
				break;
		}
		
		m_editor.endInstanceEdit();
		m_editor = null;
	}
	
	//******************************************************
	//*             NSScrollView emulation
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

	/**
	 * <p>Lays out the components of the receiver: the content view, the 
	 * scrollers, and the ruler views.</p>
	 * 
	 * <p>You rarely need to invoke this method, but subclasses may override it 
	 * to manage additional components.</p>
	 * 
	 * <p>This is used to emulate an NSScrollView. It is not ordinarily a method
	 * or NSTextView.</p>
	 */
	public function tile() {
		var contentRect:NSRect;
		var vScrollerRect:NSRect;
		var hScrollerRect:NSRect;
		var scrollerWidth:Number = NSScroller.scrollerWidth();
		contentRect = m_bounds.insetRect(m_borderType.size.width, 
			m_borderType.size.height);
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
				vScrollerRect = new NSRect(
					contentRect.maxX() - scrollerWidth, contentRect.minY(), 
					scrollerWidth, contentRect.size.height - scrollerWidth);
				hScrollerRect = new NSRect(
					contentRect.minX(), contentRect.maxY() - scrollerWidth, 
					contentRect.size.width - scrollerWidth, scrollerWidth);
				m_verticalScroller.setFrame(vScrollerRect);
				m_horizontalScroller.setFrame(hScrollerRect);
			} else {
				vScrollerRect = new NSRect(
					contentRect.maxX() - scrollerWidth, contentRect.minY(), 
					scrollerWidth, contentRect.size.height);
				m_verticalScroller.setFrame(vScrollerRect);
			}
		} else if (m_hasHorizontalScroller && !m_horizontalScroller.isHidden()) {
			hScrollerRect = new NSRect(
				contentRect.minX(), contentRect.maxY() - scrollerWidth, 
				contentRect.size.width, scrollerWidth);
			m_horizontalScroller.setFrame(hScrollerRect);
		}
		if (m_hasVerticalScroller && !m_verticalScroller.isHidden()) {
			contentRect.size.width	-= (vScrollerRect.size.width);
		}
		if (m_hasHorizontalScroller && !m_horizontalScroller.isHidden()) {
			contentRect.size.height -= (hScrollerRect.size.height);
		}
		m_textField._width = contentRect.size.width;
		m_textField._height = contentRect.size.height;
		setNeedsDisplay(true);
	}

	/**
	 * <p>Sets the receiver’s horizontal scroller to <code>aScroller</code>, 
	 * establishing the appropriate target-action relationships between 
	 * them.</p>
	 * 
	 * <p>This is used to emulate an NSScrollView. It is not ordinarily a method
	 * or NSTextView.</p>
	 */
	public function setHorizontalScroller(aScroller:NSScroller) {
		if (m_horizontalScroller != null) {
			m_horizontalScroller.removeFromSuperview();
			if (m_horizontalScroller.target() == this) {
				m_horizontalScroller.setTarget(null);
			}
		}
		m_horizontalScroller = aScroller;
		if (m_horizontalScroller != null) {
			m_horizontalScroller.setAutoresizingMask(NSView.WidthSizable);
			m_horizontalScroller.setTarget(this);
			m_horizontalScroller.setAction("scrollAction");
		}
	}

	/**
	 * <p>Returns the receiver’s horizontal scroller, regardless of whether the 
	 * receiver is currently displaying it, or <code>null</code> if the receiver
	 * has none.</p>
	 * 
	 * <p>This is used to emulate an NSScrollView. It is not ordinarily a method
	 * or NSTextView.</p>
	 */
	public function horizontalScroller():NSScroller {
		return m_horizontalScroller;
	}

	/**
	 * <p>Determines whether the receiver keeps a horizontal scroller.</p>
	 * 
	 * <p>If <code>flag</code> is <code>true</code>, the receiver allocates and
	 * displays a horizontal scroller as needed. An NSTextView by default has
	 * neither a vertical nor a horizontal scroller.</p>
	 * 
	 * <p>This is used to emulate an NSScrollView. It is not ordinarily a method
	 * or NSTextView.</p>
	 */
	public function setHasHorizontalScroller(flag:Boolean) {
		if (m_hasHorizontalScroller == flag) {
			return;
		}
		m_hasHorizontalScroller = flag;
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

	/**
	 * <p>Returns <code>true</code> if the receiver displays a horizontal 
	 * scroller, <code>false</code> if it doesn’t.</p>
	 * 
	 * <p>This is used to emulate an NSScrollView. It is not ordinarily a method
	 * or NSTextView.</p>
	 */
	public function hasHorizontalScroller():Boolean {
		return m_hasHorizontalScroller;
	}

	/**
	 * <p>Sets the receiver’s vertical scroller to <code>aScroller</code>, 
	 * establishing the appropriate target-action relationships between 
	 * them.</p>
	 * 
	 * <p>This is used to emulate an NSScrollView. It is not ordinarily a method
	 * or NSTextView.</p>
	 */
	public function setVerticalScroller(aScroller:NSScroller) {
		if (m_verticalScroller != null) {
			m_verticalScroller.removeFromSuperview();
			if (m_verticalScroller.target() == this) {
				m_verticalScroller.setTarget(null);
			}
		}
		m_verticalScroller = aScroller;
		if (m_verticalScroller != null) {
			m_verticalScroller.setAutoresizingMask(NSView.WidthSizable);
			m_verticalScroller.setTarget(this);
			m_verticalScroller.setAction("scrollAction");
		}
	}

	/**
	 * <p>Returns the receiver’s vertical scroller, regardless of whether the 
	 * receiver is currently displaying it, or <code>null</code> if the receiver
	 * has none.</p>
	 * 
	 * <p>This is used to emulate an NSScrollView. It is not ordinarily a method
	 * or NSTextView.</p>
	 */
	public function verticalScroller():NSScroller {
		return m_verticalScroller;
	}

	/**
	 * <p>Determines whether the receiver keeps a vertical scroller.</p>
	 * 
	 * <p>If <code>flag</code> is <code>true</code>, the receiver allocates and
	 * displays a vertical scroller as needed. An NSTextView by default has
	 * neither a vertical nor a horizontal scroller.</p>
	 * 
	 * <p>This is used to emulate an NSScrollView. It is not ordinarily a method
	 * or NSTextView.</p>
	 */
	public function setHasVerticalScroller(flag:Boolean) {
		if (m_hasVerticalScroller == flag) {
			return;
		}
		m_hasVerticalScroller = flag;
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

	/**
	 * <p>Returns <code>true</code> if the receiver displays a vertical scroller,
	 * <code>false</code> if it doesn’t.</p>
	 * 
	 * <p>This is used to emulate an NSScrollView. It is not ordinarily a method
	 * or NSTextView.</p>
	 */
	public function hasVerticalScroller():Boolean {
		return m_hasVerticalScroller;
	}

	/**
	 * <p>Determines whether the receiver automatically hides its scroll bars 
	 * when they are not needed.</p>
	 * 
	 * <p>The horizontal and vertical scroll bars are hidden independently of 
	 * each other. When autohiding is on and the content of the receiver 
	 * doesn't extend beyond the size of the clip view on a given axis, the 
	 * scroller on that axis is removed to leave more room for the content.</p>
	 * 
	 * <p>This is used to emulate an NSScrollView. It is not ordinarily a method
	 * or NSTextView.</p>
	 */
	public function setAutohidesScrollers(value:Boolean) {
		if (m_autohidesScrollers == value) {
			return;
		}
		m_autohidesScrollers = value;
		tile();
	}

	/**
	 * <p>Returns <code>true</code> when autohiding is set for scroll bars in 
	 * the receiver.</p>
	 * 
	 * <p>This is used to emulate an NSScrollView. It is not ordinarily a method
	 * or NSTextView.</p>
	 */
	public function autohidesScrollers():Boolean {
		return m_autohidesScrollers;
	}

	/**
	 * Callback from NSScroller in target/action
	 */
	private function scrollAction(scroller:NSScroller) {
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
	//*                Throwing exceptions
	//******************************************************
	
	private function makeUnsupportedException(name:String):Void {
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			NSException.ASNotSupported,
			name + " is not currently supported by NSTextView",
			null);
		trace(e);
		throw e;
	}
	
	//******************************************************															 
	//*                 Notifications
	//******************************************************
		
	/**
	 * <p>Posted when the selected range of characters changes.</p>
	 * 
	 * <p>The notification object is the notifying text view. The userInfo 
	 * dictionary contains the following information:</p>
	 * 
	 * <ul>
	 * <li>
	 * <strong>NSOldSelectedCharacterRange</strong> - an {@link NSRange} with 
	 * the originally selected range.
	 * </li>
	 * </ul>
	 */
	public static var NSTextViewDidChangeSelectionNotification:Number
		= ASUtils.intern("NSTextViewDidChangeSelectionNotification");
}