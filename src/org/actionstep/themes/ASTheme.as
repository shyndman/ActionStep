/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.NSDictionary;
import org.actionstep.NSNotificationCenter;
import org.actionstep.themes.ASThemeProtocol;
import org.actionstep.themes.standard.ASStandardTheme;

/**
 * <p>This class is used to set and access the current theme.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.themes.ASTheme extends org.actionstep.NSObject {
	
	//******************************************************
	//*                  Notifications
	//******************************************************
	
	/**
	 * Posted to the default notification center when the current theme changes.
	 *
	 * The userInfo dictionary contains the following:
	 *   "ASOldTheme" - The old theme (<code>ASThemeProtocol</code>)
	 *   "ASNewTheme" - The new theme (<code>ASThemeProtocol</code>)
	 */
	public static var ASThemeDidChangeNotification:Number
		= ASUtils.intern("ASThemeDidChangeNotification");
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private static var g_current:ASThemeProtocol;
	
	//******************************************************
	//*               Public Static Properties
	//******************************************************
	
	/**
	* Returns the current theme.
	*/
	public static function current():ASThemeProtocol {
		if (g_current == undefined) {
			setCurrent(new ASStandardTheme());
		}
		return g_current;
	}
	
	/**
	* Sets the current theme to <code>value</code>.
	*
	* This method results in an <code>ASThemeDidChangeNotification</code> being
	* posted to the default notification center.
	*/
	public static function setCurrent(value:ASThemeProtocol) {
		var old:ASThemeProtocol = g_current;
		
		if (g_current != undefined) {
			g_current.setActive(false);
		}
		g_current = value;
		g_current.setActive(true);
		
		//
		// Build and post notification
		//
		var userInfo:NSDictionary = NSDictionary.dictionaryWithObjectForKey(
			g_current, "ASNewTheme");
		if (null != old) {
			userInfo.setObjectForKey(old, "ASOldTheme");
		}
		
		NSNotificationCenter.defaultCenter().postNotificationWithNameObjectUserInfo(
			ASThemeDidChangeNotification,
			ASTheme,
			userInfo);
	}
}
