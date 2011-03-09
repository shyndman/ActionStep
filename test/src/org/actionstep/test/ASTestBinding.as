/* See LICENSE for copyright and terms of use */

import org.actionstep.binding.NSKeyValueObserving;
//import org.actionstep.binding.NSKeyValueCoding;
import org.actionstep.NSDictionary;
import org.actionstep.NSApplication;


/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestBinding {
	public static function test():Void {
		//
		// Run the application
		//
		NSApplication.sharedApplication().run();
		
		//
		// Create an object to observe
		//
		var obj:Object = {};
		obj.toString = function() {
			return "ASTestBinding::obj";
		};
		obj.foo = {};
		obj.foo.toString = function() {
			return "ASTestBinding::obj.foo";
		};
		obj.foo.bar = 6;
		obj.foo.flox = 3;
		obj.foo.setFlox = function(value:Object):Void {
			// for some unknown reason, this refers to obj not obj.foo
			trace("setting obj.foo.flox to "+value);
			this.flox = value;
		};

		//
		// Create an observer object
		//
		var observer:Object = {};
		observer.observeValueForKeyPathOfObjectChangeContext = function(
			keyPath:String, object:Object, change:NSDictionary, context:Object):Void {
			trace("key path:"+keyPath+", change dict:\n\t"+change);
		};

		//
		// Let's add an observer to the foo.bar property
		//
		NSKeyValueObserving.addObserverWithObjectForKeyPathOptionsContext(
			observer, obj, "foo.bar",
			NSKeyValueObserving.NSKeyValueObservingOptionNew |
			NSKeyValueObserving.NSKeyValueObservingOptionOld, null);

		//
		// This should result in the change dictionary being outputted
		//
		obj.foo.bar = 3;

		//
		// Let's add an observer to the foo.flox property
		//
		NSKeyValueObserving.addObserverWithObjectForKeyPathOptionsContext(
			observer, obj, "foo.flox",
			NSKeyValueObserving.NSKeyValueObservingOptionNew |
			NSKeyValueObserving.NSKeyValueObservingOptionOld, null);

		obj.foo.setFlox(5); // This should result in an output
		obj.foo.setFlox(5); // This should not
		obj.foo.setFlox(4); // This should result in an output

		NSKeyValueObserving.removeObserverWithObjectForKeyPath(
			observer, obj, "foo.flox");

		//
		// This should not result in an output
		//
		obj.foo.setFlox(3);

		//
		// Now let's remove the observer, and make sure no traces are outputted
		//
		NSKeyValueObserving.removeObserverWithObjectForKeyPath(
			observer, obj, "foo.bar");

		obj.foo.bar = 6;
	}
}