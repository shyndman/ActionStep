/* See LICENSE for copyright and terms of use */

import org.actionstep.NSDictionary;
import org.actionstep.rpc.soap.ASSoapDataType;
import org.actionstep.rpc.soap.common.ASSchemaComplexType;
import org.actionstep.rpc.soap.common.ASSchemaElement;

/**
 * Represents a SOAP schema, which defines available types.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASSchema {
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	/**
	 * Holds a map of schema namespace prefixes to schemas.
	 */
	private static var g_schemas:NSDictionary;
	
	/**
	 * A mapping of namespace URIs to prefixes.
	 */
	private static var g_namespaces:NSDictionary;
	
	/**
	 * Holds all standard types.
	 */
	private static var g_standardTypes:NSDictionary;
	
	/**
	 * This target's namespace.
	 */
	public var targetNamespace:String;
	
	/**
	 * This schema's prefix.
	 */
	public var prefix:String;
	
	/**
	 * Holds types handled by this schema.
	 */
	private var m_types:NSDictionary;
	
	/**
	 * Holds named elements.
	 */
	private var m_elements:NSDictionary;
	
	//******************************************************
	//*                 Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASSchema</code> class.
	 */
	public function ASSchema(targetNamespace:String) {
		this.targetNamespace = targetNamespace;
		this.prefix = prefixForUri(targetNamespace);
		m_types = NSDictionary.dictionaryWithDictionary(g_standardTypes);
		m_elements = NSDictionary.dictionary();
		
		g_schemas.setObjectForKey(this, prefix);
	}
	
	//******************************************************
	//*               Accessing elements
	//******************************************************
	
	/**
	 * Returns the element named <code>name</code>, or <code>null</code> if no 
	 * element could be found. <code>name</code> should not have a namespace.
	 */
	public function elementWithName(name:String):ASSchemaElement {
		return ASSchemaElement(m_elements.objectForKey(name));
	}
	
	/**
	 * Adds an element to the schema.
	 */
	public function addElement(element:ASSchemaElement):Void {
		m_elements.setObjectForKey(element, element.name);
	}
	
	//******************************************************
	//*              Adding complex types
	//******************************************************
	
	/**
	 * Returns the type named <code>name</code>, or <code>null</code> if no 
	 * element could be found. <code>name</code> should not have a namespace.
	 */
	public function typeWithName(name:String):ASSoapDataType {
		return ASSoapDataType(m_types.objectForKey(name));
	}
	
	/**
	 * Adds a complex type to the schema.
	 */
	public function addComplexType(complexType:ASSchemaComplexType):Void {
		var dataTypeWrap:ASSoapDataType = ASSoapDataType.ComplexDataType.copyWithZone();
		dataTypeWrap.data = complexType;
		m_types.setObjectForKey(dataTypeWrap, complexType.name);
		complexType.schema = this;
	}
	
	/**
	 * Removes a complex type from the schema.
	 */
	public function removeComplexType(complexType:ASSchemaComplexType):Void {
		m_types.removeObjectForKey(complexType.name);
	}
	
	/**
	 * Adds an array type to the schema.
	 */
	public function addArrayType(arrayType:ASSchemaComplexType):Void {
		var dataTypeWrap:ASSoapDataType = ASSoapDataType.ArrayDataType.copyWithZone();
		dataTypeWrap.data = arrayType;
		m_types.setObjectForKey(dataTypeWrap, arrayType.name);
		arrayType.schema = this;
	}
	
	/**
	 * Removes an array type from the schema.
	 */
	public function removeArrayType(arrayType:ASSchemaComplexType):Void {
		m_types.removeObjectForKey(arrayType.name);
	}
	
	//******************************************************
	//*              Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		return "ASSchema(elements=" + m_elements.description() 
			+ ",\ntypes=" + m_types.description() + ")";
	}
	
	//******************************************************
	//*            Adding schema namespaces
	//******************************************************
	
	/**
	 * Adds a schema URI to prefix mapping.
	 */
	public static function addSchemaNamespace(uri:String, prefix:String):Void {
		g_namespaces.setObjectForKey(prefix, uri);
	}
	
	/**
	 * Gets the prefix for the namespace URI.
	 */
	public static function prefixForUri(uri:String):String {
		return g_namespaces.objectForKey(uri).toString();
	}
	
	//******************************************************
	//*           Getting schemas by namespace
	//******************************************************
	
	/**
	 * Returns the schema associated with <code>prefix</code>, or 
	 * <code>null</code> if no schema could be found.
	 */
	public static function schemaWithPrefix(prefix:String):ASSchema {
		return ASSchema(g_schemas.objectForKey(prefix));
	}
	
	//******************************************************
	//*               Static construction
	//******************************************************
	
	/**
	 * Creates the standard types dictionary.
	 */
	private static function initialize():Void {
		g_schemas = NSDictionary.dictionary();
		g_namespaces = NSDictionary.dictionary();
		g_standardTypes = NSDictionary.dictionary();

		g_standardTypes.setObjectForKey(ASSoapDataType.BoolDataType, "boolean");
		g_standardTypes.setObjectForKey(ASSoapDataType.StringDataType, "string");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "decimal");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "integer");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "negativeInteger");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "nonNegativeInteger");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "positiveInteger");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "nonPositiveInteger");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "long");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "int");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "short");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "byte");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "unsignedLong");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "unsignedInt");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "unsignedShort");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "unsignedByte");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "float");
		g_standardTypes.setObjectForKey(ASSoapDataType.NumberDataType, "double");
		g_standardTypes.setObjectForKey(ASSoapDataType.DateDataType, "date");
		g_standardTypes.setObjectForKey(ASSoapDataType.DateDataType, "dateTime");
		g_standardTypes.setObjectForKey(ASSoapDataType.DateDataType, "time");
		g_standardTypes.setObjectForKey(ASSoapDataType.ObjectDataType, "base64Binary");
		g_standardTypes.setObjectForKey(ASSoapDataType.ObjectDataType, "hexBinary");
		g_standardTypes.setObjectForKey(ASSoapDataType.StringDataType, "token");
		g_standardTypes.setObjectForKey(ASSoapDataType.StringDataType, "normalizedString");
		g_standardTypes.setObjectForKey(ASSoapDataType.AnyDataType, "anyType");
		g_standardTypes.setObjectForKey(ASSoapDataType.DateDataType, "timeInstant");
	}
}