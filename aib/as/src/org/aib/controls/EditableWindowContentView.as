/* See LICENSE for copyright and terms of use */

import org.actionstep.NSView;
import org.actionstep.NSRect;
import org.actionstep.NSArray;
import org.actionstep.NSPasteboard;
import org.actionstep.NSDraggingInfo;
import org.actionstep.constants.NSDragOperation;
import org.actionstep.NSObject;
import org.actionstep.NSEvent;
import org.actionstep.NSPoint;

/**
 * @author Scott Hyndman
 */
class org.aib.controls.EditableWindowContentView extends NSView {
	
	/**
	 * Prevents {@link org.aib.controls.EditableViewDecorator} from decorating
	 * the view.
	 */
	private static var doNotDecorate:Boolean = true;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	public function initWithFrame(aRect:NSRect):EditableWindowContentView {
		super.initWithFrame(aRect);
		registerForDraggedTypes(NSArray.arrayWithObject(NSPasteboard.NSViewPboardType));
		return this;
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the EditableWindowContentView instance.
	 */
	public function description():String {
		return "EditableWindowContentView()";
	}
	
	//******************************************************
	//*                   Overrides
	//******************************************************
	
	public function mouseDown(event:NSEvent):Void {
		m_window.rootView().mouseDown(event);
	}
	
	//******************************************************
	//*                 Drag operations
	//******************************************************
	
	/**
	 * Returns NSDragOperationMove by default.
	 */
	function draggingUpdated(sender:NSDraggingInfo):NSDragOperation {
		return NSDragOperation.NSDragOperationMove;
	}
  
	/**
	 * Returns <code>true</code> if <code>#isEditable()</code> is
	 * <code>true</code>.
	 */
	function prepareForDragOperation(sender:NSDraggingInfo):Boolean	{
		return (sender.draggingSourceOperationMask() 
				& NSDragOperation.NSDragOperationMove.value != 0
			|| sender.draggingSourceOperationMask() 
				& NSDragOperation.NSDragOperationCopy.value != 0);
	}
	
	/**
	 * Accepts the pasteboard image.
	 */
	function performDragOperation(sender:NSDraggingInfo):Boolean {
		var data:NSObject = NSObject(sender.draggingPasteboard().dataForType(
			NSPasteboard.NSViewPboardType));
			
		return data != null;
		
		var pt:NSPoint = convertPointFromView(
			new NSPoint(_root._xmouse, _root._ymouse), null);
		
		pt = pt.addSize(sender.draggingOffset());
		trace(pt);
		var view:NSView = NSView(data);
		view.setFrameOrigin(pt);
		
		addSubview(view);
		
		return true;
	}
	
	/**
	 * Does nothing.
	 */
	function concludeDragOperation(sender:NSDraggingInfo):Void {
		var view:NSView = NSView(sender.draggingPasteboard().dataForType(
			NSPasteboard.NSViewPboardType));
			
		//
		// Build location and add view
		//
		var pt:NSPoint = convertPointFromView(
			new NSPoint(_root._xmouse, _root._ymouse), null);		
		pt = pt.addSize(sender.draggingOffset());

		view.setFrameOrigin(pt);
		addSubview(view);
	}
}