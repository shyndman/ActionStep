/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSObject;

/**
 * Abstract base class for controller classes.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.controllers.NSController extends NSObject {
	
	//******************************************************															 
	//*                Member variables
	//******************************************************
	
	private var m_editors:NSArray;
	
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSController</code> class.
	 */
	public function NSController() {
		m_editors = new NSArray();
	}
	
	//******************************************************															 
	//*                Managing editing
	//******************************************************
	
	/**
	 * Invoked to inform the receiver that <code>editor</code> has uncommitted 
	 * changes that can affect the receiver.
	 */
	public function objectDidBeginEditing(editor:Object):Void {
		m_editors.addObject(editor);
	}
	
	/**
	 * Invoked to inform the receiver that <code>editor</code> has committed or 
	 * discarded its changes.
	 */
	public function objectDidEndEditing(editor:Object):Void {
		m_editors.removeObject(editor);
	}
	
	/**
	 * Causes the receiver to attempt to commit any pending edits, returning 
	 * <code>true</code> if successful or no edits where pending.
	 */
	public function commitEditing():Boolean {
		return null;
	}
	
	/**
	 * Discards any edits by the current editors.
	 */
	public function discardEditing():Void {
		
	}
	
	/**
	 * Returns <code>true</code> if any registered editors are currently 
	 * editing.
	 */
	public function isEditing():Boolean {
		var arr:Array = m_editors.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			if (arr[i].isEditing()) {
				return true;
			}
		}
		
		return false;
	}
}