/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSControlSize;
import org.actionstep.graphics.ASGradient;
import org.actionstep.graphics.ASGraphicUtils;
import org.actionstep.graphics.ASLinearGradient;
import org.actionstep.NSColor;
import org.actionstep.NSPoint;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.plastic.images.ASSwitchRep;

import flash.geom.Matrix;

/**
 * <p>This class draws the highlighted (pressed) checkbox for the
 * <code>org.actionstep.NSButton</code> class.</p>
 * 
 * <p>It is used by {@link org.actionstep.NSButtonCell}.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.plastic.images.ASHighlightedSwitchRep 
		extends ASSwitchRep {
	
	/**
	 * Constructor
	 */
	public function ASHighlightedSwitchRep(size:NSControlSize) {
		super(size);

		var bg2:NSColor = ASTheme.current().colorWithName(
			ASThemeColorNames.ASHighlightedSwitchButtonBackground);
		var h:Number = bg2.hueComponent();
		var b:Number = bg2.brightnessComponent();
		var s:Number = bg2.saturationComponent();
		
		var bg1:NSColor = NSColor.colorWithCalibratedHueSaturationBrightnessAlpha(
			h, s * 0.75, 
			b * 1.1, 1);
		var bg3:NSColor = NSColor.colorWithCalibratedHueSaturationBrightnessAlpha(
			h, s * 0.65, 
			b * 1.3, 1);
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(m_size.width, m_size.height, 
			ASGraphicUtils.convertDegreesToRadians(ASGradient.ANGLE_BOTTOM_TO_TOP), 
			0, 0);
		m_bgBrush = new ASLinearGradient(
			[bg1, bg2, bg3],
			[50, 130, 255],
			matrix);
		m_graphics.setBrush(m_bgBrush);
	}
	
	/**
	 * Returns a string representation of the ASHighlightedSwitchRep instance.
	 */
	public function description():String {
		return "ASHighlightedSwitchRep(size=" + m_size + ")";
	}
	
	/**
	 * Draws the check mark.
	 */
	public function draw() {
		super.draw();
		
		//
		// Determine depth
		//
		var depth:Number = super.getClipDepth();
		
		//
		// Create clip
		//
		var clip:MovieClip = m_lastCanvas = m_drawClip.createEmptyMovieClip("__switchRep" 
			+ depth, depth);
		clip.view = m_drawClip.view;
		m_graphics.setClip(clip);
		clip._x = m_drawPoint.x;
		clip._y = m_drawPoint.y;
		super.addImageRepToDrawClip(clip);

		if (clip.getDepth() < m_bgClip.getDepth()) {
			clip.swapDepths(m_bgClip);
		}
		
		//
		// Draw check
		//
		var points:Array = [
			new NSPoint(m_checkHorzInset, m_boxOffset + m_checkVertInset + 1),
			new NSPoint((m_size.width - m_boxOffset) / 2, m_size.height - m_checkVertInset),
			new NSPoint(m_size.width, 0)];
			
		m_graphics.drawPolylineWithPoints(points, m_borderColor, m_checkThickness);
	}
}