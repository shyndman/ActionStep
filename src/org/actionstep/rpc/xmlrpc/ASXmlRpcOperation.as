/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.rpc.ASService;
import org.actionstep.rpc.xml.ASXmlConstants;
import org.actionstep.rpc.xml.ASXmlOperation;
import org.actionstep.rpc.xmlrpc.ASXmlRpcConstants;
import org.actionstep.rpc.xmlrpc.ASXmlRpcDataType;
import org.actionstep.rpc.xmlrpc.ASXmlRpcSerializer;

/**
 * Represents an XML-RPC operation.
 *
 * @author Scott Hyndman
 */
class org.actionstep.rpc.xmlrpc.ASXmlRpcOperation extends ASXmlOperation {

	//******************************************************
	//*                   Construction
	//******************************************************

	/**
	 * Constructs a new instance of the <code>ASXmlRpcOperation</code> class.
	 */
	public function ASXmlRpcOperation() {
	}

	/**
	 * Initializes the operation with the method name <code>name</code> and
	 * the service <code>service</code>.
	 */
	public function initWithNameService(name:String,
			service:ASService):ASXmlRpcOperation {
		super.initWithNameService(name, service);
		return this;
	}

	//******************************************************
	//*               Describing the object
	//******************************************************

	/**
	 * Returns a string representation of the operation.
	 */
	public function description():String {
		return "ASXmlRpcOperation(fullName=" + fullName() + ",service=" + service()
			+ ")";
	}

	//******************************************************
	//*              Getting the call's XML
	//******************************************************

	/**
	 * Gets the XML for the remote method call.
	 */
	public function getXmlWithArgs(args:Array):XML {
		//
		// Build call XML
		//
		var call:XML = new XML();
		call.ignoreWhite = true;
		call.xmlDecl = ASXmlConstants.XML_DECLARATION;
		call.contentType = ASXmlConstants.XML_CONTENT_TYPE;

		//
		// Create required nodes
		//
		var methodNode:XMLNode = call.createElement(ASXmlRpcConstants.NODE_METHOD_CALL);
		call.appendChild(methodNode);

		var methodName:XMLNode = call.createElement(ASXmlRpcConstants.NODE_METHOD_NAME);
		methodName.appendChild(call.createTextNode(fullName()));
		methodNode.appendChild(methodName);

		var paramsNode:XMLNode = call.createElement(ASXmlRpcConstants.NODE_PARAMS);
		methodNode.appendChild(paramsNode);

		//
		// Build the parameters
		//
		var serializer:ASXmlRpcSerializer = (new ASXmlRpcSerializer()).init();
		var len:Number = args.length;
		for (var i:Number = 0; i < len; i++) {
			var pNode:XMLNode = call.createElement(ASXmlRpcConstants.NODE_PARAM);
			var type:ASXmlRpcDataType = ASXmlRpcDataType(m_params.objectAtIndex(i));
			pNode.appendChild(serializer.serializeObjectWithType(args[i], type));
			paramsNode.appendChild(pNode);
		}

		//
		// Trace if required
		//
		if (service().isTracingEnabled()) {
			var xmlString:String = call.toString();
			xmlString = xmlString.split("<").join("&lt;");
			xmlString = xmlString.split(">").join("&gt;");
			trace(ASDebugger.debug("RPC XML: " + xmlString));
		}

		return call;
	}
}