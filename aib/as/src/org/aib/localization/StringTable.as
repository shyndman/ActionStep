/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.ASUtils;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSNotificationCenter;
import org.aib.AIBObject;
import org.aib.localization.LocalizedString;

/**
 * <p>A table of application strings.</p>
 * <p>
 * These strings are typically possess hierarchical keys. As an example, let's
 * say a palette named Foo. The palette's name string might be named
 * <code>"Palettes.Foo.Name"</code>.
 * </p>
 * <p>	
 * The string table can return the contents of any level in this hierarchy. If
 * I wanted to get all the strings for the Foo palette, I would call
 * <code>#stringGroupForKeyPath("Palettes.Foo")</code>. A string table of these
 * strings would be returned.
 * </p>
 * 
 * @author Scott Hyndman
 */
class org.aib.localization.StringTable extends AIBObject {
	
	//******************************************************															 
	//*                    Constants
	//******************************************************
	
	private static var AIB_GROUP_TAG:String 	= "group";
	private static var AIB_STRING_TAG:String 	= "string";
	private static var AIB_NAME_ATTR:String		= "name";
	private static var AIB_VALUE_ATTR:String	= "value";
	
	//******************************************************															 
	//*                     Members
	//******************************************************
	
	private var m_strings:NSDictionary;
	private var m_xml:XML;
	private var m_url:String;
	private var m_locStr:LocalizedString;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>StringTable</code> class.
	 */
	public function StringTable() {
	}
	
	/**
	 * Default initializer for the string table.
	 */
	public function init():StringTable {
		super.init();
		m_strings = NSDictionary.dictionary();
		return this;
	}
	
	/**
	 * Initializes the string table with the contents of an external string
	 * table that can be found at <code>url</code>.
	 * 
	 * When the string table is loaded, an 
	 * <code>StringTableDidLoadNotification</code> is posted to the default
	 * notification center.
	 */
	public function initWithContentsOfURL(url:String):StringTable {
		init();
		
		//
		// Set up the loading operation and begin loading
		//
		m_url = url;
		m_xml = new XML();
		m_xml.ignoreWhite = true;
		beginLoading();
		
		return this;
	}
	
	//******************************************************															 
	//*                Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the <code>StringTable</code> instance.
	 */
	public function description():String {
		return "StringTable(contents=" + m_strings.description() + ")";
	}
	
	//******************************************************															 
	//*                  Getting strings
	//******************************************************
	
	/**
	 * Returns the string associated with the key path <code>keyPath</code>, 
	 * or <code>null</code> if the string does not exist, or the value returned
	 * from that key path is a dictionary.
	 */
	public function stringForKeyPath(keyPath:String):String {
		var obj:Object = m_strings.objectForKey(keyPath.toLowerCase());
		
		//
		// Make sure obj isn't an NSDictionary
		//
		if (obj == null || obj instanceof NSDictionary) {
			return null;
		}
		
		return obj.toString();
	}
	
	//******************************************************
	//*           Getting the internal dictionary
	//******************************************************
	
	/**
	 * Returns the dictionary used internally by the string table.
	 */
	public function internalDictionary():NSDictionary {
		return m_strings;
	}
	
	//******************************************************															 
	//*     Loading and parsing external string tables
	//******************************************************
	
	/**
	 * Begins loading the external string table.
	 */
	private function beginLoading():Void
	{
		var self:StringTable = this;
		
		m_xml.load(m_url);
		m_xml.onLoad = function(success:Boolean) {
			self["stringFileDidLoad"](success);
		};
	}
	
	/**
	 * Handler invoked when the string file finishes loading.
	 */
	private function stringFileDidLoad(success:Boolean):Void
	{
		try
		{				
			// TODO how should we handle failure?
			if (success)
			{
				parseStringFile();
			}
			
			//
			// Post an ASAsmlFileDidLoadNotification notification to the 
			// default notification center.
			//
			NSNotificationCenter.defaultCenter().postNotificationWithNameObjectUserInfo(
				StringTableDidLoadNotification,
				this,
				NSDictionary.dictionaryWithObjectForKey(success, "AIBSuccess"));
		}
		catch (e:NSException)
		{
			trace(e.toString());
		}
	}
	
	/**
	 * Parses the string file after loading is complete.
	 */
	private function parseStringFile():Void {
		var rootNode:XMLNode = m_xml.firstChild;
		parseNodeWithPrefix(rootNode, "");
	}
	
	/**
	 * Parses a single string group node.
	 */
	private function parseNodeWithPrefix(node:XMLNode, prefix:String)
			:Void {
		var children:Array = node.childNodes;
		var len:Number = children.length;
		
		//
		// Loop through the children adding strings and groups as necessary
		//
		for (var i:Number = 0; i < len; i++) {
			var c:XMLNode = XMLNode(children[i]);
			var cName:String = c.nodeName.toLowerCase();
			
			//
			// Continue on null nodeName (probably whitespace)
			//
			if (null == cName) {
				continue;
			}
			
			//
			// Get the string / group name (the same attribute in both cases)
			//
			var sName:String = c.attributes[AIB_NAME_ATTR].toLowerCase();
			
			//
			// Log warning if no name is found, and continue
			//
			if (sName == null) {
				trace("Could not process the xml node " + ASDebugger.dump(c)
					+ " from the file at the URL " + m_url,
					ASDebugger.WARNING);
				continue;
			}
			
			//
			// Parse out either a string or a group
			//
			switch (cName) {
				case AIB_GROUP_TAG: // string group
					parseNodeWithPrefix(c, prefix + sName + ".");
					break;
					
				case AIB_STRING_TAG: // a string
					var val:String = c.attributes[AIB_VALUE_ATTR];
					
					//
					// Use an empty string if no value is specified.
					//
					if (val == null) {
						val = "";
					}
					
					m_strings.setObjectForKey(val, prefix + sName);
					
					break;
			}
		}
	}
	
	//******************************************************															 
	//*                  Notifications
	//******************************************************
	
	/**
	 * Fired when an external string table finishes loading, or an error is
	 * encountered during the load.
	 * 
	 * The userInfo dictionary contains the following:
	 * 	"AIBSuccess" - <code>true</code> if the load was successful (Boolean)
	 */
	public static var StringTableDidLoadNotification:Number
		= ASUtils.intern("StringTableDidLoadNotification");
}