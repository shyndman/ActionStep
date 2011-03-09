/* See LICENSE for copyright and terms of use */
/*
import org.actionstep.ASDebugger;
import org.actionstep.NSApplication;
import org.actionstep.NSMenu;
import org.actionstep.NSMenuItem;
import org.actionstep.NSMenuItemCell;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSImage;
import org.actionstep.NSImageRep;
import org.actionstep.NSSize;*/
import org.actionstep.*;
import org.actionstep.menu.*;
import org.actionstep.test.ASTestView;
import org.actionstep.layout.*;

import flash.display.BitmapData;
import org.actionstep.test.menu.*;

/**
 * Test for the <code>org.actionstep.NSMenu</code> class.
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.test.ASTestMenu {
	private static var g_appMenu1:NSMenu;
	private static var g_appMenu2:NSMenu;

	public static function test():Void {
		var menu:ASTestMenu = new ASTestMenu();
		menu.start(null);
	}

	private function wndNot(n:NSNotification):Void {
		//trace(n);
	}

	public function start(bd:BitmapData):Void {
		var rep:ASBitmapImageRep = (new ASBitmapImageRep()).initWithSourceRect(bd);
		var logo:NSImage = (new NSImage()).init();
		logo.setName("ActionStep Logo");
		logo.addRepresentation(rep);

		// root menu
		var m:NSMenu = (new NSMenu()).initWithTitle("AppMenu");
		// menu attached to root menu
		var am:NSMenu = (new NSMenu()).initWithTitle("Item 1");
		// menu attached to the menu attached to root
		var aam:NSMenu = (new NSMenu()).initWithTitle("AM 2");
		// horizontal menu to be compared with root menu
		var hm:NSMenu = (new NSMenu()).initWithTitle("Non-root Horizontal");
		//hm.menuRepresentation().setHorizontal(true);
		var am2:NSMenu = (new NSMenu()).initWithTitle("Item 2");

		var app:NSApplication = NSApplication.sharedApplication();
		app.setMainMenu(m);
		NSMenuView.setBounds(new NSSize(600, 400));

		var i:Number;
		var self:Object = ASTestMenu;
		var x:NSMenuItem;

//		(m.addItemWithTitleActionKeyEquivalent
//		(null, "itemSel")).
//		setImage(createImage("MyAppIcon", new NSSize(8, 8), 0xDD0000));

		// create items for root menu
		var mi:NSMenuItem = m.addItemWithTitleActionKeyEquivalent
		("Item 1", "itemSel");
//		mi.setImage(createImage("Item 1 image", new NSSize(16, 16), 0xFF0000));
		mi.setImage(logo);
		(m.addItemWithTitleActionKeyEquivalent
		("Item 2", "itemSel")).
		setImage(createImage("Item 2 image", new NSSize(25, 25), 0x00FF00));
		m.addItemWithTitleActionKeyEquivalent
		("Item 3", "itemSel");

		// set target-action
		i = m.itemArray().count();
		while(i--) {
			m.itemArray().objectAtIndex(i).setTarget(self);
		}

		// add item with rather complex modifier
		//! TODO add image for shift
		x = am.addItemWithTitleActionKeyEquivalent
		("AM 1", "itemSel", "A");
		x.setKeyEquivalentModifierMask
		((NSEvent.NSControlKeyMask | NSEvent.NSShiftKeyMask));
		x.setState(NSCell.NSOnState);
		x.setImage(createImage("Green Box", new NSSize(25, 16), 0x00FF00));

		/**
		 * Note that even thought the key equivalent is specified, it is not
		 * performed/displayed, as it has a submenu, and menus with
		 * submenus cannot display submenus.
		 */
		// off state is simply a blank box
		x = am.addItemWithTitleActionKeyEquivalent
		("AM Is a very long menu", "itemSel", "F");
		x.setState(NSCell.NSOffState);
		x.setImage(createImage("Red Box", new NSSize(16, 16), 0xFF0000));

		x = am.addItemWithTitleActionKeyEquivalent
		("The quick brown fox jumps over the lazy dog", "itemSel", "Z");
		x.setState(NSCell.NSMixedState);
		x.setImage(createImage("Blue Box", new NSSize(16, 25), 0x0000FF));

		x = am.addItemWithTitleActionKeyEquivalent
		("AM 2", "itemSel");
		x.setImage(createImage("Yellow Box", new NSSize(25, 25), 0xFFFF00));

		am.addItemWithTitleActionKeyEquivalent
		("Non-root Horizontal", "itemSel");

		i = am.itemArray().count();
		while(i--) {
			am.itemArray().objectAtIndex(i).setTarget(self);
		}

		am2.addItemWithTitleActionKeyEquivalent
		("Some funny item 1", "itemSel");
		am2.addItemWithTitleActionKeyEquivalent
		("Some funny item 2", "itemSel");

		i = am2.itemArray().count();
		while(i--) {
			am2.itemArray().objectAtIndex(i).setTarget(self);
		}

		aam.addItemWithTitleActionKeyEquivalent
		("AAM 1", "itemSel", "F");
		aam.addItemWithTitleActionKeyEquivalent
		("AAM 2", "itemSel", "S");

		i = aam.itemArray().count();
		while(i--) {
			aam.itemArray().objectAtIndex(i).setTarget(self);
		}

//		(hm.addItemWithTitleActionKeyEquivalent
//		("H1", "itemSel", "J")).setImage(createImage("Red Box"));
//
//		(hm.addItemWithTitleActionKeyEquivalent
//		("H2", "itemSel", "K")).setImage(createImage("Green Box"));
//
//		(hm.addItemWithTitleActionKeyEquivalent
//		("H3", "itemSel", "L")).setImage(createImage("Blue Box"));
//
//		i = hm.itemArray().count();
//		while(i--) {
//			hm.itemArray().objectAtIndex(i).setTarget(self);
//		}

		/**
		 * Note that for each attach, 4 notifications are sent:
		 * 1. key equivalent
		 * 2. action
		 * 3. target
		 * 4. submenu
		 */
		// attach menus
		m.setSubmenuForItem(am, mi);
		m.setSubmenuForItem(am2, m.itemWithTitle("Item 2"));
		am.setSubmenuForItem(aam, NSMenuItem(am.itemArray().objectAtIndex(1)));
		//am.setSubmenuForItem(hm, am.itemWithTitle("Non-root Horizontal"));

		g_appMenu1 = m;

		g_appMenu2 =  (new NSMenu()).initWithTitle("MyAppMenu2");
		g_appMenu2.addItemWithTitleActionKeyEquivalent("hello");
		g_appMenu2.addItemWithTitleActionKeyEquivalent("foo");

		//createWindows();

		app.run();
	}

	private function createWindows():Void {
		var wnd1:AppMainWnd = new AppMainWnd(new NSRect(100, 100, 400, 300), "Main Page");
		var wnd2:AppMainWnd = new AppMainWnd(new NSRect(150, 150, 400, 300), "Site Index");
		wnd2.makeMainWindow();

		//wnd1.setDelegate(this);
		//wnd2.setDelegate(this);
	}

	private function menuForMainWindow(wnd:AppMainWnd):NSMenu {
		var page:String = wnd.page;
		if(page=="Site Index") {
			return g_appMenu2;
		}
		return g_appMenu1;
	}

	public static function itemSel (cell:NSMenuItemCell):Void {
		//trace(ASDebugger.info("Action for: "+arguments[0]));
	}

	private static function createImage(name:String, size:NSSize, col:Number):NSImage {
		if(NSImage.imageNamed(name)!=null) {
			return NSImage.imageNamed(name);
		}
		var rep:NSImageRep = new NSImageRep();
		rep.size = function() {
			return size;
		};
		rep.description = function () {
			return name;
		};
		rep.draw = function():Boolean {
			var x:Number = this.m_drawPoint.x;
			var y:Number = this.m_drawPoint.y;
			var w:Number = this.m_size.width;
			var h:Number = this.m_size.height;

			with(this.m_drawClip) {
			 	lineStyle(0, col, 80);
			 	moveTo(x, y);
			 	lineTo(x+w, y);
			 	lineTo(x+w, y+h);
			 	lineTo(x, y+h);
			 	lineTo(x, y);
			 }
			 return true;
		};
		var img:NSImage = (new NSImage()).init();
		img.setName(name);
		img.addRepresentation(rep);

		return img;
	}

	public static function toString():String {
		return "ASTestMenu";
	}
}
