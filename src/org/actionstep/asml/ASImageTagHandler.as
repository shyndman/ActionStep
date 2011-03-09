/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASParsingUtils;
import org.actionstep.asml.ASTagHandler;
import org.actionstep.ASSymbolImageRep;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSImage;
import org.actionstep.NSImageRep;
import org.actionstep.NSObject;
import org.actionstep.NSRect;
import org.actionstep.NSSize;

/**
 * <p>Handles the <code>image</code> tag, which exists under a theme tag.</p>
 * 
 * <p>An <code>image</code> tag represents a named {@link NSImage}.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASImageTagHandler extends NSObject 
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
	 * <p>Creates an {@link NSImage} object from the XML node, then packages it 
	 * into a simple object ({@link Object}), containing two properties:
	 * <ul><li>
	 * "image":{@link NSImage}
	 * </li><li>
	 * "name":{@link String}
	 * </li></ul></p>
	 */
	public function parseNodeWithClassName(node:XMLNode, className:String)
		:Object {
		
		var image:NSImage;
		var atts:Object = node.attributes;
		
		//
		// Get the name of the image, and validate it.
		//
		var name:String = String(ASParsingUtils.extractTypedValueForAttributeKey(
			atts, "name", true, ""));
					
		if (name.length == 0) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSMissingAttributeException",
				"An image tag must contain a name attribute.",
				NSDictionary.dictionaryWithObjectForKey(node, "node"));
			trace(e);
			throw e;
		}
			
		//
		// Get the size of the image.
		//
		var sz:NSSize = null;
		var frm:NSRect = ASParsingUtils.getFrameFromNodeAttributes(atts, true);		

		if (null != frm) {
			sz = frm.size;
		}
		
		//
		// Create the image
		//
		image = new NSImage();
		image.setName(name);
		if (null != sz) 
		{
			image.setSize(sz);
		}
		
		//
		// Determine what type of image representation we should use, then
		// build the image.
		//
		var src:String = ASParsingUtils.extractTypedValueForAttributeKey(
			atts, "src", true, null).toString();
		var linkage:String = ASParsingUtils.extractTypedValueForAttributeKey(
			atts, "linkageName", true, null).toString();
		
		if (null != src)
		{
			image.initWithContentsOfURL(src);
		}
		else if (null != linkage)
		{
			var rep:NSImageRep = new ASSymbolImageRep(linkage, sz);
			image.addRepresentation(rep);
		}
		else // Can't create image without src or linkageName
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSMissingAttributeException",
				"An image tag must contain either a src or linkageName attribute.",
				NSDictionary.dictionaryWithObjectForKey(node, "node"));
			trace(e);
			throw e;
		}
		
		//
		// Apply remaining attributes and return.
		//
		ASParsingUtils.applyPropertiesToObjectWithAttributes(image, atts, true);
		
		return {image: image, name: name};
	}
}