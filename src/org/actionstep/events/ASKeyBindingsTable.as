/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;
import org.actionstep.NSDictionary;
import org.actionstep.events.ASKeyBinding;
import org.actionstep.NSEvent;
import org.actionstep.NSEnumerator;
import org.actionstep.ASUtils;
import org.actionstep.NSUserDefaults;

/**
 * <p>This class is responsible for managing a table of keybindings (that is, a 
 * table of <code>ASKeyBinding</code> objects).  It can add and remove them, 
 * and it can look up a keystroke into the table, and return the associated 
 * action, or a <code>ASKeyBindingTable</code> object which can be used to 
 * process further keystrokes, for multi-stroke keybindings.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.events.ASKeyBindingsTable extends NSObject {
	
	//******************************************************
	//*                  Class members
	//******************************************************
	
	/**
	 * A dictionary of names to character codes. The keys are descriptive
	 * character names.
	 */
	private static var g_charTable:Object;

	/**
	 * A dictionary of character codes to names.
	 */	
	private static var g_codeTable:Object;
	
	/**
	 * The table of default application bindings.
	 */
	private static var g_defaultBindings:ASKeyBindingsTable;
	
	/**
	 * Holds the key > action bindings
	 */
	private var m_bindings:NSDictionary;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASKeyBindingsTable</code> class.
	 */
	public function ASKeyBindingsTable() {
	}
	
	/**
	 * Initializes the bindings table.
	 */
	public function init():ASKeyBindingsTable {
		super.init();
		m_bindings = NSDictionary.dictionary();
		return this;
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the ASKeyBindingsTable instance.
	 */
	public function description():String {
		return "ASKeyBindingsTable(bindingsCount=" + bindingsCount() + 
			", bindings=" + m_bindings.description() + ")";
	}
	
	//******************************************************
	//*         Getting information about bindings
	//******************************************************
	
	/**
	 * Returns the number of bindings in the table.
	 */
	public function bindingsCount():Number {
		return m_bindings.count();
	}
	
	//******************************************************
	//*                Managing bindings
	//******************************************************
	
	/**
	 * Loads all bindings from the dictionary <code>dict</code>. The
	 * dictionary binds keys to action selector strings, as seen in
	 * {@link #bindKeyToAction()}
	 */
	public function loadBindingsFromDictionary(dict:NSDictionary):Void {
		var e:NSEnumerator = dict.keyEnumerator();
		var key:String;
		
		while ((key = e.nextObject().toString()) != null) {
			bindKeyToAction(key, dict.objectForKey(key));
		}
	}
	
	/**
	 * <p>Binds a specific key (a string representation of a keystroke) to
	 * a specific action, which can be a string for a selector, an array
	 * of strings for an array of selectors or a dictionary if the key is just 
	 * the prefix to a further array of keybindings.</p>
	 * 
	 * <p><strong>Keystroke strings:</strong></p>
	 * <p>
	 * Keystroke strings are composed of one or more modifier strings, 
	 * followed by a single, lowercase character. The list of modifiers is
	 * hyphen ("-") separated, and must be separated from the character with
	 * a hyphen as well.
	 * </p>
	 * <p>
	 * The modifier list must be composed of the following values:<br/>
	 * Control,Ctrl,C - Represents the control key (or command key on Mac)<br/>
	 * Alternate,Alt,A - Represents the alternate key<br/>
	 * Shift,S - Represents the shift key<br/>
	 * NumericPad,NumPad,Numeric,N - Represents the keys in the numeric pad<br/>
	 * </p>
	 */
	public function bindKeyToAction(key:String, action:Object):Void {
		//
		// Get the parts of the key
		//
		var parts:Object = parseKeyIntoParts(key);
		if (parts == null) {
			trace(asWarning("Could not bind to key " + key));
			return;
		}
		
		//
		// Interpret the action
		//
		var type:Number = 0; // 0 - string, 1 - array, 2 - dictionary
		if (ASUtils.isString(action)) {
			type = 0;
		}
		else if (ASUtils.isCollection(action)) {
			type = 1;
		} 
		else if (action instanceof NSDictionary) {
			type = 2;
		} else {
			trace(asWarning("Unrecognized action type " + key));
			return;
		}
		
		//
		// Get the entry
		//
		var entry:ASKeyBinding = ASKeyBinding(m_bindings.objectForKey(
			parts.name));
		if (entry == null) {
			entry = new ASKeyBinding(parts.code, parts.modifiers, parts.name);
		}
		
		//
		// Add information to the entry appropriate to the action type
		//
		switch (type) {
			case 0: // string action
				entry.addSelector(action.toString());
				break;
				
			case 1: // collection of selectors
				var sels:Object = ASUtils.extractArrayFromCollection(action);
				var len:Number = sels.length;
				for (var i:Number = 0; i < len; i++) {
					entry.addSelector(sels[i]);
				}
				break;
				
			case 2: // dictionary representing multi-keystrokes
				if (entry.table == null) {
					entry.table = (new ASKeyBindingsTable()).init();
				}
				
				entry.table.loadBindingsFromDictionary(NSDictionary(action));
				break;
		}
		
		m_bindings.setObjectForKey(entry, entry.description);
	}
	
	/**
	 * <p>Returns the key binding object associated with <code>key</code>
	 * and <code>modifiers</code>.</p>
	 * 
	 * <p>If no key binding exists, <code>null</code> is returned.</p>
	 */
	public function keyBindingForStrokeModifiers(key:String, 
			modifiers:Number):ASKeyBinding {
		var k:String = descriptionFromCharModifiers(key.toLowerCase(), modifiers);
		return ASKeyBinding(m_bindings.objectForKey(k));
	}

	/**
	 * <p>Returns the key binding object associated with <code>code</code>
	 * and <code>modifiers</code>.</p>
	 * 
	 * <p>If no key binding exists, <code>null</code> is returned.</p>
	 */	
	public function keyBindingForCodeModifiers(code:Number,
			modifiers:Number):ASKeyBinding {
		var k:String = descriptionFromCharModifiers(g_codeTable[code + ""], 
			modifiers);
		return ASKeyBinding(m_bindings.objectForKey(k));
	}
	
	//******************************************************
	//*                    Key parsing
	//******************************************************
	
	/**
	 * <p>Parses a key string and returns an object formatted as follows:</p>
	 * <p><code>{name:String, code:Number, modifiers:Number}</code></p>
	 * <p>If the key cannot be interpreted, <code>null</code> is returned.</p>
	 */
	public function parseKeyIntoParts(key:String):Object {
		
		var code:Number;
		var name:String;
		var mods:Number = 0;
		var parts:Array = key.split("-");
		var numParts:Number = parts.length;
				
		//
		// Parse modifiers
		//
		for (var i:Number = 0; i < numParts - 1; i++) {
			var mod:String = parts[i];
			
			switch (mod.toLowerCase()) {
				case "control":
				case "ctrl":
				case "c":
					mods |= NSEvent.NSControlKeyMask;
					break;
					
				case "alternate":
				case "alt":
				case "a":
					mods |= NSEvent.NSAlternateKeyMask;
					break;
					
				case "shift":
				case "s":
					mods |= NSEvent.NSShiftKeyMask;
					break;
					
				case "numericpad":
				case "numpad":
				case "numeric":
				case "n":
					mods |= NSEvent.NSNumericPadKeyMask;
					break;
					
				default:
					trace(asWarning("Unrecognized modifier " + mod));
					return null;

			}
		}
		
		//
		// Parse key
		//
		name = parts[numParts - 1].toLowerCase();
		
		if (name.length == 0) { // key was "-"
			name = "-";
			code = name.charCodeAt(0);
		}
		else if (name.length == 1) {
			code = name.charCodeAt(0);
		} else { // descriptive name
			if (g_charTable[name] == null) {
				trace(asWarning("Unrecognized key"));
				return null;
			}
			
			code = g_charTable[name];
		}
		
		name = descriptionFromCharModifiers(name, mods);
				
		return {name: name, code: code, modifiers: mods};
	}
	
	/**
	 * Returns a descriptive name given a character and a modifier number.
	 */
	public function descriptionFromCharModifiers(character:String, 
			modifiers:Number):String {
		var name:String = character;
		
		//
		// Build up name
		//
		if (modifiers & NSEvent.NSControlKeyMask) {
			name = "control-" + name;
		}
		
		if (modifiers & NSEvent.NSAlternateKeyMask) {
			name = "alternate-" + name;
		}
		
		if (modifiers & NSEvent.NSShiftKeyMask) {
			name = "shift-" + name;
		}
		
		if (modifiers & NSEvent.NSNumericPadKeyMask) {
			name = "numericpad-" + name;
		}
		
		return name;
	}
	
	//******************************************************
	//*         Getting the default bindings table
	//******************************************************
	
	/**
	 * <p>Returns the table of default bindings.</p>
	 * 
	 * <p>Please note that {@link org.actionstep.NSApplication#run()} must be
	 * called prior to this method, as it performs necessary set up.</p>
	 * 
	 * The default bindings are obtained 
	 */
	public static function defaultBindings():ASKeyBindingsTable {
		if (g_defaultBindings == null) {
			g_defaultBindings = (new ASKeyBindingsTable()).init();
			g_defaultBindings.loadBindingsFromDictionary(
				NSUserDefaults.standardUserDefaults().dictionaryForKey(
					NSUserDefaults.NSDefaultBindings));
		}
		
		return g_defaultBindings;
	}
	
	//******************************************************
	//*                Static construction
	//******************************************************
	
	/**
	 * Responsible for building the named character table.
	 */
	private static function initialize():Void {
		g_charTable = {};
		
		g_charTable["uparrow"] = NSUpArrowFunctionKey;
		g_charTable["downarrow"] = NSDownArrowFunctionKey;
		g_charTable["leftarrow"] = NSLeftArrowFunctionKey;
		g_charTable["rightarrow"] = NSRightArrowFunctionKey;
		g_charTable["insert"] = Key.INSERT;
		g_charTable["delete"] = Key.DELETEKEY;
		g_charTable["home"] = Key.HOME;
		g_charTable["end"] = Key.END;
		g_charTable["pageup"] = Key.PGUP;
		g_charTable["pagedown"] = Key.PGDN;
		g_charTable["scrolllock"] = 145;
		g_charTable["pause"] = 19;
		g_charTable["break"] = 19;
		g_charTable["backspace"] = Key.BACKSPACE;
		
		g_codeTable = {};
		
		g_codeTable[NSUpArrowFunctionKey + ""] = "uparrow";
		g_codeTable[NSDownArrowFunctionKey + ""] = "downarrow";
		g_codeTable[NSLeftArrowFunctionKey + ""] = "leftarrow";
		g_codeTable[NSRightArrowFunctionKey + ""] = "rightarrow";
		g_codeTable[Key.INSERT + ""] = "insert";
		g_codeTable[Key.DELETEKEY + ""] = "delete";
		g_codeTable[Key.HOME + ""] = "home";
		g_codeTable[Key.END + ""] = "end";
		g_codeTable[Key.PGUP + ""] = "pageup";
		g_codeTable[Key.PGDN + ""] = "pagedown";
		g_codeTable[145 + ""] = "scrolllock";
		g_codeTable[19 + ""] = "pause";
		g_codeTable[19 + ""] = "break";
		g_codeTable[Key.BACKSPACE + ""] = "backspace";
	}
}