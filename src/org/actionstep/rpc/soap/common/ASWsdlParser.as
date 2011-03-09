/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.ASUtils;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.rpc.soap.ASSoapConstants;
import org.actionstep.rpc.soap.ASSoapUtils;
import org.actionstep.rpc.soap.common.ASSchema;
import org.actionstep.rpc.soap.common.ASSchemaComplexType;
import org.actionstep.rpc.soap.common.ASSchemaConstant;
import org.actionstep.rpc.soap.common.ASSchemaElement;
import org.actionstep.rpc.soap.common.ASWsdlBinding;
import org.actionstep.rpc.soap.common.ASWsdlConstant;
import org.actionstep.rpc.soap.common.ASWsdlElement;
import org.actionstep.rpc.soap.common.ASWsdlFile;
import org.actionstep.rpc.soap.common.ASWsdlMessage;
import org.actionstep.rpc.soap.common.ASWsdlMessagePart;
import org.actionstep.rpc.soap.common.ASWsdlOperation;
import org.actionstep.rpc.soap.common.ASWsdlOperationIO;
import org.actionstep.rpc.soap.common.ASWsdlPort;
import org.actionstep.rpc.soap.common.ASWsdlPortType;
import org.actionstep.rpc.soap.common.ASWsdlService;
import org.actionstep.rpc.soap.common.ASWsdlSoapBody;
import org.actionstep.rpc.soap.common.ASWsdlSoapOperation;
import org.actionstep.rpc.soap.common.ASWsdlTypes;
import org.actionstep.NSNotificationCenter;
import org.actionstep.rpc.soap.ASSoapConnection;

/**
 * Used internally to parse WSDL files.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlParser extends NSObject {
	
	//******************************************************
	//*                   Constants
	//******************************************************
	
	private static var TARGET_NAMESPACE_ATTRIBUTE:String = "targetNamespace";
	private static var NAMESPACE_ATTRIBUTE:String = "namespace";
	private static var NAME_ATTRIBUTE:String = "name";
	private static var TYPE_ATTRIBUTE:String = "type";
	private static var ELEMENT_ATTRIBUTE:String = "element";
	private static var MESSAGE_ATTRIBUTE:String = "message";
	private static var USE_ATTRIBUTE:String = "use";
	private static var SOAP_ACTION_ATTRIBUTE:String = "soapAction";
	private static var STYLE_ATTRIBUTE:String = "style";
	private static var MIN_OCCURS_ATTRIBUTE:String = "minOccurs";
	private static var MAX_OCCURS_ATTRIBUTE:String = "maxOccurs";
	private static var BINDING_ATTRIBUTE:String = "binding";
	private static var LOCATION_ATTRIBUTE:String = "location";
	private static var SCHEMA_LOCATION_ATTRIBUTE:String = "schemaLocation";
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private static var g_instance:ASWsdlParser;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASWsdlParser</code> class.
	 */
	private function ASWsdlParser() {
		
	}
	
	/**
	 * Initializes the parser.
	 */
	public function init():ASWsdlParser {
		super.init();
		
		return this;
	}
	
	//******************************************************
	//*               Creating a WSDL file
	//******************************************************
	
	/**
	 * Sets up the WSDL object and begins loading all imports.
	 */
	public function createWsdlFromXml(xml:XML):ASWsdlFile {
		var root:XMLNode = xml.firstChild;
		if (ASSoapUtils.localPartFromName(root.nodeName) != ASWsdlConstant.ASWsdlDefinitions.localPart) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"root node of WSDL file must be \"definitions\"",
				NSDictionary.dictionaryWithObjectForKey(xml, "ASWsdl"));
			trace(e);
			throw e;
		}
		
		//
		// Build the file
		//
		var namespace:String = root.attributes[TARGET_NAMESPACE_ATTRIBUTE];
		var wsdl:ASWsdlFile = new ASWsdlFile(namespace);
		
		//
		// Get all namespace prefixes
		//
		for (var k:String in root.attributes) {
			if (k == TARGET_NAMESPACE_ATTRIBUTE) {
				continue;
			}
			
			var prefix:String = ASSoapUtils.localPartFromName(k);
			ASSchema.addSchemaNamespace(root.attributes[k], prefix);
		}
		wsdl.prefix = ASSchema.prefixForUri(wsdl.targetNamespace);
		
		//
		// Process imports
		//
		processImports(wsdl, root);
		
		return wsdl;
	}
	
	//******************************************************
	//*                 Parsing the XML
	//******************************************************
	
	/**
	 * <p>
	 * Parses the WSDL XML file. This is called by the SOAP connection.
	 * </p>
	 * <p>
	 * This method throws an exception if an error is encountered during the
	 * parsing process.
	 * </p>
	 */
	public function parseWsdlXml(wsdl:ASWsdlFile, xml:XML):ASWsdlFile {
		var root:XMLNode = xml.firstChild;
		if (ASSoapUtils.localPartFromName(root.nodeName) != ASWsdlConstant.ASWsdlDefinitions.localPart) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"root node of WSDL file must be \"definitions\"",
				NSDictionary.dictionaryWithObjectForKey(xml, "ASWsdl"));
			trace(e);
			throw e;
		}
		
		return parseDefinitions(wsdl, root);
	}
	
	/**
	 * Parses the WSDL definitions element.
	 */
	private function parseDefinitions(wsdl:ASWsdlFile, defs:XMLNode):ASWsdlFile {				
		//
		// Cycle through children, parsing each in turn
		//
		var arr:Array = defs.childNodes;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var node:XMLNode = arr[i];
			var local:String = ASSoapUtils.localPartFromName(node.nodeName);
			
			//
			// Switch on node name
			//
			switch (local) {
				case ASWsdlConstant.ASWsdlTypes.localPart:
					parseTypes(wsdl, node);
					break;
				
				case ASWsdlConstant.ASWsdlMessage.localPart:
					parseMessage(wsdl, node);
					break;
					
				case ASWsdlConstant.ASWsdlPortType.localPart:
					parsePortType(wsdl, node);
					break;
					
				case ASWsdlConstant.ASWsdlBinding.localPart:
					parseBinding(wsdl, node);
					break;
					
				case ASWsdlConstant.ASWsdlService.localPart:
					parseService(wsdl, node);
					break;
					
				case ASWsdlConstant.ASWsdlDocumentation.localPart:
					parseDocumentation(wsdl, node);
					break;
					
				default:
					trace(ASDebugger.warning(
						"Unexpected <definitions> child encountered: " + local));
					break;
			}
		}
				
		return wsdl;
	}
	
	/**
	 * Parses a WSDL types node, and fills <code>wsdl</code> with the type
	 * information.
	 */
	private function parseTypes(wsdl:ASWsdlFile, typesNode:XMLNode):Void {
		//
		// Create types
		//
		var types:ASWsdlTypes = wsdl.types;
		
		//
		// Parse node contents
		//
		var arr:Array = typesNode.childNodes;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var child:XMLNode = arr[i];
			var local:String = ASSoapUtils.localPartFromName(child.nodeName);
			
			switch (local) {
				case ASWsdlConstant.ASWsdlDocumentation.localPart:
					parseDocumentation(types, child);
					break;
					
				case ASSchemaConstant.ASSchemaName.localPart:
					parseSchema(types, child);
					break;
					
				default:
					trace(ASDebugger.warning(
						"Unexpected <types> child encountered: " + local));
					break;
			}
		}
	}
	
	/**
	 * Parses the schema and attaches the resulting object to the 
	 * <code>type</code> object.
	 */
	private function parseSchema(types:ASWsdlTypes, schemaNode:XMLNode):Void {
		//
		// Create a new schema
		//
		var schema:ASSchema = new ASSchema(
			schemaNode.attributes[TARGET_NAMESPACE_ATTRIBUTE]);
		
		//
		// Parse node contents
		//
		var arr:Array = schemaNode.childNodes;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var child:XMLNode = arr[i];
			var local:String = ASSoapUtils.localPartFromName(child.nodeName);
									
			switch (local) {
				case ASSchemaConstant.ASSchemaElementType.localPart:
					parseSchemaElement(schema, child);
					break;
					
				case ASSchemaConstant.ASSchemaComplexType.localPart:
					parseSchemaComplexType(schema, child);
					break;
					
				default:
					trace(ASDebugger.warning(
						"Unexpected <schema> child encountered: " + local));
					break;
			}
		}
		
		//
		// Add the schema to the types object
		//
		types.addSchema(schema);
	}
	
	/**
	 * <p>
	 * Parses a schema element and adds it to <code>elementHolder</code>.
	 * </p>
	 * <p>
	 * <code>elementHolder</code> must implement 
	 * <code>#addElement(ASSchemaElement)</code>.
	 * </p>
	 */
	private function parseSchemaElement(elementHolder:Object, elementNode:XMLNode):Void {
		if (!ASUtils.respondsToSelector(elementHolder, "addElement")) {
			trace(ASDebugger.error("elementHolder must implement addElement()"));
			return;
		}
		
		//
		// Determine max occurs
		//
		var maxOccurs:Number;
		var strMaxOccurs = elementNode.attributes[MAX_OCCURS_ATTRIBUTE];
		if (strMaxOccurs == ASSoapConstants.OCCURS_UNBOUNDED) {
			maxOccurs = Number.MAX_VALUE;
		} else {
			maxOccurs = parseInt(strMaxOccurs, 10);
		}
		
		//
		// Create a new element
		//
		var element:ASSchemaElement = new ASSchemaElement(
			elementNode.attributes[NAME_ATTRIBUTE],
			elementNode.attributes[TYPE_ATTRIBUTE],
			parseInt(elementNode.attributes[MIN_OCCURS_ATTRIBUTE], 10),
			maxOccurs);
		
		//
		// Get the schema
		//
		var schema:ASSchema = ASSchema(elementHolder);
		if (schema == null) {
			schema = ASSchemaComplexType(elementHolder).schema;
		}
		
		//
		// If a type is not specified, parse the first complexType element child
		//	
		if (element.typeName == null) {
			//
			// Parse node contents
			//
			var arr:Array = elementNode.childNodes;
			var len:Number = arr.length;
			for (var i:Number = 0; i < len; i++) {
				var child:XMLNode = arr[i];
				var local:String = ASSoapUtils.localPartFromName(child.nodeName);
										
				if (local == ASSchemaConstant.ASSchemaComplexType.localPart) {
					element.typeName = parseSchemaComplexType(schema, child);
					break;
				}
			}
		}
		
		//
		// Resolve the type
		//
		element.type = schema.typeWithName(ASSoapUtils.localPartFromName(
			element.typeName));
		
		//
		// Add the element to the schema
		//
		elementHolder.addElement(element);
	}
	
	/**
	 * Parses a complex type node, adds the type to the schema, and returns the
	 * name of the type.
	 */
	private function parseSchemaComplexType(schema:ASSchema, typeNode:XMLNode):String {
		//
		// Build a new complex type and add it to the schema
		//
		var type:ASSchemaComplexType = new ASSchemaComplexType(
			typeNode.attributes[NAME_ATTRIBUTE]);
		schema.addComplexType(type);
		
		//
		// Parse node contents
		//
		var arr:Array = typeNode.childNodes;
		var len:Number = arr.length;
		var contentFound:Boolean = false;
		var sequenceCnt:Number = -1;
		for (var i:Number = 0; i < len; i++) {
			var child:XMLNode = arr[i];
			var local:String = ASSoapUtils.localPartFromName(child.nodeName);
			
			switch (local) {
				case ASSchemaConstant.ASSchemaAll.localPart:	
				case ASSchemaConstant.ASSchemaSequence.localPart:
					sequenceCnt = parseSequence(type, child);	
					contentFound = true;
					break;
					
				case ASSchemaConstant.ASSchemaComplexContent.localPart:
					// TODO implement
					contentFound = true;
					break;
					
				case ASSchemaConstant.ASSchemaSimpleContent.localPart:
					// TODO implement
					contentFound = true;
					break;
					
				default:
					trace(ASDebugger.warning(
						"Unexpected <complexType> child encountered: " + local));
					break;
			}
			
			if (contentFound) {
				break;
			}
		}
		
		//
		// This may be an array type, not a complex type. Let's find out.
		//
		if (sequenceCnt) {
			var element:ASSchemaElement = ASSchemaElement(type.elements.objectAtIndex(0));
			
			if (element.maxOccurs > 1) {
				schema.removeComplexType(type);
				schema.addArrayType(type);
			}
		}
		
		return type.name;
	}
	
	/**
	 * Parses a complex type's internal sequence and returns the number of
	 * elements in the sequence.
	 */
	private function parseSequence(type:ASSchemaComplexType, seqNode:XMLNode):Number {
		//
		// Parse node contents
		//
		var arr:Array = seqNode.childNodes;
		var len:Number = arr.length;
		var cnt:Number = 0;
		for (var i:Number = 0; i < len; i++) {
			var child:XMLNode = arr[i];
			var local:String = ASSoapUtils.localPartFromName(child.nodeName);
						
			switch (local) {
				case ASSchemaConstant.ASSchemaElementType.localPart:
					parseSchemaElement(type, child);
					cnt++;
					break;
						
				default:
					trace(ASDebugger.warning(
						"Unexpected <" + ASSoapUtils.localPartFromName(seqNode.nodeName) 
							+ "> child encountered: " + local));
					break;
			}
		}
		
		return cnt;
	}
	
	/**
	 * Parses a WSDL message node, and adds the message to <code>wsdl</code>.
	 */
	private function parseMessage(wsdl:ASWsdlFile, node:XMLNode):Void {
		//
		// Create message
		//
		var message:ASWsdlMessage = new ASWsdlMessage(node.attributes[NAME_ATTRIBUTE]);
		
		//
		// Add child nodes (parts / documentation)
		//
		var arr:Array = node.childNodes;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var child:XMLNode = arr[i];
			var local:String = ASSoapUtils.localPartFromName(child.nodeName);
			
			switch (local) {
				case ASWsdlConstant.ASWsdlDocumentation.localPart:
					parseDocumentation(message, child);
					break;
					
				case ASWsdlConstant.ASWsdlParameter.localPart:
					var part:ASWsdlMessagePart = new ASWsdlMessagePart(
						child.attributes[NAME_ATTRIBUTE],
						child.attributes[TYPE_ATTRIBUTE],
						child.attributes[ELEMENT_ATTRIBUTE]);
						
					//
					// Ensure required fields
					//
					if (part.typeName == null && part.elementName == null) {
						var e:NSException = NSException.exceptionWithNameReasonUserInfo(
							NSException.NSInternalInconsistency,
							"All wsdl:part elements must have either the "
							+ "type or element attributes. Offending part named "
							+ part.name,
							null);
						trace(e);
						throw e;
					}
					
					message.parts.push(part);
					break;
					
				default:
					trace(ASDebugger.warning(
						"Unexpected <message> child encountered: " + local));
					break;
			}
		}
		
		//
		// Add message to wsdl
		//
		wsdl.addMessage(message);
	}

	/**
	 * Parses a WSDL port type node, and adds the port type to <code>wsdl</code>.
	 */	
	private function parsePortType(wsdl:ASWsdlFile, portNode:XMLNode):Void {
		//
		// Create port type
		//
		var port:ASWsdlPortType = new ASWsdlPortType(portNode.attributes[NAME_ATTRIBUTE]);
		
		//
		// Parse node contents
		//
		var arr:Array = portNode.childNodes;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var child:XMLNode = arr[i];
			var local:String = ASSoapUtils.localPartFromName(child.nodeName);
			
			switch (local) {
				case ASWsdlConstant.ASWsdlDocumentation.localPart:
					parseDocumentation(port, child);
					break;
					
				case ASWsdlConstant.ASWsdlOperation.localPart:
					parseOperation(port, child);
					break;
					
				default:
					trace(ASDebugger.warning(
						"Unexpected <portType> child encountered: " + local));
					break;
			}
		}
		
		//
		// Add port type to wsdl
		//
		wsdl.addPortType(port);
	}
	
	/**
	 * <p>
	 * Parses an operation element and adds it to <code>opHolder</code>.
	 * </p>
	 * <p>
	 * <code>opHolder</code> must implement addOperation(ASWsdlOperation).
	 * </p>
	 */
	private function parseOperation(opHolder:Object, opNode:XMLNode):ASWsdlOperation {
		if (!ASUtils.respondsToSelector(opHolder, "addOperation")) {
			trace(ASDebugger.error("opHolder must implement addOperation()"));
			return null;
		}
		
		var op:ASWsdlOperation = new ASWsdlOperation(opNode.attributes[NAME_ATTRIBUTE]);
		
		//
		// Parse node contents
		//
		var arr:Array = opNode.childNodes;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var child:XMLNode = arr[i];
			var local:String = ASSoapUtils.localPartFromName(child.nodeName);
						
			switch (local) {
				case ASWsdlConstant.ASWsdlDocumentation.localPart:
					parseDocumentation(op, child);
					break;
				
				case ASWsdlConstant.ASWsdlSoapOperation.localPart:
					op.soapOperation = new ASWsdlSoapOperation(
						child.attributes[SOAP_ACTION_ATTRIBUTE],
						child.attributes[STYLE_ATTRIBUTE]);
						
					//
					// Default style to soap:binding style
					//
					if (op.soapOperation.style == null && opHolder.style != null) {
						op.soapOperation.style = opHolder.style;
					}
					
					break;
					
				case ASWsdlConstant.ASWsdlInput.localPart:
					op.input = parseOperationIO(child);
					break;
					
				case ASWsdlConstant.ASWsdlOutput.localPart:
					op.output = new ASWsdlOperationIO(
						child.attributes[MESSAGE_ATTRIBUTE]);
					break;
					
				default:
					trace(ASDebugger.warning(
						"Unexpected <portType> child encountered: " + local));
					break;
			}
		}
		
		opHolder.addOperation(op);
		return op;
	}
	
	/**
	 * Parses an operation input or output element, and returns an object that
	 * represents it.
	 */
	private function parseOperationIO(ioNode:XMLNode):ASWsdlOperationIO {
		var io:ASWsdlOperationIO = new ASWsdlOperationIO(
			ioNode.attributes[MESSAGE_ATTRIBUTE]);
			
		//
		// Parse node contents
		//
		var arr:Array = ioNode.childNodes;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var child:XMLNode = arr[i];
			var local:String = ASSoapUtils.localPartFromName(child.nodeName);
						
			switch (local) {
				case ASWsdlConstant.ASWsdlDocumentation.localPart:
					parseDocumentation(io, child);
					break;
				
				case ASWsdlConstant.ASWsdlBody.localPart:
					io.body = new ASWsdlSoapBody(child.attributes[USE_ATTRIBUTE]);
					
					if (io.body.use == null) { // required attribute
						var e:NSException = NSException.exceptionWithNameReasonUserInfo(
							NSException.NSInternalInconsistency,
							"All soap:body elements must have \"use\" " 
							+ "attributes. Problem encountered on the " 
							+ "following node: " + ASDebugger.dump(ioNode.parentNode),
							null);
						trace(e);
						throw e;
					}
					
					break;
					
				default:
					trace(ASDebugger.warning(
						"Unexpected <input>/<output> child encountered: " + local));
					break;
			}
		}	
			
		return io;
	}
	
	/**
	 * Parses a WSDL binding node, and adds the binding to <code>wsdl</code>.
	 */
	private function parseBinding(wsdl:ASWsdlFile, bindingNode:XMLNode):Void {
		//
		// Create the binding
		//
		var binding:ASWsdlBinding = new ASWsdlBinding(
			bindingNode.attributes[NAME_ATTRIBUTE],
			bindingNode.attributes[TYPE_ATTRIBUTE]);
			
		//
		// Parse node contents
		//
		var arr:Array = bindingNode.childNodes;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var child:XMLNode = arr[i];
			var local:String = ASSoapUtils.localPartFromName(child.nodeName);
			
			switch (local) {
				case ASWsdlConstant.ASWsdlDocumentation.localPart:
					parseDocumentation(binding, child);
					break;
					
				//
				// Binding operation
				//
				case ASWsdlConstant.ASWsdlOperation.localPart:
					var op:ASWsdlOperation = parseOperation(binding, child);
					if (op == null) {
						break;
					}
					
					//
					// Throw exception if operation does not have a SOAP action
					//
					if (op.soapOperation == null || op.soapOperation.soapAction == null) {
						var e:NSException = NSException.exceptionWithNameReasonUserInfo(
							NSException.NSInternalInconsistency,
							"All binding wsdl:operation elements must have one "
							+ "soap:operation child. Offending element named "
							+ op.name,
							null);
						trace(e);
						throw e;
					}
					break;
				
				case ASWsdlConstant.ASWsdlSoapBinding.localPart:
					var style:String = child.attributes[STYLE_ATTRIBUTE];
					if (style != null) {
						binding.style = style;
					}
					break;
					
				default:
					trace(ASDebugger.warning(
						"Unexpected <binding> child encountered: " + local));
					break;
			}
		}
			
		//
		// Add the binding to the wsdl
		//
		wsdl.addBinding(binding);
	}
	
	/**
	 * Parses a WSDL service node, and adds the service to <code>wsdl</code>.
	 */
	private function parseService(wsdl:ASWsdlFile, serviceNode:XMLNode):Void {
		var service:ASWsdlService = new ASWsdlService(
			serviceNode.attributes[NAME_ATTRIBUTE]);
			
		//
		// Parse node contents
		//
		var arr:Array = serviceNode.childNodes;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var child:XMLNode = arr[i];
			var local:String = ASSoapUtils.localPartFromName(child.nodeName);
			
			
			switch (local) {
				case ASWsdlConstant.ASWsdlDocumentation.localPart:
					parseDocumentation(service, child);
					break;
					
				case ASWsdlConstant.ASWsdlPort.localPart:
					var port:ASWsdlPort = new ASWsdlPort(
						child.attributes[NAME_ATTRIBUTE],
						child.attributes[BINDING_ATTRIBUTE],
						child.firstChild.attributes[LOCATION_ATTRIBUTE]);
					service.addPort(port);
					break;
									
				default:
					trace(ASDebugger.warning(
						"Unexpected <service> child encountered: " + local));
					break;
			}
		}
			
		wsdl.addService(service);
	}

	/**
	 * Parses a WSDL documentation node, and adds the docs to <code>wsdl</code>.
	 */	
	private function parseDocumentation(element:ASWsdlElement, docs:XMLNode):Void {
		element.documentation = docs.firstChild.nodeValue;
	}
	
	//******************************************************
	//*                Handling Imports
	//******************************************************
	
	/**
	 * Processes WSDL imports.
	 */
	private function processImports(wsdl:ASWsdlFile, defs:XMLNode):Void {
		var arr:Array = defs.childNodes;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var node:XMLNode = arr[i];
			var local:String = ASSoapUtils.localPartFromName(node.nodeName);
			if (local == ASWsdlConstant.ASWsdlImport.localPart) {
				performImport(wsdl, node);
			}
			else if (local == ASSchemaConstant.ASSchemaName.localPart) {
				processImports(wsdl, node);
			}
		}
	}
	
	/**
	 * Imports a WSDL or schema file.
	 */
	private function performImport(parent:ASWsdlFile, node:XMLNode):Void {
		parent.addUnresolvedImport();
		
		var isWSDL:Boolean = node.attributes[LOCATION_ATTRIBUTE] == null;
		var nameParts:Array = ASSoapUtils.partsFromName(node.nodeName);
		var namespace:String = node.attributes[NAMESPACE_ATTRIBUTE];
		var location:String = isWSDL
			? node.attributes[SCHEMA_LOCATION_ATTRIBUTE]
			: node.attributes[LOCATION_ATTRIBUTE];
				
		var xml:XML = new XML();
		xml.ignoreWhite = true;
		
		var self:ASWsdlParser = this;
		xml.onLoad = function(success:Boolean):Void {
			try {
				self["importDidLoadWithParentNodeNamespaceIsWSDL"](this, 
					success, parent, node, namespace, isWSDL);
			} catch (e:Error) {
				trace(e.toString());
			}
		};
		
		xml.load(location);
	}
		
	/**
	 * Invoked when the xml file loads.
	 */
	private function importDidLoadWithParentNodeNamespace(xml:XML, 
			success:Boolean, parent:ASWsdlFile, importNode:XMLNode, namespace:String, 
			isWSDL:Boolean):Void {
		if (!success) {
			// TODO error?
			return;
		}
		
		//
		// Resolved one more import
		//
		parent.removeUnresolvedImport();
			
		var local:String = ASSoapUtils.localPartFromName(xml.firstChild.nodeName);	
		if (isWSDL) {
			var wsdl:ASWsdlFile = new ASWsdlFile(namespace);
			wsdl.parentWsdlFile = parent;
								
			if (local == ASWsdlConstant.ASWsdlDefinitions.localPart) {
				processImports(wsdl, xml.firstChild);
			} else {
				// TODO error
			}
		} else {
			if (local == ASSchemaConstant.ASSchemaName.localPart) {
				processImports(parent, xml.firstChild);
			} else {
				// error
			}
		}
		
		//
		// Replace the import node with the first child of the loaded XML
		//
		importNode.parentNode.insertBefore(xml.firstChild, importNode);
		importNode.removeNode();
		
		//
		// Port notification if fully loaded
		//
		if (parent.rootWsdl().unresolvedImports == 0) {
			var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
			nc.postNotificationWithNameObject(
				ASSoapConnection.ASWsdlFileDidLoadNotification,
				parent.rootWsdl());
		}
	}
	
	//******************************************************
	//*                   Singleton
	//******************************************************
	
	/**
	 * Returns the WSDL parser instance.
	 */
	public static function instance():ASWsdlParser {
		if (g_instance == null) {
			g_instance = (new ASWsdlParser()).init();
		}
		
		return g_instance;
	}
}