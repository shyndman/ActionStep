/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.aib.AIBObject;
import org.aib.configuration.AppSettings;
import org.aib.configuration.ConfigSections;
import org.aib.configuration.SectionHandlerProtocol;

/**
 * Handles the <code>palettes</code> section of the AIB configuration file.
 * 
 * @author Scott Hyndman
 */
class org.aib.configuration.PalettesSectionHandler extends AIBObject 
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
				case "palette":
					
					//
					// Extract key-value pair from node.
					//
					var type:String = child.attributes.type;

					if (null == type) {
						trace("type is a required attribute for palette tags",
							ASDebugger.WARNING);
						continue;
					}
					
					//
					// Add to app settings.
					//
					AppSettings.addSettingWithSectionNameValue(
						ConfigSections.PALETTES, type);
					break;
					
				default:
					trace("Unrecognized node name: " + child.nodeName,
						ASDebugger.WARNING);
					break;
			}
			
		}
	}
}