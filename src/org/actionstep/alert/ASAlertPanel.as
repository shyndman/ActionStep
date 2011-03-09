/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.constants.NSAlertReturn;
import org.actionstep.constants.NSButtonType;
import org.actionstep.exceptions.ASAlertPanelInvalidCondition;
import org.actionstep.layout.ASHBox;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSButtonCell;
import org.actionstep.NSFont;
import org.actionstep.NSImage;
import org.actionstep.NSImageView;
import org.actionstep.NSModalSession;
import org.actionstep.NSPanel;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.ASThemeProtocol;

/**
 * <p>The panel used by <code>NSAlert</code>s.</p>
 *
 * <p>Used internally.</p>
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.alert.ASAlertPanel extends NSPanel {

	//******************************************************
	//*                 Naming Constants
	//******************************************************

	public static var ASButtonSheetProperty:String = "__alertPanel";

	//******************************************************
	//*            Constants used for drawing
	//******************************************************

	public static var ASWinPos:NSPoint;
	public static var ASFont:NSFont;
	public static var ASBoldFont:NSFont;
	public static var ASFontSize:Number = 14;

	public static var ASIconLeft:Number = 24;
	public static var ASIconRight:Number = 16;
	public static var ASIconTop:Number = 15;

	public static var ASBtnTop:Number = 14;
	public static var ASBtnBottom:Number = 14;
	public static var ASBtnRight:Number = 24;
	public static var ASBtnMinHeight:Number = 24;
	public static var ASBtnMinWidth:Number = 76;
	public static var ASBtnInterspace:Number = 16;
	public static var ASBtnPadding:Number = 8;

	public static var ASMsgWidth:Number = 340;
	public static var ASInfoWidth:Number = 330;
	public static var ASInfoTop:Number = 8;
	public static var ASTextFieldDiff:Number = ASMsgWidth - ASInfoWidth;

	//******************************************************
	//*                 Class members
	//******************************************************

	private static var g_app:NSApplication;
	private static var g_defTitle:String = "";

	//******************************************************
	//*               Member variables
	//******************************************************

	private var m_alertIcon:NSImage;
	private var m_iconView:NSImageView;
	private var m_buttons:Array;

	private var m_btnHBox:ASHBox;
	private var m_msgField:TextField;
	private var m_msg:String;
	private var m_infoField:TextField;
	private var m_info:String;

	private var m_result:NSAlertReturn;
	private var m_isSheet:Boolean;

	private var m_callback:Object;
	private var m_selector:String;
	private var m_modalDelegate:Object;
	private var m_didEnd:String;
	private var m_didDismiss:String;
	private var m_modalSession:NSModalSession;
	
	private var m_requiresLayout:Boolean;

	//******************************************************
	//*                  Initialization
	//******************************************************

	/**
	 * Initializes the alert panel.
	 */
	public function init():ASAlertPanel	{
		//
		// Initialize the window
		//
		initWithContentRectStyleMask(NSRect.ZeroRect, NSTitledWindowMask);
		
		//
		// Set internal properties
		//
		m_result = NSAlertReturn.NSError;
		m_isSheet = false;
		m_requiresLayout = false;
		
		setTitle("");
		setBecomesKeyOnlyIfNeeded(false);
		setReleasedWhenClosed(true);
		
		//
		// Set display values
		//
		if (g_app == null) {
			g_app = NSApplication.sharedApplication();

			// FIXME how to handle theme change?
			var theme:ASThemeProtocol = ASTheme.current();
			ASWinPos = new NSPoint(100, 100);
			ASFont = theme.labelFontOfSize(ASFontSize);
			ASBoldFont = NSFont.boldFontWithFont(ASFont);
		}

		return this;
	}

	//******************************************************
	//*          Releasing the object from memory
	//******************************************************

	/**
	 * Releases the object from memory. If this is the active panel, the
	 * application will stop model with a code of NSAborted, and the panel's
	 * doc window will become active.
	 */
	public function release():Boolean {
		if(isActivePanel()) {
			m_result = NSAlertReturn(NSAlertReturn.NSAborted);
			g_app.stopModalWithCode(m_result);
			g_app.modalSession().docWin.makeKeyWindow();
		}

		super.release();
		return true;
	}

	//******************************************************
	//*               Describing the object
	//******************************************************

	/**
	 * Returns a string representation of the alert panel.
	 */
	public function description():String {
		return "ASAlertPanel()";
	}
	
	//******************************************************
	//*            Setting the display properties
	//******************************************************


	/**
	 * Sets the message text.
	 */
	public function setMessageText(msg:String):Void {
		m_msgField.htmlText = m_msg  = msg;
	}

	/**
	 * Returns the message text.
	 */
	public function messageText():String {
		return m_msg;
	}

	/**
	 * Sets the informational text.
	 */
	public function setInformationalText(info:String):Void {
		m_infoField.htmlText = m_info = (info == null ? "" : info);
	}

	/**
	 * Returns the informational text.
	 */
	public function informationalText():String {
		return m_info;
	}
	
	/**
	 * Sets the icon shown by this alert.
	 */
	public function setAlertIcon(icon:NSImage):Void {
		m_alertIcon = icon;
	}
	
	/**
	 * Returns the image shown by this alert.
	 */
	public function alertIcon():NSImage {
		return m_alertIcon;
	}

	//******************************************************
	//*          Adding buttons to the panel
	//******************************************************
	
	/**
	 * Adds a button to the alert panel.
	 */
	public function addButton(button:NSButton):Void {
		//
		// Insert the button into the buttons array
		//
		var idx:Number = m_buttons.length;
		m_buttons.push(button);
		
		//
		// Set the tab order
		//
		var len:Number = m_buttons.length;
		if (len != 1) {
			var prev:NSButton = m_buttons[idx - 1];
			var next:NSButton = m_buttons[0];
			
			prev.setNextKeyView(button);
			button.setNextKeyView(next);
		}
		
		//
		// If this is the first button, make it the default push button and the
		// initial first responder/first responder
		//
		if (idx == 0) {
			setDefaultButtonCell(NSButtonCell(button.cell()));
			enableKeyEquivalentForDefaultButtonCell();
			setInitialFirstResponder(button);
			makeFirstResponder(button);
		}
		
		//
		// Mark the view as requiring layout
		//
		setViewsNeedDisplay(true);
		m_requiresLayout = true;
	}

	/**
	 * Returns the array of this alert panel's buttons.
	 */
	public function buttons():Array {
		return m_buttons;
	}

	/**
	 * Sets the array of this alert panel's buttons.
	 */
	public function setButtons(buttons:Array):Void {
		if (m_buttons != null) {
			setDefaultButtonCell(null);
			setInitialFirstResponder(null);
			makeFirstResponder(null);
			
			var len:Number = m_buttons.length;
			for (var i:Number = 0; i < len; i++) {
				var btn:NSButton = NSButton(buttons[i]);				
				btn.removeFromSuperview();
				btn.release();
			}
		}
		
		m_buttons = [];
		
		//
		// Add the buttons
		//
		var len:Number = buttons.length;
		for (var i:Number = 0; i < len; i++) {
			addButton(NSButton(buttons[i]));
		}
	}

	//******************************************************
	//*                  Button actions
	//******************************************************

	/**
	 * Fired when an alert button is clicked. Used internally, because this is
	 * called by the alert, not the button itself.
	 */
	public function __buttonWasClicked(sender:Object):Void {
		//
		// Make sure we're dealing with a button
		//
		if (!(sender instanceof NSButton)) {
			var e:ASAlertPanelInvalidCondition =
				ASAlertPanelInvalidCondition.exceptionWithReasonUserInfo(
				"Unrecognized button pressed", null);
				trace(e);
				e.raise();
		}

		//
		// Verify that the button is associated with this alert panel
		//
		// (ASButtonSheetProperty is set in makeButtonWithRect)
		//
		if (!sender.hasOwnProperty(ASButtonSheetProperty)) {
			var e:ASAlertPanelInvalidCondition =
				ASAlertPanelInvalidCondition.exceptionWithReasonUserInfo(
				"Pressed button does not belong to ASAlertPanel", 	null);
				trace(e);
				e.raise();
		}
		
		//
		// Set the return value
		//
		var btn:NSButton = NSButton(sender);
		m_result = NSAlertReturn.alertReturnForValue(btn.tag());
		
		//
		// Save the document window since the modal session will be destroyed.
		//
		var docWin:NSWindow = m_modalSession.docWin;

		//
		// Instruct app to return depending on whether the alert is running
		// as a sheet or a modal window.
		//
		m_modalSession.runState = m_result;
		if (sender[ASButtonSheetProperty].isSheet()) {
			g_app.endModalSession(m_modalSession);
		}

		//
		// Return key status to the window that triggered the alert
		//
		docWin.makeKeyWindow();
	}

	//******************************************************
	//*           Getting the alert return value
	//******************************************************

	/**
	 * <p>Returns the result of the alert once a button has been pressed.</p>
	 *
	 * <p>If no button has been pressed, {@link NSAlertReturn#NSError} is
	 * returned.</p>
	 */
	public function result():NSAlertReturn {
		return m_result;
	}

	//******************************************************
	//*             Setting panel selectors
	//******************************************************

	/**
	 * Sets the selectors that will be called on the modal delegate when
	 * the alert is ended (receives user input) or dismissed.
	 */
	public function setSelectors(end:String, dismiss:String):Void {
		m_didEnd = end;
		m_didDismiss = dismiss;
	}

	/**
	 * Returns the selector that is called on the modal delegate when the
	 * alert receives user input but before the alert is dismissed.
	 *
	 * @see #setSelectors()
	 * @see #didDismissSelector()
	 */
	public function didEndSelector():String {
		return m_didEnd;
	}

	/**
	 * Returns the selector that is called on the modal delegate when the
	 * alert is dismissed.
	 *
	 * @see #setSelectors()
	 * @see #didEndSelector()
	 */
	public function didDismissSelector():String {
		return m_didDismiss;
	}

	//******************************************************
	//*              Panel related methods
	//******************************************************

	/**
	 * Returns <code>true</code> if this panel is the active panel.
	 */
	public function isActivePanel():Boolean {
		return g_app.modalWindow() == this;
	}

	/**
	 * Returns <code>true</code> if this panel is a sheet.
	 */
	public function isSheet():Boolean {
		return m_isSheet;
	}
	
	/**
	 * Used internally to set whether this alert panel is a sheet.
	 */
	private function setSheet(flag:Boolean):Void {
		m_isSheet = true;
	}
	
	//******************************************************
	//*               Drawing and layout
	//******************************************************

	/**
	 * Overridden to perform layout if required.
	 */
	public function displayIfNeeded():Void {
		if (m_viewsNeedDisplay) {
			super.displayIfNeeded();
			
			if (m_requiresLayout) {
				tile();
			}
		}	
	}

	/**
	 * Positions the alert elements.
	 */
	private function tile():Void {
		var rect:NSRect = NSRect.ZeroRect;
		var content:NSView = contentView();

		//
		// Build the icon movieclip
		//
		var iconFrame:NSRect;
		if (m_alertIcon != null) {
			var iconSize:NSSize = m_alertIcon.size();
			trace(iconSize);
			
			//
			// Create the icon view if we don't already have one, or make sure
			// it's visible if we do
			//
			if (m_iconView == null) {
				m_iconView = (new NSImageView()).initWithFrame(new NSRect(
					ASIconLeft, ASIconTop, iconSize.width, iconSize.height));
				content.addSubview(m_iconView);
			} else {
				m_iconView.setHidden(false);
			}

			//
			// Draw the icon
			//
			m_iconView.setImage(m_alertIcon);

			//
			// Get the frame
			//
			iconFrame = m_iconView.frame();
		} else {
			//
			// Hide the icon view
			//
			m_iconView.setHidden(true);
			iconFrame = NSRect.ZeroRect;
		}

		//
		// Build the two textfields
		//
		if(m_msgField == null) { // Assume that m_infoField is also null
			//
			// Position will be set later
			//
			rect.origin.x = iconFrame.maxX() + ASIconRight;
			rect.origin.y = ASIconTop;
			rect.size.width = ASMsgWidth;
			m_msgField = makeTextField(rect, "m_msgField");
			
			m_msgField.embedFonts = ASBoldFont.isEmbedded();
			m_msgField.setNewTextFormat(ASBoldFont.textFormat());

			rect.size.width = ASInfoWidth;
			m_infoField = makeTextField(rect, "m_infoField");
			m_infoField.embedFonts = ASFont.isEmbedded();
			m_infoField.setNewTextFormat(ASFont.textFormat());
		}

		//
		// Set the message and info text
		//
		m_msgField.htmlText = m_msg;
		m_infoField.htmlText = m_info;

		//
		// Hide the info text field if there is none
		//
		if(m_info == null || m_info=="") {
			m_infoField._visible = false;
		}

		//
		// Remove the old hbox
		//
		if (m_btnHBox != null) {
			m_btnHBox.removeFromSuperview();
			m_btnHBox.release();
		}

		//
		// Position the buttons
		//
		var btnHBox:ASHBox = m_btnHBox = (new ASHBox()).init();
		content.addSubview(btnHBox);
		var buttonsWidth:Number = 0;
		var btn:NSButton;
		var len:Number = m_buttons.length;
		
		for (var i:Number = 0; i < len; i++) {
			btn = NSButton(m_buttons[i]);
			
			//
			// Set the size of the button
			//
			var size:NSSize = NSButton(btn).cell().cellSize();
			size.width += ASBtnPadding * 2;
			if (size.width < ASBtnMinWidth) {
				size.width = ASBtnMinWidth;
			}

			btn.setFrameWidth(size.width);
			
			//
			// Add the button to the hbox
			//
			if (i == 0) {
				btnHBox.addView(btn);
			} else {
				btnHBox.addViewWithMinXMargin(btn, ASBtnInterspace);
				buttonsWidth += ASBtnInterspace;
			}
			
			//
			// Record the new total size
			//
			buttonsWidth += size.width;
		}

		//
		// Resize fields if needed
		//
		if (buttonsWidth > m_msgField._width + ASBtnRight) {
			m_msgField._width = buttonsWidth - m_msgField._x - ASBtnRight;
			m_infoField._width = m_msgField._width - ASTextFieldDiff;
		}

		//
		// Position info textfield
		//
		m_infoField._y = m_msgField._height + m_msgField._y + ASInfoTop;
				
		//
		// Determine initial button position
		//
		var pt:NSPoint = new NSPoint(
			m_msgField._width + m_msgField._x + ASBtnRight - buttonsWidth - ASBtnRight,
			m_infoField._y + m_infoField._height + ASBtnTop);
		
		var icoy:Number = iconFrame.maxY() + ASBtnTop;
		if (pt.y < icoy) { // See if icoy is bigger than info's max - y
			pt.y = icoy;
		}

		btnHBox.setFrameOrigin(pt);
		buttonsWidth -= ASIconLeft - iconFrame.size.width + ASBtnRight;

		//
		// Resize window -- unfortunately, no setFrameSize
		//
		rect.origin = ASWinPos.clone();
		rect.size.width = m_msgField._width + m_msgField._x + ASBtnRight;
		rect.size.height = btnHBox.frame().maxY() + ASBtnBottom
			+ rootView().titleRect().size.height;
		setFrame(rect);

		//
		// Set background color
		//
		setBackgroundColor(ASTheme.current().colorWithName(
			ASThemeColorNames.ASAlertBackground));
			
		//
		// Mark as layed out
		//
		m_requiresLayout = false;
	}

	/**
	 * Makes a textfield with a rect of <code>rect</code> and an instance
	 * name of <code>title</code>.
	 */
	private function makeTextField(rect:NSRect, title:String):TextField {
		var content:NSView = contentView();
		var mc:MovieClip = content.mcBounds();

		var txt:TextField = contentView().createBoundsTextField();;
		txt._x = rect.origin.x;
		txt._y = rect.origin.y;
		txt._width = rect.size.width;
		txt._height = rect.size.height;
		txt.html = true;
		txt.type = "dynamic";
		txt.selectable = true;
		txt.wordWrap = true;
		txt.autoSize = true;
		txt.antiAliasType = "advanced";
		
		if (ASFont.pointSize() > 20) {
    		txt.gridFitType = "none";
		} else {
			txt.gridFitType = "pixel";
		}

		return txt;
	}

	//******************************************************
	//*              Display-related methods
	//******************************************************
	
	/**
	 * Displays the alert panel and positions its elements.
	 */
	public function display():Void {
		super.display();
		tile();
	}

	/**
	 * Runs the panel 
	 */
	public function runModal(call:Object, sel:String):Void {
		m_callback = call;
		m_selector = sel;

		g_app.runModalForWindow(this, this, "modalSessionDidFinish");
		display();
	}

	/**
	 * Called when the alert panel's modal session finishes.
	 */
	private function modalSessionDidFinish(res:Object):Void {
		m_callback[m_selector].call(m_callback, this, res);
	}
	
	/**
	 * Overridden to perform a close without involving the close button.
	 */	
	public function performClose(sender:Object):Void {
		if (sender != this) {
			super.performClose(sender);
			return;
		}
				
		//
		// Ask the delegate if we should close, and if it says yes (or doesn't
		// respond), close the window.
		//
		var closeWnd:Boolean = true;
		if (ASUtils.respondsToSelector(m_delegate, "windowShouldClose")) {
			closeWnd = m_delegate.windowShouldClose(this);
		}
		
		if (closeWnd) {
			close();
		}
	}

	/**
	 * Used internally to begin running the alert sheet. Do not use directly.
	 * Instead call <code>NSAlert#beginSheetModalForWindowModalDelegateDidEndSelectorContextInfo()</code>.
	 */
	public static function runAlertSheet(panel:ASAlertPanel,
			docWindow:NSWindow, modalDelegate:Object, didEndSelector:String,
			didDismissSelector:String, contextInfo:Object):Void {
		panel.m_modalDelegate = modalDelegate;
		panel.m_didEnd = didEndSelector;
		panel.m_didDismiss = didDismissSelector;
		panel.display();

		//
		// Tell the app to begin the modal sheet
		//
		NSApplication.sharedApplication()
			.beginSheetModalForWindowModalDelegateDidEndSelectorContextInfo(
				panel, docWindow, panel, "alertCallback", contextInfo);
				
		//
		// Record the modal session in the panel
		//
		panel.m_modalSession = NSApplication.sharedApplication().modalSession();
	}

	/**
	 * Invoked when the alert is ended, resulting in fired delegate methods
	 * and the closing of the window.
	 */
	private function alertCallback(panel:ASAlertPanel, ret:Object, ctxt:Object):Void {		
		var end:Object = m_didEnd;
		var diss:Object = m_didDismiss;

		m_modalDelegate[end].call(m_modalDelegate, this, ret, ctxt);
		
		performClose(this);
		
		m_modalDelegate[diss].call(m_modalDelegate, this, ret, ctxt);
	}
	
	//******************************************************
	//*            Static creation of the panel
	//******************************************************
	
	/**
	 * Creates an alert sheet with all the necessary components.
	 */
	public static function alertSheetWithTitleIconMessageInfoButtons(title:String,
			icon:NSImage, message:String, info:String, buttons:Array):ASAlertPanel {
				
		var panel:ASAlertPanel = (new ASAlertPanel()).init();
		panel.setTitle(title == null ? g_defTitle : title);
		panel.setMessageText(message);
		panel.setInformationalText(info);
		panel.setAlertIcon(icon);
		panel.setButtons(buttons);
		panel.setSheet(true);
		
		return panel;		
	}
}
