/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSBezelStyle;
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.NSButtonCell;
import org.actionstep.NSCell;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSRect;
import org.actionstep.NSScroller;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;

/**
 * Used internally for scroller buttons.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.scroller.ASScrollerButtonCell extends NSButtonCell {
	
	//******************************************************
	//*                    Constants
	//******************************************************
	
	public static var ASLeftScrollerButton:Number	= 1;
	public static var ASTopScrollerButton:Number	= 2;
	public static var ASRightScrollerButton:Number	= 3;
	public static var ASBottomScrollerButton:Number	= 4;

	//******************************************************
	//*                     Members
	//******************************************************

	private var m_role:Number;

	//******************************************************
	//*                   Construction
	//******************************************************
		
	public function ASScrollerButtonCell() {
		super();
	}

	/**
	 * Initializes the scroller button cell
	 */
	public function init():ASScrollerButtonCell {
		initImageCell();
		
		setHighlightsBy(NSCell.NSChangeBackgroundCellMask | NSCell.NSContentsCellMask);
		setImagePosition(NSCellImagePosition.NSImageOnly);
		setContinuous(true);
		sendActionOn(NSEvent.NSLeftMouseDownMask 
			| NSEvent.NSLeftMouseUpMask | NSEvent.NSPeriodicMask);
		setPeriodicDelayInterval(.3, .03);
		setBezelStyle(NSBezelStyle.NSShadowlessSquareBezelStyle);
		setBezeled(true);
		
		return this;
	}
	
	//******************************************************
	//*             Setting the button's role
	//******************************************************
	
	/**
	 * Sets the button role to one of the constants defined in this class.
	 * 
	 * ASLeftScrollerButton
	 * ASTopScrollerButton
	 * ASRightScrollerButton
	 * ASBottomScrollerButton
	 */
	public function setButtonRole(value:Number):Void {
		m_role = value;
		
		//
		// Setup properties
		//
		switch (m_role) {
		case ASLeftScrollerButton:
			setImage(NSImage.imageNamed("NSScrollerLeftArrow"));
			setAlternateImage(NSImage.imageNamed("NSHightlightedScrollerLeftArrow"));
			break;
			
		case ASTopScrollerButton:
			setImage(NSImage.imageNamed("NSScrollerUpArrow"));
			setAlternateImage(NSImage.imageNamed("NSHightlightedScrollerUpArrow"));
			break;
			
		case ASRightScrollerButton:
			setImage(NSImage.imageNamed("NSScrollerRightArrow"));
			setAlternateImage(NSImage.imageNamed("NSHightlightedScrollerRightArrow"));
			break;
			
		case ASBottomScrollerButton:
			setImage(NSImage.imageNamed("NSScrollerDownArrow"));
			setAlternateImage(NSImage.imageNamed("NSHightlightedScrollerDownArrow"));
			break;
		}
	}
	
	//******************************************************
	//*              Drawing the button
	//******************************************************
	
	private function drawBorderWithFrameInView(cellFrame:NSRect, inView:NSView):Void {
		ASTheme.current().drawScrollerCellBorderInRectOfScroller(this, cellFrame, NSScroller(inView));
	}
	
	private function drawBezelWithFrameInView(cellFrame:NSRect, inView:NSView):Void {
		ASTheme.current().drawScrollerCellBorderInRectOfScroller(this, cellFrame, NSScroller(inView));
	}
	
	private function drawBackgroundWithFrameMaskInView(frame:NSRect, mask:Number, 
			controlView:NSView):Void {
		ASTheme.current().drawScrollerCellBackgroundWithFrameMaskInScroller(
			this, frame, mask, NSScroller(controlView));
	}
}