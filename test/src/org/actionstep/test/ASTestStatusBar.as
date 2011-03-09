/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSImage;
import org.actionstep.NSImageRep;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSStatusBar;
import org.actionstep.NSStatusItem;
import org.actionstep.NSWindow;
import org.actionstep.test.windowStyles.ASTestWindowIconRep;
import org.actionstep.ASColors;

/**
 * Tests the <code>org.actionstep.NSStatusBar</code> class.
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestStatusBar {
	public static function test():Void
	{
		var app:NSApplication = NSApplication.sharedApplication(),
		window1:NSWindow = (new NSWindow()).initWithContentRect(new NSRect(0,22,400,250));
		window1.setBackgroundColor(ASColors.lightGrayColor());

		//
		// Create the first status bar item.
		//
		var sb:NSStatusBar = NSStatusBar.systemStatusBar();
		var si:NSStatusItem = sb.statusItemWithLength(100);
		si.setTitle("Test");
		var image:NSImage = new NSImage();
		image.init();
		var rep:NSImageRep = new ASTestWindowIconRep();
		rep.setSize(new NSSize(12, 12));
		image.addRepresentation(rep);
		si.setImage(image);
		si.setAlternateImage(NSImage.imageNamed("NSScrollerUpArrow"));

		var si2:NSStatusItem = sb.statusItemWithLength(40);
		si2.setTitle("Test 2");

		app.run();

		var obj:Object = {};
		obj.pressItem1 = function() {
			trace("pressItem1");
		};
		obj.pressItem2 = function() {
			trace("pressItem2");
		};
		obj.dblClickItem1 = function() {
			trace("dblClickItem1");
		};

		si.setTarget(obj);
		si.setAction("pressItem1");
		si.setDoubleAction("dblClickItem1");
		si2.setTarget(obj);
		si2.setAction("pressItem2");
	}
}