/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSObject;

/**
 * <p>This class contains data that the user has cut or copied.</p>
 * 
 * <p>It is used extensively for dragging operations.</p>
 * 
 * <p>TODO Get owner working.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSPasteboard extends NSObject 
{
	//******************************************************															 
	//*                 Pasteboard types
	//******************************************************
	
	public static var NSColorPboardType:String 			= "color";
	public static var NSObjectPboardType:String 		= "object";
	public static var NSViewPboardType:String			= "view";
	public static var NSFontPboardType:String 			= "font";
	public static var NSStringPboardType:String 		= "string";
	public static var NSTabularTextPboardType:String 	= "tabular";
	public static var NSImagePboardType:String 			= "image";
	
	//******************************************************															 
	//*                 Named pasteboards
	//******************************************************
	
	public static var NSGeneralPboard:String = "NSGeneralPboard";
	public static var NSDragPboard:String = "NSDragPboard";
	
	//******************************************************															 
	//*                  Class members
	//******************************************************
	
	private static var g_pasteBoards:NSDictionary;
	
	//******************************************************															 
	//*                 Member variables
	//******************************************************
	
	private var m_types:NSArray;
	private var m_dataForType:NSDictionary;
	private var m_owner:Object;
	private var m_name:String;
	private var m_changeCnt:Number;
	
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	/**
	 * Invoked by the static constructors. Do not touch.
	 */
	private function NSPasteboard()
	{
		m_types = NSArray.array();
		m_dataForType = NSDictionary.dictionary();
	}
	
	//******************************************************															 
	//*         Referring to a pasteboard by name
	//******************************************************
	
	/**
	 * Returns the name of the pasteboard.
	 */
	public function name():String
	{
		return m_name;
	}
	
	//******************************************************															 
	//*                  Writing data     
	//******************************************************
	
	/**
	 * Adds the types in <code>newTypes</code> with the <code>newOwner</code>.
	 * This method must follow a {@link #declareTypesOwner} call for 
	 * the same types.
	 */
	public function addTypesOwner(newTypes:NSArray, newOwner:Object):Number
	{
		m_owner = newOwner;
		
		var nt:Array = newTypes.internalList();
		var len:Number = nt.length;
		for (var i:Number = 0; i < len; i++)
		{
			if (!m_types.containsObject(nt[i]))
			{
				m_types.addObject(nt[i]);
			}
		}
		
		return m_changeCnt;
	}
	
	/**
	 * <p>This method prepares the pasteboard to add types with a new owner. It 
	 * must preced the {@link #addTypesOwner} call.</p>
	 * 
	 * <p>The <code>newTypes</code> argument is an array of strings. The owner
	 * <code>newOwner</code> is an object responsible for writing data to
	 * the pasteboard. When the data is requested to be written, the owner is
	 * sent a {@link #pasteboardProvideDataForType} message requesting the
	 * data for a particular type.</p>
	 * 
	 * <p><code>newOwner</code> can be <code>null</code> if data is provided for
	 * all types immediately.</p>
	 * 
	 * <p>This method returns the pasteboards new change count.</p> 
	 */
	public function declareTypesOwner(newTypes:NSArray, newOwner:Object):Number
	{
		// FIXME I'm really not sure what this should do...
		m_changeCnt += newTypes.count();
		return m_changeCnt;
	}
	
	/**
	 * <p>Sets <code>data</code> for the specified <code>dataType</code>. 
	 * <code>dataType</code> must be previously declared using 
	 * {@link #declareTypesOwner}.</p>
	 * 
	 * <p>Returns <code>true</code> if the data is successfully recorded, or
	 * <code>false</code> if it is not.</p>
	 */
	public function setDataForType(data:Object, dataType:String):Boolean
	{
		if (!m_types.containsObject(dataType)) {
			return false;
		}
		
		m_dataForType.setObjectForKey(data, dataType);
		return true;
	}
	
	/**
	 * Records <code>string</code> data for <code>dataType</code> using
	 * {@link #setDataForType}.
	 */
	public function setStringForType(string:String, dataType:String):Boolean
	{
		return setDataForType(string, dataType);
	}
	
	//******************************************************															 
	//*                 Determining types
	//******************************************************
	
	/**
	 * Scans <code>types</code> and returns the first type that matches a type 
	 * declared on the pasteboard.
	 */
	public function availableTypeFromArray(types:NSArray):String
	{
		var t:Array = types.internalList();
		var len:Number = t.length;
		for (var i:Number = 0; i < len; i++)
		{
			if (m_types.containsObject(t[i])) {
				return t[i];
			}
		}
		
		return null;
	}
	
	/**
	 * Returns an array of types declared for this pasteboard.
	 */
	public function types():NSArray
	{
		return m_types;
	}
	
	//******************************************************															 
	//*                  Reading data 
	//******************************************************
	
	/**
	 * Returns the pasteboard's change count.
	 */
	public function changeCount():Number
	{
		return m_changeCnt;
	}

	/**
	 * Returns the data contained by this pasteboard for the type 
	 * <code>dataType</code>. If no data exists, <code>null</code> is returned.
	 */	
	public function dataForType(dataType:String):Object
	{
		return m_dataForType.objectForKey(dataType);
	}
	
	/**
	 * Returns a string representation of the data contained by this 
	 * pasteboard for the type <code>dataType</code>. If no data exists,
	 * <code>null</code> is returned.
	 */
	public function stringForType(dataType:String):String
	{
		var data:Object = dataForType(dataType);
		
		if (data == null)
			return null;
			
		return data.toString();
	}
	
	//******************************************************															 
	//*                Static Constructors
	//******************************************************
	
	/**
	 * Returns the general pasteboard.
	 */
	public static function generalPasteboard():NSPasteboard
	{
		return pasteboardWithName(NSGeneralPboard);
	}
	
	/**
	 * Returns the pasteboard with the name <code>name</code>. If no pasteboard
	 * exists with the specified name, one is created.
	 */
	public static function pasteboardWithName(name:String):NSPasteboard
	{
		//
		// Create the pasteboard map if none exists.
		//
		if (g_pasteBoards == null) 
		{
			g_pasteBoards = NSDictionary.dictionary();
		}
		
		if (null == g_pasteBoards.objectForKey(name))
		{
			var pb:NSPasteboard = new NSPasteboard();
			pb.m_name = name;
			g_pasteBoards.setObjectForKey(pb, name);
		}
		
		return NSPasteboard(g_pasteBoards.objectForKey(name));
	}
}