/* See LICENSE for copyright and terms of use */

import org.aib.inspector.InspectorProtocol;

/**
 * This interface must be implemented by all "editable" objects.
 * 
 * @author Scott Hyndman
 */
interface org.aib.EditableObjectProtocol {
	
	/**
	 * Returns the full class name of the object.
	 */
	function className():String;
	
	/**
	 * Returns <code>true</code> if this object supports the inspector 
	 * <code>inspector</code>.
	 */
	function supportsInspector(inspector:InspectorProtocol):Boolean;
}