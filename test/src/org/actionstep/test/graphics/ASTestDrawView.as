import org.actionstep.ASColors;
import org.actionstep.graphics.ASBrush;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.graphics.ASLinearGradient;
import org.actionstep.graphics.ASPen;
import org.actionstep.NSColor;
import org.actionstep.NSRect;
import org.actionstep.NSView;

import flash.geom.Matrix;
import org.actionstep.constants.NSLineJointStyle;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.graphics.ASTestDrawView extends NSView {
	public function drawRect(aRect:NSRect):Void {
		aRect = aRect.insetRect(10, 10);
		
		var g:ASGraphics = graphics();
		g.setJointStyle(NSLineJointStyle.NSBevelLineJointStyle);
		
		//
		// Build gradient pen
		//
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(aRect.size.width, aRect.size.height, 
			0 /* rotation */,
			aRect.origin.x, aRect.origin.y);
		var pen:ASPen = new ASLinearGradient(
			[
				// These colors' alpha values are used in the gradient
				ASColors.darkGrayColor(), 
				ASColors.lightGrayColor(), 
				ASColors.darkGrayColor()
			],
			[0, 126, 255],
			matrix);
		
		//
		// Build background brush
		//
		var brush:ASBrush = NSColor.colorWithHexValueAlpha(0x009900, 
			0.5); // 50% opaque
		
		//
		// Draw the shape
		//
		g.beginFill(brush);
		g.drawCutCornerRectWithRect(aRect, 
			15, // corner size
			pen,
			7); // thickness
		g.endFill();
	}	
}