/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.aib.AIBObject;
import org.aib.configuration.ConfigFileLoader;
import org.aib.configuration.ConfigSections;
import org.actionstep.NSException;

/**
 *
 * @author Scott Hyndman
 */
class org.aib.configuration.AppSettings extends AIBObject {	
	
	//******************************************************															 
	//*                  Class variables
	//******************************************************
	
	private static var g_loader:ConfigFileLoader;
	private static var g_settings:NSDictionary;
	private static var g_target:Object; 
	private static var g_selector:String;
	private static var g_loaded:Boolean;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Static class.
	 */
	private function AppSettings() {
	}
	
	//******************************************************															 
	//*                   Properties
	//******************************************************
	
	/**
	 * Returns a copy of the appSettings dictionary.
	 */
	public static function appSettings():NSDictionary {
		return NSDictionary(g_settings.objectForKey(
			ConfigSections.APPSETTINGS).copyWithZone());
	}
	
	//******************************************************															 
	//*             Loading a configuration file
	//******************************************************
	
	/**
	 * Loads the config file at that can be found at <code>url</code>.
	 * 
	 * When it is finished loading, the <code>obj[sel]()</code> method will be 
	 * called.
	 */
	public static function loadConfigWithContentsOfURLObjectSelector(
			url:String, obj:Object, sel:String):Void {
		g_loaded = false;
		g_target = obj;
		g_selector = sel;
		
		//
		// Begin loading
		//
		g_loader = (new ConfigFileLoader()).initWithContentsOfURL(url);
			
		//
		// Register for the notification
		//
		NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
			AppSettings, "fileDidLoad", 
			ConfigFileLoader.AIBConfigFileDidLoadNotification);
	}

	//******************************************************															 
	//*              Public Static Methods
	//******************************************************
	
	/**
	 * Adds a section named <code>name</code> to the settings dictionary.
	 * 
	 * If <code>name</code> is <code>null</code> an <code>NSException</code>
	 * will be raised.
	 */
	public static function addSectionWithName(name:String):Void {
		if (null == name) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"name argument cannot be null",
				null);
			trace(e);
			throw e;
		}
		
		if (g_settings.objectForKey(name) == null) {
			g_settings.setObjectForKey(NSArray.array(), name);
		}
	}
	
	/**
	 * Adds a setting named <code>name</code> to the section named
	 * <code>sectionName</code> with the value <code>value</code>.
	 */
	public static function addSettingWithSectionNameValue(sectionName:String, 
			value:Object):Void {	
		
		//
		// Create the section if necessary
		//
		addSectionWithName(sectionName);
		
		//
		// Add the setting
		//
		NSArray(g_settings.objectForKey(sectionName)).addObject(
			value);
	}
		
	/**
	 * Adds an application setting named <code>name</code> with the value
	 * <code>setting</code>.
	 * 
	 * If a setting named <code>name</code> already exists, this method will
	 * return <code>false</code> and will not overwrite the value. Otherwise
	 * the value is added and <code>true</code> is returned.
	 */
	public static function addAppSettingForKey(setting:Object, name:String)
			:Boolean { 		
		var appSettings:NSDictionary = NSDictionary(g_settings.objectForKey(
			ConfigSections.APPSETTINGS));
		
		if (appSettings == null) {
			appSettings = new NSDictionary();
			g_settings.setObjectForKey(appSettings, 
				ConfigSections.APPSETTINGS);
		}
			
		//
		// Uniqueness check
		//
		if (appSettings.objectForKey(name) != null) {
			return false;
		}
			
		appSettings.setObjectForKey(setting, name);
		return true;
	}
	
	/**
	 * Returns the application setting with <code>name</code>, or 
	 * <code>null</code> if none is found.
	 */
	public static function appSettingWithName(name:String):String
	{
		return NSDictionary(g_settings.objectForKey(
			ConfigSections.APPSETTINGS)).objectForKey(name).toString();
	}
	
	
	/**
	 * Returns the configuration section named <code>name</code>, or
	 * <code>null</code> if the configuration section could not be found.
	 * 
	 * The return value is an array of anonymous objects with 
	 * <code>name</code> and <code>value</code> properties.
	 */
	public static function sectionWithName(name:String):NSArray {
		var ret:NSArray = NSArray(g_settings.objectForKey(name));
		
		return ret == null ? null : ret;
	}
		
	//******************************************************															 
	//*                  Events Handlers
	//******************************************************
	
	/** 
	 * Fired when the <code>AConfigFileLoader/code> completes loading the 
	 * configuration.
	 */
	private static function fileDidLoad(ntf:NSNotification):Void {
		g_loaded = true;
		g_target[g_selector](ntf);
		
		//
		// Deregister as an observer.
		//
		NSNotificationCenter.defaultCenter().removeObserverNameObject(
			AppSettings, null, g_loader);
	}
		
	//******************************************************															 
	//*                Static Constructor
	//******************************************************
	
	/**
	 * Static constructor.
	 */
	private static function initialize():Void {			
		g_settings = NSDictionary.dictionary();
		g_loaded = false;
	}
}
