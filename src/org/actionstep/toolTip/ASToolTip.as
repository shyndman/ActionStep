/* See LICENSE for copyright and terms of use */

import org.actionstep.ASTextRenderer;
import org.actionstep.ASUtils;
import org.actionstep.NSEvent;
import org.actionstep.NSNotification;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTimer;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;

/**
 * This class represents a tool tip. It handles styling, mouse events and
 * positioning.
 *
 * This class should never be used directly. If you wish to use tool tips in
 * your views, please see <code>NSView#setToolTip</code> or
 * <code>NSView#addToolTipRectOwnerUserData</code>.
 *
 * @author Scott Hyndman
 */
class org.actionstep.toolTip.ASToolTip extends ASTextRenderer {
	private static var g_instance:ASToolTip;
	private static var g_window:NSWindow;
	private var m_showTimer:NSTimer;
	private var m_hideTimer:NSTimer;
	private var m_ttPosition:NSPoint;
	private var m_curView:NSView;
	private var m_hideOnMouseMove:Boolean;

	/**
	 * Since there is only ever one tooltip at a time, the contructor is private
	 * and access to the instance is provided through
	 * <code>#getInstance()</code>.
	 */
	private function ASToolTip() {
		super();
		m_showTimer = new NSTimer();
		m_hideTimer = new NSTimer();
		m_rightMargin = m_leftMargin = m_topMargin = m_bottomMargin = 2;

		setStyleCSS(ASTheme.current().toolTipStyleCss());
		//setUsesEmbeddedFonts(ASTheme.current().isToolTipFontEmbedded());
		setAutomaticResize(true);
		setWordWrap(false);
	}

	/**
	 * Initializes the tooltip with a size.
	 */
	public function initWithFrame(frame:NSRect):ASToolTip {
		super.initWithFrame(frame);
		return this;
	}

	/**
	 * Adds a drop shadow to the tooltip.
	 */
	public function createMovieClips():Void {
		super.createMovieClips();

		m_textField.selectable = false;
	}

	//******************************************************
	//*              Describing the object
	//******************************************************

	/**
	 * Returns a string representation of the tool tip.
	 */
	public function description():String {
		return "ASToolTip(text=" + text() + ")";
	}

	//******************************************************
	//*                   Properties
	//******************************************************

	/**
	 * Sets the text of the tooltip.
	 *
	 * This is overriden to apply styling tags and to fix layout issues.
	 */
	public function setText(text:String):Void {
		super.setText("<tipText>" + text + "</tipText>");

		//
		// FIXME: This is bad. Figure out another way to do this.
		//
		m_automaticResize = false;
		setFrameSize(frame().size.subtractSize(new NSSize(5, 5)));
		m_automaticResize = true;
	}

	/**
	 * Returns the view for which this tooltip is currently showing text.
	 */
	public function currentView():NSView {
		return m_curView;
	}

	//******************************************************
	//*                 Private methods
	//******************************************************

	/**
	 * Called by the timer to show the tool tip.
	 */
	private function showToolTip(timer:NSTimer, event:NSEvent):Void {
		var str:String;
		var ttp:Object = event.userData.__tipTextProvider;

		if (ASUtils.respondsToSelector(ttp, "viewStringForToolTipPointUserData")) {
			str = ttp["viewStringForToolTipPointUserData"](
				event.view,
				event.userData.tag,
				event.mouseLocation,
				event.userData);
		} else {
			str = ttp.toString();
		}

		//
		// Do nothing if no tooltip.
		//
		if (str == null) {
			return;
		}

		//
		// setText will result in frame changing size, and a notification
		// will be posted. onFrameChange recieves this notification and does
		// its thing
		//
		setText(str);
		setNeedsDisplay(true);
		setHidden(false);
		resizeWindow();
		g_window.rootView().setHidden(false);
		g_window.display();

		//
		// Record whether we should hide on a mouse move event.
		//
		m_hideOnMouseMove = event.userData.__hideOnMouseMove;

		//
		// Start autopop timer.
		//
		resetAutoPopTimer();
	}

	/**
	 * Hides the tooltip.
	 */
	public function hideToolTip():Void {
		mouseExited();
	}

	/**
	 * Resizes the tooltip window for proper display. This method also accounts
	 * for any shifting that may need to occur if the tooltip is too long to
	 * display where it should.
	 */
	private function resizeWindow():Void {
		var b:NSRect = bounds();
		//
		// This is kind of bad, but whatever. We probably should be targeting
		// some known mouse location.
		//
		var ms:NSPoint = new NSPoint(_root._xmouse, _root._ymouse);
		var pt:NSPoint = ms.translate(0, 24);

		//
		// Zero out window so it doesn't interfere with stage sizes.
		//
		g_window.setFrame(NSRect.ZeroRect);

		//
		// Account for stage size
		//
		if (pt.x + b.size.width > Stage.width) {
			pt.x = Stage.width - b.size.width;
		}

		if (pt.y + b.size.height > Stage.height) {
			pt.y = ms.translate(0, -b.size.height - 4).y;
		}

		g_window.setFrame(NSRect.withOriginSize(pt, b.size));
	}

	//******************************************************
	//*                 Events Handlers
	//******************************************************

	/**
	 * Begins the initial delay timer.
	 */
	public function mouseEntered(event:NSEvent):Void {
		resetShowTimer(event);
	}

	/**
	 * Resets the autopop timer.
	 */
	public function mouseMoved(event:NSEvent):Void {
		if (isHidden()) {
			resetShowTimer(event);
		}
		else if (m_hideOnMouseMove) {
			hideToolTip();
		}
	}

	/**
	 * Stops the wait timer and hides the tooltip.
	 */
	public function mouseExited(event:NSEvent):Void {
		m_curView = null;
		m_showTimer.invalidate();
		m_hideTimer.invalidate();
		setHidden(true);
		g_window.rootView().setHidden(true);
	}

	//******************************************************
	//*                 Helper Methods
	//******************************************************

	private function resetShowTimer(event:NSEvent):Void
	{
		m_curView = event.view;
		m_showTimer.invalidate();
		m_showTimer.initWithFireDateIntervalTargetSelectorUserInfoRepeats(
		  new Date(), ASTheme.current().toolTipInitialDelay(), this,
		  "showToolTip",
		  event.copyWithZone(), false);
	}

	private function resetAutoPopTimer():Void
	{
		stopAutoPopTimer();
		m_hideTimer.initWithFireDateIntervalTargetSelectorUserInfoRepeats(
			new Date(), ASTheme.current().toolTipAutoPopDelay(), this,
			"hideToolTip", null, false);
	}

	private function stopAutoPopTimer():Void
	{
		m_hideTimer.invalidate();
	}


	//******************************************************
	//*                    Drawing
	//******************************************************

	public function drawRect(aRect:NSRect):Void {
		m_graphics.clear();
		ASTheme.current().drawToolTipWithRectInView(aRect, this);
	}

	//******************************************************
	//*        Singleton and Initialization Stuff
	//******************************************************

	/**
	 * @return Singleton instance of ASToolTip.
	 */
	public static function getInstance():ASToolTip {
		return g_instance;
	}

	/**
	 * Creates the top level window in which tool tips are drawn.
	 */
	private static function createToolTipWindow():NSWindow {
		var window:NSWindow = new NSWindow();

		//
		// These sizes are changed later
		//
		window.initWithContentRectSwf(new NSRect(0, 0, 2000, 2000),
			ASTheme.current().toolTipSwf());

		//
		// Define event handlers for the window
		//
		var delegate:Object = new Object();

		delegate.windowDidDisplay = function(notification:NSNotification) {
			window.setLevel(NSWindow.NSModalPanelWindowLevel);
		};

		window.setDelegate(delegate);
		return window;
	}

	private static var g_constructed:Boolean;

	/**
	 * Run automatically when NSApplication is constructed.
	 */
	private static function initialize():Void {
		if (g_constructed) {
			return;
		}

		g_instance = new ASToolTip();
		g_instance.initWithFrame(new NSRect(0, 0, 300, 150));
		g_window = createToolTipWindow();
		g_window.contentView().addSubview(g_instance);
		g_instance.setText("init text");
		g_instance.resizeWindow();
		g_window.display();
		g_instance.setHidden(true);
		g_window.rootView().setHidden(true);

		// existence will not be felt
		g_window.canBecomeKeyWindow = g_window.canBecomeMainWindow =
		function():Boolean {
			return false;
		};

		g_constructed = true;
	}

}