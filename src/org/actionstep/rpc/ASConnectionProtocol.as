/* See LICENSE for copyright and terms of use */

import org.actionstep.rpc.ASOperation;

/**
 * Represents a connection.
 *
 * @author Scott Hyndman
 */
interface org.actionstep.rpc.ASConnectionProtocol {

	//******************************************************
	//*            Getting URL information
	//******************************************************

	/**
	 * Returns the url of this connection, or <code>null</code> if none
	 * exists.
	 */
	public function URL():String;

	/**
	 * Returns the protocol of this connection's url, or <code>null</code> if
	 * the connection does not have a url or if no protocol is specified by
	 * the url.
	 */
	public function protocol():String;

	/**
	 * Returns the port of this connection's url, or <code>null</code> if
	 * the connection does not have a url or if no port is specified by
	 * the url.
	 */
	public function port():Number;

	//******************************************************
	//*               Setting the delegate
	//******************************************************

	/**
	 * Returns the connector's delegate or <code>null</code> if none exists.
	 */
	public function delegate():Object;

	/**
	 * Sets the delegate of the connection to <code>delegate</code>.
	 *
	 * A delegate can choose to implement the following methods to respond
	 * to the connector's events:
	 *
	 * connectionHandleStatus(Object):Void
	 * connectionHandleResult(Object):Void
	 */
	public function setDelegate(delegate:Object):Void;

	//******************************************************
	//*     Performing operations with the connection
	//******************************************************

	/**
	 * Closes the connection.
	 */
	public function close():Void;

	/**
	 * Invokes a remote method with the name <code>remoteMethod</code>.
	 * <code>responder</code> is the object that will respond to the call.
	 */
	public function call(remoteMethod:ASOperation, responder:Object
			/*, ...*/):Void;
}