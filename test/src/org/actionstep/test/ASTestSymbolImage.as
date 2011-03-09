/* See LICENSE for copyright and terms of use */

import org.actionstep.ASSymbolImageRep;
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.constants.NSImageScaling;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSImage;
import org.actionstep.NSImageView;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.NSWindow;

/**
 * Tests the loading of external swfs and accessing the loaded swf's
 * library.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.test.ASTestSymbolImage {	
	public static function test():Void
	{
		var app:NSApplication = NSApplication.sharedApplication();
		var window:NSWindow = (new NSWindow()).initWithContentRectSwf(
		  new NSRect(0,0,500,500), "test/logo.swf");
		var content:NSView = window.contentView();
		
		// Build the image
		var image:NSImage = (new NSImage()).init();
		image.setName("ActionStepLogo");
		image.addRepresentation(new ASSymbolImageRep("actionstep_logo", 
		  new NSSize(15, 15)));
		
		// Image views draw images
		var view:NSImageView = (new NSImageView()).initWithFrame(
		  new NSRect(10,10,100,100));
		view.setImageScaling(NSImageScaling.NSScaleProportionally);
		view.setImage(image);
		  
    	// Image buttons
		var button:NSButton = (new NSButton()).initWithFrame(
		  new NSRect(115, 10, 100, 50));
		button.setTitle("Images!");
		button.setImagePosition(NSCellImagePosition.NSImageLeft);
		button.setAlignment(NSTextAlignment.NSLeftTextAlignment);
		button.setImage(image);

		content.addSubview(button);
		content.addSubview(view);
		app.run();
	}
}
