/* See LICENSE for copyright and terms of use */

import org.actionstep.ASFieldEditor;
import org.actionstep.NSButton;
import org.actionstep.NSButtonCell;
import org.actionstep.NSEvent;
import org.aib.controls.EditableViewProtocol;
import org.aib.inspector.InspectorProtocol;
import org.aib.stage.ResizeView;

/**
 * The editable button class.
 * 
 * It is decorated at runtime by the <code>EditableViewDecorator</code>.
 * 
 * @author Scott Hyndman
 */
class org.aib.controls.EditableButton extends NSButton
		implements EditableViewProtocol {
	
	//******************************************************															 
	//*                  Class members
	//******************************************************
	
	private static var g_cellClass:Function = NSButtonCell;
	
	//******************************************************															 
	//*                Member variables
	//******************************************************
	
	private var m_textEditingEnabled:Boolean;
	
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	/**
	 * Constructs a new instance of the <code>EditableButton</code> class.
	 */
	public function EditableButton() {
		m_textEditingEnabled = true;
	}
	
	//******************************************************															 
	//*           From EditableViewProtocol
	//******************************************************
	
	/**
	 * Returns <code>org.actionstep.NSButton</code>
	 */
	public function className():String {
		return "org.actionstep.NSButton";
	}
	
	/**
	 * Always returns true.
	 */
	public function supportsInspector(inspector:InspectorProtocol):Boolean {
		return true;
	}
	
	/**
	 * Always returns <code>true</code>.
	 */
	public function shouldSelect(event:NSEvent):Boolean {
		return true;
	}
	
	/**
	 * Returns <code>false</code> if the click count is more than one.
	 */
	public function shouldReceiveMouseDown(event:NSEvent):Boolean {	
		if (titleEditingEnabled() && event.clickCount > 1) {
			var cell:NSButtonCell = NSButtonCell(cell());
			var tf:TextField = cell.internalTextField();
			
			cell.setEditable(true);
			ASFieldEditor.startEditing(cell, this, tf);
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
	
	public function resizeUmask():Number {
		return ResizeView.MinY | ResizeView.MaxY;
	}
	
	/**
	 * Provided by {@link EditableViewDecorator}
	 */
	public function isUserResizing():Boolean {
		return null;
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
	//*                  Title editing
	//******************************************************
	
	public function textDidBeginEditing(editor:ASFieldEditor):Void {
		trace("EditableButton.textDidBeginEditing(editor)");
	}
	
	public function textShouldEndEditing(editor:ASFieldEditor):Boolean {
		return true;
	}
	
	public function textDidEndEditing(editor:ASFieldEditor):Void {
		trace("EditableButton.textDidEndEditing(editor)");
		
		var cell:NSButtonCell = NSButtonCell(cell());
		cell.setEditable(false);
	}
	
	public function textDidChange(editor:ASFieldEditor):Void {
		trace("EditableButton.textDidChange(editor)");
	}
	
	/**
	 * Returns <code>true</code> if the title can be edited in place.
	 */
	public function titleEditingEnabled():Boolean {
		return m_textEditingEnabled;
	}
	
	/**
	 * Sets whether in place title editing can take place.
	 */
	public function setTitleEditingEnabled(flag:Boolean) {
		m_textEditingEnabled = flag;
	}
	
	//******************************************************															 
	//*              Required by NSControl
	//******************************************************
	
	public static function cellClass():Function {
		return g_cellClass;
	}
	
	public static function setCellClass(cellClass:Function) {
		if (cellClass == null) {
			g_cellClass = NSButtonCell;
		} else {
			g_cellClass = cellClass;
		}
	}
}