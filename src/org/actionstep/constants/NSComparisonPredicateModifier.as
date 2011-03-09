/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Defines how the NSComparisonPredicate operator is modified.
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSComparisonPredicateModifier 
		extends ASConstantValue {	
	/**
	 * A predicate to compare directly the LHS and RHS
	 */
	public static var NSDirectPredicateModifier:NSComparisonPredicateModifier 
		= new NSComparisonPredicateModifier(0);
		
	/**
	 * A predicate to compare all entries in the destination of a to-many
	 * relationship. LHS must be a collection, compares each value in LHS
	 * against RHS, returns false when it finds the first mismatch—returns
	 * true of all match.
	 */
	public static var NSAllPredicateModifier:NSComparisonPredicateModifier 
		= new NSComparisonPredicateModifier(1, "ALL");
		
	/**
	 * A predicate to match with any entry in the destination of a to-many
	 * relationship. LHS must be a collection, the predicate compares each
	 * value in LHS against RHS and returns true when it finds the first
	 * match—returns false if no match is found.
	 */
	public static var NSAnyPredicateModifier:NSComparisonPredicateModifier 
		= new NSComparisonPredicateModifier(2, "ANY", "SOME");
	
	/**
	 * Equivalent to NOT ANY.
	 */
	public static var NSNonePredicateModifier:NSComparisonPredicateModifier 
		= new NSComparisonPredicateModifier(3, "NONE");
		
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
			:NSComparisonPredicateModifier {
		for (var k:String in g_keywords) {
			if (k == keyword) {
				return NSComparisonPredicateModifier(g_keywords[k]);
			}
		}
		
		return null;
	}
	
	//******************************************************
	//*                    Instance
	//******************************************************
	
	/** The string representation of the modifier. */
	public var string:String;
	
	/** The alternate string representation of the modifier. */
	public var altString:String;
	
	/**
	 * Creates a new instance of the <code>NSComparisonPredicateModifier</code>
	 * class.
	 */
	private function NSComparisonPredicateModifier(value:Number, 
			string:String, altString:String) {
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
