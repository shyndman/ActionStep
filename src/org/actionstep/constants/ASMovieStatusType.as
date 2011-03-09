/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * The constants in this class represent various movie status states for 
 * the <code>NSMovie</code> class.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.ASMovieStatusType extends ASConstantValue {
	
	/**
	 * Data is not being received quickly enough. The flow will be interrupted
	 * until the buffer refills.
	 */
	public static var ASBufferEmpty:ASMovieStatusType
		= new ASMovieStatusType(1);
	
	/**
	 * The buffer is full and the stream will begin playing.
	 */
	public static var ASBufferFull:ASMovieStatusType
		= new ASMovieStatusType(2);
	
	/**
	 * Data has finished streaming and the buffer will be emptied.
	 */
	public static var ASBufferFlush:ASMovieStatusType
		= new ASMovieStatusType(3);
	
	/**
	 * Playback has started.
	 */
	public static var ASPlaybackStarted:ASMovieStatusType
		= new ASMovieStatusType(4);
	
	/**
	 * Playback has stopped.
	 */
	public static var ASPlaybackStopped:ASMovieStatusType
		= new ASMovieStatusType(5);
	
	/**
	 * The seek operation is complete.
	 */
	public static var ASSeekPerformed:ASMovieStatusType
		= new ASMovieStatusType(6);
		
	/**
	 * Playback of a netstream has completed.
	 */
	public static var ASPlaybackComplete:ASMovieStatusType 
		= new ASMovieStatusType(7);
		
	/**
	 * A video is lagging behind during playback.
	 */
	public static var ASInsufficientBandwidth:ASMovieStatusType 
		= new ASMovieStatusType(8);
	
	/**
	 * Creates a new instance of the <code>ASMovieStatusType</code> class.
	 */
	public function ASMovieStatusType(value:Number) {
		super(value);
	}
}