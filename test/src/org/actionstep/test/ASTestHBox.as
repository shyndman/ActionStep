/* See LICENSE for copyright and terms of use */

import org.actionstep.layout.ASHBox;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSColor;
import org.actionstep.NSRect;
import org.actionstep.NSWindow;
import org.actionstep.test.ASTestView;

/**
 * Test class for the <code>org.actionstep.layout.ASHBox</code> class.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestHBox {
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
		// Create table
		//
		var hbHolder:ASTestView = ASTestView((new ASTestView()).initWithFrame(
			new NSRect(10, 60, 480, 240)));
		view.addSubview(hbHolder);
		var hb:ASHBox = (new ASHBox()).init();
		hb.setBorder(3);
		hbHolder.addSubview(hb);
		
		var btn1:NSButton = (new NSButton()).initWithFrame(new NSRect(0,0,60,22));
		hb.addView(btn1);
		
		//
		// Create buttons
		//
		var btnAddSeparator:NSButton = (new NSButton()).initWithFrame(new NSRect(10, 10, 100, 26));
		btnAddSeparator.setStringValue("Add Separator");
		view.addSubview(btnAddSeparator);
		
		var btnAddButton:NSButton = (new NSButton()).initWithFrame(new NSRect(115, 10, 100, 26));
		btnAddButton.setStringValue("Add Button");
		view.addSubview(btnAddButton);
		
		//
		// Create delegate
		//
		var del:Object = {};
		del.addSeparator = function()
		{
			hb.addSeparatorWithMinXMargin(3);
		};
		del.addButton = function()
		{
			var btn:NSButton = (new NSButton()).initWithFrame(new NSRect(0,0,60, 22));
			hb.addViewWithMinXMargin(btn, 3);
		};
		
		btnAddSeparator.setTarget(del);
		btnAddSeparator.setAction("addSeparator");

		btnAddButton.setTarget(del);
		btnAddButton.setAction("addButton");
		
		app.run();
	}
}