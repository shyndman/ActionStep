/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * This class contains constants representing errors encountered with an
 * <code>NSMovie</code> instance.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.ASMovieErrorType extends ASConstantValue {
	
	/**
	 * The FLV cannot be found.
	 */
	public static var ASMovieNotFoundError:ASMovieErrorType 
		= new ASMovieErrorType(1);
	
	/**
	 * The movie has been seeked past the end of the video data that has 
	 * been downloaded, or past the end of the video data.
	 */
	public static var ASMovieInvalidTimeError:ASMovieErrorType
		= new ASMovieErrorType(2);
	
	/**
	 * Creates a new instance of <code>ASMovieErrorType</code>.
	 */
	private function ASMovieErrorType(value:Number) {
		super(value);
	}
}