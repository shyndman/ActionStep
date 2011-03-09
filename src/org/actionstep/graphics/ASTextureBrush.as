import org.actionstep.graphics.ASBrush;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSObject;
import flash.display.BitmapData;
import flash.geom.Matrix;

/**
 * @author Scott Hyndman
 */
class org.actionstep.graphics.ASTextureBrush extends NSObject implements ASBrush {

	private var m_gradArgs:Array;

	//******************************************************
	//*                    Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>ASTextureBrush</code> class.
	 */
	public function ASTextureBrush() {
	}

	public function initWithBitmapMatrix(bitmap:BitmapData, matrix:Matrix):ASTextureBrush {
		return initWithBitmapMatrixRepeatSmoothing(bitmap, matrix, true, false);
	}

	public function initWithBitmapMatrixRepeat(bitmap:BitmapData, matrix:Matrix,
			repeat:Boolean):ASTextureBrush {
		return initWithBitmapMatrixRepeatSmoothing(bitmap, matrix, repeat, false);
	}

	public function initWithBitmapMatrixRepeatSmoothing(bitmap:BitmapData,
			matrix:Matrix, repeat:Boolean, smoothing:Boolean):ASTextureBrush {
		m_gradArgs = [bitmap, matrix, repeat, smoothing];
		return this;
	}

	//******************************************************
	//*               ASBrush implementation
	//******************************************************

	public function beginFillWithGraphics(graphics:ASGraphics):Void {
		var clip:MovieClip = graphics.clip();
		clip.beginBitmapFill.apply(clip, m_gradArgs);
	}

}