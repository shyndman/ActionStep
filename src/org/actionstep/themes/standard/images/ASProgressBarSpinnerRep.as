/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.themes.ASTheme;

/**
 * This class draws the spinning indeterminate progress bar.
 * 
 * It is used by the <code>org.actionstep.NSProgressIndicator</code> class.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.images.ASProgressBarSpinnerRep 
	extends NSImageRep 
{
	public function ASProgressBarSpinnerRep() 
	{
		m_size = new NSSize(18,18);
		super();
	}

	public function description():String 
	{
		return "ASProgressBarSpinnerRep(size=" + size() + ")";
	}
	
	public function draw():Void
	{
		ASTheme.current().drawProgressBarSpinnerInRectWithClip(
			new NSRect(m_drawPoint.x, m_drawPoint.y, m_size.width, m_size.height), m_drawClip);
	}
}