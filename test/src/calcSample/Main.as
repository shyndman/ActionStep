/* See LICENSE for copyright and terms of use */

import org.actionstep.*;
import org.actionstep.asml.*;

class calcSample.Main {

	public static function main() {
		Stage.align="LT";
		Stage.scaleMode="noScale";
		var main:Main = new Main();
		main.start();
	}

	public function start() {
		Loader.loadLibraryWithCallbackSelectorData("ActionStepLib.swf", this, "loadAibFile");
	}

	public function loadAibFile() {
		var app:NSApplication = NSApplication.sharedApplication();
		var reader:ASAsmlReader = (new ASAsmlReader()).initWithUrl(
			"test/calculator.asml");
		app.run();
	}

}
