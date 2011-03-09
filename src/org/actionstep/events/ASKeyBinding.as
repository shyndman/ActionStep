/* See LICENSE for copyright and terms of use */

import org.actionstep.events.ASKeyBindingsTable;
import org.actionstep.NSResponder;

/**
 * <p>Describes how to interpret a single keystroke. It binds the keystroke to
 * the selector string of an action, or to a table of bindings which are used
 * to interpret the next keystroke for multiple-keystroke bindings.</p>
 * 
 * <p>Both <code>action</code> and <code>table</code> properties may be 
 * <code>null</code> if this binding is disabled, in which case it is 
 * ignored.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.events.ASKeyBinding {
	
	/** The code of the character this binding is associated with. */
	public var code:Number;
	
	/**
	 * The modifier for the binding. A combination of NSShiftKeyMask, 
	 * NSControlKeyMask, NSAlternateKeyMask and NSNumericPadKeyMask.
	 */ 
	public var modifiers:Number;
	
	/**
	 * An array of selector strings representing the actions associated with 
	 * this binding, or <code>null</code> if there are no associated actions.
	 */
	public var selectors:Array;
	
	/**
	 * A table of <code>ASKeyBinding</code>s used to interpret the next 
	 * keystroke, or <code>null</code> if this is a leaf.
	 */
	public var table:ASKeyBindingsTable;
	
	/**
	 * String representation of the key binding.
	 */
	public var description:String;
	
	/**
	 * Contains a map of used selector strings to prevent the addition of
	 * duplicates.
	 */
	private var m_usedSelectors:Object;
	
	/**
	 * Creates a new instance of the <code>ASKeyBinding</code> class.
	 */
	public function ASKeyBinding(code:Number, modifiers:Number,
			description:String) {
		this.code = code;
		this.modifiers = modifiers;
		this.description = description;
		this.selectors = [];
		m_usedSelectors = {};
	}
	
	/**
	 * Adds a selector to the binding.
	 */
	public function addSelector(selector:String):Void {
		//
		// Dup check
		//
		if (m_usedSelectors[selector] != null) {
			return;
		}
		
		selectors.push(selector);
		m_usedSelectors[selector] = true;
	}
	
	/**
	 * Invokes all actions on the object <code>obj</code> handled by this
	 * binding.
	 */
	public function performActionWithObject(obj:NSResponder):Void {
		var len:Number = selectors.length;
		if (selectors == null || len == 0) {
			return;
		} 
		
		for (var i:Number = 0; i < len; i++) {
			obj.doCommandBySelector(selectors[i]);
		}
	}
	
	/**
	 * Returns a string representation of the binding.
	 */
	public function toString() : String {
		var ret:String = "ASKeyBinding(selectors=[" + selectors + "]";
		if (table != null) {
			ret += ", table=" + table;
		}
		ret += ")";
		return ret;
	}
}