/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Used internally to parse schemas.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASSchemaConstant extends ASConstantValue {
	
	public static var ASSchemaName:ASSchemaConstant 
		= new ASSchemaConstant("schema", XSD_URI);
	
	public static var ASSchemaAll:ASSchemaConstant 
		= new ASSchemaConstant("all", XSD_URI);
	
	public static var ASSchemaComplexType:ASSchemaConstant 
		= new ASSchemaConstant("complexType", XSD_URI);
		
	public static var ASSchemaElementType:ASSchemaConstant 
		= new ASSchemaConstant("element", XSD_URI);
		
	public static var ASSchemaImport:ASSchemaConstant 
		= new ASSchemaConstant("import", XSD_URI);
		
	public static var ASSchemaSimpleType:ASSchemaConstant 
		= new ASSchemaConstant("simpleType", XSD_URI);
		
	public static var ASSchemaComplexContent:ASSchemaConstant 
		= new ASSchemaConstant("complexContent", XSD_URI);
		
	public static var ASSchemaSequence:ASSchemaConstant 
		= new ASSchemaConstant("sequence", XSD_URI);
		
	public static var ASSchemaSimpleContent:ASSchemaConstant 
		= new ASSchemaConstant("simpleContent", XSD_URI);
		
	public static var ASSchemaRestriction:ASSchemaConstant 
		= new ASSchemaConstant("restriction", XSD_URI);
		
	public static var ASSchemaAttribute:ASSchemaConstant 
		= new ASSchemaConstant("attribute", XSD_URI);
		
	public static var ASSchemaExtension:ASSchemaConstant 
		= new ASSchemaConstant("extension", XSD_URI);

	//******************************************************
	//*                    Constants
	//******************************************************
	
	private static var XSD_URI_2001 = "http://www.w3.org/2001/XMLSchema";
	private static var XSD_URI = XSD_URI_2001;

	//******************************************************
	//*                     Members
	//******************************************************
	
	/**
	 * Name of the tag
	 */
	public var localPart:String;
	
	/**
	 * The tag's namespace URI
	 */
	public var namespaceURI:String;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASSchemaConstant</code> class.
	 */
	public function ASSchemaConstant(localPart:String, namespaceURI:String) {
		this.localPart = localPart;
		this.namespaceURI = namespaceURI;
	}
}