/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImage;
import org.actionstep.NSEvent;
import org.actionstep.NSImageRep;
import org.actionstep.NSSize;
import org.actionstep.NSPoint;

/**
 * This class allows one to use images to represent keys, eg Up, Control, Home.
 *
 * @author Tay Ray Chuan
 */

class org.actionstep.ASGlyphImage {
	/** Spacing between glyphs. */
	private static var g_spacing:Number = 10;

	/** Cached images for masks. */
	private static var g_imagesForMask:Object;

	/**
	 * Returns an image that will draw the glyphs for the masks found in
	 * <code>mask</code>.
	 *
	 * Currently only supports Control, Alternate.
	 */
	public static function glyphForKeyMask(mask:Number):NSImage {
		var arr:Array = [];
		var modifiers:Array = ["Control", "Alternate"];
		var i:Number = modifiers.length;
		var mod:Number;
		while(i--) {
			mod = NSEvent["NS"+modifiers[i]+"KeyMask"];
			if(mask & mod) {
				arr.push(NSImage.imageNamed("NSGlyph"+modifiers[i]+"Rep"));
			}
		}
		if(arr.length==0) {
			return null;
		}
		if(g_imagesForMask == null) {
			g_imagesForMask = {};
		}
		if(g_imagesForMask[mask] == null) {
			g_imagesForMask[mask] = createImageForModiferArray(arr);
		}
		return g_imagesForMask[mask];
	}

	/**
	 * Helper function to create the image and its representation.
	 *
	 * Please note that it is assumed that the height of the glyphs are the
	 * same, but the width can differ.
	 */
	private static function createImageForModiferArray(arr:Array):NSImage {
		var rep:NSImageRep = new NSImageRep();
		var img:NSImage = (new NSImage()).init();
		var size:NSSize = new NSSize(0, 0);

		var i:Number;
		var currImg:NSImage;

		// calculate the size
		i = arr.length;
		while(i--) {
			currImg = NSImage(arr[i]);
			size.width += currImg.size().width + g_spacing;
			if (currImg.size().height > size.height) {
				 size.height = currImg.size().height;
			}
		}

		// oversized in loop
		size.width -= g_spacing;

		rep.size = function() {
			return size;
		};

		var str:String = "\nASGlyphImage containing(\n\t";
		i = arr.length;
		while(i--) {
			str += NSImage(arr[i]).name() + (i==0 ? "\n)" : ", ");
		}

		rep.description = function() {
			return str;
		};

		var space:Number = g_spacing;
		rep.draw = function():Boolean {
			var w:Number = this.m_drawPoint.x;
			var y:Number = this.m_drawPoint.y;
			i = arr.length;
			while(i--) {
				currImg = NSImage(arr[i]);
				currImg.lockFocus(this.m_drawClip);
				currImg.drawAtPoint(new NSPoint(w, y));
				currImg.unlockFocus();
				w+=currImg.size().width+space;
			}
			return true;
		};

		img.addRepresentation(rep);
		return img;
	}
}