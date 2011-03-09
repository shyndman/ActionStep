/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * These constants specify predefined number format styles.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSNumberFormatterStyle extends ASConstantValue {
	
	public static var NSNumberFormatterNoStyle:NSNumberFormatterStyle 
		= new NSNumberFormatterStyle(1);
		
	public static var NSNumberFormatterDecimalStyle:NSNumberFormatterStyle 
		= new NSNumberFormatterStyle(2);
		
	public static var NSNumberFormatterCurrencyStyle:NSNumberFormatterStyle 
		= new NSNumberFormatterStyle(3);
		
	public static var NSNumberFormatterPercentStyle:NSNumberFormatterStyle 
		= new NSNumberFormatterStyle(4);
		
	public static var NSNumberFormatterScientificStyle:NSNumberFormatterStyle 
		= new NSNumberFormatterStyle(5);
		
	public static var NSNumberFormatterSpellOutStyle:NSNumberFormatterStyle 
		= new NSNumberFormatterStyle(6);
	
	/**
	 * Creates a new instance of the <code>NSNumberFormatterStyle</code> class.
	 */
	public function NSNumberFormatterStyle(value:Number) {
		super(value);
	}
}