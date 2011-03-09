/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Used to specify how numbers should be rounded
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSNumberFormatterRoundingMode extends ASConstantValue {
	
	/**
	 * Round up to next larger number with the proper number of fraction digits.
	 */
	public static var NSNumberFormatterRoundCeiling:NSNumberFormatterRoundingMode 
		= new NSNumberFormatterRoundingMode(1);
		
	/**
	 * Round down to next smaller number with the proper number of fraction digits.
	 */
	public static var NSNumberFormatterRoundFloor:NSNumberFormatterRoundingMode 
		= new NSNumberFormatterRoundingMode(2);
		
	/**
	 * Round down to next smaller number with the proper number of fraction digits.
	 */
	public static var NSNumberFormatterRoundDown:NSNumberFormatterRoundingMode 
		= new NSNumberFormatterRoundingMode(3);
		
	/**
	 * Round the last digit, when followed by a 5, toward an even digit 
	 * (.25 -> .2, .35 -> .4)
	 */
	public static var NSNumberFormatterRoundHalfEven:NSNumberFormatterRoundingMode 
		= new NSNumberFormatterRoundingMode(4);
		
	/**
	 * Round up to next larger number with the proper number of fraction digits.
	 */
	public static var NSNumberFormatterRoundUp:NSNumberFormatterRoundingMode 
		= new NSNumberFormatterRoundingMode(5);
		
	/**
	 * Round down when a 5 follows putative last digit.
	 */
	public static var NSNumberFormatterRoundHalfDown:NSNumberFormatterRoundingMode 
		= new NSNumberFormatterRoundingMode(6);
		
	/**
	 * Round up when a 5 follows putative last digit.
	 */
	public static var NSNumberFormatterRoundHalfUp:NSNumberFormatterRoundingMode 
		= new NSNumberFormatterRoundingMode(7);
	
	/**
	 * Creates a new instance of the <code>NSNumberFormatterRoundingMode</code> class.
	 */
	private function NSNumberFormatterRoundingMode(value:Number) {
		super(value);
	}
}