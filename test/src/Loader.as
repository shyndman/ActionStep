/* See LICENSE for copyright and terms of use */

class Loader {

	private static var libraryCount:Number = 0;

	public static function loadLibraryWithCallbackSelectorData(swfURL:String, callback:Object, selector:String, data:Object) {
		var baseClip:MovieClip = _root.__LIBRARIES__;
		if (baseClip == undefined) {
			baseClip = _root.createEmptyMovieClip("__LIBRARIES__", -15893);
			baseClip._x = -1000;
			baseClip._y = -1000;
		}

		_root.createTextField("__LOADING_MESSAGE__", 10000, 20, 20, 200, 30);
		var loadingMessage:TextField = _root.__LOADING_MESSAGE__;
		loadingMessage.text = "LOADING...";
		var my_fmt:TextFormat = new TextFormat();
		my_fmt.font = "Verdana";
		my_fmt.size = 20;
		my_fmt.bold = true;
		my_fmt.color = 0xF0A050;
		loadingMessage.setTextFormat(my_fmt);
		loadingMessage._width = loadingMessage.textWidth+3;
		loadingMessage._height = loadingMessage.textHeight+3;
		loadingMessage._x = 10;
		loadingMessage._y = 10;

		libraryCount++;
		var loaderClip:MovieClip = baseClip.createEmptyMovieClip(
			"Library" + libraryCount, libraryCount);
		var monitor:Object = new Object();
		var swfToLoad:String = swfURL;
		var objectToCall:Object = callback;
		var selectorToCall:String = selector;
		var dataToPass:Object = data;
		monitor.onLoadInit = function(target_mc:MovieClip) {
			loadingMessage.removeTextField();
			objectToCall[selectorToCall].call(objectToCall, dataToPass);
		};
		var image_mcl:MovieClipLoader = new MovieClipLoader();
		image_mcl.addListener(monitor);
		image_mcl.loadClip(swfToLoad, loaderClip);
	}
}