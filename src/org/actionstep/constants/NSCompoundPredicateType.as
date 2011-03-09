/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Represents the type of an <code>org.actionstep.NSCompoundPredicate</code>
 * instance.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSCompoundPredicateType extends ASConstantValue {

	/**
	 * Logical NOT.
	 */
	public static var NSNotPredicateType:NSCompoundPredicateType 
		= new NSCompoundPredicateType(0, "NOT", "!");
		
	/**
	 * Logical AND.
	 */
	public static var NSAndPredicateType:NSCompoundPredicateType 
		= new NSCompoundPredicateType(1, "AND", "&&");
		
	/**
	 * Logical OR.
	 */
	public static var NSOrPredicateType:NSCompoundPredicateType 
		= new NSCompoundPredicateType(2, "OR", "||");
	
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
			:NSCompoundPredicateType {
		for (var k:String in g_keywords) {
			if (k == keyword) {
				return NSCompoundPredicateType(g_keywords[k]);
			}
		}
		
		return null;
	}
	
	//******************************************************
	//*                     Instance
	//******************************************************
	
	/** The string representation of the type. */
	public var string:String;
	
	/** The alternate string representation of the type. */
	public var altString:String;
	
	/**
	 * Creates a new instance of the <code>NSCompoundPredicateType</code> class.
	 */
	private function NSCompoundPredicateType(value:Number, string:String,
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