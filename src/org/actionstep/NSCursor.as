/* See LICENSE for copyright and terms of use */

import org.actionstep.cursor.ASSystemArrowCursor;
import org.actionstep.NSApplication;
import org.actionstep.NSColor;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSPoint;
import org.actionstep.NSSize;
import org.actionstep.themes.ASThemeImageNames;

/**
 * <p>Represents a cursor. Cursors can be displayed over specific regions of any
 * subclass of {@link org.actionstep.NSView} (see 
 * {@link org.actionstep.NSView#addCursorRectCursor}).</p>
 *
 * <p>Instances of this class are immutable. You cannot change their hotspots or images
 * after creation.</p>
 * 
 * <p>For examples of this class' usage, please see 
 * {@link org.actionstep.test.ASTestCursors}.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSCursor extends org.actionstep.NSObject
{	
	private static var g_cursorStack:Array = [];;
	private static var g_hiddenUntilMouseMove:Boolean = false;
	private static var g_useSystemArrow:Boolean = true;
	
	private static var g_arrowCursor:NSCursor;
	private static var g_systemArrowCursor:NSCursor;
	private static var g_closedHandCursor:NSCursor;
	private static var g_crosshairCursor:NSCursor;
	private static var g_disappearingItemCursor:NSCursor;
	private static var g_IBeamCursor:NSCursor;
	private static var g_openHandCursor:NSCursor;
	private static var g_pointingHandCursor:NSCursor;
	private static var g_resizeDownCursor:NSCursor;
	private static var g_resizeLeftCursor:NSCursor;
	private static var g_resizeLeftRightCursor:NSCursor;
	private static var g_resizeRightCursor:NSCursor;
	private static var g_resizeUpCursor:NSCursor;
	private static var g_resizeUpDownCursor:NSCursor;
	private static var g_resizeDiagonalDownCursor:NSCursor;
	private static var g_resizeDiagonalUpCursor:NSCursor;
	
	private var m_image:NSImage;
	private var m_hotSpot:NSPoint;
	private var m_foregroundColorHint:NSColor;
	private var m_backgroundColorHint:NSColor;
	
	//******************************************************															 
	//*                    Construction
	//******************************************************
	
	/**
	 * Constructs a new instance of <code>NSCursor</code>.
	 */
	public function NSCursor()
	{
	}
	
	
	/**
	 * Initializes a newly created <code>NSCursor</code> with an image, a 
	 * hotspot and foreground and background color hints. 
	 * (//! FIXME WHAT is a colour hint???)
	 */
	public function initWithImageForegroundColorHintBackgroundColorHintHotSpot
		(newImage:NSImage, foregroundColorHint:NSColor, backgroundColorHint:NSColor, 
		hotSpot:NSPoint):NSCursor
	{
		initWithImageHotSpot(newImage, hotSpot);
		m_foregroundColorHint = foregroundColorHint;
		m_backgroundColorHint = backgroundColorHint;
		
		return this;
	}
	
	
	/**
	 * Initializes a newly created <code>NSCursor</code> with an image and a 
	 * hotSpot.
	 *
	 * @see org.actionstep.NSCursor#hotSpot()
	 * @see org.actionstep.NSCursor#image()
	 */
	public function initWithImageHotSpot(newImage:NSImage, hotSpot:NSPoint):NSCursor
	{
		m_image = newImage;
		m_hotSpot = hotSpot;
		
		return this;
	}
	
	//******************************************************															 
	//*                    Properties
	//******************************************************
	
	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String 
	{
		return "NSCursor(hotSpot=" + hotSpot() + ", image=" + image() + ")";
	}
	
	
	/**
	 * Returns this cursor's hotspot. If the cursor's image's hit area overlaps
	 * this point, the cursor will become visible.
	 */
	public function hotSpot():NSPoint
	{
		return m_hotSpot;
	}
	
	
	/**
	 * <p>Returns this cursor's image.</p>
	 *
	 * <p>The size of this image determines when the cursor will be shown. If the
	 * image's rect overlaps {@link #hotSpot()}.</p>
	 */
	public function image():NSImage
	{
		return m_image;
	}
	
	//******************************************************															 
	//*           Cursor Stack Manipulation
	//******************************************************
	
	/**
	 * <p>Pops the current cursor off of NSCursor stack.</p> 
	 *
	 * <p>Note that in Objective-C, this method is called -(void) pop(). Since
	 * we can't have a class method named the same as an instance method,
	 * we've changed its name.</p>
	 *
	 * @see NSCursor#pop
	 */
	public function popCursor():Void
	{
		NSCursor.pop();
	}
	
	
	/**
	 * Pushes this cursor on to the top of the cursor stack. This cursor will
	 * be displayed immediately.
	 */
	public function push():Void
	{
		NSCursor(g_cursorStack[g_cursorStack.length - 1]).cursorDidHide();
		g_cursorStack.push(this);
		draw();
	}
	
	
	/**
	 * <p>Sets this cursor to be the current cursor.</p>
	 *
	 * <p>Note that in Objective-C, this method is called -(void) set(). Since
	 * set is a reserved word in actionscript, this method name has been
	 * changed for the ActionStep implementation.</p>
	 */
	public function setSelf():Void
	{
		if (g_cursorStack.length == 1)
			return;
			
		g_cursorStack[g_cursorStack.length - 1] = this;
		draw();
	}
	
	/**
	 * Called when the cursor is popped off the stack. By default this does
	 * nothing.
	 */
	private function cursorDidHide():Void
	{	
	}
	
	//******************************************************															 
	//*                Mouse Event Handling
	//******************************************************
	
	/**
	 * Fired when the mouse rolls onto a tracking rect associated with this
	 * cursor.
	 */
	public function mouseEntered(event:NSEvent):Void
	{
		if (current() == this) {
			return;
		}
		
		this.push();
	}
	
	/**
	 * Fired when the mouse rolls off a tracking rect associated with this
	 * cursor.
	 */
	public function mouseExited(event:NSEvent):Void
	{
		this.popCursor();
	}
	
	//******************************************************															 
	//*                  Private Methods
	//******************************************************
	
	/**
	 * Draws the cursor in the cursor clip.
	 */
	private function draw():Void 
	{
		var mc:MovieClip = cursorClip();
		mc.cacheAsBitmap = false;
		mc.clear();
		
		m_image.lockFocus(mc);
		m_image.drawAtPoint(new NSPoint(-m_hotSpot.x, -m_hotSpot.y));
		m_image.unlockFocus();
		mc.cacheAsBitmap = true; //! Not sure if we should do this.
	}
	
	//******************************************************															 
	//*            Class Properties - Cursors
	//******************************************************
	
	/**
	 * Returns the current cursor.
	 */
	public static function current():NSCursor
	{
		return NSCursor(g_cursorStack[g_cursorStack.length - 1]);
	}
	
	
	/**
	 * Returns the default arrow cursor. Hotspot at the tip.
	 */
	public static function arrowCursor():NSCursor	
	{
		return g_arrowCursor;
	}
	
	
	/**
	 * Returns the closed hand cursor.
	 */
	public static function closedHandCursor():NSCursor
	{
		return g_closedHandCursor;
	}
	
	
	/**
	 * Returns the cross-hair cursor, used when precision is necessary.
	 */
	public static function crosshairCursor():NSCursor
	{
		return g_crosshairCursor;
	}
	
	
	/**
	 * Returns a cursor that displays an item disappearing.
	 */
	public static function disappearingItemCursor():NSCursor
	{
		return g_disappearingItemCursor;
	}	

	
	/**
	 * Returns the cursor used when hovering over text. It is used to
	 * specify the insertion point when clicking on text. The hotspot is
	 * where the I meets the top crossbeam.
	 */
	public static function IBeamCursor():NSCursor
	{
		return g_IBeamCursor;
	}
	
	
	/**
	 * Returns the open hand cursor.
	 */
	public static function openHandCursor():NSCursor
	{
		return g_openHandCursor;
	}
	
	
	/**
	 * Returns the pointing hand cursor.
	 */
	public static function pointingHandCursor():NSCursor
	{
		return g_pointingHandCursor;
	}


	/**
	 * Returns the resize-down cursor.
	 */
	public static function resizeDownCursor():NSCursor
	{
		return g_resizeDownCursor;
	}
	

	/**
	 * Returns the resize-left cursor.
	 */	
	public static function resizeLeftCursor():NSCursor
	{
		return g_resizeLeftCursor;
	}
	

	/**
	 * Returns the resize-left-and-right cursor.
	 */	
	public static function resizeLeftRightCursor():NSCursor
	{
		return g_resizeLeftRightCursor;
	}
	
	
	/**
	 * Returns the resize-right cursor.
	 */	
	public static function resizeRightCursor():NSCursor
	{
		return g_resizeRightCursor;
	}
	
	
	/**
	 * Returns the resize-up cursor.
	 */	
	public static function resizeUpCursor():NSCursor
	{
		return g_resizeUpCursor;
	}	
	
	
	/**
	 * Returns the resize-up-and-down cursor.
	 */	
	public static function resizeUpDownCursor():NSCursor
	{
		return g_resizeUpDownCursor;
	}
	
	
	/**
	 * <p>Returns the resize-diagonal down cursor. It is sloped like "\".</p>
	 * 
	 * <p>This is an actionstep method.</p>
	 */	
	public static function resizeDiagonalDownCursor():NSCursor
	{
		return g_resizeDiagonalDownCursor;
	}
	
	
	/**
	 * <p>Returns the resize-diagonal up cursor. It is sloped like "/".</p>
	 * 
	 * <p>This is an actionstep method.</p>
	 */	
	public static function resizeDiagonalUpCursor():NSCursor
	{
		return g_resizeDiagonalUpCursor;
	}
	
	//******************************************************															 
	//*            Class Methods - Cursor Stack
	//******************************************************
		
	public static function pop():Void
	{
		if (g_cursorStack.length == 1)
			return;
		
		var last:NSCursor = NSCursor(g_cursorStack.pop());
		last.cursorDidHide();
		NSCursor(g_cursorStack[g_cursorStack.length - 1]).draw();
	}
	
	//******************************************************															 
	//*     Class Methods - Current Cursor Visibility
	//******************************************************
	
	/**
	 * <p>Returns <code>true</code> if the mouse cursor is hidden, or
	 * <code>false</code> otherwise.</p>
	 * 
	 * <p>This is an ActionStep only method.</p>
	 */
	public static function isHidden():Boolean
	{
		return !cursorClip()._visible;
	}
	
	/**
	 * Hides the current cursor.
	 */
	public static function hide():Void
	{
		 cursorClip()._visible = false;
	}
	
	
	/**
	 * Unhides the current cursor.
	 */
	public static function unhide():Void
	{
		if (!g_hiddenUntilMouseMove) {
		  cursorClip()._visible = true;
		}
	}
	
	/**
	 * <p>If <code>flag</code> is <code>true</code>, a call to this method hides
	 * the current cursor until the mouse moves or the method is called again 
	 * with <code>flag</code> as <code>false</code>.</p>
	 *
	 * <p>{@link #unhide()} will not counter the effects of this method call.</p>
	 */
	public static function setHiddenUntilMouseMoves(flag:Boolean):Void
	{
		g_hiddenUntilMouseMove = flag;
		
		if (flag) 
		{
			hide();
		}
		else
		{
			unhide();
		}
	}
	
	//******************************************************															 
	//*           Using the system arrow cursor
	//******************************************************
	
	/**
	 * <p>Returns <code>true</code> if the arrow cursor used is the system
	 * cursor, or <code>false</code> if arrow cursor used is
	 * {@link NSCursor#arrowCursor}.</p>
	 * 
	 * <p>The default is <code>true</code>.</p>
	 */
	public static function useSystemArrowCursor():Boolean 
	{
		return g_useSystemArrow;
	}
	
	/**
	 * <p>Sets whether the arrow cursor used is the system arrow cursor. If 
	 * <code>true</code>, the system arrow cursor will be used, or 
	 * <code>false</code> if the ActionStep arrow cursor should be used.</p>
	 * 
	 * <p>The default is <code>true</code>.</p>
	 */
	public static function setUseSystemArrowCursor(flag:Boolean):Void
	{
		if (g_useSystemArrow == flag) {
			return;
		}
		
		g_useSystemArrow = flag;
		
		var newCursor:NSCursor = flag ? g_systemArrowCursor : g_arrowCursor;
		var oldCursor:NSCursor = g_cursorStack[0];

		if (current() == oldCursor)
		{
			g_cursorStack.splice(0, 0, newCursor);
			pop();
		}
		
		g_cursorStack[0] = newCursor;
	}
	
	//******************************************************															 
	//*              Private Class Methods
	//******************************************************

	/**
	 * Returns the clip on which cursors are drawn.
	 */
	private static function cursorClip():MovieClip
	{
		return NSApplication.sharedApplication().cursorClip();
	}
		
	//******************************************************															 
	//*                 Class Constructor
	//******************************************************
	
	private static var g_classConstructed:Boolean;
	
	/**
	 * Registers all the cursors.
	 * 
	 * Run automatically when NSApplication is created.
	 */
	private static function initialize():Void
	{
		if (g_classConstructed)
			return;
		
		//
		// Hide the mouse
		//
		Mouse.hide();
		
		//
		// Create cursors
		//
		var sz:NSSize;
		
		g_arrowCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSArrowCursorRepImage), 
			NSPoint.ZeroPoint);			

		g_systemArrowCursor = NSCursor((new ASSystemArrowCursor()).init());		
		
		sz = NSImage.imageNamed(ASThemeImageNames.NSCrosshairCursorRepImage)
			.bestRepresentationForDevice().size();
		g_crosshairCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSCrosshairCursorRepImage), 
			new NSPoint(sz.width / 2, sz.height / 2));		
			
		sz = NSImage.imageNamed(ASThemeImageNames.NSResizeLeftCursorRepImage)
			.bestRepresentationForDevice().size();
		g_resizeLeftCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSResizeLeftCursorRepImage), 
			new NSPoint(sz.width / 2, sz.height / 2));	
			
		sz = NSImage.imageNamed(ASThemeImageNames.NSResizeLeftRightCursorRepImage)
			.bestRepresentationForDevice().size();
		g_resizeLeftRightCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSResizeLeftRightCursorRepImage), 
			new NSPoint(sz.width / 2, sz.height / 2));	
		
		sz = NSImage.imageNamed(ASThemeImageNames.NSResizeRightCursorRepImage)
			.bestRepresentationForDevice().size();	
		g_resizeRightCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSResizeRightCursorRepImage), 
			new NSPoint(sz.width / 2, sz.height / 2));	
			
		sz = NSImage.imageNamed(ASThemeImageNames.NSResizeDownCursorRepImage)
			.bestRepresentationForDevice().size();
		g_resizeDownCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSResizeDownCursorRepImage), 
			new NSPoint(sz.width / 2, sz.height / 2));	

		sz = NSImage.imageNamed(ASThemeImageNames.NSResizeUpCursorRepImage)
			.bestRepresentationForDevice().size();
		g_resizeUpCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSResizeUpCursorRepImage), 
			new NSPoint(sz.width / 2, sz.height / 2));	

		sz = NSImage.imageNamed(ASThemeImageNames.NSResizeUpDownCursorRepImage)
			.bestRepresentationForDevice().size();
		g_resizeUpDownCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSResizeUpDownCursorRepImage), 
			new NSPoint(sz.width / 2, sz.height / 2));	
		
		sz = NSImage.imageNamed(ASThemeImageNames.NSResizeDiagonalUpCursorRepImage)
			.bestRepresentationForDevice().size();
		g_resizeDiagonalUpCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSResizeDiagonalUpCursorRepImage), 
			new NSPoint(sz.width / 2, sz.height / 2));
						
		sz = NSImage.imageNamed(ASThemeImageNames.NSResizeDiagonalDownCursorRepImage)
			.bestRepresentationForDevice().size();
		g_resizeDiagonalDownCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSResizeDiagonalDownCursorRepImage), 
			new NSPoint(sz.width / 2, sz.height / 2));		
			
		sz = NSImage.imageNamed(ASThemeImageNames.NSClosedHandCursorRepImage)
			.bestRepresentationForDevice().size();
		g_closedHandCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSClosedHandCursorRepImage), 
			new NSPoint(sz.width / 2, sz.height / 2));
		
		sz = NSImage.imageNamed(ASThemeImageNames.NSOpenHandCursorRepImage)
			.bestRepresentationForDevice().size();		
		g_openHandCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSOpenHandCursorRepImage), 
			new NSPoint(sz.width / 2, sz.height / 2));
			
		sz = NSImage.imageNamed(ASThemeImageNames.NSIBeamCursorRepImage)
			.bestRepresentationForDevice().size();
		g_IBeamCursor = (new NSCursor()).initWithImageHotSpot(
			NSImage.imageNamed(ASThemeImageNames.NSIBeamCursorRepImage), 
			new NSPoint(sz.width / 2, sz.height / 2));	

//		g_disappearingItemCursor = (new NSCursor()).initWithImageHotSpot(
//			NSImage.imageNamed("NSDisappearingItemCursorRep"), NSPoint.ZeroPoint);	
					
//		g_pointingHandCursor = (new NSCursor()).initWithImageHotSpot(
//			NSImage.imageNamed("NSPointingHandCursorRep"), NSPoint.ZeroPoint);	

		//
		// Push the standard arrow cursor onto the stack.
		//	
		if (g_useSystemArrow) 
		{
			g_systemArrowCursor.push();
		}
		else
		{
			g_arrowCursor.push();
		}
		
		g_classConstructed = true;
	}
}
