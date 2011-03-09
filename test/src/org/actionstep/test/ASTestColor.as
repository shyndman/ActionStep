/* See LICENSE for copyright and terms of use */

import org.actionstep.NSApplication;
import org.actionstep.NSColor;
import org.actionstep.ASColors;

/**
 * Tests the <code>org.actionstep.NSColor</code> class.
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestColor
{
	public static function test():Void
	{
		NSApplication.sharedApplication().run();

		//
		// Test RGB
		//
		var color1:NSColor = NSColor.colorWithCalibratedRedGreenBlueAlpha(0.5, 1, 0.2, 0);
		trace(color1);

		//
		// Test Hex
		//
		var color2:NSColor = new NSColor(0xFF0000);
		trace(color2); // should have a red of 1.0

		//
		// Test HSB
		//
		var color3:NSColor = NSColor.colorWithCalibratedHueSaturationBrightnessAlpha(
			0, 1, 1, 1); // same as 0xFF0000
		trace(color3);

		var color5:NSColor = NSColor.colorWithCalibratedHueSaturationBrightnessAlpha(
			color1.hueComponent(), 0.8, 1, 1);
		trace(color5);

		//
		// Test equality.
		//
		trace(color2.isEqual(color3));

		//
		// Test darkening.
		//
		var color4:NSColor = color3.adjustColorBrightnessByFactor(0.7);

		trace(ASColors.grayColor());
		trace(ASColors.grayColor().adjustColorBrightnessByFactor(0.8));
	}
}