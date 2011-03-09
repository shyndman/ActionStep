/* See LICENSE for copyright and terms of use */

import org.actionstep.NSColor;

/**
 * Colors used by AIB. If you modify colors, be sure to copy them first.
 * 
 * @author Scott Hyndman
 */
class org.aib.ui.AIBColors {
	
	private static var g_selectionColor:NSColor;
	private static var g_controlColor:NSColor;
	private static var g_controlBackgroundColor:NSColor;
	private static var g_controlDarkColor:NSColor;
	private static var g_controlShadowColor:NSColor;
	private static var g_controlDarkShadowColor:NSColor;
	
	/**
	 * Color used to represent selection.
	 */
	public static function selectionColor():NSColor {
		return g_selectionColor;
	}
	
	/**
	 * Returns the control color.
	 */
	public static function controlColor():NSColor {
		return g_controlColor;
	}
	
	/**
	 * Dark control color
	 */
	public static function controlDarkColor():NSColor {
		return g_controlDarkColor;
	}
	
	/**
	 * Returns the shadow color.
	 */
	public static function controlShadowColor():NSColor {
		return g_controlShadowColor;
	}
	
	/**
	 * Returns the dark shadow color.
	 */
	public static function controlDarkShadowColor():NSColor {
		return g_controlDarkShadowColor;
	}
	
	//******************************************************
	//*                Static construction
	//******************************************************
	
	private static function initialize():Void {
		g_controlBackgroundColor = NSColor.colorWithCalibratedWhiteAlpha(.97, 1);
		g_controlColor = NSColor.colorWithCalibratedWhiteAlpha(.85, 1);
		g_controlDarkColor = NSColor.colorWithCalibratedWhiteAlpha(.70, 1);
		g_controlDarkShadowColor = new NSColor(0);
		g_controlShadowColor = NSColor.colorWithCalibratedWhiteAlpha(.58, 1);
		g_selectionColor = new NSColor(0x39CC1F);
	}
}