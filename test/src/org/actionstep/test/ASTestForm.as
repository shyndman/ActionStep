/* See LICENSE for copyright and terms of use */ 

import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSColor;
import org.actionstep.NSForm;
import org.actionstep.NSRect;
import org.actionstep.NSTextField;
import org.actionstep.NSWindow;
import org.actionstep.test.ASTestView;
import org.actionstep.NSFormCell;

/**
 * Test class for <code>org.actionstep.NSForm</code>.
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestForm 
{		
	public static function test():Void {
		var txtLabel:NSTextField;
		var btnAdd:NSButton;
		var app:NSApplication = NSApplication.sharedApplication();
		var window:NSWindow = (new NSWindow()).initWithContentRect(new NSRect(0,0,500,500));
		var view:ASTestView = ASTestView((new ASTestView()).initWithFrame(new NSRect(0,0,500,500)));
		view.setBackgroundColor(new NSColor(0x995555));
		window.setContentView(view);
		
		//
		// Create form
		//
		var form:NSForm = NSForm((new NSForm()).initWithFrame(new NSRect(10, 40, 300, 400)));
		form.setEntryWidth(300);
		form.setInterlineSpacing(10);
		form.setTextAlignment(NSTextAlignment.NSRightTextAlignment);
		view.addSubview(form);
		
		//
		// Add some test entries
		//
		form.addEntry("Foo");
		form.addEntry("Bar");
		form.addEntry("Testeroo");
		form.setNeedsDisplay(true);
		
		//
		// Create test controls:
		//
		var controller:Object = new Object(); // Build controller.
		controller.addEntry = function()
		{
			var cell:NSFormCell = form.addEntry(txtLabel.stringValue());
		};
		
		//
		// Label
		//
		txtLabel = (new NSTextField()).initWithFrame(new NSRect(10, 10, 100, 20));
		view.addSubview(txtLabel);
		
		//
		// Add button
		//
		btnAdd = (new NSButton()).initWithFrame(new NSRect(120, 10, 80, 20));
		btnAdd.setTitle("Add Entry");
		btnAdd.setTarget(controller);
		btnAdd.setAction("addEntry");
		
		view.addSubview(btnAdd);
		
		window.setInitialFirstResponder(txtLabel);
		txtLabel.setNextKeyView(btnAdd);
		btnAdd.setNextKeyView(form);
		form.setNextKeyView(txtLabel);
		
		//
		// Run app
		//
		app.run();
	}
}
