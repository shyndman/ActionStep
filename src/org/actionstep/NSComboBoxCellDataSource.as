/* See LICENSE for copyright and terms of use */

import org.actionstep.NSComboBoxCell;

/**
 * The <code>NSComboBoxCellDataSource</code> category declares the methods 
 * that an {@link NSComboBoxCell} uses to access the contents of its data source
 * object.
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.NSComboBoxCellDataSource {
	
	//******************************************************
	//*    Returning information about combo box items
	//******************************************************
	
	/**
	 * Implement this method to return the object that corresponds to the item 
	 * at <code>index</code> in <code>aComboBoxCell</code>. Your data source 
	 * must implement this method.
	 */
	public function comboBoxCellObjectValueForItemAtIndex(
		aComboBoxCell:NSComboBoxCell, index:Number):Object;
		
	/**
	 * Implement this method to return the number of items managed for 
	 * <code>aComboBoxCell</code> by your data source object. An 
	 * <code>NSComboBoxCell</code> uses this method to determine how many items 
	 * it should display in its pop-up list. Your data source must implement 
	 * this method.
	 */
	public function numberOfItemsInComboBoxCell(aComboBoxCell:NSComboBoxCell)
		:Number;
}