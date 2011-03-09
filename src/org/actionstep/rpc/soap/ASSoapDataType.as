/* See LICENSE for copyright and terms of use */

import org.actionstep.rpc.xml.ASXmlDataType;

/**
 * <p>
 * SOAP data types.
 * </p>
 * <p>
 * Please note that <code>#ComplexDataType</code> is copied when used, to store
 * a different object map. Compare data types using <code>#value</code>, not
 * through reference comparison.
 * </p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.ASSoapDataType extends ASXmlDataType {

	public static var StringDataType:ASSoapDataType
		= new ASSoapDataType(1, "string");

	public static var CDataDataType:ASSoapDataType
		= new ASSoapDataType(2, "cdata");

	public static var NumberDataType:ASSoapDataType
		= new ASSoapDataType(3, "number");

	public static var XmlDataType:ASSoapDataType
		= new ASSoapDataType(4, "xml");

	public static var BoolDataType:ASSoapDataType
		= new ASSoapDataType(5, "boolean");

	public static var MapDataType:ASSoapDataType
		= new ASSoapDataType(6, "map");

	public static var DateDataType:ASSoapDataType
		= new ASSoapDataType(7, "date");

	public static var ObjectDataType:ASSoapDataType
		= new ASSoapDataType(8, "object");

	public static var ArrayDataType:ASSoapDataType
		= new ASSoapDataType(9, "array");
		
	public static var AnyDataType:ASSoapDataType
		= new ASSoapDataType(10, "any");
		
	public static var ComplexDataType:ASSoapDataType
		= new ASSoapDataType(11, "object");

	/**
	 * The name of the datatype's tag.
	 */
	public var tagName:String;
	
	/**
	 * Additional data held by the data type.
	 */
	public var data:Object;

	/**
	 * Creates a new instance of the <code>DataType</code> class.
	 */
	private function ASSoapDataType(value:Number, tagName:String) {
		super(value, tagName);
	}
	
	/**
	 * Copies the object.
	 */
	public function copyWithZone():ASSoapDataType {
		return new ASSoapDataType(value, tagName);
	}
}