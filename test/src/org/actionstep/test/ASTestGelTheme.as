/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.NSSize;

import flash.filters.BlurFilter;
import flash.filters.DropShadowFilter;
import flash.geom.Matrix;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestGelTheme {
	public static function test():Void {		
		var btn:MovieClip = createGelButton(new NSSize(100, 25), 0xCCCCCC);
		btn._x = btn._y = 10;
		
		var btn2:MovieClip = createGelButton(new NSSize(25, 25), 0xAFAFAF);
		btn2._y = 10;
		btn2._x = 115;
		
		var btn3:MovieClip = createGelButton(new NSSize(30, 50), 0x999999);
		btn3._y = 40;
		btn3._x = 10;		
	}
	
	public static function createGelButton(aSize:NSSize, baseColor:Number):MovieClip {
		//
		// Aqua button
		//
		var depth:Number = _root.getNextHighestDepth();
		var button:MovieClip = _root.createEmptyMovieClip("button" + depth, depth);
		var upperHl:MovieClip = button.createEmptyMovieClip("upperHl", 1);
		var lowerHl:MovieClip = button.createEmptyMovieClip("lowerHl", 2);
		var base:MovieClip = button.createEmptyMovieClip("base", 0);
		var w:Number = aSize.width;
		var h:Number = aSize.height;
		var r:Number = Math.floor(Math.min(w, h) / 2);
		var dx:Number = (w - w * .97) / 2;
		var dy:Number = (h - h * .97) / 2;
		
		//
		// Draw base
		//
		base.lineStyle(undefined, 0, 100);
		base.beginFill(baseColor, 100);
		ASDraw.drawRoundedRect(base, 0, 0, w, h, r);
		base.endFill();
		base.filters = [new DropShadowFilter(10, 45, 0x000000, .5, 15, 15, .75, 2, false, false, false)];
		 
		//
		// Draw upper highlight
		//
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(w, h / 2, ASDraw.getRadiansByDegrees(90));
		upperHl.lineStyle(undefined, 0, 100);
		upperHl.beginGradientFill("linear", [0xFFFFFF, 0xFFFFFF], [70, 0], 
			[75, 255], matrix);
		ASDraw.drawRoundedRect(upperHl, 0, 0, w, h, r);
		upperHl.endFill();
		upperHl._width -= 2 * dx;
		upperHl._height -= 2 * dy;
		upperHl._x = dx;
		upperHl._y = dy;
		upperHl.filters = [new BlurFilter(3, 3, 3)];
		
		//
		// Draw lower highlight
		//
		matrix = new Matrix();
		matrix.createGradientBox(w, h / 2, ASDraw.getRadiansByDegrees(90));
		lowerHl.lineStyle(undefined, 0, 100);
		lowerHl.beginGradientFill("linear", [0xFFFFFF, 0xFFFFFF], [70, 0], 
			[20, 155], matrix);
		ASDraw.drawRoundedRect(lowerHl, 0, 0, w, h, r);
		lowerHl.endFill();
		lowerHl._width -= 2 * dx;
		lowerHl._height -= 5 * dy;
		lowerHl._x = dx;
		lowerHl._y = lowerHl._height - dy;
		lowerHl._yscale *= -1;
		lowerHl._alpha = 85;
		lowerHl.blendMode = "overlay";
		
		return button;
	}
}