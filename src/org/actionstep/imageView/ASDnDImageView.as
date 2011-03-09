/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSDragOperation;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSDraggingSource;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSImageCell;
import org.actionstep.NSImageView;
import org.actionstep.NSPasteboard;
import org.actionstep.NSPoint;
import org.actionstep.NSSize;
import org.actionstep.ASCellImageRep;

/**
 * An image view that supports the dragging of its image.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.imageView.ASDnDImageView extends NSImageView
		implements NSDraggingSource {
	
	//******************************************************
	//*                   Class members
	//******************************************************
	
	private static var g_cellClass:Function = NSImageCell;
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_dragAndDropEnabled:Boolean;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASDnDImageView</code> class.
	 */
	public function ASDnDImageView() {
		m_dragAndDropEnabled = true;
	}
	
	//******************************************************
	//*              Enabling drag and drop
	//******************************************************
	
	/**
	 * Returns <code>true</code> if this image view supports drag operations on
	 * its image.
	 */
	public function isDragEnabled():Boolean {
		return m_dragAndDropEnabled;
	}
	
	/**
	 * Sets whether this image view supports drag operations.
	 */
	public function setDragEnabled(flag:Boolean):Void {
		m_dragAndDropEnabled = flag;
	}
	
	//******************************************************															 
	//*             Beginning drag operations
	//******************************************************
	
	private function mouseDown(event:NSEvent):Void {
		if (m_dragAndDropEnabled) {
			dragImage(event);
		}
	}
	
	/**
	 * Sets up mouse tracking for image dragging.
	 */
	private function dragImage(event:NSEvent):Void {
		var point:NSPoint = convertPointFromView(event.mouseLocation, null);
		m_trackingData = { 
			offsetX: point.x,
			offsetY: point.y,
			mouseDown: true, 
			dragBegan: false,
			eventMask: NSEvent.NSLeftMouseDownMask | NSEvent.NSLeftMouseUpMask 
			| NSEvent.NSLeftMouseDraggedMask | NSEvent.NSMouseMovedMask 
			| NSEvent.NSOtherMouseDraggedMask | NSEvent.NSRightMouseDraggedMask,
			complete: false
		};
		
		
		dragImageCallback(event);
	}

	/**
	 * This method performs image dragging.
	 */
	private function dragImageCallback(event:NSEvent):Void {
		if (event.type == NSEvent.NSLeftMouseUp) {
			return;
		}
		
		var pt:NSPoint = convertPointFromView(event.mouseLocation, null);
		var deltaX:Number = Math.sqrt(
			Math.pow(pt.x - m_trackingData.offsetX, 2)
			+ Math.pow(pt.y - m_trackingData.offsetY, 2));
		
		if (!m_trackingData.dragBegan && deltaX > 20) {			
			//
			// Calculate image position. 
			//
			var screenPt:NSPoint = convertPointToView(new NSPoint(
				m_trackingData.offsetX, m_trackingData.offsetY));
			var imgOrigin:NSPoint = convertPointToView(frame().origin);
			var offset:NSSize = new NSSize(imgOrigin.x - screenPt.x,
				imgOrigin.y - screenPt.y);
			
			//
			// Create pasteboard.
			//
			var pb:NSPasteboard = NSPasteboard.pasteboardWithName(
				"NSImageView");
			var types:NSArray = NSArray.arrayWithObject(
				NSPasteboard.NSImagePboardType);
			pb.declareTypesOwner(types,	this);
			pb.addTypesOwner(types, this);
			pb.setDataForType(image(), NSPasteboard.NSImagePboardType);
			
			//
			// Create image
			//
			var sz:NSSize = frame().size;
			var img:NSImage = (new NSImage()).initWithSize(sz);
			img.setScalesWhenResized(true);
			img.addRepresentation(image().bestRepresentationForDevice());
			
			//
			// Start dragging
			//
			dragImageAtOffsetEventPasteboardSourceSlideBack(img,
				NSPoint.ZeroPoint, offset, event, pb, this, false);
				
			//
			// Set the flag that dragging has begun
			//
			m_trackingData.dragBegan = true;
		}
		
		if (!m_trackingData.dragBegan) {
			NSApplication.sharedApplication().
				callObjectSelectorWithNextEventMatchingMaskDequeue(
					this, "dragImageCallback", m_trackingData.eventMask, false);
		}
	}
	
	public function draggingSourceOperationMask():Number {
		return NSDragOperation.NSDragOperationMove.valueOf();
	}

	public function ignoreModifierKeysWhileDragging():Boolean {
		return true;
	}

	public function draggedImageBeganAt(anImage:NSImage, aPoint:NSPoint):Void {
	}

	public function draggedImageEndedAtOperation(anImage:NSImage, 
			aPoint:NSPoint, operation:NSDragOperation):Void {
	}

	public function draggedImageMovedTo(anImage:NSImage, aPoint:NSPoint):Void {
	}
	
	//******************************************************															 
	//*                 Cell class stuff
	//******************************************************
	
	/**
	 * Returns the class of the cell used by this control.
	 */
	public static function cellClass():Function {
		return g_cellClass;
	}
	
	/**
	 * Sets the class of the cell used by this control.
	 */
	public static function setCellClass(cellClass:Function) {
		if (cellClass == null) {
			g_cellClass = NSImageCell;
		} else {
			g_cellClass = cellClass;
		}
	}
}