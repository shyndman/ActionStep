/* See LICENSE for copyright and terms of use */

import org.actionstep.NSComboBox;
import org.actionstep.NSNotification;

/**
 * <p>This is not an interface that you actually need to implement. Rather, these
 * are the method signitures that the combobox will expect on its delegate</p>
 * 
 * <p>You can implement as few or as many of these methods as you like, and the
 * combobox will accomodate the delegate as required.</p>
 * 
 * @see NSComboBox
 * @see NSComboBox#setDelegate()
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.comboBox.ASComboBoxDelegate {
	
	/**
	 * <p>
	 * Informs the delegate that the pop-up list selection has finished 
	 * changing.
	 * </p>
	 * <p>
	 * <code>ntf</code> is an <code>NSComboBoxSelectionDidChangeNotification</code>.
	 * </p> 
	 */
	public function comboBoxSelectionDidChange(ntf:NSNotification):Void;
	
	/**
	 * <p>
	 * Informs the delegate that the pop-up list selection is changing.
	 * </p>
	 * <p>
	 * <code>ntf</code> is an <code>NSComboBoxSelectionIsChangingNotification</code>.
	 * </p> 
	 */
	public function comboBoxSelectionIsChanging(ntf:NSNotification):Void;
	
	/**
	 * <p>
	 * Informs the delegate that the pop-up list is about to be dismissed.
	 * </p>
	 * <p>
	 * <code>ntf</code> is an <code>NSComboBoxWillDismissNotification</code>.
	 * </p> 
	 */
	public function comboBoxWillDismiss(ntf:NSNotification):Void;
	
	/**
	 * <p>
	 * Informs the delegate that the pop-up list is about to be displayed.
	 * </p>
	 * <p>
	 * <code>ntf</code> is an <code>NSComboBoxWillPopUpNotification</code>.
	 * </p> 
	 */
	public function comboBoxWillPopUp(ntf:NSNotification):Void;	
}