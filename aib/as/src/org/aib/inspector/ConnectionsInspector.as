/* See LICENSE for copyright and terms of use */

import org.actionstep.NSView;
import org.aib.AIBApplication;
import org.aib.inspector.InspectorBase;

/**
 * The connections inspector.
 * 
 * @author Scott Hyndman
 */
class org.aib.inspector.ConnectionsInspector extends InspectorBase {

	//******************************************************															 
	//*                 Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the ConnectionsInspector instance.
	 */
	public function description():String {
		return "ConnectionsInspector()";
	}
	
	//******************************************************											 
	//*                 InspectorProtocol
	//******************************************************
	
	public function inspectorName():String {
		return AIBApplication.stringForKeyPath("Inspectors.Connections.Name");
	}

	public function inspectorContents():NSView {
		return null;
	}

}