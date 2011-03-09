/* See LICENSE for copyright and terms of use */

import org.actionstep.NSView;
import org.aib.AIBApplication;
import org.aib.inspector.InspectorBase;

/**
 * The help inspector.
 * 
 * @author Scott Hyndman
 */
class org.aib.inspector.HelpInspector extends InspectorBase {

	//******************************************************															 
	//*                 Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the HelpInspector instance.
	 */
	public function description():String {
		return "HelpInspector()";
	}
	
	//******************************************************											 
	//*                 InspectorProtocol
	//******************************************************
	
	public function inspectorName():String {
		return AIBApplication.stringForKeyPath("Inspectors.Help.Name");
	}

	public function inspectorContents():NSView {
		return null;
	}

}