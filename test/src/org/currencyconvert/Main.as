import org.actionstep.*;
import org.currencyconvert.*;

/**
 * Entry point for application
 *
 * @author	Ben Longoria
 * @version	0.5
 */
class org.currencyconvert.Main {
	
	
	/**
	 * Entry point for application
	 */
	public static function start():Void {
		Stage.align="LT";
		Stage.scaleMode="noScale";
		
		ASDebugger.setLevel(ASDebugger.INFO);
		
		try{
			init();
		} catch (e:Error) {
			trace(e.message);
		}
	}
	
	/**
	 * Instantiates main application classes
	 */
	private static function init():Void {
		//get app
		var app:NSApplication = NSApplication.sharedApplication();
		
		//init main parts
		var converter:Converter = Converter((new Converter()).init());
		var converterController:ConverterController 
			= (new ConverterController()).initWithModel(converter);
		
		//start app
		app.run();
		
	}
	
}
