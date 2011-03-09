/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.ASUtils;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.NSTimer;
import org.actionstep.rpc.ASFault;
import org.actionstep.rpc.ASOperation;
import org.actionstep.rpc.ASResponse;
import org.actionstep.rpc.ASRpcConstants;
import org.actionstep.rpc.ASService;

/**
 * Represents a pending remote method call. The responder property might be
 * of interest. It is an object with methods that will be called when the
 * remote method responds. See {@link #setResponder()} for more details.
 *
 * Please note that the pending call's responder, can, but doesn't have to
 * implement {@link org.actionstep.remoting.ASResponderProtocol}. It is
 * merely there to help.
 *
 * @author Scott Hyndman
 */
class org.actionstep.rpc.ASPendingCall extends NSObject {

	//******************************************************
	//*                   Constants
	//******************************************************

	private static var RESPONDER_RESULT_METHOD:String	= "didReceiveResponse";
	private static var RESPONDER_FAULT_METHOD:String	= "didEncounterError";

	//******************************************************
	//*                Member variables
	//******************************************************

	private var m_responder:Object;
	private var m_operation:ASOperation;
	private var m_timeoutTimer:NSTimer;
	private var m_hasTimedOut:Boolean;

	//******************************************************
	//*                 Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>ASPendingCall</code> class.
	 */
	public function ASPendingCall() {
		m_hasTimedOut = false;
	}

	/**
	 * Initializes the pending call with the operation <code>operation</code>.
	 */
	public function initWithOperation(operation:ASOperation):ASPendingCall {
		m_operation = operation;
		return this;
	}

	//******************************************************
	//*             Describing the object
	//******************************************************

	/**
	 * Returns a string representation of the ASPendingCall instance.
	 */
	public function description():String {
		return "ASPendingCall(operation=" + operation() + ",responder=" +
			responder() + ")";
	}

	//******************************************************
	//*        Releasing the object from memory
	//******************************************************

	/**
	 * Releases the internal properties of this pending call.
	 */
	public function release():Boolean {
		m_operation = null;
		m_responder = null;
		return super.release();
	}

	//******************************************************
	//*          Starting the timeout counter
	//******************************************************

	/**
	 * Begins the countdown timer with a time of <code>seconds</code>.
	 */
	public function beginTimeoutWithSeconds(seconds:Number):Void {
		//
		// Stop the current timer if there is one.
		//
		if (m_timeoutTimer != null) {
			m_timeoutTimer.invalidate();
			m_timeoutTimer.release();
			m_timeoutTimer = null;
		}

		//
		// Don't do anything if there is no timeout specified.
		//
		if (seconds == ASRpcConstants.ASNoTimeOut) {
			return;
		}

		m_timeoutTimer = new NSTimer();
		m_timeoutTimer.initWithFireDateIntervalTargetSelectorUserInfoRepeats(
			new Date(), seconds, this, "callDidTimeout", null, false);
	}

	//******************************************************
	//*      Setting / getting the responder object
	//******************************************************

	/**
	 * Returns the responder of this remote method call.
	 */
	public function responder():Object {
		return m_responder;
	}

	/**
	 * <p>Sets the responder of this remote method call to <code>responder</code>.</p>
	 *
	 * <p>
	 * This object should implement two methods:
	 * <ul>
	 * <li>
	 * <code>didReceiveResponse(ASResponse):Void</code> - Called when a remote
	 * method call receives a response.
	 * </li>
	 * <li>
	 * <code>didEncounterError(ASFault):Void</code> - Called when a problem is
	 * encountered when calling the remote method.
	 * </li>
	 * </ul>
	 * </p>
	 */
	public function setResponder(responder:Object):Void {
		m_responder = responder;
	}

	//******************************************************
	//*        Getting the pending call's operation
	//******************************************************

	/**
	 * Returns this pending call's operation.
	 */
	public function operation():ASOperation {
		return m_operation;
	}

	//******************************************************
	//*              Internal event handlers
	//******************************************************

	/**
	 * Fired when a response is received from the server.
	 */
	private function onResult(result:Object):Void {
		//
		// Do nothing if we've timed out, or if we haven't stop the timer.
		//
		if (m_hasTimedOut) {
			return;
		} else {
			m_timeoutTimer.invalidate();
			m_timeoutTimer = null;
		}

		var service:ASService = operation().service();

		//
		// Trace if necessary
		//
		if (service.isTracingEnabled()) {
			trace(ASDebugger.debug(service.name() + "."+ operation().name() + "() returned "
				+ ASDebugger.dump(result)));
		}

		//
		// Check the responder to make sure it can respond.
		//
		var res:Object = responder();
		if (res != null
				&& ASUtils.respondsToSelector(res, RESPONDER_RESULT_METHOD)) {
			var response:ASResponse = (new ASResponse()
				).initWithContentsOfResponse(result);

			//
			// Call the responder
			//
			try {
				res[RESPONDER_RESULT_METHOD](response);
			} catch (e:NSException) {
				trace(asError(e.toString()));
			}
		}
	}

	/**
	 * Fired when an error is encountered during the remote call.
	 */
	private function onStatus(status:Object):Void {
		//
		// Do nothing if we've timed out, or stop the timer if we haven't.
		//
		if (m_hasTimedOut) {
			return;
		} else {
			m_timeoutTimer.invalidate();
			m_timeoutTimer = null;
		}

		//
		// Check to see if the responder can respond.
		//
		var res:Object = responder();
		if (res != null
				&& ASUtils.respondsToSelector(res, RESPONDER_FAULT_METHOD)) {
			var fault:ASFault = (new ASFault()
				).initWithContentsOfFault(status);

			//
			// Call the responder
			//
			try {
				res[RESPONDER_FAULT_METHOD](fault);
			} catch (e:NSException) {
				trace(asError(e.toString()));
			}
		}

		//
		// Trace if necessary
		//
		var service:ASService = operation().service();
		if (service.isTracingEnabled()) {
			trace(ASDebugger.debug("Service invocation failed."));
			trace(ASDebugger.debug(service.name() + "."+ operation().name() + "() returned "
				+ ASDebugger.dump(status)));
		}
	}

	/**
	 * Callback for the timeout timer.
	 */
	private function callDidTimeout(timer:NSTimer):Void {
		m_hasTimedOut = true;
		m_timeoutTimer = null;

		//
		// Trace if necessary
		//
		var service:ASService = operation().service();
		if (service.isTracingEnabled()) {
			trace(ASDebugger.debug("Service invocation failed."));
			trace(ASDebugger.debug(service.name() + "."+ operation().name() + "() timed out."
			));
		}

		//
		// Return if invalid responder
		//
		var res:Object = responder();
		if (res == null
				|| !ASUtils.respondsToSelector(res, RESPONDER_FAULT_METHOD)) {
			return;
		}

		//
		// Build fault
		//
		var f:Object = {
			detail: "Timeout occured",
			faultcode: "SERVER.TIMEOUT",
			type: "TimeoutError",
			faultstring: "A timeout occured while calling "
				+ operation().fullName()
		};

		var fault:ASFault = (new ASFault()).initWithContentsOfFault(f);

		//
		// Call the responder
		//
		try {
			res[RESPONDER_FAULT_METHOD](fault);
		} catch (e:NSException) {
			asError(e.toString());
		}
	}

	/**
	 * FIXME When does this get called?
	 */
	private function onFault(fault:Object):Void {
		trace("ASPendingCall.onFault(fault)");
	}
}