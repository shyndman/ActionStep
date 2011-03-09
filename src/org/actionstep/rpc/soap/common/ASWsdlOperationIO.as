/* See LICENSE for copyright and terms of use */

import org.actionstep.rpc.soap.common.ASWsdlElement;
import org.actionstep.rpc.soap.common.ASWsdlSoapBody;

/**
 * Represents the input or the output of an operation. 
 * 
 * @see org.actionstep.rpc.soap.common.ASWsdlOperation
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlOperationIO extends ASWsdlElement {
	
	/** The soap body. */
	public var body:ASWsdlSoapBody;
	
	/** 
	 * The name of the message associated with this operation input or
	 * output.
	 */
	public var messageName:String;
	
	/**
	 * Creates a new instance of the <code>ASWsdlOperationIO</code> class.
	 */
	public function ASWsdlOperationIO(messageName:String) {
		this.messageName = messageName;
	}
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		if (messageName != null) {
			return "ASWsdlOperationIO(messageName=" + messageName + ")";
		} else { // body != null
			return "ASWsdlOperationIO(body=" + body.toString() + ")";
		}
	}
}