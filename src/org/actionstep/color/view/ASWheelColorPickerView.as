/* See LICENSE for copyright and terms of use */

import org.actionstep.color.view.ASColorPickerView;
import org.actionstep.NSColorPicker;

/**
 * @author Scott Hyndman
 */
class org.actionstep.color.view.ASWheelColorPickerView extends ASColorPickerView {
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASWheelColorPickerView</code> class.
	 */
	public function ASWheelColorPickerView() {
	}
	
	/**
	 * Initializes and returns the <code>ASWheelColorPickerView</code> instance with a frame
	 * area of <code>aRect</code>.
	 */
	public function initWithPicker(picker:NSColorPicker):ASWheelColorPickerView {
		super.initWithPicker(picker);
		
		return this;
	}
}