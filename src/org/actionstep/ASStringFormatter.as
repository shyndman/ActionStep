/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSEnumerator;
import org.actionstep.NSCalendarDate;

/**
 * This class provides methods to format strings.
 * 
 * FIXME Should adhere to <code>org.actionstep.NSFormatter</code>
 *
 * <p>Formatting information:</p>
 * <p>{@link http://www.cplusplus.com/ref/cstdio/printf.html }</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.ASStringFormatter 
{	
	private static var VARIABLE_CHAR:String = "%";
	private static var g_types:Object;
	
	/**
	 * This class is static. The private constructor prevents instances
	 * from being created.
	 */
	private function ASStringFormatter()
	{
	}
	
	//******************************************************															 
	//*              Public Static Methods
	//******************************************************
	
	/**
	 * <p>Composes a string provided a format string and an array of arguments
	 * to inject into the string.</p>
	 *
	 * <p>The format string is the same as C's printf.</p>
	 *
	 * <p>{@link http://www.cplusplus.com/ref/cstdio/printf.html }</p>
	 */
	public static function formatString(format:String, args:NSArray):String
	{
		var en:NSEnumerator = args.objectEnumerator();
		var arg:Object;
		var argstr:String;
		var idx:Number = 0;
		var end:Number;
		var char:String;
		var tag:String;
		var fstr:String;
		var flags:Array;
		var width:String;
		var precisionstart:Number;
		var precision:Number;
		
		while ((-1 != (idx = format.indexOf(VARIABLE_CHAR, idx))))
		{
			//
			// % sign is escaped, so continue
			//
			if (format.charAt(idx - 1) == "\\" && format.charAt(idx - 2) != "\\")
				continue;
					
			flags = [false, false, false, false, false]; // -, +, blank, #, "
			precision = precisionstart = undefined;
			width = undefined;
					
			//
			// walk forward until the type is found
			//
			end = idx;
			while (end++ < format.length)
			{
				char = format.charAt(end);

				//
				// Check if we're on a type character
				//
				if (isTypeCharacter(char))
					break;
									
				//
				// Check for special characters, i.e. flags and precision marking
				//
				switch (char)
				{
					case "-":
						flags[0] = true;
						continue;
						
					case "+":
						flags[1] = true;
						continue;
						
					case "b":
						if (format.substr(end, 5) == "blank")
						{
							flags[2] = true;
							end += 4;
							continue;
						}
						break;
						
					case "#":
						flags[3] = true;
						continue;
					
					case "\"":
						flags[4] = true;
						continue;
						
					case ".":
						precisionstart = end;
						continue;
				}
				
				//
				// Build up width
				//
				if (precisionstart == undefined && parseInt(char) != NaN)
				{
					if (width == undefined)
						width = char;
					else
						width += char; 
				}
			}  
			
			//
			// Can't format anymore once we've hit the end of the string
			//
			if (end == format.length)
				break;
			
			arg = en.nextObject(); // Get argument to format
			
			if (arg == null) // We can't do anything else if there are no more args.
				break;
				
			precision = parseInt(format.substring(precisionstart + 1, end)); // extract precision
			fstr = g_types[format.charAt(end)](flags, parseInt(width), width.charAt(0) == "0", precision, arg);
			
			if (flags[4]) // append quotes if flag is on
				fstr = "\"" + fstr + "\"";
				
			format = format.slice(0, idx) + fstr + format.slice(end + 1); // insert formatted text
			idx += fstr.length; // modify index to reflect inserted text
		}
		
		return format;
	}


	/**
	 * Returns whether a character should be handled by one of the handlers or not.
	 */
	private static function isTypeCharacter(char:String):Boolean
	{		
		return (g_types[char] != undefined);
	}
	
	//******************************************************															 
	//*                 Type handlers
	//******************************************************
	
	/**
	 * Returns an integer.
	 */
	private static function handleInteger(flags:Array, width:Number, zeroPad:Boolean, precision:Number, arg:Object):String
	{
		var intg:Number = parseInt(arg.toString());
		var str:String = String(intg);
		
		if (width == undefined || width == NaN)
			return str;
		
		if (width <= str.length)
			return str;
			
		var padchar:String = zeroPad ? "0" : " ";
		var diff:Number = width - str.length;
		
		for (var i:Number = 0; i < diff; i++)
		{
			str = padchar + str;
		}
		
		if (intg > 0)
		{
			if (flags[2])
				str = " " + str;
				
			if (flags[1])
				str = "+" + str;
		}
			
		return str;
	}

	
	/**
	 * Returns a float.
	 */
	private static function handleFloat(flags:Array, width:Number, zeroPad:Boolean, precision:Number, arg:Object):String
	{
		var flt:Number = parseFloat(arg.toString());
		var str:String = String(flt);
		var parts:Array = str.split(".");
		
		//
		// Apply width
		//
		if (width == undefined && width == NaN && width > parts[0].length)
		{
			var padchar:String = zeroPad ? "0" : " ";
			var diff:Number = width - parts[0].length;
			
			for (var i:Number = 0; i < diff; i++)
			{
				parts[0] = padchar + parts[0];
			}
		}
		
		//
		// Apply precision
		//
		if (parts[1] == undefined)
			parts[1] = "";
			
		if (precision == undefined || precision == NaN)
			precision = 6;
	
		if (precision > parts[1].length)
		{
			var diff:Number = precision - parts[1].length;
			
			for (var i:Number = 0; i < diff; i++)
			{
				parts[1] = parts[1] + " ";
			}
		}
		
		str = parts.join(".");
		
		//
		// Flag specific options
		//
		if (flt > 0)
		{
			if (flags[2])
				str = " " + str;
				
			if (flags[1])
				str = "+" + str;
		}
		
		return str;
	}

	
	/**
	 * Returns a number in scientific notation.
	 */
	private static function handleScientificNotation(flags:Array, width:Number, zeroPad:Boolean, precision:Number, arg:Object):String
	{
		//! implement
		return arg.toString();
	}
	
	
	/**
	 * Returns an octal (base-8) number.
	 */
	private static function handleOctal(flags:Array, width:Number, zeroPad:Boolean, precision:Number, arg:Object):String
	{
		var flt:Number = parseFloat(arg.toString());
		var str:String = flt.toString(8);
			
		var parts:Array = str.split(".");
		
		//
		// Apply width
		//
		if (width == undefined && width == NaN && width > parts[0].length)
		{
			var padchar:String = zeroPad ? "0" : " ";
			var diff:Number = width - parts[0].length;
			
			for (var i:Number = 0; i < diff; i++)
			{
				parts[0] = padchar + parts[0];
			}
		}
		
		//
		// Apply precision
		//
		if (parts[1] == undefined)
			parts[1] = "";
			
		if (precision == undefined || precision == NaN)
			precision = 6;
	
		if (precision > parts[1].length)
		{
			var diff:Number = precision - parts[1].length;
			
			for (var i:Number = 0; i < diff; i++)
			{
				parts[1] = parts[1] + " ";
			}
		}
		
		str = parts.join(".");
		
		if (flt != 0)
		{
			if (flags[3]) // Add leading 0 if applicable
				str = "0" + str;
		}
		
		if (flt > 0)
		{
			if (flags[2]) // leading space
				str = " " + str;
				
			if (flags[1]) // leading + sign
				str = "+" + str;
		}
					
		return str;
	}
	
	
	/**
	 * Returns a string.
	 */
	private static function handleString(flags:Array, width:Number, zeroPad:Boolean, precision:Number, arg:Object):String
	{
		var str:String = arg.toString();
		
		//
		// Padding
		//
		var padchar:String = zeroPad ? "0" : " ";
		var diff:Number = width - str.length;
		
		for (var i:Number = 0; i < diff; i++)
		{
			str = padchar + str;
		}
		
		//
		// Precision
		//
		if (precision != undefined && precision != NaN && str.length > precision)
		{
			str = str.substr(0, precision);
		}
		
		return str;
	}
	
	
	/**
	 * Returns a hexidecimal number (0x11abcd).
	 */
	private static function handleHex(flags:Array, width:Number, zeroPad:Boolean, precision:Number, arg:Object, upperCase:Boolean):String
	{
		if (upperCase == undefined)
			upperCase = false;
			
		var flt:Number = parseFloat(arg.toString());
		var str:String = flt.toString(16);
		
		//
		// Apply width
		//
		if (width == undefined && width == NaN && width > str.length)
		{
			var padchar:String = zeroPad ? "0" : " ";
			var diff:Number = width - str.length;
			
			for (var i:Number = 0; i < diff; i++)
			{
				str = padchar + str;
			}
		}
				
		if (flt != 0)
		{
			if (flags[3]) // Add leading 0x if applicable
				str = "0X" + str;
		}
		
		if (flt > 0)
		{
			if (flags[2]) // leading space
				str = " " + str;
				
			if (flags[1]) // leading + sign
				str = "+" + str;
		}
		
		if (!upperCase)
			str = str.toLowerCase();
			
		return str;
	}
	

	/**
	 * Returns a hexidecimal number with upper case letters.
	 */
	private static function handleHexUpperCase(flags:Array, width:Number, 
		zeroPad:Boolean, precision:Number, arg:Object):String
	{
		return handleHex(flags, width, zeroPad, precision, arg, true);		
	}
	

	/**
	 * Returns a toString() of the object.
	 */
	private static function handleObject(flags:Array, width:Number, zeroPad:Boolean, precision:Number, arg:Object):String
	{
		if (arg instanceof NSCalendarDate)
			return arg.descriptionWithLocale(null); // null = default locale
			
		return arg.toString();
	}


	/**
	 * Returns a percent sign.
	 */
	private static function handlePercent(flags:Array, width:Number, 
		zeroPad:Boolean, precision:Number, arg:Object):String
	{
		return "%";
	}
	
		
	//******************************************************															 
	//*               Static Constructor
	//******************************************************
	
	/**
	 * Runs when the application begins.
	 */
	private static function classConstruct():Boolean
	{
		if (classConstructed)
			return true;
				
		//
		// Create type mapping
		//
		g_types = new Object();
		g_types["d"] = 
		g_types["i"] = 
		g_types["D"] = 
		g_types["u"] = 
		g_types["U"] = 
		g_types["hi"] = 
		g_types["hu"] = 
		g_types["qi"] = 
		g_types["qu"] = handleInteger;
		g_types["f"] = handleFloat;
		g_types["o"] = handleOctal;
		g_types["s"] = handleString;
		g_types["x"] = handleHex;
		g_types["X"] = handleHexUpperCase;
		g_types["%"] = handlePercent;
		g_types["@"] = handleObject;
		
		return true;
	}
	
	private static var classConstructed:Boolean = classConstruct();
}
