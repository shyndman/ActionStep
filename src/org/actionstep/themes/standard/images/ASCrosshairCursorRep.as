/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSImageRep;
import org.actionstep.NSPoint;
import org.actionstep.NSSize;

/**
 * This class draws the crosshair cursor. 
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASCrosshairCursorRep extends NSImageRep 
{
	private static var INNER_WIDTH:Number = 1;
	private static var OUTER_WIDTH:Number = 3;
		
	public function ASCrosshairCursorRep() 
	{ 
		m_size = new NSSize(16,16);
		super();
	}

	public function description():String 
	{
		return "ASCrosshairCursorRep(size=" + size() + ")";
	}
	
	public function draw():Void
	{
		g_graphics.setClip(m_drawClip);
	
		var pt:NSPoint = m_drawPoint;
		var sz:NSSize = size();	
		var halfBorder:Number = OUTER_WIDTH / 2;
		var halfInner:Number = INNER_WIDTH / 2;
		var inset:Number = (OUTER_WIDTH - INNER_WIDTH) / 2;
		
		//
		// Outline
		//
		g_graphics.brushDownWithBrush(ASColors.whiteColor());
		g_graphics.drawRect(pt.x + sz.width / 2 - halfBorder, pt.y,
			OUTER_WIDTH, sz.height, 
			null, null);
		g_graphics.drawRect(pt.x, pt.y + sz.height / 2 - halfBorder, 
			sz.width, OUTER_WIDTH, 
			null, null);
		g_graphics.brushUp();

		//
		// Inner crosshair
		//
		g_graphics.brushDownWithBrush(ASColors.blackColor());
		g_graphics.drawRect(pt.x + sz.width / 2 - halfInner, pt.y + inset,
			INNER_WIDTH, sz.height - inset * 2, 
			null, null);
		g_graphics.drawRect(pt.x + inset, pt.y + sz.height / 2 - halfInner, 
			sz.width - inset * 2, INNER_WIDTH,
			null, null);
		g_graphics.brushUp();	
	}	
}