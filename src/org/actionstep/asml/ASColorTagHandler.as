/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASParsingUtils;
import org.actionstep.asml.ASTagHandler;
import org.actionstep.NSColor;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSObject;

/**
 * Handles the <code>color</code> tag, which exists under a <code>theme</code> 
 * tag.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASColorTagHandler extends NSObject 
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
	 * <p>Creates an {@link NSColor} object from the XML node, then packages it 
	 * into a simple object ({@link Object}), containing two properties:
	 * <ul><li>
	 * "color":{@link NSColor}
	 * </li><li>
	 * "name":{@link String}
	 * </li></ul></p>
	 */
	public function parseNodeWithClassName(node:XMLNode, className:String)
		:Object {
		
		var color:NSColor;
		var alpha:Number;
		var atts:Object = node.attributes;
		
		//
		// This number specifies how the color will be created.
		//		1 - With a hex color value (and maybe an alpha)
		//		2 - With rgb values (and maybe an alpha)
		//		3 - With grayscale value (and maybe an alpha)
		//
		var colorCreationMode:Number;
		
		//
		// Make sure color has a name (this is a required field)
		//
		if (null == atts.name) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSMissingAttributeException",
				"A color tag must contain a name attribute.",
				NSDictionary.dictionaryWithObjectForKey(node, "node"));
			trace(e);
			throw e;
		}
		
		//
		// Determine with what values the color is being created.
		//
		if (null != atts.value)
		{
			colorCreationMode = 1;
		}
		else if (null != atts.red && null != atts.green && null != atts.blue)
		{
			colorCreationMode = 2;
		}
		else if (null != atts.white)
		{
			colorCreationMode = 3;
		}
		else // This node is bad, throw an exception
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSMissingAttributeException",
				"The color in this node is malformed.",
				NSDictionary.dictionaryWithObjectForKey(node, "node"));
			
			trace(e);
			throw e;
		}
		
		//
		// Get alpha (with a default of 1.0)
		//
		// TODO Should the attribute values be validated?
		//    
		alpha = Number(ASParsingUtils.extractTypedValueForAttributeKey(atts, "alpha", 
			true, 1.0));
		
		switch (colorCreationMode)
		{
			case 1: // Hex creation
				var val:Number = Number(ASParsingUtils.
					extractTypedValueForAttributeKey(atts, "value", true));
				color = NSColor.colorWithHexValueAlpha(val, alpha);
				break;
				
			case 2: // RGB creation
				var r:Number = Number(ASParsingUtils.
					extractTypedValueForAttributeKey(atts, "red", true));
				var g:Number = Number(ASParsingUtils.
					extractTypedValueForAttributeKey(atts, "green", true));
				var b:Number = Number(ASParsingUtils.
					extractTypedValueForAttributeKey(atts, "blue", true));
				color = NSColor.colorWithCalibratedRedGreenBlueAlpha(
					r, g, b, alpha);
				break;
				
			case 3: // Grayscale creation
				var w:Number = Number(ASParsingUtils.
					extractTypedValueForAttributeKey(atts, "white", true));
				color = NSColor.colorWithCalibratedWhiteAlpha(w, alpha);
				break;
		}
		
		return {color: color, name: ASParsingUtils.extractTypedValueFromString(
			atts.name)};
	}
}