/* See LICENSE for copyright and terms of use */

import org.aib.AIBObject;
import org.actionstep.NSMenuItem;
import org.aib.AIBApplication;

/**
 * Handles menu actions.
 * 
 * @author Scott Hyndman
 */
class org.aib.menu.MenuTarget extends AIBObject {
	
	private var m_app:AIBApplication;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>MenuTarget</code> class.
	 */
	public function MenuTarget() {
		
	}
	
	/**
	 * Initializes the menu target with the application <code>app</code>.
	 */
	public function initWithApplication(app:AIBApplication):MenuTarget {
		m_app = app;
		return this;
	}
	
	//******************************************************
	//*                  Action methods
	//******************************************************
	
	//
	// AIB menu
	//
	
	public function about(sender:NSMenuItem):Void {
		trace("MenuTarget.about(sender)");
	}
	
	public function preferences(sender:NSMenuItem):Void {
		trace("MenuTarget.preferences(sender)");
	}
	
	public function quit(sender:NSMenuItem):Void {
		trace("MenuTarget.quit(sender)");
	}
	
	//
	// File menu
	//
	
	public function fileNew(sender:NSMenuItem):Void {
		
	}
	
	public function open(sender:NSMenuItem):Void {
		
	}
	
	public function close(sender:NSMenuItem):Void {
		
	}
	
	public function save(sender:NSMenuItem):Void {
		
	}
	
	public function saveAs(sender:NSMenuItem):Void {
		
	}
	
	public function testInterface(sender:NSMenuItem):Void {
		
	}

	//
	// File > Open Recent
	//	
	public function clearMenu(sender:NSMenuItem):Void {
		
	}
	
	//
	// Edit
	//
	
	public function undo(sender:NSMenuItem):Void {
		
	}
	
	public function redo(sender:NSMenuItem):Void {
		
	}
	
	public function cut(sender:NSMenuItem):Void {
		
	}
	
	public function copy(sender:NSMenuItem):Void {
		
	}
	
	public function paste(sender:NSMenuItem):Void {
		
	}
	
	public function del(sender:NSMenuItem):Void {
		
	}
	
	public function selectAll(sender:NSMenuItem):Void {
		
	}
	
	public function duplicate(sender:NSMenuItem):Void {
		
	}
	
	public function find(sender:NSMenuItem):Void {
		
	}

	//
	// Edit > Find
	//	
	public function findDialog(sender:NSMenuItem):Void {
		
	}
	
	public function findNext(sender:NSMenuItem):Void {
		
	}
	
	public function findPrevious(sender:NSMenuItem):Void {
		
	}
	
	public function findUseSelection(sender:NSMenuItem):Void {
		
	}
	
	public function jumpToSelection(sender:NSMenuItem):Void {
		
	}
	
	//
	// Classes
	//
	
	public function subclass(sender:NSMenuItem):Void {
		
	}
	
	public function instantiate(sender:NSMenuItem):Void {
		
	}
	
	public function addOutlet(sender:NSMenuItem):Void {
		
	}
	
	public function addAction(sender:NSMenuItem):Void {
		
	}
	
	public function readFiles(sender:NSMenuItem):Void {
		
	}
	
	public function readSelectedClass(sender:NSMenuItem):Void {
		
	}
	
	public function createFiles(sender:NSMenuItem):Void {
		
	}
	
	//
	// Format > Font
	//
	
	public function showFonts(sender:NSMenuItem):Void {
		
	}
	
	public function bold(sender:NSMenuItem):Void {
		
	}
	
	public function italic(sender:NSMenuItem):Void {
		
	}
	
	public function underline(sender:NSMenuItem):Void {
		
	}
	
	public function bigger(sender:NSMenuItem):Void {
		
	}
	
	public function smaller(sender:NSMenuItem):Void {
		
	}
	
	public function copyStyle(sender:NSMenuItem):Void {
		
	}
	
	public function pasteStyle(sender:NSMenuItem):Void {
		
	}
	
	//
	// Format > Text
	//
	
	public function alignLeft(sender:NSMenuItem):Void {
		
	}
	
	public function alignCenter(sender:NSMenuItem):Void {
		
	}
	
	public function alignRight(sender:NSMenuItem):Void {
		
	}
	
	public function showRuler(sender:NSMenuItem):Void {
		
	}
	
	public function copyRuler(sender:NSMenuItem):Void {
		
	}
	
	public function pasteRuler(sender:NSMenuItem):Void {
		
	}
	
	//
	// Layout
	//
	
	public function bringToFront(sender:NSMenuItem):Void {
		
	}
	
	public function sentToBack(sender:NSMenuItem):Void {
		
	}
	
	public function sameSize(sender:NSMenuItem):Void {
		
	}
	
	public function sizeToFit(sender:NSMenuItem):Void {
		
	}
	
	public function transpose(sender:NSMenuItem):Void {
		
	}
	
	public function unpackSubviews(sender:NSMenuItem):Void {
		
	}
	
	public function lockFrame(sender:NSMenuItem):Void {
		
	}
	
	public function unlockFrame(sender:NSMenuItem):Void {
		
	}
	
	public function group(sender:NSMenuItem):Void {
		
	}
	
	public function ungroup(sender:NSMenuItem):Void {
		
	}
	
	//
	// Layout > Alignment
	//
	
	public function alignmentPanel(sender:NSMenuItem):Void {
		
	}
	
	public function alignLeftEdges(sender:NSMenuItem):Void {
		
	}
	
	public function alignRightEdges(sender:NSMenuItem):Void {
		
	}
	
	public function alignTopEdges(sender:NSMenuItem):Void {
		
	}
	
	public function alignBottomEdges(sender:NSMenuItem):Void {
		
	}
	
	public function alignVerticalCenters(sender:NSMenuItem):Void {
		
	}
	
	public function alignHorizontalCenters(sender:NSMenuItem):Void {
		
	}
	
	public function alignBaselines(sender:NSMenuItem):Void {
		
	}
	
	public function makeCenteredColumn(sender:NSMenuItem):Void {
		
	}
	
	public function makeCenteredRow(sender:NSMenuItem):Void {
		
	}
	
	//
	// Layout > Make subviews of
	//
	
	public function makeSubviewsOfBox(sender:NSMenuItem):Void {
		
	}
	
	public function makeSubviewsOfCustomView(sender:NSMenuItem):Void {
		
	}
	
	public function makeSubviewsOfScrollView(sender:NSMenuItem):Void {
		
	}
	
	public function makeSubviewsOfSplitView(sender:NSMenuItem):Void {
		
	}
	
	public function makeSubviewsOfTabView(sender:NSMenuItem):Void {
		
	}
	
	//
	// Layout > Guides
	//
	
	public function toggleGuideVis(sender:NSMenuItem):Void {
		
	}
	
	public function toggleGuideLocks(sender:NSMenuItem):Void {
		
	}
	
	public function addHorizontalGuide(sender:NSMenuItem):Void {
		
	}
	
	public function addVerticalGuide(sender:NSMenuItem):Void {
		
	}
	
	public function toggleGuidelines(sender:NSMenuItem):Void {
		
	}
	
	//
	// Tools
	//
	
	public function showInfo(sender:NSMenuItem):Void {
		
	}
	
	public function showColors(sender:NSMenuItem):Void {
		
	}
	
	//
	// Tools > Palettes
	//
	
	public function showPalettes(sender:NSMenuItem):Void {
		
	}
	
	public function palettePreferences(sender:NSMenuItem):Void {
		
	}
	
	public function customizeToolbar(sender:NSMenuItem):Void {
		
	}
	
	public function paletteNew(sender:NSMenuItem):Void {
		
	}
	
	public function paletteSave(sender:NSMenuItem):Void {
		
	}
	
	public function paletteSaveAs(sender:NSMenuItem):Void {
		
	}
	
	public function paletteRevert(sender:NSMenuItem):Void {
		
	}
	
	//
	// Help
	//
	
	public function showHelp(sender:NSMenuItem):Void {
		
	}
	
	public function releaseNotes(sender:NSMenuItem):Void {
		
	}
	
	public function showFAQ(sender:NSMenuItem):Void {
		
	}
}