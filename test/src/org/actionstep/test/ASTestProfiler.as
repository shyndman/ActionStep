/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSNotification;
import org.actionstep.NSArray;
import org.actionstep.constants.NSComparisonResult;
import org.actionstep.NSSortDescriptor;
import org.actionstep.debug.ASProfiler;

/**
 * @author Tay Ray Chuan
 */

class org.actionstep.test.ASTestProfiler {
	private static var SORT_PROPERTIES:Array = [
	"count",
	"time",
	"name"];

	private static var SORT_PROPERTY:String = SORT_PROPERTIES[2];

	public static function test():Void {
		var inst:ASTestProfiler = new ASTestProfiler();
		inst.main();
	}

	public function main():Void {
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		nc.addObserverSelectorNameObject(
		this, "dumpProfilingInfo",
		ASProfiler.ASProfilerDidProfileNotification, ASDebugger);

		//alternatively, you can use:
		//ASDebugger.dumpProfilingData();

		ASProfiler.enable();
	}

	public function dumpProfilingInfo(n:NSNotification):Void {
		var data:Object = ASProfiler.performanceData();

		var sorted:NSArray = NSArray.array();
		var temp:Array;
		var len:Number;

		for(var i:String in data) {
			//very fancy way of using :: to separate klass and method
			//I expect performance problems; you can safely comment this out
			///*
			temp = i.split(".");
			len = temp.length;
			temp.splice(len-2, 2, [temp[len-2], temp[len-1]].join("::"));
			data[i].name = temp.join(".");
			//*/

			sorted.addObject(data[i]);
		}

		//
		// Sort data
		//
		// Data will be sorted as: count DESC, time ASC
		//
		var descriptors:NSArray = NSArray.array();
		var sd:NSSortDescriptor = (new NSSortDescriptor()).initWithKeyAscending(
			SORT_PROPERTIES[0], false);
		descriptors.addObject(sd);
		sd = (new NSSortDescriptor()).initWithKeyAscending(
			SORT_PROPERTIES[1], true);
		descriptors.addObject(sd);
		sorted.sortUsingDescriptors(descriptors);

		//alternatively, use a compare function
		//sorted.sortUsingFunctionContext(sortColumn);

		//
		// Print data
		//
		var result:String = "";
		var arr:Array = sorted.internalList();
		var pad:String = "\t\t";
		result+="\ncount"+pad+"time"+pad+"name\n";

		for(var i:String in arr) {
			data = arr[i];
			result+=data.count+pad+Math.round(data.time*1000)/1000+pad+data.name+"\n";
		}

		trace(ASDebugger.info(result));
	}

	public function sortColumn(a1:Object, b1:Object):NSComparisonResult {
		var a:Object = a1[SORT_PROPERTY];
		var b:Object = b1[SORT_PROPERTY];

		if (a < b)
			return NSComparisonResult.NSOrderedAscending;
		else if (a > b)
			return NSComparisonResult.NSOrderedDescending;

		return NSComparisonResult.NSOrderedSame;
	}
}