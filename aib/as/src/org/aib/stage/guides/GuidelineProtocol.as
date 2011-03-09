/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSRectEdge;
import org.actionstep.NSArray;
import org.actionstep.NSView;

/**
 * Guidelines are used to assist the developer in maintaining spacing and
 * sizing standards.
 * 
 * @author Scott Hyndman
 */
interface org.aib.stage.guides.GuidelineProtocol {
	/**
	 * <p>Returns the coordinate where <code>aView</code> will snap on
	 * the edge <code>edge</code>, or <code>null</code> if no snapping will 
	 * occur.</p>
	 * 
	 * <p>The <code>guides</code> is an empty array sent to this method so
	 * the necessary {@link org.aib.stage.guides.GuideInfo} objects can be 
	 * added. If no snapping is occurring, do nothing.</p>
	 */
	public function snapPointForViewGuidesWithEdge(aView:NSView, guides:NSArray,
		edge:NSRectEdge):Number;
}