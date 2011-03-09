/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlReader;
import org.actionstep.asml.ASParsingUtils;
import org.actionstep.asml.ASTagHandler;
import org.actionstep.constants.ASAsmlParsingMode;
import org.actionstep.NSException;
import org.actionstep.NSObject;

/**
 * <p>This class is used to handle <code>include</code> tags in the ASML file.</p>
 * 
 * <p>Include tags "include" external ASML files, and glues them together with 
 * their parent ASML files.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASIncludeTagHandler extends NSObject
	implements ASTagHandler
{
	/**
	 * Does nothing.
	 */
	public function addChildToParent(child:Object, parent:Object, 
		remainingChildAttributes:Object):Void 
	{
	}

	/**
	 * Starts the loading of a new ASML file, and returns a special object
	 * that represents the loading.
	 */
	public function parseNodeWithClassName(node:XMLNode, className:String)
		:Object 
	{
		var url:String = String(ASParsingUtils.extractTypedValueForAttributeKey(
			node.attributes, "src", true, null));
						
		//
		// Mark sure we have a url to load from, and if we don't, throw an
		// exception.
		//
		if (null == url)
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSMissingAttributeException",
				"include tags must contain src attributes.",
				null);
			trace(e);
			throw e;
		}
		
		//! FIXME Parsing mode shouldn't always be the same.
		var reader:ASAsmlReader = (new ASAsmlReader()).initWithUrlParsingMode(
			url, ASAsmlParsingMode.ASPartialObjects);
			
		return reader;
	}

}