/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Defines the possible types of string comparison for NSComparisonPredicate.
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSComparisonPredicateOptions 
		extends ASConstantValue {
			
	/**
	 * A case-insensitive predicate.
	 */
	public static var NSCaseInsensitivePredicateOption:NSComparisonPredicateOptions 
		= new NSComparisonPredicateOptions(0x01);
		
	/**
	 * A diacritic-insensitive predicate.
	 */
	public static var NSDiacriticInsensitivePredicateOption:NSComparisonPredicateOptions 	
		= new NSComparisonPredicateOptions(0x02);
	
	/**
	 * Creates a new instance of the <code>NSComparisonPredicateOptions</code>
	 * class.
	 */
	private function NSComparisonPredicateOptions(value:Number) {		
		super(value);
	}
}