/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSAnimationCurve;
import org.actionstep.constants.NSAnimationMode;
import org.actionstep.NSArray;
import org.actionstep.NSObject;
import org.actionstep.NSTimer;
import org.actionstep.NSException;

/**
 * <p>Objects of the NSAnimation class manage the timing and progress of
 * animations in the user interface. The class also lets you link together
 * multiple animations so that when one animation ends another one starts. It
 * does not provide any drawing support for animation and does not directly
 * deal with views, targets, or actions.</p>
 *
 * <p>NSAnimation objects have several characteristics, including duration,
 * frame rate, and animation curve, which describes the relative speed of the
 * animation over its course. You can set progress marks in an animation, each
 * of which specifies a percentage of the animation completed; when an
 * animation reaches a progress mark, it notifies its delegate and posts a
 * notification to any observers.</p>
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.NSAnimation extends NSObject {

	//******************************************************
	//*                  Members
	//******************************************************

	private static var FLOAT_ACCURACY:Number = 1E3;

	private var m_curve:NSAnimationCurve;
	private var m_mode:NSAnimationMode;
	private var m_delegate:Object;
	private var m_frameRate:Number;
	private var m_progressMarks:NSArray;

	private var m_timer:NSTimer;

	private var m_duration:Number;
	private var m_time:Number;
	private var m_progress:Number;
	private var m_value:Number;

	private var m_startAnim:Object;
	private var m_stopAnim:Object;
	private var m_startRunningAnim:Object;
	private var m_stopRunningAnim:Object;

	//******************************************************
	//*                  Construction
	//******************************************************

	/**
	 * <p>Constructs a new instance of the <code>NSAnimation</code> class.</p>
	 *
	 * <p>Should be followed with a call to
	 * {@link #initWithDurationAnimationCurve()}.</p>
	 */
	public function NSAnimation() {
		m_mode = NSAnimationMode.NSBlocking;
		m_timer = new NSTimer();
	}

	/**
	 * <p>Returns an <code>NSAnimation</code> object initialized with the
	 * specified duration and animation-curve values.</p>
	 *
	 * @throws NSException If <code>time</code> is negative.
	 */
	public function initWithDurationAnimationCurve(time:Number, curve:NSAnimationCurve):NSAnimation {
		if (time < 0) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"time must be a non-negative number",
				null);
			trace(e);
			throw e;
		}

		m_duration = time;
		m_frameRate = .01;

		if (curve == null) {
			curve = NSAnimationCurve.NSEaseInOut;
		}

		clearStartAnimation();
		clearStopAnimation();
		m_curve = curve;
		return this;
	}

	//******************************************************
	//*          Releasing the animation from memory
	//******************************************************

	public function release():Boolean {
		stopAnimation();
		
		m_delegate = null;
		m_curve = null;
		m_progressMarks = null;
		m_timer.release();
		m_timer = null;

		return super.release();;
	}

	//******************************************************
	//*              Describing the animation
	//******************************************************

	/**
	 * Returns a string representation of the NSAnimation instance.
	 */
	public function description():String {
		return "NSAnimation()";
	}

	//******************************************************
	//*                  Attributes
	//******************************************************

	public function setBlockingMode(mode:NSAnimationMode):Void {
		m_mode = mode;
	}

	public function blockingMode():NSAnimationMode {
		return m_mode;
	}

	public function setAnimationCurve(f:NSAnimationCurve):Void {
		m_curve = f;
	}

	public function animationCurve():NSAnimationCurve {
		return m_curve;
	}

	public function setDelegate(f:Object):Void {
		m_delegate = f;
	}

	public function delegate():Object {
		return m_delegate;
	}

	//******************************************************
	//*            Time and Values Attributes
	//******************************************************

	public function currentValue():Number {
		return m_value;
	}

	public function setDuration(f:Number):Void {
		m_duration = f;
	}

	public function duration():Number {
		return m_duration;
	}

	/**
	 * <p>Sets the frame rate of the receiver.</p>
	 *
	 * <p>The frame rate is the number of updates per second. In other words it should be
	 * between 0 and 1. If you want 20 updates in one seconds, then the value would be
	 * 1/20=0.05.</p>
	 */
	public function setFrameRate(f:Number):Void {
		m_frameRate = f;
	}

	public function frameRate():Number {
		return m_frameRate;
	}

	//******************************************************
	//*                  Animation Control
	//******************************************************

	public function startAnimation():Void {
		var f:Function;
		if((f=m_delegate["animationShouldStart"])!=null) {
			if(!f.call(m_delegate, this)) {
				return;
			}
		}

		m_startRunningAnim = m_startAnim;
		m_stopRunningAnim = m_stopAnim;

		m_timer.initWithFireDateIntervalTargetSelectorUserInfoRepeats(new Date(),
			m_frameRate, this, "handleTimer", {st: getTimer()}, true);
	}

	private function handleTimer(timer:NSTimer, info:Object):Void {
		//
		// Convert from milliseconds to seconds
		//
		m_time = (getTimer() - info.st)/1000;

		//
		// Prevent "overruns", ie a value exceeding the maximum value.
		//
		if(m_time >= m_duration) {
			m_time = m_duration;
			stopAnimation();
		}

		setCurrentProgress(m_time/m_duration);

		if(m_progress >= Number(m_stopRunningAnim.progress)) {
			NSAnimation(m_stopRunningAnim.anim).stopAnimation();
			m_stopRunningAnim.progress = Number.POSITIVE_INFINITY;
		} else if(m_progress >= Number(m_startRunningAnim.progress)) {
			NSAnimation(m_startRunningAnim.anim).startAnimation();
			m_startRunningAnim.progress = Number.POSITIVE_INFINITY;
		}

		updateAfterEvent();
	}

	public function stopAnimation():Void {
		if(isAnimating()) {
			m_timer.invalidate();
		}

		if(m_progress == 1) {
			m_delegate["animationDidEnd"].call(m_delegate, this);
		} else {
			m_delegate["animationDidStop"].call(m_delegate, this);
		}
	}

	public function isAnimating():Boolean {
		return m_timer.isValid();
	}

	//******************************************************
	//*            Managing Progress Marks
	//******************************************************

	public function setProgressMarks(f:NSArray):Void {
		m_progressMarks = f;
	}

	public function progressMarks():NSArray {
		return m_progressMarks;
	}

	public function addProgressMark(n:Number):Void {
		if(n<0) {
			n=0;
		} else if(n>1) {
			n=1;
		}
		m_progressMarks.addObject(n);
	}

	public function removeProgressMark(n:Number):Void {
		m_progressMarks.removeObject(n);
	}

	public function currentProgress():Number {
		return m_progress;
	}

	public function setCurrentProgress(n:Number):Void {
		if(n<0) {
			n=0;
		} else if(n>1) {
			n=1;
		}
		m_value = m_curve.currentValue(n*m_duration, 0, 1, m_duration);
		m_progress = Math.ceil(n*FLOAT_ACCURACY)/FLOAT_ACCURACY;

		if(m_progressMarks.indexOfObject(m_progress)!=NSNotFound) {
			m_delegate["animationDidReachProgressMark"].call(delegate, this, m_progress);
		}
	}

	//******************************************************
	//*                Linking Animations
	//******************************************************

	private function setStartAnimation(anim:NSAnimation, progress:Number):Void {
		m_startAnim = {progress: progress, anim: anim};
	}

	public function startWhenAnimationReachesProgress(anim:NSAnimation, progress:Number):Void {
		anim.setStartAnimation(this, progress);
	}

	public function clearStartAnimation():Void {
		m_startAnim = {progress: Number.POSITIVE_INFINITY, anim:null};
	}

	private function setStopAnimation(anim:NSAnimation, progress:Number):Void {
		m_stopAnim = {progress: progress, anim: anim};
	}

	public function stopWhenAnimationReachesProgress(anim:NSAnimation, progress:Number):Void {
		anim.setStopAnimation(this, progress);
	}

	public function clearStopAnimation():Void {
		m_stopAnim = {progress: Number.POSITIVE_INFINITY, anim:null};
	}
}