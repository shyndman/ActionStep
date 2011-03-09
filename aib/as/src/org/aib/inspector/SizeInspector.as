/* See LICENSE for copyright and terms of use */

import org.actionstep.NSButton;
import org.actionstep.NSComboBox;
import org.actionstep.NSNotification;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTabView;
import org.actionstep.NSTabViewItem;
import org.actionstep.NSView;
import org.actionstep.window.ASRootWindowView;
import org.aib.AIBApplication;
import org.aib.constants.SizeType;
import org.aib.EditableObjectProtocol;
import org.aib.inspector.InspectorBase;
import org.aib.inspector.InspectorProtocol;
import org.aib.inspector.size.SizeInspectorContents;
import org.aib.inspector.size.ViewSizeContentView;
import org.aib.inspector.size.WindowSizeContentView;
import org.aib.InspectorController;

/**
 * The size inspector.
 * 
 * @author Scott Hyndman
 */
class org.aib.inspector.SizeInspector extends InspectorBase {

	public static var STRING_GROUP:String = "inspectors.size";
	public static var MARGINS:Number = 1;
	public static var TEXT_WIDTH:Number = 60;
	public static var COMBO_WIDTH:Number = 115;
	public static var SECTION_SPACING:Number = 15;
	public static var AUTOSIZE_EDGE_LENGTH:Number = 200;
	
	//
	// Contents
	//
	private var m_currentContents:SizeInspectorContents;
	private var m_viewContents:ViewSizeContentView;
	private var m_windowContents:WindowSizeContentView;
	
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Initializes the size inspector.
	 */
	public function initWithInspectorController(inspector:InspectorController)
			:InspectorProtocol {
		super.initWithInspectorController(inspector);
		
		//
		// Build contents
		//
		var contentSize:NSSize = inspector.contentSize();
		m_viewContents = (new ViewSizeContentView()).initWithFrameInspector(
			NSRect.withOriginSize(NSPoint.ZeroPoint, contentSize), this);
		m_windowContents = (new WindowSizeContentView()).initWithFrameInspector(
			NSRect.withOriginSize(NSPoint.ZeroPoint, contentSize), this);
		m_currentContents = m_viewContents;
		
		return this;
	}
	
	//******************************************************															 
	//*                 Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the SizeInspector instance.
	 */
	public function description():String {
		return "SizeInspector()";
	}
	
	//******************************************************
	//*                  Target actions
	//******************************************************
	
	private function lockDidChange(btn:NSButton):Void {
		trace("SizeInspector.lockDidChange(btn)");
	}
	
	private function sizeTypeDidChange(cmb:NSComboBox):Void {
		var width:String;
		var height:String;
		
		if (cmb.objectValueOfSelectedItem() == SizeType.MaxXMaxY) {
			width = AIBApplication.stringForKeyPath(
				STRING_GROUP + ".SizeMaxX");
			height = AIBApplication.stringForKeyPath(
				STRING_GROUP + ".SizeMaxY");
		} else {
			width = AIBApplication.stringForKeyPath(
				STRING_GROUP + ".SizeWidth");
			height = AIBApplication.stringForKeyPath(
				STRING_GROUP + ".SizeHeight");
		}
		
		m_currentContents.setWidthTextHeightText(width, height);
	}
	
	private function originTypeDidChange(cmb:NSComboBox):Void {
		trace("SizeInspector.originTypeDidChange(cmb)");
		
		// TODO change numbers
	}
		
	//******************************************************
	//*                  Tabview delegate
	//******************************************************
	
	private function tabViewDidSelectTabViewItem(tv:NSTabView, item:NSTabViewItem):Void {
		
	}
	
	//******************************************************
	//*                 Autosize delegate
	//******************************************************
	
	private function resizeMaskDidChange(newMask:Number):Void {
		
	}
	
	//******************************************************
	//*                 Textfield delegate
	//******************************************************
	
	private function controlTextDidEndEditing(ntf:NSNotification):Void {
		
	}
	
	//******************************************************
	//*        Making changes to the selected object
	//******************************************************
	
	/**
	 * Called by content views when they want to modify a view.
	 */
	public function modifySelectionWithObjectForKeyPath(object:Object, keyPath:String):Void {
		
	}
	
	//******************************************************											 
	//*                 InspectorProtocol
	//******************************************************
	
	public function inspectorName():String {
		return AIBApplication.stringForKeyPath("Inspectors.Size.Name");
	}

	/**
	 * Returns the current contents of the window.
	 */
	public function inspectorContents():NSView {
		//return m_windowContents;
		return NSView(m_currentContents);
	}

	/**
	 * Instructs the inspector to display the data related to 
	 * <code>selection</code>.
	 */
	function updateInspectorWithSelection(selection:EditableObjectProtocol):Boolean {
		if (!(selection instanceof NSView)) {
			return false;
		}
		
		if (selection instanceof ASRootWindowView) {
			m_currentContents = m_windowContents;
		} else {
			m_currentContents = m_viewContents;
		}
		
		m_currentContents.setSelection(selection);
		
		return true;
	}
}