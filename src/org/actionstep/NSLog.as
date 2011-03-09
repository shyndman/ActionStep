/* See LICENSE for copyright and terms of use */

import org.actionstep.ASStringFormatter;
import org.actionstep.NSArray;

/**
 * This is a class that wraps what would ordinarily be the NSLog() method in
 * Cocoa. The method name is log().
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSLog 
{	
	/**
	 * This is a static class.
	 */
	private function NSLog()
	{
	}
	
	//******************************************************															 
	//*              Public Static Methods
	//******************************************************
	
	/**
	 * Formats a string, appends a timestamp, and traces it. This method is
	 * used by passing a format string, and a number of arguments that should
	 * be injected into the string.
	 *
	 * Format string information can be found at 
	 * http://www.cplusplus.com/ref/cstdio/printf.html
	 *
	 * This method uses org.actionstep.ASStringFormatter to format the string.
	 */
	public static function log(format:String):Void
	{
		var args:Array = arguments.slice(1, arguments.length - 1);;
		
		format += " " + (new Date()).toString(); // Add timestamp
		
		trace(ASStringFormatter.formatString(format, NSArray.arrayWithArray(args)));
	}
}
