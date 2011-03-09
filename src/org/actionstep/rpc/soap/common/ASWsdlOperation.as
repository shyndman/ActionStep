/* See LICENSE for copyright and terms of use */

import org.actionstep.rpc.soap.common.ASWsdlElement;
import org.actionstep.rpc.soap.common.ASWsdlOperationIO;
import org.actionstep.rpc.soap.common.ASWsdlSoapOperation;

/**
 * Describes an operation.
 * 
 * @see org.actionstep.rpc.soap.common.ASWsdlPortType
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlOperation extends ASWsdlElement {
	
	/** The operation's name. */
	public var name:String;
	
	/** The operation's input. */
	public var input:ASWsdlOperationIO;
	
	/** The operation's output. */
	public var output:ASWsdlOperationIO;
	
	/** The soap operation. */
	public var soapOperation:ASWsdlSoapOperation;
	
	/**
	 * Creates a new instance of the <code>ASWsdlOperation</code> class.
	 */
	public function ASWsdlOperation(name:String) {
		this.name = name;
	}
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		return "ASWsdlOperation(name=" + name + ",\n"
			+ "\tinput=" + input.toString() + ",\n"
			+ "\toutput=" + output.toString() 
			+ (soapOperation != null 
				? ", soapOperation=" + soapOperation.toString() 
				: "") 
			+ ")";
	}
}