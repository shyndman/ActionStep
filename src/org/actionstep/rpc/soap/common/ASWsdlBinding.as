/* See LICENSE for copyright and terms of use */

import org.actionstep.NSDictionary;
import org.actionstep.rpc.soap.ASSoapConstants;
import org.actionstep.rpc.soap.common.ASWsdlElement;
import org.actionstep.rpc.soap.common.ASWsdlOperation;

/**
 * Represents a WSDL binding element. A binding describes how a port type's
 * operation will be transmitted over the wire.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlBinding extends ASWsdlElement {
	
	/** The name of this binding. */
	public var name:String;
	
	/** The name of the portType associated with this binding. */
	public var typeName:String;
	
	/** Operations covered by this binding. */
	public var operations:NSDictionary;
	
	/** The bindings default style. */
	public var style:String;
	
	/**
	 * Creates a new instance of the <code>ASWsdlBinding</code> class.
	 */
	public function ASWsdlBinding(name:String, typeName:String) {
		this.name = name;
		this.typeName = typeName;
		this.style = ASSoapConstants.STYLE_DOCUMENT;
		operations = NSDictionary.dictionary();
	}
	
	/**
	 * Adds an operation to the port.
	 */
	public function addOperation(op:ASWsdlOperation):Void {
		operations.setObjectForKey(op, op.name);
	}
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		return "ASWsdlBinding(name=" + name + ", typeName=" + typeName 
			+ ", operations=" + operations + ")";
	}
}