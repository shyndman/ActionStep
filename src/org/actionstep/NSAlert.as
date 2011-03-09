/* See LICENSE for copyright and terms of use */

import org.actionstep.alert.ASAlertDelegate;
import org.actionstep.alert.ASAlertPanel;
import org.actionstep.ASStringFormatter;
import org.actionstep.constants.NSAlertReturn;
import org.actionstep.constants.NSAlertStyle;
import org.actionstep.constants.NSButtonType;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSButton;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSInvocation;
import org.actionstep.NSObject;
import org.actionstep.NSRect;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeImageNames;
import org.actionstep.themes.ASThemeProtocol;

/**
 * <p>NSAlert displays a modal window to the user, and can contain text and icons.
 * The window displays a collection of buttons for the user to press. The alert
 * is dismissed after a button press has occurred.</p>
 *
 * <p>For an example of this class' usage, please see
 * {@link org.actionstep.test.ASTestSheet} or
 * {@link org.actionstep.test.ASTestPanel}.</p>
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.NSAlert extends NSObject {
	
	//******************************************************
	//*                  Members
	//******************************************************
	
	/** An array of NSButton objects belonging to this alert */
	private var m_buttons:NSArray;
	
	/** The alert's style */
	private var m_style:NSAlertStyle;
	
	/** The alert's message */
	private var m_msg:String;
	
	/** The alert's information text */
	private var m_info:String;
	
	/** <code>true</code> if alert shows a help button */
	private var m_showsHelp:Boolean;
	
	/**
	 * The anchor of the help content this alert displays when the help button 
	 * is displayed
	 */
	private var m_helpAnchor:String;
	
	/** The alert's delegate */
	private var m_delegate:ASAlertDelegate;
	
	/** The application */
	private var m_app:NSApplication;
	
	/** The panel */
	private var m_panel:ASAlertPanel;
	
	/** <code>true</code> if this alert has a custom icon */
	private var m_usingCustomIcon:Boolean;
	
	/** The icon shown by the alert */ 
	private var m_icon:NSImage;

	//******************************************************
	//*                  Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>NSAlert</code> class.
	 */
	public function NSAlert() {
		m_buttons = new NSArray();
		m_usingCustomIcon = false;
	}

	/**
	 * Initializes the default NSAlert with a style of NSAlertStyle.NSWarning.
	 */
	public function init():NSAlert {
		m_app = NSApplication.sharedApplication();
		setAlertStyle(NSAlertStyle.NSWarning);
		return this;
	}

	//******************************************************
	//*               Managing Alert Text
	//******************************************************

	/**
	 * Sets the alerts title text.
	 */
	public function setInformativeText(infoText:String):Void {
		m_info = infoText;
		
		if (m_panel != null) {
			m_panel.setInformationalText(infoText);
		}
	}

	/**
	 * Returns the alerts message text.
	 */
	public function informativeText():String {
		return m_info;
	}

	/**
	 * Sets the alerts title text.
	 */
	public function setMessageText(messageText:String):Void {
		m_msg = messageText;
		
		if (m_panel != null) {
			m_panel.setMessageText(messageText);
		}
	}

	/**
	 * Returns the alerts title text.
	 */
	public function messageText():String {
		return m_msg;
	}

	//******************************************************
	//*              Managing the Alert Icon
	//******************************************************

	/**
	 * <p>Sets the icon to be displayed in the alert to a given icon.</p>
	 *
	 * <p>By default, the icon is the image associated with the alert's style,
	 * accessed through the theme.</p>
	 *
	 * @see #icon()
	 */
	public function setIcon(icon:NSImage):Void {
		m_usingCustomIcon = true;
		_setIcon(icon);
	}

	/**
	 * Internal icon setter.
	 */
	private function _setIcon(icon:NSImage):Void {
		m_icon = icon;
	}

	/**
	 * <p>Returns the icon displayed in the alert.</p>
	 *
	 * <p>By default, the icon is the image associated with the alert's style,
	 * accessed through the theme.</p>
	 *
	 * @see #setIcon()
	 */
	public function icon():NSImage {
		return m_icon;
	}

	//******************************************************
	//*              Managing Alert Buttons
	//******************************************************

	/**
	 * <p>Adds a button to alert labeled with <code>aTitle</code>, then returns
	 * it. The button is placed to the left side of the existing buttons.</p>
	 *
	 * <p>By default the first button is the default push button.</p>
	 */
	public function addButtonWithTitle(aTitle:String):NSButton {
		if (aTitle == null) {
			return null;
		}
		
		var theme:ASThemeProtocol = ASTheme.current();
		
		//
		// Create the button
		//
		var button:NSButton = (new NSButton()).initWithFrame(
			new NSRect(0, 0, ASAlertPanel.ASBtnMinWidth, ASAlertPanel.ASBtnMinHeight));		
		button.setTitle(aTitle);
		button.setFontColor(theme.buttonTextColorForAlert(this));
		button.setButtonType(NSButtonType.NSMomentaryPushInButton);
		button[ASAlertPanel.ASButtonSheetProperty] = this;
		button.setTarget(this);
		button.setAction("buttonAction");
		
		//
		// Set the tag and key equivalent
		//
		var count:Number = m_buttons.count();
		if (count == 0) {
			button.setTag(NSAlertReturn.NSFirstButton.value);
			//button.setKeyEquivalent("\r");
		} else {
			button.setTag(NSAlertReturn.NSFirstButton.value + count);
			if (aTitle == "Cancel") {
				button.setKeyEquivalent("e");
			} else if (aTitle == "Don't Save") {
				button.setKeyEquivalent("D");
				button.setKeyEquivalentModifierMask(NSEvent.NSCommandKeyMask);
			}
		}

		//
		// Add it to our button array, and to the panel if we have one
		//
		m_buttons.addObject(button);
		
		if (m_panel != null) {
			m_panel.addButton(button);
		}
		
		return button;
	}

	/**
	 * Returns the alert's buttons.
	 */
	public function buttons():NSArray {
		return m_buttons;
	}

	//******************************************************
	//*                 Managing Help Text
	//******************************************************

	/**
	 * <p>Sets whether the alert displays a help button. If <code>true</code>,
	 * the help button is displayed.</p>
	 *
	 * <p>When the button is pressed, an {@link #alertShowsHelp()} method is
	 * called on the delegate. The method signiture is as follows:</p>
	 * 	<p><code>alertShowsHelp(alert:NSAlert):Boolean</code></p>
	 *
	 * <p>If the delegate returns <code>false</code>, or delegate is
	 * <code>null</code>, the {@link NSHelpManager} is asked to show help,
	 * passed a <code>null</code> book and the anchor specified by
	 * {@link #setHelpAnchor()}.</p>
	 *
	 * @see #showsHelp()
	 */
	public function setShowsHelp(showsHelp:Boolean):Void {
		m_showsHelp = showsHelp;
	}

	/**
	 * <p>Returns <code>true</code> if the alert has a help button, or
	 * <code>false</code> if it doesn't.</p>
	 *
	 * @see #setShowsHelp()
	 */
	public function showsHelp():Boolean {
		return m_showsHelp;
	}

	/**
	 * <p>Sets the HTML text anchor sent to the {@link NSHelpManager} if
	 * {@link #showsHelp()} is <code>true</code> and no delegate has been
	 * specified.</p>
	 *
	 * @see #helpAnchor()
	 */
	public function setHelpAnchor(anchor:String):Void {
		m_helpAnchor = anchor;
	}

	/**
	 * <p>Returns the HTML text anchor sent to the NSHelpManager if
	 * {@link #showsHelp()} is <code>true</code> and no delegate has been
	 * specified.</p>
	 *
	 * @see #setHelpAnchor()
	 */
	public function helpAnchor():String {
		return m_helpAnchor;
	}

	//******************************************************
	//*              Managing the Alert Style
	//******************************************************

	/**
	 * <p>Sets the alert style.</p>
	 *
	 * @see #alertStyle()
	 */
	public function setAlertStyle(style:NSAlertStyle):Void {
		m_style = style;

		if (m_usingCustomIcon) {
			return;
		}

		//
		// Set corresponding icon
		//
		switch (style) {
			case NSAlertStyle.NSInformational:
				_setIcon(NSImage.imageNamed(ASThemeImageNames.NSInformationAlertImage));
				break;

			case NSAlertStyle.NSWarning:
				_setIcon(NSImage.imageNamed(ASThemeImageNames.NSWarningAlertImage));
				break;

			case NSAlertStyle.NSCritical:
				_setIcon(NSImage.imageNamed(ASThemeImageNames.NSCriticalAlertImage));
				break;
		}
	}

	/**
	 * <p>Returns the alert style.</p>
	 *
	 * @see #setAlertStyle()
	 */
	public function alertStyle():NSAlertStyle {
		return m_style;
	}

	//******************************************************
	//*              Managing the Delegate
	//******************************************************

	/**
	 * Sets the delegate that displays help for the alert.
	 */
	public function setDelegate(delegate:ASAlertDelegate) {
		m_delegate = delegate;
	}

	/**
	 * Returns the delegate that displays help for the alert.
	 */
	public function delegate():ASAlertDelegate {
		return m_delegate;
	}

	//******************************************************
	//*              Displaying the Alert
	//******************************************************

	//! TODO - (int)runModal

	/**
	 * <p>Runs the modal alert in window. When the alert recieves user input,
	 * it invokes the <code>didEndSelector</code> in <code>delegate</code>.
	 * It's method signature should be as follows:</p>
	 * <p><code>alertDidEnd(NSAlert, NSRunResponse, context:Object):Void</code></p>
	 *
	 * <p><strong>Please note:</strong><br/>
	 * The delegate must either be a subclass of NSObject or have a method
	 * called respondsToSelector who when passed a string selector returns
	 * <code>true</code> if the object can respond, or <code>false</code> if
	 * it can't.</p>
	 */
	public function beginSheetModalForWindowModalDelegateDidEndSelectorContextInfo(
			window:NSWindow, delegate:Object, didEndSelector:String,
			ctxt:Object):Void {
		//
		// Get the alert panel
		//
		m_panel = ASAlertPanel.alertSheetWithTitleIconMessageInfoButtons(
			"", icon(), m_msg, m_info, m_buttons.internalList());

		//
		// Create the callback function
		//
		var didEndCallback:NSInvocation = NSInvocation.invocationWithTargetSelectorArguments(
			delegate, didEndSelector, ctxt);

		//
		// Run the alert sheet
		//
		ASAlertPanel.runAlertSheet(m_panel, window, this,
			"onSheetEnd", "onSheetDismiss", didEndCallback);
	}

	//******************************************************
	//*                Sheet callbacks
	//******************************************************

	/**
	 * Invoked when the alert ends, but before it is dismissed.
	 */
	private function onSheetEnd(sheet:NSWindow, ret:NSAlertReturn,
			didEndCallback:NSInvocation):Void {
		var ctx:Object = didEndCallback.getArgumentAtIndex(0);
		didEndCallback.setArguments(NSArray.arrayWithArray(
			[this, ret, ctx]));
		didEndCallback.invoke();
	}

	/**
	 * Invoked when the alert is dismissed (when the window disappears).
	 */
	private function onSheetDismiss(sheet:NSWindow, ret:NSAlertReturn,
			didEndCallback:NSInvocation):Void {
		m_panel = null;
	}

	//******************************************************
	//*            Obtaining the Alert Window
	//******************************************************

	/**
	 * Returns the modal dialog.
	 */
	public function window():ASAlertPanel {
		return m_panel;
	}

	//******************************************************
	//*           Responding to button actions
	//******************************************************

	/**
	 * Invoked when a button is pressed.
	 */
	private function buttonAction(sender:Object):Void {
		m_panel.__buttonWasClicked(sender);
	}

	//******************************************************
	//*                Creating an alert
	//******************************************************

	/**
	 * <p>Creates an <code>NSAlert</code> instance for display as an
	 * warning-style alert.</p>
	 *
	 * @param messageTitle Title of the alert.
	 * @param defaultButtonTitle Title for the default button.
	 * @param alternateButtonTitle Title for the alternate button.
	 * @param otherButtonTitle Title for the other button.
	 * @param informativeText Informative text, optional. Can embed
	 * 		  variable values using printf-style formatting characters; list
	 * 		  any necessary arguments for this formatted string at the end of
	 * 		  the method’s argument list.
	 * @return The initialized alert
	 */
	public static function alertWithMessageTextDefaultButtonAlternateButtonOtherButtonInformativeTextWithFormat(
			messageTitle:String, defaultButtonTitle:String,
			alternateButtonTitle:String, otherButtonTitle:String,
			informativeText:String
			/* format variables */):NSAlert {
		var alert:NSAlert = (new NSAlert()).init();
		alert.setMessageText(messageTitle);

		if (defaultButtonTitle != null) {
			alert.addButtonWithTitle(defaultButtonTitle);
		} else {
			alert.addButtonWithTitle("OK");
		}

		if (alternateButtonTitle != null) {
			alert.addButtonWithTitle(alternateButtonTitle);
		}

		if (otherButtonTitle != null) {
			alert.addButtonWithTitle(otherButtonTitle);
		}

		if (informativeText != null) {
			var formatArgs:Array = arguments.slice(5);
			alert.setInformativeText(ASStringFormatter.formatString(
				informativeText,
				NSArray.arrayWithArray(formatArgs)));
		}

		return alert;
	}
}