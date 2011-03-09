/* See LICENSE for copyright and terms of use */

import org.actionstep.alert.ASAlertPanel;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSAlertReturn;
import org.actionstep.constants.NSAlertStyle;
import org.actionstep.constants.NSBezelStyle;
import org.actionstep.NSAlert;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSColor;
import org.actionstep.NSDictionary;
import org.actionstep.NSEvent;
import org.actionstep.NSRect;
import org.actionstep.NSTextField;
import org.actionstep.NSWindow;
import org.actionstep.test.ASTestView;
import org.actionstep.NSImage;
import org.actionstep.themes.ASThemeImageNames;

/**
 * Tests the <code>org.actionstep.NSAlert</code> class.
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.test.ASTestSheet {
	private static var g_self:Object = ASTestSheet;
	private static var g_app:NSApplication;
	private static var g_main:NSWindow, g_other:NSWindow;
	private static var g_view1:ASTestView, g_view2:ASTestView;
	private static var g_b0:NSButton, g_b1:NSButton;
	private static var g_textField:NSTextField, g_textField2:NSTextField;
	private static var g_msg:String;
	private static var g_alert:NSAlert;

	private static var g_alertCounter:Number = 0;

	public static function test() {
		g_app = NSApplication.sharedApplication();
		g_main= (new NSWindow()).initWithContentRectStyleMask(new NSRect(50,50,250,250), NSWindow.NSTitledWindowMask);
		g_main.setTitle("Main");
		g_other = (new NSWindow()).initWithContentRectStyleMask(new NSRect(400,50,250,250), NSWindow.NSTitledWindowMask);
		g_other.setTitle("Some Other Window");

		g_view1 = ASTestView((new ASTestView()).initWithFrame(new NSRect(0,0,25,25)));
		g_view1.setBorderColor(new NSColor(0xFFF000));
		g_view2 = ASTestView((new ASTestView()).initWithFrame(new NSRect(0,0,250,250)));
		g_view2.setBorderColor(new NSColor(0xFF0000));

		g_b0 = (new NSButton()).initWithFrame(new NSRect(10,20,100,30));
		g_b0.setTitle("NSAlert");
		g_b0.sendActionOn(NSEvent.NSLeftMouseUpMask);
		g_b0.setBezelStyle(NSBezelStyle.NSShadowlessSquareBezelStyle);
		g_b0.setTarget(g_self);
		g_b0.setAction("trigger");

		g_b1 = (new NSButton()).initWithFrame(new NSRect(10,20,100,30));
		g_b1.setTitle("nested sheet");
		g_b1.sendActionOn(NSEvent.NSLeftMouseUpMask);
		g_b1.setBezelStyle(NSBezelStyle.NSShadowlessSquareBezelStyle);
		g_b1.setTarget(g_self);
		g_b1.setAction("nestedTrigger");

		g_textField = (new NSTextField()).initWithFrame(new NSRect(10,200,120,30));
		g_textField2 = (new NSTextField()).initWithFrame(new NSRect(10,160,120,30));

		g_view1.addSubview(g_b0);
		g_view1.addSubview(g_textField);

		g_view2.addSubview(g_b1);
		g_view2.addSubview(g_textField2);

		g_main.setContentView(g_view1);
		g_other.setContentView(g_view2);

		g_msg = "Delete the record?";
		g_textField.setStringValue(g_msg);
		g_main.makeMainWindow();

		g_app.run();

		trigger();
	}

	//modified code from:
	//http://developer.apple.com/documentation/Cocoa/Conceptual/Sheets/Tasks/UsingAlertSheets.html#//apple_ref/doc/uid/20001045
	private static function trigger(button:NSButton) {
		var str:String = g_textField.stringValue();
		if(str==null || str=="") {
			str = g_msg;
			g_textField.setStringValue(g_msg);
			g_textField.drawCell(g_textField.cell());
		} 
		g_alert = NSAlert.alertWithMessageTextDefaultButtonAlternateButtonOtherButtonInformativeTextWithFormat(
			str, "OK", "Cancel", null, "Deleted records cannot be %s. "+
			"\n<i><font size=\"10\">PS. Click \"nested sheet\" in \"Some Other Window\"</font></i>",
			"restored");
		g_alert.setIcon(NSImage.imageNamed(ASThemeImageNames.NSRegularRadioButtonImage));
		g_alert.beginSheetModalForWindowModalDelegateDidEndSelectorContextInfo(
			g_main, g_self, "alertDidEndReturnCodeContextInfo", null);
	}

	/**
	 * WARNING: Do NOT call cause the modal session to end in this function, because it will be
	 * handled for you. Besides, the sheet will be closed anyway.
	 */
	private static function alertDidEndReturnCodeContextInfo(
		sheet:NSWindow, ret:NSAlertReturn, ctxt:NSDictionary) {

	}

	/**
	 * Starts alert dialogs that block the alert created by <code>trigger</code>.
	 */
	private static function nestedTrigger():Void {
		trace("Starting nested trigger...");
		var l_sheet:ASAlertPanel = g_alert.window();
		g_alert = NSAlert.
			alertWithMessageTextDefaultButtonAlternateButtonOtherButtonInformativeTextWithFormat(
			"Are you really sure?", "Yes I am?", "I think not", null, "Contrived test, at %d level.", g_alertCounter++);
		g_alert.beginSheetModalForWindowModalDelegateDidEndSelectorContextInfo(
			l_sheet, null, null, null);
		trace("after");
		trace(g_alert.window().frame());
	}

	//look like NSObject
	public static function respondsToSelector(sel:String):Boolean {
		return g_self.hasOwnProperty(sel);
	}

	public static function toString():String {
		return "Test::ASTestPanel";
	}
}
