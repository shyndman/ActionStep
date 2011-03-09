/* See LICENSE for copyright and terms of use */

import org.actionstep.NSNotificationCenter;
import org.actionstep.ASUtils;
import org.actionstep.ASDebugger;

/**
 * @author Scott Hyndman
 * @author Tay Ray Chuan
 */

class org.actionstep.debug.ASProfiler {

	//******************************************************
	//*                    Constants
	//******************************************************
	static var STACK_OVERHEAD:Number = 0;

	//******************************************************
	//*                  Class members
	//******************************************************

	private static var g_stack:Array = [];
	private static var g_performanceData:Object = {};
	private static var g_processQueue:Array = [];
	//private static var g_methodProcessId:Number;

	private static var g_instance:ASProfiler;

	//******************************************************
	//*                    Notifications
	//******************************************************

	private static var g_nc:NSNotificationCenter =
	NSNotificationCenter.defaultCenter();

	public static var ASProfilerDidEnableProfilingNotification:Number =
	ASUtils.intern("ASProfilerDidEnableProfilingNotification");

	public static var ASProfilerDidDisableProfilingNotification:Number =
	ASUtils.intern("ASProfilerDidDisableProfilingNotification");

	public static var ASProfilerDidProfileNotification:Number =
	ASUtils.intern("ASProfilerDidProfileNotification");

	//******************************************************
	//*                  Construction
	//******************************************************

	private function ASProfiler() {
		//Singleton, not doing anything
	}

	//******************************************************
	//*                  Call stack
	//******************************************************

	/**
	 * The current callstack.
	 */
	public static function callStack():Array {
		return g_stack.slice(0);
	}

	public static function performanceData():Object {
		return g_performanceData;
	}

	/**
	 * Traces out the call stack.
	 */
	public static function dumpCallStack():Void {
		ASDebugger.debugPanelTrace(ASDebugger.info(ASDebugger.dump(callStack())));
	}

	/**
	 * Pushes a method onto the call stack.
	 */
	public static function push(
			className:String,
			methodName:String,
			fileName:String,
			lineNumber:Number,
			scope:Object,
			arguments:FunctionArguments):Void {
		//
		// This object MUST be defined before pushing to the stack, or the code
		// in this method does not appeared in the compiled swf
		// (MTASC bug it seems...)
		//
		var obj:Object = {
			className: className,
			methodName: methodName,
			fileName: fileName,
			linNumber: lineNumber,
			scope: scope,
			arguments: arguments,
			startTime: getTimer(),
			callCount: 1};
		g_stack.push(obj);
	}

	/**
	 * Pops a method descriptor off of the call stack.
	 */
	public static function pop():Void {
		//
		// Record the time and the number of internal calls
		//
		var info:Object = g_stack.pop();
		info.time = getTimer() - info.startTime;
		g_stack[g_stack.length - 1].callCount += info.callCount;

		//
		// Pushes the method descriptor onto the process queue.
		//
		g_processQueue.push(info);
	}

	/**
	 * Enables method profiling.
	 */
	public static function enable():Void {
		//commented out since interval id can be overwritten,
		//and the previous interval cannot be cleared
		//g_methodProcessId = setInterval(instance, "profileMethods", 100);
		if(g_instance==null) {
			g_instance = new ASProfiler();
		}
		g_instance.profileMethods();

		g_nc.postNotificationWithNameObject(
		ASProfilerDidEnableProfilingNotification, ASDebugger);
	}

	/**
	 * Disables method profiling.
	 */
	public static function disable():Object {
		//clearInterval(g_methodProcessId);

		g_nc.postNotificationWithNameObject(
		ASProfilerDidDisableProfilingNotification, ASDebugger);

		g_stack = [];
		g_processQueue = [];

		var ret:Object = g_performanceData;
		g_performanceData = {};
		return ret;
	}

	/**
	 * Writes the profiling data to the debug panel.
	 */
	public static function dumpProfilingData():Void {
		ASDebugger.debugPanelTrace(ASDebugger.info(ASDebugger.dump(g_performanceData)));
	}

	public static function dumpProfilingTable():String {
		var ret:String = "";
		var data:Object;
		var pad:String = "\t\t";
		ret+="\ncount"+pad+"time"+pad+"name\n";
		for(var i:String in g_performanceData) {
			data = g_performanceData[i];
			ret+=data.count+pad+Math.round(data.time*1000)/1000+pad+i+"\n";
		}
		return ret;
	}

	/**
	 * <p>Returns the performance data for the method named <code>methodName</code>
	 * in the class who's full class name (package and class name) is
	 * <code>className</code>.</p>
	 *
	 * <p>The object returned is structured as follows:</p>
	 * <p>{count:Number, time:Number}</p>
	 *
	 * <p><code>count</code> is the number of times the method has been called, and
	 * <code>time</code> is the average number of milliseconds the method took
	 * to run.</p>
	 *
	 * <p>If no performance data could be found, <code>null</code> is returned.</p>
	 */
	public static function performanceDataForFullClassNameMethodName(
			className:String, methodName:String):Object {

		var obj:Object = g_performanceData[className + "." + methodName];
		if (obj == null) {
			return null;
		}

		return obj;
	}

	/**
	 * <p>Processes the methods currently in the process queue, adding their times
	 * to a time array.</p>
	 *
	 * <p>This is an instance method because setInterval won't work on static
	 * methods.</p>
	 */
	private function profileMethods():Void {
		var len:Number = g_processQueue.length;
		for (var info:Object = g_processQueue.pop(); info != null; info = g_processQueue.pop()) {
			var key:String = info.className + "." + info.methodName;

			if (null == g_performanceData[key]) {
				g_performanceData[key] = {count: 1, time: info.time};
			} else {
		    	var data:Object = g_performanceData[key];
				data.time = (info.time
				  - info.callCount * STACK_OVERHEAD // subtract overhead
				  + data.time * data.count) / ++data.count;
			}
		}

		g_nc.postNotificationWithNameObject(
		ASProfilerDidProfileNotification, ASDebugger);
	}
}