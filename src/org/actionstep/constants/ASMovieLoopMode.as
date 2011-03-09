/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * The constants described in this class determine the looping mode of an
 * <code>org.actionstep.NSMovieView</code>.
 * 
 * This class is equivalent to <code>NSQTMovieLoopMode</code>, but since 
 * ActionStep does not deal with QuickTime movies, its name has been changed
 * to better reflect its purpose.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.ASMovieLoopMode extends ASConstantValue {
	
	/**
	 * Playback stops when end is reached.
	 */
	public static var ASMovieNormalPlayback:ASMovieLoopMode
		= new ASMovieLoopMode(1);
		
	/**
	 * Restarts playback at beginning when end is reached.
	 */
	public static var ASMovieLoopingPlayback:ASMovieLoopMode 
		= new ASMovieLoopMode(2);
		
	/**
	 * Playback runs forward and backward between both endpoints.
	 */
	public static var ASMovieLoopingBackAndForthPlayback:ASMovieLoopMode
		= new ASMovieLoopMode(3);

	/**
	 * Creates a new instance of the <code>ASMovieLoopMode</code> class.
	 */
	private function ASMovieLoopMode(value:Number) {
		super(value);
	}
}