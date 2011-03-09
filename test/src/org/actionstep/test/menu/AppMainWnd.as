/* See LICENSE for copyright and terms of use */

import org.actionstep.NSWindow;
import org.actionstep.NSRect;
import org.actionstep.test.ASTestView;
import org.actionstep.NSPoint;
import org.actionstep.ASColors;
import org.actionstep.test.menu.AppKeyWnd;

/**
 * @author Tay Ray Chuan
 */

class org.actionstep.test.menu.AppMainWnd extends NSWindow {
	public var page:String;

	public function AppMainWnd(rect:NSRect, page:String) {
		super();
		initWithContentRectStyleMask(rect, NSWindow.NSTitledWindowMask);
		this.page = page;
		setTitle("Firewolf - Browsing: "+page);

		var pt:NSPoint = rect.origin;

//		var wnd1:AppKeyWnd = (new AppKeyWnd(new NSRect(pt.x+50, pt.y+50, 300, 150)));
//		var wnd2:AppKeyWnd = (new AppKeyWnd(new NSRect(pt.x+90, pt.y+90, 300, 150)));
//		var wnd3:AppKeyWnd = (new AppKeyWnd(new NSRect(pt.x+10, pt.y+150, 300, 150)));
//
//		wnd1.setParentWindow(this);
//		wnd2.setParentWindow(this);
//		wnd3.setParentWindow(this);
//
//		wnd1.setTitle("Find");
//		wnd2.setTitle("Download Manager");
//		wnd3.setTitle("Bookmarks");

		var inset:NSRect = NSRect(rect.copy());
		inset.origin = NSPoint.ZeroPoint;
		var view:ASTestView = ASTestView((new ASTestView()).initWithFrame(inset));
		view.setBackgroundColor(ASColors.whiteColor());
		setContentView(view);

		setMakeMainAndKey(true);

		//trace("created: "+m_windowNumber);
	}

	public function canBecomeMainWindow():Boolean {
		return true;
	}

//	public function canBecomeKeyWindow():Boolean {
//		return false;
//	}
}