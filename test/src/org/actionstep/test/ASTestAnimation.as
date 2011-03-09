/* See LICENSE for copyright and terms of use */

import org.actionstep.*;
import org.actionstep.constants.NSAnimationMode;
import org.actionstep.constants.NSAnimationCurve;

/**
 * @author Tay Ray Chuan
 */

class org.actionstep.test.ASTestAnimation {
	public static function test():Void {
		var inst:ASTestAnimation = new ASTestAnimation();
		inst.start();
	}

	private function start():Void {

		var width:Number = 100, height:Number = 100;

		//
		// Define end, start points and change in distance
		//
		var ex:Number = 210;
		var sx:Number = 10;
		var dx:Number = ex-sx;

		var mc:MovieClip = _root;

		var box1:MovieClip = mc.createEmptyMovieClip("box1", mc.getNextHighestDepth());
		ASDraw.fillRect(box1, 0, 0, width, height, 0xFF0000, 80);
		var box2:MovieClip = mc.createEmptyMovieClip("box2", mc.getNextHighestDepth());
		ASDraw.fillRect(box2, 0, 0, width, height, 0x00FF00, 80);

		var outline1:MovieClip = mc.createEmptyMovieClip("box1outline", mc.getNextHighestDepth());
		ASDraw.drawRect(outline1, box1._x, box1._y, box1._width, box1._height, 0x000000, 40);

		//
		// Define progress marks (in %) for updates
		// (No, I did not type this. Apple did)
		//
		var marks:NSArray = NSArray.arrayWithArray([
		0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5,
		0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0
		]);

		//
		// Main timeline
		//
		var main:ASAnimation = (new ASAnimation()).initWithDurationAnimationCurve(
			5);
		main.setProgressMarks(marks);
		main.setFrameRate(1/100);
		main.setDelegate({
			//
			// This is optional, but we can use it to initialize
			//
			animationShouldStart:function():Boolean {
				trace("START:\tmain");
				outline1._x = box1._x = sx;
				box2._x = ex;

				outline1._y = box1._y = 10;
				box2._y = box1._height + 10 + box1._y;

				return true;
			},
			//
			// Provided are 2 ways to animate: using regular updates, or using progress marks
			// See the difference for yourself (this is not a detergent ad)
			//
			animationDidAdvance:function(foo:NSAnimation, mark:Number):Void {
				box1._x = foo.currentValue()*dx + sx;
			},
			animationDidReachProgressMark:function(foo:NSAnimation, mark:Number):Void {
				box2._x = ex - foo.currentValue()*dx;
			},
			//
			// Run has successfully completed
			// animationDidStop is not implemented because it will not be called. It is called
			// only if the animation is stopped before the run is complete (ie currentProgress!=1)
			//
			animationDidEnd:function():Void {
				trace("END:\tmain");
			}
		});

		//
		// Let's make the outline separate and catchup
		// Separation animation begins when box1 is halfway there, and stops when box1 is 4-fifths there
		// Catchup animation begins when box1 is 4-fifths there
		//
		var sp:Number = 0.5;
		var ep:Number = 0.8;
		var sep:ASAnimation = (new ASAnimation()).initWithDurationAnimationCurve(
			(ep-sp)*main.duration(), NSAnimationCurve.NSEaseInOutSine);
		sep.setFrameRate(main.frameRate());
		sep.setDelegate({
			animationShouldStart: function(foo:NSAnimation) {
				trace("START:\tsep");
				return true;
			},
			animationDidAdvance: function(foo:NSAnimation, mark:Number) {
				outline1._width = width + foo.currentValue()*dx;
			},
			//
			// Animation stopped prematurely.
			// animationDidEnd is not implemented because it will not be called (progress is 0.99).
			//
			animationDidStop: function(foo:NSAnimation) {
				trace("STOP:\tsep "+foo.currentProgress());
			}
		});

		var catchup:ASAnimation = (new ASAnimation()).initWithDurationAnimationCurve(
			(1-ep)*main.duration());
		catchup.setFrameRate(main.frameRate());
		catchup.setDelegate({
			animationShouldStart: function(foo:NSAnimation) {
				trace("START:\tcatchup");
				return true;
			},
			animationDidAdvance: function(foo:NSAnimation, mark:Number) {
				outline1._x = foo.currentValue()*dx + sx;
				outline1._width = width + dx - foo.currentValue()*dx;
			},
			//
			// Animation stopped prematurely.
			// animationDidEnd is not implemented because it will not be called (progress is 0.99).
			//
			animationDidStop: function(foo:NSAnimation) {
				trace("STOP:\tcatchup "+foo.currentProgress());
			}
		});

		sep.startWhenAnimationReachesProgress(main, sp);
		sep.stopWhenAnimationReachesProgress(main, ep);
		//
		// Provide any progress mark less than 1. Here we use 0.9.
		// This is because the "sep" animation ends before it is completed
		//
		catchup.startWhenAnimationReachesProgress(sep, 0.9);

		//
		// Up and away
		//
		main.startAnimation();
	}
}