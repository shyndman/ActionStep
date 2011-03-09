/* See LICENSE for copyright and terms of use */

import org.actionstep.graphics.ASGradient;
import org.actionstep.graphics.ASGraphicUtils;
import org.actionstep.NSException;

import flash.geom.Matrix;

/**
 * Represents a linear gradient. For information on what the initializer 
 * arguments mean, read the documentation for 
 * {@link MovieClip#beginGradientFill()}.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.graphics.ASRadialGradient extends ASGradient {
	
	private var m_gradientArgs:Array;
	private var m_matrix:Matrix;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASRadialGradient</code> class.
	 */
	public function ASRadialGradient(colors:Array, ratios:Array, matrix:Matrix,
			spreadMethod:String, interpolationMethod:String, 
			focalPointRatio:Number) {

		m_matrix = matrix;
				
		m_gradientArgs = ["radial", null, null, null, matrix, 
			spreadMethod, interpolationMethod, focalPointRatio];
			
		setColorsWithRatios(colors, ratios);
	}
	
	//******************************************************
	//*               Transformation matrix
	//******************************************************
	
	/**
	 * Returns the transformation matrix.
	 */
	public function matrix():Matrix {
		return m_matrix;
	}
	
	/**
	 * Sets the gradient transformation matrix to <code>matrix</code>.
	 */
	public function setMatrix(matrix:Matrix):Void {
		m_matrix = matrix.clone();
		m_gradientArgs[4] = m_matrix;
	}
	
	//******************************************************
	//*                Gradient attributes
	//******************************************************
	
	public function setSpreadMethod(method:String):Void {
		m_gradientArgs[5] = method;
	}
	
	public function setInterpolationMethod(method:String):Void {
		m_gradientArgs[6] = method;
	}
	
	public function setFocalPointRatio(ratio:Number):Void {
		m_gradientArgs[7] = ratio;
	}
	
	public function setColorsWithRatios(colors:Array, ratios:Array):Void {
		if (colors.length != ratios.length) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"colors and ratios must have the same number of elements",
				null);
			trace(e);
			throw e;
		}
		
		var arrs:Object = ASGraphicUtils.extractValuesAndAlphasFromColors(
			colors);
			
		m_gradientArgs[1] = arrs.colors;
		m_gradientArgs[2] = arrs.alphas;
		m_gradientArgs[3] = ratios;
	}
	
	//******************************************************
	//*                 Gradient arguments
	//******************************************************
	
	/**
	 * Returns gradient fill arguments.
	 */	
	private function gradientArguments():Array {
		return m_gradientArgs;
	}
}