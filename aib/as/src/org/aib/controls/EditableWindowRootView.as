/* See LICENSE for copyright and terms of use */

import org.actionstep.NSEvent;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSWindow;
import org.actionstep.window.ASRootWindowView;
import org.aib.controls.EditableViewProtocol;
import org.aib.inspector.HelpInspector;
import org.aib.inspector.InspectorProtocol;

/**
 * <p>Overridden to act as an editable control in AIB.</p>
 * 
 * <p>It is decorated at runtime by the <code>EditableViewDecorator</code>.</p>
 * 
 * @author Scott Hyndman
 */
class org.aib.controls.EditableWindowRootView extends ASRootWindowView
		implements EditableViewProtocol { 
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private var m_mcGuides:MovieClip;
	private var m_mcOverlay:MovieClip;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>EditableWindowRootView</code> class.
	 */
	public function EditableWindowRootView() {
	}
	
	/**
	 * Initializes the receiver with a frame of <code>aRect</code>.
	 */
	public function initWithFrame(aRect:NSRect):EditableWindowRootView {
		super.initWithFrame(aRect);
		setHasShadow(true);
		return this;
	}
	
	//******************************************************
	//*                   MovieClips
	//******************************************************
	
	/**
 	 * Overridden to create the guide and overlay movieclips.
	 */
	public function createMovieClips():Boolean {
		if (!super.createMovieClips()) {
			return false;
		}
		
		if (m_mcBounds != null) {
			m_mcGuides = m_mcBounds.createEmptyMovieClip("GUIDES", 1000050);
			m_mcOverlay = m_mcBounds.createEmptyMovieClip("OVERLAY", 1000100);
		} else {
			return false;
		}
				
		return true;
	}
	
	/**
	 * Returns the guides movie clip.
	 */
	public function mcGuides():MovieClip {
		return m_mcGuides;
	}
	
	/**
	 * Returns the overlay movie clip.
	 */
	public function mcOverlay():MovieClip {
		return m_mcOverlay;
	}
  
	//******************************************************
	//*              Describing the object
	//******************************************************
		
	/**
	 * Returns a string representation of the EditableWindowRootView instance.
	 */
	public function description():String {
		return "EditableWindowRootView()";
	}
		
	//******************************************************															 
	//*           From EditableViewProtocol
	//******************************************************
	
	/**
	 * Returns <code>NSWindow</code>
	 */
	public function className():String {
		return "org.actionstep.NSWindow";
	}
	
	/**
	 * Returns true unless inspector is a help inspector.
	 */
	function supportsInspector(inspector:InspectorProtocol):Boolean {
		return !(inspector instanceof HelpInspector);
	}
	
	/**
	 * Always returns true.
	 */
	function shouldSelect(event:NSEvent):Boolean {
		return event.view != this;
	}
	
	/**
	 * Allows the window to be dragged and resized, and passes along all other
	 * mouse events to the editable control <code>#mouseDown</code>.
	 */
	function shouldReceiveMouseDown(event:NSEvent):Boolean {
		if (m_window.styleMask() == NSWindow.NSBorderlessWindowMask) {
			return true;
		}
		
		var location:NSPoint = event.mouseLocation;
		location = convertPointFromView(location);
		
		if(m_titleRect.pointInRect(location)
				&& m_window.styleMask() & NSWindow.NSTitledWindowMask
				&& (m_window.styleMask() & NSWindow.NSNotDraggableWindowMask == 0)) {
			dragWindow(event);
			return false;
		}
		else if(m_resizeRect.pointInRect(location) 
				&& m_window.styleMask() & NSWindow.NSResizableWindowMask) {
			resizeWindow(event);
			return false;
		}
		
		return true;
	}

	function willReceiveMouseDown(event:NSEvent):Void {
		//trace("EditableWindowRootView.willReceiveMouseDown(event)");
	}

	function hasReceivedMouseDown(event:NSEvent):Void {
		//trace("EditableWindowRootView.hasReceivedMouseDown(event)");
	}
	
	/**
	 * Returns <code>true</code>.
	 */
	public function showsResizeHandles():Boolean {
		return false;
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
}