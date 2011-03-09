/* See LICENSE for copyright and terms of use */

import org.actionstep.NSRect;

import flash.geom.Matrix;
import org.actionstep.NSSize;
import org.actionstep.NSColor;

/**
 * Provides utilities commonly used when drawing graphics.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.graphics.ASGraphicUtils {
	
	//******************************************************
	//*                    Constants
	//******************************************************
	
	private static var DEGREES_PER_RADIAN:Number = 57.2957795;
	private static var RADIANS_PER_DEGREE:Number = 0.0174532925;
	
	//******************************************************
	//*              Matrix creation methods
	//******************************************************
	
	/**
	 * Returns a matrix appropriate for a linear gradient, rotated by
	 * <code>degrees</code>.
	 */
	public static function linearGradientMatrixWithRectDegrees(rect:NSRect, 
			degrees:Number):Matrix {
		var radians:Number = convertDegreesToRadians(degrees);
		if (isNaN(radians)) {
			radians = 0;
		}
		
		//
		// Verify this
		//
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(rect.size.width, rect.size.height, radians,
			rect.origin.x, rect.origin.y);
		return matrix;
	}  

    /**
     * Returns a matrix appropriate for a radial gradient, centered in the
     * middle of <code>size</code>.
     */
	public static function radialGradientMatrixForSize(size:NSSize):Matrix {
		var width:Number  = size.width;
		var height:Number = size.height;
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(width, height, 0, -width/2, -height/2);
		return matrix;
	}
    
	//******************************************************
	//*              Angle utility methods
	//******************************************************
	
	/**
	 * Converts <code>radians</code> to degrees, and returns the result.
	 * 
	 * @see #convertDegreesToRadians()
	 */
	public static function convertRadiansToDegrees(radians:Number):Number {
		return radians * DEGREES_PER_RADIAN;
	}
	
	/**
	 * Converts <code>degrees</code> to radians, and returns the result.
	 * 
	 * @see #convertRadiansToDegrees()
	 */
	public static function convertDegreesToRadians(degrees:Number):Number {
		return degrees * RADIANS_PER_DEGREE;
	}

	/**
	 * Returns the adjacent angle (in radians) of a right triangle with a 
	 * base width of <code>base</code> and a height of <code>height</code>.
	 * 
	 * @see #oppositeAngleRadiansForBaseHeight()
	 */
	public static function adjacentAngleRadiansForBaseHeight(base:Number, 
			height:Number):Number {
		return Math.atan2(height, base); 
	}

	/**
	 * Returns the opposite angle (in radians) of a right triangle with a 
	 * base width of <code>base</code> and a height of <code>height</code>. 
	 * 
	 * @see #adjacentAngleRadiansForBaseHeight()
	 */
	public static function oppositeAngleRadiansForBaseHeight(base:Number, 
			height:Number):Number {
		return Math.atan2(base, height); 
	}
  
	//******************************************************
	//*            Value extraction from colors
	//******************************************************
	
	/**
	 * <p>Extracts the color values and alpha values from an array of 
	 * {@link NSColor} objects.</p>
	 * 
	 * <p>Returns an object structured as follows:<br/>
	 * <code>{colors:Array, alphas:Array}</code></p>
	 */
	public static function extractValuesAndAlphasFromColors(colors:Array):Object {
		//
		// Build separate color and alpha arrays
		//
		var cs:Array = [];
		var alphas:Array = [];
		var len:Number = colors.length;
		for (var i:Number = 0; i < len; i++) {
			var c:NSColor = NSColor(colors[i]);
			cs.push(c.value);
			alphas.push(c.alphaValue);
		}
		
		return {colors: cs, alphas: alphas};
	}
	
	//******************************************************
	//*           Construction (or lack thereof)
	//******************************************************
	
	/**
	 * This is a static class.
	 */
	private function ASGraphicUtils() {
	}
}