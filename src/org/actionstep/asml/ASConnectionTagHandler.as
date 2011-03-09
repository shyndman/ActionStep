/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlReader;
import org.actionstep.asml.ASInstanceTagHandler;
import org.actionstep.asml.ASParsingUtils;

/**
 * Handles <code>connection</code> tags.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASConnectionTagHandler extends ASInstanceTagHandler {

	/**
	 * Creates a new instance of the <code>ASConnectionTagHandler</code>
	 * class.
	 */
	public function ASConnectionTagHandler(reader:ASAsmlReader) {
		super(reader);
	}
	
	/**
	 * Override to create the connector.
	 */
	private function initializeObject(obj:Object, node:XMLNode):Void {
		var url:Object = ASParsingUtils.extractTypedValueForAttributeKey(
			node.attributes, "URL", true, null);
			
		if (url == null) {
			obj.init();
		} else {
			obj.initWithURL(url.toString());
		}	
	}
}