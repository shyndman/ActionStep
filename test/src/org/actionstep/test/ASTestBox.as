/* See LICENSE for copyright and terms of use */
 
import org.actionstep.*;
import org.actionstep.test.ASTestView;
import org.actionstep.constants.NSTitlePosition;
import org.actionstep.constants.NSBorderType;

/**
 * Tests the <code>org.actionstep.NSBox</code> class.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestBox {
	public static function test() {
		//
		// Create app and content view
		//
		var app:NSApplication = NSApplication.sharedApplication();
		var window:NSWindow = (new NSWindow()).initWithContentRect(new NSRect(0,0,500,310));
		var view:ASTestView = ASTestView((new ASTestView()).initWithFrame(new NSRect(0,0,500,310)));
		view.setBackgroundColor(new NSColor(0x999999));
		window.setContentView(view);
		
		//
		// Create the box
		//
		var box:NSBox = (new NSBox()).initWithFrame(new NSRect(10, 10, 300, 150));
		//box.setTitle("Test Box");
		box.setBorderType(NSBorderType.NSBezelBorder);
		box.setTitlePosition(NSTitlePosition.NSNoTitle);
		view.addSubview(box);
		
		//
		// Add a button and a view to hold the button.
		//
		var button:NSButton = NSButton((new NSButton()).initWithFrame(new NSRect(0,0,120,40)));
		button.setStringValue("Test Button");

		var bv:NSView = new NSView();
		bv.init();
		bv.addSubview(button);
		box.setContentView(bv);
		
		//
		// Call sizeToFit() - automatically size the box.
		//
		box.sizeToFit();
		app.run();
	}
}