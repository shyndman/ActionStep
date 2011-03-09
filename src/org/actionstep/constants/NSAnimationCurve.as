/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.constants.ASConstantValue;

/**
 * <p>Describes the behaviour of the animation.</p>
 *
 * <p>Constants of this class are associated with easing equations that can be
 * accessed using the {@link #easingFunction()} method, or used to calculate
 * the animation's current value with the {@link #currentValue()} method.</p>
 *
 * <p>View the comments of specific curve constants to learn about the curve's
 * animation behaviour.</p>
 *
 * <p>Here we assume that Cocoa refers to an exponential-style tween for:
 * <code>
 * <ul>
 * <li>NSEaseInOut</li>
 * <li>NSEaseIn</li>
 * <li>NSEaseOut</li>
 * </ul>
 * </code>
 * <br/>Additional styles are provided.
 * </p>
 *
 * <p>Constants from Cocoa are of the form <code>NSAnimation&lt;style&gt;</code>,
 * while here they are of the form <code>NSAnimationCurve.NS&lt;style&gt;</code>.</p>
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.constants.NSAnimationCurve extends ASConstantValue {

	//******************************************************
  //*                   Constants (Non-Cocoa Additions)
  //******************************************************

  public static var NSEaseInOutExpo:NSAnimationCurve =
		new NSAnimationCurve(1, ASDraw.easeInOutExpo);

	public static var NSEaseInExpo:NSAnimationCurve =
		new NSAnimationCurve(2, ASDraw.easeInExpo);

	public static var NSEaseOutExpo:NSAnimationCurve =
		new NSAnimationCurve(3, ASDraw.easeOutExpo);

	/** quadratic easing in - accelerating from zero velocity */
  public static var NSEaseInQuad:NSAnimationCurve =
		new NSAnimationCurve(4, ASDraw.easeInQuad);

  /** quadratic easing out - decelerating to zero velocity */
  public static var NSEaseOutQuad:NSAnimationCurve =
		new NSAnimationCurve(5, ASDraw.easeOutQuad);

  /** quadratic easing in/out - acceleration until halfway, then deceleration */
  public static var NSEaseInOutQuad:NSAnimationCurve =
		new NSAnimationCurve(6, ASDraw.easeInOutQuad);

  /** cubic easing in - accelerating from zero velocity */
  public static var NSEaseInCubic:NSAnimationCurve =
		new NSAnimationCurve(7, ASDraw.easeInCubic);

  /** cubic easing out - decelerating to zero velocity */
  public static var NSEaseOutCubic:NSAnimationCurve =
		new NSAnimationCurve(8, ASDraw.easeOutCubic);

  /** cubic easing in/out - acceleration until halfway, then deceleration */
  public static var NSEaseInOutCubic:NSAnimationCurve =
		new NSAnimationCurve(9, ASDraw.easeInOutCubic);

  /** quartic easing in - accelerating from zero velocity */
  public static var NSEaseInQuart:NSAnimationCurve =
		new NSAnimationCurve(10, ASDraw.easeInQuart);

  /** quartic easing out - decelerating to zero velocity */
  public static var NSEaseOutQuart:NSAnimationCurve =
		new NSAnimationCurve(11, ASDraw.easeOutQuart);

  /** quartic easing in/out - acceleration until halfway, then deceleration */
  public static var NSEaseInOutQuart:NSAnimationCurve =
		new NSAnimationCurve(12, ASDraw.easeInOutQuart);

  /** quintic easing in - accelerating from zero velocity */
  public static var NSEaseInQuint:NSAnimationCurve =
		new NSAnimationCurve(13, ASDraw.easeInQuint);

  /** quintic easing out - decelerating to zero velocity */
  public static var NSEaseOutQuint:NSAnimationCurve =
		new NSAnimationCurve(14, ASDraw.easeOutQuint);

  /** quintic easing in/out - acceleration until halfway, then deceleration */
  public static var NSEaseInOutQuint:NSAnimationCurve =
		new NSAnimationCurve(15, ASDraw.easeInOutQuint);

  /** sinusoidal easing in - accelerating from zero velocity */
  public static var NSEaseInSine:NSAnimationCurve =
		new NSAnimationCurve(16, ASDraw.easeInSine);

  /** sinusoidal easing out - decelerating to zero velocity */
  public static var NSEaseOutSine:NSAnimationCurve =
		new NSAnimationCurve(17, ASDraw.easeOutSine);

  /** sinusoidal easing in/out - accelerating until halfway, then decelerating */
  public static var NSEaseInOutSine:NSAnimationCurve =
		new NSAnimationCurve(18, ASDraw.easeInOutSine);

  /** circular easing in - accelerating from zero velocity */
  public static var NSEaseInCirc:NSAnimationCurve =
		new NSAnimationCurve(19, ASDraw.easeInCirc);

  /** circular easing out - decelerating to zero velocity */
  public static var NSEaseOutCirc:NSAnimationCurve =
		new NSAnimationCurve(20, ASDraw.easeOutCirc);

  /** circular easing in/out - acceleration until halfway, then deceleration */
  public static var NSEaseInOutCirc:NSAnimationCurve =
		new NSAnimationCurve(21, ASDraw.easeInOutCirc);

	//******************************************************
  //*                   Constants (Original)
  //******************************************************

	/**
	 * Describes an S-curve in which the animation slowly speeds up and then slows down near the end
	 * of the animation. This constant is the default.
	 */
	public static var NSEaseInOut:NSAnimationCurve =
		NSEaseInOutExpo;

	/** Describes an animation that slows down as it reaches the end. */
	public static var NSEaseIn:NSAnimationCurve =
		NSEaseInExpo;

	/** Describes an animation that slowly speeds up from the start. */
	public static var NSEaseOut:NSAnimationCurve =
		NSEaseOutExpo;

	/** Describes an animation in which there is no change in frame rate. */
	public static var NSLinear:NSAnimationCurve =
		new NSAnimationCurve(0, ASDraw.linearTween);

	//******************************************************
  //*                   Members
  //******************************************************

	/** The easing function. */
	private var m_func:Function;

	/**
	 * Creates a new instance of the <code>NSAnimationCurve</code> class, with
	 * the value <code>value</code> and the easing function <code>func</code>.
	 */
	private function NSAnimationCurve(value:Number, func:Function) {
		super(value);
		m_func = func;
	}

	/**
	 * Returns this curve's easing function, that is, the mathematical function
	 * that is used to calculate positions of the animated object based on time.
	 */
	public function easingFunction():Function {
		return m_func;
	}

	/**
	 * <p>Returns the position of the animation based <code>timeElapsed</code>,
	 * <code>startValue</code>, <code>change</code> and <code>duration</code>.</p>
	 *
	 * <p>Note that <code>change</code> is the amount that the value
	 * will change over the <code>duration</code> of the animation, ie the final value.</p>
	 */
	public function currentValue(timeElapsed:Number, startValue:Number,
			change:Number, duration:Number):Number {
		return m_func(timeElapsed, startValue, change, duration);
	}
}