/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSRectEdge;
import org.actionstep.NSDrawer;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;

/**
 * The visual representation of a drawer.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.drawers.ASDrawerView extends NSView {
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private var m_drawer:NSDrawer;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASDrawerView</code> class.
	 */
	public function ASDrawerView() {
	}
	
	/**
	 * Initializes the drawer view with its owner drawer.
	 */
	public function initWithDrawer(drawer:NSDrawer):ASDrawerView {
		super.init();
		m_drawer = drawer;
		return this;
	}
	
	/**
	 * Releases the object from memory.
	 */
	public function release():Boolean {
		super.release();
		m_drawer = null;
		return true;
	}
	
	//******************************************************
	//*             Setting the view's frame
	//******************************************************
	
	/**
	 * Overridden to handle sizing the content view.
	 */
	public function setFrame(frame:NSRect):Void {
		super.setFrame(frame);
		sizeContentViewToFrame(frame.clone());
	}

	/**
	 * Overridden to handle sizing the content view.
	 */	
	public function setFrameSize(size:NSSize):Void {
		super.setFrameSize(size);
		sizeContentViewToFrame(NSRect.withOriginSize(NSPoint.ZeroPoint, size));
	}
	
	/**
	 * Sizes the content view.
	 */
	private function sizeContentViewToFrame(frame:NSRect):Void {
		var cv:NSView = m_drawer.contentView();
		if (cv == null) {
			return;
		}
		
		var borderWidth:Number = ASTheme.current().drawerBorderWidth();
		frame.origin = NSPoint.ZeroPoint;
		cv.setFrame(frame.insetRect(borderWidth, borderWidth));
	}
	
	//******************************************************
	//*             Drawing the drawer view
	//******************************************************
	
	/**
	 * Draws the drawer view in the rectangle <code>aRect</code>.
	 */
	public function drawRect(aRect:NSRect):Void {
		var mc:MovieClip = mcBounds();
		mc.clear();
		var edge:NSRectEdge = m_drawer.preferredEdge();
		var borderWidth:Number = ASTheme.current().drawerBorderWidth();
		
		switch (edge) {
			case NSRectEdge.NSMinXEdge:
				aRect.size.width += borderWidth;
				break;
				
			case NSRectEdge.NSMinYEdge:
				aRect.size.height += borderWidth;
				break;
				
			case NSRectEdge.NSMaxXEdge:
				aRect.origin.x -= borderWidth;
				aRect.size.width += borderWidth;
				break;
				
			case NSRectEdge.NSMaxYEdge:
				aRect.origin.y -= borderWidth;
				aRect.size.height += borderWidth;
				break;
		}
		
		ASTheme.current().drawDrawerWithRectInView(aRect, this);
	}
}