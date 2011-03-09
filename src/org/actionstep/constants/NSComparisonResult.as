/* See LICENSE for copyright and terms of use */ 

import org.actionstep.constants.ASConstantValue;

/**
 * Indicates how items in a request are ordered, from the first one given in a 
 * method invocation or function call to the last (that is, left to right in code).
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSComparisonResult extends ASConstantValue 
{	    
	/**
	 * The left operand is smaller than the right operand.
	 */
	public static var NSOrderedAscending:NSComparisonResult 	= new NSComparisonResult(-1);
	
	/**
	 * The two operands are equal.
	 */
	public static var NSOrderedSame:NSComparisonResult 			= new NSComparisonResult(0);
	
	/**
	 * The left operand is greater than the right operand.
	 */
	public static var NSOrderedDescending:NSComparisonResult 	= new NSComparisonResult(1);
	
	private function NSComparisonResult(value:Number)
	{		
		super(value);
	}
}