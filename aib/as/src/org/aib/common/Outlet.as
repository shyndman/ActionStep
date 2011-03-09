/* See LICENSE for copyright and terms of use */

import org.aib.AIBObject;
import org.aib.common.ClassObject;

/**
 * @author Scott Hyndman
 */
class org.aib.common.Outlet extends AIBObject {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_name:String;
	private var m_type:ClassObject;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>Outlet</code> class.
	 */
	public function Outlet() {
	}
	
	public function initWithNameType(name:String, type:ClassObject):Outlet {
		m_name = name; 
		m_type = type;
		return this;
	}
}