import org.actionstep.constants.NSRectEdge;
import org.actionstep.NSArray;
import org.actionstep.NSView;
import org.aib.AIBObject;
import org.aib.stage.guides.GuidelineProtocol;
import org.actionstep.NSRect;
import org.aib.stage.guides.GuideInfo;

/**
 * A guideline implementation.
 * 
 * @author Scott Hyndman
 */
class org.aib.stage.guides.ActionStepGuidelines extends AIBObject 
		implements GuidelineProtocol {
	
	//******************************************************
	//*                     Constants
	//******************************************************
	
	private static var CONTROL_SEPARATION:Number = 10;
	private static var SNAP_TOLERANCE:Number = 15;
	
	//******************************************************
	//*                    Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ActionStepGuidelines</code> class.
	 */
	public function ActionStepGuidelines() {
	}
	
	/**
	 * Initializes the object.
	 */
	public function init():ActionStepGuidelines {
		return this;
	}
	
	//******************************************************
	//*                     Snapping
	//******************************************************
	
	public function snapPointForViewGuidesWithEdge(aView:NSView, guides:NSArray,
			edge:NSRectEdge):Number {
		var supr:NSView = aView.superview(); // FIXME this should be content view
		if (supr == null) {
			return null;
		}
		
		var frm:NSRect = aView.frame();
		var suprfrm:NSRect = supr.frame();
		var loc:Number = null;
		
		switch (edge) {
			case NSRectEdge.NSMinXEdge:
				if (Math.abs(frm.origin.x - CONTROL_SEPARATION) < SNAP_TOLERANCE) {
					loc = CONTROL_SEPARATION;
					guides.addObject(new GuideInfo(loc, true));
				} 
				break;
				
			case NSRectEdge.NSMaxXEdge:
				if (Math.abs(suprfrm.maxX() - frm.maxX()  
						- CONTROL_SEPARATION) < SNAP_TOLERANCE) {
					loc = suprfrm.maxX() - CONTROL_SEPARATION;
					guides.addObject(new GuideInfo(loc, true));
				}
				break;
				
			case NSRectEdge.NSMinYEdge:
				if (Math.abs(frm.origin.y - CONTROL_SEPARATION) < SNAP_TOLERANCE) {
					loc = CONTROL_SEPARATION;
					guides.addObject(new GuideInfo(loc, false));
				} 
				break;
				
			case NSRectEdge.NSMaxYEdge:
				if (Math.abs(suprfrm.maxY() - frm.maxY() 
						- CONTROL_SEPARATION) < SNAP_TOLERANCE) {
					loc = suprfrm.maxY() - CONTROL_SEPARATION;
					guides.addObject(new GuideInfo(loc, false));
				}
				break;
		}
		
		return loc;
	}

}