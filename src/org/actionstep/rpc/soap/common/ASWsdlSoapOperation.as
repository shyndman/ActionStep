/* See LICENSE for copyright and terms of use */

import org.actionstep.rpc.soap.ASSoapConstants;
import org.actionstep.rpc.soap.common.ASWsdlElement;

/**
 * Represents a soap:operation element.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlSoapOperation extends ASWsdlElement {
	
	/** The operation's action. */
	public var soapAction:String;
	
	/** The operation's style. */
	public var style:String;
	
	/**
	 * Creates a new instance of the <code>ASSoapOperation</code> class.
	 */
	public function ASWsdlSoapOperation(soapAction:String, style:String) {
		this.soapAction = soapAction;
		this.style = style;
		
		if (this.style == null) {
			this.style = ASSoapConstants.STYLE_DOCUMENT;
		}
	}
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		var ret:String = "ASSoapOperation(soapAction=" + soapAction;
		if (style != null) {
			ret += ", style=" + style;
		}
		ret += ")";
				
		return ret;
	}
}