import org.actionstep.NSWindow;

/**
 * @author Scott Hyndman
 */
class org.aib.resource.ResourceWindow extends NSWindow {
	
	private var m_selection:Object;
	
	//******************************************************
	//*                     Events
	//******************************************************
	
	public function becomeMainWindow():Void {
		if (isMainWindow()) {
			return;
		}
		
		focusObject(m_selection);
		super.becomeMainWindow();
	}
	
	public function resignMainWindow():Void {
		if (!isMainWindow()) {
			return;
		}
		
		unfocusObject(m_selection);
		super.resignMainWindow();
	}
	
	//******************************************************
	//*                   Focusing
	//******************************************************
	
	private function focusObject(obj:Object):Void {
		// TODO implement
	}
	
	private function unfocusObject(obj:Object):Void {
		// TODO implement
	}
}