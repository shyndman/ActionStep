/* See LICENSE for copyright and terms of use */

import org.actionstep.*;

/**
 * Test for the <code>org.actionstep.ASList</code> class.
 * 
 * @author Richard Kilmer 
 */
class org.actionstep.test.ASTestList 
{	
	public static function test():Void
	{
		var app:NSApplication = NSApplication.sharedApplication();
		var window:NSWindow = (new NSWindow()).initWithContentRectSwf(new NSRect(0,0,600,500));
		
		var view:NSView = (new NSView()).initWithFrame(new NSRect(0,0,600,500));
		var list:ASList = (new ASList()).initWithFrame(new NSRect(10, 10, 150, 390));
		list.setFont(NSFont.fontWithNameSizeEmbedded("Arial", 14, false));
		list.setFontColor(new NSColor(0x50545d));
		list.setMultipleSelection(true);
		list.setToggleSelection(true);
		var labels:Array = new Array();
		var data:Array = new Array();
		for(var i:Number = 0;i<3000;i++) {
		  labels[i] = "Test Item "+i;
		  data[i] = i;
		}
		var begin:Number = getTimer();
		list.addItemsWithLabelsData(labels, data);
		trace("elapsed seconds: "+(getTimer() - begin)/1000);
		view.addSubview(list);
		
		var o:Object = new Object();
		o.select = function() { 
		  list.selectItem(ASListItem(list.items().objectAtIndex(99)));
		};
		o.remove = function() {
		  list.removeItemsAtIndexes(list.selectedIndexes());
		};

		var button:NSButton = (new NSButton()).initWithFrame(new NSRect(170,10,70,30));
		button.setTitle("Test");
		button.setTarget(o);
		button.setAction("remove");
		view.addSubview(button);

		window.setContentView(view);
		app.run();
		
		//
		// Close then reopen
		//
		window.setReleasedWhenClosed(false);
		window.close();
		window.show();
	}
}
