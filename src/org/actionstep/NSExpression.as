/* See LICENSE for copyright and terms of use */

import org.actionstep.binding.NSKeyValueCoding;
import org.actionstep.constants.NSExpressionType;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.ASUtils;
import org.actionstep.NSDate;

/**
 * <p><code>NSExpression</code> is used to represent expressions in a predicate.
 * </p>
 * 
 * <p>Comparison operations in an {@link org.actionstep.NSPredicate} are based 
 * on two expressions, as represented by instances of the 
 * <code>NSExpression</code> class. Expressions are created for constant values,
 * key paths, and so on.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSExpression extends NSObject {
	
	private static var LOG_E:Number = 0.4342944821;
	private static var g_functions:NSDictionary;
	private static var g_initialized:Boolean;
	
	private var m_args:NSArray;
	private var m_const:Object;
	private var m_func:String;
	private var m_path:String;
	private var m_var:String;
	private var m_type:NSExpressionType;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Constructs a new instance of NSExpression.
	 */
	public function NSExpression() {
	}
	
	/**
	 * Initializes a newly created <code>NSExpression</code> with the expression
	 * type <code>type</code>.
	 */
	public function initWithExpressionType(type:NSExpressionType):NSExpression {
		m_type = type;
		return this;
	}
	
	//******************************************************
	//*              Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the expression.
	 */
	public function description():String {
		var ret:String = "NSExpression(expressionType=";
				
		switch (m_type) {
			case NSExpressionType.NSConstantValueExpressionType:
				ret += "NSConstantValueExpressionType";
				ret += ", constantValue=" + m_const;
				break;
				
			case NSExpressionType.NSEvaluatedObjectExpressionType:
				ret += "NSEvaluatedObjectExpressionType";
				break;
				
			case NSExpressionType.NSVariableExpressionType:
				ret += "NSVariableExpressionType";
				ret += ", variable=" + variable;
				break;
				
			case NSExpressionType.NSKeyPathExpressionType:
				ret += "NSKeyPathExpressionType";
				ret += ", keyPath=" + m_path;
				break;
				
			case NSExpressionType.NSFunctionExpressionType:
				ret += "NSFunctionExpressionType";
				ret += ", functionName=" + m_func;
				ret += ", arguments=" + m_args;
				break;
				
			default:
				ret += "none";
				break;
		}
		
		ret += ")";
		return ret;
	}
	
	/**
	 * Returns the expression as it would appear in a formatting string.
	 */
	public function toFormatString():String {
		var ret:String;		
		switch (m_type) {
			case NSExpressionType.NSConstantValueExpressionType:
				ret = constantValue().toString();
				break;
				
			case NSExpressionType.NSEvaluatedObjectExpressionType:
				ret = "SELF";
				break;
				
			case NSExpressionType.NSVariableExpressionType:
				ret = variable();
				break;
				
			case NSExpressionType.NSKeyPathExpressionType:
				ret = keyPath();
				break;
				
			case NSExpressionType.NSFunctionExpressionType:
				ret = functionName() + "(";
				
				var arr:Array = m_args.internalList();
				var len:Number = arr.length;
				for (var i:Number = 0; i < len; i++) {
					ret += NSExpression(arr[i]).toFormatString();
					
					if (i + 1 < len) {
						ret += ", ";
					}
				}
				
				ret += ")";
				
				break;
				
		}
		
		return ret; // overridden in subclasses
	}
	
	//******************************************************
	//*      Getting information about an expression
	//******************************************************
	
	/**
	 * <p>Returns the arguments for this function expression.</p>
	 *
	 * <p>If this is not a function expression, an exception is raised.</p>
	 */
	public function arguments():NSArray {
		if (m_type != NSExpressionType.NSFunctionExpressionType) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSException",
				"Arguments can only be accessed when an expression's type is "
				+ "NSFunctionExpressionType.", 
				null);
			trace(e);
			throw e;
		}
		
		return m_args;	
	}
	
	/**
	 * <p>Returns the constant for this constant expression.</p>
	 *
	 * <p>If this is not a constant expression, an exception is raised.</p>
	 */
	public function constantValue():Object {
		if (m_type != NSExpressionType.NSConstantValueExpressionType) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSException",
				"Constant value can only be accessed when an expression's type " 
				+ "is NSConstantValueExpressionType.", 
				null);
			trace(e);
			throw e;
		}
		
		return m_const;	
	}	
	
	/**
	 * Returns this expression's type, or raises an exception if the
	 * expression has not been assigned a type.
	 */
	public function expressionType():NSExpressionType {
		if (m_type == undefined) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSException",
				"Expression type can only be accessed after it has been set.", 
				null);
			trace(e);
			throw e;
		}
		
		return m_type;
	}	
	
	/**
	 * <p>Returns the function name for this function expression.</p>
	 *
	 * <p>If this is not a function expression, an exception is raised.</p>
	 */
	public function functionName():String {
		if (m_type != NSExpressionType.NSFunctionExpressionType) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSException",
				"Function name can only be accessed when an expression's type " 
				+ "is NSFunctionExpressionType.", 
				null);
			trace(e);
			throw e;
		}
		
		return m_func;	
	}
	
	/**
	 * <p>Returns the key path for this key path expression.</p>
	 *
	 * <p>If this is not a key path expression, an exception is raised.</p>
	 */
	public function keyPath():String {
		if (m_type != NSExpressionType.NSKeyPathExpressionType)	{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSException",
				"Key path can only be accessed when an expression's type is " 
				+ "NSKeyPathExpressionType.", 
				null);
			trace(e);
			throw e;
		}
		
		return m_path;	
	}
	
	/**
	 * <p>Returns the object on which this selector will be invoked.</p>
	 *
	 * <p>If this is not a function or key path expression, an exception is 
	 * raised.</p>
	 */
	public function operand():Object {
		if (m_type != NSExpressionType.NSFunctionExpressionType &&
				m_type != NSExpressionType.NSKeyPathExpressionType)	{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSException",
				"Operand can only be accessed when an expression's type is " 
				+ "NSFunctionExpressionType or NSKeyPathExpressionType.", 
				null);
			trace(e);
			throw e;
		}
		
		return null;	
	}
	
	/**
	 * <p>Returns the variable name for this variable expression.</p>
	 *
	 * <p>If this is not a variable expression, an exception is raised.</p>
	 */
	public function variable():String {
		if (m_type != NSExpressionType.NSVariableExpressionType) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSException",
				"Variable can only be accessed when an expression's type is " 
				+ "NSVariableExpressionType.", 
				null);
			trace(e);
			throw e;
		}
		
		return m_var;	
	}
	
	//******************************************************
	//*              Evaluating an expression
	//******************************************************
	
	/**
	 * Evaluates itself using the object <code>object</code> and context 
	 * <code>context</code>.
	 */
	public function expressionValueWithObjectContext(object:Object, 
			context:NSDictionary):Object {
		
		//
		// Return evaluated expression value based on expression type
		//	
		switch (expressionType()) {
			case NSExpressionType.NSConstantValueExpressionType:
				return constantValue();
				break;
				
			case NSExpressionType.NSEvaluatedObjectExpressionType:
				return object;
				break;
				
			case NSExpressionType.NSFunctionExpressionType:
				var argVals:NSArray = NSArray.array();
				var args:Array = arguments().internalList();
				var len:Number = args.length;
				
				for (var i:Number = 0; i < len; i++) {
					argVals.addObject(NSExpression(args[i])
						.expressionValueWithObjectContext(object, context));
				}
				
				return invokeNamedFunctionWithArguments(functionName(),
					argVals);
				break;
				
			case NSExpressionType.NSKeyPathExpressionType:
				return NSKeyValueCoding.valueWithObjectForKeyPath(object, keyPath());
				break;
				
			case NSExpressionType.NSVariableExpressionType:
				//! TODO What is the variable bindings table?
				break;
		}
		
		return null;
	}
	
	//******************************************************
	//*            Instance Construction Methods
	//******************************************************	
	
	/**
	 * Returns a new expression that represents a constant value.
	 */
	public static function expressionForConstantValue(obj:Object):NSExpression {
		var exp:NSExpression = (new NSExpression()).initWithExpressionType(
			NSExpressionType.NSConstantValueExpressionType);
		exp.m_const = obj;
		
		return exp;
	}
	
	/**
	 * Returns a new expression that represents the object being evaluated.
	 */
	public static function expressionForEvaluatedObject():NSExpression {
		var exp:NSExpression = (new NSExpression()).initWithExpressionType(
			NSExpressionType.NSEvaluatedObjectExpressionType);
		
		return exp;	
	}
	
	/**
	 * <p>Returns a new expression that invokes a predefined function.</p> 
	 * 
	 * <p>The <code>name</code> parameter can be one of the following predefined 
	 * functions:</p>
	 *
	 * <p><ul>
	 * <li>avg
	 * <li>count
	 * <li>max
	 * <li>min
	 * <li>sum
	 * </ul></p>
	 *
	 * <p>All of these methods take an {@link NSArray} of 
	 * <code>NSExpressions</code> as their arguments and return a 
	 * <code>Number</code> back.</p>
	 * 
	 * <p>If <code>name</code> is not a valid function name, an
	 * {@link NSException} is raised.</p> 
	 */
	public static function expressionForFunctionArguments(name:String, 
			args:NSArray):NSExpression {
		//
		// Validate function
		//
		if (!isFunctionValid(name)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				name + " is not a valid function name.",
				null);
			trace(e);
			throw e;
		}
		
		var exp:NSExpression = (new NSExpression()).initWithExpressionType(
			NSExpressionType.NSFunctionExpressionType);
		exp.m_func = name;
		exp.m_args = args;
		
		return exp;
	}
	
	/**
	 * Returns a new expression using the key path <code>keyPath</code>.
	 */
	public static function expressionForKeyPath(keyPath:String):NSExpression {
		var exp:NSExpression = (new NSExpression()).initWithExpressionType(
			NSExpressionType.NSKeyPathExpressionType);
		exp.m_path = keyPath;
		
		return exp;
	}
	
	/**
	 * Returns a new expression that extracts a value from the variable bindings
	 * dictionary.
	 */
	public static function expressionForVariable(string:String):NSExpression {
		var exp:NSExpression = (new NSExpression()).initWithExpressionType(
			NSExpressionType.NSVariableExpressionType);
		exp.m_var = string;
		
		return exp;
	}
	
	//******************************************************
	//*                  Helper methods
	//******************************************************
	
	/**
	 * Returns <code>true</code> if <code>name</code> is a valid function name.
	 */
	public static function isFunctionValid(name:String):Boolean {
		return g_functions.objectForKey(name) != null;
	}
	
	//******************************************************
	//*                 Expression Functions
	//******************************************************
	
	/**
	 * <p>Adds an expression function named <code>name</code>.</p>
	 * 
	 * <p>When the function is invoked, <code>target</code>'s 
	 * <code>selector</code> method will be called and passed any arguments as 
	 * specified in the predicate format string.</p>
	 * 
	 * <p>An exception will be thrown if <code>name</code> is <code>null</code> 
	 * or has a length of <code>0</code>.</p> 
	 */
	public static function addFunctionWithNameTargetSelector(name:String,
			target:Object, selector:String):Void {
		//
		// Argument check
		//
		if (name == null || name.length == 0) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"name must be non-null and must have a non-zero length.",
				null);
			trace(e);
			throw e;
		}
		
		g_functions.setObjectForKey(
			{target: target, selector: selector},
			name);
	}
	
	/**
	 * Returns <code>true</code> if <code>aString</code> begins with a 
	 * registered function name.
	 */
	public static function beginsWithFunctionName(aString:String):Boolean {
		aString = aString.toLowerCase();
		var arr:Array = g_functions.allKeys().internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			if (aString.indexOf(arr[i]) == 0) {
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Returns <code>true</code> if <code>aString</code> begins with a 
	 * registered function name followed by an opening parenthesis.
	 */
	public static function beginsWithFunctionNameParen(aString:String):Boolean {
		aString = aString.toLowerCase();
		var arr:Array = g_functions.allKeys().internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			if (aString.indexOf(arr[i] + "(") == 0) {
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * <p>Invokes the function named <code>name</code> with the arguments 
	 * <code>args</code> and returns the result.</p>
	 * 
	 * <p>If no function with the name <code>name</code> exists, an exception
	 * is raised.</p>
	 */
	public static function invokeNamedFunctionWithArguments(name:String, 
			args:NSArray):Object {
		var f:Object = g_functions.objectForKey(name);

		if (f == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"There is no function named " + name,
				null);
			trace(e);
			throw e;
		}
		
		return Function(f.target[f.selector]).apply(f.target, args.internalList());		
	}
	
	//******************************************************
	//*                 Function handlers
	//******************************************************
	
	/**
	 * sum() function handler
	 */
	private static function sumFunction(obj1:Object, obj2:Object):Object {
		if (!ASUtils.isNumber(obj1) || !ASUtils.isNumber(obj2)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"sum() only accepts numeric arguments",
				null);
			trace(e);
			throw e;
		}
		
		return obj1 + obj2;
	}
	
	/**
	 * count() function handler
	 */
	private static function countFunction(obj:Object):Object {
		var arr:Object = ASUtils.extractArrayFromCollection(obj);
		if (arr == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"count() only accepts an argument of type NSArray, NSSet "
				+ "or Array",
				null);
			trace(e);
			throw e;
		}
		
		return arr.length;
	}
	
	/**
	 * min() function handler
	 */
	private static function minFunction(obj1:Object, obj2:Object):Object {
		if (!ASUtils.isNumber(obj1) || !ASUtils.isNumber(obj2)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"min() only accepts numeric arguments",
				null);
			trace(e);
			throw e;
		}
		
		return Math.min(Number(obj1), Number(obj2));
	}
	
	/** 
	 * max() function handler
	 */
	private static function maxFunction(obj1:Object, obj2:Object):Object {
		if (!ASUtils.isNumber(obj1) || !ASUtils.isNumber(obj2)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"max() only accepts numeric arguments",
				null);
			trace(e);
			throw e;
		}
		
		return Math.max(Number(obj1), Number(obj2));
	}
	
	/**
	 * average() function handler
	 */
	private static function averageFunction(obj:Object):Object {
		var arr:Object = ASUtils.extractArrayFromCollection(obj);
		if (arr == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"average() only accepts an argument of type NSArray, NSSet "
				+ "or Array",
				null);
			trace(e);
			throw e;
		}
		
		var sum:Number = 0;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			//
			// Make sure the element is a number
			//
			if (!ASUtils.isNumber(arr[i])) {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSInvalidArgument,
					"The collection passed to average() must contain only " 
					+ "numbers.",
					null);
				trace(e);
				throw e;
			}
			
			sum += Number(arr[i]);
		}
		
		return sum / arr.length;
	}
	
	/**
	 * median() function handler
	 */
	private static function medianFunction(obj:Object):Object {
		var arr:Object = ASUtils.extractArrayFromCollection(obj);
		if (arr == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"average() only accepts an argument of type NSArray, NSSet "
				+ "or Array",
				null);
			trace(e);
			throw e;
		}
		
		var sortedArr:Array = arr.sort(Array.NUMERIC | Array.RETURNINDEXEDARRAY);
		return sortedArr[Math.floor(sortedArr.length / 2)];
	}
	
	/**
	 * mode() function handler
	 */
	private static function modeFunction():Object {
		//! TODO Implement mode()
		return null;
	}
	
	/**
	 * stddev() function handler
	 */
	private static function stddevFunction(obj:Object):Object {
		var arr:Object = ASUtils.extractArrayFromCollection(obj);
		if (arr == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"average() only accepts an argument of type NSArray, NSSet "
				+ "or Array",
				null);
			trace(e);
			throw e;
		}
		
		var mean:Number = Number(averageFunction(arr));
		var sum:Number = 0;
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			//
			// Note, there is no need to check for number types here because
			// the average function has already done so.
			//		
			sum += Math.pow(Number(arr[i]) - mean, 2);
		}
		
		return Math.sqrt(sum / len);
	}
	
	/**
	 * sqrt() function handler
	 */
	private static function sqrtFunction(obj:Object):Object {
		if (!ASUtils.isNumber(obj)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"sqrt() only accepts a numeric argument",
				null);
			trace(e);
			throw e;
		}
		
		return Math.sqrt(Number(obj));
	}
	
	/**
	 * log() function handler
	 */
	private static function logFunction(obj:Object):Object {
		if (!ASUtils.isNumber(obj)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"log() only accepts a numeric argument",
				null);
			trace(e);
			throw e;
		}
		
		return Math.log(Number(obj));
	}
	
	/**
	 * ln() function handler
	 */
	private static function lnFunction(obj:Object):Object {
		if (!ASUtils.isNumber(obj)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"ln() only accepts a numeric argument",
				null);
			trace(e);
			throw e;
		}
		
		var num:Number = Number(obj);
		return Math.log(num) / LOG_E;
	}
	
	/**
	 * exp() function handler
	 */
	private static function expFunction(obj1:Object):Object {
		if (!ASUtils.isNumber(obj1)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"exp() only accepts numeric arguments",
				null);
			trace(e);
			throw e;
		}
		
		return Math.exp(Number(obj1));
	}
	
	/**
	 * floor() function handler
	 */
	private static function floorFunction(obj1:Object):Object {
		if (!ASUtils.isNumber(obj1)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"floor() only accepts numeric arguments",
				null);
			trace(e);
			throw e;
		}
		
		return Math.floor(Number(obj1));
	}
	
	/**
	 * ceiling() function handler
	 */
	private static function ceilingFunction(obj1:Object):Object {
		if (!ASUtils.isNumber(obj1)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"ceiling() only accepts numeric arguments",
				null);
			trace(e);
			throw e;
		}
		
		return Math.ceil(Number(obj1));
	}
	
	/**
	 * abs() function handler
	 */
	private static function absFunction(obj:Object):Object {
		if (!ASUtils.isNumber(obj)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"abs() only accepts numeric arguments",
				null);
			trace(e);
			throw e;
		}
		
		return Math.abs(Number(obj));
	}
	
	/**
	 * trunc() function handler
	 */
	private static function truncFunction():Object {
		//! TODO Implement trunc()
		return null;
	}
	
	/**
	 * random() function handler
	 */
	private static function randomFunction():Object {
		//! TODO Check if this is right
		return Math.random();
	}
	
	/**
	 * now() function handler
	 */
	private static function nowFunction():Object {	
		return NSDate.date();
	}
			
	//******************************************************
	//*                 Static construction
	//******************************************************
	
	/**
	 * Static constructor
	 */
	private static function initialize():Void {
		if (g_initialized) {
			return;
		}
		
		g_functions = NSDictionary.dictionary();
		
		//
		// Add the default functions
		//
		addFunctionWithNameTargetSelector("sum", NSExpression, "sumFunction");
		addFunctionWithNameTargetSelector("count", NSExpression, "countFunction");
		addFunctionWithNameTargetSelector("min", NSExpression, "minFunction");
		addFunctionWithNameTargetSelector("max", NSExpression, "maxFunction");
		addFunctionWithNameTargetSelector("average", NSExpression, "averageFunction");
		addFunctionWithNameTargetSelector("median", NSExpression, "medianFunction");
		addFunctionWithNameTargetSelector("mode", NSExpression, "modeFunction");
		addFunctionWithNameTargetSelector("stddev", NSExpression, "stddevFunction");
		addFunctionWithNameTargetSelector("sqrt", NSExpression, "sqrtFunction");
		addFunctionWithNameTargetSelector("log", NSExpression, "logFunction");
		addFunctionWithNameTargetSelector("ln", NSExpression, "lnFunction");
		addFunctionWithNameTargetSelector("exp", NSExpression, "expFunction");
		addFunctionWithNameTargetSelector("floor", NSExpression, "floorFunction");
		addFunctionWithNameTargetSelector("ceiling", NSExpression, "ceilingFunction");
		addFunctionWithNameTargetSelector("abs", NSExpression, "absFunction");
		addFunctionWithNameTargetSelector("trunc", NSExpression, "truncFunction");
		addFunctionWithNameTargetSelector("random", NSExpression, "randomFunction");
		addFunctionWithNameTargetSelector("now", NSExpression, "nowFunction");
		
		g_initialized = true;
	}
}
