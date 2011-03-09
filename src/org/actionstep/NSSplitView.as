/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASDraw;
import org.actionstep.ASUtils;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSColor;
import org.actionstep.NSEvent;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.NSCursor;
//import org.actionstep.ASDebugger;

/**
 * <p>An NSSplitView object stacks several subviews within one view so that the 
 * user can change their relative sizes. By default, the split bars between the 
 * views are horizontal, so the views are one on top of the other.</p>
 * 
 * <p>A splitview delegate is extremely powerful, and can be used to determine
 * minimum, maximum and proposed subview sizes, as well as the points at
 * which a subview can collapse. For more information on how to create a 
 * delegate class, see {@link org.actionstep.splitView.ASSplitViewDelegate}.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSSplitView extends NSView {
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private var m_isVertical:Boolean;
	private var m_dividerWidth:Number;
	private var m_neverShownBefore:Boolean;
	private var m_delegate:Object;
	private var m_isPaneSplitter:Boolean;
	private var m_collapsedSubviews:NSArray;
	private var m_backgroundColor:NSColor;
	private var m_drawsBackground:Boolean;
	private var m_trackingData:Object;
	private var m_movingDivider:MovieClip;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSSplitView</code> class.
	 */
	public function NSSplitView() {
		m_isVertical = false;
		m_neverShownBefore = true;
		setAutoresizesSubviews(false);
		m_isPaneSplitter = true;
		m_dividerWidth = 10; // FIXME Put into theme
		m_collapsedSubviews = NSArray.array();
		m_backgroundColor = ASColors.lightGrayColor(); // FIXME Put into theme
		m_drawsBackground = true;
	}
	
	/**
	 * Initializes the splitter with a frame rect of <code>aRect</code>.
	 */
	public function initWithFrame(aRect:NSRect):NSSplitView {
		super.initWithFrame(aRect);
		return this;
	}
	
	/**
	 * Releases this object from memory.
	 */
	public function release():Void {
		super.release();
		
		if (m_delegate != null) {
			NSNotificationCenter.defaultCenter().removeObserverNameObject(
				m_delegate, null, this);
		}
	}
	
	public function createMovieClips():Void {
		if (m_mcFrame != null)
		{
		   //return if already created
		   return;
		}
    
		super.createMovieClips();
		
		m_movingDivider = m_mcFrame.createEmptyMovieClip("m_movingDivider", 
			getNextDepth());
		m_movingDivider.view = this;
		ASDraw.solidCornerRect(m_movingDivider,
			0, 0, 200, 200, 0, 0xFFCCCC);
		m_movingDivider.blendMode = "invert";
		m_movingDivider.cacheAsBitmap = true;
		m_movingDivider._visible = false;
	}
	
	//******************************************************
	//*             Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the NSSplitView instance.
	 */
	public function description():String {
		return "NSSplitView()";
	}
	
	//******************************************************
	//*                   Events
	//******************************************************
	
	/**
	 * Always returns <code>true</code>.
	 */
	public function acceptsFirstMouse(theEvent:NSEvent):Boolean {
		return true;
	}
	
	private var oldRect:NSRect;
	private var lit:Boolean;
	private var m_lastP:NSPoint;
	
	/**
	 * Handles the divider dragging.
	 */
	public function mouseDown(theEvent:NSEvent):Void {
		var app:NSApplication = NSApplication.sharedApplication();
		lit = false;
		var p:NSPoint, op:NSPoint;
		var r:NSRect, r1:NSRect, bigRect:NSRect, vis:NSRect;
		var v:NSView = null, prev:NSView = null;
		var minCoord:Number, maxCoord:Number;
		var subs:Array = subviews();
		var offset:Number = 0, i:Number, len:Number = subs.length;
		var divVertical:Number, divHorizontal:Number;
		// distantFuture
		// distantPast
		var eventMask:Number = NSEvent.NSLeftMouseUpMask 
			| NSEvent.NSLeftMouseDraggedMask;
		var delegateConstrains:Boolean = false;
		var isVert:Boolean = isVertical();
		var dw:Number = dividerThickness();
		var collapsePoint:Number = -1;
		
		//
		// We can't do anything if we have less than 2 subviews
		//
		if (len < 2) {
			return;
		}
		
		if (theEvent.view != this) {
			return;
		}
		
		r1 = NSRect.ZeroRect;
		bigRect = NSRect.ZeroRect;
		vis = visibleRect();
		
		//
		// Find out what divider we've clicked on.
		//
		p = convertPointFromView(theEvent.mouseLocation, null);
		for (i = 0; i < len; i++) {
			v = NSView(subs[i]);
			r = v.frame();
//			if (r.pointInRect(p)) {
//				trace("THIS SHOULD NEVER HAPPEN.", ASDebugger.WARNING);
//				trace(theEvent.flashObject.view);
//				return;
//			}
			if (!isVert) {
				if (r.minY() >= p.y) {
					offset = i - 1;
					
					if (prev != null) {
						r = prev.frame();
					} else {
						//
						// If this happened, the user pressed exactly on the top
						// of the top subview. 
						//
						return;
					}
					
					if (v != null) {
						r1 = v.frame();
					}
					
					bigRect = r.clone();
					bigRect = bigRect.unionRect(r1);
					break;
				}
				
				prev = v;
			} else {
				if (r.minX() >= p.x) {
					offset = i - 1;
					
					if (prev != null) {
						r = prev.frame();
					} else {
						//
						// If this happened, the user pressed exactly on the 
						// left of the top subview. 
						//
						return;
					}
					
					if (v != null) {
						r1 = v.frame();
					}
					
					bigRect = r.clone();
					bigRect = bigRect.unionRect(r1, bigRect);
					break;
				}
				prev = v;
			}
		}
		
		//
		// Check if the delegate constrains the divider
		//
		delegateConstrains = m_delegate != null && ASUtils.respondsToSelector(
			m_delegate, "splitViewConstrainSplitPositionOfSubviewAt");
		
		if (!isVert) {
			divVertical = dw;
			divHorizontal = frame().size.width + 2;
			// default limits on draggins
			minCoord = bigRect.minY() + divVertical;
			maxCoord = bigRect.size.height + bigRect.minY() - divVertical;
		} else {
			divHorizontal = dw;
			divVertical = frame().size.height + 2;
			// default limits on the dragging
			minCoord = bigRect.minX() + divHorizontal;
			maxCoord = bigRect.size.width + bigRect.minX() - divHorizontal;
		}
		
		//
		// Find out what the dragging limit is
		//
		if (m_delegate != null) {
			var delMin:Number = minCoord, delMax:Number = maxCoord;
			
			if (ASUtils.respondsToSelector(m_delegate,
					"splitViewConstrainMinCoordinateOfSubviewAt")) {
				delMin = m_delegate.splitViewConstrainMinCoordinateOfSubviewAt(
					this, minCoord, offset);

				if (ASUtils.respondsToSelector(m_delegate,
						"splitViewCanCollapseSubview")
						&& m_delegate.splitViewCanCollapseSubview(this, prev)) {
					//collapsePoint = delMin + (((isVert ? r.maxX() : r.maxY()) - delMin) / 2);
					collapsePoint = delMin + 30; // FIXME This is wrong
				}
			}
			
			if (ASUtils.respondsToSelector(m_delegate,
					"splitViewConstrainMaxCoordinateOfSubviewAt")) {
				delMax = m_delegate.splitViewConstrainMaxCoordinateOfSubviewAt(
					this, maxCoord, offset);
			}
			
			// Make sure we are still constrained by the original bounds 
			if (delMin > minCoord) {
				minCoord = delMin;
			}
			if (delMax < maxCoord) {
				maxCoord = delMax;
			}
		}
		
		//
		// Construct the tracking data and begin tracking.
		//
		r = r.clone();
		r.size.width = divHorizontal;
		r.size.height = divVertical;
		
		m_trackingData = {
			mouseDown: true,
			eventMask: eventMask,
			complete: false,
			minCoord: minCoord,
			maxCoord: maxCoord,
			divVertical: divVertical,
			divHorizontal: divHorizontal,
			delegateConstrains: delegateConstrains,
			collapsePoint: collapsePoint,
			offset: offset,
			vis: vis,
			oldRect: NSRect.ZeroRect,
			r: r,
			prev: prev,
			v: v,
			bigRect: bigRect,
			isVert: isVertical(),
			lastTime: getTimer()};
			
		m_movingDivider._visible = true;
		sizeMovingDivider(r.size);
		mouseTrackingCallBack(theEvent);
	}
	
	/**
	 * Called continuously as long as the mouse is dragging.
	 */
	private function mouseTrackingCallBack(theEvent:NSEvent):Void {		
		var p:NSPoint = convertPointFromView(theEvent.mouseLocation, null);
		var r:NSRect = m_trackingData.r;
		var oldRect:NSRect = m_trackingData.oldRect;
		var isVert:Boolean = m_trackingData.isVert;
		var delegateConstrains:Boolean = m_trackingData.delegateConstrains;
		var offset:Number = m_trackingData.offset;
		var minCoord:Number = m_trackingData.minCoord;
		var maxCoord:Number = m_trackingData.maxCoord;
		var divVertical:Number = m_trackingData.divVertical;
		var divHorizontal:Number = m_trackingData.divHorizontal;
		var collapsePoint:Number = m_trackingData.collapsePoint;
		var vis:NSRect = m_trackingData.vis;
		var prev:NSView = m_trackingData.prev;
		
		//
		// If we have a constraining delegate, constrain.
		//
		if (delegateConstrains) {
			if (isVert) {
				p.x = m_delegate.splitViewConstrainSplitPositionOfSubviewAt(
					this, p.x, offset);	
			} else {
				p.y = m_delegate.splitViewConstrainSplitPositionOfSubviewAt(
					this, p.y, offset);
			}
		}
	
		//
		// Constrain the split position based on minimums and maximums.
		//
		if (!isVert) {
			if (p.y < minCoord) {
				p.y = minCoord;
			}
			if (p.y > maxCoord) {
				p.y = maxCoord;
			}
		} else {
			if (p.x < minCoord) {
				p.x = minCoord;
			}
			if (p.x > maxCoord) {
				p.x = maxCoord;
			}
		}
			
		//
		// View collapsing
		//
		if (collapsePoint != -1) {
			var collapsed:Boolean = isSubviewCollapsed(prev);

			if (isVert) {
				var value:Number =  p.x;
				
				if (collapsed) {
					if (value > collapsePoint) { // uncollapse
						p.x = collapsePoint + 2;
						m_collapsedSubviews.removeObject(prev);
					} else { // keep collapsed
						p.x = prev.frame().minX() + divHorizontal / 2;
					}
				}
				else if (!collapsed && value < collapsePoint) {
					p.x = prev.frame().minX() + divHorizontal / 2;
					m_collapsedSubviews.addObject(prev);
				}
			} else {
				var value:Number =  p.y;
				
				if (collapsed) {
					if (value > collapsePoint) { // uncollapse
						p.y = collapsePoint + 2;
						m_collapsedSubviews.removeObject(prev);
					} else { // keep collapsed
						p.y = prev.frame().minY() + divVertical / 2;
					}
				}
				else if (!collapsed && value < collapsePoint) { // collapse
					p.y = prev.frame().minY() + divVertical / 2;
					m_collapsedSubviews.addObject(prev);
				}				
			}
		}
		
		//
		// Set the origin of x
		//
		if (!isVert) {
			r.origin.y = p.y - (divVertical / 2);
			r.origin.x = vis.minX();
		} else {
			r.origin.x = p.x - divHorizontal / 2;	
			r.origin.y = vis.minY();
		}
		
		//
		// Mouse Up
		//
		if (theEvent.type == NSEvent.NSLeftMouseUp) {
			m_lastP = p;
			mouseTrackingEnded(theEvent);		
			return;
		}
		
		//
		// Only draw if we're dealing with a new rect.
		//
		if (!r.isEqual(oldRect)) {			
			//
			// Draw divider at r 
			//
			moveMovingDivider(r.origin);			
			lit = true;
			m_trackingData.oldRect = r.clone();
		}
		
		//
		// Continue tracking
		//
		NSApplication.sharedApplication()
			.callObjectSelectorWithNextEventMatchingMaskDequeue(
			this, "mouseTrackingCallBack", m_trackingData.eventMask, true);
	}
	
	/**
	 * Fired when mouse tracking finishes.
	 */
	private function mouseTrackingEnded(event:NSEvent):Void {
		m_movingDivider._visible = false;
		sizeMovingDivider(new NSSize(5, 5));
		lit = false;
		setNeedsDisplay(true);
		
		//
		// Post notification
		//
		m_notificationCenter.postNotificationWithNameObject(
			NSSplitViewWillResizeSubviewsNotification,
			this);

		//
		// Resize subviews
		//			
		var prev:NSView = NSView(m_trackingData.prev);
		var v:NSView = NSView(m_trackingData.v);
		var bigRect:NSRect = m_trackingData.bigRect;
		var isVert:Boolean = m_trackingData.isVert;
		var r:NSRect = prev.frame();
		var r1:NSRect = v.frame();
		var divVertical:Number = m_trackingData.divVertical;
		var divHorizontal:Number = m_trackingData.divHorizontal;
		var p:NSPoint = m_lastP;
		var isPrevCollapsed:Boolean = isSubviewCollapsed(prev);
			
		if (!isVert) {
			r.size.height = p.y - bigRect.minY() - (divVertical / 2);
			if (r.size.height < 1) {
				r.size.height = 1;
			}
			
			r1.origin.y = p.y + (divVertical / 2);
			if (r1.minY() < 0) {
				r1.origin.y = 0;
			}
			r1.size.height = bigRect.size.height - divVertical;
			
			if (!isPrevCollapsed) {
				r1.size.height -= r.size.height;
			}
			
			if (r1.size.height < 1) {
				r1.size.height = 1;
			}
		} else {
			r.size.width = p.x - bigRect.minX() - (divHorizontal / 2);
			if (r.size.width < 1) {
				r.size.width = 1;
			}
			
			r1.origin.x = p.x + (divHorizontal / 2);
			if (r1.minX() < 0) {
				r1.origin.x = 0;
			}
			
			r1.size.width = bigRect.size.width - divHorizontal;
			
			if (!isPrevCollapsed) {
				r1.size.width -= r.size.width;
			}
			
			if (r1.size.width < 1) {
				r1.size.width = 1;
			}			
		}
		
		if (isPrevCollapsed) {
			prev.setHidden(true);
		} else {
			prev.setFrame(r);
			prev.setHidden(false);
		}
		prev.setNeedsDisplay(true);
		v.setFrame(r1);
		v.setNeedsDisplay(true);
		
		//
		// Invalidate cursor rects
		//
		m_window.invalidateCursorRectsForView(this);
		
		//
		// Post notification
		//
		m_notificationCenter.postNotificationWithNameObject(
			NSSplitViewDidResizeSubviewsNotification,
			this);
			
		//
		// Clean up
		//
		m_trackingData = null;
		m_lastP = null;
	}
	
	/**
	 * Resizes the moving divider to occupy <code>aSize</code>.
	 */
	private function sizeMovingDivider(aSize:NSSize):Void {
		m_movingDivider._width = aSize.width;
		m_movingDivider._height = aSize.height;
	}
	
	/**
	 * Moves the moving divider to <code>aPoint</code>.
	 */
	private function moveMovingDivider(aPoint:NSPoint):Void {
		m_movingDivider._x = aPoint.x;
		m_movingDivider._y = aPoint.y;	
	}
	
	//******************************************************
	//*           Managing component views
	//******************************************************
	
	/**
	 * <p>Adjusts the sizes of the receiver’s subviews so they (plus the 
	 * dividers) fill the receiver.</p>
	 * 
	 * <p>The subviews are resized proportionally; the size of a subview 
	 * relative to the other subviews doesn’t change.</p>
	 * 
	 * @see NSView#setFrame()
	 * @see #setDelegate()
	 */
	public function adjustSubviews():Void {
		var subs:Array = subviews();
		var len:Number = subs.length;
		var frames:Array = [];
		var newSize:NSSize;
		var newPoint:NSPoint;
		var newTotal:Number;
		var oldTotal:Number;
		var scale:Number;
		var running:Number;
		var r:NSRect;
		var dw:Number = dividerThickness();
		var i:Number;
		
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		nc.postNotificationWithNameObject(NSSplitViewWillResizeSubviewsNotification, this);
				
		if (m_isVertical == false) {
			newTotal = m_bounds.size.height - dw * (len - 1);
			oldTotal = 0.0;
			
			for (i = 0; i < len; i++) {
				frames[i] = NSView(subs[i]).frame();
				oldTotal +=  NSRect(frames[i]).size.height;
			}
			scale = newTotal / oldTotal;
			running = 0.0;
			
			for (i = 0; i < len; i++) {
				var newHeight:Number;
				r = NSView(subs[i]).frame();
				newHeight = NSRect(frames[i]).size.height * scale;
				
				if (i == len - 1) {
					newHeight = Math.floor(newHeight);
				} else {
					newHeight = Math.ceil(newHeight);
				}
				
				newSize = new NSSize(m_bounds.size.width, newHeight);
				newPoint = new NSPoint(0.0, running);
				running += newHeight + dw;
				NSView(subs[i]).setFrameSize(newSize);
				NSView(subs[i]).setFrameOrigin(newPoint);
				NSView(subs[i]).setNeedsDisplay(true);
			}
		} else { // m_isVertical == true
			newTotal = m_bounds.size.width - dw * (len - 1);
			oldTotal = 0.0;
			
			for (i = 0; i < len; i++) {
				oldTotal +=  NSView(subs[i]).frame().size.width;
			}
			
			scale = newTotal/oldTotal;
			running = 0.0;
			
			for (i = 0; i < len; i++) {
				var newWidth:Number;
				r = NSView(subs[i]).frame();
				newWidth = r.size.width * scale;
				
				if (i == len - 1) {
					newWidth = Math.floor(newWidth);
				} else {
					newWidth = Math.ceil(newWidth);
				}
				
				newSize = new NSSize(newWidth, m_bounds.size.height);
				newPoint = new NSPoint(running, 0.0);
				running += newWidth + dw;
				NSView(subs[i]).setFrameSize(newSize);
				NSView(subs[i]).setFrameOrigin(newPoint);
				NSView(subs[i]).setNeedsDisplay(true);
			}
		}
		
		setNeedsDisplay(true);
		m_window.invalidateCursorRectsForView(this);
		nc.postNotificationWithNameObject(NSSplitViewDidResizeSubviewsNotification,
			this);
	}
	
	/**
	 * Attempts to call the delegate to determine subview sizes. If the 
	 * delegate does not implement 
	 * {@link org.actionstep.ASSplitViewDelegate#splitViewResizeSubviewsWithOldSize}
	 * the {@link #adjustSubviews()} method is used instead.
	 */
	private function adjustSubviewsWithOldSize(oldSize:NSSize):Void {
		if (m_delegate != null && ASUtils.respondsToSelector(
				m_delegate, "splitViewResizeSubviewsWithOldSize")) {
			m_delegate["splitViewResizeSubviewsWithOldSize"](this, oldSize);	
		} else {
			adjustSubviews();
		}
	}
	
	/**
	 * <p>Returns the thickness of the divider.</p>
	 * 
	 * <p>You can subclass <code>NSSplitView</code> and override this method to 
	 * change the divider’s size, if necessary.</p>
	 * 
	 * @see #drawDividerInRect()
	 */
	public function dividerThickness():Number {
		return m_dividerWidth;
	}
	public function dividerCursorThickness():Number {
		return dividerThickness();
	}
	
	/**
	 * Returns <code>true</code> if <code>subview</code> is in a collapsed 
	 * state, <code>false</code> otherwise.
	 */
	public function isSubviewCollapsed(subview:NSView):Boolean {
		return m_collapsedSubviews.containsObject(subview);
	}
	
	/**
	 * Performs necessary cleanup involving <code>view</code>.
	 */
	public function willRemoveSubview(view:NSView):Void {
		m_collapsedSubviews.removeObject(view);
	}
	
	//******************************************************
	//*               Managing orientation
	//******************************************************
	
	/**
	 * <p>Returns <code>true</code> if the split bars are vertical (subviews are 
	 * side by side), <code>false</code> if they are horizontal (views are one 
	 * on top of the other).</p>
	 * 
	 * <p>By default, split bars are horizontal.</p>
	 * 
	 * @see #setVertical()
	 */
	public function isVertical():Boolean {
		return m_isVertical;
	}
	
	/**
	 * <p>Sets whether the split bars are vertical.</p>
	 * 
	 * <p>If <code>flag</code> is <code>true</code>, they’re vertical (views are 
	 * side by side); if it’s <code>false</code>, they’re horizontal (views 
	 * are one on top of the other). Split bars are horizontal by default.</p>
	 * 
	 * @see #isVertical()
	 */
	public function setVertical(flag:Boolean):Void {
		m_isVertical = flag;
	}
	
	//******************************************************
	//*                Assigning a delegate
	//******************************************************
	
	/**
	 * <p>Returns the receiver’s delegate.</p>
	 * 
	 * @see #setDelegate()
	 */
	public function delegate():Object {
		return m_delegate;
	}
	
	/**
	 * <p>Makes <code>anObject</code> the receiver’s delegate.</p>
	 * 
	 * <p>For information on what methods this object can implement to receive
	 * messages from the split view, please see 
	 * {@link org.actionstep.ASSplitViewDelegate}.</p>
	 * 
	 * @see #delegate()
	 */
	public function setDelegate(anObject:Object):Void {
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		if (m_delegate != null) {
			nc.removeObserverNameObject(
				m_delegate, null, this);
		}
		
		m_delegate = anObject;
		
		if (ASUtils.respondsToSelector(m_delegate, "splitViewDidResizeSubviews")) {
			nc.addObserverSelectorNameObject(m_delegate, "splitViewDidResizeSubviews",
				NSSplitViewDidResizeSubviewsNotification);
		}
		if (ASUtils.respondsToSelector(m_delegate, "splitViewWillResizeSubviews")) {
			nc.addObserverSelectorNameObject(m_delegate, "splitViewWillResizeSubviews",
				NSSplitViewWillResizeSubviewsNotification);
		}
	}
	
	//******************************************************
	//*             Managing pane splitters
	//******************************************************
	
	/**
	 * <p>Returns <code>true</code> if the receiver’s splitter is a bar that goes 
	 * across the split view. Returns <code>false</code> if the splitter is a 
	 * thumb on the regular background pattern.</p>
	 * 
	 * <p>The default is <code>true</code>.</p>
	 * 
	 * @see #setIsPaneSplitter()
	 */
	public function isPaneSplitter():Boolean {
		return m_isPaneSplitter;
	}
	
	/**
	 * <p>Sets the type of splitter.</p>
	 * 
	 * <p>If <code>flag</code> is <code>true</code>, the receiver’s splitter is 
	 * a bar that goes across the split view. If flag is <code>false</code>, 
	 * the splitter is a thumb on the regular background pattern.</p>
	 * 
	 * @see #isPaneSplitter()
	 */
	public function setIsPaneSplitter(flag:Boolean):Void {
		m_isPaneSplitter = flag;
	}
	
	//******************************************************
	//*               Visual attributes
	//******************************************************
	
	/**
	 * Returns the split view's background color.
	 * 
	 * @see #setBackgroundColor()
	 */
	public function backgroundColor():NSColor {
		return m_backgroundColor;
	}
	
	/**
	 * Sets the split view's background color to <code>aColor</code>.
	 * 
	 * @see #backgroundColor()
	 */
	public function setBackgroundColor(aColor:NSColor):Void {
		m_backgroundColor = aColor;
	}
	
	/**
	 * Returns <code>true</code> if the split view draws a background.
	 * 
	 * @see #setDrawsBackground()
	 */
	public function drawsBackground():Boolean {
		return m_drawsBackground;
	}
	
	/**
	 * Sets whether the split view draws a background.
	 * 
	 * @see #drawsBackground()
	 */
	public function setDrawsBackground(flag:Boolean):Void {
		m_drawsBackground = flag;
	}
	
	//******************************************************
	//*                Drawing the view
	//******************************************************
	
	/**
	 * <p>Draws the divider between two of the receiver’s subviews.</p>
	 * 
	 * @see #dividerThickness()
	 */
	public function drawDividerInRect(aRect:NSRect):Void {
		//FIXME Externalize to theme
		var isVert:Boolean = isVertical();
		var angle:Number = isVert ? ASDraw.ANGLE_LEFT_TO_RIGHT :
			 ASDraw.ANGLE_TOP_TO_BOTTOM;
		var mc:MovieClip = mcBounds();
		ASDraw.gradientRectWithRect(mc, aRect, angle, [0xE9E9E9, 0x8B8B8B], [0, 255]);
		
		//
		// Draw bumps
		//
		if (isVert) {
			var x1:Number = aRect.origin.x + aRect.size.width/2-1;
			var x2:Number = x1 + 3;
			x1 -= 3;
			var midY:Number = aRect.midY();
			var y1:Number = midY - 10;
			var y2:Number = midY + 10;
			while (x1 < x2) {
				mc.lineStyle(1, 0xCEC1C6, 50);
				mc.moveTo(x1, y1);
				mc.lineTo(x1, y2);
				mc.lineStyle(1, 0x3B3F37, 50);
				mc.moveTo(x1+1, y2);
				mc.lineTo(x1+1, y1);
				x1+=2;
			}
		} else {
			var y1:Number = aRect.origin.y + aRect.size.height/2-1;
			var y2:Number = y1 + 3;
			y1 -= 3;
			var midX:Number = aRect.midX();
			var x1:Number = midX - 10;
			var x2:Number = midX + 10;
			while (y1 < y2) {
				mc.lineStyle(1, 0xCEC1C6, 50);
				mc.moveTo(x1, y1);
				mc.lineTo(x2, y1);
				mc.lineStyle(1, 0x3B3F37, 50);
				mc.moveTo(x2, y1+1);
				mc.lineTo(x1, y1+1);
				y1+=2;
			}
		}
	}
	
	/**
	 * Draws the splitter in <code>aRect</code>.
	 */
	public function drawRect(aRect:NSRect):Void {
		var subs:Array = subviews();
		var len:Number = subs.length;
		var i:Number;
		var v:NSView;
		var divRect:NSRect;
		var isVert:Boolean = isVertical();
		var dw:Number = dividerThickness();
		var mc:MovieClip = mcBounds();
		
		mc.clear();
		
		//
		// Draw the background
		//
		if (drawsBackground()) {
			ASDraw.solidCornerRectWithRect(mc, aRect, 0, backgroundColor().value);
		}
		
		//
		// Draw the dividers
		//
		for (i = 0; i < len - 1; i++) {
			v = NSView(subs[i]);
			
			var collapsed:Boolean = isSubviewCollapsed(v); 
			
			divRect = v.frame();
			
			if (isVert) {
				divRect.origin.x = collapsed ? divRect.minX() : divRect.maxX();
				divRect.size.width = dw;
			} else {
				divRect.origin.y = collapsed ? divRect.minY() : divRect.maxY();
				divRect.size.height = dw;
			}
			
			drawDividerInRect(divRect);
		}
	}
	
	//******************************************************
	//*               Overridden methods
	//******************************************************
		
	/**
	 * Gives the delegate an opportunity to lay out the views, then invalidates
	 * this view's cursor rects.
	 */
	public function frameDidChange(oldFrame:NSRect):Void {
		adjustSubviewsWithOldSize(oldFrame.size);
		window().invalidateCursorRectsForView(this);
	}
	
	public function resetCursorRects():Void {
		var subs:Array = subviews();
		var len:Number = subs.length;
		var i:Number;
		var v:NSView;
		var divRect:NSRect;
		var isVert:Boolean = isVertical();
		var dw:Number = dividerCursorThickness();
		var cursor:NSCursor;
		
		//
		// Step up the dividers
		//
		for (i = 0; i < len - 1; i++) {
			v = NSView(subs[i]);
			
			var collapsed:Boolean = isSubviewCollapsed(v); 
			
			divRect = v.frame();
			
			if (isVert) {
				divRect.origin.x = collapsed ? divRect.minX() : divRect.maxX();
				divRect.size.width = dw;
				cursor = NSCursor.resizeLeftRightCursor();
			} else {
				divRect.origin.y = collapsed ? divRect.minY() : divRect.maxY();
				divRect.size.height = dw;
				cursor = NSCursor.resizeUpDownCursor();
			}
			
			addCursorRectCursor(divRect, cursor);
		}
	}
	
	//******************************************************
	//*             MovieClip (ActionStep-only)
	//******************************************************
	
	private function requiresMask():Boolean {
		return true;
	}
	
	//******************************************************
	//*                  Notifications
	//******************************************************
	
	/**
	 * Posted after a split view changes the sizes of some or all of its 
	 * subviews. The notification object is the split view that resized its 
	 * subviews. This notification does not contain a <code>userInfo</code> 
	 * dictionary.
	 */
	public static var NSSplitViewDidResizeSubviewsNotification:Number =
		ASUtils.intern("NSSplitViewDidResizeSubviewsNotification");
		
	/**
	 * Posted before an split view changes the sizes of some or all of its 
	 * subviews. The notification object is the split view object that is about 
	 * to resize its subviews. This notification does not contain a 
	 * <code>userInfo</code> dictionary.
	 */
	public static var NSSplitViewWillResizeSubviewsNotification:Number =
		ASUtils.intern("NSSplitViewWillResizeSubviewsNotification");
}