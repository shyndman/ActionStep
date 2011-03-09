/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASLabel;
import org.actionstep.constants.NSImageAlignment;
import org.actionstep.constants.NSImageFrameStyle;
import org.actionstep.constants.NSImageScaling;
import org.actionstep.imageView.ASDnDImageView;
import org.actionstep.layout.ASHBox;
import org.actionstep.layout.ASVBox;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSColor;
import org.actionstep.NSImage;
import org.actionstep.NSImageView;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTextField;
import org.actionstep.NSView;
import org.actionstep.NSWindow;

/**
 * Tests for <code>NSImage</code> and <code>NSImageView</code> classes.
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestImages {
	public static function test()
	{
		var app:NSApplication = NSApplication.sharedApplication();
		var win:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0, 0, 400, 300));
		win.setBackgroundColor(new NSColor(0xDEDEDE));
		
		var win2:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0, 0, 600, 450));
		win2.setLevel(NSWindow.NSDesktopWindowLevel);
		win2.setBackgroundColor(ASColors.whiteColor());

		var image:NSImage = new NSImage();
		image.initWithContentsOfURL("test/warning.gif");
		//image.setFlipped(true);

		var image2:NSImage = (new NSImage()).initWithContentsOfURL("test/inbox.gif");
		//image2.setFlipped(true);

		var vbox:ASVBox = (new ASVBox()).init();
		vbox.setDefaultMinYMargin(10);
		win.contentView().addSubview(vbox);

		//
		// Create controls.
		//
		var ctrlHBox:ASHBox = (new ASHBox()).init();
		ctrlHBox.setDefaultMinXMargin(5);
		ctrlHBox.setAutoresizingMask(NSView.WidthSizable);

		var lbl:ASLabel = new ASLabel();
		lbl.initWithFrame(new NSRect(0, 0, 75, 23));
		lbl.setStringValue("Image URL:");
		ctrlHBox.addViewEnableXResizing(lbl, false);

		var txtUrl:NSTextField = (new NSTextField()).initWithFrame(
			new NSRect(0, 0, 20, 23));
		txtUrl.setAutoresizingMask(NSView.WidthSizable);
		txtUrl.setStringValue("test/heart.gif");
		ctrlHBox.addViewEnableXResizing(txtUrl, true);

		var btnLoad:NSButton = (new NSButton());
		btnLoad.init();
		btnLoad.setStringValue("Load");
		btnLoad.sizeToFit();
		ctrlHBox.addViewEnableXResizing(btnLoad, false);

		vbox.addViewEnableYResizing(ctrlHBox, false);

		//
		// Create images.
		//
		var imageHBox:ASHBox = (new ASHBox()).init();
		imageHBox.setDefaultMinXMargin(10);

		var imageView1:NSImageView = new NSImageView();
		imageView1.initWithFrame(new NSRect(0, 0, 100, 100));
		imageView1.setImageAlignment(NSImageAlignment.NSImageAlignBottom);
		imageView1.setImageScaling(NSImageScaling.NSScaleToFit);
		imageView1.setImageFrameStyle(NSImageFrameStyle.NSImageFrameButton);
		imageView1.setAllowsCutCopyPaste(true);
		imageView1.setImage(image);
		imageHBox.addView(imageView1);

		var imageView2:NSImageView = new ASDnDImageView();
		imageView2.initWithFrame(new NSRect(0, 0, 80, 80));
		imageView2.setImageAlignment(NSImageAlignment.NSImageAlignCenter);
		imageView2.setImageScaling(NSImageScaling.NSScaleProportionally);
		imageView2.setImageFrameStyle(NSImageFrameStyle.NSImageFrameButton);
		imageView2.setAllowsCutCopyPaste(true);
		imageView2.setImage(image2);
		imageHBox.addView(imageView2);

		var imageView3:NSImageView = new NSImageView();
		imageView3.initWithFrame(new NSRect(0, 0, 170, 130));
		imageView3.setImageAlignment(NSImageAlignment.NSImageAlignCenter);
		imageView3.setImageScaling(NSImageScaling.NSScaleToFit);
		imageView3.setImageFrameStyle(NSImageFrameStyle.NSImageFrameGroove);
		//imageView3.setImage(image);
		imageView3.setEditable(true);
		imageView3.setAllowsCutCopyPaste(true);
		imageHBox.addView(imageView3);

		vbox.addViewEnableYResizing(imageHBox, false);
		vbox.setFrameOrigin(new NSPoint(10, 10));
		vbox.setFrameSize(new NSSize(380, 200));
		NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
			ASTestImages, "imageDidLoad", NSImage.NSImageDidLoadNotification, image);

		//
		// Set up tab order
		//
		win.setInitialFirstResponder(imageView1);
		imageView1.setNextKeyView(imageView2);
		imageView2.setNextKeyView(imageView3);
		imageView3.setNextKeyView(imageView1);
		app.run();

		//
		// Create controller
		//
		var ctrl:Object = {};
		ctrl.loadFromUrl = function()
		{
			var url:String = txtUrl.stringValue();
			var img:NSImage = (new NSImage()).initWithContentsOfURL(url);

			imageView1.setImage(img);
			imageView2.setImage(img);
			imageView3.setImage(img);
		};

		btnLoad.setTarget(ctrl);
		btnLoad.setAction("loadFromUrl");
		
		//
		// Rotate
		//
//		imageView1.mcFrame()._x = -50;
//		imageView1.mcFrame()._y = -50;
//		imageView1["m_mcFrameMask"]._x = -50;
//		imageView1["m_mcFrameMask"]._y = -50;
//		imageView1["m_mcFrameMask"]._xscale = 300;
//		imageView1["m_mcFrameMask"]._yscale = 300;
//		imageView1.mcBounds()._x = 50;
//		imageView1.mcBounds()._y = 50;
//		imageView1.setFrameRotation(90);
	}

	public static function imageDidLoad(ntf:NSNotification):Void
	{
		var drawClip:MovieClip = _root.createEmptyMovieClip("drawClip", 1000);
		var img:NSImage = NSImage(ntf.object);
		img.lockFocus(drawClip);
		//img.drawAtPoint(NSPoint.ZeroPoint);
		img.unlockFocus();
	}
}