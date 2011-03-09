/* See LICENSE for copyright and terms of use */

import org.actionstep.graphics.ASGraphics;

/**
 * <p>Defines methods used by {@link org.actionstep.graphics.ASGraphics} to draw
 * fills.</p>
 * 
 * <p>The {@link org.actionstep.NSColor} and 
 * {@link org.actionstep.graphics.ASGradient} are implementation of this
 * protocol.</p>
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.graphics.ASBrush {
	public function beginFillWithGraphics(graphics:ASGraphics):Void;
}