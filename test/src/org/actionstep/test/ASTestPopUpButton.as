/* See LICENSE for copyright and terms of use */

import org.actionstep.*;

/**
 * Tests the <code>org.actionstep.NSComboBox</code> class.
 *
 * @author Richard Kilmer
 */
class org.actionstep.test.ASTestPopUpButton {
	public static function test():Void
	{
	  var object:Object = new Object();
		var app:NSApplication = NSApplication.sharedApplication();
		var window:NSWindow = (new NSWindow()).initWithContentRect(new NSRect(0,0,500,500));
		var view:NSView = (new NSView()).initWithFrame(new NSRect(0,0,500,500));
		
		var popUpButton:NSPopUpButton = new NSPopUpButton();
		popUpButton.initWithFramePullsDown(new NSRect(10, 10, 150, 25), false);
    popUpButton.addItemWithTitle("Foo");
    popUpButton.addItemWithTitle("Bar");
    
		view.addSubview(popUpButton);

		window.setContentView(view);
		app.run();
	}
}