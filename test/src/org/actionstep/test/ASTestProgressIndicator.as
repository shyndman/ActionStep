/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSWindow;
import org.actionstep.NSRect;
import org.actionstep.ASColors;
import org.actionstep.NSProgressIndicator;
import org.actionstep.NSView;
import org.actionstep.NSTimer;
import org.actionstep.constants.NSProgressIndicatorStyle;

/**
 * Tests the <code>org.actionstep.NSProgressIndicator</code> class.
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestProgressIndicator
{
	private static var instance:ASTestProgressIndicator;
	private function ASTestProgressIndicator() {
	}

	private static function getInstance():ASTestProgressIndicator {
		if (instance == null) {
			instance = new ASTestProgressIndicator();
		}
		return instance;
	}

	public static function test():Void
	{
		var wnd:NSWindow = new NSWindow();
		wnd.initWithContentRect(new NSRect(0, 0, 500, 400));
		wnd.setBackgroundColor(ASColors.greenColor());
		var stage:NSView = wnd.contentView();
		var determinateIndicators:Array = new Array();

//////////////////  THICK

		var pb1:NSProgressIndicator = new NSProgressIndicator();
		pb1.initWithFrame(new NSRect(10, 10, 40, 40));
		pb1.setStyle(NSProgressIndicatorStyle.NSProgressIndicatorSpinningStyle);
		pb1.startAnimation();
		stage.addSubview(pb1);

		var pb2:NSProgressIndicator = new NSProgressIndicator();
		pb2.initWithFrame(new NSRect(10, 60, 120, 40));
		stage.addSubview(pb2);
		determinateIndicators.push(pb2);

		var pb3:NSProgressIndicator = new NSProgressIndicator();
		pb3.initWithFrame(new NSRect(10, 110, 120, 40));
		pb3.setIndeterminate(true);
		pb3.startAnimation();
		stage.addSubview(pb3);

		var pb4:NSProgressIndicator = new NSProgressIndicator();
		pb4.initWithFrame(new NSRect(10, 160, 120, 40));
		pb4.setAnimated(true);
		pb4.startAnimation();
		stage.addSubview(pb4);
		determinateIndicators.push(pb4);

		var pb5:NSProgressIndicator = new NSProgressIndicator();
		pb5.initWithFrame(new NSRect(10, 210, 120, 40));
		pb5.setBezeled(false);
		stage.addSubview(pb5);
		determinateIndicators.push(pb5);

		var pb6:NSProgressIndicator = new NSProgressIndicator();
		pb6.initWithFrame(new NSRect(10, 260, 120, 40));
		pb6.setAnimated(true);
		pb6.setBezeled(false);
		pb6.startAnimation();
		stage.addSubview(pb6);
		determinateIndicators.push(pb6);

		var pb7:NSProgressIndicator = new NSProgressIndicator();
		pb7.initWithFrame(new NSRect(10, 310, 120, 40));
		pb7.setIndeterminate(true);
		pb7.setBezeled(false);
		pb7.startAnimation();
		stage.addSubview(pb7);

//////////////////  MEDIUM

		var pb8:NSProgressIndicator = new NSProgressIndicator();
		pb8.initWithFrame(new NSRect(140, 10, 20, 20));
		pb8.setStyle(NSProgressIndicatorStyle.NSProgressIndicatorSpinningStyle);
		pb8.startAnimation();
		stage.addSubview(pb8);

		var pb9:NSProgressIndicator = new NSProgressIndicator();
		pb9.initWithFrame(new NSRect(140, 60, 120, 20));
		stage.addSubview(pb9);
		determinateIndicators.push(pb9);

		var pb10:NSProgressIndicator = new NSProgressIndicator();
		pb10.initWithFrame(new NSRect(140, 110, 120, 20));
		pb10.setIndeterminate(true);
		pb10.startAnimation();
		stage.addSubview(pb10);

		var pb11:NSProgressIndicator = new NSProgressIndicator();
		pb11.initWithFrame(new NSRect(140, 160, 120, 20));
		pb11.setAnimated(true);
		pb11.startAnimation();
		stage.addSubview(pb11);
		determinateIndicators.push(pb11);

		var pb12:NSProgressIndicator = new NSProgressIndicator();
		pb12.initWithFrame(new NSRect(140, 210, 120, 20));
		pb12.setBezeled(false);
		stage.addSubview(pb12);
		determinateIndicators.push(pb12);

		var pb13:NSProgressIndicator = new NSProgressIndicator();
		pb13.initWithFrame(new NSRect(140, 260, 120, 20));
		pb13.setAnimated(true);
		pb13.setBezeled(false);
		pb13.startAnimation();
		stage.addSubview(pb13);
		determinateIndicators.push(pb13);

		var pb14:NSProgressIndicator = new NSProgressIndicator();
		pb14.initWithFrame(new NSRect(140, 310, 120, 20));
		pb14.setIndeterminate(true);
		pb14.setBezeled(false);
		pb14.startAnimation();
		stage.addSubview(pb14);

//////////////////  THIN

		var pb15:NSProgressIndicator = new NSProgressIndicator();
		pb15.initWithFrame(new NSRect(270, 10, 10, 10));
		pb15.setStyle(NSProgressIndicatorStyle.NSProgressIndicatorSpinningStyle);
		pb15.startAnimation();
		stage.addSubview(pb15);

		var pb16:NSProgressIndicator = new NSProgressIndicator();
		pb16.initWithFrame(new NSRect(270, 60, 120, 10));
		stage.addSubview(pb16);
		determinateIndicators.push(pb16);

		var pb17:NSProgressIndicator = new NSProgressIndicator();
		pb17.initWithFrame(new NSRect(270, 110, 120, 10));
		pb17.setIndeterminate(true);
		pb17.startAnimation();
		stage.addSubview(pb17);

		var pb18:NSProgressIndicator = new NSProgressIndicator();
		pb18.initWithFrame(new NSRect(270, 160, 120, 10));
		pb18.setAnimated(true);
		pb18.startAnimation();
		stage.addSubview(pb18);
		determinateIndicators.push(pb18);

		var pb19:NSProgressIndicator = new NSProgressIndicator();
		pb19.initWithFrame(new NSRect(270, 210, 120, 10));
		pb19.setBezeled(false);
		stage.addSubview(pb19);
		determinateIndicators.push(pb19);

		var pb20:NSProgressIndicator = new NSProgressIndicator();
		pb20.initWithFrame(new NSRect(270, 260, 120, 10));
		pb20.setAnimated(true);
		pb20.setBezeled(false);
		pb20.startAnimation();
		stage.addSubview(pb20);
		determinateIndicators.push(pb20);

		var pb21:NSProgressIndicator = new NSProgressIndicator();
		pb21.initWithFrame(new NSRect(270, 310, 120, 10));
		pb21.setIndeterminate(true);
		pb21.setBezeled(false);
		pb21.startAnimation();
		stage.addSubview(pb21);
		NSApplication.sharedApplication().run();


		var timer:NSTimer = NSTimer.scheduledTimerWithTimeIntervalTargetSelectorUserInfoRepeats(
      .1, getInstance(), "_incrementProgress", {indicators:determinateIndicators}, true);
	}


	private function _incrementProgress(timer:NSTimer) {
		var info:Object = timer.userInfo();

		for (var i:Number=0; i<info.indicators.length; i++) {
			var pb:NSProgressIndicator = info.indicators[i];
			if (pb.doubleValue() >= 100) {
				pb.setDoubleValue(0);
			}
			else {
				pb.incrementBy(1);
			}
		}
	}
}