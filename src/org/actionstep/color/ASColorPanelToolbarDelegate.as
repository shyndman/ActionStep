/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSButtonCell;
import org.actionstep.NSColorPanel;
import org.actionstep.NSColorPicker;
import org.actionstep.NSColorPicking;
import org.actionstep.NSDictionary;
import org.actionstep.NSImage;
import org.actionstep.NSNotification;
import org.actionstep.NSToolbar;
import org.actionstep.NSToolbarItem;
import org.actionstep.toolbar.ASToolbarDelegate;
import org.actionstep.toolbar.items.ASToolbarItemButton;

/**
 * The delegate for the color panel's toolbar. This class is responsible for
 * taking the registered providers and turning them into toolbar items.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.color.ASColorPanelToolbarDelegate implements ASToolbarDelegate {
	
	private var m_allIDs:Array;
	private var m_idToPickerMap:NSDictionary;
	private var m_colorPanel:NSColorPanel;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASColorPanelToolbarDelegate</code> class.
	 */
	public function ASColorPanelToolbarDelegate() {
		m_allIDs = [];
		m_idToPickerMap = NSDictionary.dictionary();
		
		//
		// Populate the internal data structures
		//
		var pickers:NSArray = NSColorPicker._allPickers();
		var arr:Array = pickers.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			var p:NSColorPicking = NSColorPicking(arr[i]);
			m_allIDs.push(p.identifier());
			m_idToPickerMap.setObjectForKey(p, p.identifier());
		}
	}
	
	/**
	 * Initializes the delegate with the color panel.
	 */
	public function initWithColorPanel(panel:NSColorPanel):ASColorPanelToolbarDelegate {
		m_colorPanel = panel;
		
		return this;
	}
	
	//******************************************************
	//*          Adding and removal notification
	//******************************************************
	
	public function toolbarWillAddItem(notification:NSNotification):Void {
	}

	public function toolbarDidRemoveItem(notification:NSNotification):Void {
	}

	//******************************************************
	//*             Selection and population
	//******************************************************

	/**
	 * Returns a tool bar item constructed from the information contained by
	 * the picker.
	 */
	public function toolbarItemForItemIdentifierWillBeInsertedIntoToolbar(
			toolbar:NSToolbar, itemIdentifier:String, flag:Boolean):NSToolbarItem {
		//
		// Get the picker
		//
		var p:NSColorPicking = NSColorPicking(m_idToPickerMap.objectForKey(itemIdentifier));
		
		//
		// Fill the object
		//
		var item:NSToolbarItem = (new NSToolbarItem()).initWithItemIdentifier(itemIdentifier);
		var img:NSImage = p.provideNewButtonImage();
		item.setImage(img);
		
		var cell:NSButtonCell = NSButtonCell(ASToolbarItemButton(
			item.__backView()).cell());
		p.insertNewButtonImageIn(img, cell);
		item.setToolTip(p.buttonToolTip());
		
		//
		// Target-action
		//
		var self:ASColorPanelToolbarDelegate = this;
		var targ:Object = {};
		targ.changePicker = function(tbItem:NSToolbarItem):Void {
			self.m_colorPanel.changePicker(p);
		};
		item.setTarget(targ);
		item.setAction("changePicker");
		
		return item;
	}

	/**
	 * Returns an array of all the picker IDs.
	 */
	public function toolbarDefaultItemIdentifiers(toolbar:NSToolbar):NSArray {
		return NSArray.arrayWithArray(m_allIDs);
	}

	/**
	 * Returns an array of all the picker IDs.
	 */
	public function toolbarSelectableItemIdentifiers(toolbar:NSToolbar):NSArray {
		return NSArray.arrayWithArray(m_allIDs);
	}

}