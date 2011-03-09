/* See LICENSE for copyright and terms of use */

/**
 * @author Tay Ray Chuan
 */

class org.actionstep.debug.ASCallStack {
	private static var g_callStack:Array = [];

	private function ASCallStack() {
		//Singleton, not doing anything
	}

	public static function enable():Void {
		g_callStack = [];
	}

	public static function disable():Array {
		var arr:Array = g_callStack.slice(0);
		delete g_callStack;
		return arr;
	}

	public static function push(
	klass:String,
	mtd:String,
	file:String,
	line:Number,
	scope:Object,
	arguments:FunctionArguments):Void {
		g_callStack.push([
		klass+"::"+mtd+"("+line+")", file, line, scope
		]);
	}

	public static function pop(line:Number):Void {
		g_callStack.push([
		">>end<<("+line+")", "__end__"
		]);
	}

	public static function dumpCallStack(stack:Array):String {
		if(stack==null) {
			stack = g_callStack;
		}
		var ret:String = "";
		var len:Number = stack.length;
		var level:Number = 0;
		var data:Array;
		var pad:String;

		var helper:Function = function (i:Number):String {
			var str:String = "";
			while(i--) {
				str += "  ";
			}

			return str;
		};

		for (var i : Number = 0; i < len; i++) {
			data = Array(stack.shift());
			pad =
			helper(
			Number((data[1]=="__end__") ?
			--level : level++)
			);
			ret += pad + data[0] + "\n";
		}
		return ret;
	}
}