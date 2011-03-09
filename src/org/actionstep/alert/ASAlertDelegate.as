/* See LICENSE for copyright and terms of use */

import org.actionstep.NSAlert;

/**
 * Describes method to be implemented by the delegate of an NSAlert instance.
 * 
 * @see NSAlert#setDelegate()
 * @author Scott Hyndman
 */
interface org.actionstep.alert.ASAlertDelegate {

	/**
	 * <p>Sent to the delegate when the user clicks the alert’s help button. 
	 * The delegate causes help to be displayed for an alert, directly or 
	 * indirectly.</p>
	 * 
	 * <p>Returns <code>true</code> when the delegate displayed help directly, 
	 * or <code>false</code> otherwise. When <code>false</code> and the alert 
	 * has a help anchor ({@link NSAlert#setHelpAnchor()}), the application’s 
	 * help manager displays help using the help anchor.</p>
	 */
	public function alertShowHelp(anAlert:NSAlert):Boolean;	
}