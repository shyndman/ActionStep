/* See LICENSE for copyright and terms of use */

import org.actionstep.NSDictionary;
import org.actionstep.rpc.soap.common.ASWsdlElement;
import org.actionstep.rpc.soap.common.ASWsdlPort;

/**
 * Represents a named service. A service has named ports that describe
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlService extends ASWsdlElement {
	
	/** The service's name. */
	public var name:String;
	
	/** Ports in this service. */
	public var ports:NSDictionary;
	
	/**
	 * Creates a new instance of the <code>ASWsdlService</code> class.
	 */
	public function ASWsdlService(name:String) {
		this.name = name;
		ports = NSDictionary.dictionary();
	}
	
	/**
	 * Adds a port to the service.
	 */
	public function addPort(port:ASWsdlPort):Void {
		ports.setObjectForKey(port, port.name);
	}
	
	/**
	 * Returns the port named <code>name</code>. If that port doesn't
	 * exist, and <code>dflt</code> is <code>true</code>, the first port
	 * contained in the service will be returned.
	 */
	public function portWithNameDefault(name:String, dflt:Boolean):ASWsdlPort {
		var port:ASWsdlPort = ASWsdlPort(ports.objectForKey(name));
		if (port == null && dflt) {
			port = ASWsdlPort(ports.allValues().objectAtIndex(0));
		}
		
		return port;
	}
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		return "ASWsdlService(name=" + name + ", ports=" + ports + ")";
	}
}