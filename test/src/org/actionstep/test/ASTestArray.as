/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSComparisonResult;
import org.actionstep.NSArray;
import org.actionstep.NSSortDescriptor;
import org.actionstep.test.arrays.ASTestArrayElement;
import org.actionstep.NSApplication;

/**
 * Tests the <code>NSArray</code> class.
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestArray 
{	
	public static function test():Void
	{
		var start:Number;
		var arrStrings:Array = [
			"this", 
			"is", 
			"a",
			"test!",
			"look",
			"what",
			"it",
			"does!"
			];
		var arr:NSArray = NSArray.arrayWithArray(arrStrings);
		
		var sd:NSSortDescriptor = (new NSSortDescriptor()).initWithKeyAscending(null, true);
		
		arr.sortUsingDescriptors(NSArray.arrayWithObject(sd));
		
		NSApplication.sharedApplication().run();
		trace(arr);
	}
	
	private static function compareNums(a:Number, b:Number, context:Object):Number
	{
		if (a < b)
			//return NSComparisonResult.NSOrderedAscending;
			return -1;
		else if (a > b)
			return 1;
			//return NSComparisonResult.NSOrderedDescending;
			
		return 0;
		//return NSComparisonResult.NSOrderedSame;
	}
	
	private static function compareDates(a:Date, b:Date, context:Object):NSComparisonResult
	{
		if (a.getTime() < b.getTime())
			return NSComparisonResult.NSOrderedAscending;
		else if (a.getTime() > b.getTime())
			return NSComparisonResult.NSOrderedDescending;
			
		return NSComparisonResult.NSOrderedSame;
	}
}