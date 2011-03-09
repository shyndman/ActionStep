/* See LICENSE for copyright and terms of use */

import org.actionstep.NSCell;
import org.actionstep.NSDictionary;
import org.actionstep.NSMenu;
import org.actionstep.NSMenuItem;
import org.aib.AIBApplication;
import org.actionstep.NSApplication;

/**
 * Creates the default AIB menu.
 * 
 * @author Scott Hyndman
 */
class org.aib.menu.MenuBuilder {
		
	private static var SEPARATOR:Number = 1;
	private static var STRING_GROUP:String = "menu.";
	private static var g_menuDict:NSDictionary;
	private static var g_target:Object;
	
	/**
	 * Builds the AIB menu.
	 */
	public static function buildMenuWithTarget(target:Object):NSMenu {
		g_target = target;
		g_menuDict = AIBApplication.stringTable().internalDictionary();
		var rootMenu:NSMenu = (new NSMenu()).initWithTitle("ROOT");
		NSApplication.sharedApplication().setMainMenu(rootMenu);
		addMenuItemsToMenu(menuItems(), rootMenu);
		return rootMenu;
	}
	
	/**
	 * Adds all the items contained in <code>items</code> to the menu
	 * <code>menu</code>.
	 */
	private static function addMenuItemsToMenu(items:Array, menu:NSMenu):Void {
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
			
			var title:String = g_menuDict.objectForKey(STRING_GROUP + items[i].sid.toLowerCase()).toString();
			if (items[i].ellipsis != undefined && items[i].ellipsis) {
				title += "...";
			}
			
			//trace(items[i].sid + "::" + title);
			
			//
			// Build the action name
			//
			var action:String;
			if (items[i].items != undefined) {
				action = null;
			}
			else if (items[i].action != undefined) {
				action = items[i].action;
			} else {
				action = items[i].sid;
				action = action.charAt(0).toLowerCase() + action.substr(1);
			}
			
			//
			// Create menu item
			//
			mi = menu.addItemWithTitleActionKeyEquivalent(title, action, "");
			
			//
			// Set menu item properties based on contents of item
			//
			if (items[i].enabled != undefined) {
				mi.setEnabled(items[i].enabled);
			}
			if (items[i].checked) {
				mi.setState(NSCell.NSOnState);
			}
			if (items[i].bold) {
				// TODO figure out how to bold
			}
			if (items[i].target) {
				mi.setTarget(items[i].target);
			} else {
				mi.setTarget(g_target); // default target
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
			{sid:"AIB", bold:true, items:[
				{sid:"About"},
				SEPARATOR,
				{sid:"Preferences", ellipsis:true},
				SEPARATOR,
				{sid:"Quit"}
				]
			},
			{sid:"File", items:[
				{sid:"FileNew", ellipsis:true},
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
				{sid:"Undo"},
				{sid:"Redo"},
				SEPARATOR,
				{sid:"Cut"},
				{sid:"Copy"},
				{sid:"Paste"},
				{sid:"Del"},
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
					{sid:"HideGuides", action:"toggleGuideVis"}, // FIXME or ShowGuides?
					{sid:"LockGuides", action:"toggleGuideLocks"}, // FIXME or UnlockGuides?
					{sid:"AddHorizontalGuide"},
					{sid:"AddVerticalGuide"},
					SEPARATOR,
					{sid:"DisableGuidelines", action:"toggleGuidelines"} // FIXME or EnableGuidelines
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
				{sid:"ShowHelp"},
				SEPARATOR,
				{sid:"ReleaseNotes"},
				{sid:"ShowFAQ"}
				]
			}
		];
	}
}