/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSWindow;
import org.actionstep.NSView;
import org.actionstep.NSRect;
import org.actionstep.test.ASTestView;
import org.actionstep.NSColor;
import org.actionstep.ASColors;

/**
 * Tests drag and drop. 
 * 
 * This test is incomplete.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestDragAndDrop 
{
	public static function test()
	{
		var app:NSApplication = NSApplication.sharedApplication();
		var window1:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0,0,500,500));
		var view:NSView = (new ASTestView()).initWithFrame(
			new NSRect(0,0,500,500));
				
		//
		// Run application
		//
		window1.setContentView(view);
		
		var dragView:ASTestView = ASTestView((new ASTestView()).initWithFrame(
			new NSRect(30,30,100,100)));
		dragView.setBackgroundColor(ASColors.greenColor());
		dragView.setDndEnabled(true);
		view.addSubview(dragView);
		app.run();
	}
}