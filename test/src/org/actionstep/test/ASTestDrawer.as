/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSWindow;
import org.actionstep.NSDrawer;
import org.actionstep.constants.NSRectEdge;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.ASColors;
import org.actionstep.NSView;
import org.actionstep.NSButton;
import org.actionstep.NSColor;
import org.actionstep.ASColoredView;
import org.actionstep.ASLabel;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestDrawer {
	public static function test():Void {
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRectStyleMask(
			new NSRect(150, 150, 200, 200),
			NSWindow.NSTitledWindowMask
			| NSWindow.NSMiniaturizableWindowMask);
		wnd.setTitle("Window with drawer");
		wnd.setBackgroundColor(ASColors.lightGrayColor());
		
		//
		// Build right drawer
		//
		var rightDrawer:NSDrawer = (new NSDrawer()).initWithContentSizePreferredEdge(
			new NSSize(100, 100),
			NSRectEdge.NSMaxXEdge);
		rightDrawer.setParentWindow(wnd);
		rightDrawer.setTrailingOffset(10);
		rightDrawer.setLeadingOffset(10);
		
		var drawerContent:ASColoredView = new ASColoredView();
		drawerContent.setBackgroundColor(new NSColor(0xAAFFAA));
		drawerContent.setBorderColor(new NSColor(0x330000));
		rightDrawer.setContentView(drawerContent);
		
		var drawerLbl:ASLabel = (new ASLabel()).initWithFrame(
			new NSRect(5, 5, 90, 22));
		drawerLbl.setStringValue("Right label");
		drawerContent.addSubview(drawerLbl);
		
		//
		// Build left drawer
		//
		var leftDrawer:NSDrawer = (new NSDrawer()).initWithContentSizePreferredEdge(
			new NSSize(100, 100),
			NSRectEdge.NSMinXEdge);
		leftDrawer.setParentWindow(wnd);
		leftDrawer.setTrailingOffset(10);
		leftDrawer.setLeadingOffset(10);
		
		drawerContent = new ASColoredView();
		drawerContent.setBackgroundColor(new NSColor(0xAAAAFF));
		drawerContent.setBorderColor(new NSColor(0x330000));
		leftDrawer.setContentView(drawerContent);
		
		drawerLbl = (new ASLabel()).initWithFrame(
			new NSRect(5, 5, 90, 22));
		drawerLbl.setStringValue("Left label");
		drawerContent.addSubview(drawerLbl);
		
		//
		// Build top drawer
		//
		var topDrawer:NSDrawer = (new NSDrawer()).initWithContentSizePreferredEdge(
			new NSSize(100, 100),
			NSRectEdge.NSMinYEdge);
		topDrawer.setParentWindow(wnd);
		topDrawer.setTrailingOffset(10);
		topDrawer.setLeadingOffset(10);
		
		drawerContent = new ASColoredView();
		drawerContent.setBackgroundColor(new NSColor(0x99AAAA));
		drawerContent.setBorderColor(new NSColor(0x330000));
		topDrawer.setContentView(drawerContent);
		
		drawerLbl = (new ASLabel()).initWithFrame(
			new NSRect(5, 5, 90, 22));
		drawerLbl.setStringValue("Top label");
		drawerContent.addSubview(drawerLbl);
		
		//
		// Build bottom drawer
		//
		var bottomDrawer:NSDrawer = (new NSDrawer()).initWithContentSizePreferredEdge(
			new NSSize(100, 100),
			NSRectEdge.NSMaxYEdge);
		bottomDrawer.setParentWindow(wnd);
		bottomDrawer.setTrailingOffset(10);
		bottomDrawer.setLeadingOffset(10);
		
		drawerContent = new ASColoredView();
		drawerContent.setBackgroundColor(new NSColor(0xFFAAAA));
		drawerContent.setBorderColor(new NSColor(0x330000));
		bottomDrawer.setContentView(drawerContent);
		
		drawerLbl = (new ASLabel()).initWithFrame(
			new NSRect(5, 5, 90, 22));
		drawerLbl.setStringValue("Bottom label");
		drawerContent.addSubview(drawerLbl);
		
		//
		// Build content view for window
		//
		var del:Object = {};
		del.toggleRightDrawer = function() {
			rightDrawer.toggle(this);
		};
		del.toggleLeftDrawer = function() {
			leftDrawer.toggle(this);
		};
		del.toggleTopDrawer = function() {
			topDrawer.toggle(this);
		};
		del.toggleBottomDrawer = function() {
			bottomDrawer.toggle(this);
		};
		
		var view:NSView = wnd.contentView();
		var btn:NSButton = (new NSButton()).initWithFrame(
			new NSRect(10, 10, 150, 22));
		btn.setTitle("Toggle right drawer");
		btn.setTarget(del);
		btn.setAction("toggleRightDrawer");
		view.addSubview(btn);

		var btn2:NSButton = (new NSButton()).initWithFrame(
			new NSRect(10, 35, 150, 22));
		btn2.setTitle("Toggle bottom drawer");
		btn2.setTarget(del);
		btn2.setAction("toggleBottomDrawer");
		view.addSubview(btn2);

		var btn3:NSButton = (new NSButton()).initWithFrame(
			new NSRect(10, 60, 150, 22));
		btn3.setTitle("Toggle left drawer");
		btn3.setTarget(del);
		btn3.setAction("toggleLeftDrawer");
		view.addSubview(btn3);
				
		var btn4:NSButton = (new NSButton()).initWithFrame(
			new NSRect(10, 85, 150, 22));
		btn4.setTitle("Toggle top drawer");
		btn4.setTarget(del);
		btn4.setAction("toggleTopDrawer");
		view.addSubview(btn4);
		
		app.run();
	}
}