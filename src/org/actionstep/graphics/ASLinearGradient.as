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
class org.actionstep.graphics.ASLinearGradient extends ASGradient {
	
	private var m_gradientArgs:Array;
	private var m_matrix:Matrix;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * <p>
	 * Creates a new instance of the <code>ASLinearGradientBrush</code> class.
	 * </p>
	 * <p>
	 * For information on arguments, read the documentation for the
	 * {@link MovieClip#beginGradientFill()} method.
	 * </p>
	 * <p>
	 * <code>spreadMethod</code> and <code>interpolationMethod</code> are
	 * optional.
	 * </p>
	 */
	public function ASLinearGradient(colors:Array, ratios:Array, matrix:Matrix,
			spreadMethod:String, interpolationMethod:String) {
		if (colors.length != ratios.length) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"colors and ratios must have the same number of elements",
				null);
			trace(e);
			throw e;
		}
		
		m_matrix = matrix;
		var arrs:Object = ASGraphicUtils.extractValuesAndAlphasFromColors(
			colors);
		m_gradientArgs = ["linear", arrs.colors, arrs.alphas, ratios, matrix, 
			spreadMethod, interpolationMethod];
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
	//*                 Gradient arguments
	//******************************************************
	
	/**
	 * Returns gradient fill arguments.
	 */	
	private function gradientArguments():Array {
		return m_gradientArgs;
	}
}