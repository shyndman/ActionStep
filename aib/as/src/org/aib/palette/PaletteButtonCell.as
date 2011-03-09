/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.NSButtonCell;
import org.actionstep.NSCell;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;

/**
 * Button cell for the palette type selector.
 * 
 * @author Scott Hyndman
 */
class org.aib.palette.PaletteButtonCell extends NSButtonCell {
	
	/**
	 * Constructs a new instance of <code>PaletteButtonCell</code>.
	 */
	public function PaletteButtonCell() {
		setBackgroundColor(ASColors.lightGrayColor());
	}
	
	/**
	 * Overridden to draw borders differently.
	 */
	private function drawBezelWithFrameInView(cellFrame:NSRect, 
			inView:NSView):Void {
				
		//
		// Get the mask
		//
		var mask:Number;
		var highlighted:Boolean = isHighlighted();
		if (highlighted) {
			mask = highlightsBy();
			if (state() == 1) {
				mask &= ~showsStateBy();
			}
		} else if (state() == 1) {
			mask = showsStateBy();
		} else {
			mask = NSCell.NSNoCellMask;
		}
		
		if (m_enabled) {
			if ((mask & (NSChangeGrayCellMask | NSChangeBackgroundCellMask))) {
				ASTheme.current().drawFillWithRectColorInView(cellFrame, 
        			backgroundColor(), inView);
			}		
		}
	}
}