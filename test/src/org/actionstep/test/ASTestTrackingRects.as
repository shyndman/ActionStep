/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSWindow;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.test.trackingRects.ASTestDrawingView;
import org.actionstep.ASColors;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestTrackingRects {
	public static function test():Void {
		var app:NSApplication = NSApplication.sharedApplication();

		//
		// Create the canvas window
		//
		var canvasWnd:NSWindow = (new NSWindow()).initWithContentRectStyleMask(
			new NSRect(40, 40, 400, 300),
			NSWindow.NSTitledWindowMask
			| NSWindow.NSResizableWindowMask);
		canvasWnd.setBackgroundColor(ASColors.whiteColor());

		//
		// Create the tools window
		//
		var toolsWnd:NSWindow = (new NSWindow()).initWithContentRectStyleMask(
			new NSRect(370, 50, 180, 120),
			NSWindow.NSTitledWindowMask
			| NSWindow.NSResizableWindowMask);
		toolsWnd.setBackgroundColor(ASColors.lightGrayColor());

		//
		// Create the drawing view
		//
		var drawCanvas:ASTestDrawingView = (new ASTestDrawingView())
			.initWithFrame(new NSRect(15, 15, 370, 270));
		drawCanvas.setAutoresizingMask(
			NSView.WidthSizable |
			NSView.HeightSizable);
		canvasWnd.contentView().addSubview(drawCanvas);

		//
		// Run the application
		//
		app.run();
	}
}