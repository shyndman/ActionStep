/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlReader;
import org.actionstep.asml.ASParsingUtils;
import org.actionstep.asml.ASReferenceProperty;
import org.actionstep.asml.ASTagHandler;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeProtocol;

/**
 * This handles parsing of <code>theme</code> tags. It adds color and image
 * resources to the theme.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASThemeTagHandler extends NSObject 
	implements ASTagHandler 
{
	private var m_reader:ASAsmlReader;
	private var m_theme:ASThemeProtocol;
	
	/**
	 * Creates a new instance of ASThemeTag handler for the {@link AsmlReader} 
	 * <code>reader</code>.
	 */
	public function ASThemeTagHandler(reader:ASAsmlReader)
	{
		m_reader = reader;
	}
	
	/**
	 * <p>Adds assets to the theme.</p>
	 * 
	 * <p>Color objects passed to this method must be packaged into a simple
	 * object containing these two properties:
	 * <ul><li>
	 * "color":{@link NSColor}
	 * </li><li>
	 * "name":{@link String}
	 * </li></ul></p>
	 */
	public function addChildToParent(child:Object, parent:Object, 
		remainingChildAttributes:Object):Void 
	{		
		if (null != child.color && null != child.name) // NSColor
		{
			m_theme.setColorForName(child.color, child.name);
		}
		else if (null != child.image && null != child.name) // NSImage
		{
			// do nothing
		}
	}

	/**
	 * <p>Parses the theme tag.</p>
	 * 
	 * <p>Throws an exception if the theme tag contains no <code>instanceOf</code> 
	 * attribute</p>
	 */
	public function parseNodeWithClassName(node:XMLNode, className:String)
		:Object {
		var atts:Object = node.attributes;
		
		if (null == atts.instanceOf) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSMissingAttributeException",
				"A theme tag must contain an instanceOf attribute.",
				NSDictionary.dictionaryWithObjectForKey(node, "node"));
			trace(e);
			throw e;
		}
		
		//
		// Create the theme
		//
		var theme:ASThemeProtocol = ASThemeProtocol(
			ASParsingUtils.createInstanceWithClassNameAttributes(className,
			atts));
		
		//
		// Apply remaining properties.
		//
		var refs:Array = ASParsingUtils.applyPropertiesToObjectWithAttributes(
			theme, atts);
		
		//
		// Set the owner for all the reference properties and add them to the
		// reader.
		//
		var len:Number = refs.length;
		for (var i:Number = 0; i < len; i++)
		{
			ASReferenceProperty(refs[i]).setOwner(theme);
			m_reader.addReferenceProperty(ASReferenceProperty(refs[i]));
		}
		
		//
		// Set as theme for the application.
		//
		ASTheme.setCurrent(theme);
		m_theme = theme;
		
		return theme;
	}
}