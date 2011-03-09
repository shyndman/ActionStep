/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.NSObject;
import org.actionstep.rpc.ASConnectionProtocol;
import org.actionstep.rpc.ASPendingCall;
import org.actionstep.rpc.ASService;
import org.actionstep.rpc.remoting.ASRemotingPendingCall;

/**
 * Represents a remote operation.
 *
 * @author Scott Hyndman
 */
class org.actionstep.rpc.remoting.ASRemotingOperation extends NSObject
		implements org.actionstep.rpc.ASOperation {

	//******************************************************
	//*                  Member variables
	//******************************************************

	private var m_name:String;
	private var m_service:ASService;

	//******************************************************
	//*                   Construction
	//******************************************************

	/**
	 * Constructs a new instance of the <code>ASOperation</code> class.
	 */
	public function ASOperation() {
	}

	/**
	 * Initializes the operation with the method name <code>name</code> and
	 * the service <code>service</code>.
	 */
	public function initWithNameService(name:String,
			service:ASService):ASRemotingOperation {
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
		return "ASOperation(fullName=" + fullName() + ",service=" + service()
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

		//
		// Trace if necessary
		//
		if (service().isTracingEnabled()) {
			trace(ASDebugger.debug("Invoking " + name() + " on " + service().name()
			));
			trace(ASDebugger.debug("Arguments:<br/>" + ASDebugger.dump(args)));
		}

		var result:ASPendingCall = (new ASRemotingPendingCall()).
			initWithOperation(this);
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
}