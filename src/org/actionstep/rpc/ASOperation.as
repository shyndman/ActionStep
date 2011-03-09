/* See LICENSE for copyright and terms of use */

import org.actionstep.rpc.ASService;
import org.actionstep.rpc.ASPendingCall;

/**
 * Represents a remote operation.
 *
 * @author Scott Hyndman
 */
interface org.actionstep.rpc.ASOperation {

	//******************************************************
	//*       Getting information about the operation
	//******************************************************

	/**
	 * Returns the name of this operation's method.
	 */
	public function name():String;

	/**
	 * Returns the full name of the operation in the format
	 * serviceName.methodName.
	 */
	public function fullName():String;

	/**
	 * Returns the service owned by this operation.
	 */
	public function service():ASService;

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
			responder:Object):ASPendingCall;
}