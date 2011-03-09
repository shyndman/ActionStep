/* See LICENSE for copyright and terms of use */

import org.actionstep.NSDictionary;

/**
 * Implemented by classes that require more specific XML serialization.
 *
 * @author Scott Hyndman
 */
interface org.actionstep.rpc.xmlrpc.ASXmlRpcSerializable {

	/**
	 * Returns a string representing the name of this object's class.
	 */
	public function serializableClassName():String;

	/**
	 * Returns an NSDictionary of objects representing the fields in the object
	 * that should be serialized. The dictionary's values should be objects
	 * structured as follows:
	 *
	 * {type:ASXmlDataType}
	 */
	public function serializableFields():NSDictionary;
}