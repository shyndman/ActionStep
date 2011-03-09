/* See LICENSE for copyright and terms of use */

import org.actionstep.NSComboBoxCellDataSource;
import org.actionstep.NSComboBoxCell;

/**
 * This interface provides smart search capabilities to the combobox cell
 * accessing this datasource.
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.NSComboBoxCellSearchingDataSource extends NSComboBoxCellDataSource {
	//******************************************************
	//*           Working with entered strings
	//******************************************************
	
	/**
	 * <p>An <code>NSComboBoxCell</code> uses this method to perform incremental—or
	 * “smart”—searches when the user types into the text field. Your 
	 * implementation should return the first complete string that starts with 
	 * <code>uncompletedString</code>.</p>
	 * 
	 * <p>As the user types in the text field, the receiver uses this method to 
	 * search for items from the pop-up list that start with what the user has 
	 * typed. The receiver adds the new text to the end of the field and selects
	 * the new text, so when the user types another character, it replaces the 
	 * new text.</p>
	 * 
	 * <p>This method is optional. If you don’t implement it, the receiver does 
	 * not perform incremental searches.</p>
	 */
	public function comboBoxCellCompletedString(aComboBoxCell:NSComboBoxCell,
		uncompletedString:String):String;
		
	/**
	 * <p>An <code>NSComboBoxCell</code>, <code>aComboBoxCell</code>, uses this 
	 * method to synchronize the pop-up list’s selected item with the text 
	 * field’s contents. Your implementation of this method should return the 
	 * index for the item that matches <code>aString</code>, or 
	 * {@link org.actionstep.NSObject#NSNotFound} if no item matches. If 
	 * {@link #comboBoxCellCompletedString} is implemented, <code>aString</code>
	 * is the string returned by that method. Otherwise, <code>aString</code> is
	 * the text that the user has typed.</p>
	 */
	public function comboBoxCellIndexOfItemWithStringValue(
		aComboBoxCell:NSComboBoxCell, aString:String):Number;	
}