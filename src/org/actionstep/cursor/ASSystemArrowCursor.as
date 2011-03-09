/* See LICENSE for copyright and terms of use */

import org.actionstep.NSCursor;

/**
 * This is a special cursor that when drawn, displays the system cursor
 * instead of an image.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.cursor.ASSystemArrowCursor extends NSCursor 
{
	//******************************************************															 
	//*                Overridden methods
	//******************************************************
	
	/**
	 * Shows the system arrow cursor.
	 */
	public function draw():Void
	{
		var mc:MovieClip = cursorClip();
		mc.cacheAsBitmap = false;
		mc.clear();
		
		Mouse.show();
	}
	
	/**
	 * Hides the system arrow cursor.
	 */
	private function cursorDidHide():Void
	{
		Mouse.hide();
	}
}