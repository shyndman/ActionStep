/* See LICENSE for copyright and terms of use */

import org.actionstep.rpc.ASFault;
import org.actionstep.rpc.ASResponse;

/**
 * This interface can be implemented by classes that wish to act as responders
 * for remote method calls, although it doesn't have to be. This is merely
 * provided to show you what methods can be called on remote methods, and
 * provide some type safety to your classes.
 *
 * @author Scott Hyndman
 */
interface org.actionstep.rpc.ASResponderProtocol {

	/**
	 * Called when a remote method call receives a response.
	 */
	function didReceiveResponse(response:ASResponse):Void;

	/**
	 * Called when a problem is encountered when calling the remote method.
	 */
	function didEncounterError(fault:ASFault):Void;
}