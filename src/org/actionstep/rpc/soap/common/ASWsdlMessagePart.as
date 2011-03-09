import org.actionstep.rpc.soap.ASSoapDataType;
/* See LICENSE for copyright and terms of use */

/**
 * Represent's a single part within a WSDL message.
 * 
 * @see org.actionstep.rpc.soap.common.ASWsdlMessage
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlMessagePart {
	
	/** The name of the part. */
	public var name:String;
	
	/** The type name of the part. */
	public var typeName:String;
	
	/** The part's data type. */
	public var type:ASSoapDataType;
	
	/** The element name of the part. */
	public var elementName:String;
	
	/**
	 * Creates a new instance of the <code>ASWsdlMessagePart</code> class.
	 */
	public function ASWsdlMessagePart(name:String, typeName:String, elementName:String) {
		this.name = name;
		this.typeName = typeName;
		this.elementName = elementName;
	}
	
	/**
	 * Returns a string representation of the part.
	 */
	public function toString():String {
		if (typeName != null) {
			return "ASWsdlMessagePart(name=" + name + ", typeName=" + typeName + ")";
		} else { // elementName != null
			return "ASWsdlMessagePart(name=" + name + ", elementName=" + elementName + ")";
		}
	}
}