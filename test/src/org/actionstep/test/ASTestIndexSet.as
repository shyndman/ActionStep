/* See LICENSE for copyright and terms of use */

import org.actionstep.NSIndexSet;
import org.actionstep.NSApplication;
import org.actionstep.NSRange;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestIndexSet {
	public static function test():Void {
		NSApplication.sharedApplication().run();
		
		var is:NSIndexSet = NSIndexSet.indexSetWithIndex(3);
		trace(is);
		is.addIndex(4);
		is.addIndex(1);
		trace(is);
		is.addIndexesInRange(new NSRange(0, 6));
		trace(is);
		is.removeIndex(3);
		is.removeIndex(0);
		is.removeIndex(5);
		trace(is);
	}
}