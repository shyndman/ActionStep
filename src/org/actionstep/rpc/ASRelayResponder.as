/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;
import org.actionstep.rpc.ASFault;
import org.actionstep.rpc.ASResponderProtocol;
import org.actionstep.rpc.ASResponse;

/**
 * <p>
 * Act as a delegate. Proxies response and fault events to the specified methods
 * on a given object.
 * </p>
 * <h2>Usage:</h2>
 * <p> 
 * <code>_oPendingCall.setResponder( new ASRelayResponder(scope, "responseHandler", "faultHandler") );</code></p>
 * </p>
 * 
 * @author Michael Barbero - http://www.deja-vue.net
 */
class org.actionstep.rpc.ASRelayResponder extends NSObject 
		implements ASResponderProtocol {
	
	//******************************************************
	//*                Member variables
	//******************************************************
	
	private var m_responder:Object;
	private var m_fResponse:String;
	private var m_fFault:String;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Constructs a new instance of the <code>ASRelayResponder</code> class.
	 */
	function ASRelayResponder(responder:Object, fResponse:String, fFault:String) {
		m_responder = responder;
		m_fResponse = fResponse;
		m_fFault = fFault;
	}
	
	//******************************************************
	//*          ASResponderProtocol implementation
	//******************************************************
	
	/**
	 * Called when a problem is encountered when calling the remote method.
	 */
	public function didEncounterError(fault:ASFault):Void {
		m_responder[m_fFault](fault);
	}
	
	/**
	 * Called when a remote method call receives a response.
	 */
	public function didReceiveResponse(response:ASResponse):Void {
		m_responder[m_fResponse](response);
	}
}