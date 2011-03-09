/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.graphics.ASLinearGradient;
import org.actionstep.NSColor;
import org.actionstep.NSRect;
import org.actionstep.NSSliderCell;
import org.actionstep.NSView;

/**
 * Cell for a color slider.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.color.view.ASColorSliderCell extends NSSliderCell {
	
	private static var SLIDER_TRACK_WIDTH:Number = 10;
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_gradient:ASLinearGradient;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASColorSliderCell</code> class.
	 */
	public function ASColorSliderCell() {
		
	}
	
	//******************************************************
	//*                 Setting the gradient
	//******************************************************
	
	/**
	 * Sets the cell gradient to <code>grad</code>.
	 */
	public function setGradient(grad:ASLinearGradient):Void {
		m_gradient = grad;
	}
	
	//******************************************************
	//*                      Drawing
	//******************************************************
	
	/**
	 * Returns the track rect.
	 */
	private function linearTrackRect():NSRect {
		var ret:NSRect = super.linearTrackRect();
		if (m_isVertical) {
			ret.size.width = SLIDER_TRACK_WIDTH;
		} else {
			ret.size.height = SLIDER_TRACK_WIDTH;
		}
		ret = m_sliderRect.intersectionRect(ret);
		
		return ret;
	}
	
	/**
	 * Draws the slider’s bar—but not its bezel or knob—inside 
	 * <code>aRect</code>.
	 * 
	 * <code>flipped</code> indicates whether the coordinate system is flipped.
	 */
	public function drawBarInsideFlipped(aRect:NSRect, flipped:Boolean):Void {
		var view:NSView = controlView();
		var g:ASGraphics = view.graphics();
							
		g.brushDownWithBrush(ASColors.lightGrayColor());
		g.drawRectWithRect(aRect);
		g.brushUp();
		aRect = aRect.insetRect(1, 1);
		g.brushDownWithBrush(new NSColor(0xEAEAEA));
		g.drawRectWithRect(aRect);
		g.brushUp();
		aRect = aRect.insetRect(1, 1);
		g.brushDownWithBrush(m_gradient);
		g.drawRectWithRect(aRect);
		g.brushUp();
	}
	
	//******************************************************															 
	//*        Asking about the cell’s behavior
	//******************************************************
	
	/**
	 * By default, this method returns <code>true</code>, so an 
	 * <code>NSSliderCell</code> continues to track the cursor even after the 
	 * cursor leaves the cell’s tracking rectangle.
	 */
	public static function prefersTrackingUntilMouseUp():Boolean {
		return true;
	}
}