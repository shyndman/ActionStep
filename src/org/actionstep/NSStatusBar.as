/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSObject;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSStatusItem;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;

/**
 * A status bar displays a collection of status items that can display 
 * information or be interacted with. Status items can display images, text,
 * menus and can also send action messages to a target when clicked.
 * 
 * For an example of this class' usage, please see
 * <code>org.actionstep.test.ASTestStatusBar</code>.
 * 
 * @see org.actionstep.NSStatusItem
 * @author Scott Hyndman
 */
class org.actionstep.NSStatusBar extends NSObject 
{
	//******************************************************															 
	//*                    Constants
	//******************************************************
	/** Sets the status item length to the status bar thickness. */
	public static var NSSquareStatusItemLength:Number = -103;
	
	/** Sets the status item to adjust dynamically based on its contents. */
	public static var NSVariableStatusItemLength:Number = -105;
	
	//******************************************************															 
	//*                     Members
	//******************************************************
	
	private static var g_systemBar:NSStatusBar;
	private var m_statusItems:NSArray;
	private var m_window:NSWindow;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of NSStatusBar.
	 * 
	 * This method is private. Use {@see #systemStatusBar} to access the status
	 * bar.
	 */
	private function NSStatusBar()
	{
		m_statusItems = new NSArray();
		
		//
		// Register the status bar as an observer for stage resize events.
		//
		NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
			this, "stageDidResize",
			NSApplication.ASStageDidResizeNotification,
			null);
		
		//
		// Create the status bar window.
		//
		m_window = (new NSWindow()).initWithContentRect(
			new NSRect(0, 0, Stage.width, thickness()));
		m_window.setBackgroundColor(ASTheme.current().colorWithName(
			"mainMenuBackgroundColor"));
		m_window.setLevel(NSWindow.NSMainMenuWindowLevel);
		m_window.display();
	}
	
	//******************************************************															 
	//*                    Properties
	//******************************************************
	
	/**
	 * Returns a string representation of the status bar.
	 */
	public function description():String 
	{
		return "NSStatusBar(thickness=" + thickness() + ",statusItems=" 
			+ m_statusItems.description() + ")";
	}
	
	/**
	 * Returns <code>true</code> if this status bar has a vertical orientation.
	 * 
	 * Because the <code>systemStatusBar</code> is the only status bar, this 
	 * method always returns <code>false</code>.
	 */
	public function isVertical():Boolean
	{
		return false;
	}
	
	/**
	 * Returns the thickness of the status bar.
	 * 
	 * This number is configurable through 
	 * <code>ASThemeProtocol#statusBarThickness</code>.
	 */
	public function thickness():Number
	{
		return ASTheme.current().statusBarThickness();
	}
	
	//******************************************************															 
	//*                  Status Items
	//******************************************************
	
	/**
	 * Removes <code>item</code> from the status bar. All remaining items will
	 * shift to the right to fill its space.
	 */
	public function removeStatusItem(item:NSStatusItem):Void
	{
		var idx:Number = m_statusItems.indexOfObject(item);
		
		if (-1 == idx) {
			return;
		}
		
		//
		// Record the length of the item so that we can shift the following 
		// views properly.
		//
		var width:Number = item.length();
		
		//
		// Remove the object.
		//
		m_statusItems.removeObjectAtIndex(idx);
		
		//
		// Shift the views
		//
		shiftToItemAtIndexByLength(idx, width);
	}
	
	/**
	 * Creates and returns a new status item with a length of 
	 * <code>length</code> pixels. The item is immediately added to the status
	 * bar to the left of all other status items.
	 */
	public function statusItemWithLength(length:Number):NSStatusItem
	{
		//
		// Create the status bar.
		//
		var item:NSStatusItem = new NSStatusItem(this);
		item.setLength(length);
			
		//
		// Insert the new status item into the collection.
		//
		m_statusItems.insertObjectAtIndex(item, 0);
		
		//
		// Deal with the status bar's view.
		//
		var x:Number;
		if (m_statusItems.count() == 1)
		{
			x = m_window.frame().maxX() - length;
		}
		else
		{
			x = NSStatusItem(m_statusItems.lastObject()).view().frame()
				.minX() - length;
		}
		
		item.view().setFrameOrigin(new NSPoint(x, 1));		
		m_window.contentView().addSubview(item.view());
		
		return item;
	}
	
	//******************************************************															 
	//*              Stage resize handling
	//******************************************************
	
	/**
	 * Resizes the status bar window to fill the area at the top of the screen.
	 */
	private function stageDidResize(notf:NSNotification):Void
	{
		//
		// Size the status bar window accordingly.
		//
		var stageSize:NSSize = NSSize(
			NSDictionary(notf.userInfo).objectForKey("ASNewSize"));
		var oldStageSize:NSSize = NSSize(
			NSDictionary(notf.userInfo).objectForKey("ASOldSize"));
		m_window.setContentSize(new NSSize(stageSize.width, thickness()));	
		m_window.rootView().setNeedsDisplay(true);
		
		//
		// Shift the children to be right aligned.
		//
		var dx:Number = stageSize.width - oldStageSize.width;
		var arr:Array = m_statusItems.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++)
		{
			var view:NSView = NSStatusItem(arr[i]).view();
			view.setFrameOrigin(
				view.frame().origin.addPoint(new NSPoint(dx, 0)));
		}
	}
	
	//******************************************************															 
	//*                Layout methods
	//******************************************************
	
	/**
	 * Shifts all status items up to, but not including <code>item</code> by
	 * <code>length</code>.
	 * 
	 * For internal use only.
	 */
	public function shiftUpToItemByLength(item:NSStatusItem, length:Number):Void
	{
		var idx:Number = m_statusItems.indexOfObject(item);
		
		if (idx > 0) {
			shiftToItemAtIndexByLength(idx, length);
		}
	}
	
	private function shiftToItemAtIndexByLength(idx:Number, length:Number):Void
	{
		var arr:Array = m_statusItems.internalList();
		var len:Number = arr.length;
		for (var i:Number = len - 1; i >= idx; i--)
		{
			var view:NSView = NSStatusItem(arr[i]).view();
			view.setFrameOrigin(view.frame().origin.addPoint(
				new NSPoint(length, 0)));
		}	
	}
	
	//******************************************************															 
	//*                 Class Methods
	//******************************************************
	
	/**
	 * Returns the system-wide status bar.
	 */
	public static function systemStatusBar():NSStatusBar
	{
		if (null == g_systemBar) {
			g_systemBar = new NSStatusBar();
		}
		
		return g_systemBar;
	}
}