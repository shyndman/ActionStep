/* See LICENSE for copyright and terms of use */
 
import org.actionstep.layout.ASVBox;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSColor;
import org.actionstep.NSRect;
import org.actionstep.NSTextField;
import org.actionstep.NSWindow;
import org.actionstep.test.ASTestView;

/**
 * Test class for the <code>org.actionstep.layout.ASVBox</code> class.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestVBox {
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
		var hb:ASVBox = (new ASVBox()).init();
		hb.setBorder(3);
		view.addSubview(hb);
		
		var btn1:NSButton = (new NSButton()).initWithFrame(new NSRect(0,0,60,22));
		hb.addView(btn1);
		hb.addSeparatorWithMinYMargin(3);
		var btn2:NSButton = (new NSButton()).initWithFrame(new NSRect(0,0,60,22));
		hb.addViewEnableYResizingWithMinYMargin(btn2, true, 3);
		hb.addSeparatorWithMinYMargin(3);
		var btn3:NSButton = (new NSButton()).initWithFrame(new NSRect(0,0,60,22));
		hb.addViewEnableYResizingWithMinYMargin(btn3, true, 3);
		hb.addSeparatorWithMinYMargin(3);
		var txt:NSTextField = (new NSTextField()).initWithFrame(new NSRect(0,0,100,22));
		hb.addViewEnableYResizingWithMinYMargin(txt, true, 3);
				
		app.run();
	}
}