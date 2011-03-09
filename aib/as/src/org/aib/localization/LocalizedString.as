/* See LICENSE for copyright and terms of use */

import org.aib.AIBObject;
import org.aib.AIBApplication;

/**
 * Represents a localized string. It has a string id, and it's toString() 
 * method returns the localized string. 
 * 
 * @author Scott Hyndman
 */
class org.aib.localization.LocalizedString extends AIBObject {
	
	private var m_stringId:String;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>LocalizedString</code> class.
	 */
	public function LocalizedString() {
	}
	
	//******************************************************
	//*              Setting the string id
	//******************************************************
	
	/**
	 * Returns the string ID.
	 */
	public function stringId():String {
		return m_stringId;
	}
	
	/**
	 * Sets the string ID to <code>id</code>.
	 */
	public function setStringId(id:String):Void {
		m_stringId = id;
	}
	
	//******************************************************
	//*           Getting the localized string
	//******************************************************
	
	/**
	 * Returns the localized string, according to {@link #stringId()}.
	 */
	public function toString():String {
		if (m_stringId == null) {
			return "String ID not set";
		}
		
		return AIBApplication.stringForKeyPath(m_stringId);
	}
}