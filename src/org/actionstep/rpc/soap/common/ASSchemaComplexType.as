/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.rpc.soap.common.ASSchemaElement;
import org.actionstep.rpc.soap.common.ASSchema;

/**
 * Represents a complexType element in a schema.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASSchemaComplexType {
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private static var g_typeCounter:Number = 0;
	
	/** Name of the type */
	public var name:String;
	
	/** The element sequence contained by this type */
	public var elements:NSArray;
	
	/** The schema that owns this type */
	public var schema:ASSchema;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASSchemaComplexType</code> class.
	 */
	public function ASSchemaComplexType(name:String) {
		this.name = (name == null ? "__complexType" + g_typeCounter++ : name);
		this.elements = NSArray.array(); 
	}
	
	//******************************************************
	//*                 Adding elements
	//******************************************************
	
	/**
	 * Adds an element to the type.
	 */
	public function addElement(element:ASSchemaElement):Void {
		elements.addObject(element);
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		return "ASSchemaComplexType(name=" + name + ", elements=\n" + elements.description() + ")";
	}
}