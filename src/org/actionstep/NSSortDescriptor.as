/* See LICENSE for copyright and terms of use */

import org.actionstep.binding.NSKeyValueCoding;
import org.actionstep.constants.NSComparisonResult;
import org.actionstep.NSArray;
import org.actionstep.NSCopying;
import org.actionstep.NSObject;

/**
 * <p>This object describes how an array should be sorted.</p>
 *
 * <p>Instances of this object are created by specifying the property key to be 
 * compared, whether the sort should be ascending or descending, and a selector 
 * that performs the comparisons.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSSortDescriptor extends NSObject implements NSCopying
{	
	private var m_keyPath:String;
	private var m_ascending:Boolean;
	private var m_selector:String;
		
	/**
	 * Creates a new instance of NSSortDescriptor.
	 */
	public function NSSortDescriptor()
	{
	}
	
	
	/** 
	 * Returns the initialized NSSortDescriptor using property key key, and the
	 * sort order of ascending. A default selector is used.
	 */
	public function initWithKeyAscending(key:String, ascending:Boolean)
		:NSSortDescriptor
	{
		m_keyPath = key;
		m_ascending = ascending;
		m_selector = "compare"; // default
		
		return this;
	}
	
	
	/**
	 * Returns the initialized NSSortDescriptor using property key key, the
	 * sort order of ascending, a the selector selector used to perform the sort.
	 */
	public function initWithKeyAscendingSelector(key:String, ascending:Boolean, 
		selector:String):NSSortDescriptor
	{
		m_keyPath = key;
		m_ascending = ascending;
		m_selector = selector;
		
		return this;
	}
	
	//******************************************************
	//*                  Testing equality
	//******************************************************
	
	public function isEqual(other:Object):Boolean {
		if (!(other instanceof NSSortDescriptor)) {
			return false;
		}
		
		var sd:NSSortDescriptor = NSSortDescriptor(other);
		return m_keyPath == sd.m_keyPath && m_ascending == sd.m_ascending
			&& m_selector == sd.m_selector;
	}
	
	//******************************************************															 
	//*                   Properties					 
	//******************************************************
	
	/**
	 * Returns the direction of the sort. TRUE is ascending, FALSE is descending.
	 */
	public function ascending():Boolean
	{
		return m_ascending;
	}
	
	
	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String 
	{
		return "NSSortDescriptor(key=" + key() + ", ascending=" + ascending() + ")";
	}
	
	
	/**
	 * Returns the NSSortDescriptor's property key. This is the key into objects that will
	 * be sorted.
	 */
	public function key():String
	{
		return m_keyPath;
	}
	
	
	/**
	 * Returns a copy of this NSSortDescriptor with its order reversed.
	 */
	public function reversedSortDescriptor():NSSortDescriptor
	{
		var copy:NSSortDescriptor = NSSortDescriptor(super.memberwiseClone());
		copy.m_ascending = !m_ascending;
		
		return copy;
	}
	
	
	/**
	 * Returns the selector the NSSortDescriptor will use to compare objects.
	 */
	public function selector():String
	{
		return m_selector;
	}
	
	//******************************************************															 
	//*                    Public Methods					   
	//******************************************************
	
	/**
	 * Compares object1 to object2 using the NSSortDescriptor's selector.
	 *
	 * Returns NSOrderedAscending if object1 is less than object2.
	 * Returns NSOrderedEqual if object1 is equal to object2.
	 * Returns NSOrderedDescending if object1 is greater than object2.
	 */
	public function compareObjectToObject(object1:Object, object2:Object)
		:NSComparisonResult
	{
		var res:NSComparisonResult;
		
		if (m_keyPath == null) {
			res = object1[m_selector](object2);
		} else {
			object1 = NSKeyValueCoding.valueWithObjectForKeyPath(object1, m_keyPath);
			object2 = NSKeyValueCoding.valueWithObjectForKeyPath(object2, m_keyPath);
			res = object1[m_selector](object2);
		}
		
		//
		// Case where object does not respond
		//
		if (res == null) {
			res = defaultSelector(object1, object2);
		}
		
		//
		// Flip ascending to descending and vice-versa if sort order is descending.
		//
		if (!m_ascending && res != NSComparisonResult.NSOrderedSame)
		{
			if (res == NSComparisonResult.NSOrderedAscending)
				res = NSComparisonResult.NSOrderedDescending;
			else if (res == NSComparisonResult.NSOrderedDescending)
				res = NSComparisonResult.NSOrderedAscending;			
		}
		
		return res;
	}
	
	
	/**
	 * @see org.actionstep.NSCopying#copyWithZone()
	 */
	public function copyWithZone():NSObject
	{
		return NSSortDescriptor(super.memberwiseClone());
	}
	
	//******************************************************															 
	//*             Private Static Methods
	//******************************************************
	
	/**
	 * The default selector used if none is specified.
	 */
	private static function defaultSelector(object1:Object, object2:Object):NSComparisonResult
	{
		if (object1 < object2)
			return NSComparisonResult.NSOrderedAscending;
			
		if (object1 > object2)
			return NSComparisonResult.NSOrderedDescending;
			
		//
		// This should be last, because equality is slightly slower to calculate
		// than inequality I expect.
		//
		return NSComparisonResult.NSOrderedSame;
	}
	
	//******************************************************															 
	//*            Internal Static Methods
	//******************************************************

	public static function compareObjectToObjectWithDescriptors(object1:Object, 
		object2:Object, descriptors:NSArray):NSComparisonResult
	{
		var arr:Array = descriptors.internalList();
		var sd:NSSortDescriptor;
		var ret:NSComparisonResult;
		
		for (var i:Number = 0; i < arr.length; i++)
		{
			sd = NSSortDescriptor(arr[i]);
			ret = sd.compareObjectToObject(object1, object2);
			
			if (ret != NSComparisonResult.NSOrderedSame)
				break;
		}
		
		return ret;
	}
}
