/* See LICENSE for copyright and terms of use */

import org.actionstep.NSColor;

/**
 * This class is meant to contain values for colors such as red, white and black. It is meant
 * to relieve <code>NSColor</code> of this load.
 *
 * @author Tay Ray Chuan
 */

class org.actionstep.ASColors {

	//******************************************************
	//*                  2-Bit Deep Grayscale Color Space
	//******************************************************

	/**
	 * These constants are the standard gray values for the 2-bit deep grayscale
	 * color space.
	 */

	/**
	 * Returns a color who's RGB value is 0x000000.
	 */
	public static function blackColor():NSColor {
		return new NSColor(0x000000);
	}

	/**
	 * Returns a color who's RGB value is 0x666666.
	 */
	public static function darkGrayColor():NSColor {
		return new NSColor(0x666666);
	}

	/**
	 * Returns a color who's RGB value is 0x808080.
	 */
	public static function grayColor():NSColor {
		return new NSColor(0x808080);
	}

	/**
	 * Returns a color who's RGB value is 0xAAAAAA.
	 */
	public static function lightGrayColor():NSColor {
		return new NSColor(0xAAAAAA);
	}

	/**
	 * Returns a color who's RGB value is 0xFFFFFF.
	 */
	public static function whiteColor():NSColor {
		return new NSColor(0xFFFFFF);
	}

	//******************************************************
	//*                  Named Colors
	//******************************************************

	/**
	 * Returns a color who's RGB value is 0x0000FF.
	 */
	public static function blueColor():NSColor {
		return new NSColor(0x0000FF);
	}

	/**
	 * Returns a color who's RGB value is 0xA52A2A.
	 */
	public static function brownColor():NSColor {
		return new NSColor(0xA52A2A);
	}

	/**
	 * Returns a color who's RGB value is 0xFFFFFF and alpha is 0.
	 */
	public static function clearColor():NSColor {
		return NSColor.colorWithHexValueAlpha(0xFFFFFF, 0);
	}

	/**
	 * Returns a color who's RGB value is 0x00FFFF.
	 */
	public static function cyanColor():NSColor {
		return new NSColor(0x00FFFF);
	}

	/**
	 * Returns a color who's RGB value is 0x008000.
	 */
	public static function greenColor():NSColor {
		return new NSColor(0x008000);
	}

	/**
	 * Returns a color who's RGB value is 0xFF00FF.
	 */
	public static function magentaColor():NSColor {
		return new NSColor(0xFF00FF);
	}

	/**
	 * Returns a color who's RGB value is 0xFFA500.
	 */
	public static function orangeColor():NSColor {
		return new NSColor(0xFFA500);
	}

	/**
	 * Returns a color who's RGB value is 0x800080.
	 */
	public static function purpleColor():NSColor {
		return new NSColor(0x800080);
	}

	/**
	 * Returns a color who's RGB value is 0xFF0000.
	 */
	public static function redColor():NSColor {
		return new NSColor(0xFF0000);
	}

	/**
	 * Returns a color who's RGB value is 0xFFFF00.
	 */
	public static function yellowColor():NSColor {
		return new NSColor(0xFFFF00);
	}

	/**
	 * Returns a color who's RGB value is 0xD4DAE3.
	 */
	public static function martiniGlassColor():NSColor {
		return new NSColor(0xD4DAE3);
	}
}