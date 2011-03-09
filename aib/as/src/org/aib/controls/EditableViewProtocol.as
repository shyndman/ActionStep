/* See LICENSE for copyright and terms of use */

import org.actionstep.NSEvent;
import org.aib.EditableObjectProtocol;
import org.actionstep.NSWindow;

/**
 * <p>Describes the interface that must be exposed by all editable control 
 * classes.</p>
 * 
 * <p>Since editable controls have their event handlers overwritten to handle
 * selection and dragging, these methods are provided to handle events 
 * differently than the default behaviour.</p> 
 * 
 * @author Scott Hyndman
 */
interface org.aib.controls.EditableViewProtocol 
		extends EditableObjectProtocol {
	
	/**
	 * Returns <code>true</code> if the view should become the selected view as 
	 * a result of the event <code>event</code>.
	 */
	function shouldSelect(event:NSEvent):Boolean;
	
	/**
	 * <p>Called before the editable control performs its 
	 * {@link NSResponder#mouseDown} behaviour (which ordinarily involves 
	 * dragging and resizing) and allows the control to prevent these things 
	 * from happening.</p>
	 * 
	 * <p>To prevent the editable control from performing its actions, this method
	 * should return <code>false</code>. Otherwise it should return 
	 * <code>true</code>.</p>
	 */
	function shouldReceiveMouseDown(event:NSEvent):Boolean;
	
	/**
	 * Called before the editable control performs its {@link NSResponder#mouseDown}
	 * behaviour.
	 */
	function willReceiveMouseDown(event:NSEvent):Void;
	
	/**
	 * Called after the {@link NSResponder#mouseDown} event has been processed by
	 * the editable control.
	 */
	function hasReceivedMouseDown(event:NSEvent):Void;
	
	/**
	 * Returns <code>true</code> if the view should display resize handles.
	 */
	function showsResizeHandles():Boolean;
	
	/**
	 * <p>Returns a bitwise ORd combination of {@link NSResizeView#MinX},
	 * {@link NSResizeView#MaxX}, {@link NSResizeView#MinY} and 
	 * {@link NSResizeView#MaxY}. The umask is used to disallow resizing in
	 * certain directions.</p>
	 * 
	 * <p>For example, returning a value of 
	 * <code>NSResizeView.MinY | NSResizeView.MaxY</code> would prevent the
	 * view from being resized vertically.</p>
	 */
	function resizeUmask():Number;
	
	/**
	 * Returns <code>true</code> if this view is resizing.
	 */
	function isUserResizing():Boolean;
	
	/**
	 * Sets whether this view is resizing to <code>flag</code>.
	 */
	function setUserResizing(flag:Boolean):Void;
	
	/**
	 * Returns <code>true</code> if this view's frame is locked.
	 */
	public function isFrameLocked():Boolean;
	/**
	 * Sets whether this view's frame is locked.
	 */
	public function setFrameLocked(flag:Boolean):Void;
	
	/**
	 * Returns this view's window.
	 */
	function window():NSWindow;
}