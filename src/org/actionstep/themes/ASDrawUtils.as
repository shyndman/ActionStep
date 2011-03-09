import org.actionstep.ASColors;
import org.actionstep.constants.NSRectEdge;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSRect;
import org.actionstep.NSView;
/* See LICENSE for copyright and terms of use */

/**
 * Contains common drawing utilities
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.ASDrawUtils {
	
	//******************************************************
	//*                Drawing helpers
	//******************************************************
	
	//
	// Groove variables
	//
	private static var g_grooveSides:Array = [
		NSRectEdge.NSMinXEdge, NSRectEdge.NSMaxYEdge, NSRectEdge.NSMinXEdge, 
		NSRectEdge.NSMaxYEdge, NSRectEdge.NSMaxXEdge, NSRectEdge.NSMinYEdge, 
		NSRectEdge.NSMaxXEdge, NSRectEdge.NSMinYEdge];
	private static var g_grooveColors:Array = [
		ASColors.darkGrayColor(), ASColors.darkGrayColor(), ASColors.whiteColor(), 
		ASColors.whiteColor(), ASColors.whiteColor(), ASColors.whiteColor(), 
		ASColors.darkGrayColor(), ASColors.darkGrayColor()];
	
	/**
	* Draws a groove on view in the area specified by <code>rect</code>.
	*/
	public static function drawGrooveInRectWithView(rect:NSRect, view:NSView):Void {
		var g:ASGraphics = view.graphics();
		var remainder:NSRect = g.drawTiledRectsWithRectEdgesColors(rect, 
		g_grooveSides, g_grooveColors);
		g.brushDownWithBrush(ASColors.grayColor());
		g.drawRectWithRect(remainder);
		g.brushUp();
	}
	
	private static var g_grayBezelSides:Array = [
		NSRectEdge.NSMaxXEdge, NSRectEdge.NSMinYEdge, NSRectEdge.NSMinXEdge, 
		NSRectEdge.NSMaxYEdge, NSRectEdge.NSMaxXEdge, NSRectEdge.NSMinYEdge, 
		NSRectEdge.NSMinXEdge, NSRectEdge.NSMaxYEdge];
	private static var g_grayBezelColors:Array = [
		ASColors.whiteColor(), ASColors.whiteColor(), ASColors.darkGrayColor(), 
		ASColors.darkGrayColor(), ASColors.lightGrayColor(), ASColors.lightGrayColor(), 
		ASColors.blackColor(), ASColors.blackColor()];
	
	public static function drawGrayBezelInRectWithView(rect:NSRect, view:NSView):Void {
		var g:ASGraphics = view.graphics();
		var remainder:NSRect = g.drawTiledRectsWithRectEdgesColors(rect, 
			g_grayBezelSides, g_grayBezelColors);
				
		g.brushDownWithBrush(ASColors.darkGrayColor());
		g.drawRect(rect.minX() + 1, rect.minY() + 1, 1, 1);
		g.drawRect(rect.maxX() - 2, rect.maxY() - 1, 1, 1);
		g.brushUp();
		
		g.brushDownWithBrush(ASColors.lightGrayColor());
		g.drawRectWithRect(remainder);
		g.brushUp();
	}
	
	private static var g_whiteBezelSides:Array = [
		NSRectEdge.NSMaxYEdge, NSRectEdge.NSMaxXEdge, NSRectEdge.NSMinYEdge, 
		NSRectEdge.NSMinXEdge, NSRectEdge.NSMaxYEdge, NSRectEdge.NSMaxXEdge, 
		NSRectEdge.NSMinYEdge, NSRectEdge.NSMinXEdge];
	private static var g_whiteBezelColors:Array = [
		ASColors.darkGrayColor(), ASColors.whiteColor(), ASColors.whiteColor(), 
		ASColors.darkGrayColor(), ASColors.darkGrayColor(), ASColors.lightGrayColor(), 
		ASColors.lightGrayColor(), ASColors.darkGrayColor()];
		   
	public static function drawWhiteBezelInRectWithView(rect:NSRect, view:NSView):Void {
		var g:ASGraphics = view.graphics();
		var remainder:NSRect = g.drawTiledRectsWithRectEdgesColors(rect, 
		g_whiteBezelSides, g_whiteBezelColors);
		g.brushDownWithBrush(ASColors.whiteColor());
		g.drawRectWithRect(remainder);
		g.brushUp();
	}
	
	private static var g_darkBezelSides:Array = [
		NSRectEdge.NSMaxXEdge, NSRectEdge.NSMinYEdge, NSRectEdge.NSMinXEdge, 
		NSRectEdge.NSMaxYEdge, NSRectEdge.NSMaxXEdge, NSRectEdge.NSMinYEdge, 
		NSRectEdge.NSMinXEdge, NSRectEdge.NSMaxYEdge];
	private static var g_darkBezelColors:Array = [
		ASColors.whiteColor(), ASColors.whiteColor(), ASColors.lightGrayColor(), 
		ASColors.lightGrayColor(), ASColors.lightGrayColor(), ASColors.lightGrayColor(), 
		ASColors.blackColor(), ASColors.blackColor()];
	
	private static var g_lightBezelSides:Array = [
		NSRectEdge.NSMaxXEdge, NSRectEdge.NSMinYEdge, NSRectEdge.NSMinXEdge, 
		NSRectEdge.NSMaxYEdge, NSRectEdge.NSMaxXEdge, NSRectEdge.NSMinYEdge, 
		NSRectEdge.NSMinXEdge, NSRectEdge.NSMaxYEdge];
	private static var g_lightBezelColors:Array = [
		ASColors.whiteColor(), ASColors.whiteColor(), ASColors.grayColor(), 
		ASColors.grayColor(), ASColors.blackColor(), ASColors.blackColor(), 
		ASColors.blackColor(), ASColors.blackColor()];
}