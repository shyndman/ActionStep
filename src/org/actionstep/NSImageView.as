/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSDragOperation;
import org.actionstep.constants.NSImageAlignment;
import org.actionstep.constants.NSImageFrameStyle;
import org.actionstep.constants.NSImageScaling;
import org.actionstep.NSArray;
import org.actionstep.NSControl;
import org.actionstep.NSDraggingInfo;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSImageCell;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPasteboard;
import org.actionstep.NSRect;

/**
 * This class displays a single <code>NSImage</code> in a frame. It has the 
 * ability to scale and align the image. A user can also drag images into this 
 * view to change the <code>NSImage</code> it displays.
 * 
 * This class uses an instance of <code>NSImageCell</code> to display its
 * contents.
 * 
 * For an example of this class' usage, please see
 * <code>org.actionstep.test.ASTestImages</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSImageView extends NSControl {
	
	/** The cell class used by this control. */
	private static var g_cellClass:Function = org.actionstep.NSImageCell;
	
	private var m_editable:Boolean;
	private var m_animates:Boolean;
	private var m_allowsCutCopyPaste:Boolean;
	private var m_trackingData:Object;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of <code>NSImageView</code>.
	 */
	public function NSImageView() {
		super();
		
		m_animates = true;
		m_allowsCutCopyPaste = false;
	}

	/**
	 * Overridden to supply defaults to the cell.
	 */
	public function initWithFrame(theFrame:NSRect):NSImageView 
	{
		super.initWithFrame(theFrame);
		
		setImageAlignment(NSImageAlignment.NSImageAlignCenter);
		setImageScaling(NSImageScaling.NSScaleNone);
		setImageFrameStyle(NSImageFrameStyle.NSImageFrameNone);
		
		return this;
	}
	
	//******************************************************															 
	//*                 Choosing the image
	//******************************************************
	
	/**
	 * Returns the image displayed by this image view.
	 */
	public function image():NSImage
	{
		return NSImageCell(m_cell).image();
	}
	
	/**
	 * Sets the image displayed by this image view.
	 */
	public function setImage(anImage:NSImage):Void {
		NSImageCell(m_cell).setImage(anImage);
		setNeedsDisplay(true);
	}
	
	//******************************************************
	//*          Getting the image rectangle
	//******************************************************
	
	/**
	 * Returns the rectangle in which this view's image is drawn.
	 */
	public function imageRect():NSRect {
		return NSImageCell(m_cell).imageRect();
	}
	
	//******************************************************															 
	//*                 Event handlers
	//******************************************************
	
	/**
	 * Fired when this image view's image loads.
	 */
	private function imageDidLoad(ntf:NSNotification):Void
	{
		setNeedsDisplay(true);
	}
	
	//******************************************************															 
	//*                 Common Properties
	//******************************************************
	
	/**
	 * Returns a string representation of the image view.
	 */
	public function description():String
	{
		return "NSImageView(frame=" + frame() + ", image=" + image() + ")";	
	}
		
	//******************************************************															 
	//*                Choosing the frame
	//******************************************************
	
	/**
	 * Returns the type of frame that borders the image.
	 */
	public function imageFrameStyle():NSImageFrameStyle
	{
		return NSImageCell(m_cell).imageFrameStyle();		
	}
	
	/**
	 * Sets the type of frame that borders the image to <code>frameStyle</code>.
	 */
	public function setImageFrameStyle(frameStyle:NSImageFrameStyle):Void
	{
		NSImageCell(m_cell).setImageFrameStyle(frameStyle);
	}
	
	//******************************************************															 
	//*           Aligning and scaling the image
	//******************************************************
	
	/**
	 * Returns the position of the image within the frame.
	 */
	public function imageAlignment():NSImageAlignment
	{
		return NSImageCell(m_cell).imageAlignment();
	}
	
	/**
	 * Sets the position of the image within the frame to
	 * <code>alignment</code>.
	 */
	public function setImageAlignment(alignment:NSImageAlignment):Void
	{
		NSImageCell(m_cell).setImageAlignment(alignment);
	}
	
	/**
	 * Returns the way the image will alter to fit the frame.
	 */
	public function imageScaling():NSImageScaling
	{
		return NSImageCell(m_cell).imageScaling();
	}
	
	/**
	 * Sets the way the image will alter to fit the frame to
	 * <code>scaling</code>.
	 */
	public function setImageScaling(scaling:NSImageScaling):Void
	{
		NSImageCell(m_cell).setImageScaling(scaling);
	}
	
	//******************************************************															 
	//*            Responding to user events
	//******************************************************
	
	/**
	 * Returns whether a new image can be dragged into the frame.
	 * 
	 * The default is <code>true</code>.
	 */
	public function isEditable():Boolean 
	{
		return m_editable;
	}
	
	/**
	 * Sets whether a new image can be dragged into the frame. If 
	 * <code>true</code> a new image can be dragged into the frame, and if
	 * <code>false</code> it cannot be.
	 */
	public function setEditable(flag:Boolean):Void
	{
		if (flag == m_editable) {
			return;
		}
		
		m_editable = flag;
		
		if (m_editable) {
			registerForDraggedTypes(NSArray.arrayWithObject(
				NSPasteboard.NSImagePboardType));
		} else {
			unregisterDraggedTypes();
		}
	}
	
	//******************************************************															 
	//*                  Drag and drop
	//******************************************************
	
	/**
	 * Returns none by default.
	 */
	function draggingUpdated(sender:NSDraggingInfo):NSDragOperation {
		return NSDragOperation.NSDragOperationMove;
	}
  
	/**
	 * Returns <code>true</code> if <code>#isEditable()</code> is
	 * <code>true</code>.
	 */
	function prepareForDragOperation(sender:NSDraggingInfo):Boolean	{
		return isEditable() && 
			(sender.draggingSourceOperationMask() & NSDragOperation.NSDragOperationMove.value != 0
			|| sender.draggingSourceOperationMask() & NSDragOperation.NSDragOperationCopy.value != 0);
	}
	
	/**
	 * Accepts the pasteboard image.
	 */
	function performDragOperation(sender:NSDraggingInfo):Boolean {
		var image:NSImage = NSImage(sender.draggingPasteboard().dataForType(
			NSPasteboard.NSImagePboardType));
			
		if (image == null) {
			return false;
		}
		
		setImage(image);
		setNeedsDisplay(true);
		return true;
	}
	
	/**
	* Does nothing.
	*/
	function concludeDragOperation(sender:NSDraggingInfo):Void {
	
	}
	
	//******************************************************															 
	//*              Animating Image Playback
	//******************************************************
	
	/**
	 * Returns <code>true</code> if this image view automatically plays
	 * an animated image. If this returns <code>false</code>, no animation
	 * occurs.
	 */
	public function animates():Boolean
	{
		return m_animates;
	}
	
	/**
	 * Sets whether an image assigned to this image view animates automatically.
	 * If <code>true</code>, it does. If <code>false</code>, it does not.
	 */
	public function setAnimates(flag:Boolean):Void
	{
		// TODO implement
		m_animates = flag;
	}
	
	//******************************************************															 
	//*                Pasteboard support
	//******************************************************

	/**
	 * Returns whether this image view allows the user to cut, copy and paste 
	 * the image contents.
	 */	
	public function allowsCutCopyPaste():Boolean
	{
		return m_allowsCutCopyPaste;
	}
	
	/**
	 * Specifies whether this image view allows the user to cut, copy and paste 
	 * the image contents.
	 */
	public function setAllowsCutCopyPaste(flag:Boolean):Void
	{
		m_allowsCutCopyPaste = flag;
	}
	
	//******************************************************															 
	//*                Keyboard equivalents
	//******************************************************
	
	public function keyDown(event:NSEvent):Void
	{		
		if (!m_allowsCutCopyPaste
			|| !(event.modifierFlags & NSEvent.NSControlKeyMask)) {
			super.keyDown(event);
			return;
		}
		
		switch (event.charactersIgnoringModifiers.toLowerCase()) 
		{
			case "x":
				NSPasteboard.generalPasteboard().addTypesOwner(
					NSArray.arrayWithObject(NSPasteboard.NSImagePboardType), 
					null);
				NSPasteboard.generalPasteboard().setDataForType(
					image(), NSPasteboard.NSImagePboardType);
				setImage(null);
				setNeedsDisplay(true);
				break;
				
			case "c":
				NSPasteboard.generalPasteboard().addTypesOwner(
					NSArray.arrayWithObject(NSPasteboard.NSImagePboardType), 
					null);
				NSPasteboard.generalPasteboard().setDataForType(
					image(), NSPasteboard.NSImagePboardType);
				break;
				
			case "v":
				var img:NSImage = NSImage(NSPasteboard.generalPasteboard()
					.dataForType(NSPasteboard.NSImagePboardType));
				
				if (img == null) {
					super.keyDown(event);
					break;
				}
				
				setImage(img);
				setNeedsDisplay(true);
				break;
				
			default:
				super.keyDown(event);
				
		}
		
		return;
	}
	
	//******************************************************															 
	//*                     Drawing
	//******************************************************
	
	/**
	 * Asks the cell to draw the image view.
	 */
	public function drawRect(aRect:NSRect):Void
	{
		m_mcBounds.clear();
		m_cell.drawWithFrameInView(aRect, this);
	}
	
	//******************************************************															 
	//*                  First responder
	//******************************************************
	  
	public function becomeFirstResponder():Boolean 
	{
		m_cell.setShowsFirstResponder(true);
		setNeedsDisplay(true);
		return true;
	}
	
	public function resignFirstResponder():Boolean 
	{
		m_cell.setShowsFirstResponder(false);
		setNeedsDisplay(true);
		return true;
	}
	
	public function becomeKeyWindow() 
	{
		m_cell.setShowsFirstResponder(true);
		setNeedsDisplay(true);
	}
	
	public function resignKeyWindow() 
	{
		m_cell.setShowsFirstResponder(false);
		setNeedsDisplay(true);
	}
	
	public function acceptsFirstMouse(event:NSEvent):Boolean 
	{
		return true;
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