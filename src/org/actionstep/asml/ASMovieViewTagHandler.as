/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlReader;
import org.actionstep.asml.ASDefaultTagHandler;
import org.actionstep.asml.ASParsingUtils;
import org.actionstep.NSInvocation;
import org.actionstep.NSException;
import org.actionstep.NSMovieView;
import org.actionstep.NSMovie;
import org.actionstep.ASConnection;

/**
 * Handles <code>movieView</code> tags. This will handle creation of a movie
 * ({@link NSMovie}) and assigns it to the movieView (
 * {@link org.actionstep.NSMovieView}).
 * 
 * @author Scott Hyndman
 */
class org.actionstep.asml.ASMovieViewTagHandler extends ASDefaultTagHandler {
	
	/**
	 * Creates a new instance of the <code>ASMovieViewTagHandler</code> 
	 * class.
	 */
	public function ASMovieViewTagHandler(reader:ASAsmlReader) {
		super(reader);
		super.m_shouldApplyProperties = false;
	}
	
	public function parseNodeWithClassName(node:XMLNode, className:String)
			:Object {
		var obj:NSMovieView = NSMovieView(
			super.parseNodeWithClassName(node, className));
		
		//
		// Apply properties ourselves
		//
		var isControllerVisible:Boolean = Boolean(
			ASParsingUtils.extractTypedValueForAttributeKey(
			node.attributes, "isControllerVisible", true, true));
		obj.showControllerAdjustingSize(isControllerVisible, true);
		
		//
		// Create movie object
		//
		var src:Object = ASParsingUtils.extractTypedValueForAttributeKey(
			node.attributes, "src", true, null);
			
		//
		// src attribute is required
		//
		if (src == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"ASParsingException",
				"src is a required attribute of the movieView tag",
				null);
			trace(e);
			throw e;
		}
		
		var connector:Object = ASParsingUtils.extractTypedValueForAttributeKey(
			node.attributes, "connection", true, null);
		
		//
		// Postpone the movie creation operation
		//
		var createMovie:NSInvocation = NSInvocation.invocationWithTargetSelectorArguments(
			this, "createMovie", obj, src, connector);
		m_reader.addPostponedOperation(createMovie);
		
		return obj;
	}
	
	/**
	 * The deferred method that creates the movie and gives it to the movieView.
	 */
	private function createMovie(movieView:NSMovieView, src:String, 
			connector:String):Void {
		var connection:ASConnection = ASConnection(
			m_reader.asmlFile().objectForId(connector));
		var movie:NSMovie = new NSMovie();
		
		if (connection != null) {
			movie.initWithContentsOfConnectionURL(connection, src);
		} else {
			movie.initWithContentsOfURL(src);
		}
		
		movieView.setMovie(movie);
	}
}