/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.constants.NSComparisonResult;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSObject;

/**
 * <p>This class provides methods for modifying the properties of a class using
 * key-value coding.</p>
 *
 * <p>This is implemented as a separate class so that it will work with objects
 * that do not descend from {@link NSObject}.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.binding.NSKeyValueCoding extends NSObject
{
	//******************************************************
	//*               Array and set operators
	//******************************************************

	/**
	 * The <code>@avg</code> operator uses
	 * {@link #valueWithObjectForKeyPath} to get the value for each item in
	 * the receiver, then averages them together.
	 */
	public static var NSAverageKeyValueOperator:String
		= "@avg";

	/**
	 * The <code>@count</code> operator uses gets the returns the length of the
	 * collection. The keyPath to the right of the collection is ignored.
	 */
	public static var NSCountKeyValueOperator:String
		= "@count";

	/**
	 * The <code>@distinctUnionOfArrays</code> operator returns an array
	 * containing the distinct objects in the arrays returned by using
	 * {@link #valueWithObjectForKeyPath} on each item in the array,
	 * passing the key path to the right of the array operator.
	 */
	public static var NSDistinctUnionOfArraysKeyValueOperator:String
		= "@distinctUnionOfArrays";

	/**
	 * The <code>@distinctUnionOfObjects</code> operator returns an array
	 * containing the distinct objects returned by using
	 * {@link #valueWithObjectForKeyPath} on each item in the array,
	 * using the key path to the right of the array operator.
	 */
	public static var NSDistinctUnionOfObjectsKeyValueOperator:String
		= "@distinctUnionOfObjects";

	/**
	 * <p>The <code>@distinctUnionOfSets</code> operator returns an array
	 * containing the distinct objects returned by using
	 * {@link #valueWithObjectForKeyPath} with each item in the receiver,
	 * passing the key path to the right of the @ operator.</p>
	 *
	 * <p>This operator is the same as <code>@distinctUnionOfArrays</code> , but
	 * operates on an {@link NSSet}, rather than an {@link NSArray}.
	 * The <code>@unionOfSets</code> operator is similar, but does not remove
	 * duplicate objects.</p>
	 */
	public static var NSDistinctUnionOfSetsKeyValueOperator:String
		= "@distinctUnionOfSets";

	/**
	 * The <code>@max</code> operator compares the objects returned by using
	 * {@link #valueWithObjectForKeyPath} with each item in the array
	 * passing the key path to the right of the array operator as the parameter
	 * returning the maximum value found. The maximum value is determined using
	 * the {@link #compare} method of the objects at the specified key
	 * path, or standard comparison if the objects are base types. The compared
	 * property objects must support comparison with each other.
	 */
	public static var NSMaximumKeyValueOperator:String
		= "@max";

	/**
	 * The <code>@min</code> operator compares the objects returned by using
	 * {@link #valueWithObjectForKeyPath} with each item in the array
	 * passing the key path to the right of the array operator as the parameter
	 * returning the minimum value found. The maximum value is determined using
	 * the {@link #compare} method of the objects at the specified key
	 * path, or standard comparison if the objects are base types. The compared
	 * property objects must support comparison with each other.
	 */
	public static var NSMinimumKeyValueOperator:String
		= "@min";

	/**
	 * The <code>@sum</code> operator returns the total of all the numbers
	 * returned by using {@link #valueWithObjectForKeyPath} with each item
	 * in the array passing the key path to the right of the array operator as
	 * the parameter.
	 */
	public static var NSSumKeyValueOperator:String
		= "@sum";

	/**
	 * The <code>@unionOfArrays</code> operator is just like the
	 * <code>@distinctUnionOfArrays</code>, except the contents of the array
	 * are not necessary unique.
	 */
	public static var NSUnionOfArraysKeyValueOperator:String
		= "@unionOfArrays";

	/**
	 * The <code>@unionOfObjects</code> operator is just like the
	 * <code>@distinctUnionOfObjects</code>, except the contents of the array
	 * are not necessary unique.
	 */
	public static var NSUnionOfObjectsKeyValueOperator:String
		= "@unionOfObjects";
	/**
	 * The <code>@unionOfSets</code> operator is just like the
	 * <code>@distinctUnionOfSets</code>, except the contents of the array
	 * are not necessary unique.
	 */
	public static var NSUnionOfSetsKeyValueOperator:String
		= "@unionOfSets";

	//******************************************************
	//*                  Indexer constants
	//******************************************************

	private static var INDEX_FIRST:String 	= "FIRST";
	private static var INDEX_LAST:String 	= "LAST";
	private static var INDEX_SIZE:String 	= "SIZE";

	//******************************************************
	//*                   Class members
	//******************************************************

	private static var g_operators:Object;

	//******************************************************
	//*                    Construction
	//******************************************************
	/**
	 * This is a static class.
	 */
	private function NSKeyValueCoding()
	{
	}

	//******************************************************
	//*                  Getting values
	//******************************************************

	/**
	 * <p>Returns the property identified by <code>key</code> for
	 * <code>anObject</code>.</p>
	 *
	 * <p>The default implementation works as follows:
	 * <ol>
	 * <li>
	 * Searches for a public accessor method based on <code>key</code>. For
	 * example, with the key "foo", it will look for a method called
	 * <code>foo</code> or <code>getFoo</code>.
	 * </li>
	 * <li>
	 * If an accessor method is not found, this will search for an instance
	 * variable. In the case of the key "foo", a variable named
	 * <code>foo</code> will be searched for.
	 * </li>
	 * <li>
	 * If the accessor is not found,
	 * {@link anObject#valueForUndefinedKey} is called if it exists.
	 * </li>
	 * <li>
	 * If the object doesn't have a {@link #valueForUndefinedKey}
	 * method, an {@link NSException} is thrown.
	 * </li>
	 * </ol>
	 *  </p>
	 */
	public static function valueWithObjectForKey(anObject:Object,
			key:String):Object {
		//
		// Operator check
		//
		if (key.charAt(0) == "@" && operatorWithName(key) != null) {
			return valueWithObjectForKeyPath(anObject, key);
		}

		//
		// "this" check
		//
		if (key == "__kvc_this__") {
			return anObject;
		}
		else if (ASUtils.isCollection(anObject)) {
			return valueWithObjectForKeyPath(anObject, key);
		}

		//
		// Check for indexers
		//
		var hasIndexers:Boolean = false;
		var index:String;
		var bidx:Number;

		if ((bidx = key.indexOf("[")) != -1 && key.indexOf("]") != -1) {
			//
			// We're using an indexer.
			//
			hasIndexers = true;
			index = key.substring(bidx + 1, key.indexOf("]")).toUpperCase();
			key = key.substring(0, bidx);
		}
		
		var ret:Object;
		
		//
		// Get the getter
		//
		var getter:Object = getterWithObjectForKey(anObject, key);
		
		//
		// No getter
		//
		if (getter == null) {
			if (ASUtils.respondsToSelector(anObject, "valueForUndefinedKey")) {
				ret = anObject["valueForUndefinedKey"](key);
			} else {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					"NSUndefinedKeyException",
					"A property named " + key + " does not exist on " + anObject + ".",
					NSDictionary.dictionaryWithObjectForKey(anObject, "NSObject"));
				trace(e);
				throw e;	
			}
		}

		//
		// Get the value
		//
		switch (getter.type) {
			case 1: // function
				ret = getter.value.call(anObject);
				break;
				
			case 2: // value
				ret = anObject[getter.value];
				break;
		}
		
		//
		// Extract value as denoted by indexers if necessary.
		//
		if (hasIndexers) {
			//
			// Make sure ret is an array
			//
			if (!(ret instanceof Array || ret instanceof NSArray)) {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSInvalidArgument,
					"Indexers can only be used on NSArrays or Arrays.",
					null);
				trace(e);
				throw e;
			}

			//
			// Get an NSArray for the collection
			//
			var collection:NSArray = NSArray(ret);;

			if (collection == null) {
				collection = NSArray.array();
				collection["m_list"] = ret;
			}

			//
			// Return the index
			//
			if (!isNaN(index)) {
				return collection.objectAtIndex(Number(index));
			}
			else if (index == INDEX_FIRST) {
				return collection.objectAtIndex(0);
			}
			else if (index == INDEX_LAST) {
				return collection.lastObject();
			}
			else if (index == INDEX_SIZE) {
				return collection.count();
			} else {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSInvalidArgument,
					"Unrecognized indexer - " + index,
					null);
				trace(e);
				throw e;
			}
		}

		return ret;
	}

	/**
	 * <p>Returns the getter for the property at <code>key</code>.</p>
	 * 
	 * <p>Returns an object structured as follows:<br>
	 * <code>{type:Number, value:Object]}</code></p>
	 * 
	 * <p><code>type</code> will be either <code>1</code>, which means
	 * <code>value</code> is a function, or <code>2</code> if 
	 * <code>value</code> is an object value.</p>
	 * 
	 * <p>If <code>null</code> is returned, no property could be found.</p>
	 */
	public static function getterWithObjectForKey(anObject:Object, key:String):Object {
		//
		// Build alternate accessor names
		//
		var getKeyName:String = "get" + key.charAt(0).toUpperCase()
			+ key.substr(1);
		var isKeyName:String = "is" + key.charAt(0).toUpperCase()
			+ key.substr(1);
			
		//
		// Attempt all routes of getting the value
		//
		var ret:Object = {};
		ret.toString = function():String {
			return "Getter(type=" + this.type + ", value=" + this.value + ")";
		};
		ret.type = 1;
		
		if (ASUtils.respondsToSelector(anObject, key)) {
			ret.value = anObject[key];
		}
		else if (ASUtils.respondsToSelector(anObject, isKeyName)) {
			ret.value = anObject[isKeyName];
		}
		else if (ASUtils.respondsToSelector(anObject, getKeyName)) {
			ret.value = anObject[getKeyName];
		}
		else if (anObject[key] != undefined) {
			ret.value = key;
			ret.type = 2;
		} else {
			return null;
		}
		
		return ret;
	}
	
	/**
	 * Returns the value of the derived key path <code>keyPath</code> for the
	 * object <code>anObject</code>. This method uses {@link #valueForKey}
	 * for every key in the path.
	 */
	public static function valueWithObjectForKeyPath(anObject:Object,
			keyPath:String):Object {
		
		//
		// Return the object if no key path is found
		//
		if (keyPath == null || keyPath.length == 0) {
			return anObject;
		}

		var parts:Array = keyPath.split(".");
		parts.splice(0, 0, "__kvc_this__");
		var len:Number = parts.length;
		var curObj:Object = anObject;

		for (var i:Number = 0; i < len; i++) {
			var key:String = parts[i];

			//
			// Operator check
			//
			var op:Object = operatorWithName(key);

			if (op != null) {
				var targ:Object = op.target;
				var sel:String = op.selector;

				//
				// Attempt to get the collection object
				//
				var collection:Object = curObj;

				//
				// Extract the internal array from the collection
				//
				var arr:Object = ASUtils.extractArrayFromCollection(collection);

				if (arr == null) {
					//
					// Throw an exception if we couldn't get the collection
					//
					var e:NSException =
						NSException.exceptionWithNameReasonUserInfo(
							NSException.NSInvalidArgument,
							collection + " is not a collection.",
							NSDictionary.dictionaryWithObjectForKey(collection,
							"NSObject"));
					trace(e);
					throw e;
				}

				//
				// Create the keypath
				//
				var modelKeyPath:String = parts.slice(i + 1).join(".");
				
				return targ[sel](arr, modelKeyPath);

				continue;
			}

			//
			// Not an operator, so keep going.
			//
			curObj = valueWithObjectForKey(curObj, parts[i]);

			if (curObj == null) {
				break;
			}

			//
			// Check if curObj is a collection
			//
			if (!ASUtils.isCollection(curObj)
					|| i + 1 == len
					|| isOperator(parts[i + 1])) {

				continue;
			}

			//
			// Proceed to the right of the key path.
			//
			var arr:Object = ASUtils.extractArrayFromCollection(curObj);
			var ckeypath:String = parts.slice(i + 1).join(".");
			var clen:Number = arr.length;
			var cret:NSArray = NSArray.array();
			curObj = cret;

			for (var j:Number = 0; j < clen; j++) {
				var element:Object = valueWithObjectForKeyPath(arr[j], ckeypath);

				if (element instanceof NSArray) {
					cret.addObjectsFromArray(NSArray(element));
				} else {
					cret.addObject(element);
				}
			}

			break;
		}

		return curObj;
	}

	/**
	 * Returns a dictionary indexed on each key in <code>keys</code> who's
	 * values are the result of {@link #valueForKey} on the key.
	 */
	public static function dictionaryWithObjectValueForKeys(anObject:Object,
			keys:NSArray):NSDictionary {
		var ret:NSDictionary = NSDictionary.dictionary();
		var arr:Array = keys.internalList();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			ret.setObjectForKey(valueWithObjectForKey(anObject, arr[i]), arr[i]);
		}

		return ret;
	}

	/**
	 * Returns an object containing a reference to the object and a reference
	 * to the setter method for <code>anObject</code> on
	 * <code>keyPath</code>. If no setter is found, this method will return
	 * the member variable that contains the value.
	 */
	public static function setterAndObjectWithObjectForKeyPath(anObject:Object,
			keyPath:String):Object {
		var parts:Array = keyPath.split(".");
		var len:Number = parts.length;
		var curObj:Object;

		//
		// Get the second to last element
		//
		if (len > 1) {
			curObj = valueWithObjectForKeyPath(anObject, parts.slice(0, -1).join("."));
		} else {
			curObj = anObject;
		}

		//
		// Create a standard style setter name
		//
		var varName:String = parts[len - 1];
		var setKeyName:String = "set" + varName.charAt(0).toUpperCase()
			+ varName.substr(1);

		//
		// Check if we're dealing with a flag property (starts with is, does or has)
		//
		var setFlagKeyName:String;
		var flagProperty:Boolean = false;
		if (varName.indexOf("is") == 0) {
			setFlagKeyName = "set" + varName.substr(2);
			flagProperty = true;
		}
// FIXME Make these alternates
//		else if (varName.indexOf("has") == 0) {
//			setFlagKeyName = "set" + varName.substr(3);
//			flagProperty = true;
//		}
//		else if (varName.indexOf("does") == 0) {
//			setFlagKeyName = "set" + varName.substr(4);
//			flagProperty = true;
//		}

		//
		// TODO How do I figure out if the key path represents one or more relationships?
		//
		if (ASUtils.isCollection(curObj)) {
			var arr:Object = ASUtils.extractArrayFromCollection(curObj);
			//
			// Return the selector if there is one.
			//
			if (ASUtils.respondsToSelector(arr[0], setKeyName)) {
				return {object: curObj, setter: arr[0][setKeyName],
					setterName: setKeyName};
			}
			else if (flagProperty && ASUtils.respondsToSelector(curObj, arr[0])) {
				return {object: curObj, setter: arr[0][setFlagKeyName],
					setterName: setFlagKeyName};
			}
			else if (arr[0][varName] != undefined) {
				return {object: curObj, setter: varName, setterName: varName};
			} else {
				return {object: curObj, setter: null};
			}
		}

		//
		// Return the selector if there is one.
		//
		if (ASUtils.respondsToSelector(curObj, setKeyName)) {
			return {object: curObj, setter: curObj[setKeyName],
				setterName: setKeyName};
		}
		else if (flagProperty && ASUtils.respondsToSelector(curObj, setFlagKeyName)) {
			return {object: curObj, setter: curObj[setFlagKeyName],
				setterName: setFlagKeyName};
		}
		else if (curObj[varName] != undefined) {
			return {object: curObj, setter: varName};
		} else {
			return {object: curObj, setter: null};
		}
	}

	//******************************************************
	//*                Setting values
	//******************************************************

	/**
	 * Sets the value for the property identified by <code>keyPath</code>
	 * in <code>anObject</code> to <code>value</code>.
	 */
	public static function setValueWithObjectForKeyPath(anObject:Object,
			value:Object, keyPath:String):Void {

		var objAndSetter:Object = setterAndObjectWithObjectForKeyPath(anObject,
			keyPath);

		//
		// Check for undefined key
		//
		if (objAndSetter.setter == null) {
			if (ASUtils.respondsToSelector(anObject, "setValueForUndefinedKey")) {
				anObject.setValueForUndefinedKey(value, keyPath);
			} else {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					"NSUndefinedKeyException",
					"There is no key on the object " + anObject + " named " + keyPath,
					null);
				trace(e);
				throw e;
			}
		}

		//
		// Deal with the case where the object we got back is a collection
		//
		var objects:Object;
		if (ASUtils.isCollection(objAndSetter.object)) {
			objects = ASUtils.extractArrayFromCollection(objAndSetter.object);
		} else {
			objects = [objAndSetter.object];
		}

		var len:Number = objects.length;
		for (var i:Number = 0; i < len; i++) {
			if (typeof(objAndSetter.setter) == "function") {
				objAndSetter.setter.call(objects[i], value);
			} else {
				objects[i][objAndSetter.setter] = value;
			}
		}
	}

	/**
	 * Sets the value for the property identified by <code>key</code>
	 * in <code>anObject</code> to <code>value</code>.
	 */
	public static function setValueWithObjectForKey(anObject:Object,
			value:Object, key:String):Void {
		setValueWithObjectForKeyPath(anObject, value, key);
	}

	//******************************************************
	//*             Set and array operators
	//******************************************************

	/**
	 * <p>Adds a set or array operator. <code>operator</code> must begin with
	 * a <code>@</code> and be followed with 1 or more characters.</p>
	 *
	 * <p>The <code>selector</code> method on <code>target</code> should have this
	 * method signature:</br>
	 * <pre>	selector(collection:Array, keyPath:String):Object</pre></p>
	 *
	 * <p>Throws an {@link NSException} if an operator named
	 * <code>operator</code> already exists, if target does not contain
	 * a method named selector, of if the operator does not use a
	 * <code>@</code> as its first character.</p>
	 */
	public static function addOperatorWithNameTargetSelector(operator:String,
			target:Object, selector:String):Void {

		//
		// @ check
		//
		if (operator == null
				|| operator.charAt(0) != "@"
				|| operator.length <= 1) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				operator + " is an invalid operator.",
				null);
			trace(e);
			throw e;
		}

		//
		// Unique check
		//
		if (g_operators[operator] != null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"An operator named " + operator + " already exists.",
				null);
			trace(e);
			throw e;
		}

		//
		// Selector check
		//
		if (!ASUtils.respondsToSelector(target, selector)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"The target " + target + " does not have a method named "
				+ selector,
				null);
			trace(e);
			throw e;
		}

		//
		// Add the operator
		//
		g_operators[operator] = {
			target: target,
			selector: selector};
	}

	/**
	 * Gets the operator named <code>operator</code>, or <code>null</code> if
	 * no such operator exists.
	 */
	public static function operatorWithName(operator:String):Object {
		if (operator.charAt(0) != "@") {
			return null;
		}

		return g_operators[operator];
	}


	/**
	 * Returns <code>true</code> if <code>part</code> is an operator.
	 */
	private static function isOperator(part:String):Boolean {
		return operatorWithName(part) != null;
	}

	/**
	 * Handler for the <code>@average</code> operator.
	 */
	private static function averageOperator(collection:Array,
			keyPath:String):Number {
		var cnt:Number = countOperator(collection, keyPath);
		var sum:Number = sumOperator(collection, keyPath);

		return sum / cnt;
	}

	/**
	 * Handles the <code>@count</code> operator.
	 */
	private static function countOperator(collection:Array,
			keyPath:String):Number {
		return collection.length;
	}

	/**
	 * Handles the <code>@distinctUnionOfArrays</code> operator.
	 */
	private static function distinctArrayUnionOperator(arr:Array,
			keyPath:String):NSArray {
		var contents:NSArray = arrayUnionOperator(arr, keyPath);
		var ret:NSArray = NSArray.array();

		arr = contents.internalList();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			if (ret.containsObject(arr[i])) {
				continue;
			}

			ret.addObject(arr[i]);
		}

		return ret;
	}

	/**
	 * Handles the <code>@distinctUnionOfObjects</code> operator.
	 */
	private static function distinctObjectUnionOperator(arr:Array,
			keyPath:String):NSArray {
		var contents:NSArray = objectUnionOperator(arr, keyPath);

		//
		// Fill the resultant array
		//
		var ret:NSArray = NSArray.array();
		arr = contents.internalList();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			if (ret.containsObject(arr[i])) {
				continue;
			}

			ret.addObject(arr[i]);
		}

		return ret;
	}

	/**
	 * Handles the <code>@maximum</code> operator.
	 */
	private static function maximumOperator(arr:Array, keyPath:String):Object {

		var contents:NSArray = distinctObjectUnionOperator(arr, keyPath);
		var sample:Object = contents.lastObject();
		var useCompare:Boolean = !(typeof(sample) == "number"
				|| typeof(sample) == "date"
				|| typeof(sample) == "string"
				|| sample instanceof Number
				|| sample instanceof String
				|| sample instanceof Date);

		var max:Object = null;

		arr = contents.internalList();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			var obj:Object = arr[i];

			if (max == null) {
				max = obj;
				continue;
			}

			if (useCompare) {
				max = max.compare(obj) == NSComparisonResult.NSOrderedAscending
					? obj : max;
			} else {
				max = obj > max ? obj : max;
			}
		}

		return max;
	}

	/**
	 * Handles the <code>@minimum</code> operator.
	 */
	private static function minimumOperator(arr:Array, keyPath:String):Object {
		var contents:NSArray = distinctObjectUnionOperator(arr, keyPath);
		var sample:Object = contents.lastObject();
		var useCompare:Boolean = !(typeof(sample) == "number"
				|| typeof(sample) == "date"
				|| typeof(sample) == "string"
				|| sample instanceof Number
				|| sample instanceof String
				|| sample instanceof Date);

		var min:Object = null;

		arr = contents.internalList();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			var obj:Object = arr[i];

			if (min == null) {
				min = obj;
				continue;
			}

			if (useCompare) {
				min = min.compare(obj) == NSComparisonResult.NSOrderedAscending
					? min : obj;
			} else {
				min = obj > min ? min : obj;
			}
		}

		return min;
	}

	/**
	 * Handles the <code>@sum</code> operator.
	 */
	private static function sumOperator(arr:Array, keyPath:String):Number {
		var contents:NSArray = objectUnionOperator(arr, keyPath);

		arr = contents.internalList();
		var len:Number = arr.length;
		var sum:Number = 0;

		for (var i:Number = 0; i < len; i++) {
			sum += arr[i];
		}

		return sum;
	}

	/**
	 * Handles the <code>@unionOfArrays</code> operator.
	 */
	private static function arrayUnionOperator(arr:Array, keyPath:String)
			:NSArray {
		var parts:Array = keyPath.split(".");
		var collections:NSArray = objectUnionOperator(arr, "");
		var newKeyPath:String = "";
		if (parts.length > 0) {
			newKeyPath = "." + keyPath;
		}
		var ret:NSArray = NSArray.array();
		arr = collections.internalList();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			var internal:Object = arr[i];
			var objects:NSArray = NSArray(valueWithObjectForKeyPath(
				internal, NSUnionOfObjectsKeyValueOperator + newKeyPath));
			ret.addObjectsFromArray(objects);
		}

		return ret;
	}

	/**
	 * Handles the <code>@unionOfObjects</code> operator.
	 */
	private static function objectUnionOperator(arr:Array, keyPath:String)
			:NSArray {
		//
		// Fill the return array
		//
		var ret:NSArray = NSArray.array();
		var len:Number = arr.length;

		for (var i:Number = 0; i < len; i++) {
			ret.addObject(valueWithObjectForKeyPath(arr[i], keyPath));
		}

		return ret;
	}

	//******************************************************
	//*               Class construction
	//******************************************************

	/**
	 * This method must be called to use key-value coding.
	 */
	private static function initialize():Void {
		if (g_classConstructed) {
			return;
		}

		//
		// Set up operators
		//
		var kvc:Function = NSKeyValueCoding;

		g_operators = {};
		addOperatorWithNameTargetSelector(NSAverageKeyValueOperator, kvc,
			"averageOperator");
		addOperatorWithNameTargetSelector(NSCountKeyValueOperator, kvc,
			"countOperator");
		addOperatorWithNameTargetSelector(NSDistinctUnionOfArraysKeyValueOperator, kvc,
			"distinctArrayUnionOperator");
		addOperatorWithNameTargetSelector(NSDistinctUnionOfObjectsKeyValueOperator, kvc,
			"distinctObjectUnionOperator");
		addOperatorWithNameTargetSelector(NSDistinctUnionOfSetsKeyValueOperator, kvc,
			"distinctObjectUnionOperator");
		addOperatorWithNameTargetSelector(NSMaximumKeyValueOperator, kvc,
			"maximumOperator");
		addOperatorWithNameTargetSelector(NSMinimumKeyValueOperator, kvc,
			"minimumOperator");
		addOperatorWithNameTargetSelector(NSSumKeyValueOperator, kvc,
			"sumOperator");
		addOperatorWithNameTargetSelector(NSUnionOfArraysKeyValueOperator, kvc,
			"arrayUnionOperator");
		addOperatorWithNameTargetSelector(NSUnionOfObjectsKeyValueOperator, kvc,
			"objectUnionOperator");
		addOperatorWithNameTargetSelector(NSUnionOfSetsKeyValueOperator, kvc,
			"objectUnionOperator");

		g_classConstructed = true;
	}

	private static var g_classConstructed:Boolean;
}