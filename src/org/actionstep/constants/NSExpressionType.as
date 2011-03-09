/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 *
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSExpressionType extends ASConstantValue {
		
	/**
	 * An expression that always returns the same value.
	 */
	public static var NSConstantValueExpressionType:NSExpressionType
		= new NSExpressionType(0);
	
	/**
	 * An expression that always returns the parameter object itself.
	 */
	public static var NSEvaluatedObjectExpressionType:NSExpressionType
		= new NSExpressionType(1);
	
	/**
	 * An expression that always returns whatever value is associated with the 
	 * key specified by ‘variable’ in the bindings dictionary.
	 */
	public static var NSVariableExpressionType:NSExpressionType
		= new NSExpressionType(2);
	
	/**
	 * An expression that returns something that can be used as a key path.
	 */
	public static var NSKeyPathExpressionType:NSExpressionType
		= new NSExpressionType(3);
	
	/**
	 * An expression that returns the result of evaluating a function.
	 */
	public static var NSFunctionExpressionType:NSExpressionType
		= new NSExpressionType(4);
	
	
	/**
	 * Creates a new instance of the <code>NSExpressionType</code> class.
	 */
	private function NSExpressionType(value:Number) {
		super(value);
	}
}