/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Represents the style of an <code>NSDatePicker</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSDatePickerStyle extends ASConstantValue {
	
	/**
	 * Provide a text field and stepper style interface. 
	 */
	public static var NSTextFieldAndStepperDatePickerStyle:NSDatePickerStyle
		= new NSDatePickerStyle(0);
		
	/**
	 * Provide a visual clock and calendar style interface.
	 */
	public static var NSClockAndCalendarDatePickerStyle:NSDatePickerStyle
		= new NSDatePickerStyle(0);
	
	/**
	 * Constructs a new instance of the <code>NSDatePickerStyle</code> class.
	 */
	private function NSDatePickerStyle(value:Number) {
		super(value);
	}
}