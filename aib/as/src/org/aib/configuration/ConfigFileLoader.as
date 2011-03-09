/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.ASUtils;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSNotificationCenter;
import org.aib.AIBObject;
import org.aib.configuration.ConfigSections;
import org.aib.configuration.SectionHandlerProtocol;

/**
 *
 *
 * @author Scott Hyndman
 */
class org.aib.configuration.ConfigFileLoader extends AIBObject {
	//
	// Constants for internal use.
	//
	private static var HANDLER_TYPE_FUNCTION:Number = 1;
	private static var HANDLER_TYPE_CLASS:Number = 2;
	
	/** The xml connector, for loading config files. */
	private var m_xml:XML;
	
	/** The path where the config file can be found. */
	private var m_url:String;
	
	/** A hash map of handlers for the configuration sections. */
	private var m_handlers:Object;
	
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the ConfigFileLoader class.
	 *
	 * @param path The path to the config file.
	 */	
	public function ConfigFileLoader() {
		m_handlers = {}; // Create the handler hash map.
	}
	
	/**
	 * Initializes the configuration file to being loading the configuration
	 * file at <code>url</code>.
	 * 
	 * The config file loader will post an 
	 * <code>AIBConfigFileDidLoadNotification</code> notification to the default
	 * notification center when the loading is complete.
	 */
	public function initWithContentsOfURL(url:String):ConfigFileLoader {
		super.init();
		
		//
		// Create the XML connector and prepare it for loading.
		//
		m_url = url;
		var self:ConfigFileLoader = this;
		m_xml = new XML();
		m_xml.ignoreWhite = true;
		m_xml.onLoad = function(success:Boolean):Void {
			try {
				self["configFileDidLoad"](success);
			} catch (e:NSException) {
				self.asError(e.description());
			}
		};
		
		//
		// Begin loading
		//
		beginLoading();
		
		return this;
	}
	
	//******************************************************															 
	//*                  Section handlers
	//******************************************************
	
	/**
	 * Adds a handler to the list of handlers.
	 */
	private function addHandlerWithNameTypeConstructor(name:String, type:Number, 
			handler:Function):Void {
		m_handlers[name] = {type: type, handler: handler};
	}
	
	
	/**
	 * Gets the handler for the section named <code>name</code>.
	 */
	private function getHandlerForName(name:String):Object	{
		var info:Object = m_handlers[name];
		var handler:Object;
		
		switch (info.type) {
			case HANDLER_TYPE_CLASS:
				handler = ASUtils.createInstanceOf(info.handler, []);
				break;
				
			case HANDLER_TYPE_FUNCTION:
				handler = info.handler;
				break;
				
		}
		
		return handler;
	}
	
	//******************************************************															 
	//*              Loading the config file
	//******************************************************
	
	/**
	 * Triggers the loading of the configuration file.
	 */
	private function beginLoading():Void	{
		m_xml.load(m_url);
	}
	
	/**
	 * Fired when the connector finishes loading the config file.
	 */
	private function configFileDidLoad(success:Boolean):Void {
		//
		// Trace out a warning.
		//
		if (!success) {
			trace("Did not load configuration file " + m_url,
				ASDebugger.WARNING);
			NSNotificationCenter.defaultCenter(
				).postNotificationWithNameObjectUserInfo(
				AIBConfigFileDidLoadNotification,
				this,
				NSDictionary.dictionaryWithObjectForKey(false, "AIBSuccess"));
			return;
		}
		
		var root:XMLNode = m_xml.firstChild;
			
		//
		// Loop through the top-level config sections until
		// ConfigSections.SECTIONSETTINGS is found, and add the 
		// handlers.
		//
		for (var child:XMLNode = root.firstChild; 
				child != null; 
				child = child.nextSibling) {	
			if (child.nodeName != ConfigSections.SECTIONSETTINGS)
				continue;
				
			handleSectionSettings(child);
		}
			
		//
		// Loop through the top-level config sections and
		// handle each one in turn.
		//
		for (var child:XMLNode = root.firstChild; 
				child != null; 
				child = child.nextSibling) {	
			//
			// Do not parse section secttings.
			//
			if (child.nodeName == ConfigSections.SECTIONSETTINGS)
				continue;
			
			//
			// Get the handler.
			//
			var handler:Object = getHandlerForName(child.nodeName);
			
			if (handler == null) {
				trace("WARNING - ConfigFileLoader - No handler exists " +
				"for the section called " + child.nodeName + " in " + 
				m_url + ".");
				
				continue;
			}
				
			try {
				switch (typeof(handler)) {
					case "function":
						Function(handler).apply(this, [child]); // call function				
						break;
						
					case "object":
						var sh:SectionHandlerProtocol 
							= SectionHandlerProtocol(handler);
						
						//
						// If the handler implements SectionHandlerProtocol,
						// let it handle the node, otherwise issue a warning.
						//
						if (sh != null) {
							sh.initWithSectionNode(child);
						} else {
							trace("The handler for the " + child.nodeName + " "
								+ "section does not implement "
								+ "SectionHandlerProtocol.",
							ASDebugger.WARNING);
							continue;
						}
	
						break;					
				}
			} catch (e:NSException) {
				trace(e.description(), ASDebugger.ERROR);
				continue;
			}
		}
		
		//
		// Dispatch a notification
		//
		NSNotificationCenter.defaultCenter(
			).postNotificationWithNameObjectUserInfo(
			AIBConfigFileDidLoadNotification,
			this,
			NSDictionary.dictionaryWithObjectForKey(true, "AIBSuccess"));
	}
	
	//******************************************************															 *
	//*	                Private Methods
	//******************************************************

	private function handleSectionSettings(node:XMLNode):Void {		
		for (var child:XMLNode = node.firstChild; 
				child != null; 
				child = child.nextSibling) {		
			//
			// Handle differently depending on nodeName.
			//
			switch (child.nodeName)	{
				case ConfigSections.SECTION:
					
					//
					// Extract key-value pair from node.
					//
					var name:String = child.attributes.name;
					var type:String = child.attributes.type;
					var handler:Function;
					var handlertype:Number;
					
					//
					// Get the numeric handler type and corresponding
					// handler function.
					//
					switch (child.attributes.handlerType) {
						case "function":
							handlertype = HANDLER_TYPE_FUNCTION;
							handler = eval("this." + type);
							break;
							
						case "class":
							// Let it fall through.
						default: // class is default
							handlertype = HANDLER_TYPE_CLASS;
							handler = eval(type);
							break;
							
					}
					
					//
					// Validate handler existence.
					//
					if (typeof(handler) != "function") {
						trace("Handler for " + name + " is not of a valid type" 
							+ " (" + type + "). Make sure this class exists "
							+ "in the swf.", ASDebugger.ERROR);
						continue;
					}
					
					//
					// Add the handler.
					//
					addHandlerWithNameTypeConstructor(name, handlertype, handler);
					
					break;
					
				default:
					trace("Unrecognized node name: " + child.nodeName,
						ASDebugger.WARNING);
					break;
			}
		}		
	}
	
	//******************************************************															 
	//*                  Notifications
	//******************************************************
	
	/**
	 * Fired when an config file finishes loading, or an error is
	 * encountered during the load.
	 * 
	 * The userInfo dictionary contains the following:
	 * 	"AIBSuccess" - <code>true</code> if the load was successful (Boolean)
	 */
	public static var AIBConfigFileDidLoadNotification:Number
		= ASUtils.intern("AIBConfigFileDidLoadNotification");
}
