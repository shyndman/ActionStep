/* See LICENSE for copyright and terms of use */

import org.actionstep.NSDictionary;
import org.actionstep.rpc.soap.common.ASWsdlElement;
import org.actionstep.rpc.soap.common.ASWsdlOperation;

/**
 * <p>
 * Represents a WSDL portType element.
 * </p>
 * <p>
 * A port defines a named set of operations on the web-service.
 * </p>
 * 
 * @see org.actionstep.rpc.soap.common.ASWsdlOperation
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlPortType extends ASWsdlElement {
	
	/** The name of the port */
	public var name:String;
	
	/** Operations contained by this port (operation name -> operation map) */
	public var operations:NSDictionary;
	
	/**
	 * Creates a new instance of the <code>ASWsdlPortType</code> class.
	 */
	public function ASWsdlPortType(name:String) {
		this.name = name;
		operations = NSDictionary.dictionary();
	}
	
	/**
	 * Adds an operation to the port.
	 */
	public function addOperation(op:ASWsdlOperation):Void {
		operations.setObjectForKey(op, op.name);
	}
	
	/**
	 * Returns the operation named <code>name</code>, or <code>null</code> if
	 * it cannot be found.
	 */
	public function operationWithName(name:String):ASWsdlOperation {
		return ASWsdlOperation(operations.objectForKey(name));
	}
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		return "ASWsdlPortType(name=" + name + ", operations=" + operations + ")";
	}
}