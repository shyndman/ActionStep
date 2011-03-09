/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.NSDate;
import org.actionstep.NSDateFormatter;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.rpc.xmlrpc.ASXmlRpcConstants;
import org.actionstep.rpc.xmlrpc.ASXmlRpcDataType;
import org.actionstep.rpc.xmlrpc.ASXmlRpcSerializable;

/**
 * Performs tasks related to XML-RPC serialization and deserialization.
 *
 * @author Scott Hyndman
 */
class org.actionstep.rpc.xmlrpc.ASXmlRpcSerializer extends NSObject {

	private static var g_xml:XML;
	private static var g_dateFormatter:NSDateFormatter;
	private static var g_dateFormatterBasic:NSDateFormatter;

	private var objectIDs:NSDictionary;
	private var currentID:Number;

	/**
	 * Creates a new instance of the <code>ASXmlRpcSerializer</code> class.
	 */
	public function ASXmlRpcSerializer() {		
		if (g_xml == null) {
			g_xml = new XML();
			g_xml.ignoreWhite = true;

			g_dateFormatter = (new NSDateFormatter()).initWithDateFormatAllowNaturalLanguage(
				"%Y-%m-%dT%I:%M:%S", false);
			
			g_dateFormatterBasic = (new NSDateFormatter()).initWithDateFormatAllowNaturalLanguage(
				"%Y%m%dT%I:%M:%S", false);
		}
	}

	/**
	 * Initializes and returns the <code>ASXmlRpcSerializer</code> instance.
	 */
	public function init():ASXmlRpcSerializer {
		super.init();
		reset();
		return this;
	}

	/**
	 * Resets the state of the parser.
	 */
	public function reset():Void {
		objectIDs = NSDictionary.dictionary();
		currentID = 0;
	}

	/**
	 * Serializes obj into the optional type type.
	 *
	 * If type is ommitted or null, the serializer attempts to determine the
	 * type.
	 */
	public function serializeObjectWithType(obj:Object, type:ASXmlRpcDataType):XMLNode {
		var n:XMLNode = g_xml.createElement(ASXmlRpcConstants.NODE_VALUE);

		//
		// Determine type if necessary
		//
		if (type == null) {
			type = getTypeWithObject(obj);
		}

		//
		// Serialize object
		//
		var typeNode:XMLNode = g_xml.createElement(type.tagName);
		n.appendChild(typeNode);

		switch (type) {
			case ASXmlRpcDataType.ArrayDataType:
				var dataNode:XMLNode = g_xml.createElement(ASXmlRpcConstants.NODE_DATA);
				typeNode.appendChild(dataNode);

				//
				// Serialize the array contents
				//
				var arr:Object = ASUtils.extractArrayFromCollection(obj);
				var len:Number = arr.length;
				for (var i:Number = 0; i < len; i++) {
					dataNode.appendChild(serializeObjectWithType(arr[i], null));
				}

				break;

			case ASXmlRpcDataType.StructDataType:

				//
				// Extract members
				//
				var members:Object = {};
				if (obj instanceof ASXmlRpcSerializable) {
					var sObj:ASXmlRpcSerializable = ASXmlRpcSerializable(obj);

					//
					// Serialize class name
					//
					var cls:String = sObj.serializableClassName();
					if (cls != null) {
						members[ASXmlRpcConstants.MEMBER_CLASSNAME] =
							{value: cls, type: ASXmlRpcDataType.StringDataType};
					}

					//
					// Serialize members
					//
					var sMems:Object = sObj.serializableFields().internalDictionary();
					for (var mName:String in sMems) {
						members[mName] = {value: obj[mName], type: sMems[mName].type};
					}
				} else {
					for (var mName:String in obj) {
						members[mName] =
							{value: obj[mName], type: getTypeWithObject(obj[mName])};
					}
				}

				//
				// Add member nodes
				//
				for (var mName:String in members) {
					var mInfo:Object = members[mName];
					var memberNode:XMLNode = g_xml.createElement(ASXmlRpcConstants.NODE_MEMBER);
					var nameNode:XMLNode = g_xml.createElement(ASXmlRpcConstants.NODE_NAME);
					nameNode.appendChild(g_xml.createTextNode(mName));
					memberNode.appendChild(nameNode);
					memberNode.appendChild(serializeObjectWithType(mInfo.value, mInfo.type));
					typeNode.appendChild(memberNode);
				}

				break;

			case ASXmlRpcDataType.DateDataType:
				var dt:NSDate = NSDate.dateWithDate(
					ASUtils.extractNativeDate(obj));
				var value:String = g_dateFormatter.stringFromDate(dt);
				typeNode.appendChild(g_xml.createTextNode(value));
				break;

			case ASXmlRpcDataType.BoolDataType:
				var value:String = (obj == true) ? "1" : "0";
				typeNode.appendChild(g_xml.createTextNode(value));
				break;
				
			case ASXmlRpcDataType.CDataDataType:
			case ASXmlRpcDataType.StringDataType:
				typeNode.removeNode();
				typeNode = n;
				//fall through

			default:
				var value:String = obj.toString();
				if (type == ASXmlRpcDataType.CDataDataType) {
					value = "<![CDATA[" + value + "]]>";
				}

				typeNode.appendChild(g_xml.createTextNode(value));
				break;
		}

		return n;
	}

	private var m_objectMap:Object;

	/**
	 * Deserializes an XMLNode into an object.
	 */
	public function deserializeObjectWithNode(node:XMLNode):Object {
		var val:Object = null;
		var strVal:String = "";
		if (node.nodeType == 3) {
			strVal = node.nodeValue;
		} else {
			strVal = node.firstChild.nodeValue;
		}

		switch (node.nodeName) {
			case ASXmlRpcDataType.I4DataType.tagName:
			case ASXmlRpcDataType.IntDataType.tagName:
				val = parseInt(strVal, 10);
				break;

			case ASXmlRpcDataType.BoolDataType.tagName:
				val = strVal == "1" || strVal == "true";
				break;

			case ASXmlRpcDataType.DoubleDataType.tagName:
				val = parseFloat(strVal);
				break;

			case ASXmlRpcDataType.DateDataType.tagName:
				try {
					val = g_dateFormatterBasic.dateFromString(strVal).internalDate();
				} catch(e) {
					val = g_dateFormatter.dateFromString(strVal).internalDate();
				}
				break;

			case ASXmlRpcDataType.StructDataType.tagName:
				var len:Number = node.childNodes.length;
				
				//
				// Check for an object ID
				//
				var objectID:String;
				var found:Boolean = false;
				for (var i:Number = len - 1; i >= 0; i--) {
					var memberNode:XMLNode = node.childNodes[i];
					var name:String = "";
					for (var j:Number = 0; j < 2; j++) {
						switch (memberNode.childNodes[j].nodeName) {
							case ASXmlRpcConstants.NODE_NAME:
								name = memberNode.childNodes[j].firstChild.nodeValue;
								if (name == ASXmlRpcConstants.MEMBER_OBJECTID) {
									var idx:Number = j == 0 ? 1 : 0;
									objectID = memberNode.childNodes[idx]
										.firstChild.nodeValue;
									found = true;
								}
								break;
						}
					}
					
					if (found) {
						break;
					}
				}
				
				//
				// We already have the object. Break
				//
				if (objectID != null && m_objectMap[objectID] != null) {
					return m_objectMap[objectID];
				}
				
				//
				// Extract the values
				//
				var memberNames:Array = [];
				var toDeserialize:Object = {};
				len = node.childNodes.length;
				for (var i:Number = 0; i < len; i++) {
					var memberNode:XMLNode = node.childNodes[i];
					var name:String = "";
					var mval:XMLNode = null;
					for (var j:Number = 0; j < 2; j++) {
						switch (memberNode.childNodes[j].nodeName) {
							case ASXmlRpcConstants.NODE_NAME:
								name = memberNode.childNodes[j].firstChild.nodeValue;
								break;

							case ASXmlRpcConstants.NODE_VALUE:
								mval = memberNode.childNodes[j].firstChild;
								break;
						}
					}
					memberNames.push(name);
					toDeserialize[name] = mval;
				}

				//
				// Check if this should be a class, and if so, build it
				//
				if (toDeserialize[ASXmlRpcConstants.MEMBER_CLASSNAME] != null) {
					var className:String = deserializeObjectWithNode(
						toDeserialize[ASXmlRpcConstants.MEMBER_CLASSNAME]).toString();
					var inst:Object = ASUtils.createInstanceOf(
						eval(className), []);
					//
					// Verify that an instance was created
					//
					if (inst == null) {
						var e:NSException = NSException.exceptionWithNameReasonUserInfo(
							NSException.NSInternalInconsistency,
							"Was unable to instantiate an instance of the " +
							className + " class",
							null);
						trace(e);
						throw e;
					}
					
					val = inst;
				} else {
					val = {};
				}
				
				//
				// Add the value to the map
				//
				if (objectID != null) {
					m_objectMap[objectID.toString()] = val;
				}
				
				//
				// Set the properties
				//
				len = memberNames.length;
				for (var i:Number = 0; i < len; i++) {
					var k:String = memberNames[i];

					if (k != ASXmlRpcConstants.MEMBER_CLASSNAME
							&& k != ASXmlRpcConstants.MEMBER_OBJECTID) {
						//
						// Must assign to v, and not to val[k] directly.
						//
						var v:Object = deserializeObjectWithNode(toDeserialize[k]);
						val[k] = v;
					}
				}
				
				break;

			case ASXmlRpcDataType.ArrayDataType.tagName:
				val = new Array();
				var dataNode:XMLNode = node.firstChild;
				var len:Number = dataNode.childNodes.length;
				for (var i:Number = 0; i < len; i++) {
					var obj = deserializeObjectWithNode(
						dataNode.childNodes[i].firstChild); 
					val[i] = obj;
				}

				break;

			case ASXmlRpcDataType.StringDataType.tagName:
			case ASXmlRpcDataType.CDataDataType.tagName:
			default:
				val = strVal;
				if (strVal == undefined) {
					val = "";
				}
				break;
		}

		return val;
	}

	/**
	 * Deserializes an XML-RPC response into an object.
	 */
	public function deserializeResponseWithXml(response:XML):Object {
		m_objectMap = {};
		
		var value:XMLNode = response.firstChild.firstChild.firstChild.firstChild.firstChild;
		return deserializeObjectWithNode(value);
	}

	/**
	 * Deserializes an XML-RPC response into an object.
	 */
	public function deserializeFaultWithXml(response:XML):Object {
		var structRoot:XMLNode = response.firstChild.firstChild.firstChild.firstChild;
		return deserializeObjectWithNode(structRoot);
	}

	/**
	 * Attempts to determine the type associated with obj.
	 *
	 * If obj is a number type, its type will be returned as double.
	 */
	private function getTypeWithObject(obj:Object):ASXmlRpcDataType {
		var type:ASXmlRpcDataType = null;

		if (ASUtils.isCollection(obj)) {
			type = ASXmlRpcDataType.ArrayDataType;
		}
		else if (ASUtils.isNumber(obj)) {
			type = ASXmlRpcDataType.DoubleDataType;
		}
		else if (ASUtils.isString(obj)) {
			type = ASXmlRpcDataType.StringDataType;
		}
		else if (ASUtils.isBoolean(obj)) {
			type = ASXmlRpcDataType.BoolDataType;
		}
		else if (ASUtils.isDate(obj)) {
			type = ASXmlRpcDataType.DateDataType;
		} else {
			type = ASXmlRpcDataType.StructDataType;
		}

		return type;
	}
}