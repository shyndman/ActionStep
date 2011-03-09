/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlReader;
import org.actionstep.asml.ASInstanceTagHandler;
import org.actionstep.asml.ASParsingUtils;
import org.actionstep.NSObject;
import org.actionstep.NSTabViewItem;
import org.actionstep.NSView;

/**
 * <p>Handles tabItem tags. This class constructs {@link NSTabViewItem} 
 * instances and handles adding their associated views.</p>
 * 
 * <p>These tabItems are later added to a tabView using the
 * {@link org.actionstep.asml.ASTabViewTagHandler} class.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASTabViewItemTagHandler extends ASInstanceTagHandler 
{
	/**
	 * <p>Constructs a new instance of <code>ASTabViewHandler</code>.</p> 
	 * 
	 * <p><code>reader</code> is the {@link ASAsmlReader} using this tag
	 * handler.</p>
	 */
	public function ASTabViewItemTagHandler(reader:ASAsmlReader)
	{
		super(reader);
	}
	
	/**
	 * Adds the <code>child</code> tab as a subview of <code>parent</code>.
	 */
	public function addChildToParent(child:NSObject, parent:NSObject,
		remainingChildAttributes:Object):Void 
	{
		//! TODO Not sure if this is right.
		var ti:NSTabViewItem = NSTabViewItem(parent);
		ti.setView(NSView(child));
	}
	
	/**
	 * Override to provide more specific functionality.
	 */
	private function initializeObject(obj:Object, node:XMLNode):Void
	{
		var id:String = ASParsingUtils.extractTypedValueForAttributeKey(node.attributes,
			"identifier", true, null).toString();
		var ti:NSTabViewItem = NSTabViewItem(obj);
		ti.initWithIdentifier(id);
	}
}