/* See LICENSE for copyright and terms of use */

import org.actionstep.NSException;
import org.aib.configuration.AppSettings;
import org.aib.configuration.NameValueSectionHandler;

/**
 * Handles the app settings section of a configuration file.
 *
 * @author Scott Hyndman
 */
class org.aib.configuration.AppSettingsSectionHandler 
		extends NameValueSectionHandler{	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>AAppSettingsectionHandler</code>
	 * class.
	 */
	public function AppSettingsSectionHandler() {
		super();
	}
	
	//******************************************************															 
	//*                 Protected Methods
	//******************************************************
	
	/**
	 * Sets an application setting named <code>key</code> to the object
	 * <code>value</code>.
	 * 
	 * This method throws an <code>NSException</code> if an app setting named
	 * <code>key</code> already exists.
	 */
	private function setObjectForKey(value:Object, key:String):Void	{		
		if (!AppSettings.addAppSettingForKey(value, key)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSGeneric,
				"A pair with the key " + key + " already exists" 
				+ "in the app settings dictionary.",
				null);
			trace(e);
			throw e;
		}
	}
}