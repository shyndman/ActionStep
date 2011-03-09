/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.rpc.xmlrpc.ASXmlRpcConnection;
import org.actionstep.rpc.xml.ASXmlConnection;
import org.actionstep.rpc.xmlrpc.ASXmlRpcService;
import org.actionstep.rpc.xmlrpc.ASXmlRpcOperation;
import org.actionstep.rpc.xmlrpc.ASXmlRpcDataType;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestXmlRpc {
	public static function test():Void {
		//
		// Create app
		//
		var app:NSApplication = NSApplication.sharedApplication();
		app.run();
		
		//
		// Create connection
		//
		var conn:ASXmlConnection = (new ASXmlRpcConnection()).initWithURL(
			"http://localhost:8080/cShare/xmlrpc");
		var service:ASXmlRpcService = (new ASXmlRpcService()).initWithNameConnectionTracing(
			"cShareService", conn, true);
			
		//
		// Build method
		//
		var op:ASXmlRpcOperation = service.addRemoteOperationWithName("add");
		//op.addParameter(ASXmlRpcDataType.IntDataType);
		//op.addParameter(ASXmlRpcDataType.IntDataType);
		
		//
		// Invoke method
		//
		service.login("scott", "foo");
		//service.getCWD();
	}
}