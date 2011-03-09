/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.aib.AIBObject;
import org.aib.configuration.AppSettings;
import org.aib.configuration.ConfigSections;
import org.aib.configuration.SectionHandlerProtocol;

/**
 * @author Scott Hyndman
 */
class org.aib.configuration.LibrariesSectionHandler extends AIBObject 
		implements SectionHandlerProtocol {
	
	//******************************************************															 
	//*                    Construction
	//******************************************************
	
	function initWithSectionNode(node:XMLNode):SectionHandlerProtocol {	
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
				case "library":
					
					//
					// Extract key-value pair from node.
					//
					var src:String = child.attributes.src;

					if (null == src) {
						trace("src is a required attribute for library tags",
							ASDebugger.WARNING);
						continue;
					}
					
					//
					// Add to app settings.
					//
					AppSettings.addSettingWithSectionNameValue(
						ConfigSections.LIBRARIES, src);
					break;
					
				default:
					trace("Unrecognized node name: " + child.nodeName,
						ASDebugger.WARNING);
					break;
			}
			
		}
	}
}