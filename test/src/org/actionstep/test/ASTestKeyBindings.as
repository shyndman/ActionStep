/* See LICENSE for copyright and terms of use */

import org.actionstep.events.ASKeyBindingsTable;
import org.actionstep.NSApplication;
import org.actionstep.NSDictionary;
import org.actionstep.events.ASKeyBinding;

/**
 * Performs tests related to key binding.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestKeyBindings {
	public static function test():Void {
		var app:NSApplication = NSApplication.sharedApplication();
		app.run();
		
		//
		// Create a key binding table and add a few things to it
		//
		var table:ASKeyBindingsTable = (new ASKeyBindingsTable()).init();
		
		table.bindKeyToAction("Control-c", "foo");
		table.bindKeyToAction("Control-c", "foo2");
		table.bindKeyToAction("Control-c", "foo2"); // shouldn't be added
		table.bindKeyToAction("Alternate-Control-f", "foo");
		table.bindKeyToAction("Shift-Home", "foo");
		table.bindKeyToAction("Shift-PageUp", "foo");
		table.bindKeyToAction("A-C-S-q", "foo");
		
		trace(table.description());
		
		//
		// Bind a dictionary of key bindings to a key 
		//
		var secondLevel:NSDictionary = NSDictionary.dictionary();
		secondLevel.setObjectForKey("undo", "Control-z");
		secondLevel.setObjectForKey("find", "Control-f");
		secondLevel.setObjectForKey("redo", "Control-y");
		secondLevel.setObjectForKey("bold", "Control-b");
		table.bindKeyToAction("Alt-o", secondLevel);
		
		trace(table.description());
		
		//
		// Get the default bindings
		//
		table = ASKeyBindingsTable.defaultBindings();
		trace(table);
		
		//
		// Get a binding
		//
		var binding:ASKeyBinding = table.keyBindingForStrokeModifiers("PageUp", 0);
		trace(binding);
	}
}