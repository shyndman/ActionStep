/* See LICENSE for copyright and terms of use */

import org.actionstep.NSBox;
import org.actionstep.NSRect;
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSTitlePosition;
import org.actionstep.ASDraw;
import org.actionstep.ASColors;

/**
 * @author Scott Hyndman
 */
class org.aib.stage.GroupView extends NSBox {
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	public function initWithFrame(aRect:NSRect):GroupView {
		super.initWithFrame(aRect);
		setTitlePosition(NSTitlePosition.NSNoTitle);
		return this;
	}
	
	//******************************************************
	//*                    Drawing
	//******************************************************
	
	private function drawBackgroundWithRectExcludeRectBorderType(
			rect:NSRect, exclude:NSRect, borderType:NSBorderType):Void {
		var mc:MovieClip = mcBounds();
		mc.clear();
		
		mc.lineStyle(1, ASColors.grayColor().value, 100);
		ASDraw.drawDashedRectWithRect(mc, rect, 3, 2);
	}
}