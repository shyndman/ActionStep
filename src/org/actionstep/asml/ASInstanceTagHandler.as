/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlReader;
import org.actionstep.asml.ASParsingUtils;
import org.actionstep.asml.ASReferenceProperty;
import org.actionstep.asml.ASTagHandler;
import org.actionstep.NSObject;

/**
 * <p>This class handles <code>instance</code> tags from the ASML file.</p>
 * 
 * <p>An instance tag intantiates an instance of a class as specified by the
 * <code>instanceOf</code> attribute on the tag. This is generally used for
 * creating controller objects that will talk with views.</p>
 * 
 * <p>To create a view of an undetermined class, the <code>view</code> tag is
 * typically used.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASInstanceTagHandler extends NSObject 
	implements ASTagHandler 
{
	private var m_reader:ASAsmlReader;
	
	/**
	 * <p>Constructs a new instance of <code>ASInstanceTagHandler</code>.</p> 
	 * 
	 * <p><code>reader</code> is the {@link ASAsmlReader} using this tag
	 * handler.</p>
	 */
	public function ASInstanceTagHandler(reader:ASAsmlReader)
	{
		m_reader = reader;
	}
	
	/**
	 * Does nothing. Instances aren't a member of any hierarchy.
	 */
	public function addChildToParent(child:NSObject, parent:NSObject,
		remainingChildAttributes:Object):Void 
	{
	}

	/**
	 * // TODO Describes steps taken here.
	 */
	public function parseNodeWithClassName(node:XMLNode, className:String)
		:Object 
	{
		var atts:Object = node.attributes;
		
		//
		// Store for exception
		//
		var clsName:String = atts.instanceOf == null ? className :	atts.instanceOf;
			
		//
		// Get view instance
		//
		var instance:Object =
			ASParsingUtils.createInstanceWithClassNameAttributes(className, 
			atts);
		
		initializeObject(instance);
							
		//
		// Apply remaining properties.
		//
		var refs:Array = ASParsingUtils.applyPropertiesToObjectWithAttributes(
			instance, atts);
		
		//
		// Set the owner for all the reference properties and add them to the
		// reader.
		//
		var len:Number = refs.length;
		for (var i:Number = 0; i < len; i++)
		{
			ASReferenceProperty(refs[i]).setOwner(instance);
			m_reader.addReferenceProperty(ASReferenceProperty(refs[i]));
		}
		
		return instance;
	}
	
	/**
	 * Override to provide more specific functionality.
	 */
	private function initializeObject(obj:Object, node:XMLNode):Void
	{
	}
}