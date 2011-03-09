/* See LICENSE for copyright and terms of use */

import org.actionstep.NSView;
import org.aib.AIBApplication;
import org.aib.inspector.InspectorBase;

/**
 * The bindings inspector.
 * 
 * @author Scott Hyndman
 */
class org.aib.inspector.BindingsInspector extends InspectorBase {

	//******************************************************															 
	//*                 Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the BindingsInspector instance.
	 */
	public function description():String {
		return "BindingsInspector()";
	}
	
	//******************************************************											 
	//*                 InspectorProtocol
	//******************************************************
	
	public function inspectorName():String {
		return AIBApplication.stringForKeyPath("Inspectors.Bindings.Name");
	}

	public function inspectorContents():NSView {
		return null;
	}

}