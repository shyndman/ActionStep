/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColoredView;
import org.actionstep.ASTextRenderer;
import org.actionstep.NSApplication;
import org.actionstep.NSColor;
import org.actionstep.ASColors;
import org.actionstep.NSMovie;
import org.actionstep.NSMovieView;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.NSWindow;

/**
 * This is a test for the <code>NSMovie</code> and <code>NSMovieView</code>
 * classes.
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestMovie {
	public static function test():Void {
		//
		// Create window and app.
		//
		// Note the way we are creating the window. We MUST use lib/video.swf
		// as the content swf, so that we can access the Video object provided
		// within the swf.
		//
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRectSwf(
			new NSRect(0, 0, 320, 500), "lib/video.swf");
		wnd.setBackgroundColor(ASColors.greenColor());
		var stage:NSView = wnd.contentView();

		//
		// Create the movie object
		//
		var movie:NSMovie = (new NSMovie()).initWithContentsOfURL("test/video.flv");

		//
		// Create the movie view
		//
		var movieView:NSMovieView = new NSMovieView();
		movieView.initWithFrame(new NSRect(10, 190, 300, 300));
		movieView.setMovie(movie);
		stage.addSubview(movieView);

		//
		// Create the description
		//
		var descHolder:ASColoredView = new ASColoredView();
		descHolder.initWithFrame(new NSRect(10, 10, 300, 170));
		descHolder.setBackgroundColor(new NSColor(0xDDDDDD));
		descHolder.setBorderColor(new NSColor(0x333333));
		stage.addSubview(descHolder);

		var desc:ASTextRenderer = new ASTextRenderer();
		desc.initWithFrame(new NSRect(0, 0, 300, 170));
		desc.setDrawsBackground(false);
		desc.setWordWrap(true);
		desc.setStyleCSS("desc { font-family: Georgia; font-size: 11px; }");
		desc.setText("<desc>This example shows an NSMovie and NSMovieView in " +
		"action.<br><br>An NSMovie can represent a streamed movie (from a " +
		"Red5 or Flash Comm Server) or a progressively downloaded movie " +
		"loaded from the local webserver.<br><br>The NSMovieView provides " +
		"numerous helpful methods for controlling the playback of your movie." +
		"</desc>");
		descHolder.addSubview(desc);

		//
		// Run the application
		//
		app.run();
	}
}