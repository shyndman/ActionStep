/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.plastic.ASPlasticTheme;
import org.bugtracker.Application;

/**
 * This is the main class for the bug tracker application.
 * 
 * @author Scott Hyndman
 */
class org.bugtracker.MainClass {
	
	/**
	 * The entry point for the application.
	 */
	public static function run():Void {
		ASTheme.setCurrent(new ASPlasticTheme());
		org.actionstep.ASDebugger.debugPanelTrace("hit");
		try {
			var app:Application = (new Application()).init();
		} catch (e:Error) {
			trace(e.toString());
			NSApplication.sharedApplication().run();
		}
	}
}