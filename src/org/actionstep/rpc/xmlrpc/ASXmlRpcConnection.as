/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.rpc.ASOperation;
import org.actionstep.rpc.xml.ASXmlConnection;
import org.actionstep.rpc.xmlrpc.ASXmlRpcOperation;
import org.actionstep.rpc.xmlrpc.ASXmlRpcSerializer;
import org.actionstep.rpc.xmlrpc.ASXmlRpcUtils;

/**
 * Concrete implementation of an XML connection.
 *
 * @author Scott Hyndman
 */
class org.actionstep.rpc.xmlrpc.ASXmlRpcConnection extends ASXmlConnection {

	private var m_pendingCalls:NSDictionary;
	private var m_callCounter:Number;

	//******************************************************
	//*                  Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>ASXmlRpcConnection</code> class.
	 */
	public function ASXmlRpcConnection() {
	}

	//******************************************************
	//*     Performing operations with the connection
	//******************************************************

	/**
	 * Closes the connection.
	 */
	public function close():Void {
		// do nothing
	}

	//******************************************************
	//*                  Event handlers
	//******************************************************

	/**
	 * Fired when the XML-RPC call finishes.
	 */
	private function connectionOnLoad(success:Boolean, callID:Number):Void {
		//
		// Get call object and remove it from the pending set
		//
		var callObj:Object = m_pendingCalls.objectForKey(callID.toString());
		m_pendingCalls.removeObjectForKey(callID.toString());

		//
		// Deal with call properties
		//
		var response:XML = callObj.xml;
		callObj.xml = null;
		response.onLoad = null;

		var responder:Object = callObj.responder;
		callObj.responder = null;

		//
		// Server failure
		//
		if (!success) {
			connectionOnStatus(null);
			return;
		}

		//
		// Deserialize fault or response
		//
		
		var serializer:ASXmlRpcSerializer = (new ASXmlRpcSerializer()).init();
		if (ASXmlRpcUtils.isFaultResponse(response)) {
			var fault:Object = serializer.deserializeFaultWithXml(response);
			connectionOnStatus(fault);
			responder.onStatus(fault);
		} else {
			var res:Object = serializer.deserializeResponseWithXml(response);
			connectionOnResult(res);
			responder.onResult(res);
		}

//		var xmlString:String = response.toString();
//		xmlString = xmlString.split("<").join("&lt;");
//		xmlString = xmlString.split(">").join("&gt;");
//		trace(ASDebugger.debug("RPC XML: " + xmlString));
	}
}