/* See LICENSE for copyright and terms of use */

import org.actionstep.NSAnimation;
import org.actionstep.constants.NSAnimationCurve;

/**
 * <p>Invokes the method <code>animationDidAdvance</code>, which frees the delegate
 * from specifiying a large number of progress marks for a smooth animation. This is
 * also an alternative to the Cocoa-recommended subclassing of <code>NSAnimation</code>.
 * </p>
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.ASAnimation extends NSAnimation {

	private var m_start:Number;
	private var m_range:Number;

	//******************************************************
	//*                  Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>ASAnimation</code> class.
	 */
	public function ASAnimation() {
		m_start = 0;
		m_range = 1;
	}

	/**
	 * Initializes the animation.
	 */
	public function initWithDurationAnimationCurve(time:Number, curve:NSAnimationCurve):ASAnimation {
		return ASAnimation(super.initWithDurationAnimationCurve(time, curve));
	}
	
	//******************************************************
	//*         Setting end points and progress
	//******************************************************
	
	/**
	 * Sets the points the animation interpolates between.
	 * 
	 * The defaults are 0 and 1.
	 */
	public function setEndPoints(start:Number, end:Number):Void {
		m_start = start;
		m_range = end - start;
	}

	/**
	 * Overridden to call a special delegate method, and to transform the
	 * progress into a value between the animation's endpoints.
	 */
	public function setCurrentProgress(n:Number):Void {
		super.setCurrentProgress(n);
		var prog:Number = currentProgress() * m_range + m_start; 
		m_delegate["animationDidAdvance"].call(m_delegate, this, prog);
	}
}