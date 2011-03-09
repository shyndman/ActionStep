/* See LICENSE for copyright and terms of use */

import org.actionstep.graphics.ASGraphics;

/**
 * <p>Defines methods used by {@link org.actionstep.graphics.ASGraphics} to draw
 * lines.</p>
 * 
 * <p>The {@link org.actionstep.NSColor} and 
 * {@link org.actionstep.graphics.ASGradient} are implementation of this
 * protocol.</p>
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.graphics.ASPen {
	
	/**
	 * Applies the pen's line style to the clip handled by 
	 * <code>graphics</code>.
	 */
	public function applyLineStyleWithGraphicsThickness(graphics:ASGraphics, 
		thickness:Number):Void;
}