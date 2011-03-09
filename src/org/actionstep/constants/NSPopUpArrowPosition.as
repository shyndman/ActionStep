/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Specifies the possible positions for displaying the arrow in the popup
 * button cell, and is used by <code>arrowPosition</code> and
 * <code>setArrowPosition</code>
 *
 * @see org.actionstep.NSPopUpButtonCell#arrowPosition
 * @see org.actionstep.NSPopUpButtonCell#setArrowPosition
 * @author Tay Ray Chuan
 */

class org.actionstep.constants.NSPopUpArrowPosition extends ASConstantValue {
	/** Does not display any arrow in the receiver. */
	public static var NSPopUpNoArrow:NSPopUpArrowPosition
	= new NSPopUpArrowPosition(0);

	/**
	 * Arrow is centered vertically, pointing toward the
	 * <code>preferredEdge</code>.
	 *
	 * @see org.actionstep.NSPopUpButtonCell#preferredEdge
	 */
	public static var NSPopUpArrowAtCenter:NSPopUpArrowPosition
	= new NSPopUpArrowPosition(1);

	/**
	 * Arrow is drawn at the edge of the button, pointing toward the
	 * <code>preferredEdge</code>.
	 *
	 * @see org.actionstep.NSPopUpButtonCell#preferredEdge
	 */
	public static var NSPopUpArrowAtBottom:NSPopUpArrowPosition
	= new NSPopUpArrowPosition(2);

	private function NSPopUpArrowPosition(value:Number) {
		super(value);
	}
}