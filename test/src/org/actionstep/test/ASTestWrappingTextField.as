/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSView;
import org.actionstep.NSRect;
import org.actionstep.NSWindow;
import org.actionstep.NSTextField;
import org.actionstep.NSTextFieldCell;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestWrappingTextField {
	public static function test():Void {
		var app:NSApplication = NSApplication.sharedApplication();
		
		//
		// Create a few text fields to test various properties
		//
		var wnd1:NSWindow = (new NSWindow()).initWithContentRectStyleMask(
			new NSRect(20,20,200,100),
			NSWindow.NSTitledWindowMask |
			NSWindow.NSResizableWindowMask);
		var stg:NSView = wnd1.contentView();
		
		//
		// Create a wrapped text field
		//
		var tf1:NSTextField = (new NSTextField()).initWithFrame(
			new NSRect(0, 0, 200, 90));
		tf1.setAutoresizingMask(NSView.WidthSizable | NSView.HeightSizable);
		tf1.cell().setWraps(true);
		
		var str:String = "";
		for (var i:Number = 0; i < 20; i++) {
			str += "Wrapping, non-scrolling text field! ";
		}
		
		tf1.setStringValue(str);
		tf1.setEditable(false);
		tf1.setSelectable(true);
		tf1.setDrawsBackground(false);
		stg.addSubview(tf1);
		
		//
		// Run the app
		//
		app.run();
	}
}