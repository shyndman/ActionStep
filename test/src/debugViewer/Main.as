/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.debug.ASDebuggingPanel;
import org.actionstep.NSApplication;

import debugViewer.DebugGet;

/**
 * @author Tay Ray Chuan
 */

class debugViewer.Main {
	public static function main() {
		Stage.align="LT";
		Stage.scaleMode="noScale";
		var main:Main = new Main();
		main.start();
	}

	public function start():Void {
		ASDebuggingPanel.traceLine(
		ASDebugger.INFO,
		">> Beginning Debug Session on "+(new Date()).toString(),
		"debugViewer.Main", "start", 21);
		DebugGet.start();
		NSApplication.sharedApplication().run();
	}
}