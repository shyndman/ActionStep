/* See LICENSE for copyright and terms of use */

import org.actionstep.*;
import org.actionstep.test.ASTestView;
//import org.actionstep.constants.*;

class org.actionstep.test.ASTestCursors {
	public static function test() {
		var app:NSApplication = NSApplication.sharedApplication();
		var window:NSWindow = (new NSWindow()).initWithContentRect(new NSRect(0,0,500,500));
		var view:ASTestView = ASTestView((new ASTestView()).initWithFrame(new NSRect(0,0,500,500)));
		view.setBackgroundColor(new NSColor(0x995555));
		window.setContentView(view);
		
		var cb:NSComboBox = (new NSComboBox()).initWithFrame(
			new NSRect(260, 50, 100, 25));
		cb.setEditable(true);
		view.addSubview(cb);
		
		var tf:NSTextField = (new NSTextField()).initWithFrame(
			new NSRect(260, 80, 100, 25));
		tf.setEditable(true);
		view.addSubview(tf);
		
		var view2:ASTestView = ASTestView((new ASTestView()).initWithFrame(new NSRect(50, 50, 200, 200)));
		view.addSubview(view2);
		view2.setBackgroundColor(new NSColor(0x009900));
		app.run();
		
		view2.addCursorRectCursor(
			new NSRect(0, 0, 200, 200),
			NSCursor.resizeUpDownCursor());
			
		view2.addCursorRectCursor(
			new NSRect(20, 20, 160, 160),
			NSCursor.resizeLeftCursor());
			
		view2.addCursorRectCursor(
			new NSRect(30, 30, 140, 140),
			NSCursor.resizeUpCursor());
			
		view2.addCursorRectCursor(
			new NSRect(40, 40, 120, 120),
			NSCursor.resizeDownCursor());
			
		view2.addCursorRectCursor(
			new NSRect(50, 50, 100, 100),
			NSCursor.resizeLeftRightCursor());
			
		view2.addCursorRectCursor(
			new NSRect(60, 60, 80, 80),
			NSCursor.resizeRightCursor());
			
		view2.addCursorRectCursor(
			new NSRect(70, 70, 60, 60),
			NSCursor.crosshairCursor());
			
		NSCursor.setUseSystemArrowCursor(true);
	}
	
	public static function mouseEntered(event:NSEvent):Void {
		trace("ASTestCursors.mouseEntered(event)");
	}
	
	public static function mouseExited(event:NSEvent):Void {
		trace("ASTestCursors.mouseExited(event)");
	}
}