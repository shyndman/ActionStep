/* See LICENSE for copyright and terms of use */

import org.actionstep.ASLabel;
import org.actionstep.ASStringFormatter;
import org.actionstep.constants.NSButtonType;
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.graphics.ASGraphicUtils;
import org.actionstep.graphics.ASLinearGradient;
import org.actionstep.layout.ASHBox;
import org.actionstep.layout.ASVBox;
import org.actionstep.movie.ASMovieProgressBar;
import org.actionstep.NSArray;
import org.actionstep.NSButton;
import org.actionstep.NSCell;
import org.actionstep.NSColor;
import org.actionstep.NSFont;
import org.actionstep.NSImage;
import org.actionstep.NSMovieView;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.themes.ASThemeImageNames;

/**
 * This view provides controls to control the playback of an 
 * <code>NSMovieView</code>.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.movie.ASMovieControllerView extends NSView {
	
	private static var TIME_FORMAT:String = "%02d:%02d";
	
	//******************************************************															 
	//*                  Member variables
	//******************************************************
	
	private var m_movieView:NSMovieView;
	private var m_hbox:ASHBox;
	private var m_playButton:NSButton;
	private var m_timeLabel:ASLabel;
	private var m_progress:ASMovieProgressBar;
	private var m_mute:NSButton;
	private var m_gradient:ASLinearGradient;
	
	//******************************************************															 
	//*                    Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASMovieControllerView</code> class.
	 */
	public function ASMovieControllerView() {
	}
	
	/**
	 * Initializes the movie controller with a frame rectangle of 
	 * <code>frame</code>.
	 */
	public function initWithFrame(frame:NSRect):ASMovieControllerView {
		super.initWithFrame(frame);
		
		//
		// Build gradient
		//
		m_gradient = new ASLinearGradient(
			[new NSColor(0xefefef), new NSColor(0xdadada)],
			[90, 255],
			ASGraphicUtils.linearGradientMatrixWithRectDegrees(
				m_bounds, ASLinearGradient.ANGLE_TOP_TO_BOTTOM));
		
		//
		// Create child components
		//
		m_hbox = (new ASHBox()).init();
		m_hbox.setAutoresizingMask(NSView.WidthSizable);
		m_hbox.setBorder(3);
		addSubview(m_hbox);
		
		//
		// Play button
		//
		m_hbox.addViewEnableXResizing(playButton(), false);
		
		//
		// Progress bar / timer
		//
		m_hbox.addViewEnableXResizingWithMinXMargin(progressVBox(), true, 3);
		
		//
		// Add mute button
		//
		m_hbox.addViewEnableXResizingWithMinXMargin(muteButton(), false, 3);
		
		//
		// Size hbox
		//
		m_hbox.setFrameWidth(m_frame.size.width);
		
		return this;
	}
	
	public function playButton():NSButton {
		if (m_playButton == null) {
			m_playButton = new NSButton();
			m_playButton.initWithFrame(new NSRect(0,0,50,25));
			m_playButton.setTarget(this);
			m_playButton.setAction("didClickPlay");
			m_playButton.setImagePosition(NSCellImagePosition.NSImageOnly);
			m_playButton.setImage(NSImage.imageNamed(ASThemeImageNames.NSMovieControllerPlayRepImage));
			m_playButton.setAlternateImage(NSImage.imageNamed(ASThemeImageNames.NSMovieControllerPauseRepImage));
			m_playButton.setButtonType(NSButtonType.NSToggleButton);
		}
		
		return m_playButton;
	}
	
	private function progressVBox():ASVBox {
		var vbox:ASVBox = (new ASVBox()).init();
		vbox.setAutoresizingMask(NSView.WidthSizable);
		
		vbox.addView(timeLabel());
		vbox.addViewWithMinYMargin(progressBar(), 2);
		return vbox;
	}
	
	private function timeLabel():ASLabel {
		if (m_timeLabel == null) {
			m_timeLabel = (new ASLabel()).initWithFrame(new NSRect(
				0, 0, 80, 12));
			m_timeLabel.setAutoresizingMask(NSView.WidthSizable);
			m_timeLabel.setAlignment(NSTextAlignment.NSRightTextAlignment);
			m_timeLabel.setStringValue("00:00 / 00:00");
			m_timeLabel.setFont(NSFont.labelFontOfSize(10));
			m_timeLabel.setTextColor(new NSColor(0x808080));
		}
		
		return m_timeLabel;
	}
	
	private function progressBar():ASMovieProgressBar {
		if (m_progress == null) {
			m_progress = (new ASMovieProgressBar()).initWithFrame(new NSRect(
				0, 0, 80, 10));
			m_progress.setMinValue(0);
			m_progress.setMaxValue(1);
			m_progress.setDoubleValue(0);
			m_progress.setTarget(this);
			m_progress.setAction("progressDidSeek");
			m_progress.setAutoresizingMask(NSView.WidthSizable);
		}
		
		return m_progress;
	}
	
	private function muteButton():NSButton {
		if (m_mute == null) {
			m_mute = (new NSButton()).initWithFrame(
				new NSRect(0, 0, 25, 25));
			m_mute.setShowsBorderOnlyWhileMouseInside(true);
			m_mute.setButtonType(NSButtonType.NSToggleButton);
			m_mute.setImagePosition(NSCellImagePosition.NSImageOnly);
			m_mute.setImage(NSImage.imageNamed(ASThemeImageNames.NSMovieControllerUnmuteRepImage));
			m_mute.setAlternateImage(NSImage.imageNamed(ASThemeImageNames.NSMovieControllerMuteRepImage));
			m_mute.setTarget(this);
			m_mute.setAction("muteWasPressed");
		}
		
		return m_mute;
	}
	
	//******************************************************															 
	//*              Setting the movie view
	//******************************************************
	
	/**
	 * Returns the movie view this view is controlling.
	 */
	public function movieView():NSMovieView {
		return m_movieView;
	}
	
	/**
	 * Sets the movie view that this view should control to 
	 * <code>movieView</code>.
	 */
	public function setMovieView(movieView:NSMovieView):Void {
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		if (m_movieView != null) {
			nc.removeObserverNameObject(this, null, m_movieView);
		}
		m_movieView = movieView;
		if (m_movieView != null) {
			m_movieView.setDelegate(this);				
		}
	}
	
	//******************************************************															 
	//*           Getting the preferred height
	//******************************************************
	
	/**
	 * Returns the preferred height of the controller.
	 * 
	 * This should be overridden in subclasses.
	 */
	public function preferredHeight():Number {
		return 30;
	}
	
	//******************************************************
	//*                  Notifications
	//******************************************************
	
	private function playheadDidUpdate(time:Number):Void {
		var roundedTime:Number = Math.round(time);
		
		//
		// Change label
		//
		var seconds:Number = roundedTime % 60;
		var minutes:Number = Math.floor(roundedTime / 60);
		
		var str:String = ASStringFormatter.formatString(TIME_FORMAT, 
			NSArray.arrayWithArray([minutes, seconds]));
		
		//
		// Try to get duration
		//
		var dur:Number = m_movieView.movie().duration();
		if (dur != undefined) {
			var roundedDur:Number = Math.round(dur);
			seconds = roundedDur % 60;
			minutes = Math.floor(roundedDur / 60);
			
			str += " / " + ASStringFormatter.formatString(TIME_FORMAT, 
				NSArray.arrayWithArray([minutes, seconds]));
		}
		
		m_timeLabel.setStringValue(str);
		m_timeLabel.setNeedsDisplay(true);
		
		//
		// Change progress bar
		//
		if (dur != undefined) {
			m_progress.setDoubleValue(time / dur);
			m_progress.setNeedsDisplay(true);
		}
	}
	
	private function progressDidChange(loaded:Number, total:Number):Void {
		m_progress.setLoadProgress(loaded / total);
		m_progress.setNeedsDisplay(true);
	}
	
	//******************************************************															 
	//*                 Drawing the view
	//******************************************************
	
	/**
	 * Draws the movie controller in the area defined by <code>rect</code>.
	 */
	public function drawRect(rect:NSRect):Void {
		var g:ASGraphics = graphics();
		g.clear();
		
		g.brushDownWithBrush(m_gradient);
		g.drawRectWithRect(rect, null, null);
		g.brushUp();
	}
	
	//******************************************************															 
	//*               Responding to actions
	//******************************************************
	
	/**
	 * Fired when the play button is clicked.
	 */
	private function didClickPlay(playButton:NSButton):Void {
		var state:Number = playButton.state();
		
		if (state == NSCell.NSOnState) {
			if (m_progress.doubleValue() == 1) {
				movieView().gotoBeginning(this);
			}
			movieView().start(this);
		} else {
			movieView().stop(this);
		}
	}
	
	/**
	 * Fired when the mute button is pressed.
	 */
	private function muteWasPressed(muteButton:NSButton):Void {
		var state:Number = muteButton.state();
		
		if (state == NSCell.NSOnState) {
			movieView().setMuted(true);
		} else {
			movieView().setMuted(false);
		}
	}
	
	/**
	 * Attempts to seek to a position in the video.
	 */
	private function progressDidSeek(pb:ASMovieProgressBar):Void {
		var dur:Number = m_movieView.movie().duration();
		if (dur == null) {
			return;
		}
		
		var seconds:Number = dur * pb.doubleValue();
		m_movieView.seek(seconds);
	}
}