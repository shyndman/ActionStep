/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;
import org.actionstep.NSArray;

/**
 * <p>Represents a distinct, unordered collection of objects.</p>
 * 
 * <p>This class is combination of the <code>NSSet</code> and 
 * <code>NSMutableSet</code> classes from the Cocoa spec.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSSet extends NSObject {
	
	private var m_list:NSArray;
	
	//******************************************************
	//*                    Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>NSSet</code> class.
	 */
	public function NSSet() {
		m_list = new NSArray();
	}
	
	/**
	 * Initializes and returns the set.
	 */
	public function init():NSSet {
		
		return this;
	}
	
	/**
	 * Initializes and returns a set containing the elements found in
	 * <code>anArray</code>.
	 */
	public function initWithArray(anArray:Array):NSSet {
		var len:Number = anArray.length;
		
		for (var i:Number = 0; i < len; i++) {
			if (!m_list.containsObject(anArray[i])) {
				m_list.addObject(anArray[i]);
			}
		}
		
		return this;
	}
	
	/**
	 * Initializes and returns a set containing the elements found in
	 * <code>anArray</code>.
	 */
	public function initWithNSArray(anArray:NSArray):NSSet {
		return initWithArray(anArray.internalList());
	}
	
	//******************************************************
	//*                 Describing a set
	//******************************************************
	
	/**
	 * Returns a string representation of the <code>NSSet</code> instance.
	 */
	public function description():String {
		return "NSSet(allObjects=" + m_list.toString() + ")";
	}
	
	//******************************************************
	//*                  Counting entries
	//******************************************************
	
	/**
	 * Returns the number of items contained by this set.
	 */
	public function count():Number {
		return m_list.count();
	}
	
	//******************************************************
	//*                Accessing the members
	//******************************************************
	
	/**
	 * Returns an array containing all the set's data.
	 */
	public function allObjects():NSArray {
		return (new NSArray()).initWithArrayCopyItems(m_list, false);
	}
	
	/**
	 * <p>Returns one of the objects in the receiver, or <code>null</code> if the 
	 * receiver contains no objects.</p>
	 * 
	 * <p>This object will be chosen at random.</p>
	 */
	public function anyObject():Object {
		if (m_list.count() == 0) {
			return null;
		}
		
		return m_list.objectAtIndex(random(m_list.count()));
	}
	
	/**
	 * Returns <code>true</code> if the set contains <code>anObject</code>.
	 */
	public function containsObject(anObject:Object):Boolean {
		return m_list.containsObject(anObject);
	}
	
	/**
	 * Calls the method named <code>selector</code> in each object contained
	 * by the set.
	 */
	public function makeObjectsPerformSelector(selector:String):Void {
		m_list.makeObjectsPerformSelector(selector);
	}
	
	/**
	 * Calls the method named <code>selector</code> in each object contained
	 * by the set, passing <code>anObject</code> as the argument.
	 */
	public function makeObjectsPerformSelectorWithObject(selector:String,
			anObject:Object):Void {
		m_list.makeObjectsPerformSelectorWithObject(selector, anObject);		
	}
	
	//******************************************************
	//*                   Comparing sets
	//******************************************************
	
	/**
	 * <p>Returns <code>true</code> if <code>otherSet</code> is a subset of this
	 * one.</p>
	 * 
	 * <p>A subset means that all the elements in <code>otherSet</code> are 
	 * contained in this set, but not vice-versa.</p>
	 */
	public function isSubsetOfSet(otherSet:NSSet):Boolean {
		var arr:Array = otherSet.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			if (!m_list.containsObject(arr[i])) {
				return false;
			}
		}
		
		return true;
	}
	
	/**
	 * Returns <code>true</code> if at least one object in this set is also 
	 * present in <code>otherSet</code>, <code>false</code> otherwise.
	 */
	public function intersectsSet(otherSet:NSSet):Boolean {
		var arr:Array = otherSet.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			if (m_list.containsObject(arr[i])) {
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Compares this set to <code>otherSet</code>.
	 */
	public function isEqualToSet(otherSet:NSSet):Boolean {
		if (otherSet.count() != this.count()) {
			return false;
		}
		
		var arr:Array = otherSet.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			if (!containsObject(arr[i])) {
				return false;
			}
		}
		
		return true;
	}
	
	/**
	 * Overridden to call <code>#isEqualToSet</code>.
	 */
	public function isEqual(anObject:Object):Boolean {
		if (!(anObject instanceof NSSet)) {
			return false;
		}
		
		return isEqualToSet(NSSet(anObject));
	}
	 
	//******************************************************
	//*             Adding and removing entries
	//******************************************************
	
	/**
	 * Adds the specified object to the set if it is not already a member.
	 */
	public function addObject(anObject:Object):Void {
		if (containsObject(anObject)) {
			return;
		}
		
		m_list.addObject(anObject);
	}
	
	/**
	 * Removes <code>anObject</code> from the set.
	 */
	public function removeObject(anObject:Object):Void {
		m_list.removeObject(anObject);
	}
	
	/**
	 * Empties the set of all of its members.
	 */
	public function removeAllObjects():Void {
		m_list.removeAllObjects();
	}
	
	/**
	 * Adds each object contained in <code>anArray</code> to the set, if that 
	 * object is not already a member.
	 */
	public function addObjectsFromArray(anArray:NSArray):Void {
		var arr:Array = anArray.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			addObject(arr[i]);
		}
	} 
	
	//******************************************************
	//*             Combining and recombining sets
	//******************************************************
	
	/**
	 * Adds each object contained in <code>otherSet</code> to the set, if that 
	 * object is not already a member.
	 */
	public function unionSet(otherSet:NSSet):Void {
		addObjectsFromArray(otherSet.allObjects());
	}
	
	/**
	 * Removes from the set each object contained in <code>otherSet</code> that 
	 * is also present in the receiver.
	 */
	public function minusSet(otherSet:NSSet):Void {
		var arr:Array = otherSet.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			removeObject(arr[i]);
		}
	}
	
	/**
	 * Removes from the set each object that isn’t a member of 
	 * <code>otherSet</code>.
	 */
	public function intersectSet(otherSet:NSSet):Void {
		var objs:NSArray = otherSet.allObjects();
		var arr:Array = m_list.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			if (!objs.containsObject(arr[i])) {
				removeObject(arr[i]);
			}
		}
	}
	
	/**
	 * Empties the set, then adds each object contained in <code>otherSet</code>
	 * to the receiver.
	 */
	public function setSet(otherSet:NSSet):Void {
		removeAllObjects();
		addObjectsFromArray(otherSet.allObjects());
	}
	
	//******************************************************															 
	//*              Getting the internal list
	//******************************************************
	
	/**
	 * <p>Returns the internal array representation of the set.</p>
	 * 
	 * <p>For internal use only.</p>
	 */
	public function internalList():Array {
		return m_list.internalList();
	}
	
	//******************************************************
	//*                     Creation
	//******************************************************
	
	/**
	 * Creates and returns an empty set.
	 */
	public static function emptySet():NSSet {
		return (new NSSet()).init();
	}
	
	/**
	 * Creates and returns a set containing a uniqued collection of those 
	 * objects contained within the array <code>anArray</code>.
	 */
	public static function setWithArray(anArray:Array):NSSet {
		return (new NSSet()).initWithArray(anArray);
	}
	
	/**
	 * Creates and returns a set containing a uniqued collection of those 
	 * objects contained within the array <code>anArray</code>.
	 */
	public static function setWithNSArray(anArray:NSArray):NSSet {
		return (new NSSet()).initWithNSArray(anArray);
	}
}