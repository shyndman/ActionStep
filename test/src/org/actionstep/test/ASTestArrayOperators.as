/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSArray;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestArrayOperators {
	public static function test():Void {

		NSApplication.sharedApplication().run();
		var arr:NSArray = NSArray.arrayWithObjects(
			10,
			2,
			3,
			4,
			10,
			12,
			4,
			5);
		trace(arr);
		trace(arr.valueForKey("@count"));
		trace(arr.valueForKey("@avg"));
		trace(arr.valueForKey("@max"));
		trace(arr.valueForKey("@min"));
		trace(arr.valueForKey("@distinctUnionOfObjects"));

		var arr2:NSArray = NSArray.arrayWithObjects(
			[1, 2, 3, 4],
			[1, 2, 3, 4],
			[1, 2, 3, 4]);
		trace(arr2.valueForKey("@distinctUnionOfArrays"));

		var arr3:NSArray = NSArray.arrayWithObjects(
			[{name: "Fred"}, {name: "Bob"}, {name: "Frank"}],
			[{name: "Fred"}],
			[{name: "Fred"}],
			[{name: "Fred"}, {name: "Lisa"}]);
		trace(arr3.valueForKeyPath("@distinctUnionOfArrays.name"));
	}
}