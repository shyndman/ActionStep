/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSDragOperation;
import org.actionstep.NSDraggingInfo;

/**
 * <p>This interface must be implemented by the destination of a dragging 
 * operation.</p>
 * 
 * <p>TODO Document this class.</p>
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.NSDraggingDestination 
{
	//******************************************************															 
	//*           Before the image is released
	//******************************************************
	
	function draggingEntered(sender:NSDraggingInfo):NSDragOperation;
	
	function draggingUpdated(sender:NSDraggingInfo):NSDragOperation;
	
	function draggingEnded(sender:NSDraggingInfo):Void;
	
	function draggingExited(sender:NSDraggingInfo):Void;
	
	/**
	 * If <code>true</code>, the destination will recieve periodic dragging
	 * updates (updates not based on mouse movement or modifier flag changes).
	 * If <code>false</code>, the destination will only recieve updates when
	 * the mouse moves or the modifier flags change.
	 */
	function wantsPeriodicDraggingUpdates():Boolean;
	
	//******************************************************															 
	//*           After the image is released
	//******************************************************
	
	function prepareForDragOperation(sender:NSDraggingInfo):Boolean;
	
	function performDragOperation(sender:NSDraggingInfo):Boolean;
	
	function concludeDragOperation(sender:NSDraggingInfo):Void;
}