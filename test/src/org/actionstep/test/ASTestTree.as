/* See LICENSE for copyright and terms of use */

import org.actionstep.ASTreeView;
import org.actionstep.constants.NSBorderType;
import org.actionstep.NSApplication;
import org.actionstep.NSRect;
import org.actionstep.NSScrollView;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.tree.ASXmlTreeDelegate;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestTree {
	public static function test():Void {
		//
		// Create the app and the window
		//
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0, 0, 800, 600));
		var stg:NSView = wnd.contentView();
		
		//
		// Build a scrollview
		//
		var sv:NSScrollView = (new NSScrollView()).initWithFrame(
			new NSRect(20, 20, 200, 200));
		sv.setBorderType(NSBorderType.NSBezelBorder);
		sv.setHasHorizontalScroller(true);
		sv.setHasVerticalScroller(true);
		stg.addSubview(sv);
			
		//
		// Build the tree delegate
		//
		var xml:XML = new XML(
			"<root>" + generateXmlString(6, "") + "</root>");
		var del:ASXmlTreeDelegate = (new ASXmlTreeDelegate()).initWithXmlTitleKey(
			xml.firstChild, "name");
		
		//
		// Build the tree
		//
		var tree:ASTreeView = (new ASTreeView()).initWithFrame(
			new NSRect(0, 0, 150, 22));
		tree.setDelegate(del);
		tree.setAcceptsAlphaNumericalKeys(true);
		sv.setDocumentView(tree);
		
		//
		// Run the application
		//
		wnd.setInitialFirstResponder(tree);
		app.run();
		
		
	}
	
	/**
	 * Generates an XML string representing a tree of random data.
	 */
	private static function generateXmlString(depth:Number, path:String):String {
		var ret:String = "";
		var items:Number = random(11) + depth - 3;
		for (var i:Number = 0; i < items; i++) {
			var name:String = path;
			if (path.length > 0) {
				name += ".";
			}
			name += i;
			
			if (random(20) == 0) {
				name = "toronto";
			}
			
			ret += "<item name='" + name + "'>";
			if (depth > 0) {
				ret += generateXmlString(depth - 1, name);
			}
			ret += "</item>";
		}
		
		return ret;
	}
}