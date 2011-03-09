/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.ASUtils;
import org.actionstep.NSDate;
import org.actionstep.NSDateFormatter;
import org.actionstep.NSObject;
import org.actionstep.rpc.soap.ASSoapDataType;
import org.actionstep.rpc.soap.ASSoapOperation;
import org.actionstep.rpc.soap.ASSoapUtils;
import org.actionstep.rpc.soap.common.ASSchemaComplexType;
import org.actionstep.rpc.soap.common.ASSchemaElement;
import org.actionstep.rpc.soap.common.ASWsdlFile;
import org.actionstep.rpc.soap.common.ASWsdlMessagePart;

/**
 * Serializes and deserializes SOAP messages.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.ASSoapSerializer extends NSObject {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private static var g_instance:ASSoapSerializer;
	private var m_xml:XML;
	
	/** CCYY-MM-DD */
	private var m_dateFormatter:NSDateFormatter;
		
	/** hh:mm:ss */
	private var m_timeFormatter:NSDateFormatter;
	
	/** CCYY-MM-DDThh:mm:ss */
	private var m_dateTimeFormatter:NSDateFormatter;
	
	//******************************************************
	//*                    Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASSoapSerializer</code> class.
	 */
	private function ASSoapSerializer() {
		m_xml = new XML();
	}
	
	/**
	 * Initializes the serializer.
	 */
	public function init():ASSoapSerializer {
		super.init();
		
		m_dateFormatter = (new NSDateFormatter()).initWithDateFormatAllowNaturalLanguage(
			"%Y-%m-%d", false);
		m_timeFormatter = (new NSDateFormatter()).initWithDateFormatAllowNaturalLanguage(
			"%H:%M:%S", false);
		m_dateTimeFormatter = (new NSDateFormatter()).initWithDateFormatAllowNaturalLanguage(
			"%Y-%m-%dT%H:%M:%S", false);
		return this;
	}
	
	//******************************************************
	//*                Serializing Objects
	//******************************************************
	
	/**
	 * Serializes obj into the optional type type.
	 *
	 * If type is ommitted or null, the serializer attempts to determine the
	 * type.
	 */
	public function serializeObjectWithNameType(obj:Object, name:String, 
			type:ASSoapDataType, refinedType:String):XMLNode {
		var n:XMLNode = m_xml.createElement(name);		
		
		//
		// Serialize object
		//
		switch (type.value) {
			case ASSoapDataType.ArrayDataType.value:
				
				var arrType:ASSchemaElement = 
					ASSchemaElement(ASSchemaComplexType(type.data).elements.objectAtIndex(0));
				
				//
				// Serialize the array contents
				//
				var arr:Object = ASUtils.extractArrayFromCollection(obj);
				var len:Number = arr.length;
				for (var i:Number = 0; i < len; i++) {
					n.appendChild(serializeObjectWithNameType(arr[i], 
						ASSoapUtils.localPartFromName(arrType.typeName), 
						arrType.type, arrType.typeName));
				}

				break;

			case ASSoapDataType.AnyDataType.value:

				break;

			case ASSoapDataType.DateDataType.value:
				var dt:NSDate = NSDate.dateWithDate(
					ASUtils.extractNativeDate(obj));
				refinedType = ASSoapUtils.localPartFromName(refinedType);
				
				if (refinedType == null) {
					refinedType = "date";
				}
									
				//
				// Build date string
				//
				var dtStr:String = "";
				if (refinedType == "date") {
					dtStr = m_dateFormatter.stringFromDate(dt);
				}
				else if (refinedType == "dateTime") {
					dtStr = m_dateTimeFormatter.stringFromDate(dt);
				}
				else if (refinedType == "time") {
					dtStr = m_timeFormatter.stringFromDate(dt);
				}

				n.appendChild(m_xml.createTextNode(dtStr));
				
				break;
			
			case ASSoapDataType.AnyDataType.value:
				
				// TODO do something here, maybe type detection
				
			case ASSoapDataType.CDataDataType.value:
			case ASSoapDataType.StringDataType.value:
			case ASSoapDataType.BoolDataType.value:
			case ASSoapDataType.NumberDataType.value:
			default:
				var value:String = obj.toString();
				if (type == ASSoapDataType.CDataDataType) {
					value = "<![CDATA[" + value + "]]>";
				}

				n.appendChild(m_xml.createTextNode(value));
				break;
		}

		return n;
	}
	
	//******************************************************
	//*                  Deserializing
	//******************************************************
	
	/**
	 * Deserializes a type from a node.
	 */
	public function deserializeTypeWithWsdlNode(type:ASSoapDataType,
			wsdl:ASWsdlFile, resultNode:XMLNode, refinedType:String):Object {
		var strContents:String = resultNode.firstChild.nodeValue;
		if (strContents == null) {
			strContents = "";
		}
				
		switch (type.value) {
			
			//
			// Objects
			//
			case ASSoapDataType.MapDataType.value:
			case ASSoapDataType.ObjectDataType.value:
			case ASSoapDataType.ComplexDataType.value:
				var complex:ASSchemaComplexType = ASSchemaComplexType(type.data);
				var obj:Object = {};
				
				var elements:Array = complex.elements.internalList();
				var len:Number = elements.length;
				for (var i:Number = 0; i < len; i++) {
					var e:ASSchemaElement = elements[i];
					if (e.type == null) {
						e.type = wsdl.typeWithName(e.typeName);
					}
					
					obj[e.name] = deserializeTypeWithWsdlNode(e.type, wsdl, 
						resultNode.childNodes[i], e.typeName);
				}
								
				return obj;
			
			//
			// Arrays
			//
			case ASSoapDataType.ArrayDataType.value:
				var complex:ASSchemaComplexType = ASSchemaComplexType(type.data);
				var typeElement:ASSchemaElement = ASSchemaElement(complex.elements
					.objectAtIndex(0));
				if (typeElement.type == null) {
					typeElement.type = wsdl.typeWithName(typeElement.typeName);
				}
				
				var arr:Array = [];
				var items:Array = resultNode.childNodes;
				var len:Number = items.length;
				for (var i:Number = 0; i < len; i++) {
					arr.push(deserializeTypeWithWsdlNode(typeElement.type, wsdl, 
						items[i], typeElement.typeName));
				}
				
				return arr;
			
			//
			// Booleans
			//
			case ASSoapDataType.BoolDataType.value:
				return (strContents == "true" || strContents == "1");
						
			//
			// Numbers
			//		
			case ASSoapDataType.NumberDataType.value:
				return Number(strContents);
				
			//
			// Dates
			//		
			case ASSoapDataType.DateDataType.value:
				var idx:Number = strContents.indexOf(".");
				if (idx != -1) {
					strContents = strContents.substring(0, idx);
				}
								
				refinedType = ASSoapUtils.localPartFromName(refinedType);
				if (refinedType == "date") {
					return m_dateFormatter.dateFromString(strContents);
				}
				else if (refinedType == "dateTime") {
					return m_dateTimeFormatter.dateFromString(strContents);
				}
				else if (refinedType == "time") {
					return m_timeFormatter.dateFromString(strContents);
				}
				
				return Number(strContents);
				
			//
			// Strings
			//
			case ASSoapDataType.AnyDataType.value:
			case ASSoapDataType.StringDataType.value:
			case ASSoapDataType.CDataDataType.value:
			default:
				return strContents;
		}
				
		return null;	
	}
	
	/**
	 * Deserializes a SOAP response into an object.
	 */
	public function deserializeResponseWithOperationWsdlXml(
			operation:ASSoapOperation, wsdl:ASWsdlFile, response:XML):Object {
		var responseNode:XMLNode = response.firstChild.firstChild.firstChild;
		var returnPart:ASWsdlMessagePart = ASWsdlMessagePart(
			operation.returnTypes().internalList()[0]);
		
		if (returnPart.elementName != null) {
			var ele:ASSchemaElement = ASSchemaElement(wsdl.elementWithName(
				returnPart.elementName).type.data.elements.objectAtIndex(0));
			if (ele.type == null) {
				ele.type = wsdl.typeWithName(ele.typeName); 
			}
						
			return deserializeTypeWithWsdlNode(ele.type, wsdl, 
				responseNode.firstChild, ele.typeName);
		} else { // returnPart.typeName != null
			return deserializeTypeWithWsdlNode(returnPart.type, wsdl, 
				responseNode.firstChild, returnPart.typeName);
		}
	}

	/**
	 * Deserializes a SOAP response into an object.
	 */
	public function deserializeFaultWithWsdlXml(wsdl:ASWsdlFile, response:XML):Object {
		var fault:Object = {};
		var faultNode:XMLNode = response.firstChild.firstChild.firstChild;
		
		var arr:Array = faultNode.childNodes;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var child:XMLNode = arr[i];
			var name:String = child.nodeName;
			
			switch (name) {
				case "faultcode":
					fault.errorCode = child.firstChild.nodeValue;
					break;
					
				case "faultstring":
					fault.description = child.firstChild.nodeValue;
					break;
				
				case "faultactor":
					fault._className = child.firstChild.nodeValue;
					break;
				
				case "detail":
					fault.details = ASDebugger.dump(child.firstChild);
					break;
			}
		}
		
		return fault;
	}
	
	
	//******************************************************
	//*                    Singleton
	//******************************************************
	
	/**
	 * Gets the SOAP serializer.
	 */
	public static function instance():ASSoapSerializer {
		if (g_instance == null) {
			g_instance = (new ASSoapSerializer()).init();
		}
		
		return g_instance;
	}
}