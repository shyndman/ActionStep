import org.actionstep.constants.NSDragOperation;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSDraggingSource;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSImageCell;
import org.actionstep.NSImageView;
import org.actionstep.NSObject;
import org.actionstep.NSPasteboard;
import org.actionstep.NSPoint;
import org.actionstep.NSSize;
import org.actionstep.ASUtils;
import org.aib.constants.SourceObjectType;

/**
 * @author Scott Hyndman
 */
class org.aib.palette.PaletteObjectSource extends NSImageView 
		implements NSDraggingSource {
	
	//******************************************************
	//*                   Class members
	//******************************************************
	
	private static var g_cellClass:Function = NSImageCell;
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_dragAndDropEnabled:Boolean;
	private var m_sourceObjClass:Function;
	private var m_plist:NSDictionary;
	private var m_type:SourceObjectType;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>PaletteObjectSource</code> class.
	 */
	public function PaletteObjectSource() {
		m_dragAndDropEnabled = true;
		setSourceObjectType(SourceObjectType.AIBView);
	}
	
	//******************************************************
	//*              Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the PaletteObjectSource instance.
	 */
	public function description():String {
		return "PaletteObjectSource()";
	}
	
	//******************************************************
	//*             Setting the source object
	//******************************************************
	
	/**
	 * Returns the properties used to instantiate the object.
	 */	
	public function sourceObjectProperties():NSDictionary {
		return m_plist;
	}
	
	/**
	 * Sets the properties used to instantiate the source object to
	 * <code>props</code>.
	 */
	public function setSourceObjectProperties(props:NSDictionary):Void {
		m_plist = props;
	}
	
	/**
	 * Returns the class of the source object.
	 */
	public function sourceObjectClass():Function {
		return m_sourceObjClass;
	}
	
	/**
	 * <p>Sets the class of the source object to <code>clz</code>.</p>
	 * 
	 * <p><code>clz</code> must be a subclass of {@link NSObject}</p>
	 */
	public function setSourceObjectClass(clz:Function):Void {
		m_sourceObjClass = clz;
	}
	
	/**
	 * Returns the source object type.
	 */
	public function sourceObjectType():SourceObjectType {
		return m_type;
	}
	
	/**
	 * Sets the source object type to <code>type</code>.
	 */
	public function setSourceObjectType(type:SourceObjectType):Void {
		m_type = type;
	}
	
	/**
	 * Creates a new source object instance.
	 */
	public function createSourceObject():NSObject {
		var ret:NSObject = NSObject(ASUtils.createInstanceOf(sourceObjectClass()));
		ret.init();
		
		var keys:Array = m_plist.allKeys().internalList();
		var len:Number = keys.length;
		for (var i:Number = 0; i < len; i++) {
			ret.setValueForKey(m_plist.objectForKey(keys[i]), keys[i]);
		}
				
		return ret;
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
		//trace(deltaX);
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
				NSPasteboard.NSDragPboard);
			var type:String;
			switch (sourceObjectType()) {
				case SourceObjectType.AIBObject:
					type = NSPasteboard.NSObjectPboardType;
					break;
					
				case SourceObjectType.AIBView:
					type = NSPasteboard.NSViewPboardType;
					break;
			}
					
			var types:NSArray = NSArray.arrayWithObject(type);
			pb.declareTypesOwner(types,	this);
			pb.addTypesOwner(types, this);
			pb.setDataForType(createSourceObject(), type);
			
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
				NSPoint.ZeroPoint, offset, event, pb, this, true);
				
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
		if (g_cellClass == null) {
			g_cellClass = org.actionstep.NSImageCell;
		}
		
		return g_cellClass;
	}
	
	/**
	 * Sets the class of the cell used by this control.
	 */
	public static function setCellClass(cellClass:Function) {
		g_cellClass = cellClass;
	}
}