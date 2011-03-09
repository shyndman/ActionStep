/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Indicate the blocking mode of an NSAnimation object when it is running.
 *
 * @author Tay Ray Chuan
 */

class org.actionstep.constants.NSAnimationMode extends ASConstantValue {

	/**
	 * Requests the animation to run in the main thread in a custom run-loop mode that
	 * blocks user input. This is the default.
	 */
	public static var NSBlocking:NSAnimationMode = new NSAnimationMode(0);

	/**
	 * Requests the animation to run in a standard or specified run-loop mode that
	 * allows user input.
	 */
	public static var NSNonblocking:NSAnimationMode = new NSAnimationMode(1);

	/**
	 * Requests the animation to run in a separate thread that is spawned by the
	 * NSAnimation object. (The secondary thread has its own run loop.)
	 *
	 * Irrelevant to this implementation.
	 */
	//public static var NSNonblockingThreaded:NSAnimationMode = new NSAnimationMode(2);

	private function NSAnimationMode(value:Number) {
		super(value);
	}
}