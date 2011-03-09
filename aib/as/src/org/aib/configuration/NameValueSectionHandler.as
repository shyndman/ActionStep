/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.aib.configuration.AppSettings;
import org.aib.configuration.SectionHandlerProtocol;

/**
 * A section handler that handles name value pairs and adds
 * them to AppSetting.config map.
 *
 * Can be subclassed to provide additional functionality. The
 * addPair() and deserialize() methods have been created to easily
 * change the behaviour of the class while leaving the parsing untouched.
 *
 * @author Scott Hyndman
 */
class org.aib.configuration.NameValueSectionHandler 
	implements org.aib.configuration.SectionHandlerProtocol
{	
	public var ITEM_NODE_NAME:String;
	private var m_node:XMLNode;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NameValueSectionHandler</code>
	 * class.
	 */
	public function NameValueSectionHandler() {		
		ITEM_NODE_NAME = "add";
	}
	
	/**
	 * @see affsys.acl.configuration.ISectionHandler#initWithSectionNode
	 */
	public function initWithSectionNode(node:XMLNode)
			:SectionHandlerProtocol {
		parseNode(node);
		return this;		
	}

	//******************************************************															 
	//*                   Public Methods
	//******************************************************
	
	/**
	 * Parses the node <code>node</code>.
	 */
	private function parseNode(node:XMLNode):Void {
		m_node = node;
		
		//
		// Loop through the configuration nodes.
		//
		// For some reason iterating the root.childNodes array doesn't work,
		// so instead I'm using child.nextSibling starting on root.firstChild.
		//
		for (var child:XMLNode = node.firstChild; 
				child != null; 
				child = child.nextSibling) {		
			//
			// Handle differently depending on nodeName.
			//
			switch (child.nodeName)	{
				case ITEM_NODE_NAME:
					
					//
					// Extract key-value pair from node.
					//
					var key:String = child.attributes.key;
					var value:String = child.attributes.value;
					
					//
					// Add to app settings.
					//
					setObjectForKey(deserialize(value), key);
					break;
					
				default:
					trace("Unrecognized node name: " + child.nodeName,
						ASDebugger.WARNING);
					break;
			}
			
		}
	}
	
	//******************************************************															 
	//*                Protected Methods
	//******************************************************
	
	/**
	 * Adds a pair as the implementation of the class dictates.
	 *
	 * Can be overridden by subclasses.
	 */
	private function setObjectForKey(value:Object, key:String):Void {		
		AppSettings.addSettingWithSectionNameValue(m_node.nodeName, 
			{name: key, value: value});
	}
	
	
	/**
	 * Deserializes the value half of the pair into an object.
	 *
	 * The default implementation is to leave as a string.
	 *
	 * Can be overridden by subclasses.
	 */
	private function deserialize(value:String):Object {
		return value;
	}
}