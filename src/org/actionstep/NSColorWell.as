/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSDragOperation;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSArray;
import org.actionstep.NSColor;
import org.actionstep.NSColorPanel;
import org.actionstep.NSControl;
import org.actionstep.NSDraggingInfo;
import org.actionstep.NSDraggingSource;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPasteboard;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.themes.ASTheme;

/**
 * <p>An NSColorWell object is an NSControl for selecting and displaying a 
 * single color value. An example of an NSColorWell object (or simply color 
 * well) is found in an NSColorPanel, which uses a color well to display the 
 * current color selection.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSColorWell extends NSControl implements NSDraggingSource {
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private var m_color:NSColor;
	private var m_isActive:Boolean;
	private var m_target:Object;
	private var m_action:String;
	private var m_isBordered:Boolean;
	private var m_wellRect:NSRect;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSColorWell</code> class.
	 */
	public function NSColorWell() {
		m_isActive = false;
		m_isBordered = true;
		m_color = ASColors.blackColor();
	}
	
	/**
	 * Initializes and returns the <code>NSColorWell</code> instance with a frame
	 * area of <code>aRect</code>.
	 */
	public function initWithFrame(aRect:NSRect):NSColorWell {
		super.initWithFrame(aRect);
		
		//
		// Register for color dragging
		//
		registerForDraggedTypes(NSArray.arrayWithObject(
			NSPasteboard.NSColorPboardType));
		
		return this;
	}
	
	/**
	 * Releases the color well from memory.
	 */
	public function release():Boolean {
		if (m_isActive) {
			deactivate();
		}
		
		return super.release();
	}
	
	//******************************************************
	//*                   Activating
	//******************************************************
	
	/**
	 * <p>Activates the receiver, displays the color panel, and makes the 
	 * current color the same as its own.</p>
	 * 
	 * <p><code>exclusive</code> is <code>true</code> to deactivate any other 
	 * color wells or <code>false</code> to keep them active. If a color panel 
	 * is active with exclusive set to <code>true</code> and another is 
	 * subsequently activated with exclusive set to <code>false</code>, the 
	 * exclusive setting of the first panel is ignored.</p>
	 * 
	 * <p>This method redraws the receiver. An active color well will have its 
	 * color updated when the current color of the NSColorPanel changes. Any 
	 * color well that shows its border highlights the border when it’s 
	 * active.</p>
	 * 
	 * @see #deactivate()
	 * @see #isActive()
	 */
	public function activate(exclusive:Boolean):Void {
		if (m_isActive) {
			return;
		}
		
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		var cp:NSColorPanel = NSColorPanel.sharedColorPanel();
		
		if (exclusive) {
			nc.postNotificationWithNameObject(
				ASColorWellDidBecomeExclusiveNotification,
				this);
		}
		
		nc.addObserverSelectorNameObject(this, "deactivate",
			ASColorWellDidBecomeExclusiveNotification,
			null);
		
		nc.addObserverSelectorNameObject(this, "takeColorFromPanel",
			NSColorPanel.NSColorPanelColorDidChangeNotification,
			null);
			
		m_isActive = true;
		cp.setColor(color());
		cp.orderFront(this);
		setNeedsDisplay(true);
	}
	
	/**
	 * Deactivates the receiver and redraws it.
	 * 
	 * @see #activate()
	 * @see #isActive()
	 */
	public function deactivate():Void {
		if (!m_isActive) {
			return;
		}
		
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		nc.removeObserver(this);
		
		m_isActive = false;
		
		setNeedsDisplay(true);
	}
	
	/**
	 * Returns a Boolean value indicating whether the receiver is active.
	 */
	public function isActive():Boolean {
		return m_isActive;
	}
	
	//******************************************************
	//*                  Managing color
	//******************************************************
	
	/**
	 * <p>Returns the color of the receiver.</p>
	 * 
	 * @see #setColor()
	 * @see #takeColorFrom()
	 */
	public function color():NSColor {
		return m_color;
	}
	
	/**
	 * <p>Sets the color of the receiver and redraws the receiver.</p>
	 * 
	 * @see #color()
	 * @see #takeColorFrom()
	 */
	public function setColor(aColor:NSColor):Void {
		m_color = aColor;
		
		if (m_isActive) {
			var cp:NSColorPanel = NSColorPanel.sharedColorPanel();
			cp.setColor(aColor);
		}
		
		sendActionTo(action(), target());
		setNeedsDisplay(true);
	}
	
	/**
	 * <p>Changes the color of the receiver to that of the specified object.</p>
	 */
	public function takeColorFrom(sender:Object):Void {
		if (ASUtils.respondsToSelector(sender, "color")) {
			setColor(sender.color());
		}
	}
	
	private function takeColorFromPanel(ntf:NSNotification):Void {
		var sender:Object = ntf.object;
		if (ASUtils.respondsToSelector(sender, "color")) {
			m_color = sender.color();
			sendActionTo(action(), target());
			setNeedsDisplay(true);
		}
	}
	
	//******************************************************
	//*                Managing borders
	//******************************************************
	
	/**
	 * Returns a Boolean value indicating whether the receiver has a border.
	 */
	public function isBordered():Boolean {
		return m_isBordered;
	}
	
	/**
	 * Places or removes a border on the receiverand redraws the receiver.
	 */
	public function setBordered(flag:Boolean):Void {
		if (flag == m_isBordered) {
			return;
		}
		
		m_isBordered = flag;
		setNeedsDisplay(true);
	}
	
	public function isOpaque():Boolean {
		return m_isBordered;
	}
	
	//******************************************************
	//*                Target - action
	//******************************************************
	
	public function action():String {
		return m_action;
	}
	
	public function setAction(selector:String):Void {
		m_action = selector;
	}
	
	public function target():Object {
		return m_target;
	}
	
	public function setTarget(anObject:Object):Void {
		m_target = anObject;
	}
	
	//******************************************************
	//*                    Events
	//******************************************************
	
	public function mouseDown(event:NSEvent):Void {
		if (!isEnabled()) {
			return;
		}
		
		var point:NSPoint = convertPointFromView(event.mouseLocation, null);
		
		if (m_wellRect.pointInRect(point)) {
			NSColorPanel.dragColorWithEventFromView(m_color, event, this);
		}
		else if (!m_isActive) {
			activate(true);
		} else {
			deactivate();
		}
	}
	
	//******************************************************
	//*                    Drawing
	//******************************************************
	
	/**
	 * Draws the colored area inside the receiver at the specified location 
	 * without drawing borders.
	 */
	public function drawWellInside(insideRect:NSRect):Void {
		var g:ASGraphics = graphics();
		
		g.brushDownWithBrush(ASColors.blackColor());
		g.drawPolygonWithPoints([
			new NSPoint(insideRect.minX(), insideRect.minY()),
			new NSPoint(insideRect.maxX(), insideRect.minY()),
			new NSPoint(insideRect.minX(), insideRect.maxY())], null, null);
		g.brushUp();
		g.brushDownWithBrush(ASColors.whiteColor());
		g.drawPolygonWithPoints([
			new NSPoint(insideRect.maxX(), insideRect.minY()),
			new NSPoint(insideRect.maxX(), insideRect.maxY()),
			new NSPoint(insideRect.minX(), insideRect.maxY())], null, null);
		g.brushUp();
		g.brushDownWithBrush(m_color);
		g.drawRectWithRect(insideRect, null, null);
		g.brushUp();
	}
	
	/**
	 * Draws the view.
	 */
	public function drawRect(aRect:NSRect):Void {
		graphics().clear();
				
		var borderWidth:Number = ASTheme.current(
			).drawColorWellBorderWithRectInWell(aRect, this);
		m_wellRect = aRect.insetRect(borderWidth, borderWidth);
				
		drawWellInside(m_wellRect);
	}
	
	//******************************************************															 
	//             Dragging source stuff
	//******************************************************
	
	/**
	 * <p>Returns a copy mask.</p>
	 */
	public function draggingSourceOperationMask():Number {
		return NSDragOperation.NSDragOperationCopy.value;
	}

	/**
	 * Returns <code>false</code>
	 */
	public function ignoreModifierKeysWhileDragging():Boolean {
		return false;
	}
	
	/**
	 * <p>Does nothing</p>
	 */
	public function draggedImageBeganAt(anImage:NSImage, aPoint:NSPoint):Void {
	}
	
	/**
	 * <p>Does nothing</p>
	 */
	public function draggedImageEndedAtOperation(anImage:NSImage, aPoint:NSPoint,
		operation:NSDragOperation):Void {		
	}
		
	/**
	 * <p>Does nothing</p>
	 */
	public function draggedImageMovedTo(anImage:NSImage, aPoint:NSPoint):Void {
	}
	
	//******************************************************
	//*              Dragging destination
	//******************************************************
		
	public function draggingEntered(sender:NSDraggingInfo):NSDragOperation {
		return NSDragOperation.NSDragOperationCopy;
	}
	
	public function draggingUpdated(sender:NSDraggingInfo):NSDragOperation {
		return NSDragOperation.NSDragOperationCopy;
	}
		
	/**
	 * Always returns <code>true</code>.
	 */
	public function prepareForDragOperation(sender:NSDraggingInfo):Boolean {
		return true;
	}
	
	/**
	 * Copies the dragging pasteboard's color to this well
	 */
	public function performDragOperation(sender:NSDraggingInfo):Boolean {
		var c:NSColor = NSColor(sender.draggingPasteboard().dataForType(
			NSPasteboard.NSColorPboardType));
		setColor(c);
		return true;
	}
	
	//******************************************************
	//*                 Notifications
	//******************************************************
	
	public static var ASColorWellDidBecomeExclusiveNotification:Number =
		ASUtils.intern("ASColorWellDidBecomeExclusiveNotification");
}