/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSControlSize;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.graphics.ASGraphicUtils;
import org.actionstep.graphics.ASPen;
import org.actionstep.graphics.ASRadialGradient;
import org.actionstep.NSColor;
import org.actionstep.NSImageRep;
import org.actionstep.NSRect;
import org.actionstep.themes.ASTheme;

import flash.geom.Matrix;

/**
 * <p>This class draws the radio button image for the
 * {@link org.actionstep.NSButton} class when it is in radio button mode.</p>
 * 
 * <p>It is used by {@link org.actionstep.NSButtonCell}.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.plastic.images.ASRadioButtonRep extends NSImageRep {
  
	private var m_dotRadius:Number;
	private var m_graphics:ASGraphics;
	private var m_base:ASRadialGradient;
	private var m_highlight1:ASRadialGradient;
	private var m_highlight2:ASRadialGradient;
	private var m_border:ASPen;
	
	/**
	 * Constructs a new instance of the radio button image rep with a
	 * control size.
	 */
	public function ASRadioButtonRep(size:NSControlSize) {
		m_size = ASTheme.current().radioImageSizeForControlSize(size);
		m_dotRadius = m_size.width / 5;
		m_graphics = (new ASGraphics()).init();
		registerColors();
	}

	/**
	 * Registers the colors used by this rep.
	 */
	public function registerColors():Void {
		var w:Number = m_size.width;
		var h:Number = m_size.height;
		
		//
		// Draw the base gradient
		//
		var c1:NSColor = new NSColor(0x919191);
		var c2:NSColor = new NSColor(0x737373);
		var c3:NSColor = new NSColor(0x373737);
		
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(w, h, 
			ASGraphicUtils.convertDegreesToRadians(90), 
			0, 0); // TODO fix these. they shouldn't be zero
		
		m_base = new ASRadialGradient([c1, c2, c3], 
			[0, 235, 250],
			matrix,
			null,
			null,
			-0.3);
			
		//
		// Draw the first highlight
		//
		var h1w:Number = 1.21 * w;
		var h1h:Number = .71 * h;
		
		var hca1:NSColor = new NSColor(0xE6E6E6);
		var hca2:NSColor = NSColor.colorWithHexValueAlpha(0xFCFCFC, 0.21);
		var hca3:NSColor = NSColor.colorWithHexValueAlpha(0xFFFFFF, 0);
		
		matrix = new Matrix();
		matrix.createGradientBox(h1w, h1h, 0, -.1 * w, -.3 * h);
		
		m_highlight1 = new ASRadialGradient(
			[hca1, hca2, hca3],
			[0, 138, 255],
			matrix);
			
		//
		// Draw the second highlight
		//
		var h2w:Number = 2 * w;
		var h2h:Number = 1.29 * h;
		var x:Number = (w - h2w) / 2;
		
		var hcb1:NSColor = NSColor.colorWithHexValueAlpha(0xF7F7F7, 0.70);
		var hcb2:NSColor = NSColor.colorWithHexValueAlpha(0xFFFFFF, 0.23);
		var hcb3:NSColor = NSColor.colorWithHexValueAlpha(0xFFFFFF, 0);
		
		matrix = new Matrix();
		matrix.createGradientBox(h2w, h2h, 
			ASGraphicUtils.convertDegreesToRadians(90), x, h * 0.23);
		//matrix.tx = x - 0.14 * w;
		
		m_highlight2 = new ASRadialGradient(
			[hcb1, hcb2, hcb3],
			[40, 125, 255],
			matrix,
			null,
			null,
			0.15);
			
		m_border = NSColor.colorWithCalibratedWhiteAlpha(0.3, 1);
	}
	
	/**
	 * Returns a string representation of the ASRadioButtonRep instance.
	 */
	public function description():String {
		return "ASRadioButtonRep()";
	}
  
	public function draw() {
		var g:ASGraphics = m_graphics;
			
		//
		// Determine depth
		//
		var depth:Number = super.getClipDepth();
		
		//
		// Create clip
		//
		var clip:MovieClip = m_lastCanvas = m_drawClip.createEmptyMovieClip("__radioRep" 
			+ depth, depth);
		m_graphics.setClip(clip);
		clip.view = m_drawClip.view;
		clip._x = m_drawPoint.x;
		clip._y = m_drawPoint.y;
		super.addImageRepToDrawClip(clip);
		
		var w:Number = m_size.width;
		var h:Number = m_size.height;
				
		g.brushDownWithBrush(m_base);
		g.drawCircleInRect(new NSRect(0, 0, w, h), null, 0);
		g.brushUp();
				
		g.brushDownWithBrush(m_highlight1);
		g.drawCircleInRect(new NSRect(0,0,w,h), null, 0);
		g.brushUp();
		
		g.brushDownWithBrush(m_highlight2);
		g.drawEllipseInRect(new NSRect(0,0,w,h), m_border, 1);
		g.brushUp();
	}
}