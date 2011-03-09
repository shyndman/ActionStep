import org.actionstep.NSEvent;
import org.actionstep.NSMatrix;

/**
 * @author Scott Hyndman
 */
class org.actionstep.browser.ASBrowserMatrix extends NSMatrix {
	
	//******************************************************
	//*                  First mouse
	//******************************************************
	
	public function acceptsFirstMouse():Boolean {
		return true;
	}
	
	//******************************************************
	//*                Forwarding events
	//******************************************************
	
	/** Skip the responder chain */
	public function scrollWheel(event:NSEvent):Void {
		superview().scrollWheel(event);
	}
	
	//******************************************************
	//*                    Required
	//******************************************************
	
	public static function cellClass():Function {
		if (g_cellClass == undefined) 
		{
			g_cellClass = org.actionstep.NSCell;
		}
		
		return g_cellClass;
	}
}