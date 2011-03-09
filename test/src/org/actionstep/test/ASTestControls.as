/* See LICENSE for copyright and terms of use */

import org.actionstep.*;
import org.actionstep.asml.ASAsmlReader;

class org.actionstep.test.ASTestControls {
  
	public static var lblDependency:Function = org.actionstep.ASLabel;
	public static function test() {
		//
		// Create app and windows.
		//
		var app:NSApplication = NSApplication.sharedApplication();
		app.run();
		
		NSCursor.setUseSystemArrowCursor(false);
		
		var items:NSArray = new NSArray();
		items.addObject((new ASListItem()).initWithLabelData("Richard Kilmer", null));
		items.addObject((new ASListItem()).initWithLabelData("Steve Minuk", null));
		items.addObject((new ASListItem()).initWithLabelData("Ray Chuan", null));
		
		items.addObject((new ASListItem()).initWithLabelData("Peter Drinkwater", null));
		items.addObject((new ASListItem()).initWithLabelData("Mike Gunn", null));
		items.addObject((new ASListItem()).initWithLabelData("Richard Kilmer", null));
		items.addObject((new ASListItem()).initWithLabelData("Rachel Manno", null));
		items.addObject((new ASListItem()).initWithLabelData("Scott Hyndman", null));
		
		var reader:ASAsmlReader = (new ASAsmlReader()).initWithUrl("test/controls.asml");	
		reader.asmlFile().associateIdWithObject("listItems", items);
		
		app.run();
	}

}
