/* See LICENSE for copyright and terms of use */

import org.actionstep.NSButton;
import org.actionstep.NSPopUpButtonCell;
import org.actionstep.NSRect;
import org.actionstep.NSMenu;
import org.actionstep.constants.NSRectEdge;
import org.actionstep.NSArray;
import org.actionstep.NSMenuItem;
import org.actionstep.ASUtils;

/**
 * @author Tay Ray Chuan
 */
class org.actionstep.NSPopUpButton extends NSButton {

	//******************************************************
	//*                  Notifications
	//******************************************************

	public static var NSPopUpButtonWillPopUpNotification:Number = ASUtils.intern("NSPopUpButtonWillPopUpNotification");


	//******************************************************
	//*                 Member variables
	//******************************************************

	//******************************************************
	//*							Required by NSControl
	//******************************************************

	private static var g_cellClass:Function = NSPopUpButtonCell;

	public static function cellClass():Function {
		return g_cellClass;
	}

	public static function setCellClass(cellClass:Function):Void {
		if (cellClass == null) {
			g_cellClass = org.actionstep.NSButtonCell;
		} else {
			g_cellClass = cellClass;
		}
	}

	//******************************************************
	//*                  Construction
	//******************************************************

	public function init():NSPopUpButton {
		return initWithFrame(NSRect.ZeroRect, false);
	}

	public function initWithFrame(rect:NSRect):NSPopUpButton {
		return initWithFramePullsDown(rect, false);
	}

	public function initWithFramePullsDown(rect:NSRect, pullsDown:Boolean):NSPopUpButton {
		super.initWithFrame(rect);
		setPullsDown(pullsDown);
		return this;
	}

	//******************************************************
	//*                  Adding Items
	//******************************************************

	public function addItemWithTitle(title:String):Void {
		NSPopUpButtonCell(m_cell).addItemWithTitle(title);
		synchronizeTitleAndSelectedItem();
	}

	public function addItemWithTitles(titles:NSArray):Void {
		NSPopUpButtonCell(m_cell).addItemsWithTitles(titles);
		synchronizeTitleAndSelectedItem();
	}

	public function insertItemWithTitleAtIndex(title:String):Void {
		NSPopUpButtonCell(m_cell).insertItemWithTitleAtIndex(title);
		synchronizeTitleAndSelectedItem();
	}

	//******************************************************
	//*                  Removing Items
	//******************************************************

	public function removeAllItems():Void {
		NSPopUpButtonCell(m_cell).removeAllItems();
		synchronizeTitleAndSelectedItem();
	}

	public function removeItemWithTitle(title:String):Void {
		NSPopUpButtonCell(m_cell).removeItemWithTitle(title);
		synchronizeTitleAndSelectedItem();
	}

	public function removeItemAtIndex(index:Number):Void {
		NSPopUpButtonCell(m_cell).removeItemAtIndex(index);
		synchronizeTitleAndSelectedItem();
	}

	//******************************************************
	//*                  Selecting Items
	//******************************************************

	public function selectedItem():NSMenuItem {
		return NSPopUpButtonCell(m_cell).selectedItem();
	}

	public function selectItem(item:NSMenuItem):Void {
		NSPopUpButtonCell(m_cell).selectItem(item);
		//synchronizeTitleAndSelectedItem();
	}

	public function selectItemAtIndex(index:Number):Void {
		NSPopUpButtonCell(m_cell).selectItemAtIndex(index);
		//synchronizeTitleAndSelectedItem();
	}

	public function selectItemWithTag(tag:Number):Void {
		NSPopUpButtonCell(m_cell).selectItemWithTag(tag);
		//synchronizeTitleAndSelectedItem();
	}

	public function selectItemWithTitle(title:String):Void {
		NSPopUpButtonCell(m_cell).selectItemWithTitle(title);
		//synchronizeTitleAndSelectedItem();
	}

	public function titleOfSelectedItem():String {
		return NSPopUpButtonCell(m_cell).titleOfSelectedItem();
	}

	//******************************************************
	//*                  Retrieving Menu Items
	//******************************************************

	public function itemAtIndex(n:Number):NSMenuItem {
		return NSPopUpButtonCell(m_cell).itemAtIndex(n);
	}

	public function indexOfItem(item:NSMenuItem):Number {
		return NSPopUpButtonCell(m_cell).indexOfItem(item);
	}

	public function indexOfItemWithRepresentedObject(obj:Object):Number {
		return NSPopUpButtonCell(m_cell).indexOfItemWithRepresentedObject(obj);
	}

	public function indexOfItemWithTag(tag:Number):Number {
		return NSPopUpButtonCell(m_cell).indexOfItemWithTag(tag);
	}

	public function indexOfItemWithTargetAndAction
	(target:Object, action:String):Number {
		return NSPopUpButtonCell(m_cell).indexOfItemWithTargetAndAction(target, action);
	}

	public function indexOfItemWithTitle(title:String):Number {
		return NSPopUpButtonCell(m_cell).indexOfItemWithTitle(title);
	}

	public function indexOfSelectedItem():Number {
		return NSPopUpButtonCell(m_cell).indexOfSelectedItem();
	}

	public function itemTitleAtIndex(n:Number):String {
		return NSPopUpButtonCell(m_cell).itemTitleAtIndex();
	}

	public function itemTitles():NSArray {
		return NSPopUpButtonCell(m_cell).itemTitles();
	}

	public function itemWithTitle(title:String):NSMenuItem {
		return NSPopUpButtonCell(m_cell).itemWithTitle(title);
	}

	public function lastItem():NSMenuItem {
		return NSPopUpButtonCell(m_cell).lastItem();
	}

	//******************************************************
	//*                  Setting/getting Cell Attributes
	//******************************************************

	public function setPullsDown(f:Boolean):Void {
		NSPopUpButtonCell(m_cell).setPullsDown(f);
	}

	public function pullsDown():Boolean {
		return NSPopUpButtonCell(m_cell).pullsDown();
	}

	public function setMenu(f:NSMenu):Void {
		NSPopUpButtonCell(m_cell).setMenu(f);
	}

	public function menu():NSMenu {
		return NSPopUpButtonCell(m_cell).menu();
	}

	public function setAutoenablesItems(f:Boolean):Void {
		NSPopUpButtonCell(m_cell).setAutoenablesItems(f);
	}

	public function autoenablesItems():Boolean {
		return NSPopUpButtonCell(m_cell).autoenablesItems();
	}

	public function setPreferredEdge(f:NSRectEdge):Void {
		NSPopUpButtonCell(m_cell).setPreferredEdge(f);
	}

	public function preferredEdge():NSRectEdge {
		return NSPopUpButtonCell(m_cell).preferredEdge();
	}

	public function synchronizeTitleAndSelectedItem():Void {

	}
}