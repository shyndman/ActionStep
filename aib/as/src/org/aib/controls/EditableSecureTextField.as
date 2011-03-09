/* See LICENSE for copyright and terms of use */

import org.actionstep.NSEvent;
import org.actionstep.NSTextField;
import org.aib.controls.EditableViewProtocol;
import org.aib.inspector.InspectorProtocol;

/**
 * @author Scott Hyndman
 */
class org.aib.controls.EditableSecureTextField extends NSTextField 
		implements EditableViewProtocol {
	
	//******************************************************															 
	//*                 Class members
	//******************************************************
	
	private static var g_cellClass:Function 
		= org.actionstep.NSSecureTextFieldCell;
	
	//******************************************************															 
	//*                Member variables
	//******************************************************
	
	private var m_textEditingEnabled:Boolean;
	
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	/**
	 * Constructs a new instance of the <code>EditableTextField</code> class. 
	 */
	public function EditableTextField() {
		m_textEditingEnabled = true;
	}
	
	//******************************************************															 
	//*              AIBEditingViewProtocol
	//******************************************************
	
	public function className():String {
		return "org.actionstep.NSSecureTextField";
	}

	/**
	 * Always returns true.
	 */
	public function supportsInspector(inspector:InspectorProtocol):Boolean {
		return true;
	}
	
	public function shouldSelect(event:NSEvent):Boolean {
		return true;
	}

	public function shouldReceiveMouseDown(event:NSEvent):Boolean {
		if (inPlaceEditingEnabled() && event.clickCount > 1) {
			super.becomeFirstResponder();
			return false;
		}
		
		return true;
	}

	public function willReceiveMouseDown(event:NSEvent):Void {
	}

	public function hasReceivedMouseDown(event:NSEvent):Void {
	}

	/**
	 * Returns <code>true</code>.
	 */
	public function showsResizeHandles():Boolean {
		return true;
	}
	
	/**
	 * Provided by {@link EditableViewDecorator}
	 */
	public function isUserResizing():Boolean {
		return null;
	}
	
	/**
	 * Returns 0.
	 */
	public function resizeUmask():Number {
		return 0;
	}
	
	/**
	 * Provided by {@link EditableViewDecorator}
	 */
	public function setUserResizing(flag:Boolean):Void {
	}
	
	/**
	 * Provided by {@link EditableViewDecorator}
	 */
	public function isFrameLocked():Boolean {
		return null;
	}
	
	/**
	 * Provided by {@link EditableViewDecorator}
	 */
	public function setFrameLocked(flag:Boolean):Void {
	}
	
	//******************************************************															 
	//*                 In place editing
	//******************************************************
	
	/**
	 * Returns <code>true</code> if the string value can be edited in place.
	 */
	public function inPlaceEditingEnabled():Boolean {
		return m_textEditingEnabled;
	}
	
	/**
	 * Sets whether in place string value editing can take place.
	 */
	public function setInPlaceEditingEnabled(flag:Boolean) {
		m_textEditingEnabled = flag;
	}
	
	//******************************************************															 
	//*               Required by NSControl
	//******************************************************
	
	public static function cellClass():Function {
		return g_cellClass;
	}
	
	public static function setCellClass(cellClass:Function) {
		if (cellClass == null) {
			g_cellClass = org.actionstep.NSSecureTextFieldCell;
		} else {
			g_cellClass = cellClass;
		}
	}
}