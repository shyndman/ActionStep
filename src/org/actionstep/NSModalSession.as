/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSRunResponse;
import org.actionstep.NSObject;
import org.actionstep.NSWindow;

/**
 * An application uses an NSModalSession object when it begins and runs a
 * modal session. An NSModalSession object encapsulates certain information
 * about a session, such as the application and the window(s) involved.
 *
 * This is used by <code>org.actionstep.NSApplication</code>.
 *
 * @author Tay Ray Chuan
 */

class org.actionstep.NSModalSession extends NSObject {
	/** Return value of a modal loop, and controls its behaviour */
	public var runState:NSRunResponse;

	/** The level of <code>window</code> before the loop commenced */
	public var entryLevel:Number;	//not supported (yet)

	/** The window which will remain active during the modal loop */
	public var window:NSWindow;

	/** The previous modal session */
	public var previous:NSModalSession;

	//******************************************************
	//*                    Additional data (AS-specific)
	//******************************************************

	/** The window for which a modal session will be set up for */
	public var docWin:NSWindow;

	/** Is <code>window</code> a sheet? */
	public var isSheet:Boolean;

	/**
	 * Take note of the last main and key windows, so that their status can be restored when
	 * the modal session ends.
	 *
	 * This is important since {@link NSApplication#__windowWillClose} will change the
	 * key and main status of an arbitrary window.
	 *
	 */
	public var keyWindow:NSWindow;
	public var mainWindow:NSWindow;

	//******************************************************
	//*                    Target information (AS-specific)
	//******************************************************
	public var callback:Object;
	public var selector:String;

	public function NSModalSession(run:NSRunResponse) {
		if(run==null) {
			run = NSRunResponse.NSContinues;
		}
		runState = run;
		isSheet = false;
	}

	/**
	 * Not all modal sessions involve sheets, so <code>win</code> can be null.
	 */
	public function setSheet(win:NSWindow):Void {
		docWin = win;
		isSheet = (win==null) ? false : true;
	}

	public function setCallbackSelector(call:Object, sel:String):Void {
		callback = call;
		selector = sel;
	}

	public function description():String {
		return "NSModalSession(\n" +
			buildDescription(
			"callback", callback,
			"selector", selector,
			"docWin", docWin,
			"window", window,
			"has previous?", Boolean(previous!=null),
			"is sheet?", isSheet)+
			")";
	}
}