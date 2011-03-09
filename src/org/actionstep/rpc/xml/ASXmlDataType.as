/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Abstract base class for XML data types.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.xml.ASXmlDataType extends ASConstantValue {
	
	/**
	 * The name of the datatype's tag.
	 */
	public var tagName:String;

	/**
	 * Creates a new instance of the <code>DataType</code> class.
	 */
	private function ASXmlDataType(value:Number, tagName:String) {
		super(value);
		this.tagName = tagName;
	}
}