/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.NSDraggingSource;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSPasteboard;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSResponder;
import org.actionstep.NSSize;
import org.actionstep.NSWindow;
import org.aib.controls.EditableViewProtocol;
import org.aib.inspector.InspectorProtocol;
import org.aib.SelectionManager;
import org.aib.stage.GuideManager;

/**
 * Decorates editable views by overriding their event handling functions.
 * 
 * @author Scott Hyndman
 */ 
class org.aib.controls.EditableViewDecorator extends NSResponder
		implements EditableViewProtocol { 
	
	//******************************************************															 
	//*                  Class members
	//******************************************************
	
	private static var g_instance:EditableViewDecorator;
	
	//******************************************************															 
	//*         Member variables (for type checking)
	//******************************************************
	
	private var __trackingData:Object;
	private var __isResizing:Boolean;
	private var __origFrameDidChange:Function;
	private var __trackingId:Number;
	private var __frameLocked:Boolean;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	/**
	 * Constructs a new instance of the <code>EditableViewDecorator</code>
	 * class.
	 */
	private function EditableViewDecorator() {
	}
	
	//******************************************************															 
	//*               To satisfy type checks
	//******************************************************
	
	public function className():String {
		return null;
	}
	public function supportsInspector(inspector:InspectorProtocol):Boolean {
		return true;
	}
	public function shouldSelect(event:NSEvent):Boolean {
		return null;
	}
	public function shouldReceiveMouseDown(event:NSEvent):Boolean {
		return null;
	}
	public function willReceiveMouseDown(event:NSEvent):Void {
	}
	public function hasReceivedMouseDown(event:NSEvent):Void {
	}
	public function showsResizeHandles():Boolean {
		return true;
	}
	public function resizeUmask():Number {
		return 0;
	}
	public function window():NSWindow {
		return null;
	}
	public function convertPointFromView(pt:NSPoint, obj:Object):NSPoint {
		return null;
	}
	public function dragImageAtOffsetEventPasteboardSourceSlideBack(
		image:NSImage, imageLoc:NSPoint, offset:NSSize, event:NSEvent, 
		pasteboard:NSPasteboard, source:NSDraggingSource, slideBack:Boolean)
		:Void {
	}
	public function removeFromSuperview():Void {
	}
	public function frame():NSRect {
		return null;
	}
	
	public function frameSize():NSSize {
		return null;
	}
	public function setFrameOrigin(pt:NSPoint):Void {
	}
	public function addTrackingRectOwnerUserDataAssumeInside(aRect:NSRect,
			owner:Object, userData:Object, flag:Boolean):Number {
		return null;
	}
	public function removeTrackingRect(aTag:Number):Void {
	}
	
	//******************************************************
	//*                 Resizing methods
	//******************************************************
	
	/**
	 * Decorated into view classes.
	 */
	public function isUserResizing():Boolean {
		return __isResizing;
	}
	
	/**
	 * Decorated into view classes.
	 */
	public function setUserResizing(flag:Boolean):Void {
		__isResizing = flag;
	}
	
	/**
	 * Returns <code>true</code> if the view's frame is locked.
	 */
	public function isFrameLocked():Boolean {
		return __frameLocked;
	}
	
	/**
	 * Sets whether the view's frame is locked.
	 */
	public function setFrameLocked(flag:Boolean):Void {
		__frameLocked = flag;
	}
	
	//******************************************************															 
	//*             Overridden event handlers
	//******************************************************
	
	/**
	 * The mouse down handler that is used by all editable controls.
	 */
	public function mouseDown(event:NSEvent):Void {
		if (isUserResizing()) {
			if(m_nextResponder!=undefined) {
				m_nextResponder.mouseDown(event);
			} else {
				noResponderFor("mouseDown");
			}
			return;
		}
			
		if (!shouldReceiveMouseDown(event)) {
			if (shouldSelect(event)) {
				SelectionManager.instance().selectViewWithEvent(this, event);
			}
			return;
		}
		
		willReceiveMouseDown(event);
		
		//
		// Select this view
		//
		SelectionManager.instance().selectViewWithEvent(this, event);
		
		hasReceivedMouseDown(event);
	}
	
	/**
	 * Overridden to add deletion and movement support to views.
	 */
	public function keyDown(event:NSEvent):Void {
		if (m_nextResponder != undefined) {
			m_nextResponder.keyDown(event);
		} else {
			noResponderFor("keyDown");
		}
	}
	
	/**
	 * Always returns <code>true</code>.
	 */
	public function acceptsFirstResponder():Boolean {
		return true;
	}
  
	/**
	 * Always returns <code>true</code>.
	 */
	public function becomesFirstResponder():Boolean {
		return true;
	}
	
	/**
	 * Always returns <code>true</code>.
	 */
	public function canBecomeKeyView():Boolean {
		return true;
	}
	
	/**
	 * Overridden to register tracking rects.
	 */	
	private function frameDidChange(oldFrame:NSRect):Void {
		removeTrackingRect(__trackingId);
		__trackingId = addTrackingRectOwnerUserDataAssumeInside(
			NSRect.withOriginSize(NSPoint.ZeroPoint, frameSize()),
			GuideManager.instance(),
			this,
			false);
		__origFrameDidChange(oldFrame);
	}
	
	//******************************************************															 
	//*                 Decorating views
	//******************************************************
	
	/**
	 * Decorates all the views in the package <code>package</code>.
	 */
	public static function decorateViewsWithPackage(package:Object):Void {
		for (var className:String in package) {
			//
			// Don't decorate this class or any protocols.
			//
			if (className == "EditableViewDecorator"
					|| className.toLowerCase().indexOf("protocol") != -1) {
				continue;
			}
			
			var cls:Function = Function(package[className]);
			
			if (cls.doNotDecorate) {
				continue;
			}
			
			//
			// Create an instance to test whether it implements the
			// protocol.
			//
			var instance:Object = ASUtils.createInstanceOf(cls, []);
			
			if (!(instance instanceof EditableViewProtocol)) {
				continue;
			}
			
			decorateViewClass(cls);
		}
	}
	
	/**
	 * Decorates the <code>cls</code> view class.
	 * 
	 * <code>cls</code> should be the constructor function of the view class
	 * to decorate.
	 */
	public static function decorateViewClass(cls:Function):Void {
		var p:Object = cls.prototype;
		p.mouseDown = g_instance.mouseDown;
		p.keyDown = g_instance.keyDown;
		p.acceptsFirstResponder = g_instance.acceptsFirstResponder;
		p.becomesFirstResponder = g_instance.becomesFirstResponder;
		p.canBecomeKeyView = g_instance.canBecomeKeyView;
		p.isUserResizing = g_instance.isUserResizing;
		p.setUserResizing = g_instance.setUserResizing;
		p.isFrameLocked = g_instance.isFrameLocked;
		p.setFrameLocked = g_instance.setFrameLocked;
		p.__frameLocked = false;
		p.__origFrameDidChange = p.frameDidChange;
		p.frameDidChange = g_instance.frameDidChange;
	}
	
	//******************************************************															 
	//*                Static constructor
	//******************************************************
	
	/**
	 * Static constructor. Creates necessary static members.
	 */
	private static function classConstruct():Boolean {
		if (g_classConstructed) {
			return true;
		}
		
		g_instance = new EditableViewDecorator();
		g_instance.init();
		
		return true;
	}
	
	private static var g_classConstructed:Boolean = classConstruct();
}