/* See LICENSE for copyright and terms of use */

import org.actionstep.NSView;
import org.actionstep.NSRect;

/**
 * @author Scott Hyndman
 */

class org.actionstep.test.trackingRects.ASTestDrawingView extends NSView{
	public function initWithFrame(frame:NSRect):ASTestDrawingView {
		return ASTestDrawingView(super.initWithFrame(frame));
	}
}