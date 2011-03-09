/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.constants.NSControlSize;
import org.actionstep.graphics.ASGraphicUtils;
import org.actionstep.graphics.ASRadialGradient;
import org.actionstep.NSColor;
import org.actionstep.themes.plastic.images.ASRadioButtonRep;

import flash.geom.Matrix;

/**
 * <p>This class draws the highlighted (pressed) radio button image for the
 * {@link org.actionstep.NSButton} class when it is in radio button 
 * mode.</p>
 * 
 * <p>It is used by {@link org.actionstep.NSButtonCell}.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.plastic.images.ASHighlightedRadioButtonRep 
	extends ASRadioButtonRep {

	/**
	 * Constructs a new instance of the highlighted radio button rep with
	 * a control size.
	 */
	public function ASHighlightedRadioButtonRep(size:NSControlSize) {
		super(size);
	}
  
    private function registerColors():Void {
		var w:Number = m_size.width;
		var h:Number = m_size.height;
		
		//
		// Draw the base gradient
		//
		var c1:NSColor = new NSColor(0x689ACA);
		var c2:NSColor = new NSColor(0x0653AA);
		var c3:NSColor = new NSColor(0x032341);
		
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
		
		var hca1:NSColor = new NSColor(0x89FEFD);
		var hca2:NSColor = NSColor.colorWithHexValueAlpha(0xBCFCFF, 0.21);
		var hca3:NSColor = NSColor.colorWithHexValueAlpha(0xBCFCFF, 0);
		
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
		
		var hcb1:NSColor = NSColor.colorWithHexValueAlpha(0xD5FFFF, 0.70);
		var hcb2:NSColor = NSColor.colorWithHexValueAlpha(0xC4FFFF, 0.23);
		var hcb3:NSColor = NSColor.colorWithHexValueAlpha(0xBCFCFF, 0);
		
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
	 * Returns a string representation of the ASHighlightedRadioButtonRep instance.
	 */
	public function description():String {
		return "ASHighlightedRadioButtonRep()";
	}
  
	/**
	 * Draws the image.
	 */
	public function draw() {
		super.draw();
		
		drawDot();
	}
	
	private function drawDot():Void {
		var x:Number = m_size.width / 2;
		var y:Number = m_size.height / 2;
		m_graphics.brushDownWithBrush(ASColors.blackColor());
		m_graphics.drawCircle(x + .5, y, m_dotRadius, null, 0);
		m_graphics.brushUp();
	}
}