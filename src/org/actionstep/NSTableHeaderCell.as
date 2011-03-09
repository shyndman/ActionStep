/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSImage;
import org.actionstep.NSImageRep;
import org.actionstep.NSRect;
import org.actionstep.NSTextFieldCell;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;

/**
 * Draws the header cell for a single column. Used by NSTableHeaderView.
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSTableHeaderCell extends NSTextFieldCell
{	
	/**
	 * Creates a new instance of NSTableHeaderCell.
	 */
	public function NSTableHeaderCell()
	{
	}
	
	//******************************************************															 
	//*                    Properties
	//******************************************************
	
	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String 
	{
		return "NSTableHeaderCell()";
	}
	
	
	/**
	 * Initializes and returns an NSTableHeaderCell with an empty string.
	 */
	public function init():NSTableHeaderCell
	{
		super.initTextCell("");
		return this;
	}
	
	
	/**
	 * Initializes and returns an NSTableHeader with the string aString.
	 */
	public function initWithTextCell(aString:String):NSTableHeaderCell
	{
		super.initTextCell(aString);
		return this;
	}
	
	//******************************************************
	//*                Copying the cell
	//******************************************************
	
	public function copyWithZone():NSTableHeaderCell {
		return NSTableHeaderCell(super.copyWithZone());
	}
	
	//******************************************************															 
	//*                 Public Methods
	//******************************************************
	
	/**
	 * Draws a sort indicator in the specified boundary frame in the view view.
	 * If isAscending is TRUE, the icon used indicates an upwards sort. If 
	 * FALSE, the icon used indicates a downwards sort. Priority (for multi-
	 * column sorts) is specified by priority. If priority is 0, this should
	 * show the primary sort.
	 */
	public function drawSortIndicatorWithFrameInViewAscendingPriority(
		frame:NSRect, view:NSView, isAscending:Boolean, priority:Number):Void
	{
		//! TODO factor in priority
		
		var imageName:String = 
			isAscending ? "NSSortUpIndicator" : "NSSortDownIndicator";
		var image:NSImage = NSImage.imageNamed(imageName);

		//
		// Set the size of the image.
		//
		var sortIndicator:NSImageRep = image.bestRepresentationForDevice();
		sortIndicator.setSize(frame.size.clone());
		
		//
		// Draw the image.
		//		
		image.lockFocus(view.mcBounds());
		image.drawAtPoint(frame.origin);
		image.unlockFocus();
	}
	
	
	/**
	 * Returns the location to display the sort indicator given a boundary 
	 * rect theRect.
	 */
	public function sortIndicatorRectForBounds(theRect:NSRect):NSRect
	{
		var rect:NSRect = theRect.clone();
		rect.size.height = rect.size.height / 2;
		rect.size.width = rect.size.height;
		
		if (alignment() == NSTextAlignment.NSRightTextAlignment) {
			rect.origin.x = theRect.minX() + 3;
		} else {
			rect.origin.x = theRect.maxX() - rect.size.width - 3;
		}
		rect.origin.y = Math.round((theRect.size.height - rect.size.height) / 2);
		
		return rect;
	}
	
	//******************************************************															 
	//*             Overridden Cell Methods
	//******************************************************
	
	public function drawWithFrameInView(frame:NSRect, view:NSView):Void
	{
		super.drawWithFrameInView(frame, view);
	}
	
	/**
	 * @see org.actionstep.NSCell#drawInteriorWithFrameInView()
	 */
	public function drawInteriorWithFrameInView(frame:NSRect, view:NSView):Void
	{		
		super.drawInteriorWithFrameInView(frame, view);
		ASTheme.current().drawTableHeaderWithRectInViewHighlightedSelected(frame, 
			view, m_state == NSOnState, m_highlighted);
	}
	
	/**
	 * Forces the textfield to update.
	 */
	public function validateTextField(cellFrame:NSRect):Void {
		super.validateTextField(cellFrame);
	}
	
	/**
	 * Returns the header's title rect.
	 */
	public function titleRectForBounds(theRect:NSRect):NSRect {
		var ret:NSRect = super.titleRectForBounds(theRect);
		return ret.insetRect(2, 0);
	}
}
