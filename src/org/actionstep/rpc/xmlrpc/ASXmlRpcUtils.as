import org.actionstep.rpc.xmlrpc.ASXmlRpcConstants;
/* See LICENSE for copyright and terms of use */

/**
 * Utility methods for XML-RPC
 *
 * @author Scott Hyndman
 */
class org.actionstep.rpc.xmlrpc.ASXmlRpcUtils {

	/**
	 * Creates a new instance of the <code>ASXmlRpcUtils</code> class.
	 */
	private function ASXmlRpcUtils() {
	}

	/**
	 * Returns true if response represents a fault.
	 */
	public static function isFaultResponse(response:XML):Boolean {
		return response.firstChild.firstChild.nodeName == ASXmlRpcConstants.NODE_FAULT;
	}
}