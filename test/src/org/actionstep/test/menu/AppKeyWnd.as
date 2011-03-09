/* See LICENSE for copyright and terms of use */

import org.actionstep.NSWindow;
import org.actionstep.NSRect;
import org.actionstep.NSPoint;
import org.actionstep.test.ASTestView;
import org.actionstep.ASColors;

/**
 * @author Tay Ray Chuan
 */

class org.actionstep.test.menu.AppKeyWnd extends NSWindow {
	public function AppKeyWnd(rect:NSRect) {
		super();
		initWithContentRectStyleMask(rect, NSWindow.NSTitledWindowMask | NSWindow.NSClosableWindowMask);

		var inset:NSRect = NSRect(rect.copy());
		inset.origin = NSPoint.ZeroPoint;
		var view:ASTestView = ASTestView((new ASTestView()).initWithFrame(inset));
		view.setBackgroundColor(ASColors.whiteColor());
		setContentView(view);

		//trace("created: "+m_windowNumber);
	}

	public function canBecomeMainWindow():Boolean {
		return false;
	}
}