/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSDragOperation;
import org.actionstep.NSImage;
import org.actionstep.NSPoint;

/**
 * <p>This interface describes an object being used as the source of a dragging
 * operation.</p>
 * 
 * <p>The only method that absolutely must be implemented completely is
 * {@link #draggingSourceOperationMask}.</p>
 * 
 * @see org.actionstep.NSView#dragImageAtOffsetEventPasteboardSourceSlideBack
 * @author Scott Hyndman
 */
interface org.actionstep.NSDraggingSource 
{
	//******************************************************															 
	//              Specifying dragging options
	//******************************************************
	
	/**
	 * <p>This method should return a mask created by bitwise or-ing constants
	 * as defined in {@link org.actionstep.constants.NSDraggingOperation}.</p>
	 * 
	 * <p>This mask indicates what dragging operations the source object will 
	 * allow to occur on the dragged image's data.</p>
	 * 
	 * <p>This interface differs from the Cocoa docs as I have left out an
	 * <code>isLocal</code> argument, which specifies whether the drag 
	 * destination exists within the same application as the source. In 
	 * ActionStep we're only ever dealing with a single application, so the
	 * argument has been omitted.</p>
	 * 
	 * <p><strong>Note to implementors:</strong><br/>
	 * This method MUST be implemented completely.</p>
	 */
	function draggingSourceOperationMask():Number;

	/**
	 * Sets whether a pressed modifier key has an effect on the drag operation
	 * performed. If not implemented, this method should return 
	 * <code>false</code>.
	 */
	function ignoreModifierKeysWhileDragging():Boolean;
	
	//******************************************************															 
	//*           Responding to dragging sessions
	//******************************************************
	
	/**
	 * <p>Invoked when <code>anImage</code> is displayed but before it starts
	 * following the mouse. <code>aPoint</code> is the origin of the image
	 * (in root coordinates).</p>
	 * 
	 * <p>This could be implemented to provide some visual cue that dragging
	 * has begun.</p>
	 */
	function draggedImageBeganAt(anImage:NSImage, aPoint:NSPoint):Void;
	
	/**
	 * Invoked after <code>anImage</code> has been released and the dragging
	 * destination has had an opportunity to operate on its data.
	 * <code>aPoint</code> is the origin of the image (in root coordinates).
	 * <code>operation</code> indicates the operation to be performed by the
	 * destination. 
	 */
	function draggedImageEndedAtOperation(anImage:NSImage, aPoint:NSPoint,
		operation:NSDragOperation):Void;
		
	/**
	 * Invoked when <code>anImage</code> is moved to the new screen coordinate
	 * <code>aPoint</code>.
	 */
	function draggedImageMovedTo(anImage:NSImage, aPoint:NSPoint):Void;
}