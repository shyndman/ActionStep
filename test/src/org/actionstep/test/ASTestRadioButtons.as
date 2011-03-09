/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSButtonType;
import org.actionstep.constants.NSControlSize;
import org.actionstep.layout.ASVBox;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.NSCell;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestRadioButtons {
	public static function test():Void {
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0, 0, 800, 600));
		var stg:NSView = wnd.contentView();
		
		//
		// Build radio buttons in each size
		//
		var vbox:ASVBox = (new ASVBox()).init();
		stg.addSubview(vbox);
		
		var btn:NSButton = (new NSButton()).initWithFrame(new NSRect(10, 10, 140, 25));
		btn.setTitle("Regular radio button");
		btn.setButtonType(NSButtonType.NSRadioButton);
		vbox.addViewWithMinYMargin(btn, 4);

		btn = (new NSButton()).initWithFrame(new NSRect(10, 10, 140, 25));
		btn.setTitle("Small radio button");
		btn.setButtonType(NSButtonType.NSRadioButton);
		btn.cell().setControlSize(NSControlSize.NSSmallControlSize);
		vbox.addViewWithMinYMargin(btn, 4);

		btn = (new NSButton()).initWithFrame(new NSRect(10, 10, 140, 25));
		btn.setTitle("Mini radio button");
		btn.setButtonType(NSButtonType.NSRadioButton);
		btn.cell().setControlSize(NSControlSize.NSMiniControlSize);
		vbox.addViewWithMinYMargin(btn, 4);
		
		//
		// Disabled
		//
		btn = (new NSButton()).initWithFrame(new NSRect(10, 10, 200, 25));
		btn.setTitle("Regular disabled radio button");
		btn.setButtonType(NSButtonType.NSRadioButton);
		btn.cell().setControlSize(NSControlSize.NSRegularControlSize);
		btn.setEnabled(false);
		vbox.addViewWithMinYMargin(btn, 4);
		
		btn = (new NSButton()).initWithFrame(new NSRect(10, 10, 200, 25));
		btn.setTitle("Small disabled radio button");
		btn.setButtonType(NSButtonType.NSRadioButton);
		btn.cell().setControlSize(NSControlSize.NSSmallControlSize);
		btn.setEnabled(false);
		vbox.addViewWithMinYMargin(btn, 4);

		btn = (new NSButton()).initWithFrame(new NSRect(10, 10, 200, 25));
		btn.setTitle("Mini disabled radio button");
		btn.setButtonType(NSButtonType.NSRadioButton);
		btn.cell().setControlSize(NSControlSize.NSMiniControlSize);
		btn.setEnabled(false);
		btn.setState(NSCell.NSOnState);
		vbox.addViewWithMinYMargin(btn, 4);
		
		vbox.setFrameOrigin(new NSPoint(10, 10));		
		app.run();
		
//		//
//		// Do the drawing
//		//
//		var w:Number = 30;
//		var h:Number = 30;
//		var g:ASGraphics = btn.graphics();
//		
//		//
//		// Draw the base gradient
//		//
//		var c1:NSColor = new NSColor(0x689ACA);
//		var c2:NSColor = new NSColor(0x0653AA);
//		var c3:NSColor = new NSColor(0x032341);
//		
//		var matrix:Matrix = new Matrix();
//		matrix.createGradientBox(w, h, ASGraphicUtils.convertDegreesToRadians(90), 0, 0);
//		
//		var base:ASRadialGradient = new ASRadialGradient([c1, c2, c3], 
//			[0, 235, 250],
//			matrix,
//			null,
//			null,
//			-0.3);
//		
//		g.brushDownWithBrush(base);
//		g.drawCircleInRect(new NSRect(0, 0, w, h), null, 0);
//		g.brushUp();
//		
//		//
//		// Draw the first highlight
//		//
//		var h1w:Number = 1.21 * w;
//		var h1h:Number = .71 * h;
//		
//		var hca1:NSColor = new NSColor(0x89FEFD);
//		var hca2:NSColor = NSColor.colorWithHexValueAlpha(0xBCFCFF, 0.21);
//		var hca3:NSColor = NSColor.colorWithHexValueAlpha(0xBCFCFF, 0);
//		
//		matrix = new Matrix();
//		matrix.createGradientBox(h1w, h1h, 0, -.1 * w, -.3 * h);
//		
//		var highlight1:ASRadialGradient = new ASRadialGradient(
//			[hca1, hca2, hca3],
//			[0, 138, 255],
//			matrix);
//		
//		g.brushDownWithBrush(highlight1);
//		g.drawCircleInRect(new NSRect(0,0,w,h), null, 0);
//		g.brushUp();
//		
//		//
//		// Draw the second highlight
//		//
//		var h2w:Number = 2 * w;
//		var h2h:Number = 1.29 * h;
//		var x:Number = (w - h2w) / 2;
//		
//		var hcb1:NSColor = NSColor.colorWithHexValueAlpha(0xD5FFFF, 0.70);
//		var hcb2:NSColor = NSColor.colorWithHexValueAlpha(0xC4FFFF, 0.23);
//		var hcb3:NSColor = NSColor.colorWithHexValueAlpha(0xBCFCFF, 0);
//		
//		matrix = new Matrix();
//		matrix.createGradientBox(h2w, h2h, 
//			ASGraphicUtils.convertDegreesToRadians(90), x, h * 0.23);
//		//matrix.tx = x - 0.14 * w;
//		
//		var highlight2:ASRadialGradient = new ASRadialGradient(
//			[hcb1, hcb2, hcb3],
//			[40, 125, 255],
//			matrix,
//			null,
//			null,
//			0.15);
//		
//		g.brushDownWithBrush(highlight2);
//		g.drawEllipseInRect(new NSRect(0,0,w,h), null, 0);
//		g.brushUp();
	}
}