/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSDraggingSource;
import org.actionstep.NSImage;
import org.actionstep.NSObject;
import org.actionstep.NSPasteboard;
import org.actionstep.NSPoint;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.ASAnimation;
import org.actionstep.constants.NSAnimationCurve;

/**
 * <p>Provides information about a dragging session.</p>
 *
 * <p>In Cocoa, this is an interface, but one that you never have to implement.
 * The strangeness of this leads me to believe that we can just use a class
 * instead, so no one has to worry about it.</p>
 *
 * @see org.actionstep.NSDraggingSource
 * @see org.actionstep.NSDraggingDestination
 * @see org.actionstep.NSView#dragImageAtOffsetEventPasteboardSourceSlideBack
 * @author Scott Hyndman
 */
class org.actionstep.NSDraggingInfo extends NSObject
{
	private static var g_sequenceCnt:Number = 0;
	private var m_src:NSDraggingSource;
	private var m_destWindow:NSWindow;
	private var m_pasteBrd:NSPasteboard;
	private var m_sequenceNo:Number;
	private var m_image:NSImage;
	private var m_imageLocation:NSPoint;
	private var m_offset:NSSize;
	private var m_slideBack:Boolean;

	//******************************************************
	//*                  Constructor
	//******************************************************

	/**
	 * Should never be directly invoked.
	 */
	private function NSDraggingInfo()
	{
	}

	//******************************************************
	//*           Dragging-session information
	//******************************************************

	/**
	 * Returns the source of the dragged data.
	 */
	public function draggingSource():NSDraggingSource
	{
		return m_src;
	}

	/**
	 * Returns the dragging source operation mask created by bitwise or-ing
	 * constants as defined in {@link org.actionstep.constants.NSDragOperation}.
	 */
	public function draggingSourceOperationMask():Number
	{
		return m_src.draggingSourceOperationMask();
	}

	/**
	 * Returns the destination window for the drag operation. The destination
	 * can be the window itself, or a view contained within the window.
	 */
	public function draggingDestinationWindow():NSWindow
	{
		return m_destWindow;
	}

	/**
	 * For internal use only.
	 */
	public function setDraggingDestinationWindow(wnd:NSWindow):Void {
		m_destWindow = wnd;
	}

	/**
	 * Returns the paste board that contains the data being dragged.
	 */
	public function draggingPasteboard():NSPasteboard
	{
		return m_pasteBrd;
	}

	/**
	 * Returns a number that uniquely identifies this dragging session.
	 */
	public function draggingSequenceNumber():Number
	{
		return m_sequenceNo;
	}

	/**
	 * Returns the current location of the mouse in the base coordinates of
	 * the destination object's window.
	 */
	public function draggingLocation():NSPoint
	{
		return m_destWindow.convertBaseToScreen(
			new NSPoint(_root._xmouse, _root._ymouse));
	}

	/**
	 * Returns the dragging offset.
	 */
	public function draggingOffset():NSSize {
		return m_offset.clone();
	}

	//******************************************************
	//*                Image information
	//******************************************************

	/**
	 * Returns the image being dragged.
	 */
	public function draggedImage():NSImage
	{
		return m_image;
	}

	/**
	 * Returns the origin of the image being dragged in the destination
	 * window's base coordinate system.
	 */
	public function draggedImageLocation():NSPoint
	{
		return m_imageLocation;
	}

	//******************************************************
	//*                Sliding the image
	//******************************************************

	/**
	 * Returns true if the image should slide back to the source.
	 */
	public function slideBack():Boolean
	{
		return m_slideBack;
	}

	private var m_slidebackClip:MovieClip;
	private var m_slidebackDest:NSPoint;
	private var m_xAnim:ASAnimation;
	private var m_yAnim:ASAnimation;

	private var m_xAnimInfo:Object;
	private var m_yAnimInfo:Object;

	/**
	 * Slides the image to <code>aPoint</code> (screen coordinates).
	 */
	public function slideDraggedImageTo(aPoint:NSPoint):Void
	{
		var app:NSApplication = NSApplication.sharedApplication();

		//
		// Clear the dragging clip
		//
		app.draggingClip().clear();

		//
		// Record the source and destination
		//
		var currPt:NSPoint = new NSPoint(_root._xmouse, _root._ymouse);
		m_slidebackDest = aPoint.clone();

		//
		// Move the image over to the slide back window
		//
		var clip:MovieClip = app.draggingSlideBackClip();
		var depth:Number = clip.getNextHighestDepth();
		m_slidebackClip = clip.createEmptyMovieClip("__slideback" + depth, depth);
		m_slidebackClip._x = currPt.x;
		m_slidebackClip._y = currPt.y;
		m_image.lockFocus(m_slidebackClip);
		m_image.drawAtPoint(new NSPoint(m_offset.width, m_offset.height));
		m_image.unlockFocus();

		//
		// Create the animations
		//
		m_xAnimInfo = {begin: currPt.x, change: m_slidebackDest.x - currPt.x};
		m_xAnim = (new ASAnimation()).initWithDurationAnimationCurve(
			3, NSAnimationCurve.NSEaseInOut);
		m_xAnim.setDelegate(this);
		m_yAnimInfo = {begin: currPt.y, change: m_slidebackDest.y - currPt.y};
		m_yAnim = (new ASAnimation()).initWithDurationAnimationCurve(
			3, NSAnimationCurve.NSEaseInOut);
		m_yAnim.setDelegate(this);

		trace([m_slidebackDest, currPt]);

		m_xAnim.startAnimation();
		m_yAnim.startAnimation();
	}

	//******************************************************
	//*              NSAnimation delegate
	//******************************************************

	private function animationDidAdvance(animation:ASAnimation):Void {
		if (animation == m_xAnim) {
			m_slidebackClip._x = m_xAnimInfo.begin + m_xAnimInfo.change * animation.currentValue();
		} else {
			m_slidebackClip._y = m_yAnimInfo.begin + m_yAnimInfo.change * animation.currentValue();
		}
	}

	private function animationDidEnd(animation:ASAnimation):Void {
		m_slidebackClip.removeMovieClip();
		animation.release();
	}

	//******************************************************
	//*                Helper Methods
	//*           (For internal use only)
	//******************************************************

	/**
	 * Returns <code>true</code> if <code>aView</code> is registered to handle
	 * the data contained in this dragging info's pasteboard.
	 */
	public function doesViewHandleTypes(aView:NSView):Boolean
	{
		var viewTypes:NSArray = aView.registeredDraggedTypes();
		var pbTypes:Array = m_pasteBrd.types().internalList();

		var len:Number = pbTypes.length;
		for (var i:Number = 0; i < len; i++)
		{
			if (!viewTypes.containsObject(pbTypes[i])) {
				return false;
			}
		}

		return true;
	}

	//******************************************************
	//*              Static Constructors
	//******************************************************

	public static function draggingInfoWithImageAtOffsetPasteboardSourceSlideBack(
		image:NSImage, imageLoc:NSPoint, offset:NSSize, pasteboard:NSPasteboard,
		source:NSDraggingSource, slideBack:Boolean):NSDraggingInfo
	{
		var info:NSDraggingInfo = new NSDraggingInfo();
		info.m_image = image;
		info.m_imageLocation = imageLoc;
		info.m_offset = offset;
		info.m_pasteBrd = pasteboard;
		info.m_src = source;
		info.m_slideBack = slideBack;
		info.m_sequenceNo = g_sequenceCnt++;

		return info;
	}
}