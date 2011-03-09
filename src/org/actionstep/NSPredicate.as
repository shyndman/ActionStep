/* See LICENSE for copyright and terms of use */

import org.actionstep.ASStringFormatter;
import org.actionstep.NSArray;
import org.actionstep.NSExpression;
import org.actionstep.NSObject;
import org.actionstep.predicates.ASPredicateStringParser;

/**
 * <p>This class is used to create search constraints.</p>
 * 
 * <p>Please note that {@link org.actionstep.NSApplication#run()} must be called 
 * before using predicates.</p>
 *
 * <p>To compile a predicate by using a format string, call
 * {@link #predicateWithFormat}, {@link #predicateWithFormatArgumentArray} or
 * {@link #predicateWithValue}.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSPredicate extends NSObject {	
	
	private var m_format:String;
	private var m_expression:NSExpression;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSPredicate</code> class.
	 */
	public function NSPredicate() {
	}
	
	/**
	 * Used internally to initialize a predicate with a format.
	 */
	private function initWithFormat(format:String):NSPredicate {
		m_format = format;
		return this;
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String {
		return "NSPredicate(predicateFormat=" + m_format + ")";
	}
	
	/**
	 * Returns the predicate as it would appear in a formatting string.
	 */
	public function toFormatString():String {
		return ""; // overridden in subclasses
	}
	
	//******************************************************
	//*             Getting format information
	//******************************************************
	
	/**
	 * Returns the format of this predicate.
	 */
	public function predicateFormat():String {
		return m_format;
	}
	
	//******************************************************
	//*                   Evaluating
	//******************************************************
	
	/**
	 * Returns <code>true</code> if the object satisfies the conditions of 
	 * the predicate.
	 */
	public function evaluateWithObject(object:Object):Boolean {
		return Boolean(m_expression.expressionValueWithObjectContext(
			object, null));
	}
	
	//******************************************************
	//*            Instance Construction Methods
	//******************************************************

	/**
	 * Creates a new predicate with the format format, which it parses
	 * immediately.
	 */
	public static function predicateWithFormat(format:String):NSPredicate {
		return ASPredicateStringParser.predicateForFormat(format);
	}
	
	/**
	 * Returns a new predicate by substituting the values in arguments into
	 * predicateFormat in the order they appear, and parsing the result.
	 */
	public static function predicateWithFormatArgumentArray(format:String, 
			args:NSArray):NSPredicate {
		format = format.split("%@").join("%\"@"); // make sure we use quotes
		format = ASStringFormatter.formatString(format, args);
		
		return predicateWithFormat(format);
	}
	
	/**
	 * Creates and returns a predicate that always evaluates to value.
	 */
	public static function predicateWithValue(value:Boolean):NSPredicate {
		var format:String;
		if (value)
			format = "TRUE";
		else
			format = "FALSE";
			
		return predicateWithFormat(format);
	}
}