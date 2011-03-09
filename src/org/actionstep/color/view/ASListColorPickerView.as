/* See LICENSE for copyright and terms of use */

import org.actionstep.color.view.ASColorPickerView;
import org.actionstep.NSColorPicker;

/**
 * @author Scott Hyndman
 */
class org.actionstep.color.view.ASListColorPickerView extends ASColorPickerView {
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASListColorPickerView</code> class.
	 */
	public function ASListColorPickerView() {
	}
	
	/**
	 * Initializes and returns the <code>ASListColorPickerView</code> instance with a frame
	 * area of <code>aRect</code>.
	 */
	public function initWithPicker(picker:NSColorPicker):ASListColorPickerView {
		super.initWithPicker(picker);
		
		return this;
	}
}