/* See LICENSE for copyright and terms of use */

import org.actionstep.binding.NSKeyValueCoding;
import org.actionstep.NSArray;
import org.actionstep.rpc.ASService;
import org.actionstep.rpc.soap.ASSoapConstants;
import org.actionstep.rpc.soap.ASSoapDataType;
import org.actionstep.rpc.soap.ASSoapSerializer;
import org.actionstep.rpc.soap.ASSoapService;
import org.actionstep.rpc.soap.common.ASSchemaComplexType;
import org.actionstep.rpc.soap.common.ASSchemaElement;
import org.actionstep.rpc.soap.common.ASWsdlMessagePart;
import org.actionstep.rpc.xml.ASXmlConstants;
import org.actionstep.rpc.xml.ASXmlOperation;
import org.actionstep.rpc.soap.common.ASWsdlFile;

/**
 * Represents a SOAP operation.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.ASSoapOperation extends ASXmlOperation {

	private var m_soapAction:String;
	private var m_returnTypes:NSArray;
	private var m_style:String;
	private var m_inputUse:String;
	private var m_outputUse:String;
	
	//******************************************************
	//*                   Construction
	//******************************************************

	/**
	 * Constructs a new instance of the <code>ASSoapOperation</code> class.
	 */
	public function ASSoapOperation() {
		m_returnTypes = NSArray.array();
	}

	/**
	 * Initializes the operation with the method name <code>name</code> and
	 * the service <code>service</code>.
	 */
	public function initWithNameServiceSoapActionStyle(name:String, 
			service:ASService, soapAction:String, style:String):ASSoapOperation {
		super.initWithNameService(name, service);
		m_soapAction = soapAction;
		m_style = style;
		return this;
	}

	//******************************************************
	//*               Describing the object
	//******************************************************

	/**
	 * Returns a string representation of the operation.
	 */
	public function description():String {
		return "ASSoapOperation(fullName=" + fullName() 
			+ ", service=" + service()
			+ ")";
	}
	
	//******************************************************
	//*              Getting SOAP specifics
	//******************************************************
	
	/**
	 * Returns the SOAP action for this operation.
	 */
	public function soapAction():String {
		return m_soapAction;
	}
	
	//******************************************************
	//*              Setting encoding
	//******************************************************
	
	public function setInputOutputUse(input:String, output:String):Void {
		m_inputUse = input;
		m_outputUse = output;
	}
		
	//******************************************************
	//*              Adding parameters
	//******************************************************
	
	/**
	 * Returns an array of expected parameter types for this method.
	 *
	 * Each element is an instance of <code>ASWsdlMessagePart</code>.
	 */
	public function parameters():NSArray {
		return m_params;
	}
	
	/**
	 * Adds an expected parameter data type to the method's parameter list.
	 */
	public function addParameter(part:ASWsdlMessagePart):Void {
		m_params.addObject(part);
	}
		
	//******************************************************
	//*       Setting the expected operation params
	//******************************************************

	/**
	 * Removes all return types from the operation.
	 */
	public function resetReturnTypes():Void {
		m_returnTypes.removeAllObjects();
	}

	/**
	 * Returns an array of expected return types for this method.
	 *
	 * Each element is an instance of <code>ASWsdlMessagePart</code>.
	 */
	public function returnTypes():NSArray {
		return m_returnTypes;
	}

	/**
	 * Adds an expected return data type to the method's return type.
	 */
	public function addReturnType(part:ASWsdlMessagePart):Void {
		m_returnTypes.addObject(part);
	}
		
	//******************************************************
	//*              Getting the call's XML
	//******************************************************

	private var m_wsdl:ASWsdlFile;

	/**
	 * Gets the XML for the remote method call.
	 */
	public function getXmlWithArgs(args:Array):XML {
		m_wsdl = ASSoapService(service()).wsdlFile();
		
		//
		// Build call XML
		//
		var call:XML = new XML();
		call.ignoreWhite = true;
		call.xmlDecl = ASXmlConstants.XML_DECLARATION;
		call.contentType = ASXmlConstants.XML_CONTENT_TYPE;
		
		//
		// Add envelope
		//
		var env:XMLNode = call.createElement(ASSoapConstants.NODE_ENVELOPE);
		env.attributes[ASSoapConstants.ATTRIBUTE_XSI_NS] = ASSoapConstants.NAMESPACE_XSI;
		env.attributes[ASSoapConstants.ATTRIBUTE_SOAP_NS] = ASSoapConstants.NAMESPACE_SOAP;
		env.attributes[ASSoapConstants.ATTRIBUTE_XSD_NS] = ASSoapConstants.NAMESPACE_XSD;
		call.appendChild(env);
		
		//
		// Add body
		//
		var body:XMLNode = call.createElement(ASSoapConstants.NODE_BODY);
		env.appendChild(body);
		
		//
		// Add body contents
		//
		var bodyContents:XMLNode = body;
		
		if (m_inputUse == ASSoapConstants.USE_LITERAL) {
			if (m_style == ASSoapConstants.STYLE_DOCUMENT) {
				
			} else { // m_style == ASSoapConstants.STYLE_RPC
				bodyContents = call.createElement(name());
				bodyContents.attributes[ASSoapConstants.ATTRIBUTE_XML_NS] 
					= m_wsdl.targetNamespace;
				body.appendChild(bodyContents);
			}
		}
				
		//
		// Add parameters
		//
		var params:Array = m_params.internalList();
		var len:Number = params.length;
		for (var i:Number = 0; i < len; i++) {
			var p:ASWsdlMessagePart = params[i];
			var t:ASSoapDataType = p.type;
			var pNode:XMLNode;
			
			if (t instanceof ASSchemaElement) {
				pNode = call.createElement(ASSchemaElement(t).name);
				pNode.attributes[ASSoapConstants.ATTRIBUTE_XML_NS] 
					= m_wsdl.targetNamespace;
				
				t = ASSchemaElement(t).type;
			} else {
				if (t.value == ASSoapDataType.ComplexDataType.value) {
					pNode = call.createElement(p.name);
				} else {
					pNode = ASSoapSerializer.instance().serializeObjectWithNameType(
						args[i], p.name, t, p.typeName);
				}
			}
			
			bodyContents.appendChild(pNode);
			
			//
			// Fill pNode
			//
			if (t.value == ASSoapDataType.ComplexDataType.value) {
				var complex:ASSchemaComplexType = ASSchemaComplexType(t.data);
				var eles:Array = complex.elements.internalList();
				var len2:Number = eles.length;
				for (var j:Number = 0; j < len2; j++) {
					var sEle:ASSchemaElement = ASSchemaElement(eles[j]);
					if (sEle.type == null) {
						sEle.type = m_wsdl.typeWithName(sEle.typeName);
					}
					
					addElementValueToNodeWithXml(sEle, 
						args[i], pNode, call);
				} 
			}
		}
		
		return call;
	}
	
	/**
	 * Adds an element to the specified node.
	 */
	private function addElementValueToNodeWithXml(element:ASSchemaElement, 
			obj:Object, node:XMLNode, xml:XML):Void {
		var isComplex:Boolean = element.type.value == ASSoapDataType.ComplexDataType.value;
		var eleNode:XMLNode;
				
		if (isComplex) {
			eleNode = xml.createElement(element.name);
		} else {
			if (element.type == null) {
				element.type = m_wsdl.typeWithName(element.typeName);
			}
			
 			eleNode = ASSoapSerializer.instance().serializeObjectWithNameType(
 				obj, element.name, element.type, element.typeName);	
		}
		
		node.appendChild(eleNode);
		
		if (isComplex) {
			var complex:ASSchemaComplexType = ASSchemaComplexType(element.type.data);
			var eles:Array = complex.elements.internalList();
			var len2:Number = eles.length;
			for (var j:Number = 0; j < len2; j++) {
				var e:ASSchemaElement = ASSchemaElement(eles[j]);
				addElementValueToNodeWithXml(e, 
					NSKeyValueCoding.valueWithObjectForKey(obj, e.name),
					eleNode, xml);
			}
		}
	}
}