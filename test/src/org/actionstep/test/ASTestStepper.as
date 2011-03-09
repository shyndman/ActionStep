/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.NSBezelStyle;
import org.actionstep.constants.NSScrollerPart;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSEvent;
import org.actionstep.NSRect;
import org.actionstep.NSScroller;
import org.actionstep.NSStepper;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.test.ASTestView;
import org.actionstep.NSTextField;

/**
 * Tests the <code>org.actionstep.NSStepper</code> control.
 * 
 * @author Tay Ray Chuan
 */
class org.actionstep.test.ASTestStepper {
	public static function test() {

		var app:NSApplication = NSApplication.sharedApplication();
		var window1:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0,20,250,300));
		var view:NSView = window1.contentView();
		
		
		var tf:NSTextField = (new NSTextField()).initWithFrame(
			new NSRect(10, 10, 200, 25));
		view.addSubview(tf);
		
		var btn:NSButton = (new NSButton()).initWithFrame(
			new NSRect(10, 40, 200, 25));
		view.addSubview(btn);
		
		var stepper:NSStepper = (new NSStepper()).initWithFrame(
			new NSRect(10, 70, 100, 25));
		stepper.setAutorepeat(true);
		view.addSubview(stepper);	
		
		//
		// Set up tab order
		//	
		window1.setInitialFirstResponder(tf);
		tf.setNextKeyView(btn);
		btn.setNextKeyView(stepper);
		stepper.setNextKeyView(tf);
		
		app.run();
	}
}
