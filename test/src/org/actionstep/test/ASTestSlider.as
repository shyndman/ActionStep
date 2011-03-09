/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSWindow;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.NSSlider;
import org.actionstep.constants.NSTickMarkPosition;
import org.actionstep.binding.NSKeyValueObserving;
import org.actionstep.NSDictionary;
import org.actionstep.NSSliderCell;
import org.actionstep.constants.NSSliderType;

/**
 * Test class for the <code>NSSlider</code> control.
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestSlider {
	public static function test():Void {
		//
		// Create the app and the window
		//
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0, 0, 600, 400));
		var stage:NSView = wnd.contentView();

		var v:NSView = (new NSView()).initWithFrame(new NSRect(10, 10, 320, 40));
		stage.addSubview(v);
		
		//
		// Create the slider
		//
		var slider:NSSlider = new NSSlider();
		slider.initWithFrame(new NSRect(20, 0, 300, 40));
		slider.setTickMarkPosition(NSTickMarkPosition.NSTickMarkBelow);
		slider.setFloatValue(100);
		slider.setMaxValue(100);
		slider.setMinValue(0);
		v.addSubview(slider);

		var slider2:NSSlider = new NSSlider();
		slider2.initWithFrame(new NSRect(10, 55, 300, 40));
		slider2.setTickMarkPosition(NSTickMarkPosition.NSTickMarkAbove);
		slider2.setAllowsTickMarkValuesOnly(true);
		slider2.setNumberOfTickMarks(21);
		stage.addSubview(slider2);

		var slider3:NSSlider = new NSSlider();
		slider3.initWithFrame(new NSRect(315, 10, 40, 280));
		slider3.setTickMarkPosition(NSTickMarkPosition.NSTickMarkLeft);
		stage.addSubview(slider3);

		var slider4:NSSlider = new NSSlider();
		slider4.initWithFrame(new NSRect(360, 10, 40, 280));
		slider4.setTickMarkPosition(NSTickMarkPosition.NSTickMarkRight);
		stage.addSubview(slider4);

		var slider5:NSSlider = new NSSlider();
		slider5.initWithFrame(new NSRect(10, 100, 300, 40));
		slider5.setNumberOfTickMarks(0);
		stage.addSubview(slider5);

		var slider6:NSSlider = new NSSlider();
		slider6.initWithFrame(new NSRect(10, 145, 30, 30));
		slider6.setNumberOfTickMarks(0);
		slider6.setFloatValue(70);
		NSSliderCell(slider6.cell()).setSliderType(NSSliderType.NSCircularSlider);
		stage.addSubview(slider6);

		wnd.setInitialFirstResponder(slider);
		
		//
		// Run the application
		//
		app.run();
	}
}