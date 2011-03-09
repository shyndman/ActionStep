/* See LICENSE for copyright and terms of use */

import org.actionstep.rpc.soap.common.ASWsdlElement;

/**
 * Represents a soap:body element.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlSoapBody extends ASWsdlElement {
	
	/** literal or encoded */
	public var use:String;
	
	/**
	 * Creates a new instance of the <code>ASSoapBody</code> class.
	 */
	public function ASWsdlSoapBody(use:String) {
		this.use = use;
	}
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		return "ASSoapBody(use= " + use + ")";
	}
}