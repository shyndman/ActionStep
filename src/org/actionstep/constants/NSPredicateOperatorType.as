/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * These constants represent operators available to an instance of the
 * <code>org.actionstep.NSComparisonPredicate</code> class.
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSPredicateOperatorType extends ASConstantValue {
		    	
	/** < */
	public static var NSLessThanPredicateOperatorType:NSPredicateOperatorType 	
		= new NSPredicateOperatorType(0, "<");
		
	/** <= */
	public static var NSLessThanOrEqualToPredicateOperatorType:NSPredicateOperatorType 
		= new NSPredicateOperatorType(1, "<=", "=<");
		
	/** > */
	public static var NSGreaterThanPredicateOperatorType:NSPredicateOperatorType 
		= new NSPredicateOperatorType(2, ">");
		
	/** >= */
	public static var NSGreaterThanOrEqualToPredicateOperatorType:NSPredicateOperatorType 
		= new NSPredicateOperatorType(3, ">=", "=>");
		
	/** == */
	public static var NSEqualToPredicateOperatorType:NSPredicateOperatorType 
		= new NSPredicateOperatorType(4, "==", "=");
		
	/** != */
	public static var NSNotEqualToPredicateOperatorType:NSPredicateOperatorType 
		= new NSPredicateOperatorType(5, "!=", "<>");
		
	/** A full regular expression matching predicate. */
	public static var NSMatchesPredicateOperatorType:NSPredicateOperatorType 
		= new NSPredicateOperatorType(6, "MATCHES");
		
	/** A SQL-like partial match. */
	public static var NSLikePredicateOperatorType:NSPredicateOperatorType 
		= new NSPredicateOperatorType(7, "LIKE");
		
	/** A begins-with predicate. */
	public static var NSBeginsWithPredicateOperatorType:NSPredicateOperatorType 
		= new NSPredicateOperatorType(8, "BEGINSWITH");
		
	/** An ends-with predicate. */
	public static var NSEndsWithPredicateOperatorType:NSPredicateOperatorType 
		= new NSPredicateOperatorType(9, "ENDSWITH");
		
	/** 
	 * A predicate to determine if the RH side of the comparison exists in
	 * the LH side. For strings, TRUE is returned if LHS is a substring of the RHS.
	 * For collections, TRUE is returned if LHS exists as an element of RHS.
	 */
	public static var NSInPredicateOperatorType:NSPredicateOperatorType 
		= new NSPredicateOperatorType(10, "IN", "CONTAINS");
		
	/**
	 * Predicate that uses a custom selector that takes a single argument and returns
	 * a boolean value. The selector is invoked on LHS with RHS.
	 */
	public static var NSCustomSelectorPredicateOperatorType:NSPredicateOperatorType 
		= new NSPredicateOperatorType(11);
	
	//******************************************************
	//*                     Lookup
	//******************************************************
	
	private static var g_keywords:Object;
	
	/**
	 * Checks to see if <code>string</code> begins with one of the keywords
	 * in this class. If so, it returns the keyword. If not, <code>null</code>
	 * is returned.
	 */
	public static function startsWithKeyword(string:String):String {
		var longest:String = null;
		
		for (var k:String in g_keywords) {
			if (string.indexOf(k) == 0) {
				if (longest == null || k.length > longest.length) {
					longest = k;
				}
			}
		}
		
		return longest;
	}
	
	/**
	 * Returns the constant associated with the keyword <code>keyword</code>
	 * or <code>null</code> if no association exists.
	 */
	public static function constantForKeyword(keyword:String)
			:NSPredicateOperatorType {
		for (var k:String in g_keywords) {
			if (k == keyword) {
				return NSPredicateOperatorType(g_keywords[k]);
			}
		}
		
		return null;
	}
	
	//******************************************************
	//*                     Instance
	//******************************************************
	
	/** The string representation of the operator. */
	public var string:String;
	
	/** 
	 * The alternate string representation of the operator.
	 * 
	 * If none is specified during construction, this assumes the value of
	 * <code>#string</code>.
	 */
	public var altString:String;
	
	/**
	 * Constructs a new instance of the <code>NSPredicateOperatorType</code>
	 * class.
	 */
	private function NSPredicateOperatorType(value:Number, string:String,
			altString:String) {		
		super(value);
		
		//
		// Create keywords hash if necessary
		//
		if (null == g_keywords) {
			g_keywords = {};
		}
		
		if (null != string) {
			this.string = string;
			g_keywords[string] = this;
		}
		
		if (null == altString) {
			this.altString = string;
		} else {
			this.altString = altString;
			g_keywords[altString] = this;
		}
	}
}
