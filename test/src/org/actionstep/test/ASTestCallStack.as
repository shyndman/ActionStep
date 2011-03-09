/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.debug.ASCallStack;

/**
 * @author Tay Ray Chuan
 */

class org.actionstep.test.ASTestCallStack {
	public static function test():Void {
		//IF start logging from here,
		//ASDebugger.enableMethodLogging();
		//ENDIF
		var inst:ASTestCallStack = new ASTestCallStack();
		inst.main();
	}

	public function main():Void {
		var stack:Array = ASCallStack.disable();
		trace(ASDebugger.info(ASCallStack.dumpCallStack(stack)));
	}
}