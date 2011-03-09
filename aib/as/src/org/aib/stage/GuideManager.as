/* See LICENSE for copyright and terms of use */

import org.aib.AIBObject;
import org.actionstep.NSEvent;
import org.actionstep.NSView;
import org.aib.controls.EditableViewProtocol;
import org.aib.SelectionManager;
import org.actionstep.NSArray;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSNotification;

/**
 * Manages guides.
 * 
 * @author Scott Hyndman
 */
class org.aib.stage.GuideManager extends AIBObject {
	
	private static var g_instance:GuideManager;
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_currentDistanceView:NSView;
	private var m_showingDistanceOverlay:Boolean;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>GuideManager</code> class.
	 */
	private function GuideManager() {
		m_showingDistanceOverlay = false;
	}
	
	/**
	 * Initializes the guide manager.
	 */
	public function init():GuideManager {
		NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
			this, "selectionDidChange", 
			SelectionManager.SelectionDidChangeNotification,
			null);
		return this;
	}
	
	//******************************************************
	//*                  Event handlers
	//******************************************************
	
	public function mouseEntered(event:NSEvent):Void {
		showDistanceOverlayIfNeeded(event);
	}
	
	public function mouseExited(event:NSEvent):Void {
		showDistanceOverlayIfNeeded(event);
	}
	
	public function mouseMoved(event:NSEvent):Void {
		showDistanceOverlayIfNeeded(event);
	}
	
	private function selectionDidChange(ntf:NSNotification):Void {
		
	}
	
	//******************************************************
	//*                 Distance overlays
	//******************************************************
	
	private function showDistanceOverlayIfNeeded(event:NSEvent):Void {
		var sel:NSArray;
		if (event.modifierFlags & NSEvent.NSAlternateKeyMask == 0) {
			if (m_showingDistanceOverlay) {
				hideDistanceOverlay(event);
			}
			return;
		}
		else if (m_showingDistanceOverlay 
				&& m_currentDistanceView == event.view) {
			return;	
		}
		else if ((sel = SelectionManager.instance().currentSelection()).count() == 0) {
			if (m_showingDistanceOverlay) {
				hideDistanceOverlay(event);
			}
			return;
		}
		else if (sel.objectAtIndex(0) == m_currentDistanceView) {
			if (m_showingDistanceOverlay) {
				hideDistanceOverlay(event);
			}
			return;
		}
		
		m_showingDistanceOverlay = true;
		m_currentDistanceView = event.view;
		trace("showing");
	}
	
	/**
	 * 
	 */
	private function hideDistanceOverlay(event:NSEvent):Void {
		trace("hiding");
		m_showingDistanceOverlay = false;
		m_currentDistanceView = null;
	}
	
	//******************************************************
	//*                Getting the instance
	//******************************************************
	
	/**
	 * Returns the guide manager instance.
	 */
	public static function instance():GuideManager {
		if (g_instance == undefined) {
			g_instance = (new GuideManager()).init();
		}
		
		return g_instance;
	}
}