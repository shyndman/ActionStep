import org.actionstep.rpc.soap.ASSoapDataType;
/* See LICENSE for copyright and terms of use */

/**
 * Holds information about an element in a schema.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASSchemaElement extends ASSoapDataType {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private static var g_elementDataTypeCount:Number = 20;
	
	/**
	 * The name of this element.
	 */
	public var name:String;
	
	/**
	 * The type of this element.
	 */
	public var typeName:String;
	
	/**
	 * The data type.
	 */
	public var type:ASSoapDataType;
	
	/**
	 * The minimum occurrences of element occurrences allowed. This is
	 * typically 0 if the element is optional, 1 if it is required, or some
	 * higher number if it refers to array elements where there is a lower
	 * bound on the array.
	 */
	public var minOccurs:Number;
	
	/**
	 * The maximum number of element occurrences allowed. This is typically
	 * a high number for arrays, or the unbounded value (-1).
	 */
	public var maxOccurs:Number;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASSchemaElement</code> class. 
	 */
	public function ASSchemaElement(name:String, typeName:String, minOccurs:Number, 
			maxOccurs:Number) {
		this.name = name;
		this.typeName = typeName;
		this.minOccurs = isNaN(minOccurs) ? null : minOccurs;
		this.maxOccurs = isNaN(maxOccurs) ? null : maxOccurs;
		
		this.tagName = name;
		this.value = g_elementDataTypeCount++;
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		return "ASSchemaElement(name=" + name + ", typeName=" + typeName 
			+ (minOccurs == null ? "" : ", minOccurs=" + minOccurs) 
			+ (maxOccurs == null ? "" : ", maxOccurs=" 
				+ (maxOccurs == Number.MAX_VALUE ? "unbounded" : maxOccurs))
			+ ")";
	}
}