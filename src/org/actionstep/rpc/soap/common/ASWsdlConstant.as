/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Used internally to parse WSDL files.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlConstant extends ASConstantValue {
	
	public static var ASWsdlDefinitions:ASWsdlConstant 
		= new ASWsdlConstant("definitions", WSDL_URI);
	
	public static var ASWsdlTypes:ASWsdlConstant 
		= new ASWsdlConstant("types", WSDL_URI);
		
	public static var ASWsdlMessage:ASWsdlConstant 
		= new ASWsdlConstant("message", WSDL_URI);
		
	public static var ASWsdlPortType:ASWsdlConstant 
		= new ASWsdlConstant("portType", WSDL_URI);
	
	public static var ASWsdlBinding:ASWsdlConstant 
		= new ASWsdlConstant("binding", WSDL_URI);
		
	public static var ASWsdlService:ASWsdlConstant 
		= new ASWsdlConstant("service", WSDL_URI);
	
	public static var ASWsdlImport:ASWsdlConstant 
		= new ASWsdlConstant("import", WSDL_URI);
	
	public static var ASWsdlDocumentation:ASWsdlConstant 
		= new ASWsdlConstant("documentation", WSDL_URI);
	
	public static var ASWsdlPort:ASWsdlConstant 
		= new ASWsdlConstant("port", WSDL_URI);
	
	public static var ASWsdlAddress:ASWsdlConstant 
		= new ASWsdlConstant("address", WSDL_SOAP_URI);
		
	public static var ASWsdlSoapBinding:ASWsdlConstant 
		= new ASWsdlConstant("binding", WSDL_SOAP_URI);
		
	public static var ASWsdlOperation:ASWsdlConstant 
		= new ASWsdlConstant("operation", WSDL_URI);
		
	public static var ASWsdlSoapOperation:ASWsdlConstant 
		= new ASWsdlConstant("operation", WSDL_SOAP_URI);
		
	public static var ASWsdlBody:ASWsdlConstant 
		= new ASWsdlConstant("body", WSDL_SOAP_URI);
		
	public static var ASWsdlInput:ASWsdlConstant 
		= new ASWsdlConstant("input", WSDL_URI);
		
	public static var ASWsdlOutput:ASWsdlConstant 
		= new ASWsdlConstant("output", WSDL_URI);
		
	public static var ASWsdlParameter:ASWsdlConstant 
		= new ASWsdlConstant("part", WSDL_URI);
		
	//******************************************************
	//*             Non-enumerated Constants
	//******************************************************
	
	public static var WSDL_SHORT_NAMESPACE:String = "tns";
	public static var WSDL_URI:String = "http://schemas.xmlsoap.org/wsdl/";
    public static var WSDL_SOAP_URI:String = "http://schemas.xmlsoap.org/wsdl/soap/";
	
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
	 * Creates a new instance of the <code>ASSoapWsdlConstant</code> class.
	 */
	public function ASWsdlConstant(localPart:String, namespaceURI:String) {
		this.localPart = localPart;
		this.namespaceURI = namespaceURI;
	}
}