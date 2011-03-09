/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.NSArray;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.rpc.ASConnectionProtocol;
import org.actionstep.rpc.ASPendingCall;
import org.actionstep.rpc.ASRpcConstants;
import org.actionstep.rpc.ASService;
import org.actionstep.rpc.xmlrpc.ASXmlRpcDataType;
import org.actionstep.rpc.xml.ASXmlDataType;

/**
 * Represents an XML-RPC operation.
 *
 * @author Scott Hyndman
 */
class org.actionstep.rpc.xml.ASXmlOperation extends NSObject
		implements org.actionstep.rpc.ASOperation {

	//******************************************************
	//*                  Member variables
	//******************************************************

	private var m_name:String;
	private var m_service:ASService;
	private var m_params:NSArray;

	//******************************************************
	//*                   Construction
	//******************************************************

	/**
	 * Constructs a new instance of the <code>ASXmlOperation</code> class.
	 */
	public function ASXmlOperation() {
		m_params = NSArray.array();
	}

	/**
	 * Initializes the operation with the method name <code>name</code> and
	 * the service <code>service</code>.
	 */
	public function initWithNameService(name:String,
			service:ASService):ASXmlOperation {
		m_name = name;
		m_service = service;
		return this;
	}

	//******************************************************
	//*               Describing the object
	//******************************************************

	/**
	 * Returns a string representation of the operation.
	 */
	public function description():String {
		return "ASXmlOperation(fullName=" + fullName() + ",service=" + service()
			+ ")";
	}

	//******************************************************
	//*       Getting information about the operation
	//******************************************************

	/**
	 * Returns the name of this operation's method.
	 */
	public function name():String {
		return m_name;
	}

	/**
	 * Returns the full name of the operation in the format
	 * serviceName.methodName.
	 */
	public function fullName():String {
		return service().name() + "." + name();
	}

	/**
	 * Returns the service owned by this operation.
	 */
	public function service():ASService {
		return m_service;
	}

	//******************************************************
	//*       Setting the expected operation params
	//******************************************************

	/**
	 * Removes all parameter types from the operation.
	 */
	public function resetParameters():Void {
		m_params.removeAllObjects();
	}

	/**
	 * Returns an array of expected parameter types for this method.
	 *
	 * Each element is an instance of <code>ASXmlDataType</code>.
	 */
	public function parameters():NSArray {
		return m_params;
	}

	/**
	 * Adds an expected parameter data type to the method's parameter list.
	 */
	public function addParameter(param:ASXmlDataType):Void {
		m_params.addObject(param);
	}

	//******************************************************
	//*             Invoking the operation
	//******************************************************

	/**
	 * <p>Invokes the remote operation, and returns a pending call.</p>
	 *
	 * <p>If <code>timeout</code> is specified, then it will be treated as the
	 * number of seconds that can pass before the call is marked timed out.</p>
	 */
	public function invokeWithArgsTimeoutResponder(args:Array, timeout:Number,
			responder:Object):ASPendingCall {

		if (timeout == null) {
			timeout = ASRpcConstants.ASNoTimeOut;
		}

		//
		// Trace if necessary
		//
		if (service().isTracingEnabled()) {
			trace(ASDebugger.debug("Invoking " + name() + " on " + service().name()
			));
			trace(ASDebugger.debug("Arguments:<br/>" + ASDebugger.dump(args)));
		}

		var result:ASPendingCall = (new ASPendingCall()).initWithOperation(this);
		result.setResponder(responder);
		result.beginTimeoutWithSeconds(timeout);

		//
		// Build the arguments
		//
		if (null == arguments) {
			args = [];
		} else {
			args = args.concat(); // copy the array
		}

		args.unshift(this, result);

		//
		// Call the service method
		//
		var conn:ASConnectionProtocol = service().connection();
		conn.call.apply(conn, args);

		return result;
	}
	
	//******************************************************
	//*              Getting the call's XML
	//******************************************************

	/**
	 * Gets the XML for the remote method call.
	 */
	public function getXmlWithArgs(args:Array):XML {
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			NSException.ASAbstractMethod,
			"To be implemented by subclasses",
			null);
		trace(e);
		throw e;
		
		return null;
	}
}