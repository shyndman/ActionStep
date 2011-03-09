/* See LICENSE for copyright and terms of use */

import org.actionstep.NSBrowserCell;
import org.actionstep.NSApplication;
import org.actionstep.NSWindow;
import org.actionstep.NSRect;
import org.actionstep.ASColors;
import org.actionstep.NSView;
import org.actionstep.NSBrowser;
import org.actionstep.browser.ASXmlBrowserDelegate;
import org.actionstep.NSButton;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestBrowser {
	public static function test():Void {
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0, 0, 600, 300));
		wnd.setBackgroundColor(ASColors.greenColor().adjustColorBrightnessByFactor(1.2));
		var view:NSView = wnd.contentView();
		
		//
		// Build browser delegate (which supplies data to the browser)
		//
		var xml:XML = new XML(
			"<root>" + generateXmlString(4, "") + "</root>");
		var del:ASXmlBrowserDelegate = (new ASXmlBrowserDelegate()).initWithXmlTitleKey(
			xml.firstChild, "name");
		
		//
		// Build browser
		//
		var browser:NSBrowser = (new NSBrowser()).initWithFrame(
			new NSRect(10, 10, 580, 200));
		browser.setAllowsMultipleSelection(false);
		browser.setTakesTitleFromPreviousColumn(true);
		browser.setMaxVisibleColumns(3);
		browser.setReusesColumns(false);
		browser.setDelegate(del);
		browser.setHasHorizontalScroller(true);
		browser.setTitled(true);
		view.addSubview(browser);
		wnd.setInitialFirstResponder(browser);

		//
		// Builds a button
		//
		var btn:NSButton = (new NSButton()).initWithFrame(
			new NSRect(10, 215, 120, 22));
		btn.setTitle("Test button");
		view.addSubview(btn);
		
		//
		// Tab order
		//
		browser.setNextKeyView(btn);
		btn.setNextKeyView(browser);
		
		app.run();
	}
	
	private static function generateXmlString(depth:Number, path:String):String {
		var ret:String = "";
		var items:Number = random(11) + depth - 3;
		for (var i:Number = 0; i < items; i++) {
			var name:String = path;
			if (path.length > 0) {
				name += ".";
			}
			name += i;
			ret += "<item name='" + name + "'>";
			if (depth > 0) {
				ret += generateXmlString(depth - 1, name);
			}
			ret += "</item>";
		}
		
		return ret;
	}
}