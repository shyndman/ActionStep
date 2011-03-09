/* See LICENSE for copyright and terms of use */

import org.actionstep.rpc.xml.ASXmlDataType;

/**
 * XML-RPC data types
 *
 * @author Scott Hyndman
 */
class org.actionstep.rpc.xmlrpc.ASXmlRpcDataType extends ASXmlDataType {

	public static var StringDataType:ASXmlRpcDataType
		= new ASXmlRpcDataType(1, "string");

	public static var CDataDataType:ASXmlRpcDataType
		= new ASXmlRpcDataType(2, "cdata");

	public static var I4DataType:ASXmlRpcDataType
		= new ASXmlRpcDataType(3, "i4");

	public static var IntDataType:ASXmlRpcDataType
		= new ASXmlRpcDataType(4, "int");

	public static var BoolDataType:ASXmlRpcDataType
		= new ASXmlRpcDataType(5, "boolean");

	public static var DoubleDataType:ASXmlRpcDataType
		= new ASXmlRpcDataType(6, "double");

	public static var DateDataType:ASXmlRpcDataType
		= new ASXmlRpcDataType(7, "dateTime.iso8601");

	public static var Base64DataType:ASXmlRpcDataType
		= new ASXmlRpcDataType(8, "base64");

	public static var StructDataType:ASXmlRpcDataType
		= new ASXmlRpcDataType(9, "struct");

	public static var ArrayDataType:ASXmlRpcDataType
		= new ASXmlRpcDataType(10, "array");

	/**
	 * The name of the datatype's tag.
	 */
	public var tagName:String;

	/**
	 * Creates a new instance of the <code>DataType</code> class.
	 */
	private function ASXmlRpcDataType(value:Number, tagName:String) {
		super(value, tagName);
	}
}