import org.actionstep.constants.ASConstantValue;

/**
 * Represents the mode of an <code>NSDatePicker</code>. 
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSDatePickerMode extends ASConstantValue {
	
	/**
	 * Allow selection of a single date.
	 */
	public static var NSSingleDateMode:NSDatePickerMode 
		= new NSDatePickerMode(1);
		
	/**
	 * Allow selection of a range of dates.
	 */
	public static var NSRangeDateMode:NSDatePickerMode 
		= new NSDatePickerMode(2);
	
	/**
	 * Constructs a new instance of the <code>NSDatePickerMode</code> class.
	 */
	private function NSDatePickerMode(value:Number) {
		super(value);
	}
}