/* See LICENSE for copyright and terms of use */

import org.actionstep.ASBitmapImageRep;
import org.actionstep.NSSize;
import flash.display.BitmapData;

/**
 * @author Scott Hyndman
 */
class org.actionstep.themes.plastic.images.ASScrollerUpArrowRep 
		extends ASBitmapImageRep {
	
	/**
	 * Creates a new instance of the <code>ASScrollerUpArrowRep</code> class.
	 */
	public function ASScrollerUpArrowRep() {
		m_size = new NSSize(8, 4);
		buildImage();
	}
	
	/**
	 * Returns the color of the arrow as a 32-bit number.
	 */
	private function arrowColor():Number {
		return 0xFF000000;
	}
	
	/**
	 * Builds the bitmap image.
	 */
	private function buildImage():Void {
		var c:Number = arrowColor();
		m_image = new BitmapData(8, 4, true, null);
		
		var pPerRow:Array = new Array(2, 4, 6, 8);
		for (var i:Number = 0; i < 4; i++) {
			var cnt:Number = pPerRow[i];
			for (var j:Number = 4 - cnt / 2; j < 4 + cnt / 2; j++) {
				m_image.setPixel32(j, i, c);
			}
		}
	}
}