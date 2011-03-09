/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSRunResponse;

/**
 * The following values are derivatives of <code>org.actionstep.constants.NSRunResponse</code>,
 * since functions handling these values are not aware of their content and merely
 * pass it along.
 *
 * These values are used as return codes from <code>NSAlert</code> functions.
 *
 * Please note that return values for buttons are position dependant. If you have
 * more than three buttons on your alert, the button-position return value is
 * NSThirdButtonReturn + n, where n is an integer.
 * 
 * Localization is as yet unsupported.
 */
class org.actionstep.constants.NSAlertReturn extends NSRunResponse {

	//******************************************************
	//*                 Class members
	//******************************************************
	
	/**
	 * A map of constant values to constants.
	 */
	private static var g_valueToConstant:Object ;

	//******************************************************
	//*           Return values for alert panels
	//******************************************************

	/**
	 * The value returned if running the NSAlertPanel resulted in an error.
	 */
	public static var NSError:NSAlertReturn	 = new NSAlertReturn(-2);

	//******************************************************
	//*             Return values for buttons
	//******************************************************

	/** The user clicked the first (rightmost) button on the dialog or sheet. */
	public static var NSFirstButton:NSAlertReturn = new NSAlertReturn(1000);

	/** The user clicked the second button from the right edge of the dialog or sheet. */
	public static var NSSecondButton:NSAlertReturn = new NSAlertReturn(1001);

	/** The user clicked the third button from the right edge of the dialog or sheet. */
	public static var NSThirdButton:NSAlertReturn = new NSAlertReturn(1002);

	//******************************************************
	//*                 Construction
	//******************************************************

	/**
	 * Private constructor
	 */
	private function NSAlertReturn(value:Number) {
		super(value);
		
		if (g_valueToConstant == null) {
			g_valueToConstant = {};
		}
		
		g_valueToConstant[value.toString()] = this;
	}
	
	//******************************************************
	//*            Getting other return values
	//******************************************************
	
	/**
	 * Returns the alert return constant for the specified button number. The
	 * button number is 0-indexed, so 0 corresponds to the first button, 1 to
	 * the second and so on.
	 */
	public static function alertReturnForButtonNumber(num:Number):NSAlertReturn {
		return alertReturnForValue(NSFirstButton.value + num);
	}
	
	/**
	 * Returns the alert return constant for the specified constant value.
	 */
	public static function alertReturnForValue(val:Number):NSAlertReturn {
		var ret:NSAlertReturn = NSAlertReturn(g_valueToConstant[val.toString()]);
		
		if (ret == null) {
			ret = new NSAlertReturn(val);
		}
		
		return ret;
	}
}
