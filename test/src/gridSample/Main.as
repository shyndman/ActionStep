import org.actionstep.*;
import org.actionstep.asml.*;

class gridSample.Main {

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
			"test/grid.asml");
		app.run();
	}

}
