/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSWindow;
import org.actionstep.NSRect;
import org.actionstep.NSTextView;
import org.actionstep.NSView;
import org.actionstep.NSScrollView;
import org.actionstep.ASColors;
import org.actionstep.constants.NSBorderType;
import org.actionstep.NSButton;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestTextView {
	public static function test():Void {
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0, 0, 800, 600));
		wnd.setBackgroundColor(ASColors.lightGrayColor());
		var stg:NSView = wnd.contentView();
		
		//
		// Build a few textviews
		//
		var textview:NSTextView = (new NSTextView()).initWithFrame(
			new NSRect(10, 10, 300, 192));
		textview.setHasVerticalScroller(true);
		textview.setAutohidesScrollers(true);
		textview.setBorderType(NSBorderType.NSGrooveBorder);
		stg.addSubview(textview);
		
		var tv2:NSTextView = (new NSTextView()).initWithFrame(
			new NSRect(310, 10, 300, 192));
		tv2.setHasVerticalScroller(true);
		tv2.setAutohidesScrollers(false);
		tv2.setTextColor(ASColors.blueColor());
		stg.addSubview(tv2);
		
		//
		// Run app
		//
		app.run();
	}
}