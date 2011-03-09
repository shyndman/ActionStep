/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSComparisonPredicateModifier;
import org.actionstep.constants.NSPredicateOperatorType;
import org.actionstep.NSPredicate;
import org.actionstep.NSExpression;
import org.actionstep.NSException;
import org.actionstep.ASUtils;
import org.actionstep.NSArray;
import org.actionstep.constants.NSComparisonPredicateOptions;

/**
 * <p>This class is a predicate used to compare expressions.</p>
 *
 * <p>This predicate compares the results of two expressions, compares the results
 * with an operator, and returns a boolean value. An expression is represented
 * by an instance of the {@link NSExpression} class.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSComparisonPredicate extends NSPredicate {

	private var m_leftExpression:NSExpression;
	private var m_rightExpression:NSExpression;
	private var m_customSelector:String;
	private var m_comparisonModifier:NSComparisonPredicateModifier;
	private var m_options:Number;
	private var m_operatorType:NSPredicateOperatorType;
	private var m_usesSelector:Boolean;
	
	//******************************************************
	//*                   Construction
	//******************************************************
		
	/**
	 * Creates a new instance of the <code>NSComparisonPredicate</code> class.
	 */
	public function NSComparisonPredicate() {
		m_usesSelector = false;
	}
	
	/**
	 * Initializes a predicate formed by combining the left and right 
	 * expressions using the specified selector.
	 */
	public function initWithLeftExpressionRightExpressionCustomSelector(
			lhs:NSExpression, rhs:NSExpression, selector:String)
			:NSComparisonPredicate {
		m_leftExpression = lhs;
		m_rightExpression = rhs;
		m_customSelector = selector;
		m_usesSelector = true;
		
		return this;
	}
	
	/**
	 * Initializes a predicate of type <code>type</code> formed by combining the 
	 * left and right expressions using the specified modifier and options.
	 */
	public function initWithLeftExpressionRightExpressionModifierTypeOptions(
			lhs:NSExpression, rhs:NSExpression,
			mod:NSComparisonPredicateModifier, type:NSPredicateOperatorType,
			options:Number):NSComparisonPredicate {
		m_leftExpression = lhs;
		m_rightExpression = rhs;
		m_comparisonModifier = mod;
		m_operatorType = type;
		m_options = options;
		m_usesSelector = false;
		
		return this;		
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the predicate.
	 */
	public function description():String {
		return "NSComparisonPredicate(leftExpression=" + leftExpression() 
			+ ",predicateOperatorType=" + predicateOperatorType().string
			+ ",rightExpression=" + rightExpression() + ")";
	}
	
	/**
	 * Returns the predicate as it would appear in a formatting string.
	 */
	public function toFormatString():String {
		return leftExpression().toFormatString() + " "
			+ predicateOperatorType().string + " "
			+ rightExpression().toFormatString();
	}
	
	//******************************************************
	//*  Getting information about a comparison predicate
	//******************************************************
	
	/**
	 * Returns the comparison predicate modifier, or <code>null</code> if there
	 * is none.
	 */
	public function comparisonPredicateModifier():NSComparisonPredicateModifier{
		return m_comparisonModifier;
	}
	
	/**
	 * Returns the selector for the predicate, or <code>null</code> if there is
	 * none.
	 */
	public function customSelector():String {
		return m_customSelector;
	}
	
	/**
	 * Returns the left expression for the predicate, or <code>null</code> if 
	 * there is none.
	 */
	public function leftExpression():NSExpression {
		return m_leftExpression;
	}
	
	/**
	 * Returns the right expression for the predicate, or <code>null</code> if 
	 * there is none.
	 */
	public function rightExpression():NSExpression {
		return m_rightExpression;
	}
	
	/**
	 * Returns the options that are set for the predicate.
	 */
	public function options():Number {
		return m_options;
	}
	
	/**
	 * Returns the predicate type for the predicate, or <code>null</code> if 
	 * there is none.
	 */
	public function predicateOperatorType():NSPredicateOperatorType {
		return m_operatorType;
	}
	
	//******************************************************
	//*                   Evaluating
	//******************************************************
	
	/**
	 * Returns <code>true</code> if the object satisfies the conditions of 
	 * the predicate.
	 */
	public function evaluateWithObject(object:Object):Boolean {
		var lhs:Object = m_leftExpression.expressionValueWithObjectContext(
			object, null);
		var rhs:Object = m_rightExpression.expressionValueWithObjectContext(
			object, null);
			
		//
		// Options
		//
		var opts:Number = options();
		var optCi:Boolean = (opts & NSComparisonPredicateOptions.NSCaseInsensitivePredicateOption.value)
			== NSComparisonPredicateOptions.NSCaseInsensitivePredicateOption.value;
		var optDi:Boolean = (opts & NSComparisonPredicateOptions.NSDiacriticInsensitivePredicateOption.value)
			== NSComparisonPredicateOptions.NSDiacriticInsensitivePredicateOption.value;
		
		//
		// Apply options
		//
		if (optCi && ASUtils.isString(rhs)) {
			rhs = String(rhs).toLowerCase();
		}
		if (optDi && ASUtils.isString(rhs)) {
			rhs = ASUtils.dediacriticfyString(String(rhs));
		}
			
		//
		// Perform the operation based on the modifier
		//
		var mod:NSComparisonPredicateModifier = comparisonPredicateModifier();
		if (mod == NSComparisonPredicateModifier.NSAllPredicateModifier) {
			//
			// Get internal Array
			//
			var arr:Object = ASUtils.extractArrayFromCollection(lhs);
			if (arr == null) {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSInvalidArgument,
					"The ALL modifier expect a collection as the left "
					+ "operand.",
					null);
				trace(e);
				throw e;
			}
			
			//
			// Make sure every object in the collection matches
			//
			var len:Number = arr.length;
			for (var i:Number = 0; i < len; i++) {
				var lo:Object = arr[i];
				
				if (optCi && ASUtils.isString(lo)) {
					lo = String(lo).toLowerCase();
				}
				if (optDi && ASUtils.isString(lo)) {
					lo = ASUtils.dediacriticfyString(String(lo));
				}
				
				if (!performOperation(lo, rhs)) {
					return false;
				}
			}
			
			return true;
		}
		else if (mod == NSComparisonPredicateModifier.NSAnyPredicateModifier
				|| mod == NSComparisonPredicateModifier.NSNonePredicateModifier) {
			//
			// Get internal Array
			//
			var arr:Object = ASUtils.extractArrayFromCollection(lhs);
			if (arr == null) {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSInvalidArgument,
					"ANY and NONE modifiers expect a collection as the left "
					+ "operand.",
					null);
				trace(e);
				throw e;
			}
			
			//
			// Test each object until we find a match
			//
			var ret:Boolean = false;
			var len:Number = arr.length;
			for (var i:Number = 0; i < len; i++) {
				var lo:Object = arr[i];
				
				if (optCi && ASUtils.isString(lo)) {
					lo = String(lo).toLowerCase();
				}
				if (optDi && ASUtils.isString(lo)) {
					lo = ASUtils.dediacriticfyString(String(lo));
				}
				
				if (performOperation(lo, rhs)) {
					ret = true;
					break;
				}
			}
			
			if (mod == NSComparisonPredicateModifier.NSNonePredicateModifier) {
				ret = !ret;
			}
			
			return ret;
		} else { // direct
			//
			// Apply options
			//
			if (optCi && ASUtils.isString(lhs)) { // rhs is already handled
				lhs = String(lhs).toLowerCase();
			}
			if (optDi && ASUtils.isString(lhs)) {
				lhs = ASUtils.dediacriticfyString(String(lhs));
			}
				
			return performOperation(lhs, rhs);
		}
	}
	
	/**
	 * Performs the comparison and returns the result.
	 */
	private function performOperation(lhs:Object, rhs:Object):Boolean {
		//
		// Perform the operation based on the current operator
		//
		switch (m_operatorType) {
			case NSPredicateOperatorType.NSLessThanPredicateOperatorType:
				return lhs < rhs;
				
			case NSPredicateOperatorType.NSLessThanOrEqualToPredicateOperatorType:
				return lhs <= rhs;
				
			case NSPredicateOperatorType.NSGreaterThanPredicateOperatorType:
				return lhs > rhs;
				
			case NSPredicateOperatorType.NSGreaterThanOrEqualToPredicateOperatorType:
				return lhs >= rhs;
				
			case NSPredicateOperatorType.NSEqualToPredicateOperatorType:
				return lhs == rhs;
				
			case NSPredicateOperatorType.NSNotEqualToPredicateOperatorType:
				return lhs != rhs;
				
			//
			// FIXME Add MATCHES support when Regex is native
			//
			case NSPredicateOperatorType.NSMatchesPredicateOperatorType:
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSGeneric,
					"MATCHES operator currently not supported.",
					null);
				trace(e);
				throw e;
				
			case NSPredicateOperatorType.NSLikePredicateOperatorType:
				return evalLike(lhs, rhs);
				
			case NSPredicateOperatorType.NSBeginsWithPredicateOperatorType:
				return evalBeginsWith(lhs, rhs);
				
			case NSPredicateOperatorType.NSEndsWithPredicateOperatorType:
				return evalEndsWith(lhs, rhs);
				
			case NSPredicateOperatorType.NSInPredicateOperatorType:
				return evalIn(lhs, rhs);
				
			case NSPredicateOperatorType.NSCustomSelectorPredicateOperatorType:
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSGeneric,
					"Custom selector operations currently not supported.",
					null);
				trace(e);
				throw e;
		}
		
		return false;	
	}
	
	/**
	 * Evaluates <code>lhs</code> and <code>rhs</code> using the 
	 * <code>LIKE</code> operator.
	 */
	private function evalLike(lhs:Object, rhs:Object):Boolean {
		if (!ASUtils.isString(lhs) || !ASUtils.isString(rhs)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"The LIKE operator can only be used on strings.",
				null);
			trace(e);
			throw e;
		}
		
		var str:String = String(lhs);
		var stars:Array = String(rhs).split("*");
		var len:Number = stars.length;
		var pos:Number = 0;
		var lastPos:Number;
		
		for (var i:Number = 0; i < len; i++) {
			var piece:String = String(stars[i]);
			var percents:Array = piece.split("%");
			var len2:Number = percents.length;
			
			for (var j:Number = 0; j < len2; j++) {
				lastPos = pos;
				pos = str.indexOf(percents[j], pos);
				
				//! FIXME This won't really work as is
				
				if (pos == -1) {
					return false;
				}
			}
		}
		
		return true;
	}
	
	/**
	 * Evaluates <code>lhs</code> and <code>rhs</code> using the 
	 * <code>BEGINSWITH</code> operator.
	 */
	private function evalBeginsWith(lhs:Object, rhs:Object):Boolean {
		if (!ASUtils.isString(lhs) || !ASUtils.isString(rhs)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"The BEGINSWITH operator can only be used on strings.",
				null);
			trace(e);
			throw e;
		}
		
		var start:String = String(lhs).substr(0, String(rhs).length);
		
		return start == rhs;
	}
	
	/**
	 * Evaluates <code>lhs</code> and <code>rhs</code> using the 
	 * <code>ENDSWITH</code> operator.
	 */
	private function evalEndsWith(lhs:Object, rhs:Object):Boolean {
		if (!ASUtils.isString(lhs) || !ASUtils.isString(rhs)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"The ENDSWITH operator can only be used on strings.",
				null);
			trace(e);
			throw e;
		}
		
		var end:String = String(lhs).substr(-String(rhs).length);
		
		return end == rhs;
	}

	/**
	 * Evaluates <code>lhs</code> and <code>rhs</code> using the 
	 * <code>IN</code> operator.
	 */	
	private function evalIn(lhs:Object, rhs:Object):Boolean {
		//
		// String CONTAINS
		//
		if (ASUtils.isString(lhs) && ASUtils.isString(rhs)) {
			
			return String(rhs).indexOf(String(lhs)) != -1;
		}
		
		//
		// Array IN
		//
		var	arr:Object = ASUtils.extractArrayFromCollection(rhs);
		
		if (arr == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"The IN operator requires a collection as its right operand, "
				+ "or strings as both its left and right operands.",
				null);
			trace(e);
			throw e;
		}
		
		//
		// Options
		//
		arr = applyOptionsToArray(arr);
		
		var narr:NSArray = NSArray.array();
		narr["m_list"] = arr;
		
		return narr.containsObject(lhs);
	}
	
	//******************************************************
	//*                  Applying Options
	//******************************************************
	
	/**
	 * Returns a copy of <code>arr</code> with options applied. 
	 */
	public function applyOptionsToArray(arr:Object):Object {
		arr = arr.slice(0, arr.length);
		var opts:Number = options();
		var optCi:Boolean = (opts & NSComparisonPredicateOptions.NSCaseInsensitivePredicateOption.value)
			== NSComparisonPredicateOptions.NSCaseInsensitivePredicateOption.value;
		var optDi:Boolean = (opts & NSComparisonPredicateOptions.NSDiacriticInsensitivePredicateOption.value)
			== NSComparisonPredicateOptions.NSDiacriticInsensitivePredicateOption.value;
			
		if (optCi || optDi) {
			var len:Number = arr.length;
			for (var i:Number = 0; i < len; i++) {
				var e:Object = arr[i];
				if (!ASUtils.isString(e)) {
					continue;
				}
				
				//
				// Case change
				//
				if (optCi) {
					arr[i] = String(e).toLowerCase();
				}
				if (optDi) {
					arr[i] = ASUtils.dediacriticfyString(String(e));
				}
			}
		}
		
		return arr;	
	}
	
	//******************************************************
	//*                Instance constructors
	//******************************************************

	/**
	 * Returns a new predicate formed by combining the left and right 
	 * expressions using the specified selector.
	 */
	public static function predicateWithLeftExpressionRightExpressionCustomSelector(
			lhs:NSExpression, rhs:NSExpression, selector:String)
			:NSComparisonPredicate {
		return (new NSComparisonPredicate())
			.initWithLeftExpressionRightExpressionCustomSelector(lhs, rhs,
				selector);		
	}
	
	/**
	 * Returns a new predicate of type <code>type</code> formed by combining 
	 * the left and right expressions using the specified modifier and options.
	 */
	public static function predicateWithLeftExpressionRightExpressionModifierTypeOptions(
			lhs:NSExpression, rhs:NSExpression, 
			mod:NSComparisonPredicateModifier, type:NSPredicateOperatorType,
			options:Number):NSComparisonPredicate {
		return (new NSComparisonPredicate())
			.initWithLeftExpressionRightExpressionModifierTypeOptions(
				lhs, rhs, mod, type, options);		
	}	
}
