/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSRect;
import org.actionstep.NSTextField;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.rpc.ASFault;
import org.actionstep.rpc.ASResponse;
import org.actionstep.rpc.remoting.ASRemotingPendingCall;
import org.actionstep.rpc.remoting.ASRemotingService;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestRemoting {
	public static function test():Void {
		//
		// Create app and window
		//
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0,0,400,300));
		var stage:NSView = wnd.contentView();

		//
		// Create controls
		//
		var btn:NSButton = (new NSButton()).initWithFrame(
			new NSRect(10, 10, 100, 22));
		btn.setTitle("Trigger");
		stage.addSubview(btn);

		var res:NSTextField = (new NSTextField()).initWithFrame(
			new NSRect(10, 35, 100, 22));
		res.setEditable(false);
		stage.addSubview(res);

		//
		// Create the service object
		//
		var service:ASRemotingService = (new ASRemotingService()).initWithNameGatewayURLTracing(
			"HelloWorld",  // service name
			"http://localhost:80/amfphp/gateway.php", // gateway URL
			true); // will trace status messages

		//
		// Set the timeout
		//
		// service.setTimeout(2);
		
		//
		// Create and set the responder
		//
		var responder:Object = {};
		responder.didReceiveResponse = function(response:ASResponse):Void {
			res.setStringValue(response.response().toString());
			res.setNeedsDisplay(true);
		};
		responder.didEncounterError = function(fault:ASFault):Void {
			res.setStringValue(fault.description());
			res.setNeedsDisplay(true);
		};

		//
		// Set up action handlers
		//
		var del:Object = {};
		del.triggerService = function(b:NSButton):Void {
			//
			// Call the server
			//
			var call:ASRemotingPendingCall = service.say("45");
			call.setResponder(responder);
		};

		btn.setTarget(del);
		btn.setAction("triggerService");

		//
		// Run the app
		//
		app.run();
	}
}