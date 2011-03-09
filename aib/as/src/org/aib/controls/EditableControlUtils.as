import org.actionstep.ASBitmapImageRep;
import org.actionstep.NSApplication;
import org.actionstep.NSImage;
import org.actionstep.NSObject;
import org.actionstep.NSPoint;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.aib.PaletteController;

/**
 * @author Scott Hyndman
 */
class org.aib.controls.EditableControlUtils extends NSObject {
	
	public static function beginDraggingViewFromPalette(obj:Object):Void {
		var view:NSView = NSView(obj);
		
		//
		// Create image from view
		//
		var image:NSImage = createImageFromView(view);
		
		view.dragImageAtOffsetEventPasteboardSourceSlideBack(
			image, NSPoint.ZeroPoint, NSSize.ZeroSize, 
			NSApplication.sharedApplication().currentEvent(), 
			null, PaletteController.instance(), true);
	}
	
	public static function createImageFromView(view:NSView):NSImage {		
		var rep:ASBitmapImageRep = (new ASBitmapImageRep()).initWithMovieClip(
			view.mcBounds());
		var image:NSImage = (new NSImage()).initWithSize(rep.size());
		image.addRepresentation(rep);
		
		return image;
	}
}