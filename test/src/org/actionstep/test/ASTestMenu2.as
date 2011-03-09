import org.actionstep.ASDraw;
import org.actionstep.menu.NSMenuView;
import org.actionstep.NSApplication;
import org.actionstep.NSCell;
import org.actionstep.NSEvent;
import org.actionstep.NSMenu;
import org.actionstep.NSMenuItem;
import org.actionstep.NSPoint;
import org.actionstep.NSSize;

class org.actionstep.test.ASTestMenu2 {

  private static var m_app:NSApplication;
  private static var m_target:Object;
  private static var SEPARATOR:Number = 1;
  
	public static function test():Void {
		//
		// Create window and app.
		//
		// Note the way we are creating the window. We MUST use lib/video.swf
		// as the content swf, so that we can access the Video object provided
		// within the swf.
		//
		m_target = new Object();
		m_target.showStatusAlertTimesDialog = function() {
		  trace("Got showStatusAlertTimesDialog");
		};
		m_app = NSApplication.sharedApplication();
		addMenuItemsToMenu(menuItems());

		//
		// Test boundaries, and draw a rect to see it in action
		//
		NSMenuView.setBounds(new NSSize(550, 400));
		var pt:NSPoint = NSMenu.rootMenu().window().frame().origin;
		var size:NSSize = NSMenuView.bounds();
		ASDraw.drawRect(_root, pt.x, pt.y, size.width, size.height, 0xFF0000, 100, .25);

		m_app.run();
	}

	/**
	 * Adds all the items contained in <code>items</code> to the menu
	 * <code>menu</code>.
	 */
	private static function addMenuItemsToMenu(items:Array, menu:NSMenu):Void {
		if (menu == null) {
			menu = (new NSMenu()).initWithTitle("ROOT");
			m_app.setMainMenu(menu);
		}
		
		var mi:NSMenuItem;
		for (var i:Number = 0;i<items.length;i++) {
			//
			// Add a separator if required
			//
			if (items[i] == SEPARATOR) {
				menu.addItem(NSMenuItem.separatorItem());
				continue;
			}
			
			//
			// Build title
			//
			var title:String = items[i].sid;
			if (items[i].ellipsis != undefined && items[i].ellipsis) {
				title += "...";
			}
			
			//trace(items[i].sid + "::" + title);
			
			//
			// Build the action name
			//
			var action:String = "";
			if (items[i].action != undefined) {
				action = items[i].action;
			} else {
				action = items[i].sid;
				action = action.charAt(0).toLowerCase() + action.substr(1);
			}
			
			//
			// Key equiv
			//
			var key:String = "";
			if (items[i].keyEquiv != undefined) {
				key = items[i].keyEquiv;
			}
			
			//
			// Create menu item
			//
			mi = menu.addItemWithTitleActionKeyEquivalent(title, action, key);
			
			
			if (items[i].mods != undefined) {
				mi.setKeyEquivalentModifierMask(items[i].mods);
			}
			
			//
			// Set menu item properties based on contents of item
			//
			if (items[i].enabled != undefined) {
				mi.setEnabled(items[i].enabled);
			}
			if (items[i].checked) {
				mi.setState(NSCell.NSOnState);
			}
			if (items[i].toolTip) {
				mi.setToolTip(items[i].toolTip);
			}
			
			//
			// If the menu has child menus, add them
			//
			if (items[i].items != undefined) {
				var submenu:NSMenu = (new NSMenu()).initWithTitle(title);
				addMenuItemsToMenu(items[i].items, submenu);
				menu.setSubmenuForItem(submenu, mi);
			}
		}
	}
  
	/**
	 * Returns the menu items used by the application.
	 */
	private static function menuItems():Array {
		return [
			{sid:"AIB", items:[
				{sid:"About", toolTip:"About about about"},
				SEPARATOR,
				{sid:"Preferences", ellipsis:true, toolTip:"Prefs"},
				SEPARATOR,
				{sid:"Quit"}
				]
			},
			{sid:"File", items:[
				{sid:"New", ellipsis:true},
				{sid:"Open", ellipsis:true},
				{sid:"OpenRecent", items:[
					// this is where the recent list goes
					SEPARATOR,
					{sid:"ClearMenu"}
					]
				},
				SEPARATOR,
				{sid:"Import", items:[
					{sid:"ImportResource"}
					]
				},
				SEPARATOR,
				{sid:"Close"},
				{sid:"Save"},
				{sid:"SaveAs", ellipsis:true},
				{sid:"Revert"},
				SEPARATOR,
				{sid:"TestInterface"}
				]
			},
			{sid:"Edit", items:[
				{sid:"Undo", keyEquiv:"z", mods: NSEvent.NSControlKeyMask},
				{sid:"Redo"},
				SEPARATOR,
				{sid:"Cut"},
				{sid:"Copy"},
				{sid:"Paste"},
				{sid:"Delete"},
				{sid:"SelectAll"},
				{sid:"Duplicate"},
				SEPARATOR,
				{sid:"Find", items:[
					{sid:"FindDialog", ellipsis:true},
					{sid:"FindNext"},
					{sid:"FindPrevious"},
					{sid:"FindUseSelection"},
					{sid:"JumpToSelection"}
					]
				}
				]
			},
			{sid:"Classes", items:[
				{sid:"Subclass"},
				{sid:"Instantiate"},
				SEPARATOR,
				{sid:"AddOutlet"},
				{sid:"AddAction"},
				SEPARATOR,
				{sid:"ReadFiles", ellipsis:true},
				{sid:"ReadSelectedClass"},
				{sid:"CreateFiles"}
				]
			},
			{sid:"Format", items:[
				{sid:"Font", items:[
					{sid:"ShowFonts"},
					{sid:"Bold"},
					{sid:"Italic"},
					{sid:"Underline"},
					SEPARATOR,
					{sid:"Bigger"},
					{sid:"Smaller"},
					SEPARATOR,
					{sid:"CopyStyle"},
					{sid:"PasteStyle"}
					]
				},
				{sid:"Text", items:[
					{sid:"AlignLeft"},
					{sid:"AlignCenter"},
					{sid:"AlignRight"},
					SEPARATOR,
					{sid:"ShowRuler"},
					{sid:"CopyRuler"},
					{sid:"PasteRuler"}
					]
				}
				]
			},
			{sid:"Layout", items:[
				{sid:"Alignment", items:[
					{sid:"AlignmentPanel"},
					SEPARATOR,
					{sid:"AlignLeftEdges"},
					{sid:"AlignRightEdges"},
					{sid:"AlignTopEdges"},
					{sid:"AlignBottomEdges"},
					SEPARATOR,
					{sid:"AlignVerticalCenters"},
					{sid:"AlignHorizontalCenters"},
					{sid:"AlignBaselines"},
					SEPARATOR,
					{sid:"MakeCenteredColumn"},
					{sid:"MakeCenteredRow"}
					]
				},
				SEPARATOR,
				{sid:"BringToFront"},
				{sid:"SendToBack"},
				SEPARATOR,
				{sid:"SameSize"},
				{sid:"SizeToFit"},
				{sid:"Transpose"},
				SEPARATOR,
				{sid:"MakeSubviewsOf", items:[
					{sid:"MakeSubviewsOfBox"},
					{sid:"MakeSubviewsOfCustomView"},
					{sid:"MakeSubviewsOfScrollView"},
					{sid:"MakeSubviewsOfSplitView"},
					{sid:"MakeSubviewsOfTabView"}
					]
				},
				{sid:"UnpackSubviews"},
				SEPARATOR,
				{sid:"LockFrame"},
				{sid:"UnlockFrame"},
				SEPARATOR,
				{sid:"Group"},
				{sid:"Ungroup"},
				SEPARATOR,
				{sid:"Guides", items:[
					{sid:"HideGuides"}, // FIXME or ShowGuides?
					{sid:"LockGuides"}, // FIXME or UnlockGuides?
					{sid:"AddHorizontalGuide"},
					{sid:"AddVerticalGuide"},
					SEPARATOR,
					{sid:"DisableGuidelines"} // FIXME or EnableGuidelines
					]
				}
				]
			},
			{sid:"Tools", items:[
				{sid:"ShowInfo"},
				{sid:"Palettes", items:[
					{sid:"ShowPalettes"},
					SEPARATOR,
					{sid:"PalettePreferences", ellipsis:true},
					{sid:"CustomizeToolbar", ellipsis:true},
					SEPARATOR,
					{sid:"PaletteNew"},
					{sid:"PaletteSave"},
					{sid:"PaletteSaveAs", ellipsis:true},
					{sid:"PaletteRevert"}
					]
				},
				{sid:"ShowColors"}
				]
			},
			{sid:"Help", items:[
				{sid:"AIBHelp"},
				SEPARATOR,
				{sid:"ReleaseNotes"},
				{sid:"FAQ"}
				]
			}
		];
	}
}