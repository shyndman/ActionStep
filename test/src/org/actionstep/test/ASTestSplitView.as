/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSSplitView;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.NSRect;
import org.actionstep.ASColoredView;
import org.actionstep.NSColor;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestSplitView {
	public static function test():Void {
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0, 0, 500, 300));
		var view:NSView = wnd.contentView();
		
		//
		// Create the first splitter
		//
		var splitter:NSSplitView = (new NSSplitView()).initWithFrame(
			new NSRect(10, 10, 400, 300));
		splitter.setVertical(true);
		view.addSubview(splitter);
		

		
		//
		// Create a few subviews for the splitter (including a secondary splitter)
		//
		var sv1:ASColoredView = new ASColoredView();
		sv1.initWithFrame(new NSRect(0, 0, 150, 300));
		sv1.setBackgroundColor(new NSColor(0x990000));
		splitter.addSubview(sv1);

		//
		// Create the second splitter and some subviews
		//
		var splitter2:NSSplitView = (new NSSplitView()).initWithFrame(
			new NSRect(0, 0, 250, 300));
			
		var sv2:ASColoredView = new ASColoredView();
		sv2.initWithFrame(new NSRect(0, 0, 250, 150));
		sv2.setBackgroundColor(new NSColor(0x009900));
		splitter2.addSubview(sv2);

		var sv3:ASColoredView = new ASColoredView();
		sv3.initWithFrame(new NSRect(0, 0, 250, 150));
		sv3.setBackgroundColor(new NSColor(0x000099));
		splitter2.addSubview(sv3);
		
		var sv4:ASColoredView = new ASColoredView();
		sv4.initWithFrame(new NSRect(0, 0, 250, 150));
		sv4.setBackgroundColor(new NSColor(0x009999));
		splitter2.addSubview(sv4);
		
		splitter2.adjustSubviews();
		
		splitter.addSubview(splitter2);
				
		//
		// Adjust the splitter views
		//
		splitter.adjustSubviews();
		
		//
		// Run the application
		//
		app.run();
	}
}