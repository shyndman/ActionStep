/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSRectEdge;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSColor;
import org.actionstep.NSCursor;
import org.actionstep.NSEvent;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.aib.AIBApplication;
import org.aib.configuration.AppSettings; 
import org.aib.ui.AIBColors;

/**
 * This view encapsulates a view that is to be resized. It displays resize
 * handles that, when clicked and dragged, resize it's child view.
 * 
 * @author Scott Hyndman
 */
class org.aib.stage.ResizeView extends NSView 
{
	//******************************************************
	//*                 Style constants
	//******************************************************
	
	private static var BOX_SIDE_LENGTH:Number = 4;
	private static var BOX_BORDER_COLOR:NSColor;
	private static var BOX_BACKGROUND_COLOR:NSColor;
	
	//******************************************************
	//*                Sizing constants
	//******************************************************
	
	public static var MinX:Number = 1;
	public static var MinY:Number = 2;
	public static var MaxX:Number = 4;
	public static var MaxY:Number = 8;
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private var m_handles:Array;
	private var m_trackingData:Object;
	private var m_view:NSView;
	private var m_originalAutoresizing:Number;
	private var m_umask:Number;
	
	/**
	 * Creates a new instance of ASResizeView.
	 */
	public function ResizeView()
	{
		if (BOX_BACKGROUND_COLOR == null) {
			var selColor:NSColor = AIBColors.selectionColor();
			BOX_BACKGROUND_COLOR = selColor.adjustColorBrightnessByFactor(1.3);
			BOX_BORDER_COLOR = selColor.adjustColorBrightnessByFactor(1.1);
		}
	}
	
	/**
	 * Initializes the resize view with the view <code>aView</code>.
	 */
	public function initWithView(aView:NSView):ResizeView {
		m_view = aView;
		m_originalAutoresizing = m_view.autoresizingMask();
		m_view.setAutoresizingMask(
			NSView.WidthSizable | NSView.HeightSizable);
		initWithFrame(m_view.frame());
		addSubview(m_view);
		m_view.setFrameOrigin(NSPoint.ZeroPoint);
		
		return this;
	}
	
	/**
	 * Creates the resize handle clips.
	 */
	private function createMovieClips():Void
	{
		super.createMovieClips();
		m_handles = [];
		
		for (var i:Number = 0; i < 9; i++)
		{
			if (i == 4)
				continue;
				
			var constraints:Number;
			switch (i)
			{
				case 0:
					constraints = MinX | MinY;
					break;
					
				case 8:
					constraints = MaxX | MaxY;
					break;
					
				case 1:
					constraints = MinY;
					break;
					
				case 7:
					constraints = MaxY;
					break;
					
				case 2:
					constraints = MinY | MaxX;
					break;
					
				case 6:
					constraints = MaxY | MinX;
					break;
					
				case 3:
					constraints = MinX;
					break;
					
				case 5:
					constraints = MaxX;
					break;
					
			}
			
			var handle:MovieClip = m_mcBounds.createEmptyMovieClip("handle" + i,
				m_mcDepth++);
			handle.view = this;
			handle.constraints = constraints;
			drawBoxInHandle(handle);
			m_handles[i] = handle;
		}
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the ResizeView instance.
	 */
	public function description():String {
		return "ResizeView()";
	}
	
	//******************************************************															 
	//*             Setting the focused view
	//******************************************************
	
	public static function focusViewWithUmask(view:NSView, umask:Number):ResizeView {
		if (view["__resizeView"] != undefined) {
			return null;
		}
		
		var sprview:NSView = view.superview();
		var ret:ResizeView = (new ResizeView()).initWithView(view);
		ret.m_umask = umask;
		sprview.addSubview(ret);
		view["__resizeView"] = ret;
		_global.ASSetPropFlags(view, ["__resizeView"], 1);
		
		return ret;
	}
	
	public static function unfocusView(view:NSView):Void {
		var resizer:ResizeView = ResizeView(view["__resizeView"]);
		if (resizer == null) {
			return;
		}
		view["__resizeView"] = null;
		
		//
		// Reposition
		//
		var frm:NSRect = resizer.frame();
		var sprview:NSView = resizer.superview();
		view.setFrame(frm);
		view.setAutoresizingMask(resizer.m_originalAutoresizing);
		view.removeFromSuperview();
		sprview.addSubview(view);
		
		//
		// Destroy resizer
		//
		resizer.removeFromSuperview();
		resizer.release();
	}
	
	//******************************************************															 
	//*                    Cursors
	//******************************************************
	
	public function resetCursorRects():Void
	{		
		for (var i:Number = 0; i < 9; i++)
		{
			if (i == 4)
				continue;
			
			var cursor:NSCursor;	
			var handle:MovieClip = MovieClip(m_handles[i]);
			
			switch (i)
			{
				case 0:
				case 8:
					cursor = NSCursor.resizeDiagonalDownCursor();
					break;
					
				case 1:
				case 7:
					cursor = NSCursor.resizeUpDownCursor();
					break;
					
				case 2:
				case 6:
					cursor = NSCursor.resizeDiagonalUpCursor();
					break;
					
				case 3:
				case 5:
					cursor = NSCursor.resizeLeftRightCursor();
					break;
					
			}
			
			var rect:NSRect = new NSRect(handle._x, handle._y, 
				handle._width, handle._height);
			
			addCursorRectCursor(rect, cursor);
		}
	}
	
	//******************************************************															 
	//*              Handling Mouse Events
	//******************************************************
	
	public function mouseDown(event:NSEvent):Void
	{
		//
		// View moving
		//
		if (event.view == m_view) {
			dragView(event);
			return;
		}
		
		//
		// View resizing
		//
		var len:Number = m_handles.length;
		for (var i:Number = 0; i < len; i++) 
		{
			if (event.flashObject == m_handles[i])
			{
				resizeViewWithConstraints(event, event.flashObject.constraints);
				break;
			}
		}
	}
	
	private function resizeViewWithConstraints(event:NSEvent, constraints:Number)
		:Void
	{
		var frame:NSRect = frame();
		m_trackingData = 
		{ 
			firstPoint: event.mouseLocation.clone(),
			origin: frame,
			offsetX: frame.origin.x + frame.size.width - event.mouseLocation.x,
			offsetY: frame.origin.y + frame.size.height - event.mouseLocation.y,
			mouseDown: true, 
			eventMask: NSEvent.NSLeftMouseDownMask | NSEvent.NSLeftMouseUpMask | NSEvent.NSLeftMouseDraggedMask
			| NSEvent.NSMouseMovedMask  | NSEvent.NSOtherMouseDraggedMask | NSEvent.NSRightMouseDraggedMask,
			complete: false,
			constraints: constraints & ~m_umask
		};
		resizeViewCallback(event);
	}
	
	private function resizeViewCallback(event:NSEvent):Void
	{
		if (event.type == NSEvent.NSLeftMouseUp) {
			return;
		}
	
		//
		// Calculate dimensions based on constraints
		//
		var frm:NSRect = frame();
		var edges:Array = [];
		
		var ini:NSRect = m_trackingData.origin;
		var constraints:Number = m_trackingData.constraints;
		if (constraints & MinX) {
			var chg:Number = (event.mouseLocation.x - m_trackingData.firstPoint.x);
			frm.origin.x = ini.origin.x + chg;
			frm.size.width = ini.size.width - chg;
			edges.push(NSRectEdge.NSMinXEdge);
		}
		else if (constraints & MaxX) {
			var chg:Number = (event.mouseLocation.x - m_trackingData.firstPoint.x);
			frm.size.width = ini.size.width + chg;
			edges.push(NSRectEdge.NSMaxXEdge);
		}
		
		if (constraints & MinY) {
			var chg:Number = (event.mouseLocation.y - m_trackingData.firstPoint.y);
			frm.origin.y = ini.origin.y + chg;
			frm.size.height = ini.size.height - chg;
			edges.push(NSRectEdge.NSMinYEdge);			
		}
		else if (constraints & MaxY) {
			var chg:Number = (event.mouseLocation.y - m_trackingData.firstPoint.y);
			frm.size.height = ini.size.height + chg;
			edges.push(NSRectEdge.NSMaxYEdge);
		}
		
		//
		// Set the frame and mark as needing redisplay
		//
		setFrame(frm);
		setNeedsDisplay(true);
		
		//
		// Use the guidelines
		//
		if (AIBApplication.usingGuidelines()) {
			var len:Number = edges.length;
			var modified:Boolean = false;
			var allGuides:NSArray = NSArray.array();
			
			for (var i:Number = 0; i < len; i++) {
				var guides:NSArray = NSArray.array();
				var loc:Number = AIBApplication.guidelines()
					.snapPointForViewGuidesWithEdge(this, guides, edges[i]);
				
				if (loc != null) {
					modified = true;
					//
					// Resize the view
					//					
					switch (edges[i]) {
						case NSRectEdge.NSMinXEdge:
							frm.size.width += (frm.origin.x - loc);
							frm.origin.x = loc;
							break;
							
						case NSRectEdge.NSMaxXEdge:
							frm.size.width = loc - frm.origin.x;
							break;
							
						case NSRectEdge.NSMinYEdge:
							frm.size.height += (frm.origin.y - loc);
							frm.origin.y = loc;
							break;
							
						case NSRectEdge.NSMaxYEdge:
							frm.size.height = loc - frm.origin.y;
							break;
					}
					
					allGuides.addObjectsFromArray(guides);
				}
			}
			
			if (modified) {
				setFrame(frm);
			}
		}
		
		NSApplication.sharedApplication().
			callObjectSelectorWithNextEventMatchingMaskDequeue(
				this, "resizeViewCallback", m_trackingData.eventMask, true);
	}
	
	private function dragView(event:NSEvent):Void {
		var point:NSPoint = convertPointFromView(event.mouseLocation, null);
		m_trackingData = {
			offsetX: point.x,
			offsetY: point.y,
			mouseDown: true,
			eventMask: NSEvent.NSLeftMouseDownMask | NSEvent.NSLeftMouseUpMask | NSEvent.NSLeftMouseDraggedMask
			| NSEvent.NSMouseMovedMask  | NSEvent.NSOtherMouseDraggedMask | NSEvent.NSRightMouseDraggedMask,
			complete: false
		};
		dragViewCallback(event);
	}
	
	public function dragViewCallback(event:NSEvent):Void {
		if (event.type == NSEvent.NSLeftMouseUp) {
			return;
		}
		
		var frm:NSRect = frame();
		
		//
		// Calculate the new origin
		//
		var pt:NSPoint = convertPointFromView(event.mouseLocation, null);
		pt = convertPointToView(pt, superview());
		pt = new NSPoint(
			pt.x - m_trackingData.offsetX, 
			pt.y - m_trackingData.offsetY);
			
		setFrameOrigin(pt);
		setNeedsDisplay(true);
		
		//
		// Generate data for guidelines
		//
		if (AIBApplication.usingGuidelines()) {
			
			var delta:NSPoint = frm.origin.pointDistanceToPoint(pt);
			
			//
			// Determine applicable edges
			//
			var edges:Array = [];
			
			if (delta.x > 0) {
				edges.push(NSRectEdge.NSMaxXEdge);
			}
			else if (delta.x < 0) {
				edges.push(NSRectEdge.NSMinXEdge);
			}
			if (delta.y > 0) {
				edges.push(NSRectEdge.NSMaxYEdge);
			}
			else if (delta.y < 0) {
				edges.push(NSRectEdge.NSMinYEdge);
			}

			var len:Number = edges.length;
			var modified:Boolean = false;
			var allGuides:NSArray = NSArray.array();
			
			for (var i:Number = 0; i < len; i++) {
				var guides:NSArray = NSArray.array();
				var loc:Number = AIBApplication.guidelines()
					.snapPointForViewGuidesWithEdge(this, guides, edges[i]);
				
				if (loc != null) {
					modified = true;
					//
					// Resize the view
					//					
					switch (edges[i]) {
						case NSRectEdge.NSMinXEdge:
							frm.origin.x = loc;
							break;
							
						case NSRectEdge.NSMaxXEdge:
							frm.origin.x = loc - frm.size.width;
							break;
							
						case NSRectEdge.NSMinYEdge:
							frm.origin.y = loc;
							break;
							
						case NSRectEdge.NSMaxYEdge:
							frm.origin.y = loc - frm.size.height;
							break;
					}
					
					allGuides.addObjectsFromArray(guides);
				}
			}
			
			if (modified) {
				setFrameOrigin(frm.origin);
			}
		}
				
		NSApplication.sharedApplication().callObjectSelectorWithNextEventMatchingMaskDequeue(
			this, "dragViewCallback", m_trackingData.eventMask, true);
	}
	
	public function keyDown(event:NSEvent):Void {
		var dist:Number = Number(AppSettings.appSettingWithName(
			"arrowKeyMoveDistance"));
		var loc:NSPoint = frame().origin;
		
		switch (event.keyCode) {
			case Key.DELETEKEY:
				trace("DELETEKEY");
				break;
				
			// TODO Factor in support for multiple selection
			case Key.LEFT:
				setFrameOrigin(loc.translate(-dist, 0));
				break;
				
			case Key.RIGHT:
				setFrameOrigin(loc.translate(dist, 0));
				break;
				
			case Key.UP:
				setFrameOrigin(loc.translate(0, -dist));
				break;
				
			case Key.DOWN:
				setFrameOrigin(loc.translate(0, dist));
				break;	
		}
	}
	
	//******************************************************															 
	//*                Drawing the view
	//******************************************************
	
	/**
	 * Positions the resize handles.
	 */
	public function drawRect(rect:NSRect):Void
	{
		var x1:Number = rect.origin.x;
		var x3:Number = rect.origin.x + rect.size.width - BOX_SIDE_LENGTH - 1;
		var x2:Number = (x3 - x1 + BOX_SIDE_LENGTH) / 2;
		
		var y1:Number = rect.origin.y;
		var y3:Number = rect.origin.y + rect.size.height - BOX_SIDE_LENGTH - 1;
		var y2:Number = (y3 - y1) / 2;
		
		m_handles[0]._x = x1;
		m_handles[0]._y = y1;
		m_handles[1]._x = x2;
		m_handles[1]._y = y1;
		m_handles[2]._x = x3;
		m_handles[2]._y = y1;
		
		m_handles[3]._x = x1;
		m_handles[3]._y = y2;
		
		m_handles[5]._x = x3;
		m_handles[5]._y = y2;
		
		m_handles[6]._x = x1;
		m_handles[6]._y = y3;
		m_handles[7]._x = x2;
		m_handles[7]._y = y3;
		m_handles[8]._x = x3;
		m_handles[8]._y = y3;
	
		m_window.invalidateCursorRectsForView(this);
	}
	
	/**
	 * Draws the contents of a handle.
	 */
	public function drawBoxInHandle(handle:MovieClip):Void
	{
		handle.lineStyle(0.5, BOX_BORDER_COLOR.value, 100);
		handle.beginFill(BOX_BACKGROUND_COLOR.value, 100);
		handle.lineStyle(0);
		handle.moveTo(0, 0);
		handle.lineTo(0, BOX_SIDE_LENGTH);
		handle.lineTo(BOX_SIDE_LENGTH, BOX_SIDE_LENGTH);
		handle.lineTo(BOX_SIDE_LENGTH, 0);
		handle.lineTo(0, 0);
		handle.endFill();
	}
	
	//******************************************************
	//*                Class constructor
	//******************************************************
	
	private static function initialize():Void {

	}
}