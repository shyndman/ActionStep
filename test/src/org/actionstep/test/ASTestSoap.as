/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.rpc.soap.ASSoapConnection;
import org.actionstep.rpc.soap.ASSoapService;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSNotification;
import org.actionstep.NSDate;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestSoap {
	
	
	public static function test():Void {
		//
		// Create and run application
		//
		var app:NSApplication = NSApplication.sharedApplication();
		app.run();
		
		//
		// Create web service connection and load WSDL
		//
		var conn:ASSoapConnection = (new ASSoapConnection()).initWithURL(
			//"http://localhost/ActionStepWebService/WS.asmx?wsdl");
			"http://localhost:8080/WSTest/wsdl/WS.wsdl");
			
		var service:ASSoapService = (new ASSoapService()).initWithNameConnectionTracing(
			"WS", conn, true);
			
		//
		// Watch the connection for loading
		//
		var observer:Object = {};
		observer.serviceDidLoad = function(ntf:NSNotification) {
			trace("ASTestSoap.anonymous function(ntf)");
//			service.Echo("foo");
//			service.MultiplyFloat(4.3, 9.5);
//			service.GetComplexObject();
//			service.GetDates();
//			service.EchoDate((new NSDate()).init());
//			service.GetComplexObjects();
//			service.GetNestedComplexObject();
//			var user:Object = {};
//			user.FirstName = "Foo";
//			user.LastName = "Bar";
//			user.Grades = [40.3, 100.5, 60.3, 68.2];
//			service.EchoComplexObject(user);

			service.echoDate((new NSDate()).init());
			service.echoString("this is a test");
		};
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		nc.addObserverSelectorNameObject(observer, "serviceDidLoad",
			ASSoapService.ASSoapServiceDidLoadNotification,
			service);
	}
}