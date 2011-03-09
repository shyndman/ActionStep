/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColoredView;
import org.actionstep.ASColors;
import org.actionstep.constants.NSToolbarSizeMode;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSRect;
import org.actionstep.NSToolbar;
import org.actionstep.NSWindow;
import org.actionstep.test.toolbar.ASToolbarTestDelegate;
import org.actionstep.constants.NSToolbarDisplayMode;
import org.actionstep.NSView;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestToolbar {
	public static function test():Void {
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRectStyleMask(
			new NSRect(50, 50, 300, 200),
			NSWindow.NSTitledWindowMask |
			NSWindow.NSResizableWindowMask);
			
		//
		// Build content view
		//
		var view:ASColoredView = ASColoredView((new ASColoredView()).initWithFrame(
			new NSRect(0, 0, 300, 450)));
		view.setBackgroundColor(ASColors.whiteColor());
		view.setBorderColor(ASColors.lightGrayColor());
		
		var btn:NSButton = (new NSButton()).initWithFrame(new NSRect(
			10, 10, 280, 26));
		btn.setAutoresizingMask(NSView.WidthSizable);
		btn.setTitle("Show / Hide");
		view.addSubview(btn);
				
		var btn2:NSButton = (new NSButton()).initWithFrame(new NSRect(
			10, 40, 280, 26));
		btn2.setAutoresizingMask(NSView.WidthSizable);
		btn2.setTitle("Change Size");
		view.addSubview(btn2);
		
		var btn3:NSButton = (new NSButton()).initWithFrame(new NSRect(
			10, 70, 280, 26));
		btn3.setAutoresizingMask(NSView.WidthSizable);
		btn3.setTitle("Change Display Mode");
		view.addSubview(btn3);
		
		wnd.setContentView(view);
		
		//
		// Create the toolbar delegate
		//
		var delegate:ASToolbarTestDelegate = new ASToolbarTestDelegate();
		
		//
		// Create the toolbar
		//
		var tb:NSToolbar = (new NSToolbar()).initWithIdentifier("foo");
//		tb.setShowsBaselineSeparator(true);
//		tb.setSizeMode(NSToolbarSizeMode.NSToolbarSizeModeSmall);
//		tb.setDisplayMode(NSToolbarDisplayMode.NSToolbarDisplayModeIconAndLabel);
//		tb.setDelegate(delegate);
//		
//		wnd.setToolbar(tb);
		
		app.run();
		
		//
		// Button Action
		//
		var curDisplay:Number = 0;
		var displayModes:Array = [
			NSToolbarDisplayMode.NSToolbarDisplayModeIconAndLabel,
			NSToolbarDisplayMode.NSToolbarDisplayModeIconOnly,
			NSToolbarDisplayMode.NSToolbarDisplayModeLabelOnly];
		var targ:Object = {};
		targ.addToolbar = function() {
			if (wnd.toolbar() != null) {
				wnd.toggleToolbarShown(this);
				return;
			}			
		};
		targ.changeSize = function() {
			tb.setSizeMode(
				tb.sizeMode() == NSToolbarSizeMode.NSToolbarSizeModeRegular
				? NSToolbarSizeMode.NSToolbarSizeModeSmall
				: NSToolbarSizeMode.NSToolbarSizeModeRegular);
		};
		targ.changeDisplay = function() {
			curDisplay++;
			curDisplay %= displayModes.length;
			tb.setDisplayMode(displayModes[curDisplay]);
		};
		btn.setTarget(targ);
		btn.setAction("addToolbar");
		btn2.setTarget(targ);
		btn2.setAction("changeSize");
		btn3.setTarget(targ);
		btn3.setAction("changeDisplay");
	}
}