/* See LICENSE for copyright and terms of use */

import org.actionstep.NSView;
import org.aib.AIBApplication;
import org.aib.inspector.InspectorBase;

/**
 * The custom class inspector.
 * 
 * @author Scott Hyndman
 */
class org.aib.inspector.CustomClassInspector extends InspectorBase {

	//******************************************************															 
	//*                 Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the CustomClassInspector instance.
	 */
	public function description():String {
		return "CustomClassInspector()";
	}
	
	//******************************************************											 
	//*                 InspectorProtocol
	//******************************************************
	
	public function inspectorName():String {
		return AIBApplication.stringForKeyPath("Inspectors.CustomClass.Name");
	}

	public function inspectorContents():NSView {
		return null;
	}

}