/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.binding.NSKeyValueCoding;
import org.actionstep.constants.NSComparisonResult;
import org.actionstep.NSCopying;
import org.actionstep.NSEnumerator;
import org.actionstep.NSException;
import org.actionstep.NSIndexSet;
import org.actionstep.NSObject;
import org.actionstep.NSPredicate;
import org.actionstep.NSRange;
import org.actionstep.NSSortDescriptor;

/**
 * <p>Represents an array of objects.</p>
 *
 * <p>This class is a combination of both <code>NSArray</code> and
 * <code>NSMutableArray</code> classes described in the Cocoa docs.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSArray extends NSObject implements NSCopying
{
	/** The internal list */
	private var m_list:Array;

	//******************************************************
	//*                    Construction
	//******************************************************

	/**
	 * Creates a new instance of <code>NSArray</code>.
	 */
	public function NSArray() {
		m_list = new Array();
	}

	/**
	 * Initializes a newly created array.
	 */
	public function init():NSArray {
		return this;
	}

	/**
	 * Initializes a newly allocated array, giving it enough memory to hold
	 * <code>numItems</code> objects.
	 */
	public function initWithCapacity(numItems:Number):NSArray {
		//
		// Throw an exception if out of range.
		//
		if (numItems < 0)
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSInvalidArgumentException",
				"numItems cannot be negative.",
				null);
			trace(e);
			throw e;
		}

		m_list = new Array(numItems);

		return this;
	}

	/**
	 * Initializes a newly allocated array by placing in it the objects
	 * contained in <code>anArray</code>.
	 */
	public function initWithArray(anArray:Array):NSArray {
		if (anArray == null) {
			anArray = [];
		}
		
		m_list = anArray.slice(0, anArray.length);
		return this;
	}

	/**
	 * Initializes a newly allocated array by placing in it the objects
	 * contained in <code>anArray</code>.
	 */
	public function initWithNSArray(anArray:NSArray):NSArray {
		return initWithArray(anArray.m_list);
	}

	/**
	 * <p>Initializes a newly allocated array using <code>anArray</code> as the
	 * source of data objects for the array.</p>
	 *
	 * <p>If <code>flag</code> is <code>false</code>, each object in
	 * <code>anArray</code>, objects are added to this array as is. If
	 * <code>flag</code> is <code>true</code>, each object in
	 * <code>anArray</code> receives a {@link #copyWithZone} message to
	 * create a copy of the object.</p>
	 */
	public function initWithArrayCopyItems(anArray:NSArray, flag:Boolean):NSArray {
		if (!flag) {
			return initWithNSArray(anArray);
		}

		//
		// Copy
		//
		var arr:Array = anArray.internalList();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			var val:Object = arr[i];

			if (ASUtils.respondsToSelector(val, "copyWithZone")) {
				val = val.copyWithZone();
			}
			else if (ASUtils.respondsToSelector(val, "memberwiseClone")) {
				val = val.memberwiseClone();
			}

			this.addObject(val);
		}

		return this;
	}

	/**
	 * Initializes a newly allocated array by placing the objects in the
	 * argument list in it.
	 */
	public function initWithObjects(/* ... */):NSArray {
		return initWithArray(arguments);
	}

	/**
	 * Initializes a newly allocated array by placing <code>count</code> objects
	 * from the <code>objects</code> array in it.
	 */
	public function initWithObjectsCount(objects:NSArray, count:Number)
			:NSArray {
		var rng:NSRange = new NSRange(0, count);
		return initWithNSArray(objects.subarrayWithRange(rng));
	}

	//******************************************************
	//*                Describing the object
	//******************************************************

	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String {
    	var ret:String = "NSArray(";
    	var len:Number = m_list.length;

    	//
    	// Append the descriptions of all objects save the last.
    	//
    	for (var i:Number = 0; i < len - 1; i++)
    		ret += m_list[i].toString() + ",";

    	if (len > 0)
    		ret += m_list[len - 1].toString(); // no comma

    	return ret + ")";
	}

	//******************************************************
	//*              Getting the internal list
	//******************************************************

	/**
	 * Returns the internal array. For super quick operations only.
	 */
	public function internalList():Array {
		return m_list;
	}

	//******************************************************
	//*                Querying the array
	//******************************************************

	/**
	 * <p>Returns <code>true</code> if <code>anObject</code> is present in the
	 * array.</p>
	 *
	 * <p>This method determines whether an object is present in the array by
	 * sending an {@link #isEqual} message to each of the array’s objects
	 * (and passing <code>anObject</code> as the parameter to each
	 * {@link #isEqual} message).</p>
	 */
	public function containsObject(anObject:Object):Boolean	{
		return indexOfObject(anObject) != NSObject.NSNotFound;
	}

	/**
	 * Returns the number of objects currently in the array.
	 */
	public function count():Number {
		return m_list.length;
	}

	/**
	 * Searches the receiver for <code>anObject</code> and returns the lowest 
	 * index whose corresponding array value is equal to anObject. Objects are 
	 * considered equal if {@link #isEqual} returns <code>true</code>. If none 
	 * of the objects in the receiver is equal to <code>anObject</code>, 
	 * {@link #indexOfObject} returns {@link #NSNotFound}.
	 */
	public function indexOfObject(anObject:Object):Number {
		return indexOfObjectInRange(anObject, new NSRange(0, m_list.length));
	}

	/**
	 * Searches the specified range within the receiver for 
	 * <code>anObject</code> and returns the lowest index whose corresponding 
	 * array value is equal to <code>anObject</code>. Objects are considered 
	 * equal if {@link #isEqual} returns <code>true</code>. If none of the
	 * objects in the specified range is equal to <code>anObject</code>, returns 
	 * {@link #NSNotFound}.
	 */
	public function indexOfObjectInRange(anObject:Object, range:NSRange):Number{
		var startIdx:Number = range.location;
		var endIdx:Number = range.location + range.length;

		for (var i:Number = startIdx; i < endIdx; i++)	{
			if (ASUtils.respondsToSelector(m_list[i], "isEqual")) {
				if (m_list[i].isEqual(anObject))
					return i;
			} else {
				if (m_list[i] == anObject)
					return i;
			}
		}

		return NSObject.NSNotFound;
	}

	/**
	 * <p>Searches the receiver for <code>anObject</code> and returns the index 
	 * of the first equal object. Objects are considered equal when comparer 
	 * returns <code>true</code>.</p>
	 *
	 * <p>The comparer function must return <code>true</code> if equal, 
	 * <code>false</code> if inequal, and take 2 objects as arguments 
	 * (the objects to compare).</p>
	 */
	public function indexOfObjectWithCompareFunction(anObject:Object,
			comparer:Function):Number {
		return indexOfObjectWithCompareFunctionInRange(anObject, comparer,
			new NSRange(0, m_list.length));
	}

	/**
	 * <p>Searches the specified range for <code>anObject</code> and returns the 
	 * index of the first equal object. Objects are considered equal when 
	 * comparer returns <code>true</code>.</p>
	 *
	 * <p>The comparer function must return <code>true</code> if equal, 
	 * <code>false</code> if inequal, and take 2 objects as arguments (the 
	 * objects to compare).</p>
	 */
	public function indexOfObjectWithCompareFunctionInRange(anObject:Object,
			comparer:Function, range:NSRange):Number {
		var startIdx:Number = range.location;
		var endIdx:Number = range.location + range.length;

		for (var i:Number = startIdx; i < endIdx; i++)	{
			if (comparer(m_list[i], anObject))
				return i;
		}

		return NSObject.NSNotFound;
	}

	/**
	 * Searches the receiver for <code>anObject</code> (testing for equality by 
	 * comparing object addresses) and returns the lowest index whose 
	 * corresponding array value is identical to <code>anObject</code>. If none 
	 * of the objects in the receiver is identical to <code>anObject</code>, 
	 * {@link #indexOfObjectIdenticalTo} returns {@link #NSNotFound}.
	 */
	public function indexOfObjectIdenticalTo(anObject:Object):Number {
		return indexOfObjectIdenticalToInRange(anObject, new NSRange(0,
			m_list.length));
	}

	/**
	 * Searches the specified range within the receiver for 
	 * <code>anObject</code> (testing for equality by comparing object 
	 * addresses) and returns the lowest index whose corresponding array value 
	 * is identical to <code>anObject</code>. If none of the objects in the 
	 * specified range is identical to <code>anObject</code>, 
	 * {@link #NSNotFound} is returned.
	 */
	public function indexOfObjectIdenticalToInRange(anObject:Object,
			range:NSRange):Number {
		var startIdx:Number = range.location;
		var endIdx:Number = range.location + range.length;

		for (var i:Number = startIdx; i < endIdx; i++) {
			if (m_list[i] == anObject)
				return i;
		}

		return NSObject.NSNotFound;
	}

	/**
	 * Returns the last object in the array, or <code>null</code> if the array is
	 * empty.
	 */
	public function lastObject():Object	{
		return m_list.length == 0 ? null : m_list[m_list.length - 1];
	}


	/**
	 * Returns the object located at <code>index</code>. If <code>index</code> 
	 * is beyond the end of the array (that is, if index is greater than or 
	 * equal to the value returned by {@link #count}), <code>null</code> is 
	 * returned.
	 */
	public function objectAtIndex(index:Number):Object {
		//
		// Check if the index is in range.
		//
		if (index < 0 || index >= m_list.length)
			return null;

		return m_list[index];
	}

	/**
	 * Returns an enumerator object that lets you access each object
	 * in the receiver, in order, starting with the element at index 
	 * <code>0</code>.
	 * 
	 * @see NSEnumerator#nextObject
	 */
	public function objectEnumerator(pref:Object):NSEnumerator {
		return new NSEnumerator(m_list, false, pref);
	}

	/**
	 * Returns an enumerator object that lets you access each object in the
	 * receiver, in order, from the element at the highest index down to the
	 * element at index <code>0</code>. Your code shouldn’t modify the array 
	 * during enumeration.
	 *
	 * @see NSEnumerator#nextObject
	 */
	public function reverseObjectEnumerator():NSEnumerator {
		return new NSEnumerator(m_list, true);
	}

	//******************************************************
	//*            Sending messages to elements
	//******************************************************

	/**
	 * Sends the <code>aSelector</code> message to each object in the array,
	 * starting with the first object and continuing through the array to the
	 * last object. The <code>aSelector</code> method must not take any
	 * arguments. It shouldn’t have the side effect of modifying the receiving
	 * array. This method raises an {@link NSException} if
	 * <code>aSelector</code> is <code>null</code>.
	*/
	public function makeObjectsPerformSelector(aSelector:String):Void {
		if (aSelector == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"aSelector cannot be null",
				null);
			trace(e);
			throw e;
		}

		var arr:Array = m_list;
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			var obj:Object = arr[i];
			obj[aSelector]();
		}
	}

	/**
	 * Sends the <code>aSelector</code> message to each object in the array,
	 * starting with the first object and continuing through the array to the
	 * last object, passing <code>anObject</code> as the single argument.
	 * The <code>aSelector</code> method must take a single argument.
	 * It shouldn’t have the side effect of modifying the receiving
	 * array. This method raises an {@link NSException} if 
	 * <code>aSelector</code> is <code>null</code>.
	*/
	public function makeObjectsPerformSelectorWithObject(aSelector:String,
			anObject:Object):Void {
		if (aSelector == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"aSelector cannot be null",
				null);
			trace(e);
			throw e;
		}

		var arr:Array = m_list;
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			var obj:Object = arr[i];
			obj[aSelector](anObject);
		}
	}

	//******************************************************
	//*                 Comparing arrays
	//******************************************************

	/**
	 * Returns the first object contained in the receiver that’s equal to an
	 * object in <code>otherArray</code>. If no such object is found, this 
	 * method returns <code>null</code>. This method uses {@link #isEqual} to 
	 * check for object equality.
	 */
	public function firstObjectCommonWithArray(otherArray:NSArray):Object {
		var idx:Number;
		var len:Number = otherArray.m_list.length;

		//
		// Cycle through passed array, searching for each object in turn.
		//
		for (var i:Number = 0; i < len; i++) {
			if ((idx = indexOfObject(otherArray.m_list[i]))
					!= NSObject.NSNotFound)
				return m_list[idx];
		}

		return null; // not found
	}

	/**
	 * <p>Compares the receiving array to <code>otherArray</code>. If the contents 
	 * of <code>otherArray</code> are equal to the contents of the receiver, 
	 * this method returns <code>true</code>. If not, it returns 
	 * <code>false</code>.</p>
     *
     * <p>Two arrays have equal contents if they each hold the same number
     * of objects and objects at a given index in each array satisfy the
     * {@link #isEqual} test, or provided there is no isEqual.</p>
	 */
	public function isEqualToArray(otherArray:NSArray):Boolean {
		//
		// Test lengths first, as it's speedy.
		//
		if (m_list.length != otherArray.m_list.length)
			return false;

		//
		// Test each of the elements against eachother in turn.
		//
		var len:Number = m_list.length;

		for (var i:Number = 0; i < len; i++) {
			if (m_list[i].isEqual != null && !m_list[i].isEqual(otherArray.m_list[i])
					|| m_list[i] != otherArray.m_list[i]) {
				return false;
			}
		}

		return true;
	}

	/**
	 * Overridden to call {@link #isEqualToArray}.
	 */
	public function isEqual(otherObject:Object):Boolean {
		if (!(otherObject instanceof NSArray)) {
			return false;
		}

		return isEqualToArray(NSArray(otherObject));
	}

	//******************************************************
	//*               Deriving new arrays
	//******************************************************

	/**
	 * <p>Returns a new array that is a copy of this array (but without copied
	 * contents) with <code>anObject</code> added to the end.</p>
	 *
	 * <p>If <code>anObject</code> is <code>null</code>, an {@link NSException} is 
	 * raised.</p>
	 */
	public function arrayByAddingObject(anObject:Object):NSArray {
		if (anObject == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"anObject cannot be null",
				null);
			trace(e);
			throw e;
		}

		var arr:NSArray = (new NSArray()).initWithArrayCopyItems(this, false);
		arr.addObject(anObject);

		return arr;
	}

	/**
	 * Returns a new array that is a copy of this array with the objects
	 * contained in <code>otherArray</code> added to the end.
	 */
	public function arrayByAddingObjectsFromArray(otherArray:NSArray):NSArray {
		var newArray:Array = m_list.concat(otherArray.m_list);
		return NSArray.arrayWithArray(newArray);
	}

	/**
	 * Evaluates the <code>predicate</code> against this array’s content and
	 * returns a new array containing the objects that match.
	 */
	public function filteredArrayUsingPredicate(predicate:NSPredicate):NSArray {
		var arr:Array = new Array();
		var len:Number = m_list.length;

		for (var i:Number = 0; i < len; i++) {
			if (predicate.evaluateWithObject(m_list[i])) {
				arr.push(m_list[i]);
			}
		}

		return NSArray.arrayWithArray(arr);
	}

	/**
	 * <p>Returns a new array containing this array’s elements that fall within the
	 * limits specified by <code>range</code>.</p>
	 *
	 * <p>If <code>range</code> isn’t within this array’s range of elements, an
	 * {@link NSException} is raised.</p>
	 */
	public function subarrayWithRange(range:NSRange):NSArray {
		var upperBound:Number = m_list.length;
		var start:Number = range.location;
		var end:Number = range.location + range.length;

		if (end > upperBound || start < 0) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSRange,
				range + " is outside this arrays range of elements.",
				null);
			trace(e);
			throw e;
		}

		return NSArray.arrayWithArray(
			m_list.slice(range.location, range.location + range.length));
	}

	//******************************************************
	//*                 Sorting arrays
	//******************************************************

	//! TODO - (NSArray *)sortedArrayUsingFunction:(int (*)(id, id, void *))comparator context:(void *)context
	//! TODO - (NSArray *)sortedArrayUsingFunction:(int (*)(id, id, void *))comparator context:(void *)context hint:(NSData *)hint/
	//! TODO - (NSArray *)sortedArrayUsingDescriptors:(NSArray *)sortDescriptors
	//! TODO - (NSArray *)sortedArrayUsingSelector:(SEL)comparator

	//******************************************************
	//*             Adding and replacing objects
	//******************************************************

	/**
	 * <p>Adds an <code>anObject</code> to the end of the collection.</p>
	 *
	 * <p>This operation should not be performed while the collection is being
	 * enumerated.</p>
	 */
	public function addObject(anObject:Object):Void {
		insertObjectAtIndex(anObject, m_list.length);
	}

	/**
	 * Adds the contents of <code>array</code> to this array.
	 */
	public function addObjectsFromArray(array:NSArray):Void {
		addObjectsFromList(array.internalList());
	}

	/**
	 * Adds all objects from the native array <code>list</code> onto the end
	 * of this array.
	 */
	public function addObjectsFromList(list:Array):Void {
		m_list = m_list.concat(list);
	}

	/**
	 * <p>Inserts <code>anObject</code> into the collection at index 
	 * <code>index</code>.</p>
	 *
	 * <p>An error is thrown if the index is greater than the length of the list
	 * or is less than zero.</p>
	 *
	 * <p>This operation should not be performed while the collection is being
	 * enumerated.</p>
	 */
	public function insertObjectAtIndex(anObject:Object, index:Number):Void {
		//
		// Check for index validity.
		//
		if (index > m_list.length || index < 0) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"InvalidArgumentException",
				"The index " + index + " is invalid.",
				null);
			trace(e);
			throw e;
		}

		//
		// Insert the object.
		//
		if (index == m_list.length) {
			m_list.push(anObject);
		}
		else
			m_list.splice(index, 0, anObject);
	}

	/**
	 * Inserts the objects in <code>objects</code> into the receiver at the
	 * indexes specified by <code>indexes</code>.
	 */
	public function insertObjectAtIndexes(objects:NSArray, indexes:NSIndexSet)
			:Void {
		//! TODO implement
	}

	/**
	 * Replaces the object at <code>index</code> index with <code>anObject</code>.
	 */
	public function replaceObjectAtIndexWithObject(index:Number,
			anObject:Object):Void {
		m_list[index] = anObject;
	}

	//! TODO replaceObjectsAtIndexes:withObjects:
	//! TODO replaceObjectsInRange:withObjectsFromArray:range:
	//! TODO replaceObjectsInRange:withObjectsFromArray:

	/**
	 * Sets the contents of this array to be the contents of
	 * <code>otherArray</code>.
	 */
	public function setArray(otherArray:NSArray):Void {
		initWithNSArray(otherArray); //! Not sure if this is okay
	}

	//******************************************************
	//*                 Removing objects
	//******************************************************

	/**
	 * Evaluates the predicate against this array’s content and leaves only
	 * objects that match.
	 */
	public function filterUsingPredicate(predicate:NSPredicate):Void {
		var arr:NSArray = filteredArrayUsingPredicate(predicate);
		setArray(arr);
	}

	/**
	 * <p>Clears the collection.</p>
	 *
	 * <p>This operation should not be performed while the collection is being
	 * enumerated.</p>
	 */
	public function removeAllObjects():Void {
		m_list = new Array();
	}

	/**
	 * <p>Removes the last object in the collection.</p>
	 *
	 * <p>An exception is raised if the collection is empty.</p>
	 */
	public function removeLastObject():Void	{
		if (m_list.length == 0)
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"RangeException",
				"NSArray::removeLastObject - This method cannot be called " +
				"when the collection is empty.",
				null);
			trace(e);
			throw e;
		}

		//! this could be faster with splice, but is better practice this way
		removeObjectAtIndex(m_list.length - 1);
	}

	/**
	 * Removes the object <code>anObject</code> from the collection.
	 */
	public function removeObject(anObject:Object):Void {
		removeObjectInRange(anObject, new NSRange(0, m_list.length));
	}

	/**
	 * Removes all occurrences of <code>anObject</code> within the specified
	 * range, <code>aRange</code>.
	 */
	public function removeObjectInRange(anObject:Object, aRange:NSRange):Void {
		var idx:Number;

		while ((idx = indexOfObjectInRange(anObject, aRange))
				!= NSObject.NSNotFound) {
			m_list.splice(idx, 1);
			aRange.location = idx;
			aRange.length = m_list.length - idx;
		}
	}

	/**
	 * Removes the object at the index <code>index</code> from the collection.
	 */
	public function removeObjectAtIndex(index:Number):Void {
		//
		// Check if the index is in range.
		//
		if (index < 0 || index >= m_list.length) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"RangeException",
				"NSArray::removeObjectAtIndex - The index " + index +
				" is out of range.",
				null);
			trace(e);
			throw e;
		}

		m_list.splice(index, 1); // Remove the object.
	}

	/**
	 * Removes the objects at the specified <code>indexes</code> from the 
	 * receiver.
	 */
	public function removeObjectsAtIndexes(indexes:NSIndexSet):Void {
		removeObjectsFromIndicesNumIndices(indexes, indexes.count());
	}

	/**
	 * Removes the object <code>anObject</code> from the collection.
	 */
	public function removeObjectIdenticalTo(anObject:Object):Void {
		removeObjectIdenticalToInRange(anObject, new NSRange(0, m_list.length));
	}

	/**
	 * Removes all occurrences of <code>anObject</code> within the specified
	 * range, <code>aRange</code>.
	 */
	public function removeObjectIdenticalToInRange(anObject:Object,
			aRange:NSRange):Void {
		var idx:Number;

		while ((idx = indexOfObjectIdenticalToInRange(anObject, aRange))
				!= NSObject.NSNotFound) {
			m_list.splice(idx, 1);
			aRange.length--;
		}
	}

	/**
	 * <p>Removes the specified number of objects from the receiver, begininning
	 * at the specified index.</p>
	 * 
	 * <p>Uses {@link #removeObjectAtIndex} internally.</p>
	 */
	public function removeObjectsFromIndicesNumIndices(indices:NSIndexSet,
			count:Number):Void {
		var indexes:NSArray = indices.getIndexes();
		var it:NSEnumerator = indexes.objectEnumerator();
		var idx:Number;
		var offset:Number = 0;
		
		while (null != (idx = Number(it.nextObject())) && count-- > 0) {
			removeObjectAtIndex(idx - offset++);
		}
	}

	/**
	 * This method is similar to {@link #removeObject}, but allows you to
	 * efficiently remove large sets of objects with a single operation.
	 */
	public function removeObjectsInArray(otherArray:NSArray):Void {
		var arr:Array = otherArray.internalList();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			removeObject(arr[i]);
		}
	}

	/**
	 * <p>Removes all objects located in <code>range</code>.</p>
	 * 
	 * <p>If <code>range</code> is out of bounds, an {@link NSException} is
	 * raised.</p>
	 */
	public function removeObjectsInRange(range:NSRange):Void {
		var upperBound:Number = m_list.length;
		var start:Number = range.location;
		var end:Number = range.location + range.length;

		if (end > upperBound || start < 0) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSRange,
				range + " is outside this arrays range of elements.",
				null);
			trace(e);
			throw e;
		}

		//
		// Must remove using removeObjectAtIndex, since specs says so
		// do it from the back, since indices in front won't change
		//
		var i:Number = range.length;
		while(i--) {
			removeObjectAtIndex(i+start);
		}
		//
		// Which is actually the same as
		// m_list.splice(start, range.length);
	}

	//******************************************************
	//*               Rearranging objects
	//******************************************************

	/**
	 * Sorts this array as specified by <code>sortDescriptors</code>.
	 */
	public function sortUsingDescriptors(sortDescriptors:NSArray):Void {		
		//
		// Can't sort if there are no descriptors.
		//
		if (sortDescriptors.count() == 0 || m_list.length == 0 || m_list.length == 1) {
			return;
		}

		NSArray.quickSort(m_list, 0, m_list.length - 1, sortDescriptors);
	}

	/**
	 * <p>Sorts the collection in ascending order using the comparison function
	 * <code>compare</code>. The comparison method prototype should be as 
	 * follows:</p>
	 * <p>
	 * <code>
	 * compare(object1:Object, object2:Object[, context:Object]):{@link NSComparisonResult}
	 * </code>
	 * </p>
	 *
	 * <p>The optional context argument is that specified by 
	 * <code>context</code>, and can contain additional information relating to 
	 * the sort.</p>
	 */
	public function sortUsingFunctionContext(compare:Function,
			context:Object):Void {
		NSArray.quickSort(m_list, 0, m_list.length - 1, compare, context);
	}

	/**
	 * <p>Sorts the array using the comparison method specified by 
	 * <code>comparator</code>.</p>
	 *
	 * <p>The method named <code>comparator</code> is called on each object in 
	 * the array with the single argument of another object in the array. It 
	 * should return {@link NSComparisonResult#NSOrderedAscending} if the 
	 * receiver is smaller than the argument, 
	 * {@link NSComparisonResult#NSOrderedEqual} if they are equal, and
	 * {@link NSComparisonResult#NSOrderedDescending} if the receiver is less 
	 * than the argument.</p>
	 */
	public function sortUsingSelector(comparator:String):Void {
		NSArray.quickSort(m_list, 0, m_list.length - 1, comparator);
	}

	//******************************************************
	//*                 Public Methods
	//******************************************************
	
	/**
	 * Uses {@link NSKeyValueCoding#setValueWithObjectForKeyPath} to set the 
	 * <code>keyPath</code> property of every element in the collection to 
	 * <code>value</code>. 
	 */
	public function setValueForKeyPath(keyPath:String, value:Object):Void {
		var len:Number = m_list.length; // faster
		for (var i:Number = 0; i < len; i++)
		{
			NSKeyValueCoding.setValueWithObjectForKeyPath(m_list[i], value, keyPath);
		}
	}

	//******************************************************
	//*	                   NSCopying
	//******************************************************

	/**
	 * Copies the array.
	 */
	public function copyWithZone():NSObject {
		return (new NSArray()).initWithArrayCopyItems(this, true);
	}

	//******************************************************
	//*                Instance constructors
	//******************************************************

	/**
	 * Creates and returns a new <code>NSArray</code>.
	 */
	public static function array():NSArray {
		return (new NSArray()).init();
	}

	/**
	 * <p>Creates and returns an <code>NSArray</code> containing the objects in 
	 * <code>anArray</code>.</p>
	 *
	 * <p>Please note that this differs from {@link NSArray#arrayWithNSArray} as it 
	 * takes Flash's intrinsic Array type and not an <code>NSArray</code>.</p>
	 */
	public static function arrayWithArray(anArray:Array):NSArray {
		return (new NSArray()).initWithArray(anArray);
	}

	/**
	 * Creates and returns an <code>NSArray</code> containing the objects in 
	 * <code>anArray</code>.
	 */
	public static function arrayWithNSArray(anArray:NSArray):NSArray {
		return (new NSArray()).initWithNSArray(anArray);
	}

	/**
	 * <p>Creates and returns an <code>NSArray</code> with a capacity of 
	 * <code>numItems</code>.</p>
	 *
	 * <p>Since the Cocoa docs say that <code>numItems</code> is an unsigned int, 
	 * and we don't have any equivalent in ActionScript, this method
	 * will throw an exception if <code>numItems</code> is negative.</p>
	 */
	public static function arrayWithCapacity(numItems:Number):NSArray {
		return (new NSArray()).initWithCapacity(numItems);
	}

	/**
	 * Creates and returns an array containing the single element 
	 * <code>anObject</code>.
	 */
	public static function arrayWithObject(anObject:Object):NSArray {
		var ret:NSArray = new NSArray();
		ret.m_list.push(anObject);

		return ret;
	}

	/**
	 * <p>Creates and returns an array containing the objects in the argument list.</p>
	 *
	 * <p>This method takes a list comma-seperated objects.</p>
	 */
	public static function arrayWithObjects():NSArray {
		return (new NSArray()).initWithArray(arguments);
	}

	/**
	 * Creates and returns an array containing <code>count</code> objects from 
	 * <code>objects</code>.
	 */
	public static function arrayWithObjectsCount(objects:NSArray, count:Number)
			:NSArray {
		return (new NSArray()).initWithObjectsCount(objects, count);
	}

	//******************************************************
	//*                  Helper methods
	//******************************************************

	/**
	 * This is the standard quicksort algorithm modified a little bit
	 * to support selectors and custom comparing methods.
	 *
	 * @param arr      The array to sort.
	 * @param first    The starting index of the sort.
	 * @param last     The last index of the sort.
	 * @param compare  This argument can be a selector string or a comparison function.
	 *                 Please see NSArray.sortUsingSelector() and
	 *                 NSArray.sortUsingFunctionContext() for further details.
	 * @param context  This is an optional piece of information that is passed on every
	 *                 call to the comparison function.
	 * @param sortMode Used internally. Do not pass a value.
	 */
	public static function quickSort(arr:Array, first:Number, last:Number,
			compare:Object, context:Object, sortMode:Number):Void {
		var f:Number = first;
		var l:Number = last;
		var item:Object = arr[Math.round((f + l) / 2)];

		//
		// Determine sort mode if applicable
		//
		if (sortMode == undefined) {
			if(typeof(compare) == "string" || compare instanceof String) {
				sortMode = 1; // selector
			}
			else if (typeof(compare) == "function"
					|| compare instanceof Function) {
				sortMode = 2; // compare function
			}
			else if (compare instanceof NSArray) {
				sortMode = 3; // array of descriptors
			}
		}

		//
		// Sort the array.
		//
		do {
			switch (sortMode) {
				//
				// Sort using selectors
				//
				case 1:
					while (arr[f][compare](item)
							== NSComparisonResult.NSOrderedAscending)
						f++;

					while (item[compare](arr[l])
							== NSComparisonResult.NSOrderedAscending)
						l--;

					break;

				//
				// Sort using a compare function (and context)
				//
				case 2:
					var compareFunc:Function = Function(compare);

					while (compareFunc(arr[f], item, context)
							== NSComparisonResult.NSOrderedAscending)
						f++;

					while (compareFunc(item, arr[l], context)
							== NSComparisonResult.NSOrderedAscending)
						l--;

					break;

				//
				// Sort using an array of NSSortDescriptors
				//
				case 3:

					var arrDesc:NSArray = NSArray(compare);

					while (NSSortDescriptor.compareObjectToObjectWithDescriptors(
							arr[f], item, arrDesc)
							== NSComparisonResult.NSOrderedAscending) {
						f++;
					}

					while (NSSortDescriptor.compareObjectToObjectWithDescriptors(
							item, arr[l], arrDesc)
							== NSComparisonResult.NSOrderedAscending) {
						l--;
					}

					break;
			}

			if (f <= l)	{
				//
				// swap
				//
				var temp:Object = arr[f];
				arr[f] = arr[l];
				arr[l] = temp;

				f++;
				l--;
			}
		}
		while (f <= l);

		if (first < l)
			quickSort(arr, first, l, compare, context, sortMode);

		if (f < last)
			quickSort(arr, f, last, compare, context, sortMode);
	}
}
