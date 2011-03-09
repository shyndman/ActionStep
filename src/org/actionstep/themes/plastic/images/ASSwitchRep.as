/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.constants.NSControlSize;
import org.actionstep.constants.NSLineJointStyle;
import org.actionstep.graphics.ASGradient;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.graphics.ASGraphicUtils;
import org.actionstep.graphics.ASLinearGradient;
import org.actionstep.NSColor;
import org.actionstep.NSImageRep;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;

import flash.filters.DropShadowFilter;
import flash.geom.Matrix;

/**
 * <p>This class draws the unpressed checkbox for the 
 * {@link org.actionstep.NSButton} class.</p>
 * 
 * <p>It is used by {@link org.actionstep.NSButtonCell}.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.plastic.images.ASSwitchRep 
		extends NSImageRep {
	
	private var m_graphics:ASGraphics;
	private var m_cornerSize:Number;
	private var m_checkThickness:Number;
	private var m_boxOffset:Number;
	private var m_checkVertInset:Number;
	private var m_checkHorzInset:Number;
	private var m_borderColor:NSColor;
	private var m_bgBrush:ASLinearGradient;
	private var m_dropShadow:DropShadowFilter;
	private var m_bgClip:MovieClip;
	
	/**
	 * Constructs a new switch rep with the control size.
	 */
	public function ASSwitchRep(size:NSControlSize) {		
				
		m_size = ASTheme.current().switchImageSizeForControlSize(size);
		m_boxOffset = m_size.width / 6;
		m_checkVertInset = m_size.height / 6;
		m_checkHorzInset = m_size.width / 4.5;
		m_checkThickness = Math.ceil(m_size.width / 9);
		m_cornerSize = Math.floor(m_size.width / 12);
		
		//
		// Set up graphics
		//
		var sidelen:Number = m_size.width;
		
		m_graphics = (new ASGraphics()).init();
		m_graphics.setJointStyle(NSLineJointStyle.NSBevelLineJointStyle);
		
		m_borderColor = ASColors.blackColor();
		var bg1:NSColor = ASTheme.current().colorWithName(ASThemeColorNames.ASSwitchButtonBackground);
		var bg2:NSColor = bg1.adjustColorBrightnessByFactor(0.8);
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(sidelen - m_boxOffset, sidelen - m_boxOffset, 
			ASGraphicUtils.convertDegreesToRadians(ASGradient.ANGLE_BOTTOM_TO_TOP), 
			0, 0);
		m_bgBrush = new ASLinearGradient(
			[bg1, bg2, bg1],
			[50, 130, 255],
			matrix);
		m_graphics.setBrush(m_bgBrush);
		
		m_dropShadow = new DropShadowFilter(1.5, 55, 0, 100, 1.5, 1.5, 0.7, 1);
	}
	
	/**
	 * Returns a string representation of the ASSwitchRep instance.
	 */
	public function description():String {
		return "ASSwitchRep(size=" + m_size + ")";
	}
	
	public function draw() {
		//
		// Determine depth
		//
		var depth:Number = super.getClipDepth();
		
		//
		// Create clip
		//
		var clip:MovieClip = m_bgClip = m_drawClip.createEmptyMovieClip("__switchRep" 
			+ depth, depth);
		clip.view = m_drawClip.view;
		clip.filters = [m_dropShadow];
		clip._x = m_drawPoint.x;
		clip._y = m_drawPoint.y;
		super.addImageRepToDrawClip(clip);
		
		//
		// Draw checkbox 
		//
		var x:Number = 0;
		var y:Number = m_boxOffset;
		var width:Number = m_size.width - m_boxOffset;
		var height:Number = m_size.height - m_boxOffset;
		
		m_graphics.setClip(clip);			
		m_graphics.brushDown();
		m_graphics.drawCutCornerRect(x, y, width, height, m_cornerSize,
			m_borderColor, 1);
		m_graphics.brushUp();
	}
}