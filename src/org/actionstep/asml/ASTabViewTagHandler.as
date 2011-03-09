/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlReader;
import org.actionstep.asml.ASDefaultTagHandler;
import org.actionstep.NSObject;
import org.actionstep.NSTabView;
import org.actionstep.NSTabViewItem;

/**
 * This handler constructs an {@link NSTabView} and adds child 
 * {@link NSTabViewItem}s to the view.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASTabViewTagHandler extends ASDefaultTagHandler 
{
	/**
	 * <p>Constructs a new instance of <code>ASTabViewHandler</code>.</p> 
	 * 
	 * <p><code>reader</code> is the {@link ASAsmlReader} using this tag
	 * handler.</p>
	 */
	public function ASTabViewTagHandler(reader:ASAsmlReader)
	{
		super(reader);
	}
	
	/**
	 * Adds the <code>child</code> tab as a subview of <code>parent</code>.
	 */
	public function addChildToParent(child:NSObject, parent:NSObject,
		remainingChildAttributes:Object):Void 
	{
		var tv:NSTabView = NSTabView(parent);
		var ti:NSTabViewItem = NSTabViewItem(child);
		
		tv.addTabViewItem(ti);
	}
}