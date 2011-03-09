/* See LICENSE for copyright and terms of use */

import org.actionstep.rpc.ASConnectionProtocol;

/**
 * @author Scott Hyndman
 */
interface org.actionstep.rpc.ASService {

	//******************************************************
	//*       Getting information about the service
	//******************************************************

	/**
	 * Returns the name of this connection.
	 */
	public function name():String;

	/**
	 * Returns the connection used by this service.
	 */
	public function connection():ASConnectionProtocol;

	//******************************************************
	//*                Setting timeouts
	//******************************************************

	/**
	 * <p>Returns the number in seconds before a remote method call is marked
	 * as being timed out.</p>
	 *
	 * <p>A value of {@link #ASNoTimeOut} means there is no timeout used.</p>
	 */
	public function timeout():Number;

	/**
	 * <p>Sets the amount of time in seconds that will pass before a remote method
	 * call is marked as being timed out.</p>
	 *
	 * <p>This will only affect future server calls, and not calls that are in
	 * process.</p>
	 *
	 * <p>To disable timeouts, pass {@link #ASNoTimeOut} to this method.</p>
	 */
	public function setTimeout(seconds:Number):Void;

	//******************************************************
	//*                Enabling tracing
	//******************************************************

	/**
	 * <p>Returns <code>true</code> if tracing is enabled for this service.</p>
	 *
	 * <p>The default value is <code>false</code>.</p>
	 */
	public function isTracingEnabled():Boolean;

	/**
	 * Sets whether this service traces out messages for debugging purposes.
	 */
	public function setTracingEnabled(flag:Boolean):Void;
}