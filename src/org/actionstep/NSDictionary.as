/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSCopying;
import org.actionstep.NSEnumerator;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.ASUtils;

/**
 * <p>The <code>NSDictionary</code> object holds key value pairs, accessible by 
 * key. Keys are unique, that is, there can only be one object for every key.</p>
 *
 * <p>This class is a combination of <code>NSDictionary</code> and 
 * <code>NSMutableDictionary</code> classes as defined in the Cocoa 
 * documentation.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSDictionary extends NSObject
	implements NSCopying
{
	private var m_keys:NSArray;
	private var m_objects:NSArray;
	private var m_dict:Object;
	private var m_count:Number;


	/**
	 * Creates a new instance of <code>NSDictionary</code> with no entries.
	 */
	public function NSDictionary()
	{
		m_dict = new Object();
		m_count = 0;
		m_keys = new NSArray();
		m_objects = new NSArray();
	}


	/**
	 * Initializes this dictionary with the contents from another
	 * dictionary, and returns the initialized object.
	 */
	public function initWithDictionary(otherDictionary:NSDictionary)
			:NSDictionary {
		return initWithDictionaryCopyItems(otherDictionary, false);
	}


	/**
	 * Initializes this dictionary with the contents of otherDictionary
	 * if flag is <code>false</code>, and copies of the contents of 
	 * <code>otherDictionary</code> if flag is <code>true</code>.
	 */
	public function initWithDictionaryCopyItems(otherDictionary:NSDictionary,
			flag:Boolean):NSDictionary {
		var dict:Object = otherDictionary.internalDictionary();

		for (var key:String in dict) {
			var val:Object = dict[key];

			//
			// Copy items if possible
			//
			if (flag) {
				if (ASUtils.respondsToSelector(val, "copyWithZone")) {
					val = val.copy();
				}
				else if (ASUtils.respondsToSelector(val, "memberwiseClone")) {
					val = val.memberwiseClone();
				}
			}

			setObjectForKey(val, key);
		}

		return this;
	}


	/**
	 * <p>Initializes this dictionary with the contents of <code>objects</code> 
	 * and <code>keys</code>. The objects and keys array are stepped through, 
	 * with each entry being added in turn.</p>
	 *
	 * <p>An exception is through if objects and keys don't contain the same
	 * number of elements.</p>
	 */
	public function initWithObjectsForKeys(objects:NSArray, keys:NSArray)
		:NSDictionary
	{
		if (objects.count() != keys.count())
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"InvalidArgumentException", "initWithObjectsForKeys - object " +
				"and key arrays must have the same number of elements", null);
			trace(e);
			throw e;
		}

		var kitr:NSEnumerator = keys.objectEnumerator();
		var oitr:NSEnumerator = objects.objectEnumerator();
		var key:Object;
		var obj:Object;

		while (null != (key = kitr.nextObject()))
		{
			obj = oitr.nextObject();

			try {
				setObjectForKey(obj, String(key));
			} catch(e:NSException) {
				break;
			}
		}

		return this;
	}


	/**
	 * <p>Initializes this dictionary with count entries consisting of
	 * keys from the <code>keys</code> array and objects from the 
	 * <code>objects</code> array.</p>
	 *
	 * <p>An exception is through if objects and keys don't contain the same
	 * number of elements.</p>
	 */
	public function initWithObjectsForKeysCount(objects:NSArray, keys:NSArray,
		count:Number):NSDictionary
	{
		if (objects.count() != keys.count())
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"InvalidArgumentException", "initWithObjectsForKeys - object " +
				"and key arrays must have the same number of elements", null);
			trace(e);
			throw e;
		}

		while (keys.count() > count)
			keys.removeObjectAtIndex(keys.count() - 1);

		while (objects.count() > count)
			objects.removeObjectAtIndex(objects.count() - 1);

		return initWithObjectsForKeys(objects, keys);
	}


	/**
	 * <p>Initializes this dictionary containing entries constructed from
	 * the arguments list, which alternate between objects and keys.</p>
	 *
	 * <p>An exception is raised if a key is <code>null</code>.</p>
	 */
	public function initWithObjectsAndKeys():NSDictionary
	{
		var args:Array = arguments;
		var obj:Object;

		for (var i:Number = 0; i < args.length; i++)
		{
			var isObj:Boolean = (i % 2) == 0;

			if (isObj)
			{
				obj = args[i];
				continue;
			}

			//
			// Key handling
			//
			if (args[i] == null)
			{
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					"InvalidArgumentException", "initWithObjectsAndKeys - object " +
					"and key arrays must have the same number of elements", null);
				trace(e);
				throw e;
			}

			try {
				setObjectForKey(obj, args[i]);
			} catch(e:NSException) {
				//if obj is null, continue to next pair
				continue;
			}
		}

		return this;
	}


	//******************************************************
	//*					  Properties					   *
	//******************************************************

	/**
	 * Returns a new array containing this dictionary's keys.
	 */
	public function allKeys():NSArray
	{
		return NSArray.arrayWithNSArray(m_keys);
	}


	/**
	 * Returns a new array containing this dictionary's objects.
	 */
	public function allValues():NSArray
	{
		return NSArray.arrayWithNSArray(m_objects);
	}


	/**
	 * Returns the number of entries this dictionary contains.
	 */
	public function count():Number
	{
		return m_count;
	}


	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String
	{
		var ret:String = "NSDictionary(";

		for (var key:String in m_dict)
		{
			ret += "\n\t"+key + "=>" + m_dict[key].toString() + ",";
		}

		if (count() > 0)
			ret = ret.substr(0, ret.length -1);

		ret += "\n\t)";

		return ret;
	}


	/**
	 * <p>Returns the internal data structure of this dictionary.</p>
	 *
	 * <p>For developer use only.</p>
	 */
	public function internalDictionary():Object
	{
		return m_dict;
	}


	/**
	 * <p>Returns an enumerator for this dictionary's keys.</p>
	 *
	 * <p>Do not modify this collection while undergoing enumeration. If you
	 * wish to do so, use the {@link #allKeys()} method, and enumerate through 
	 * that array, as it is a copy.</p>
	 */
	public function keyEnumerator():NSEnumerator
	{
		return m_keys.objectEnumerator();
	}


	/**
	 * <p>Returns an enumerator for this dictionary's values.</p>
	 *
	 * <p>Do not modify this collection while undergoing enumeration. If you
	 * wish to do so, use the {@link #allObjects()} method, and enumerate 
	 * through that array, as it is a copy.</p>
	 */
	public function objectEnumerator():NSEnumerator
	{
		return m_objects.objectEnumerator();
	}


	/**
	 * Returns the object associated with the key <code>aKey</code>, or 
	 * <code>null</code> if the key does not exist.
	 */
	public function objectForKey(aKey:String):Object
	{
		var obj:Object = m_dict[aKey];
		return obj == undefined ? null : obj; // make sure null is returned, not undefined
	}

	//******************************************************
	//*					 Public Methods					   *
	//******************************************************

	/**
	 * Returns a new array containing all keys associated with 
	 * <code>anObject</code>.
	 */
	public function allKeysForObject(anObject:Object):NSArray
	{
		var ret:NSArray = new NSArray();
		var isNSObj:Boolean = anObject instanceof NSObject;

		//
		// If anObject is an NSObject, we use isEqual, and
		// reference equality otherwise.
		//
		if (isNSObj)
		{
			for (var p:String in m_dict)
			{
				if (anObject.isEqual(m_dict[p]))
					ret.addObject(p);
			}
		}
		else
		{
			for (var p:String in m_dict)
			{
				if (anObject == m_dict[p])
					ret.addObject(p);
			}
		}

		return ret;
	}


	/**
	 * <p>Returns <code>true</code> if this dictionary is equal to 
	 * <code>otherDictionary</code>, and <code>false</code> otherwise.</p>
	 *
	 * <p>The two dictionaries are equal if their sizes are the same, and for any
	 * given key, the corresponding object must satisfy an {@link #isEqual()} 
	 * test (if {@link NSObject}) or an equality test (if not 
	 * <code>NSObject</code>).</p>
	 */
	public function isEqualToDictionary(otherDictionary:NSDictionary):Boolean
	{
		//
		// Size test (fastest and easiest)
		//
		if (m_count != otherDictionary.m_count)
			return false;

		//!

		return true;
	}


	//******************************************************
	//*			  Adding and Removing Entries			   *
	//******************************************************

	/**
	 * <p>Adds each entry from <code>otherDictionary</code> into this dictionary.</p>
	 *
	 * <p>If a key in <code>otherDictionary</code> already exists in this 
	 * dictionary, the object is replaced.</p>
	 */
	public function addEntriesFromDictionary(otherDictionary:NSDictionary):Void
	{
		var itr:NSEnumerator = otherDictionary.keyEnumerator();
		var key:String;

		while (null != (key = String(itr.nextObject())))
		{
			this.setObjectForKey(otherDictionary.objectForKey(key), key);
		}
	}


	/**
	 * Empties the dictionary.
	 */
	public function removeAllObjects():Void
	{
		m_keys.removeAllObjects();
		m_objects.removeAllObjects();
		m_dict = new Object();
		m_count = 0;
	}


	/**
	 * Removes the object corresponding to <code>aKey</code> from the dictionary.
	 */
	public function removeObjectForKey(aKey:String):Void
	{
		if (aKey == null)
			return;

		var obj:Object = objectForKey(aKey);

		if (obj == null) // don't do anything
			return;

		m_objects.removeObject(obj);
		m_keys.removeObject(aKey);
		m_count--;
		delete m_dict[aKey];
	}


	/**
	 * Removes the objects corresponding to the keys in <code>keyArray</code>.
	 */
	public function removeObjectsForKeys(keyArray:NSArray):Void
	{
		var itr:NSEnumerator = keyArray.objectEnumerator();

		//
		// Remove objects for each key in turn.
		//
		var key:String;
		while (null != (key = String(itr.nextObject())))
		{
			removeObjectForKey(key);
		}
	}


	/**
	 * Sets the contents of this dictionary to the contents of 
	 * <code>otherDictionary</code>.
	 */
	public function setDictionary(otherDictionary:NSDictionary):Void
	{
		removeAllObjects();
		addEntriesFromDictionary(otherDictionary);
	}


	/**
	 * <p>Adds an entry to this dictionary consisting of the key <code>aKey</code>,
	 * and its corresponding value <code>anObject</code>.</p>
	 *
	 * <p>If a value corresponding to <code>aKey</code> already exists, it is 
	 * replaced with <code>anObject</code>.</p>
	 *
	 * <p>An exception is thrown if <code>aKey</code> 
	 * is <code>null</code>.</p>
	 */
	public function setObjectForKey(anObject:Object, aKey:String):Void
	{
		if (aKey == null)
		{		
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"InvalidArgumentException", 
				"aKey argument cannot be null.", 
				null);
			trace(e);
			throw e;
		}

		//
		// If doesn't exist, add the key, and up the count,
		// otherwise remove the old object.
		//
		if (objectForKey(aKey) == null)
		{
			m_keys.addObject(aKey);
			m_count++;
		}
		else
		{
			m_objects.removeObject(objectForKey(aKey));
		}

		//
		// No need to store multiple references to the same object.
		//
		if (!m_objects.containsObject(anObject))
			m_objects.addObject(anObject);

		m_dict[aKey] = anObject;
	}

	//******************************************************
	//*	                   NSCopying
	//******************************************************

	public function copyWithZone():NSObject
	{
		var result:NSDictionary = new NSDictionary();
		result.initWithDictionaryCopyItems(NSDictionary(this), true);
		return result;
	}

	//******************************************************
	//*				    Protected Methods				   *
	//******************************************************
	//******************************************************
	//*					 Private Methods				   *
	//******************************************************
	//******************************************************
	//*			   Public Static Properties				   *
	//******************************************************
	//******************************************************
	//*				 Public Static Methods				   *
	//******************************************************

	/**
	 * Creates and returns an empty dictionary.
	 */
	public static function dictionary():NSDictionary
	{
		return new NSDictionary();
	}


	/**
	 * Creates and returns a dictionary filled with the contents
	 * of <code>otherDictionary</code>.
	 */
	public static function dictionaryWithDictionary(
		otherDictionary:NSDictionary):NSDictionary
	{
		return (new NSDictionary()).initWithDictionary(otherDictionary);
	}


	/**
	 * Creates and returns a dictionary containing a single entry
	 * of <code>anObject</code> indexed on <code>aKey</code>.
	 */
	public static function dictionaryWithObjectForKey(anObject:Object,
		aKey:String):NSDictionary
	{
		var dict:NSDictionary = new NSDictionary();
		try {
			dict.setObjectForKey(anObject, aKey);
		} catch(e:NSException) {
			//tag it so that line, class name, etc set
			trace(e);
			e.raise();
		}
		return dict;
	}


	/**
	 * <p>Creates and returns a dictionary containing the contents of
	 * <code>objects</code> and <code>keys</code>.</p>
	 *
	 * <p>An exception is raised if the <code>objects</code> and <code>keys</code> 
	 * arrays don't have the same number of elements.</p>
	 */
	public static function dictionaryWithObjectsForKeys(objects:NSArray,
		keys:NSArray):NSDictionary
	{
		return (new NSDictionary()).initWithObjectsForKeys(
			objects, keys);
	}


	/**
	 * <p>Creates and returns a dictionary containing <code>count</code> objects 
	 * from <code>objects</code> and <code>keys</code>.</p>
	 *
	 * <p>An exception is raised if the <code>objects</code> and 
	 * <code>keys</code> array don't have the same number of elements.</p>
	 */
	public static function dictionaryWithObjectsForKeysCount(objects:NSArray,
		keys:NSArray, count:Number):NSDictionary
	{
		return (new NSDictionary()).initWithObjectsForKeysCount(
			objects, keys, count);
	}


	/**
	 * <p>Creates and returns a dictionary containing entries constructed from
	 * the arguments list, which alternate between objects and keys.</p>
	 *
	 * <p>An exception is raised if a key is <code>null</code>.</p>
	 */
	public static function dictionaryWithObjectsAndKeys():NSDictionary
	{
		var dict:NSDictionary = new NSDictionary();
		dict.initWithObjectsAndKeys.apply(dict, arguments);
		return dict;
	}
}
