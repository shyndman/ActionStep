/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;

/**
 * Represents a token in a predicate format string.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.predicates.ASPredicateToken extends Object {
	
	//******************************************************
	//*                    Constants
	//******************************************************
	
	public static var KEYWORD:Number		= 1;
	public static var GROUP:Number			= 2;
	public static var EXPRESSION:Number		= 3;
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	public var type:Number;
	public var subTokens:NSArray;
	public var contents:String;
	public var position:Number;
	public var isFunction:Boolean;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASPredicateToken</code> class.
	 */
	public function ASPredicateToken() {
		isFunction = false;
	}
	
	/**
	 * Creates and returns a new group token.
	 */
	public static function groupToken():ASPredicateToken {
		var token:ASPredicateToken = new ASPredicateToken();
		token.type = GROUP;
		token.subTokens = new NSArray();
		
		return token;
	}
	
	/**
	 * Creates and returns a new keyword token.
	 */
	public static function keywordTokenWithContents(contents:String)
			:ASPredicateToken {
		var token:ASPredicateToken = new ASPredicateToken();
		token.type = KEYWORD;
		token.contents = contents;
		
		return token;
	}
	
	/**
	 * Creates and returns a new expression token.
	 */
	public static function expressionTokenWithContents(contents:String)
			:ASPredicateToken {
		var token:ASPredicateToken = new ASPredicateToken();
		token.type = EXPRESSION;
		token.contents = contents;
		
		return token;
	}
	
	/**
	 * <p>Creates and returns a new function token, representing the function
	 * named <code>name</code>.</p>
	 * 
	 * <p><code>args</code> is an array of expression type 
	 * <code>ASPredicateToken</code>s.</p>
	 */
	public static function functionTokenWithNameArguments(name:String,
			args:NSArray):ASPredicateToken {
		var token:ASPredicateToken = new ASPredicateToken();
		token.type = EXPRESSION;
		token.isFunction = true;
		token.contents = name;
		token.subTokens = args;	
		
		return token;
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the object.
	 */
	public function toString():String {
		var ret:String = "ASPredicateToken(type=" + type + ",contents=";
		
		if (type == GROUP) {
			ret += subTokens.toString();
		} else {
			ret += contents;
		}
		
		ret += ",position=" + position + ")";
		
		return ret;
	}
}