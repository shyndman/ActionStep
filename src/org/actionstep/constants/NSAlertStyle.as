/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * The following constants are specific to <code>org.actionstep.NSAlert</code>, and control
 * the style of the alert to be displayed, which is indicative of the severity or importance
 * of the alert to the user.
 */
class org.actionstep.constants.NSAlertStyle extends ASConstantValue {
	/**
	 * An alert used to warn the user about a current or impending event. The purpose
	 * is more than informational but not critical. This is the default alert style.
	 */
	public static var NSWarning:NSAlertStyle		 = new NSAlertStyle(0);

	/** An alert used to inform the user about a current or impending event. */
	public static var NSInformational:NSAlertStyle	 = new NSAlertStyle(1);

	/**
	 * Reserved this style for critical alerts, such as when there might be
	 * severe consequences as a result of a certain user response (for
	 * example, a “clean install” will erase all data on a volume). This style
	 * causes the icon to be badged with a caution icon.
	 */
	public static var NSCritical:NSAlertStyle	 = new NSAlertStyle(2);

	public function NSAlertStyle(value:Number) {
		super(value);
	}
}
