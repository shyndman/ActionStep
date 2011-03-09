/* See LICENSE for copyright and terms of use */

/**
 * Common SOAP utility methods.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.ASSoapUtils {

	//******************************************************
	//*               Identification methods
	//******************************************************

	/**
	 * Returns <code>true</code> if the <code>response</code> XML represents
	 * a SOAP fault.
	 */
	public static function isFaultResponse(response:XML):Boolean {
		var insideBody:XMLNode = response.firstChild.firstChild.firstChild;
		return insideBody.nodeName == "soap:Fault";
	}

	//******************************************************
	//*                 Utility methods
	//******************************************************
	
	/**
	 * When given a node name formatted like "namespace:localName", a two 
	 * element array is returned. namespace in the first element, local name in
	 * the second element. If <code>name</code> contains no colon, the returned
	 * array contains nothing in the first element.
	 */
	public static function partsFromName(name:String):Array {
		if (name.indexOf(":") == -1) {
			return ["", name];
		}
		
		return name.split(":");
	}
	
	/**
	 * When given a node name formatted like "namespace:localName", the
	 * localName part of the name will be returned.
	 */
	public static function localPartFromName(name:String):String {
		var idx:Number = name.indexOf(":");
		if (idx == -1) {
			return name;
		}
		
		return name.substr(idx + 1);
	}
	
}