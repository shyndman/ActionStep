/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.asml.ASReferenceProperty;
import org.actionstep.ASUtils;
import org.actionstep.constants.ASConstantValue;
import org.actionstep.NSColor;
import org.actionstep.NSColorList;
import org.actionstep.NSDate;
import org.actionstep.NSException;
import org.actionstep.NSRect;
import org.actionstep.themes.ASTheme;

/**
 * A number of handy utils for use by tag handlers. It includes methods for
 * extracting the object values of tag attributes, creation of objects, and
 * setting properties on objects.
 *
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASParsingUtils
{
	private static var ASColorIndicatorChar:String 		= "!";
	private static var ASObjectIdentifierChar:String	= "#";
	private static var ASStringWrapChar:String 			= "'";
	private static var ASSelectorChar:String			= ":";

	/**
	 * <p>Creates an instance of the <code>className</code> class, or, if
	 * <code>attributes</code> contains an <code>instanceOf</code> entry, use
	 * its value as the <code>className</code> instead.</p>
	 *
	 * <p><code>attributes</code> should be the attributes property of the
	 * <code>XMLNode</code> currently being parsed.</p>
	 *
	 * <p>If <code>instanceOf</code> is contained in <code>attributes</code>,
	 * it is removed from the dictionary by this method.</p>
	 *
	 * <p>This method will throw an {@link NSException} if the instance
	 * could not be created.</p>
	 */
	public static function createInstanceWithClassNameAttributes(
		className:String, attributes:Object):Object
	{
		if (null != attributes.instanceOf) {
			className = attributes.instanceOf;
			delete attributes.instanceOf;
		}

		var obj:Object = ASUtils.createInstanceOf(eval(className));

		//
		// Throw an exception if obj is null
		//
		if (null == obj)
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSClassNotFoundException",
				"The class " + className + " could not be found. Make sure it" +
				" is compiled into the swf.",
				null);
			trace(e);
			throw e;
		}

		return obj;
	}

	/**
	 *
	 *
	 * <p>This method returns an array of "reference" properties. i.e. Properties
	 * that is was unable to apply because they point to the references of
	 * other objects.</p>
	 *
	 * <p>The array contains instances of {@link ASReferenceProperty}.</p>
	 */
	public static function applyPropertiesToObjectWithAttributes(obj:Object,
		attributes:Object, removeUnusedAttributes:Boolean):Array
	{
		var ret:Array = [];
		var setter:String;
		var value:Object;

		for (var key:String in attributes)
		{
			value = extractTypedValueForAttributeKey(attributes, key, false);
			setter = "set" + key.charAt(0).toUpperCase() + key.substr(1);

			//
			// If this setter takes a reference to another object, record it
			// and continue.
			//
			if (value instanceof ASReferenceProperty)
			{
				ASReferenceProperty(value).setPropertyName(setter);
				ret.push(value);
				continue;
			}

			//
			// Call the setter if one exists.
			//
			if (undefined != obj[setter] && typeof(obj[setter]) == "function")
			{
				obj[setter](value);
				removeAttributeForKey(attributes, key);
			}
			else if (removeUnusedAttributes)
			{
				removeAttributeForKey(attributes, key);
			}
		}

		return ret;
	}

	/**
	 * <p>Given the {@link XMLNode} attributes dictionary <code>attributes</code>,
	 * this method will return an {@link NSRect} containing the x, y, width and
	 * height values found in the dictionary.</p>
	 *
	 * <p>If one or more of these values do not exist, <code>null</code> is
	 * returned.</p>
	 *
	 * <p>The x, y, width and height attributes are deleted from the dictionary
	 * if <code>remove</code> is <code>true</code>. This argument is optional,
	 * and if omitted will default to <code>false</code>.</p>
	 */
	public static function getFrameFromNodeAttributes(attributes:Object,
		remove:Boolean):NSRect
	{
		var x:Number, y:Number, w:Number, h:Number;

		//
		// Deal with width and height
		//
		if (null == attributes.width || null == attributes.height)
		{
			return null;
		}
		else
		{
			w = Number(attributes.width);
			h = Number(attributes.height);
		}

		//
		// Deal with x and y
		//
		if (null == attributes.x || null == attributes.y)
		{
			x = 0;
			y = 0;
		}
		else
		{
			x = Number(attributes.x);
			y = Number(attributes.y);
		}

		var ret:NSRect = new NSRect(x, y, w, h);

		//
		// Remove the attributes from the dictionary if asked to.
		//
		if (undefined != remove && remove)
		{
			delete attributes.x;
			delete attributes.y;
			delete attributes.width;
			delete attributes.height;
		}

		return ret;
	}

	/**
	 * Removes the <code>key</code> attribute from <code>attributes</code>.
	 */
	public static function removeAttributeForKey(attributes:Object, key:String)
		:Void
	{
		delete attributes.key;
	}

	/**
	 * <p>Extracts the typed value of <code>attributes[key]</code>. If
	 * the optional argument <code>remove</code> is <code>true</code>, the
	 * attribute <code>key</code> will be removed from <code>attributes</code>.</p>
	 *
	 * <p>If no attribute can be found associated with <code>key</code>, the
	 * <code>defaultValue</code> argument is returned.</p>
	 *
	 * <p>When omitted, <code>remove</code> defaults to <code>false</code>.</p>
	 */
	public static function extractTypedValueForAttributeKey(attributes:Object,
		key:String, remove:Boolean, defaultValue:Object):Object
	{
		var ret:Object = extractTypedValueFromString(attributes[key]);

		removeAttributeForKey(key);

		return ret == undefined ? defaultValue : ret;
	}

	/**
	 * <p>Given an attribute value string <code>string</code>, this method will
	 * extract a typed value. </p>
	 *
	 * <p>For example:
	 * <pre>
	 *   string = "'This is a string'"
	 *   return "This is a string" (String)
	 *
	 *   string = "true"
	 *   return true (Boolean)
	 *
	 *   string = "51.4"
	 *   return 51.4 (Number)</pre></p>
	 */
	public static function extractTypedValueFromString(string:String):Object
	{
		//
		// Handle null case
		//
		if (null == string) {
			return null;
		}

		//
		// String
		//
		if (string.charAt(0) == ASStringWrapChar
			&& string.charAt(string.length - 1) == ASStringWrapChar)
		{
			return string.substring(1, string.length - 1);
		}

		//
		// Boolean
		//
		var lower:String = string.toLowerCase();
		if (lower == "true") {
			return true;
		}
		else if (lower == "false") {
			return false;
		}

		//
		// Number
		//
		var num:Number;
		if (!isNaN(num = Number(string))) {
			return num;
		}

		//
		// Date (dd/mm/yyyy[ hh[:mm[:ss[:mmmm]]]])
		//
		if (-1 != string.indexOf("/"))
		{
			var parts:Array = string.split(" ");
			var date:Array = parts[0].split("/");
			var time:Array = parts[1].split(":");

			var dt:Date = new Date(Number(date[2]), Number(date[1]),
				Number(date[0]));

			if (null != time && time.length > 0)
			{
				dt.setHours(Number(time[0]));

				if (time.length > 1)
				{
					dt.setMinutes(Number(time[1]));

					if (time.length > 2)
					{
						dt.setSeconds(Number(time[2]));

						if (time.length > 3) {
							dt.setMilliseconds(Number(time[3]));
						}
					}
				}
			}

			return NSDate.dateWithDate(dt);
		}

		//
		// Colour (NSColor)
		//
		if (string.charAt(0).toLowerCase() == ASColorIndicatorChar)
		{
			var colour:String = string.substring(1);

			//
			// Colour value
			//
			if (!isNaN(Number(colour))) {
				return new NSColor(Number(colour));
			}

			var c:NSColor;
			var hasColourOnList:Boolean = false;

			//
			// Colour on named colour list
			//
			if (-1 != colour.indexOf("."))
			{
				var parts:Array = colour.split(".");
				var cl:NSColorList = NSColorList.colorListNamed(parts[0]);

				if (null != cl)
				{
					c = cl.colorWithKey(parts[1]);

					if (null != c) {
						hasColourOnList = true;
					}
				}
			}

			//
			// Return a colour based on contents.
			//
			if (null != ASTheme.current().colors().colorWithKey(colour))
			{
				return ASTheme.current().colors().colorWithKey(colour);
			}
			else if (hasColourOnList)
			{
				return c;
			}
			else if (ASUtils.respondsToSelector(NSColor, colour + "Color"))
			{
				return NSColor[colour + "Color"]();
			}
			else if (ASUtils.respondsToSelector(ASColors, colour + "Color"))
			{
				return ASColors[colour + "Color"]();
			}
			else
			{
				return null;
			}
		}

		//
		// Object ID
		//
		if (string.charAt(0) == ASObjectIdentifierChar)
		{
			var propRef:ASReferenceProperty = new ASReferenceProperty();
			propRef.setID(string.substr(1));
			return propRef;
		}

		//
		// Selector
		//
		if (string.charAt(string.length - 1) == ASSelectorChar)
		{
			return string.substring(0, string.length - 1);
		}

		//
		// Detect the constant type
		//
		if (string.indexOf("|") == -1
				&& string.indexOf("&") == -1
				&& string.indexOf("^") == -1
				&& string.indexOf("~") == -1) {
			return parseConstant(string);	
		}
		
		//
		// Parse ANDs
		//
		var andVal:Number = null;
		var ands:Array = string.split("&");
		var andlen:Number = ands.length;
		
		for (var i:Number = 0; i < andlen; i++) {
			//
			// Parse XORs
			//
			var xorVal:Number = null;
			var xors:Array = ands[i].split("^");			
			var xorlen:Number = xors.length;
			
			for (var j:Number = 0; j < xorlen; j++) {
				//
				// Parse ORs
				//
				var orVal:Number = null;
				var ors:Array = xors[j].split("|");
				var orlen:Number = ors.length;
				
				for (var k:Number = 0; k < orlen; k++) {
					//
					// Parse the string
					//					
					var cnstString:String = ASUtils.trimString(ors[k]);
					var cnst:Object;
					var negate:Boolean = false;
					if (cnstString.charAt(0) == "~") {
						negate = true;
						cnstString = cnstString.substr(1);
					}
					
					//
					// Extract the constant value
					//
					cnst = parseConstant(cnstString);
					if (cnst == null) {
						var e:NSException = NSException.exceptionWithNameReasonUserInfo(
							"ASAsmlParseException",
							"The constant " + cnstString + " could not be " + 
							"resolved to a value.",
							null);
						trace(e);
						throw e;
					}
					
					if (cnst instanceof ASConstantValue)
					{
						cnst = cnst.valueOf();
					}
					
					//
					// Negate if necessary
					//
					if (negate) {
						cnst = ~Number(cnst);
					}

					//
					// Perform OR op
					//					
					if (orVal == null) {
						orVal = Number(cnst);
					} else {
						orVal |= Number(cnst);
					}
				}
				
				//
				// Perform XOR op
				// 
				if (xorVal == null) {
					xorVal = orVal;
				} else {
					xorVal ^= orVal;
				}
			}
			
			//
			// Perform AND op
			//
			if (andVal == null) {
				andVal = xorVal;
			} else {
				andVal &= xorVal;
			}
		}

		return andVal;
	}
	
	/**
	 * Returns the value of a constant given a constant string.
	 */
	private static function parseConstant(constString:String):Object {
		if (constString.indexOf("org.actionstep.") != 0
			&& eval("org.actionstep." + constString) != undefined)
		{
			constString = "org.actionstep." + constString;
		}
		else if (constString.indexOf("org.actionstep.constants.") != 0
			&& eval("org.actionstep.constants." + constString) != undefined)
		{
			constString = "org.actionstep.constants." + constString;
		}
		
		return eval(constString) == undefined ? 0 : eval(constString);
	}
}