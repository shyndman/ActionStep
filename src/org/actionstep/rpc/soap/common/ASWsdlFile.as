/* See LICENSE for copyright and terms of use */

import org.actionstep.NSDictionary;
import org.actionstep.rpc.soap.ASSoapDataType;
import org.actionstep.rpc.soap.ASSoapUtils;
import org.actionstep.rpc.soap.common.ASSchema;
import org.actionstep.rpc.soap.common.ASSchemaElement;
import org.actionstep.rpc.soap.common.ASWsdlBinding;
import org.actionstep.rpc.soap.common.ASWsdlElement;
import org.actionstep.rpc.soap.common.ASWsdlMessage;
import org.actionstep.rpc.soap.common.ASWsdlPortType;
import org.actionstep.rpc.soap.common.ASWsdlService;
import org.actionstep.rpc.soap.common.ASWsdlTypes;

/**
 * <p>
 * Used internally to represent a WSDL file. An instance of this class stores
 * all WSDL related information, such as messages, portTypes, bindings,
 * services, types and documentation.
 * </p>
 * <p>
 * !!!TODO!!!
 * This needs an overhaul to get namespace lookups working properly.
 * </p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.common.ASWsdlFile extends ASWsdlElement {
	
	private static var g_wsdlDocs:NSDictionary;
	
	public var targetNamespace:String;
	public var prefix:String;
	public var parentWsdlFile:ASWsdlFile;
	public var unresolvedImports:Number;
	public var isRootWsdl:Boolean;
	public var messages:NSDictionary;
	public var portTypes:NSDictionary;
	public var services:NSDictionary;
	public var bindings:NSDictionary;
	public var types:ASWsdlTypes;
	public var toParse:Array;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASSoapWsdl</code> class.
	 */
	public function ASWsdlFile(targetNamespace:String) {
		this.targetNamespace = targetNamespace;
		messages = NSDictionary.dictionary();
		portTypes = NSDictionary.dictionary();
		services = NSDictionary.dictionary();
		bindings = NSDictionary.dictionary();
		types = new ASWsdlTypes();
		unresolvedImports = 0;
		isRootWsdl = false;
		parentWsdlFile = null;
		toParse = [];
		
		g_wsdlDocs.setObjectForKey(this, this.targetNamespace);
	}
	
	//******************************************************
	//*          Adding and accessing attributes
	//******************************************************
	
	/**
	 * Adds a service to the WSDL file.
	 */
	public function addService(service:ASWsdlService):Void {
		services.setObjectForKey(service, service.name);
	}
	
	/**
	 * Returns the service named <code>name</code>. If that service doesn't
	 * exist, and <code>dflt</code> is <code>true</code>, the first service
	 * contained in the WSDL will be returned.
	 */
	public function serviceWithNameDefault(name:String, dflt:Boolean):ASWsdlService {
		var service:ASWsdlService = ASWsdlService(services.objectForKey(name));
		if (service == null && dflt) {
			service = ASWsdlService(services.allValues().objectAtIndex(0));
		}
		
		return service;
	}
	
	/**
	 * Adds a binding to the WSDL file.
	 */
	public function addBinding(binding:ASWsdlBinding):Void {
		bindings.setObjectForKey(binding, binding.name);
	}
	
	/**
	 * <p>
	 * Returns the binding named <code>name</code>, or <code>null</code> if not
	 * found.
	 * </p>
	 * <p>
	 * If name is in the format "namespace:localName", then namespace should be
	 * <code>#prefix</code>. If it is just a name without a colon, the
	 * method assumes the name is in the target namespace. 
	 * </p>
	 */
	public function bindingWithName(name:String):ASWsdlBinding {
		var parts:Array = ASSoapUtils.partsFromName(name);
		if (parts[0] == "") {
			parts[0] = prefix;
		}
		
		return ASWsdlBinding(bindings.objectForKey(parts[1]));
	}
	
	/**
	 * Adds a message to the WSDL file.
	 */
	public function addMessage(message:ASWsdlMessage):Void {
		messages.setObjectForKey(message, message.name);
	}
	
	/**
	 * <p>
	 * Returns the message named <code>name</code>, or <code>null</code> if not
	 * found.
	 * </p>
	 * <p>
	 * If name is in the format "namespace:localName", then namespace should be
	 * <code>#prefix</code>. If it is just a name without a colon, the
	 * method assumes the name is in the target namespace. 
	 * </p>
	 */
	public function messageWithName(name:String):ASWsdlMessage {
		var parts:Array = ASSoapUtils.partsFromName(name);
		if (parts[0] == "") {
			parts[0] = prefix;
		}
		
		return ASWsdlMessage(messages.objectForKey(parts[1]));
	}
	
	/**
	 * Adds a port type to the WSDL file.
	 */
	public function addPortType(portType:ASWsdlPortType):Void {
		portTypes.setObjectForKey(portType, portType.name);
	}
	
	/**
	 * <p>
	 * Returns the port type named <code>name</code>, or <code>null</code> if not
	 * found.
	 * </p>
	 * <p>
	 * If name is in the format "namespace:localName", then namespace should be
	 * <code>#prefix</code>. If it is just a name without a colon, the
	 * method assumes the name is in the target namespace. 
	 * </p>
	 */
	public function portTypeWithName(name:String):ASWsdlPortType {
		var parts:Array = ASSoapUtils.partsFromName(name);
		if (parts[0] == "") {
			parts[0] = prefix;
		}
		
		return ASWsdlPortType(portTypes.objectForKey(parts[1]));
	}
	
	/**
	 * <p>
	 * Returns the element named <code>name</code>, or <code>null</code> if not
	 * found.
	 * </p>
	 * <p>
	 * If name is in the format "namespace:localName", then namespace should be
	 * <code>#prefix</code>. If it is just a name without a colon, the
	 * method assumes the name is in the target namespace. 
	 * </p>
	 */
	public function elementWithName(name:String):ASSchemaElement {
		var parts:Array = ASSoapUtils.partsFromName(name);
		if (parts[0] == "") {
			parts[0] = prefix;
		}
		
		return ASSchemaElement(types.schemaWithPrefix(parts[0])
			.elementWithName(parts[1]));
	}
	
	/**
	 * <p>
	 * Returns the type named <code>name</code>, or <code>null</code> if not
	 * found.
	 * </p>
	 * <p>
	 * If name is in the format "namespace:localName", then namespace should be
	 * <code>#prefix</code>. If it is just a name without a colon, the
	 * method assumes the name is in the target namespace. 
	 * </p>
	 */
	public function typeWithName(name:String):ASSoapDataType {
		var parts:Array = ASSoapUtils.partsFromName(name);
		if (parts[0] == "") {
			parts[0] = prefix;
		}
		
		return ASSoapDataType(types.schemaWithPrefix(parts[0]).typeWithName(parts[1]));
	}
	
	/**
	 * Returns this WSDL file's schema.
	 */
	public function schema():ASSchema {
		return types.schemaWithPrefix(prefix);
	}
	
	//******************************************************
	//*             Imports and WSDL tree
	//******************************************************
	
	/**
	 * Returns the root WSDL file.
	 */
	public function rootWsdl():ASWsdlFile {
		var parent:ASWsdlFile = this;
		
		while (parent.parentWsdlFile != null) {
			parent = parent.parentWsdlFile;
		}
		
		return parent;
	}
	
	/**
	 * Increases the unresolved import count of this file and its ancestors.
	 */
	public function addUnresolvedImport():Void {
		var parent:ASWsdlFile = this;
		
		do {
			parent.unresolvedImports++;
			parent = parent.parentWsdlFile;
		} while (parent.parentWsdlFile != null);
	}
	
	/**
	 * Decreases the unresolved import count of this file and its ancestors.
	 */
	public function removeUnresolvedImport():Void {
		var parent:ASWsdlFile = this;
		
		do {
			parent.unresolvedImports--;
			parent = parent.parentWsdlFile;
		} while (parent.parentWsdlFile != null);
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		//
		// Add messages
		//
		var ret:String = "ASWsdlFile(targetNamespace=" + targetNamespace 
			+ ", prefix=" + prefix
			+ ",\nmessages=" + messages.toString();
				
		//
		// Add portTypes
		//		
		ret += ",\nportTypes=" + portTypes.toString();
				
		//
		// Add services
		//
		ret += ",\nservices=" + services.toString();
		
		//
		// Add bindings
		//
		ret += ",\nbindings=" + bindings.toString();
				
		//
		// Add types
		//
		ret += ",\ntypes=" + (types == null ? "null" : "\n" + types.toString()) + ")";
		
		return ret;
	}
	
	//******************************************************
	//*              Getting WSDLs by namespace
	//******************************************************
	
	public static function wsdlForNamespace(namespace:String):ASWsdlFile {
		return ASWsdlFile(g_wsdlDocs.objectForKey(namespace));
	}
	
	//******************************************************
	//*                Static construction
	//******************************************************
	
	private static function initialize():Void {
		g_wsdlDocs = NSDictionary.dictionary();
	}
}