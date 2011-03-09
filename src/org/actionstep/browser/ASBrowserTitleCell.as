/* See LICENSE for copyright and terms of use */

import org.actionstep.NSRect;
import org.actionstep.NSTableHeaderCell;
import org.actionstep.NSView;

/**
 * For internal use.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.browser.ASBrowserTitleCell extends NSTableHeaderCell {
	
	/**
	 * @see org.actionstep.NSCell#drawInteriorWithFrameInView()
	 */
	public function drawInteriorWithFrameInView(frame:NSRect, view:NSView):Void {
		validateTextField(frame);
	}
}