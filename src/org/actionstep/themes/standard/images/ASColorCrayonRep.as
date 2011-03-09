/* See LICENSE for copyright and terms of use */

import org.actionstep.NSColor;
import org.actionstep.NSImageRep;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSPoint;
import org.actionstep.graphics.ASLinearGradient;
import flash.geom.Matrix;
import org.actionstep.ASColors;
import org.actionstep.graphics.ASGraphicUtils;

/**
 * Draws a coloured crayon. The color of the crayon can be set using the
 * <code>#setColor()</code> method.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASColorCrayonRep extends NSImageRep {
	
	private static var WIDTH:Number = 22;
	private static var HEIGHT:Number = 100;
	
	//******************************************************
	//*                  Class members
	//******************************************************

	/** A light linear gradient applied to stripes on the body */
	private static var g_lightBodyGradient:ASLinearGradient;

	/** A dark linear gradient applied to stripes on the body */
	private static var g_darkBodyGradient:ASLinearGradient;

	/** Size of the crayon */
	private static var g_size:NSSize;

	//******************************************************
	//*                     Members
	//******************************************************

	/** The color to draw */
	private var m_color:NSColor;
	
	/** 0 - base colors, 1 - light overlay, 2 - dark overlay */
	private var m_mode:Number;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASColorCrayonRep</code> class.
	 */
	public function ASColorCrayonRep() {
		m_size = new NSSize(WIDTH, HEIGHT);
		m_mode = 0;
	}
	
	/**
	 * Returns a string representation of the ASColorCrayonRep instance.
	 */
	public function description():String {
		return "ASColorCrayonRep()";
	}
	
	//******************************************************
	//*                Setting the color
	//******************************************************
	
	/**
	 * Sets the color this image will draw to <code>color</code>.
	 */
	public function setColor(color:NSColor):Void {
		m_color = color.copyWithZone();
	}
	
	//******************************************************
	//*                Setting the mode
	//******************************************************
	
	/**
	 * Sets what part of the crayon the rep should draw.
	 * 
	 * 0 - base colors
	 * 1 - light overlay
	 * 2 - dark overlay
	 */
	public function setMode(mode:Number):Void {
		m_mode = mode;
	}
	
	//******************************************************
	//*                    Drawing
	//******************************************************
	
	/**
	 * Draws the color swatch.
	 */
	public function draw():Void {
		var rect:NSRect = NSRect.withOriginSize(m_drawPoint, size());
		g_graphics.setClip(m_drawClip);
		var bodyRect:NSRect = new NSRect(rect.origin.x, rect.origin.y + 22, 22, 
			m_size.height - 22);
		
		if (m_mode == 0) { // base colors
			//
			// Draw the shape
			//
			g_graphics.brushDownWithBrush(m_color);
			
			//
			// Body
			//
			g_graphics.drawRectWithRect(bodyRect);
			
			//
			// Tip
			//		
			g_graphics.drawPolygonWithPoints([
				new NSPoint(bodyRect.origin.x + 2, bodyRect.origin.y),
				new NSPoint(rect.origin.x + 9, rect.origin.y),
				new NSPoint(rect.maxX() - 9, rect.origin.y),
				new NSPoint(rect.maxX() - 2, bodyRect.origin.y)]);
			
			g_graphics.brushUp();
		}
		else if (m_mode == 1) { // light overlay
			g_graphics.brushDownWithBrush(g_lightBodyGradient);
			
			g_graphics.drawRectWithRect(new NSRect(
				bodyRect.origin.x, bodyRect.origin.y + 6, 
				bodyRect.size.width, 3));
			g_graphics.brushUp();
				
			g_graphics.brushDownWithBrush(g_lightBodyGradient);
			g_graphics.drawRectWithRect(new NSRect(
				bodyRect.origin.x, bodyRect.origin.y + 21, 
				bodyRect.size.width, bodyRect.size.height - 21));	
			
			g_graphics.brushUp();
		}
		else if (m_mode == 2) { // dark overlay
			g_graphics.brushDownWithBrush(g_darkBodyGradient);
			
			g_graphics.drawRectWithRect(new NSRect(
				bodyRect.origin.x, bodyRect.origin.y, 
				bodyRect.size.width, 6));
			g_graphics.brushUp();
			
			g_graphics.brushDownWithBrush(g_darkBodyGradient);
			g_graphics.drawRectWithRect(new NSRect(
				bodyRect.origin.x, bodyRect.origin.y + 9, 
				bodyRect.size.width, 12));	
			
			g_graphics.brushUp();
		}
	}
	
	//******************************************************
	//*                 Class construction
	//******************************************************
	
	/**
	 * Creates the gradients used by this image
	 */
	private static function initialize():Void {
		g_size = new NSSize(WIDTH, HEIGHT);
		
		//
		// Set up gradients
		//
		var colors:Array;
		var ratios:Array;
		var matrix:Matrix;
		
		//
		// Light
		//
		colors = [ASColors.lightGrayColor(), new NSColor(0xB9B9B9), 
			new NSColor(0xC5C5C5), ASColors.grayColor()];
		ratios = [25, 100, 115, 245];
		matrix = ASGraphicUtils.linearGradientMatrixWithRectDegrees(
			NSRect.withOriginSize(NSPoint.ZeroPoint, g_size),
			ASLinearGradient.ANGLE_LEFT_TO_RIGHT); 
		g_lightBodyGradient = new ASLinearGradient(colors, ratios, matrix);
		
		//
		// Dark
		//
		colors = [ASColors.whiteColor(), new NSColor(0xCCCCCC), ASColors.whiteColor()];
		ratios = [35, 100, 230];
		matrix = ASGraphicUtils.linearGradientMatrixWithRectDegrees(
			NSRect.withOriginSize(NSPoint.ZeroPoint, g_size),
			ASLinearGradient.ANGLE_LEFT_TO_RIGHT); 
		g_darkBodyGradient = new ASLinearGradient(colors, ratios, matrix);
	}
}