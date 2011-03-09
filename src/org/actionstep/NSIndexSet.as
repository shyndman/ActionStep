/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.NSRange;

/**
 * An immutable collection of Numbers (should be unsigned integers). These
 * Numbers represent a series of indexes. An index can only appear once. These
 * indexes are always sorted, so the order in which they are added does not
 * matter.
 *
 * Internally, indexes are stored as a collection of ranges.
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSIndexSet extends NSObject
{
	//******************************************************
	//*                     Members
	//******************************************************

	private var m_ranges:NSArray;
	private var m_list:Array;

	//******************************************************
	//*                   Construction
	//******************************************************

	/**
	 * Creates a new instance of NSIndexSet. Must be followed by a call to an
	 * initialization method.
	 */
	public function NSIndexSet()
	{
	}


	/**
	 * Initializes a new instance with no indexes.
	 */
	public function init():NSIndexSet
	{
		m_ranges = NSArray.array();
		m_list = m_ranges.internalList();
		return this;
	}


	/**
	 * Initializes a new instance with a single index.
	 */
	public function initWithIndex(idx:Number):NSIndexSet
	{
		return initWithIndexesInRange(new NSRange(idx, 1));
	}


	/**
	 * Initializes a new instance with indexes specified by range.
	 *
	 * An exception is thrown if the range is invalid (negative location).
	 */
	public function initWithIndexesInRange(range:NSRange):NSIndexSet
	{
		if (range.location < 0) // bad range
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSRangeException",
				"The range's location is invalid. (" + range.location + ")",
				NSDictionary.dictionaryWithObjectForKey(range, "range"));
			trace(e);
			throw e;
		}

		init();
		m_ranges.addObject(range.copyWithZone());
		return this;
	}


	/**
	 * Initializes a new instance with the indexes in indexSet.
	 */
	public function initWithIndexSet(indexSet:NSIndexSet):NSIndexSet
	{
		m_ranges = NSArray(indexSet.m_ranges.copyWithZone());
		return this;
	}

	//******************************************************
	//*              Describing the index set
	//******************************************************

	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String {
		var ret:String = "NSIndexSet(indexes=";
		var ind:Array = getIndexes().internalList();
		var len:Number = ind.length;

		for (var i:Number = 0; i < len; i++) {
			ret += ind[i];

			if (i + 1 < len) {
				ret += ",";
			}
		}

		return ret + ")";
	}

	//******************************************************
	//*                 Testing an index set
	//******************************************************

	/**
	 * Returns <code>true</code> if the indexes contained in
	 * <code>indexSet</code> are identical to the ones contained in this index
	 * set.
	 */
	public function isEqualToIndexSet(indexSet:NSIndexSet):Boolean {
		var arr:Array = m_list;
		var arr2:Array = indexSet.m_ranges.internalList();

		if (arr.length != arr2.length) {
			return false;
		}

		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			if (!NSRange(arr[i]).isEqual(arr[2])) {
		  		return false;
			}
		}

		return true;
	}

	/**
	 * @see org.actionstep.NSObject#isEqual
	 */
	public function isEqual(anObject:Object):Boolean {
		if (!(anObject instanceof NSIndexSet)) {
			return false;
		}

		return isEqualToIndexSet(NSIndexSet(anObject));
	}

	/**
	 * Returns <code>true</code> if the index set contains the index
	 * <code>idx</code>.
	 */
	public function containsIndex(idx:Number):Boolean {
		var rng:NSRange;
		var rngs:Array = m_list;
		var len:Number = rngs.length;

		for (var i:Number = 0; i < len; i++) {
			rng = NSRange(rngs[i]);
			if (rng.containsValue(idx)) {
				return true;
			}
		}

		return false;
	}

	/**
	 * Returns <code>true</code> if this index set contains all the indexes
	 * found in <code>indexSet</code>.
	 */
	public function containsIndexes(indexSet:NSIndexSet):Boolean {
		var arr:Array = indexSet.getIndexes().internalList();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			if (!containsIndex(Number(arr[i]))) {
				return false;
			}
		}

		return true;
	}

	/**
	 * Returns <code>true</code> if this index set contains all the indexes
	 * found in <code>range</code>.
	 */
	public function containsIndexesInRange(range:NSRange):Boolean {
		var low:Number;
		var high:Number;
		var rng:NSRange;
		var alow:Number = range.location;
		var ahigh:Number = alow + range.length - 1;
		var rngs:Array = m_list;
		var len:Number = rngs.length;

		for (var i:Number = 0; i < len; i++) {
			rng = NSRange(rngs[i]);
			low = rng.location;
			high = low + rng.length - 1;

			if (ahigh <= high && alow >= low) {
				return true;
			}
		}

		return false;
	}

	/**
	 * Returns <code>true</code> if the receiver contains any indexes in the
	 * range specified by <code>range</code>.
	 */
	public function intersectsIndexesInRange(range:NSRange):Boolean {
		var rng:NSRange;
		var rngs:Array = m_list;
		var len:Number = rngs.length;

		for (var i:Number = 0; i < len; i++) {
			rng = NSRange(rngs[i]);
			if (rng.intersectsRange(range)) {
				return true;
			}
		}

		return false;
	}

	//******************************************************
	//*        Getting information about an index set
	//******************************************************

	/**
	 * Returns the number of indexes in the set.
	 */
	public function count():Number {
		var rng:NSRange;
		var rngs:Array = m_list;
		var len:Number = rngs.length;
		var cnt:Number = 0;

		for (var i:Number = 0; i < len; i++)
		{
			rng = NSRange(rngs[i]);
			cnt += rng.length;
		}

		return cnt;
	}

	//******************************************************
	//*                 Accessing indexes
	//******************************************************

	/**
	 * Returns the first index in the set, or NSObject.NSNotFound if the set
	 * is empty.
	 */
	public function firstIndex():Number
	{
		if (m_ranges.count() == 0)
		{
			return NSObject.NSNotFound;
		}

		var rng:NSRange = NSRange(m_ranges.objectAtIndex(0));
		return rng.location;
	}

	/**
	 * Returns the last index in the set, or NSObject.NSNotFound if the set
	 * is empty.
	 */
	public function lastIndex():Number {
		if (m_ranges.count() == 0) {
			return NSObject.NSNotFound;
		}

		var rng:NSRange = NSRange(m_ranges.lastObject());
		return rng.location + rng.length - 1;
	}

	/**
	 * Returns the next closest index that is greater than idx or NSNotFound
	 * if value is the last index in the set.
	 */
	public function indexGreaterThanIndex(idx:Number):Number {
		var arr:Array = m_list;
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			var rng:NSRange = NSRange(arr[i]);

			//
			// Range contains value
			//
			if (rng.containsValue(idx)) {
				if (rng.containsValue(idx + 1)) {
					return idx + 1;
				}

				if (i + 1 < len) {
					return NSRange(arr[i+1]).location;
				}
			}

			//
			// Range doesn't contain value
			//
			var bnd:Number = rng.upperBound();
			if (bnd < idx) {
				if (i + 1 < len) {
					return NSRange(arr[i+1]).location;
				}
			}
		}

		return NSObject.NSNotFound;
	}

	/**
	 * Returns the next closest index that is greater than or equal to idx or
	 * NSNotFound if value is the last index in the set.
	 */
	public function indexGreaterThanOrEqualToIndex(idx:Number):Number {
		var arr:Array = m_list;
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			var rng:NSRange = NSRange(arr[i]);

			//
			// Range contains value
			//
			if (rng.containsValue(idx)) {
				return idx;
			}

			//
			// Range doesn't contain value
			//
			var bnd:Number = rng.upperBound();
			if (bnd < idx) {
				if (i + 1 < len) {
					return NSRange(arr[i+1]).location;
				}
			}
		}

		return NSObject.NSNotFound;
	}

	/**
	 * Returns the next closest index that is less than idx or NSNotFound
	 * if value is the first index in the set.
	 */
	public function indexLessThanIndex(idx:Number):Number {
		var arr:Array = m_list;
		var len:Number = arr.length;

		for (var i:Number = len - 1; i >= 0; i--) {
			var rng:NSRange = NSRange(arr[i]);

			//
			// Range contains value
			//
			if (rng.containsValue(idx)) {
				if (rng.containsValue(idx - 1)) {
					return idx - 1;
				}

				if (i - 1 >= 0) {
					return NSRange(arr[i-1]).upperBound();
				}
			}

			//
			// Range doesn't contain value
			//
			var bnd:Number = rng.upperBound();
			if (bnd < idx) {
				return rng.upperBound();
			}
		}

		return NSObject.NSNotFound;
	}


	/**
	 * Returns the next closest index that is less than or equal to idx or
	 * NSNotFound if value is the first index in the set.
	 */
	public function indexLessThanOrEqualToIndex(idx:Number):Number {
		var arr:Array = m_list;
		var len:Number = arr.length;

		for (var i:Number = len - 1; i >= 0; i--) {
			var rng:NSRange = NSRange(arr[i]);

			//
			// Range contains value
			//
			if (rng.containsValue(idx)) {
				return idx;
			}

			//
			// Range doesn't contain value
			//
			var bnd:Number = rng.upperBound();
			if (bnd < idx) {
				return rng.upperBound();
			}
		}

		return NSObject.NSNotFound;
	}

	/**
	 * Returns all indexes held by this index set.
	 *
	 * This is actionstep's equivalent to
	 * <code>getIndexes:maxCount:inIndexRange:</code>.
	 */
	public function getIndexes():NSArray {
		var ret:NSArray = NSArray.array();
		var arr:Array = m_list;
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			var rng:NSRange = NSRange(arr[i]);
			var lower:Number = rng.location;
			var upper:Number = rng.upperBound();

			for (var j:Number = lower; j <= upper; j++) {
				ret.addObject(j);
			}
		}

		return ret;
	}

	//******************************************************
	//*                  Adding indexes
	//******************************************************

	/**
	 * Adds the index specified by <code>value</code> to the receiver.
	 */
	public function addIndex(value:Number):Void {
		if (containsIndex(value)) {
			return;
		}

		var arr:Array = m_list;
		var len:Number = arr.length;

		//
		// Empty index set case
		//
		if (len == 0) {
			m_ranges.addObject(new NSRange(value, 1));
			return;
		}

		//
		// Figure out where to position the index in the list of ranges
		//
		for (var i:Number = 0; i < len; i++) {
			var rng:NSRange = NSRange(arr[i]);
			var nextRng:NSRange;
			var lower:Number = rng.upperBound();
			var upper:Number;

			if (i + 1 < len) {
				nextRng = NSRange(arr[i+1]);
				upper = nextRng.location;
			} else {
				nextRng = null;
				upper = -1;
			}

			if (rng.location == value + 1) {
				rng.location--;
				rng.length++;
				return;
			}
			else if (lower + 1 == value) {
				rng.length++;
				return;
			}
			else if (upper == value + 1) {
				//
				// Belongs to next
				//
				continue;
			}
			else if (value > lower && upper == -1) {
				m_ranges.addObject(new NSRange(value, 1));
			}
			else if (value < lower && upper == -1) {
				m_ranges.insertObjectAtIndex(new NSRange(value, 1), 0);
			}
			else if (value > lower && value < upper) {
				m_ranges.insertObjectAtIndex(new NSRange(value, 1), i);
			}
		}
	}

	/**
	 * Adds the indexes specified by indexSet to the receiver.
	 */
	public function addIndexes(indexSet:NSIndexSet):Void {
		var arr:Array = indexSet.getIndexes().internalList();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			addIndex(Number(arr[i]));
		}
	}

	/**
	 * Adds the indexes specified by <code>range</code> to the receiver.
	 */
	public function addIndexesInRange(range:NSRange):Void {
		var len:Number = range.upperBound();
		for (var i:Number = range.location; i <= len; i++) {
			addIndex(i);
		}
	}

	//******************************************************
	//*                  Removing indexes
	//******************************************************

	/**
	 * Removes the index specified by <code>value</code> from the receiver.
	 */
	public function removeIndex(value:Number):Void {
		var arr:Array = m_list;
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			var rng:NSRange = NSRange(arr[i]);
			var upper:Number = rng.upperBound();

			if (!rng.containsValue(value)) {
				continue;
			}

			if (rng.location == value) {
				rng.location++;
				rng.length--;
				return;
			}
			else if (upper == value) {
				rng.length--;
				return;
			} else {
				//
				// Split the range in two
				//
				var cntBefore:Number = upper - value;
				var cntAfter:Number = upper - cntBefore;
				var startPoint:Number = value + 1;

				var newRange:NSRange = new NSRange(startPoint, cntAfter);
				m_ranges.insertObjectAtIndex(newRange, i + 1);

				rng.length = cntBefore - 1;
			}
		}
	}

	/**
	 * Removes the indexes contained in <code>indexSet</code> from the
	 * receiver.
	 */
	public function removeIndexes(indexSet:NSIndexSet):Void {
		var arr:Array = indexSet.getIndexes().internalList();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			removeIndex(Number(arr[i]));
		}
	}

	/**
	 * Removes the indexes specified by <code>range</code> from the receiver.
	 */
	public function removeIndexesInRange(range:NSRange):Void {
		var len:Number = range.upperBound();
		for (var i:Number = range.location; i <= len; i++) {
			addIndex(i);
		}
	}

	/**
	 * Removes all indexes from the index set.
	 */
	public function removeAllIndexes():Void {
		m_ranges.removeAllObjects();
		m_list = m_ranges.internalList();
	}

	//******************************************************
	//*          Shifting indexes in an index set
	//******************************************************

	//! TODO - (void)shiftIndexesStartingAtIndex:(unsigned int)index by:(int)delta

	//******************************************************
	//*               Copying an index set
	//******************************************************
	
	/**
	 * Creates a copy of this index set and returns it.
	 */
	public function copyWithZone():NSIndexSet {
		return (new NSIndexSet()).initWithIndexSet(this);
	}
	
	//******************************************************
	//*               Creating an index set
	//******************************************************

	/**
	 * Initializes and returns an empty index set.
	 */
	public static function indexSet():NSIndexSet
	{
		return (new NSIndexSet()).init();
	}


	/**
	 * Initializes and returns an index set containing a single index.
	 */
	public static function indexSetWithIndex(idx:Number):NSIndexSet
	{
		return (new NSIndexSet()).initWithIndex(idx);
	}


	/**
	 * Initializes and returns an index set containing the indexes found in
	 * range.
	 */
	public static function indexSetWithIndexesInRange(range:NSRange):NSIndexSet
	{
		return (new NSIndexSet()).initWithIndexesInRange(range);
	}

}
