/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSComboBox;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.NSTextField;
import org.actionstep.NSWindow;
import org.actionstep.NSColor;
import org.actionstep.NSArray;
import org.actionstep.NSModalSession;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;

/**
 * Tests the <code>org.actionstep.NSComboBox</code> class.
 *
 * @author Richard Kilmer
 */
class org.actionstep.test.ASTestComboBox {
	
	private static var g_app:NSApplication;
	private static var g_appWnd:NSWindow;
	private static var g_nc:NSNotificationCenter;
	
	public static function test():Void
	{
	  var object:Object = new Object();
		var app:NSApplication = g_app = NSApplication.sharedApplication();
		var nc:NSNotificationCenter = g_nc = NSNotificationCenter.defaultCenter();
		var window:NSWindow = g_appWnd = (new NSWindow()).initWithContentRect(new NSRect(0,0,500,500));
		var view:NSView = (new NSView()).initWithFrame(new NSRect(0,0,500,500));

		var comboBox:NSComboBox = new NSComboBox();
		comboBox.initWithFrame(new NSRect(10, 10, 150, 25));
		//comboBox.setEditable(false);
		comboBox.setSelectable(false);
		view.addSubview(comboBox);

		//
		// The modulus operator allows us to test the different ways
		//
		var data:Array = ["Rich", "Dave", "Tom", "Mark", "Ryan", "Ingrid", "Jessica", "Nicolas"];
		comboBox.addItemsWithObjectValues(NSArray.arrayWithArray(data));

		var comboBox2:NSComboBox = new NSComboBox();
		comboBox2.initWithFrame(new NSRect(10, 45, 100, 28));
		comboBox2.setEditable(false);
		comboBox2.setHasVerticalScroller(false);
		comboBox2.addItemsWithObjectValues(NSArray.arrayWithArray(
			["Rich", "Dave", "Tom", "Mark", "Ryan", "Ingrid", "Jessica", "Nicolas"]));
		comboBox2.selectItemWithObjectValue("Tom");
		view.addSubview(comboBox2);

		var tf:NSTextField = new NSTextField();
		tf.initWithFrame(new NSRect(10, 75, 100, 25));
		tf.setBackgroundColor(new NSColor(0xaaaa00));
		tf.setBorderColor(new NSColor(0x000000));
		tf.setDrawsBackground(false);
		view.addSubview(tf);

		var o:Object = new Object();
		o.changed = function(box:NSComboBox) {
		  tf.setStringValue(String(box.objectValueOfSelectedItem()));
		  tf.display();
		};

		comboBox.setTarget(o);
		comboBox.setAction("changed");
		comboBox2.setTarget(o);
		comboBox2.setAction("changed");

		window.setContentView(view);
		app.run();
		
		//
		// Create a modal window
		//
		var mwnd:NSWindow = (new NSWindow()).initWithContentRectStyleMask(
			new NSRect(40, 40, 200, 200),
			NSWindow.NSTitledWindowMask | NSWindow.NSClosableWindowMask);
		mwnd.setLevel(NSWindow.NSModalPanelWindowLevel);
		mwnd.display();
		mwnd.center();
		app.beginSheetModalForWindowModalDelegateDidEndSelectorContextInfo(
			mwnd, 
			null, // not a sheet 
			null, null, null); // no callback
		mwnd["__modalSession"] = app.modalSession();
		g_nc.addObserverSelectorNameObject(ASTestComboBox, "modalWindowWillClose",
			NSWindow.NSWindowWillCloseNotification,
			mwnd);
		mwnd.makeKeyAndOrderFront(true);
		
		//
		// Add a combobox to that window
		//
		var cb3:NSComboBox = new NSComboBox();
		cb3.initWithFrame(new NSRect(10, 45, 100, 28));
		cb3.setEditable(false);
		cb3.setHasVerticalScroller(false);
		cb3.addItemsWithObjectValues(NSArray.arrayWithArray(
			["Rich", "Dave", "Tom", "Mark", "Ryan", "Ingrid", "Jessica", "Nicolas"]));
		cb3.selectItemWithObjectValue("Tom");
		mwnd.contentView().addSubview(cb3);
	}
	
		/**
	 * Called when a modal window is about to close. 
	 */
	private static function modalWindowWillClose(ntf:NSNotification):Void {
		var wnd:NSWindow = NSWindow(ntf.object);
		var sess:NSModalSession = wnd["__modalSession"];
		
		//
		// End the modal session and restore focus to the application window
		//
		g_app.endModalSession(sess);
		g_appWnd.makeMainAndKey();
		
		//
		// Stop observing the window
		//
		g_nc.removeObserverNameObject(ASTestComboBox, 
			NSWindow.NSWindowWillCloseNotification, wnd);
	}
}
