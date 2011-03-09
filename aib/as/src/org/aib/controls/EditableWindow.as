/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.aib.controls.EditableViewProtocol;
import org.aib.controls.EditableWindowContentView;
import org.aib.controls.EditableWindowRootView;
import org.aib.SelectionManager;
import org.aib.stage.ResizeView;

/**
 * This class is subclasses to always use the 
 * <code>EditableWindowRootView</code> as its root view.
 * 
 * @author Scott Hyndman
 */
class org.aib.controls.EditableWindow extends NSWindow {
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private var m_selection:NSArray;
		
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>EditableWindow</code> class.
	 */
	public function EditableWindow() {
		m_selection = NSArray.array();
	}
	
	/**
	 * Always uses <code>EditableWindowRootView</code> as the 
	 * <code>viewClass</code>.
	 */
	public function initWithContentRectStyleMaskSwfViewClass(contentRect:NSRect, 
			styleMask:Number, swf:String, viewClass:Function):NSWindow {
		//
		// Register with the selection manager
		//
		SelectionManager.instance().registerWindow(this);
		
		//
		// Set some properties
		//
		setReleasedWhenClosed(false);
		
		//
		// Initialize
		//
		super.initWithContentRectStyleMaskSwfViewClass(
			contentRect, 
			NSWindow.NSTitledWindowMask
			| NSWindow.NSResizableWindowMask
			| NSWindow.NSClosableWindowMask, 
			swf, 
			EditableWindowRootView);
			
		setContentView((new EditableWindowContentView()).initWithFrame(
			NSRect.withOriginSize(
				convertScreenToBase(m_contentRect.origin), 
				m_contentRect.size)));
			
		return this;	
	}
	
	//******************************************************
	//*                     Events
	//******************************************************
	
	public function becomeMainWindow():Void {
		if (isMainWindow()) {
			return;
		}
		
		focusViews(m_selection);
		super.becomeMainWindow();
	}
	
	public function resignMainWindow():Void {
		if (!isMainWindow()) {
			return;
		}
		
		unfocusViews(m_selection);
		super.resignMainWindow();
	}
	
	//******************************************************
	//*                    Selection
	//******************************************************
	
	/**
	 * Returns the selected views contained in this window.
	 */
	public function selectedViews():NSArray {
		return m_selection;
	}
	
	/**
	 * Clears the selection array.
	 */
	public function clearSelection():Void {
		unfocusViews(m_selection);
		m_selection.removeAllObjects();
	}
	
	/**
	 * Adds the view <code>aView</code> to the selection.
	 */
	public function addViewToSelection(aView:EditableViewProtocol):Void {
		m_selection.addObject(aView);
		
		if (isMainWindow() && aView.showsResizeHandles()) {
			ResizeView.focusViewWithUmask(NSView(aView), aView.resizeUmask());
			aView.setUserResizing(true);
		}
	}
	
	/**
	 * Removes the view <code>aView</code> from the selection.
	 */
	public function removeViewFromSelection(aView:EditableViewProtocol):Void {
		var idx:Number = m_selection.indexOfObjectIdenticalTo(aView);
		if (idx == NSNotFound) {
			return;
		}
		
		removeViewAtIndexFromSelection(idx);
	}
	
	/**
	 * Removes the view at <code>index</code> from the selection.
	 */
	public function removeViewAtIndexFromSelection(index:Number):Void {
		//
		// Remove resize handles if we have them
		//
		var view:NSView = NSView(m_selection.objectAtIndex(index));
		var ev:EditableViewProtocol = EditableViewProtocol(view);
		if (ev.isUserResizing()) {
			ResizeView.unfocusView(view);
			ev.setUserResizing(false);
		}
		
		m_selection.removeObjectAtIndex(index);
	}
	
	/**
	 * Toggles <code>aView</code>'s selection state.
	 */
	public function toggleSelectionWithView(aView:EditableViewProtocol):Void {
		var idx:Number = m_selection.indexOfObjectIdenticalTo(aView);
		if (idx == NSNotFound) {
			addViewToSelection(aView);
		} else {
			removeViewAtIndexFromSelection(idx);
		}
	}
	
	//******************************************************
	//*              Resize view focusing
	//******************************************************
	
	private function focusViews(views:NSArray):Void {
		var arr:Array = views.internalList();
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var aView:NSView = NSView(arr[i]);
			var ev:EditableViewProtocol = EditableViewProtocol(arr[i]);
			if (ev.showsResizeHandles()) {
				ResizeView.focusViewWithUmask(aView, ev.resizeUmask());
			}
			if (!ev.isUserResizing()) {
				ev.setUserResizing(true);
			}
		}
	}
	
	private function unfocusViews(views:NSArray):Void {
		var arr:Array = views.internalList();
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var ev:EditableViewProtocol = EditableViewProtocol(arr[i]);
			ResizeView.unfocusView(NSView(arr[i]));
			if (ev.isUserResizing()) {
				ev.setUserResizing(false);
			}
		}
	}	
}