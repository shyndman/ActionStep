/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.constants.NSLineJointStyle;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.graphics.ASLinearGradient;
import org.actionstep.graphics.ASRadialGradient;
import org.actionstep.NSApplication;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.NSWindow;

import flash.geom.Matrix;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import org.actionstep.graphics.ASTextureBrush;
import org.actionstep.NSColor;
import org.actionstep.test.graphics.ASTestDrawView;

/**
 * Tests primitive drawing.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestGraphics {
	public static function test():Void {
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0, 0, 800, 600));
		var view:NSView = (new NSView()).initWithFrame(new NSRect(0, 0, 800, 600));
		wnd.contentView().addSubview(view);
		app.run();
		
		//
		// Begin tests
		//
		var g:ASGraphics = view.graphics();
		g.setJointStyle(NSLineJointStyle.NSMiterLineJointStyle);
		
		//
		// Arc
		//
		g.beginFill(ASColors.blueColor());
		g.drawArc(40, 10, 40, 89, 45, true, ASColors.blackColor(), 3);
		g.endFill();
		
		//
		// Helix
		//
		NSColor.colorWithHexValueAlpha(0x009900, 0.7);
		g.beginFill(ASColors.greenColor());
		g.drawHelix(100, 40, 30, 0, 
			ASColors.greenColor().adjustColorBrightnessByFactor(0.6), 2);
		g.endFill();
		
		//
		// Hexagon
		//
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(60, 60, 30, 140, 40);
		var fillGrad:ASRadialGradient = new ASRadialGradient(
				[ASColors.blueColor(), ASColors.greenColor()],
				[20, 200], matrix);
				
		matrix = new Matrix();
		matrix.createGradientBox(60, 60, 30, 0, 0);
		var lineGrad:ASLinearGradient = new ASLinearGradient(
				[ASColors.blackColor(), ASColors.lightGrayColor()],
				[0, 255], matrix);
		g.beginFill(fillGrad);
		g.drawHexagon(140, 40, 40, lineGrad, 7);
		g.endFill();
		
		//
		// Ellipse
		//
		matrix = new Matrix();
		matrix.createGradientBox(40, 40, 67, 0, 0);
		
		var bmp:BitmapData = new BitmapData(50, 50, false, 0x3388FF);
		bmp.fillRect(new Rectangle(5, 5, 20, 20), 0x000099);
		
		var texture:ASTextureBrush = (new ASTextureBrush()).initWithBitmapMatrix(
			bmp, matrix);
		g.beginFill(texture);
		g.drawCircle(260, 40, 40, ASColors.blackColor(), 2);
		g.endFill();
		
		//
		// View
		//
		var drawView:ASTestDrawView = new ASTestDrawView();
		drawView.initWithFrame(new NSRect(500, 500, 300, 50));
		wnd.contentView().addSubview(drawView);
	}
}