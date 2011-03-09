/* See LICENSE for copyright and terms of use */

import org.actionstep.NSDictionary;
import org.actionstep.rpc.soap.common.ASSchema;
import org.actionstep.rpc.soap.common.ASWsdlElement;

/**
 * Represent's a WSDL file's types element.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlTypes extends ASWsdlElement {
	
	/** The schema for the WSDL file */
	public var schemas:NSDictionary;
	
	/**
	 * Creates a new instance of the <code>ASWsdlTypes</code> class.
	 */
	public function ASWsdlTypes() {
		schemas = NSDictionary.dictionary();
	}
	
	/**
	 * Adds a schema to the types element.
	 */
	public function addSchema(schema:ASSchema):Void {
		schemas.setObjectForKey(schema, schema.prefix);
	}
	
	/**
	 * Returns the schema with <code>prefix</code>, or <code>null</code> if
	 * no schema can be found.
	 */
	public function schemaWithPrefix(prefix:String):ASSchema {
		return ASSchema(schemas.objectForKey(prefix));
	}
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		return "ASWsdlTypes(schemas=" + schemas.toString() + ")";
	}
}