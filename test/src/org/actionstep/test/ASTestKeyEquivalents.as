/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSButton;
//import org.actionstep.NSButtonCell;
import org.actionstep.NSEvent;
import org.actionstep.NSRect;
import org.actionstep.NSWindow;

/**
 * Tests key equivalents.
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestKeyEquivalents {
	public static function test():Void {
		//
		// Create the app and the window
		//
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0, 0, 400, 300));

		//
		// Create the key equiv button
		//
		var btn:NSButton = new NSButton();
		btn.initWithFrame(new NSRect(10, 10, 140, 25));
		btn.setTitle("Ctrl+Z");
		wnd.contentView().addSubview(btn);

		//
		// Create the key equivalency
		//
		btn.setKeyEquivalent("z");
		btn.setKeyEquivalentModifierMask(NSEvent.NSCommandKeyMask);

		//
		// Create the key equiv button
		//
		var btn2:NSButton = new NSButton();
		btn2.initWithFrame(new NSRect(10, 40, 140, 25));
		btn2.setTitle("Ctrl+Y");
		wnd.contentView().addSubview(btn2);

		//
		// Create the key equivalency
		//
		btn2.setKeyEquivalent("y");
		btn2.setKeyEquivalentModifierMask(NSEvent.NSCommandKeyMask);

		//
		// Create the default push button
		//
//		var btn3:NSButton = new NSButton();
//		btn3.initWithFrame(new NSRect(10, 70, 140, 25));
//		btn3.setTitle("Enter");
//		wnd.contentView().addSubview(btn3);
//		wnd.setDefaultButtonCell(NSButtonCell(btn3.cell()));
//		wnd.enableKeyEquivalentForDefaultButtonCell();

		//
		// Create target action
		//
		var delegate:Object = {};
		delegate.buttonPress = function(button:NSButton):Void {
			trace(button.keyEquivalent());
		};
		btn.setTarget(delegate);
		btn.setAction("buttonPress");
		btn2.setTarget(delegate);
		btn2.setAction("buttonPress");

		//
		// Key loop
		//
		btn.setNextKeyView(btn2);
		btn2.setNextKeyView(btn);
		wnd.setInitialFirstResponder(btn);

		//
		// Run the application
		//
		app.run();
	}
}