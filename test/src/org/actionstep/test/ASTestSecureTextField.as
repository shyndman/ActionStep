/* See LICENSE for copyright and terms of use */

import org.actionstep.*;

/**
 * Tests the <code>org.actionstep.NSSecureTextField</code> class.
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestSecureTextField 
{	
	public static function test():Void
	{
		
		trace("application start");
		var txtPassword:NSSecureTextField;
		var txtField:NSTextField;
		var app:NSApplication = NSApplication.sharedApplication();
		var window:NSWindow = (new NSWindow()).initWithContentRect(new NSRect(0,0,500,500));
		var view:NSView = (new NSView()).initWithFrame(new NSRect(0,0,500,500));
		window.setContentView(view);
		
		txtPassword = new NSSecureTextField();
		txtPassword.initWithFrame(new NSRect(100, 10, 100, 22));
		view.addSubview(txtPassword);
				
		txtField = (new NSTextField()).initWithFrame(new NSRect(10,10,90,22));
		txtField.setDrawsBackground(false);
		txtField.setEditable(false);
		txtField.setStringValue("Password:");
		view.addSubview(txtField);
		
		app.run();
	}
}
