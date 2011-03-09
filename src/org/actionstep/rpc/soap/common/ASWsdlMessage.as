/* See LICENSE for copyright and terms of use */

import org.actionstep.rpc.soap.common.ASWsdlElement;

/**
 * Represents a WSDL message element.
 * 
 * @see org.actionstep.rpc.soap.common.ASWsdlMessagePart
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlMessage extends ASWsdlElement {
	
	/** The message's name. */
	public var name:String;
	
	/** An array of ASWsdlMessagePart instances. */
	public var parts:Array;
	
	/**
	 * Creates a new instance of the <code>ASWsdlMessage</code> class.
	 */
	public function ASWsdlMessage(name:String) {
		this.name = name;
		parts = [];
	}
	
	/**
	 * Returns a string representation of the message.
	 */
	public function toString():String {
		var ret:String = "ASWsdlMessage(name=" + name + ", parts=[";
		
		//
		// Add parts
		//
		var len:Number = parts.length;
		for (var i:Number = 0; i < len; i++) {
			ret += "\n\t" + parts[i].toString() + (i + 1 < len ? "," : "");
		}
		
		ret += "])"; 
		
		return ret;
	}
}