/* See LICENSE for copyright and terms of use */

/**
 * Symbolic constants for SOAP XML.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.ASSoapConstants {
	
	public static var NODE_ENVELOPE:String = "soap:Envelope";
	public static var NODE_BODY:String = "soap:Body";
	
	public static var ATTRIBUTE_XML_NS:String = "xmlns";
	
	public static var ATTRIBUTE_XSI_NS:String = "xmlns:xsi";
	public static var NAMESPACE_XSI:String = "http://www.w3.org/2001/XMLSchema-instance";
	
	public static var ATTRIBUTE_XSD_NS:String = "xmlns:xsd";
	public static var NAMESPACE_XSD:String = "http://www.w3.org/2001/XMLSchema";
	
	public static var ATTRIBUTE_SOAP_NS:String = "xmlns:soap";
	public static var NAMESPACE_SOAP:String = "http://schemas.xmlsoap.org/soap/envelope/";
	
	public static var STYLE_DOCUMENT:String = "document";
	public static var STYLE_RPC:String = "rpc";
	public static var STYLE_WRAPPED:String = "wrapped";
	
	public static var USE_LITERAL:String = "literal";
	public static var USE_ENCODED:String = "encoded";
	
	public static var OCCURS_UNBOUNDED:String = "unbounded";
}