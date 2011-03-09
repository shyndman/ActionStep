/* See LICENSE for copyright and terms of use */

import org.actionstep.NSPredicate;
import org.actionstep.constants.NSCompoundPredicateType;
import org.actionstep.NSArray;

/**
 * <p><code>NSCompoundPredicate</code> is a subclass of <code>NSPredicate</code> 
 * used to represent logical "gate" operations (AND/OR/NOT).</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSCompoundPredicate extends NSPredicate {
	
	private var m_compoundPredicateType:NSCompoundPredicateType;
	private var m_subpredicates:NSArray;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSCompoundPredicate</code> class.
	 */
	public function NSCompoundPredicate() {	
	}
	
	/**
	 * Initializes the predicate, setting its type to <code>type</code> and 
	 * subpredicates array to <code>subpredicates</code>.
	 */
	public function initWithTypeSubpredicates(type:NSCompoundPredicateType,
			subpredicates:NSArray):NSCompoundPredicate {		
		m_compoundPredicateType = type;
		m_subpredicates = subpredicates;
		
		return this;		
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the predicate.
	 */
	public function description():String {
		var ret:String = "NSCompoundPredicate(subpredicates=" + m_subpredicates 
			+ "," + "compoundPredicateType=";
		
		switch (m_compoundPredicateType) {
			case NSCompoundPredicateType.NSNotPredicateType:
				ret += "NOT";
				break;
				
			case NSCompoundPredicateType.NSAndPredicateType:
				ret += "AND";
				break;
				
			case NSCompoundPredicateType.NSOrPredicateType:
				ret += "OR";
				break;
		}
		
		return ret + ")";
	}
	
	/**
	 * Returns the predicate as it would appear in a formatting string.
	 */
	public function toFormatString():String {
		var ret:String = "";
		var arr:Array = subpredicates().internalList();
		var len:Number = arr.length;
		
		switch (m_compoundPredicateType) {
			case NSCompoundPredicateType.NSNotPredicateType:
				ret = "NOT " + NSPredicate(arr[0]).toFormatString();
				break;
				
			case NSCompoundPredicateType.NSAndPredicateType:
				for (var i:Number = 0; i < len; i++) {
					ret += NSPredicate(arr[i]).toFormatString();
					
					if (i + 1 < len) {
						ret += " AND ";
					}
				}
				break;
				
			case NSCompoundPredicateType.NSOrPredicateType:
				for (var i:Number = 0; i < len; i++) {
					ret += NSPredicate(arr[i]).toFormatString();
					
					if (i + 1 < len) {
						ret += " OR ";
					}
				}
				break;
		}
		
		return ret; // overridden in subclasses
	}
	
	//******************************************************
	//*   Getting information about a compound predicate
	//******************************************************
	
	/**
	 * Returns this predicate's predicate type.
	 */
	public function compoundPredicateType():NSCompoundPredicateType {
		return m_compoundPredicateType;
	}
	
	/**
	 * Returns the array of this predicates sub predicates.
	 */
	public function subpredicates():NSArray {
		return m_subpredicates;
	}

	//******************************************************
	//*                   Evaluating
	//******************************************************
	
	/**
	 * Returns <code>true</code> if the object satisfies the conditions of 
	 * the predicate.
	 */
	public function evaluateWithObject(object:Object):Boolean {
		//
		// Handle NOT functionality
		//
		if (compoundPredicateType() 
				== NSCompoundPredicateType.NSNotPredicateType) {
			var p:NSPredicate = NSPredicate(subpredicates().objectAtIndex(0));
			return !p.evaluateWithObject(object);
		}
		
		//
		// Handle AND and OR functionality
		//
		var preds:Array = subpredicates().internalList();
		var len:Number = preds.length;
		
		//
		// true if first true match returns, false if first false match returns
		//
		var returnBehaviour:Boolean =  
			compoundPredicateType() == NSCompoundPredicateType.NSOrPredicateType;
		
		for (var i:Number = 0; i < len; i++) {
			var p:NSPredicate = NSPredicate(preds[i]);
			var res:Boolean = p.evaluateWithObject(object);
			
			if (res && returnBehaviour) {
				return true;
			}
			else if (!res && !returnBehaviour) {
				return false;
			}
		}
		
		return !returnBehaviour; 
	}
	
	//******************************************************
	//*                   Constructors
	//******************************************************
	
	/**
	 * Returns a new predicate formed by AND-ing the predicates specified by 
	 * <code>subpredicates</code>.
	 */
	public static function andPredicateWithSubpredicates(subpredicates:NSArray)
			:NSCompoundPredicate {
		return (new NSCompoundPredicate()).initWithTypeSubpredicates(
			NSCompoundPredicateType.NSAndPredicateType, subpredicates);		
	}
	
	/**
	 * Returns a new predicate formed by NOT-ing the predicate specified by 
	 * <code>subpredicate</code>.
	 */
	public static function notPredicateWithSubpredicate(
			subpredicate:NSPredicate):NSCompoundPredicate {
		return (new NSCompoundPredicate()).initWithTypeSubpredicates(
			NSCompoundPredicateType.NSNotPredicateType, 
			NSArray.arrayWithObject(subpredicate));		
	}
	
	/**
	 * Returns a new predicate formed by OR-ing the predicates specified by 
	 * <code>subpredicates</code>.
	 */
	public static function orPredicateWithSubpredicates(subpredicates:NSArray)
			:NSCompoundPredicate {
		return (new NSCompoundPredicate()).initWithTypeSubpredicates(
			NSCompoundPredicateType.NSOrPredicateType, subpredicates);		
	}
}
