/* See LICENSE for copyright and terms of use */

import org.actionstep.rpc.soap.common.ASWsdlElement;

/**
 * Represent's a service's port.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlPort extends ASWsdlElement {
	
	/** The name of this port */
	public var name:String;
	
	/** The name of the binding associated with this port */
	public var bindingName:String;
	
	/** The port's address */
	public var address:String;
	
	/**
	 * Creates a new instance of the <code>ASWsdlPort</code> class.
	 */
	public function ASWsdlPort(name:String, bindingName:String, address:String) {
		this.name = name;
		this.bindingName = bindingName;
		this.address = address;
	}
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		return "ASWsdlPort(name=" + name + ", bindingName=" + bindingName 
			+ ", address=" + address + ")";
	}
}