/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASDraw;
import org.actionstep.ASUtils;
import org.actionstep.constants.ASMovieErrorType;
import org.actionstep.constants.ASMovieLoopMode;
import org.actionstep.constants.ASMoviePlaybackState;
import org.actionstep.constants.ASMovieStatusType;
import org.actionstep.movie.ASMovieControllerView;
import org.actionstep.NSButton;
import org.actionstep.NSCell;
import org.actionstep.NSColor;
import org.actionstep.NSException;
import org.actionstep.NSMovie;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSSound;
import org.actionstep.NSTimer;
import org.actionstep.NSView;

/**
 * <p>This class is used to display and control an {@link NSMovie} object.</p>
 *
 * <p>Please note that to use this class, the view's window must load in a swf
 * containing a <code>MovieClip</code> named <code>"videoSymbol"</code>. This
 * movieclip must contain a Video instance named <code>video</code>. A swf
 * fitting these descriptions are provided for you by
 * <code>lib/video.swf</code>.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSMovieView extends NSView {

	//******************************************************
	//*                    Constants
	//******************************************************

	/**
	 * The linkage identifier used by the <code>MovieClip</code> containing the
	 * <code>Video</code> instance.
	 */
	private static var VIDEO_SYMBOL_LINKAGE:String = "videoSymbol";

	/**
	 * The number of seconds between autoresize checks.
	 */
	private static var AUTOSIZE_INTERVAL:Number = 0.1;
	
	/**
	 * The maximum time allowed to attempt an autoresize.
	 */
	private static var AUTOSIZE_TIMEOUT_INTERVAL:Number = 5;
	
	/**
	 * The amount of time between time updates.
	 */
	private static var UPDATE_TIME_INTERVAL:Number = 0.25;

	/**
	 * The amount of time between progress updates.
	 */	
	private static var UPDATE_PROGRESS_INTERVAL:Number = 0.25;
	
	//******************************************************
	//*                 Member variables
	//******************************************************

	private var m_movie:NSMovie;
	private var m_ns:NetStream;
	private var m_isRTMP:Boolean;
	private var m_movieSound:NSSound;
	private var m_state:ASMoviePlaybackState;
	private var m_isMuted:Boolean;
	private var m_volume:Number;
	private var m_loopMode:ASMovieLoopMode;
	private var m_playsSelectionOnly:Boolean;
	private var m_magnification:Number;
	private var m_isEditable:Boolean;
	
	private var m_waitingForAutosize:Boolean;
	private var m_autosizeTimer:NSTimer;
	private var m_autosizeTimeoutTimer:NSTimer;
	private var m_hiddenForAutosize:Boolean;
	private var m_playImmediately:Boolean;	
	
	private var m_delegate:Object;
	
	private var m_timeTimer:NSTimer;
	private var m_lastUpdateTime:Number;
	private var m_progressTimer:NSTimer;
	
	private var m_isControllerVisible:Boolean;
	private var m_controller:ASMovieControllerView;

	private var m_movieClip:MovieClip;
	private var m_movieClipDepth:Number;
	private var m_video:Video;
	
	private var m_drawsBackground:Boolean;
	private var m_backgroundColor:NSColor;

	private var m_nc:NSNotificationCenter;
	
	//******************************************************
	//*                   Construction
	//******************************************************

	/**
	 * <p>Creates a new instance of the <code>NSMovieView</code> class.</p>
	 *
	 * <p>This should be followed by a call to {@link #init()} or
	 * {@link #initWithFrame()}. </p>
	 */
	public function NSMovieView() {
		m_state = ASMoviePlaybackState.ASMovieDisconnectedState;
		m_lastUpdateTime = -1;
		m_isMuted = false;
		m_volume = 1.0;
		m_loopMode = ASMovieLoopMode.ASMovieNormalPlayback;
		m_playsSelectionOnly = false;
		m_isControllerVisible = true;
		m_magnification = 1;
		m_isEditable = true;
		m_drawsBackground = true;
		m_waitingForAutosize = false;
		m_playImmediately = false;
		m_backgroundColor = ASColors.blackColor();
		
		m_nc = NSNotificationCenter.defaultCenter();
	}

	/**
	 * Initializes the movie view with the frame rectangle of
	 * <code>frame</code>.
	 */
	public function initWithFrame(frame:NSRect):NSMovieView {
		super.initWithFrame(frame);

		//
		// Create the controller
		//
		var ctrl:ASMovieControllerView = new ASMovieControllerView();
		ctrl.initWithFrame(new NSRect(0, 0, frame.size.width, ctrl.preferredHeight()));
		setMovieController(ctrl);

		return this;
	}
	
	/**
	 * Releases the object from memory.
	 */
	public function release():Boolean {
		super.release();
		
		stopObservingMovie();
		m_movieSound = null;
		m_ns = null;
		m_movie = null;
		m_autosizeTimer.release();
		m_autosizeTimer = null;
		m_autosizeTimeoutTimer.release();
		m_autosizeTimeoutTimer = null;
		m_controller.release();
		m_controller.removeFromSuperview();
		m_controller = null;
		m_progressTimer.release();
		m_progressTimer = null;
		m_timeTimer.release();
		m_timeTimer = null;
		
		return true;
	}

	//******************************************************
	//*               Describing the view
	//******************************************************
	
	/**
	 * Returns a string representation of the NSMovieView instance.
	 */
	public function description():String {
		return "NSMovieView()";
	}

	//******************************************************
	//*                  View methods
	//******************************************************

	public function createMovieClips():Boolean {
		if (m_mcFrame != null) {
			return true;
		}
			
		m_movieClipDepth = getNextDepth();
		if (!super.createMovieClips()) {
			return false;
		}
		
		return createVideoMovieClips();
	}
	
	/**
	 * Creates video movie clips.
	 */
	private function createVideoMovieClips():Boolean {
		var depth:Number = m_movieClipDepth;
		m_movieClip = m_mcBounds.attachMovie(VIDEO_SYMBOL_LINKAGE,
			"m_movieClip", depth);

		//
		// If we weren't able to attach the movie symbol, throw an
		// exception. The root window swf must not be one that contains
		// a videoSymbol.
		//
		if (null == m_movieClip) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSGeneric,
				"The NSMovieView was not able to attach the movieclip " +
				"with the linkage " + VIDEO_SYMBOL_LINKAGE + ". Make " +
				"sure your window is initialized with a swf containing " +
				"this symbol.",
				null);
			trace(e);
			throw e;
		}

		m_video = Video(m_movieClip.video);

		//
		// If we weren't able to get the the Video instance, throw an
		// exception.
		//
		if (null == m_video) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSGeneric,
				"The NSMovieView was not able to obtain the video " +
				"instance named video from the MovieClip with the " +
				"linkage " + VIDEO_SYMBOL_LINKAGE + ". Make " +
				"sure your window is initialized with a swf containing " +
				"this symbol.",
				null);
			trace(e);
			throw e;
		}

		//
		// Associate the new movieclips with the view
		//
		m_movieClip.view = this;
		m_video["view"] = this;
		
		if (m_movie != null && !m_movie.isLoaded()) {
			return true; // keep waiting for handler
		}
		
		attachNetstreamToVideo();
		
		if (m_movie.isCapturingCamera()) {
			autosize();
		}
		else if (m_waitingForAutosize) {
			startAutosize();
		} else {
			sizeMovieClip();
		}
		
		return true;	
	}
	
	/**
	 * Overridden to remove the "movie" clip.
	 */
	public function removeMovieClips():Void {
		m_movieClip.removeMovieClip();
		m_movieClip = null;

		super.removeMovieClips();
	}

	/**
	 * Fired when the frame changes.
	 */
	private function frameDidChange(oldFrame:NSRect):Void {
		if (m_frame.size.isEqual(oldFrame.size)) {
			return;
		}
		
		sizeMovieClip();
		movieDidAutosize(true);
	}

	//******************************************************
	//*                 Setting a movie
	//******************************************************

	/**
	 * Returns the movie displayed by this view.
	 */
	public function movie():NSMovie {
		return m_movie;
	}

	/**
	 * Sets the <code>NSMovie</code> to be displayed by this view to
	 * <code>movie</code>.
	 */
	public function setMovie(movie:NSMovie):Void {
		stopObservingMovie();
		m_movie = movie;
		m_ns = movie.internalNetStream();
		beginObservingMovie();
		
		//
		// Mark the video as needing a resize
		//
		m_waitingForAutosize = m_movie != null;
		
		//
		// Determine whether the movie is RTMP or not
		//
		var url:String = m_movie.connection().URL();
		m_isRTMP = !(url == null || url.substr(0, 4) != "rtmp") || m_movie.isCapturingCamera();
		
		if (!m_isRTMP) {
			m_progressTimer = (new NSTimer()).initWithFireDateIntervalTargetSelectorUserInfoRepeats(
				new Date(), UPDATE_PROGRESS_INTERVAL, this, "doProgressUpdate", null, true);
		}
		
		//
		// Change the state
		//
		if (m_movie == null) {
			m_video.attachVideo(null);
			m_movieClip.attachAudio(null);
			m_video.clear();
			setState(ASMoviePlaybackState.ASMovieDisconnectedState);
			return;
		} 
		else if (m_movie.isLoaded()) {
			setState(ASMoviePlaybackState.ASMovieStoppedState);
		} else {
			setState(ASMoviePlaybackState.ASMovieLoadingState);
			return; // wait for handler
		}
				
		//
		// Attach the video
		//
		if (m_mcBounds == null) {
			return;
		}
		
		attachNetstreamToVideo();
		
		if (m_movie.isCapturingCamera()) {
			autosize();
		}
		else if (m_waitingForAutosize) {
			startAutosize();
		}
	}

	private function attachNetstreamToVideo():Void {
		if (m_movie.isCapturingCamera()) {
			m_video.attachVideo(m_movie.camera());
		} else {
			m_video.attachVideo(m_movie.internalNetStream());
		}	
	}
	
	private function attachNetstreamAudio():Void {
		//
		// Attach the audio so we can control the sound.
		//
		if (m_movie.isCapturingMicrophone()) {
			m_movieClip.attachAudio(m_movie.microphone());
		} else {
			m_movieClip.attachAudio(m_movie.internalNetStream());
		}
		
		m_movieSound = (new NSSound()).initWithSound(
			new Sound(m_movieClip));
		updateVolume();	
	}
	
	/**
	 * Unregisters this view as an observer of movie events for the current
	 * movie.
	 */
	private function stopObservingMovie():Void {
		var movie:NSMovie = movie();

		if (null == movie) {
			return;
		}

		NSNotificationCenter.defaultCenter().removeObserverNameObject(
			this,
			null,
			movie);
	}

	/**
	 * Registers this view as an observer of movie events for the current
	 * movie.
	 */
	private function beginObservingMovie():Void {
		var movie:NSMovie = movie();

		if (null == movie) {
			return;
		}

		var center:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		center.addObserverSelectorNameObject(
			this,
			"movieDidInitialize",
			NSMovie.ASMovieDidInitialize,
			m_movie);
		center.addObserverSelectorNameObject(
			this,
			"movieDidReceiveMetaData",
			NSMovie.ASMovieDidReceiveMetaData,
			m_movie);
		center.addObserverSelectorNameObject(
			this,
			"movieDidChangeStatus",
			NSMovie.ASMovieStatusDidChangeNotification,
			m_movie);
		center.addObserverSelectorNameObject(
			this,
			"movieDidEncounterError",
			NSMovie.ASMovieEncounteredErrorNotification,
			m_movie);
	}
	
	//******************************************************
	//*                Playback settings
	//******************************************************

	/**
	 * Returns whether the movie should play immediately after initializing.
	 */	
	public function playsImmediately():Boolean {
		return m_playImmediately;
	}
	
	/**
	 * Sets whether the movie should play immediately after initializing.
	 */
	public function setPlaysImmediately(flag:Boolean):Void {
		m_playImmediately = flag;
	}
	
	//******************************************************
	//*               Setting a delegate
	//******************************************************
	
	public function setDelegate(delegate:Object):Void {
		m_delegate = delegate;
	}
	
	//******************************************************
	//*                    States
	//******************************************************
	
	private function state():ASMoviePlaybackState {
		return m_state;
	}
	
	private function setState(newState:ASMoviePlaybackState):Void {
		if (m_state == newState) {
			return;
		}
		
		//
		// Do nothing if we're resizing and we hit a buffer or playback
		//
		if ((newState == ASMoviePlaybackState.ASMoviePlayingState
				|| newState == ASMoviePlaybackState.ASMovieBufferingState)
				&& m_state == ASMoviePlaybackState.ASMovieResizingState) {
			return;		
		}
		
		m_state = newState;
		
		switch (m_state) {
			case ASMoviePlaybackState.ASMovieBufferingState:
			case ASMoviePlaybackState.ASMoviePlayingState:
				if (m_timeTimer == null) {
					m_timeTimer = (new NSTimer()).initWithFireDateIntervalTargetSelectorUserInfoRepeats(
						new Date(), UPDATE_TIME_INTERVAL, this, "doTimeUpdate",
						null, true);
				}
				break;
		}
	}

	//******************************************************
	//*      Setting the appearance of the movie view
	//******************************************************

	/**
	 * <p>Returns <code>true</code> if the movie view draws a background.</p>
	 *
	 * <p>This method is ActionStep only.</p>
	 *
	 * @see #setDrawsBackground()
	 * @see #backgroundColor()
	 */
	public function drawsBackground():Boolean {
		return m_drawsBackground;
	}

	/**
	 * <p>Sets whether the movie view draws a background.</p>
	 *
	 * <p>This method is ActionStep only.</p>
	 *
	 * @see #drawsBackground()
	 */
	public function setDrawsBackground(flag:Boolean):Void {
		m_drawsBackground = flag;
	}

	/**
	 * <p>Returns the background color of the movie view.</p>
	 *
	 * <p>This method is ActionStep only.</p>
	 *
	 * @see #setBackgroundColor()
	 */
	public function backgroundColor():NSColor {
		return m_backgroundColor;
	}

	/**
	 * <p>Sets the background color of the movie view to <code>color</code>.</p>
	 *
	 * <p>This method is ActionStep only.</p>
	 *
	 * @see #backgroundColor()
	 * @see #drawsBackground()
	 */
	public function setBackgroundColor(color:NSColor):Void {
		m_backgroundColor = color;
	}

	//******************************************************
	//*                 Playing a movie
	//******************************************************

	/**
	 * <p>Sets the playhead to the beginning of the movie.</p>
	 *
	 * <p>If the movie is playing, it continues to play from the new position.</p>
	 */
	public function gotoBeginning(sender:Object):Void {
		var movie:NSMovie = movie();
		if (null == movie || movie.isLive()) {
			return;
		}

		movie.internalNetStream().seek(0);
	}

	/**
	 * <p>Sets the playhead to the end of the movie.</p>
	 *
	 * <p>This method is only available to movies that contain meta data.</p>
	 *
	 * <p>If the movie is in a loop mode, the movie will continue playing
	 * accordingly. Otherwise it is stopped.</p>
	 */
	public function gotoEnd(sender:Object):Void {
		var movie:NSMovie = movie();
		if (null == movie || movie.isLive()) {
			return;
		}

		if (!movie.hasMetaData()) {
			asWarning("Movies with no meta data cannot use the NSMovieView" +
			".gotoEnd() method.");
			return;
		}

		movie.internalNetStream().seek(movie.duration());
	}

	/**
	 * Returns <code>true</code> if the movie is playing, or <code>false</code>
	 * otherwise.
	 */
	public function isPlaying():Boolean {
		return m_state == ASMoviePlaybackState.ASMovieBufferingState
				|| m_state == ASMoviePlaybackState.ASMoviePlayingState;
	}

	/**
	 * <p>Starts the movie playing at its current location.</p>
	 *
	 * <p>This method does nothing if the movie is already playing.</p>
	 */
	public function start(sender:Object):Void {
		if (isPlaying()) {
			return;
		}

		if (sender != m_controller) {
			var btn:NSButton = m_controller.playButton();
			btn.setState(NSCell.NSOnState);
			btn.setNeedsDisplay(true);
		}

		setState(ASMoviePlaybackState.ASMoviePlayingState);

		var movie:NSMovie = movie();
		if (null != movie) {
			movie.internalNetStream().pause(false);
		}
		
		
	}

	/**
	 * <p>Sets the playhead of the movie to one frame before the current frame.</p>
	 *
	 * <p>If the movie is playing, it will stop at the new frame.</p>
	 */
	public function stepBack(sender:Object):Void {
		//! TODO Implement
	}

	/**
	 * <p>Sets the playhead of the movie to one frame after the current frame.</p>
	 *
	 * <p>If the movie is playing, it will stop at the new frame.</p>
	 */
	public function stepForward(sender:Object):Void {
		//! TODO Implement
	}

	/**
	 * <p>This action stops the movie.</p>
	 *
	 * <p>If the movie is already stopped, this method does nothing.</p>
	 */
	public function stop(sender:Object):Void {
		if (m_state == ASMoviePlaybackState.ASMovieStoppedState) {
			return;
		}
		
		if (sender != m_controller) {
			var btn:NSButton = m_controller.playButton();
			btn.setState(NSCell.NSOffState);
			btn.setNeedsDisplay(true);
		}

		setState(ASMoviePlaybackState.ASMovieStoppedState);
		
		var movie:NSMovie = movie();
		if (null != movie) {
			if (movie.isLive()) {
				
			} else {
				movie.internalNetStream().pause(true);
			}
		}
	}

	/**
	 * Seeks to a specific keyframe closest to the specified number of seconds
	 * from the beginning of the stream.
	 */
	public function seek(seconds:Number):Void {
		var m:NSMovie = m_movie;
		if (m.isLive()) {
			return;
		}
		
		setState(ASMoviePlaybackState.ASMovieSeekingState);
		if (m != null) {
			m_ns.seek(seconds);
		}
	}

	/**
	 * Returns the frame rate of the movie.
	 */
	public function rate():Number {
		var movie:NSMovie = movie();
		if (null == movie) {
			return null;
		}

		if (!movie.hasMetaData()) {
			return movie.internalNetStream().currentFps;
		} else {
			return movie.frameRate();
		}
	}

	//! TODO (void)gotoPosterFrame:(id)sender
	//! TODO (void)setRate:(float)rate

	//******************************************************
	//*                     Sound
	//******************************************************

	/**
	 * Returns <code>true</code> if the movie's sound is muted, or
	 * <code>false</code> otherwise.
	 *
	 * @see #setMuted()
	 */
	public function isMuted():Boolean {
		return m_isMuted;
	}

	/**
	 * Sets whether the movie's sound is muted. <code>true</code> mutes the
	 * sound, and <code>false</code> plays the sound.
	 *
	 * @see #isMuted()
	 */
	public function setMuted(muted:Boolean):Void {
		if (isMuted() == muted) {
			return;
		}

		m_isMuted = muted;
		updateVolume();
	}

	/**
	 * <p>Returns the volume of the movie.</p>
	 *
	 * <p>Volume is a value from 0.0 to 1.0.</p>
	 *
	 * @see #setVolume()
	 */
	public function volume():Number {
		return m_volume;
	}

	/**
	 * <p>Sets the volume of the movie to <code>volume</code>.</p>
	 *
	 * <p>Volume is value from 0.0 to 1.0.</p>
	 *
	 * @see #volume()
	 */
	public function setVolume(volume:Number):Void {
		if (volume < 0) {
			volume = 0;
		}
		else if (volume > 1) {
			volume = 1;
		}

		m_volume = volume;
		updateVolume();
	}

	/**
	 * <p>Updates the volume of the movie's sound if possible.</p>
	 */
	private function updateVolume():Void {
		if (null == m_movieSound) {
			return;
		}

		if (isMuted()) {
			m_movieSound.setVolume(0);
		} else {
			m_movieSound.setVolume(volume());
		}
	}

	//******************************************************
	//*                   Play modes
	//******************************************************

	/**
	 * <p>Returns the playback behavior of this movie view.</p>
	 */
	public function loopMode():ASMovieLoopMode {
		return m_loopMode;
	}

	/**
	 * <p>Sets the playback of the movie view to <code>loopMode</code>.</p>
	 */
	public function setLoopMode(loopMode:ASMovieLoopMode):Void {
		m_loopMode = loopMode;
	}

	/**
	 * <p>Returns <code>true</code> if the movie view only plays the selected
	 * portion of the movie.</p>
	 */
	public function playsSelectionOnly():Boolean {
		return m_playsSelectionOnly;
	}

	/**
	 * <p>Sets whether only the selected portion of the movie is played to
	 * <code>flag</code>.</p>
	 *
	 * <p>If there is no selection, the entire movie is played.</p>
	 */
	public function setPlaysSelectionOnly(flag:Boolean):Void {
		m_playsSelectionOnly = flag;
	}

	//! TODO (BOOL)playsEveryFrame
	//! TODO (void)setPlaysEveryFrame:(BOOL)flag

	//******************************************************
	//*                Setting controller
	//******************************************************

	/**
	 * Returns the controller view.
	 */
	public function movieController():ASMovieControllerView {
		return m_controller;
	}

	/**
	 * Sets the controller view of the movie view to ctrl.
	 */
	public function setMovieController(ctrl:ASMovieControllerView):Void {
		m_controller.removeFromSuperview();
		m_controller.setMovieView(null);
		
		m_controller = ctrl;
		
		m_controller.setAutoresizingMask(NSView.WidthSizable | NSView.MinYMargin);
		ctrl.setMovieView(this);
		addSubview(ctrl);
		resizeControllerView();
	}

	/**
	 * <p>Returns <code>true</code> if the movie controller is visible.</p>
	 *
	 * <p>The default is <code>true</code>.</p>
	 */
	public function isControllerVisible():Boolean {
		return m_isControllerVisible;
	}

	/**
	 * <p>Sets whether the movie controller is shown beneath the movie.</p>
	 *
	 * <p>If <code>adjustSize</code> is <code>true</code>, the height of this
	 * view will be modified so the size of the movie remains unchanged. If
	 * <code>adjustSize</code> if <code>false</code>, the movie will be scaled
	 * to fit within the frame. </p>
	 *
	 * <p>This adjustment is only made if <code>show</code> is different than the
	 * value of {@link #isControllerVisible()}.</p>
	 */
	public function showControllerAdjustingSize(show:Boolean,
			adjustSize:Boolean):Void {
		if (show == isControllerVisible()) {
			return;
		}
		
		m_controller.setHidden(!show);
		m_isControllerVisible = show;
	}

	/**
	 * Resizes the controller view to accomodate the current frame.
	 */
	private function resizeControllerView():Void {
		m_controller.setFrame(controllerFrame());
	}

	/**
	 * Returns the rectangle of the controller based on the frame size of the
	 * movie view.
	 */
	private function controllerFrame():NSRect {
		var ctrlHeight:Number = m_controller.preferredHeight();
		var frame:NSRect = frame();
		return new NSRect(0,
			frame.size.height - ctrlHeight,
			frame.size.width,
			ctrlHeight);
	}

	//******************************************************
	//*                     Sizing
	//******************************************************

	/**
	 * Returns the rectangle containing the movie.
	 */
	public function movieRect():NSRect {
		return new NSRect(m_movieClip._x, m_movieClip._y,
			m_movieClip._width, m_movieClip._height);
	}

	/**
	 * Resizes the views frame to the size required to display the movie with
	 * a magnification of <code>magnification</code> and a movie controller
	 * beneath it.
	 *
	 * @see #sizeForMagnification()
	 */
	public function resizeWithMagnification(magnification:Number):Void {
		setFrameSize(sizeForMagnification(magnification));
	}

	/**
	 * <p>Returns the size that would be required for this movie view if it was
	 * magnified by <code>magnification</code>.</p>
	 *
	 * <p>An extra 16 pixels are added to the vertical dimension to allow room for
	 * the movie controller, even if it is currently hidden.</p>
	 *
	 * @see #resizeWithMagnification()
	 */
	public function sizeForMagnification(magnification:Number):NSSize {
		var movieSize:NSSize = movieRect().size;
		movieSize.width /= m_magnification * magnification;
		movieSize.height /= m_magnification * magnification
			+ movieController().preferredHeight();

		return movieSize;
	}

	//******************************************************
	//*                    Editing
	//******************************************************

	/**
	 * <p>Returns <code>true</code> if the movie is editable.</p>
	 *
	 * <p>When a movie is editable, the {@link #clear()}, {@link #cut()},
	 * {@link #copy()}, {@link #delete()} and {@link #paste()}
	 * operations will be available. In addition, you will able to drag movies
	 * onto the view to replace the currently playing movie.</p>
	 *
	 * <p>The default is <code>true</code>.</p>
	 *
	 * @see #setEditable()
	 */
	public function isEditable():Boolean {
		return m_isEditable;
	}

	/**
	 * Sets whether the movie can be edited to <code>editable</code>.
	 *
	 * @see #isEditable()
	 */
	public function setEditable(editable:Boolean):Void {
		m_isEditable = editable;
	}

	// I'm pretty sure these methods are only really possible through tricks
	//! TODO (void)selectAll:(id)sender
	//! TODO (void)clear:(id)sender
	//! TODO (void)copy:(id)sender
	//! TODO (void)cut:(id)sender
	//! TODO (void)delete:(id)sender
	//! TODO (void)paste:(id)sender

	//******************************************************
	//*             Handling movie notifications
	//******************************************************

	/**
	 * Fired when the movie finishes initializing.
	 */
	private function movieDidInitialize(ntf:NSNotification):Void {		
		stop();
		attachNetstreamToVideo();
		if (m_waitingForAutosize) {
			startAutosize();
		}
	}
	
	/**
	 * Fired when the movie status changes.
	 */
	private function movieDidChangeStatus(ntf:NSNotification):Void {
		var status:ASMovieStatusType = ASMovieStatusType(
			ntf.userInfo.objectForKey("ASMovieStatusChange"));
		switch (status) {
			case ASMovieStatusType.ASBufferEmpty:
			
				break;
				
			case ASMovieStatusType.ASBufferFlush:
				
				break;
				
			case ASMovieStatusType.ASBufferFull:				
			case ASMovieStatusType.ASPlaybackStarted:
				

				break;
				
			case ASMovieStatusType.ASPlaybackStopped:
				trace("ASMovieStatusType.ASPlaybackStopped");
				if (loopMode() == ASMovieLoopMode.ASMovieLoopingPlayback) {
					gotoBeginning();
				} else {
					stop();
				}
				break;
			
			case ASMovieStatusType.ASSeekPerformed:
				trace("ASMovieStatusType.ASSeekPerformed");
				break;
		}
	}

	/**
	 * Fired when the movie encounters an error.
	 */
	private function movieDidEncounterError(ntf:NSNotification):Void {
		var error:ASMovieErrorType = ASMovieErrorType(ntf.userInfo.objectForKey("ASMovieErrorType"));
		trace("ERROR");
		trace(error.value);
		
		if (error == ASMovieErrorType.ASMovieNotFoundError) {
			setState(ASMoviePlaybackState.ASMovieConnectionErrorState);
		}
	}
	
	//******************************************************
	//*                  Sizing the movie
	//******************************************************

	/**
	 * Starts attempting to autosize the video.
	 */
	private function startAutosize():Void {
		if (m_state == ASMoviePlaybackState.ASMovieResizingState) {
			return;
		}
		
		m_hiddenForAutosize = false;
		
		//
		// We already have the data we need
		//
		if (m_movie.hasMetaData() && m_movie.width() != undefined 
				&& m_movie.height() != undefined) {
			autosize();
			return;
		}
		
		//
		// Set the state
		//
		setState(ASMoviePlaybackState.ASMovieResizingState);
		
		//
		// Otherwise we hide ourselves and start waiting
		//
		m_movieClip._visible = false;
		start();
		m_hiddenForAutosize = true;
		m_autosizeTimer = (new NSTimer()).initWithFireDateIntervalTargetSelectorUserInfoRepeats(
			new Date(), AUTOSIZE_INTERVAL, this, "checkAutosize", null, true);
		m_autosizeTimeoutTimer = (new NSTimer()).initWithFireDateIntervalTargetSelectorUserInfoRepeats(
			new Date(), AUTOSIZE_TIMEOUT_INTERVAL, this, "autosizeDidTimeout", null, false);
	}
	
	/**
	 * Checks to see if the video has received width and height or if metadata
	 * has arrived.
	 */
	private function checkAutosize():Void {
		var shouldAutosize:Boolean = false;
		
		//
		// See if anything has changed
		//
		if (m_video.width != 0 && m_waitingForAutosize) {
			m_movie.setWidth(m_video.width);
			m_movie.setHeight(m_video.height);
			shouldAutosize = true;
		}		
		else if (m_movie.hasMetaData() && m_movie.width() != undefined 
				&& m_movie.height() != undefined) {
			shouldAutosize = true;		
		}
		
		if (shouldAutosize) {
			autosize();
		}
	}

	/**
	 * Fired when the autosize fails to complete.
	 */
	private function autosizeDidTimeout():Void {
		m_autosizeTimer.release();
		m_autosizeTimer = null;
		m_autosizeTimeoutTimer.release();
		m_autosizeTimeoutTimer = null;

		m_waitingForAutosize = false;
		if (m_hiddenForAutosize) {
			stop();
			gotoBeginning();
			if (m_playImmediately) {
				start();
			}
			attachNetstreamAudio();
			m_movieClip._visible = true;
			m_hiddenForAutosize = false;
		}
		
		sizeMovieClip();
		
		movieDidAutosize(false);
	}

	/**
	 * Adjusts the movie size while maintaining aspect ratio.
	 */
	private function autosize():Void {
		var cam:Boolean = m_movie.isCapturingCamera();
		
		m_autosizeTimer.release();
		m_autosizeTimer = null;
		m_autosizeTimeoutTimer.release();
		m_autosizeTimeoutTimer = null;
		
		m_waitingForAutosize = false;
		if (m_hiddenForAutosize) {
			attachNetstreamAudio();
			
			if (!cam) {
				stop();
				gotoBeginning();
				if (m_playImmediately) {
					trace("playing immediately");
					start();
				}
			}
			
			m_movieClip._visible = true;
			m_hiddenForAutosize = false;
		}
		
		sizeMovieClip();
		
		movieDidAutosize(true);
	}
	
	/**
	 * Sizes the movieclip to the video.
	 */
	private function sizeMovieClip():Void {
		var maxSz:NSSize = frame().size;

		if (isControllerVisible()) {
			maxSz.height -= movieController().preferredHeight();
		}
		
		//
		// Determine the right size
		//
		var sz:NSSize;
		if (m_movie.width() != null && m_movie.height() != null) {
			sz = ASUtils.scaleSizeToSize(
				new NSSize(m_movie.width(), m_movie.height()),
				maxSz);
		} else {
			sz = maxSz;
		}
		
		//
		// Apply it to the movieclip
		//
		m_movieClip._width = sz.width;
		m_movieClip._height = sz.height;
		m_movieClip._x = (maxSz.width - sz.width) / 2;
		m_movieClip._y = (maxSz.height - sz.height) / 2;	
	}
	
	/**
	 * Called when the movie is autosized.
	 */
	private function movieDidAutosize(success:Boolean):Void {
		
	}
	
	//******************************************************
	//*                 Updating the time
	//******************************************************
	
	/**
	 * Posts a notification regarding the current playhead position.
	 */
	private function doTimeUpdate():Void {
		var time:Number = m_movie.internalNetStream().time;
		
		switch (m_state) {
			case ASMoviePlaybackState.ASMovieDisconnectedState:
			case ASMoviePlaybackState.ASMovieStoppedState:
			case ASMoviePlaybackState.ASMovieConnectionErrorState:
				m_timeTimer.release();
				m_timeTimer = null;
				break;	
		}
		
		if (time != m_lastUpdateTime) {
			m_delegate.playheadDidUpdate(time);
			m_lastUpdateTime = time;
		}
	}
	
	/**
	 * Posts a notification containing data relating to the amount of bytes
	 * downloaded from a progressive FLV.
	 */
	private function doProgressUpdate():Void {
		if (m_ns == null) {
			return;
		}
		
		var loaded:Number = m_ns.bytesLoaded;
		var total:Number = m_ns.bytesTotal;
		
		if (loaded >= 0 && total >= 0) {
			m_delegate.progressDidChange(loaded, total);
		}
		
		if (m_state == ASMoviePlaybackState.ASMovieConnectionErrorState
				|| m_state == ASMoviePlaybackState.ASMovieDisconnectedState
				|| m_ns.bytesLoaded == m_ns.bytesTotal) {
			m_progressTimer.invalidate();
			m_progressTimer = null;		
		}
	}

	//******************************************************
	//*                  Drawing the view
	//******************************************************

	/**
	 * Draws the movie view inside the area defined by <code>rect</code>.
	 */
	public function drawRect(rect:NSRect):Void {
		// FIXME hackarifica
		if (m_mcBounds == null) {
			return;
		}
		
		var mc:MovieClip;
		mc = mcBounds();
		mc.clear();

		//
		// Draw the background color
		//
		if (drawsBackground()) {
			var color:NSColor = backgroundColor();
			ASDraw.fillRectWithRect(mc, rect, color.value);
		}
	
		if (isControllerVisible()) {
			m_controller.setNeedsDisplay(true);
		}
	}
}
