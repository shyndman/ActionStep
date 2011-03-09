/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.constants.NSComparisonPredicateModifier;
import org.actionstep.constants.NSCompoundPredicateType;
import org.actionstep.constants.NSPredicateOperatorType;
import org.actionstep.NSArray;
import org.actionstep.NSComparisonPredicate;
import org.actionstep.NSCompoundPredicate;
import org.actionstep.NSException;
import org.actionstep.NSExpression;
import org.actionstep.NSObject;
import org.actionstep.NSPredicate;
import org.actionstep.predicates.ASPredicateToken;
import org.actionstep.NSDictionary;
import org.actionstep.constants.NSComparisonPredicateOptions;

/**
 * <p>Handles the parsing of predicate format strings into predicates.</p>
 * 
 * <p>The parser is whitespace insensitive, case insensitive with respect to 
 * keywords, and supports nested parenthetical expressions.</p>
 * 
 * <p>Used internally by <code>NSPredicate</code>.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.predicates.ASPredicateStringParser extends NSObject {
	
	//******************************************************
	//*                    States
	//******************************************************
	
	private static var INITIAL:Number			= 0;
	private static var NOT:Number				= 1;
	private static var AND:Number				= 2;
	private static var OR:Number				= 3;
	private static var PRED_OP:Number			= 4;
	private static var COMPARE_MOD:Number		= 5;
	private static var PREDICATE:Number			= 6;
	private static var EXPRESSION:Number		= 7;
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private static var g_instance:ASPredicateStringParser;
	
	private var m_root:ASPredicateToken;
	private var m_format:String;
	private var m_len:Number;
	private var m_idx:Number;
	private var m_needsNewToken:Boolean;

	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASPredicateStringParser</code> class.
	 */
	private function ASPredicateStringParser() {	
	}
	
	/**
	 * Initializes the predicate string parser.
	 */
	private function init():ASPredicateStringParser {
		return this;
	}
	
	//******************************************************
	//*             Parsing the format string
	//******************************************************
	
	/**
	 * Parses the format string <code>format</code> into a predicate.
	 */
	private function parseFormat(format:String):NSPredicate {
		if (!validateFormat(format)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				format + " is an invalid format string.",
				null);
			trace(e);
			throw e;
		}
		
		//
		// Set up necessary variables
		//
		m_format = format;
		m_idx = 0;
		m_len = format.length;
		m_root = ASPredicateToken.groupToken();
		m_needsNewToken = true;
		
		//
		// Tokenize step
		//
		tokenizeGroupUntilClose(m_root);
		
		//
		// Parsing step
		//
		return parseTokens(m_root.subTokens);
	}
	
	/**
	 * Parses the tokens contained in <code>group</code> and returns the
	 * resulting {@link NSPredicate}.
	 */
	private function parseTokens(tokens:NSArray):NSPredicate {
		//
		// Parsing states
		//
		var state:Number = INITIAL;
		var lastState:Number = null;		
		
		//
		// Predicates
		//
		var andStack:NSArray = NSArray.array();
		//
		// The predicate we will return. We start with an OR because it has 
		// operator precendence. If it is found that there is no need for the
		// OR because it has only one subpredicate, the subpredicate will be
		// returned.
		//
		var orPred:NSCompoundPredicate = NSCompoundPredicate.orPredicateWithSubpredicates(
			NSArray.array());; 
		var pred:NSPredicate = orPred;
		var curPred:NSPredicate = null; // The current predicate we are dealing with
		var insideAnd:Boolean = false;
		var waitingForNot:Boolean = false; // TRUE if we're building a NOT predicate
		var compMod:NSComparisonPredicateModifier 
			= NSComparisonPredicateModifier.NSDirectPredicateModifier;
		//
		// Expression variables
		//
		var lhsExp:NSExpression; // The left expression. NULL if none
		var expOp:NSPredicateOperatorType = null; // The expression operation. NULL if none
		var operOptions:Number = 0;
		
		//
		// Parse the tokens
		//
		var arr:Array = tokens.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			var t:ASPredicateToken = ASPredicateToken(arr[i]);
			
			switch (state) {
				case INITIAL:
//					trace("INITIAL state");
//					trace(t.contents);
					if (t.type == ASPredicateToken.GROUP) {
						//
						// Create predicate based on sub group
						//
						curPred = parseTokens(t.subTokens);
						lastState = state;
						state = PREDICATE;
					}
					else if (t.type == ASPredicateToken.KEYWORD
							&& isNotType(t.contents)) {
						//
						// Mark the state as NOT
						//
						lastState = state;
						state = NOT;
						waitingForNot = true;
					}
					else if (t.type == ASPredicateToken.KEYWORD
							&& isComparisonModifier(t.contents)) {
						//
						// Record the comparison modifier
						//
						compMod = NSComparisonPredicateModifier.constantForKeyword(
							t.contents);
						lastState = state;
						state = COMPARE_MOD;
					}
					else if (t.type == ASPredicateToken.EXPRESSION
							&& isExpression(t.contents)) {
						//
						// Add an expression to the stack
						//
						lhsExp = createExpression(t);
						lastState = state;
						state = EXPRESSION;
					} else {
						var e:NSException = NSException.exceptionWithNameReasonUserInfo(
							NSException.NSGeneric,
							"Predicate string must begin with an expression, " 
							+ "a NOT modifier, or a group (" + t.position + ")",
							null);
						trace(e);
						throw e;
					}
					
					break;
				
				case COMPARE_MOD:
					//
					// Expressions are all that are allowed
					//
					if (t.type != ASPredicateToken.EXPRESSION) {
						var e:NSException = NSException.exceptionWithNameReasonUserInfo(
							NSException.NSGeneric,
							"ANY, ALL and NONE keywords must be followed by an "
							+ "expression. (" + t.position + ")",
							null);
						trace(e);
						throw e;
					}
					
					//
					// Create an expression
					//			
					lhsExp = createExpression(t);
						
					lastState = state;
					state = EXPRESSION;
						
					break;
					
				case NOT:
//					trace("NOT state");
//					trace(t.contents);			
					if (t.type == ASPredicateToken.KEYWORD) {
						//
						// Double NOTs cancel
						//
						if (isNotType(t.contents)) {
							state = lastState;
							waitingForNot = state == NOT;
							continue;
						}
						
						//
						// No other keyword is valid
						//
						var e:NSException = NSException.exceptionWithNameReasonUserInfo(
							NSException.NSGeneric,
							"NOT keyword must be followed by an expression or " 
							+ " a group. (" + t.position + ")",
							null);
						trace(e);
						throw e;
					}
					else if (t.type == ASPredicateToken.GROUP) {
						//
						// Create a NOT predicate containing a seperate
						//
						curPred = NSCompoundPredicate.notPredicateWithSubpredicate(
							parseTokens(t.subTokens));
							
						lastState = state;
						state = PREDICATE;
						waitingForNot = false;
					}
					else if (t.type == ASPredicateToken.EXPRESSION) {
						//
						// Create an expression
						//			
						lhsExp = createExpression(t);
							
						lastState = state;
						state = EXPRESSION;
					}
					
					break;
					
				case AND:					
					// fall through
				case OR:
//					trace("AND/OR state");
//					trace(t.contents);
					
					if (t.type == ASPredicateToken.KEYWORD
							&& isNotType(t.contents)) {
						//
						// NOT handling
						//
						waitingForNot = true;
						lastState = state;
						state = NOT;
					}
					else if (t.type == ASPredicateToken.GROUP) {
						curPred = parseTokens(t.subTokens);
						lastState = state;
						state = PREDICATE;
					}
					else if (t.type == ASPredicateToken.EXPRESSION) {
						lhsExp = createExpression(t);
						lastState = state;
						state = EXPRESSION;
					} else {
						//
						// Invalid state
						//
						var e:NSException = NSException.exceptionWithNameReasonUserInfo(
							NSException.NSGeneric,
							"AND or OR must be followed by a group, NOT or an "
							+ "expression. (" + t.position + ")",
							null
							);
						trace(e);
						throw e;
					}
					
					break;
					
				case PREDICATE:
//					trace("PREDICATE state");
//					trace(t.contents);
					
					//
					// Predicates anticipate following operators
					//
					if (t.type != ASPredicateToken.KEYWORD
							|| !isCompoundType(t.contents)
							|| isNotType(t.contents)) {
						var e:NSException = NSException.exceptionWithNameReasonUserInfo(
							NSException.NSGeneric,
							"Predicates must be followed by an AND or an OR. (" 
							+ t.position + ")",
							null);
						trace(e);
						throw e;
					}
					
					//
					// AND or OR
					//
					lastState = state;
					if (isAndType(t.contents)) {
						state = AND;

						//
						// We now we're in an AND, so we perform the necessary
						// modifications.
						//
						if (!insideAnd) {
							andStack.removeAllObjects();
							insideAnd = true;
							
							var sp:NSArray = orPred.subpredicates();
							andStack.addObject(sp.lastObject());
							sp.removeLastObject();
						}
					}
					else if (isOrType(t.contents)) {
						state = OR;
						
						if (insideAnd) {
							insideAnd = false;
							
							orPred.subpredicates().addObject(
								NSCompoundPredicate.andPredicateWithSubpredicates(
								(new NSArray()).initWithArrayCopyItems(andStack, false)));
							andStack.removeAllObjects();
						}
					}
										
					break;
					
				case EXPRESSION:
//					trace("EXPRESSION state");
//					trace(t.contents);
					
					//
					// Expressions expect a predicate operator to follow
					//
					if (!isPredicateOperator(t.contents)) {
						var e:NSException = NSException.exceptionWithNameReasonUserInfo(
							NSException.NSGeneric,
							"Expressions must be followed by a predicate " 
							+ "operator. (" + t.position + ")",
							null);
						trace(e);
						throw e;
					}
					
					//
					// isPredicateOperator(t.contents)
					//
					var optionIdx:Number = t.contents.indexOf("[");
					if (optionIdx == -1) {
						expOp = NSPredicateOperatorType.constantForKeyword(
							t.contents);
					} else {
						//
						// Extract the comparison options
						//
						expOp = NSPredicateOperatorType.constantForKeyword(
							t.contents.substr(0, optionIdx));
						operOptions = optionsForString(t.contents.substring(
							optionIdx + 1, t.contents.indexOf("]")));
					}
					
					lastState = state;
					state = PRED_OP;
					
					break;
					
				case PRED_OP:
//					trace("PRED_OP state");
//					trace(t.contents);
					
					//
					// Make sure we're on an expression
					//
					if (t.type == ASPredicateToken.KEYWORD
							|| !isExpression(t.contents)) {
						var e:NSException = NSException.exceptionWithNameReasonUserInfo(
							NSException.NSGeneric,
							"Predicate operators must be followed by an "
							+ "expression (" + t.position + ")",
							null);
						trace(e);
						throw e;
					}
					
					//
					// t.contents is an expression
					//
					curPred = NSComparisonPredicate.
						predicateWithLeftExpressionRightExpressionModifierTypeOptions(
							lhsExp,
							createExpression(t),
							compMod,
							expOp,
							operOptions
						);
						
					//
					// Reset variables
					//
					lhsExp = null;
					expOp = null;
					compMod = NSComparisonPredicateModifier.NSDirectPredicateModifier;
					operOptions = 0;
					
					//
					// Check if we're waiting for a NOT
					//
					if (waitingForNot) {
						//
						// Build the NOT
						//
						curPred = NSCompoundPredicate.notPredicateWithSubpredicate(
							curPred);
						waitingForNot = false;
					}
					
					//
					// Set state
					//
					lastState = state;
					state = PREDICATE;

					break;
			}
			
			//
			// We haven't created a predicate on this pass, so just keep going.
			//
			if (curPred == null) {
				continue;
			}
			
			//
			// Add the predicate to the AND stack or the OR pred
			//
			if (insideAnd) {
				andStack.addObject(curPred);
			} else {
				orPred.subpredicates().addObject(curPred);
			}
			
			curPred = null;
		}
		
		//
		// Handle being inside an AND
		//
		if (insideAnd) {
			orPred.subpredicates().addObject(
				NSCompoundPredicate.andPredicateWithSubpredicates(
				(new NSArray()).initWithArrayCopyItems(andStack, false)));
			andStack.removeAllObjects();
		}
		
		//
		// Prepare return data
		//
		var subpreds:NSArray = orPred.subpredicates();
		
		//
		// We were unable to create a predicate with the provided data.
		//
		if (subpreds.count() == 0) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSGeneric,
				"Unable to create a predicate from the provided format string",
				NSDictionary.dictionaryWithObjectForKey(
					m_format, "ASPredicateFormat"));
			trace(e);
			throw e;
		}
		
		//
		// If we only have one subpredicate, we will return it and not the
		// enclosing OR.
		//
		if (subpreds.count() == 1) {
			pred = NSPredicate(subpreds.objectAtIndex(0));
		}
		
		return pred;
	}
	
	//******************************************************
	//*                  State handlers
	//******************************************************
	
	/**
	 * <p>Creates an expression based on <code>contents</code>.</p>
	 * 
	 * <p>If no expression matching the format of <code>contents</code> can be 
	 * found, and exception is thrown.</p>
	 */
	private function createExpression(token:ASPredicateToken):NSExpression {
		//
		// Arg check
		//
		if (token.type != ASPredicateToken.EXPRESSION) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"Expression token expected.",
				NSDictionary.dictionaryWithObjectForKey(
					token, "ASPredicateToken"));
			trace(e);
			throw e;
		}
		
		var exp:NSExpression;
				
		//
		// Identify the expression type and create the expression
		//
		if (token.isFunction) {
			exp = createFunctionExpression(token);
		}
		else if (isLiteralValue(token.contents)) {
			exp = createLiteralExpression(token.contents);
		}
		else if (isKeyPathExpression(token.contents)) {
			exp = createKeyPathExpression(token.contents);
		}
		else if (isPredicateVariable(token.contents)) {
			//! TODO Implement
		}
		else {
			//
			// Unrecognized expression type
			//
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSGeneric,
				"Could not identify expression type for " + token,
				null);
			trace(e);
			throw e;
		}
		
		return exp;
	}
	
	/**
	 * Creates and returns a literal expression based on <code>contents</code>.
	 */
	private function createLiteralExpression(contents:String):NSExpression {
		var exp:NSExpression;
		var const:Object;
		var evalObject:Boolean = false;
		var upper:String = contents.toUpperCase();
		
		if (upper == "NULL") {
			const = null;
		}
		else if (upper == "TRUE") {
			const = true;
		}
		else if (upper == "FALSE") {
			const = false;
		}
		else if (upper == "SELF") {
			evalObject = true;
		}
		else if (isStringValue(contents)) {
			const = contents.substring(1, contents.length - 1);
		}
		else if (isNumericValue(contents)) {
			const = parseFloat(contents);
		}
		
		if (evalObject) {
			exp = NSExpression.expressionForEvaluatedObject();
		} else {
			exp = NSExpression.expressionForConstantValue(const);
		}
		
		return exp;
	}
	
	/**
	 * Creates a key path expression based on <code>contents</code>.
	 */
	private function createKeyPathExpression(contents:String):NSExpression {
		return NSExpression.expressionForKeyPath(contents);
	}
	
	/**
	 * Creates a function expression based on <code>contents</code>.
	 */
	private function createFunctionExpression(token:ASPredicateToken):NSExpression {
		var arr:Array = token.subTokens.internalList(); // the argument tokens
		var len:Number = arr.length;
		var args:NSArray = new NSArray();
		
		for (var i:Number = 0; i < len; i++) {
			args.addObject(createExpression(arr[i]));
		}
		
		return NSExpression.expressionForFunctionArguments(token.contents, args);
	}
	
	/**
	 * Returns the number representing the options described in
	 * <code>optionsString</code>.
	 */	
	private function optionsForString(optionsString:String):Number {		
		var ret:Number = 0;
		optionsString = optionsString.toLowerCase();
		
		if (optionsString.indexOf("c") != -1) {
			ret |= NSComparisonPredicateOptions.NSCaseInsensitivePredicateOption.value;
		}
		
		if (optionsString.indexOf("d") != -1) {
			ret |= NSComparisonPredicateOptions.NSDiacriticInsensitivePredicateOption.value;
		}
		
		return ret;
	}
	
	//******************************************************
	//*                   Tokenizing
	//******************************************************
	
	/**
	 * Tokenizes the group <code>group</code> using the current format string
	 * and read index until a closing brace is hit.
	 */
	private function tokenizeGroupUntilClose(group:ASPredicateToken):Void {
		var curT:ASPredicateToken = null;
				
		for (m_idx = m_idx; m_idx < m_len; m_idx++) {
			
			var c:String = m_format.charAt(m_idx);
										
			//
			// Deal with individual character cases
			//
			switch (c) {
				case ",":
				case " ":
					if (!m_needsNewToken && curT != null) {
						group.subTokens.addObject(curT);
						curT = null;
					}
					
					m_needsNewToken = true;
					continue;
				
				case "(":
					if (!m_needsNewToken && curT != null) {
						group.subTokens.addObject(curT);
						curT = null;
					}
					
					var grp:ASPredicateToken = ASPredicateToken.groupToken();
					group.subTokens.addObject(grp);
					m_idx++;
					m_needsNewToken = true;
					tokenizeGroupUntilClose(grp);
					break;
					
				case ")":
					if (!m_needsNewToken && curT != null) {
						group.subTokens.addObject(curT);
						curT = null;
					}
					
					return;
			}
			
			//
			// Attempt to extract keyword
			//
			if (m_needsNewToken) {
				var t:ASPredicateToken = extractKeyword(m_format.substr(m_idx));
				t.position = m_idx;
				
				if (t != null) {
					group.subTokens.addObject(t);
					continue;
				}
				
				t = extractFunction(m_format.substr(m_idx));
								
				if (t != null) {
					group.subTokens.addObject(t);
					continue;
				}
			}
			
			//
			// Create a new expression token, or continue filling it as necessary
			//
			if (m_needsNewToken) {
				curT = ASPredicateToken.expressionTokenWithContents(c);
				curT.position = m_idx;
				
				m_needsNewToken = false;
			} else {
				curT.contents += c;
			}
		}
		
		//
		// Add the last token
		//
		if (curT != null) {
			group.subTokens.addObject(curT);
		}
	}
	
	/**
	 * <p>Extracts the keyword from the beginning of <code>format</code> if one
	 * exists, and returns an {@link ASPredicateToken} containing the 
	 * keyword.</p>
	 * 
	 * <p>If no keyword is found, <code>null</code> is returned.</p>
	 * 
	 * <p>If a keyword is found, {@link #m_idx} is updated to reflect the new 
	 * position.</p>
	 */
	private function extractKeyword(format:String):ASPredicateToken {
		var k:String;
		
		//! FIXME We need to check for a blank space
		
		format = format.toUpperCase(); // case insensitive
		
		k = NSPredicateOperatorType.startsWithKeyword(format);
				
		if (k != null) {
			m_idx += k.length;
			
			//
			// Check for options
			//
			var trimmed:String = format.substr(k.length);
			
			if (trimmed.charAt(0) == "[") {				
				var closeIdx:Number = trimmed.indexOf("]");
				var options:String = trimmed.substring(0, closeIdx + 1);
				k += options;
				m_idx += options.length;
			}
			
			return ASPredicateToken.keywordTokenWithContents(k);
		}
		
		k = NSCompoundPredicateType.startsWithKeyword(format);
		
		if (k != null) {
			m_idx += k.length;
			return ASPredicateToken.keywordTokenWithContents(k);
		}
		
		k = NSComparisonPredicateModifier.startsWithKeyword(format);
		
		if (k != null) {
			m_idx += k.length;
			
			return ASPredicateToken.keywordTokenWithContents(k);
		}
		
		return null;
	}
	
	/**
	 * Extracts and returns a function token, or returns <code>null</code> if
	 * none is found. <code>m_idx</code> is modified to reflect the new 
	 * position.
	 */
	private function extractFunction(format:String):ASPredicateToken {
		
		if (!NSExpression.beginsWithFunctionNameParen(
				format.split(" ").join(""))) { // remove spaces
			return null;
		}
		
		var idx:Number = format.indexOf("(");
		var name:String = format.substr(0, idx);
		m_idx = idx + 1;
				
		//
		// Get the subtokens
		//
		var argGrp:ASPredicateToken = ASPredicateToken.groupToken();
		m_needsNewToken = true;
		tokenizeGroupUntilClose(argGrp);

		return ASPredicateToken.functionTokenWithNameArguments(
			name, argGrp.subTokens);
	}
	
	//******************************************************
	//*                  Identification
	//******************************************************
	
	/**
	 * Returns <code>true</code> if <code>keyword</code> is a predicate 
	 * operator.
	 */
	private function isPredicateOperator(keyword:String):Boolean {
		return NSPredicateOperatorType.startsWithKeyword(keyword) != null;
	}
	
	/**
	 * Returns <code>true</code> if <code>keyword</code> is a comparison
	 * modifier.
	 */
	private function isComparisonModifier(keyword:String):Boolean {
		return NSComparisonPredicateModifier.constantForKeyword(keyword) != null;
	}
	
	/**
	 * Returns <code>true</code> if <code>keyword</code> is a compound type.
	 */
	private function isCompoundType(keyword:String):Boolean {
		return NSCompoundPredicateType.constantForKeyword(keyword) != null;
	}

	/**
	 * Returns <code>true</code> if <code>keyword</code> is an OR.
	 */	
	private function isOrType(keyword:String):Boolean {
		return keyword.toUpperCase() == "OR"
			|| keyword == "||";
	}
	
	/**
	 * Returns <code>true</code> if <code>keyword</code> is an AND.
	 */
	private function isAndType(keyword:String):Boolean {
		return keyword.toUpperCase() == "AND"
			|| keyword == "&&";
	}
	
	/**
	 * Returns <code>true</code> if <code>keyword</code> is a NOT.
	 */
	private function isNotType(keyword:String):Boolean {
		return keyword.toUpperCase() == "NOT";
	}
	
	/**
	 * Returns <code>true</code> is <code>contents</code> represents an
	 * expression.
	 */
	private function isExpression(contents:String):Boolean {
		return
			isIndexExpression(contents) 
			|| NSExpression.beginsWithFunctionName(contents) // function
			|| isKeyPathExpression(contents)
			|| isValueExpression(contents);
//!TODO  	|| "(" isExpression ")"
	}
	
	/**
	 * Returns true if <code>contents</code> represents a literal value or
	 * literal aggregate.
	 */
	private function isValueExpression(contents:String):Boolean {
		return isLiteralValue(contents) || isLiteralAggregate(contents);
	}
	
	/**
	 * Returns <code>true</code> if <code>contents</code> represents a 
	 * string value, numeric value, predicate argument, predicate variable,
	 * NULL, TRUE, FALSE or SELF.
	 */
	private function isLiteralValue(contents:String):Boolean {
		var upper:String = contents.toUpperCase();
		
		return isStringValue(contents)
			|| isNumericValue(contents)
			|| upper == "NULL"
			|| upper == "TRUE"
			|| upper == "FALSE"
			|| upper == "SELF";
	}
	
	/**
	 * Returns <code>true</code> if <code>contents</code> represents a string
	 * value.
	 */
	private function isStringValue(contents:String):Boolean {
		var c:String = contents.charAt(0);
		return (c == '"' || c == "'") 
			&& c == contents.charAt(contents.length - 1);
	}
	
	/**
	 * Returns <code>true</code> if <code>contents</code> represents a
	 * predicate argument.
	 */
	private function isPredicateArgument(contents:String):Boolean {
		if (contents.length != 2) {
			return false;
		}
		
		var c1:String = contents.charAt(0);
		var c2:String = contents.charAt(1);
		
		return c1 == "%" && (c2 == "@" || c2 == "%" || c2 == "K");
	}
	
	/**
	 * Returns <code>true</code> if <code>contents</code> represents a
	 * predicate variable.
	 */
	private function isPredicateVariable(contents:String):Boolean {
		return contents.charAt(0) == "$" && isIdentifier(contents.substr(1));
	}
	
	/**
	 * Returns <code>true</code> if <code>contents</code> represents a key
	 * path.
	 */
	private function isKeyPathExpression(contents:String):Boolean {
		var isKeyPath:Boolean = isIdentifier(contents)
			|| (contents.charAt(0) == "@" && isIdentifier(contents.substr(1)));
		
		if (isKeyPath) {
			return true;
		}
		
		//
		// Attempt multiple expression matching
		//
		var loc:Number = contents.indexOf(".");
		
		if (loc == -1) {
			return false;
		}
		
		return isExpression(contents.substring(0, loc)) 
			&& isExpression(contents.substring(loc + 1));
	}
	
	/**
	 * Returns <code>true</code> if <code>contents</code> represents a literal
	 * aggregate.
	 */
	private function isLiteralAggregate(contents:String):Boolean {
		//
		// A literal aggregate is an array definition (This is a note to myself)
		//
		//! TODO literal_aggregate ::= "{" [ expression [ "," expression ... ] ] "}"
		return false;
	}
	
	/**
	 * Returns <code>true</code> is <code>contents</code> represents an
	 * index expression.
	 */
	private function isIndexExpression(contents:String):Boolean {
//!TODO	index_expression ::= array_expression "[" integer_expression "]"
//		| dictionary_expression   "[" expression "]"
//		| aggregate_expression "[" FIRST "]"
//		| aggregate_expression "[" LAST "]"
//		| aggregate_expression "[" SIZE "]"

		return false;
	}
	
	/**
	 * Returns <code>true</code> is <code>contents</code> represents an
	 * aggregate expression.
	 */
	private function isAggregateExpression(contents:String):Boolean {
		return isArrayExpression(contents) || isDictionaryExpression(contents);
	}
	
	/**
	 * Returns <code>true</code> if <code>contents</code> represents an
	 * array expression.
	 */
	private function isArrayExpression(contents:String):Boolean {
		var f:String = contents.charAt(0);
		var l:String = contents.charAt(contents.length - 1);
		
		if (f != "{" || l != "}") {
			return false;
		}
		
		//
		// Evaluate each member in the array to determine whether is is
		// an expression
		//
		var exp:Array = contents.substring(1, contents.length).split(",");
		var len:Number = exp.length;
		
		for (var i:Number = 0; i < len; i++) {
			if (!isExpression(exp[i])) {
				return false;
			}
		}
		
		return true;
	}
	
	/**
	 * Returns <code>true</code> if <code>contents</code> represents an
	 * dictionary expression.
	 */
	private function isDictionaryExpression(contents:String):Boolean {
		//! TODO Figure out how this should be implemented
		return false;
	}
	
	/**
	 * Returns <code>true</code> if <code>contents</code> represents an
	 * numeric value.
	 */
	private function isNumericValue(contents:String):Boolean {
		var val:Number = parseFloat(contents);
		
		return !isNaN(val);
	}
	
	/**
	 * Returns <code>true</code> if <code>contents</code> represents an
	 * identifier.
	 */
	private function isIdentifier(contents:String):Boolean {
		return true;
	}
	
	//******************************************************
	//*            Validating the format string
	//******************************************************
	
	private function validateFormat(format:String):Boolean {
		return ASUtils.countIndicesOf(format, "(")
			== ASUtils.countIndicesOf(format, ")")
			&& ASUtils.countIndicesOf("[")
			== ASUtils.countIndicesOf("]");
	}
	
	//******************************************************
	//*            Accessible parsing methods
	//******************************************************
	
	/**
	 * <p>Parses the format string <code>format</code> into a predicate.</p>
	 * 
	 * <p>An {@link NSException} is raised if the format string is invalid.</p>
	 */
	public static function predicateForFormat(format:String):NSPredicate {
		if (null == g_instance) {
			g_instance = (new ASPredicateStringParser()).init();
		}
		
		return g_instance.parseFormat(format);
	}
}