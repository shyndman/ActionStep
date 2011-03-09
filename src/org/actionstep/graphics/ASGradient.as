/* See LICENSE for copyright and terms of use */

import org.actionstep.graphics.ASGraphics;
import org.actionstep.graphics.ASPen;
import org.actionstep.NSObject;
import org.actionstep.graphics.ASBrush;
import org.actionstep.NSException;
import org.actionstep.NSColor;

/**
 * <p>An abstract class for drawing gradients.</p>
 *
 * <p>{@link org.actionstep.graphics.ASLinearGradient} and
 * {@link org.actionstep.graphics.ASRadialGradient} are concrete
 * implementations.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.graphics.ASGradient extends NSObject implements ASPen, ASBrush {

	public static var ANGLE_LEFT_TO_RIGHT:Number =   0;
	public static var ANGLE_TOP_TO_BOTTOM:Number =  90;
	public static var ANGLE_RIGHT_TO_LEFT:Number = 180;
	public static var ANGLE_BOTTOM_TO_TOP:Number = 270;

	/**
	 * Returns gradient fill arguments.
	 */
	private function gradientArguments():Array {
		var e:NSException = createAbstractExceptionWithName("gradientArguments");
		trace(e);
		throw e;

		return null;
	}

	/**
	 * Sets up a gradient line style on the clip handled by
	 * <code>graphics</code>.
	 */
	public function applyLineStyleWithGraphicsThickness(graphics:ASGraphics,
			thickness:Number):Void {
		graphics.__applyLineStyleWithColorThickness(new NSColor(0x000000), thickness);
		var clip:MovieClip = graphics.clip();
		clip.lineGradientStyle.apply(clip, gradientArguments());
	}

	/**
	 * Sets up a gradient line style on the clip handled by
	 * <code>graphics</code>.
	 */
	public function beginFillWithGraphics(graphics:ASGraphics):Void {
		var clip:MovieClip = graphics.clip();
		clip.beginGradientFill.apply(clip, gradientArguments());
	}

	//******************************************************
	//*                  Helper methods
	//******************************************************

	private function createAbstractExceptionWithName(name:String):NSException {
		return NSException.exceptionWithNameReasonUserInfo(
			NSException.ASAbstractMethod,
			name + " must be implemented by subclasses",
			null);
	}
}