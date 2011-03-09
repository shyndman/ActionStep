/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSNotificationCenter;
import org.aib.AIBObject;
import org.aib.EditableObjectProtocol;
import org.aib.controls.EditableViewProtocol;
import org.actionstep.NSEvent;
import org.actionstep.NSWindow;
import org.actionstep.NSNotification;
import org.aib.controls.EditableWindow;

/**
 * @author Scott Hyndman
 */
class org.aib.SelectionManager extends AIBObject {
	
	//******************************************************															 
	//*                  Class members
	//******************************************************
	
	private static var g_instance:SelectionManager;
	
	//******************************************************															 
	//*                 Member variables
	//******************************************************
	
	private var m_selection:NSArray;
	private var m_nc:NSNotificationCenter;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Singleton.
	 * 
	 * Access instance using <code>#instance()</code>. 
	 */
	private function SelectionManager() {
		m_selection = NSArray.array();
		m_nc = NSNotificationCenter.defaultCenter();
	}
	
	/**
	 * Initializes the selection manager.
	 */
	public function init():SelectionManager {
		super.init();
		return this;
	}
	
	//******************************************************
	//*                Registering windows
	//******************************************************
	
	public function registerWindow(window:NSWindow):Void {
		m_nc.addObserverSelectorNameObject(this, "windowDidBecomeMain",
			NSWindow.NSWindowDidBecomeMainNotification,
			window);
		m_nc.addObserverSelectorNameObject(this, "windowDidResignMain",
			NSWindow.NSWindowDidResignMainNotification,
			window);
	}
	
	public function deregisterWindow(window:NSWindow):Void {
		m_nc.removeObserverNameObject(this, null, window);
	}
	
	//******************************************************
	//*              Window notifications
	//******************************************************
	
	private function windowDidBecomeMain(ntf:NSNotification):Void {
		//
		// Build and dispatch the notification
		//
		var old:NSArray = m_selection;
		m_selection = (new NSArray()).initWithArrayCopyItems(
			EditableWindow(ntf.object).selectedViews(),
			false);
		
		var userInfo:NSDictionary = NSDictionary.dictionaryWithObjectsAndKeys(
			old, "AIBOldSelection",
			m_selection, "AIBNewSelection");
			
		NSNotificationCenter.defaultCenter().postNotificationWithNameObjectUserInfo(
			SelectionDidChangeNotification,
			this,
			userInfo);
	}
	
	/**
	 * Removes all resize views from window selection.
	 */
	private function windowDidResignMain(ntf:NSNotification):Void {
		
	}
	
	//******************************************************															 
	//*            Setting the current selection
	//******************************************************
	
	/**
	 * Returns the current selection.
	 */
	public function currentSelection():NSArray {
		return m_selection;
	}
	
	/**
	 * Selects <code>object</code>.
	 * 
	 * This results in an <code>SelectionDidChangeNotification</code> being
	 * posted to the default notification center.
	 */
	public function selectObject(object:EditableObjectProtocol):Void {
		if (object == m_selection) {
			return;
		}
		
		var old:NSArray = m_selection;
		m_selection = NSArray.arrayWithObject(object);
		
		var userInfo:NSDictionary = NSDictionary.dictionaryWithObjectsAndKeys(
			old, "AIBOldSelection",
			m_selection, "AIBNewSelection");
			
		NSNotificationCenter.defaultCenter().postNotificationWithNameObjectUserInfo(
			SelectionDidChangeNotification,
			this,
			userInfo);
	}
	
	/**
	 * Selects <code>aView</code>
	 */
	public function selectViewWithEvent(aView:EditableViewProtocol, 
			event:NSEvent):Void {
		var wnd:EditableWindow = EditableWindow(aView.window());
		var multi:Boolean = (event.modifierFlags & NSEvent.NSShiftKeyMask) != 0;
			
		//
		// Modify the selection
		//
		if (!multi) {
			if (m_selection.count() == 1 
					&& aView == m_selection.objectAtIndex(0)) {
				return;		
			}
			wnd.clearSelection();
			wnd.addViewToSelection(aView);
		} else {
			wnd.toggleSelectionWithView(aView);
		}
		
		//
		// Change selection
		//
		var old:NSArray = m_selection;
		m_selection = (new NSArray()).initWithArrayCopyItems(wnd.selectedViews(),
			false);
		
		//
		// Build and dispatch the notification
		//
		var userInfo:NSDictionary = NSDictionary.dictionaryWithObjectsAndKeys(
			old, "AIBOldSelection",
			m_selection, "AIBNewSelection");
			
		NSNotificationCenter.defaultCenter().postNotificationWithNameObjectUserInfo(
			SelectionDidChangeNotification,
			this,
			userInfo);
	}
	
	//******************************************************															 
	//*                Getting the instance
	//******************************************************
	
	/**
	 * Returns the selection manager instance.
	 */
	public static function instance():SelectionManager {
		if (null == g_instance) {
			g_instance = new SelectionManager();
			g_instance.init();
		}
		
		return g_instance;
	}
	
	//******************************************************															 
	//*                  Notifications
	//******************************************************
	
	/**
	 * Posted to the default notification center when the current selection
	 * changes.
	 * 
	 * The user info dictionary contains:
	 *   -"AIBOldSelection": The old selection (NSArray)
	 *   -"AIBNewSelection": The new selection (NSArray)
	 */
	public static var SelectionDidChangeNotification:Number 
		= ASUtils.intern("SelectionDidChangeNotification");
}