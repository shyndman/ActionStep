/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * @author Scott Hyndman
 */
class org.actionstep.constants.ASMoviePlaybackState extends ASConstantValue {
	
	//******************************************************
	//*                    Constants
	//******************************************************
	
	public static var ASMovieDisconnectedState:ASMoviePlaybackState 
		= new ASMoviePlaybackState(1);
		
	public static var ASMovieStoppedState:ASMoviePlaybackState 
		= new ASMoviePlaybackState(2);
		
	public static var ASMoviePlayingState:ASMoviePlaybackState 
		= new ASMoviePlaybackState(3);
		
	public static var ASMovieBufferingState:ASMoviePlaybackState 
		= new ASMoviePlaybackState(4);
		
	public static var ASMovieLoadingState:ASMoviePlaybackState 
		= new ASMoviePlaybackState(5);
		
	public static var ASMovieConnectionErrorState:ASMoviePlaybackState 
		= new ASMoviePlaybackState(6);
		
	public static var ASMovieSeekingState:ASMoviePlaybackState 
		= new ASMoviePlaybackState(7);
		
	public static var ASMovieResizingState:ASMoviePlaybackState 
		= new ASMoviePlaybackState(8);
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASMoviePlaybackState</code> class.
	 */
	private function ASMoviePlaybackState(value:Number) {
		super(value);
	}
	
	/**
	 * Returns a string representation of the ASMoviePlaybackState instance.
	 */
	public function description():String {
		return "ASMoviePlaybackState(value=" + value + ")";
	}
}