/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * These constants of type NSNumberFormatterPadPosition are used to specify how 
 * numbers should be padded.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSNumberFormatterPadPosition extends ASConstantValue {
	
	/**
	 * Specifies that the padding should occur before the prefix.
	 */
	public static var NSNumberFormatterPadBeforePrefix:NSNumberFormatterPadPosition 
		= new NSNumberFormatterPadPosition(1);
		
	/**
	 * Specifies that the padding should occur after the prefix.
	 */
	public static var NSNumberFormatterPadAfterPrefix:NSNumberFormatterPadPosition 
		= new NSNumberFormatterPadPosition(2);
		
	/**
	 * Specifies that the padding should occur before the suffix.
	 */
	public static var NSNumberFormatterPadBeforeSuffix:NSNumberFormatterPadPosition 
		= new NSNumberFormatterPadPosition(3);
		
	/**
	 * Specifies that the padding should occur after the suffix.
	 */
	public static var NSNumberFormatterPadAfterSuffix:NSNumberFormatterPadPosition 
		= new NSNumberFormatterPadPosition(4);
		
	/**
	 * Creates a new instance of the <code>NSNumberFormatterPadPosition</code> class.
	 */
	private function NSNumberFormatterPadPosition(value:Number) {
		super(value);
	}
}