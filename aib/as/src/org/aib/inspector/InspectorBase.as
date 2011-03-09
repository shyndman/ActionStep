import org.actionstep.NSException;
import org.actionstep.NSView;
import org.aib.AIBObject;
import org.aib.EditableObjectProtocol;
import org.aib.inspector.InspectorProtocol;
import org.aib.InspectorController;

/**
 * Base class for inspectors.
 * 
 * @author Scott Hyndman
 */
class org.aib.inspector.InspectorBase extends AIBObject 
		implements InspectorProtocol {
	
	//******************************************************															 
	//*                   Member variables
	//******************************************************
	
	private var m_inspector:InspectorController;
	private var m_src:String;
	
	//******************************************************															 
	//*                     Construction
	//******************************************************
	
	public function initWithInspectorController(inspector:InspectorController)
			:InspectorProtocol {
		m_inspector = inspector;
		return this;
	}

	//******************************************************															 
	//*                 InspectorProtocol
	//******************************************************
	
	public function setSourceDirectory(path:String):Void {
		m_src = path;
	}
	
	public function inspectorName():String {
		throwAbstractMethodException("inspectorName");
		return null;
	}

	public function inspectorContents():NSView {
		throwAbstractMethodException("inspectorContents");
		return null;
	}
	
	/**
	 * Instructs the inspector to display the data related to 
	 * <code>selection</code>.
	 */
	function updateInspectorWithSelection(selection:EditableObjectProtocol):Boolean {
		return false;
	}
	
	/**
	 * Throws an NSException.
	 * 
	 * Should be called by abstract methods. <code>methodName</code> is the
	 * name of the abstract method.
	 */
	private function throwAbstractMethodException(methodName:String):Void {
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			NSException.ASAbstractMethod,
			methodName + "() is an abstract method.",
			null);
		trace(e);
		throw e;	
	}
}