/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.constants.NSDrawerState;
import org.actionstep.constants.NSRectEdge;
import org.actionstep.drawers.ASDrawerView;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSResponder;
import org.actionstep.NSSize;
import org.actionstep.NSTimer;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;

/**
 * <p><code>NSDrawer</code> is a user interface element that contains and 
 * displays view objects (all classes that inherit from {@link NSView}). A 
 * drawer is associated with a window, called its parent, and can appear only 
 * while its parent is visible onscreen. A drawer cannot be moved or ordered 
 * independently of a window, but is instead attached to one edge of its parent 
 * and moves along with it.</p>
 * 
 * <p>The drawer's edge is described using one of the {@link NSRectEdge} 
 * constants. Here is how each edge corresponds to the drawer's location:</p>
 * <table>
 * <tr>
 * 	<td>{@link NSRectEdge#NSMinXEdge}</td><td>The left edge of a window</td>
 * </tr>
 * <tr>
 * 	<td>{@link NSRectEdge#NSMinYEdge}</td><td>The bottom edge of a window</td>
 * </tr>
 * <tr>
 * 	<td>{@link NSRectEdge#NSMaxXEdge}</td><td>The right edge of a window</td>
 * </tr>
 * <tr>
 * 	<td>{@link NSRectEdge#NSMaxYEdge}</td><td>The top edge of a window</td>
 * </tr>
 * </table>
 * 
 * <p>The drawer class can optionally use a delegate to better control the
 * drawer's behaviour. For information on what methods this delegate can choose
 * to implement, please see the {@link org.actionstep.drawers.ASDrawerDelegate}
 * interface. The delegate can be set using {@link #setDelegate()}.</p>
 * 
 * <p>For information on the positioning and sizing of drawers, please read the
 * document at {@link http://developer.apple.com/documentation/Cocoa/Conceptual/Drawers/Concepts/DrawerSizing.html#//apple_ref/doc/uid/20001524 }</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSDrawer extends NSResponder {
		
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_state:NSDrawerState;
	private var m_queuedState:NSDrawerState;
	private var m_delegate:Object;
	
	private var m_lastParentWindow:NSWindow;
	private var m_parentWindow:NSWindow;
	private var m_parentDidChange:Boolean;
	private var m_contentView:NSView;
	private var m_drawerWindow:NSWindow;
	private var m_drawerView:ASDrawerView;
	
	private var m_preferredEdge:NSRectEdge;
	private var m_edge:NSRectEdge;
	
	private var m_contentSize:NSSize;
	private var m_minContentSize:NSSize;
	private var m_maxContentSize:NSSize;
	private var m_leadingOffset:Number;
	private var m_trailingOffset:Number;	
	
	private var m_timer:NSTimer;
	
	private var m_nc:NSNotificationCenter;
	
	//******************************************************
	//*                Creating an NSDrawer
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSDrawer</code> class.
	 */
	public function NSDrawer() {
		m_state = NSDrawerState.NSDrawerClosedState;
		m_nc = NSNotificationCenter.defaultCenter();
		m_parentDidChange = false;
		m_timer = new NSTimer();
		m_leadingOffset = m_trailingOffset = 0;
		
		//
		// Set up window and drawer view
		//
		m_drawerWindow = (new NSWindow()).initWithContentRectStyleMask(
			NSRect.ZeroRect,
			NSWindow.NSBorderlessWindowMask);
		m_drawerView = (new ASDrawerView()).initWithDrawer(this);
		m_drawerView.setAutoresizingMask(
			NSView.HeightSizable | NSView.WidthSizable);
		m_drawerWindow.setContentView(m_drawerView);
		m_drawerWindow.display();
		m_drawerWindow.rootView().setAutoresizesSubviews(true);
		m_drawerWindow.hide();
	}
	
	/**
	 * Initializes a new <code>NSDrawer</code> object with size specified by 
	 * <code>contentSize</code> and the edge to attach to specified by edge. 
	 * You must specify the parent window and content view of the drawer using 
	 * the methods included.
	 */
	public function initWithContentSizePreferredEdge(contentSize:NSSize,
			edge:NSRectEdge):NSDrawer {
		setMinContentSize(contentSize);
		setMaxContentSize(contentSize);
		setContentSize(contentSize);
		setPreferredEdge(edge);
		return this;	
	}
	
	/**
	 * Releases the drawer from memory.
	 */
	public function release():Boolean {
		super.release();
		m_timer.release();
		m_state = NSDrawerState.NSDrawerClosedState;
		setParentWindow(null);
		m_lastParentWindow = null;
		m_drawerView.release();
		return true;
	}
	
	//******************************************************
	//*            Opening and closing drawers
	//******************************************************
	
	/**
	 * <p>If the receiver is open, this method closes it.</p>
	 * 
	 * <p><code>sender</code> is the user interface element that invoked this
	 * method. It can be omitted.</p>
	 * 
	 * @see #open()
	 */
	public function close(sender:Object):Void {
		switch (m_state) {
			case NSDrawerState.NSDrawerClosedState:
			case NSDrawerState.NSDrawerClosingState:
				return;
				
			case NSDrawerState.NSDrawerOpeningState:
				m_queuedState = NSDrawerState.NSDrawerClosingState;
				return;
		}
		
		//
		// Remove the queued opening state if one exists
		//
		if (m_queuedState == NSDrawerState.NSDrawerOpeningState) {
			m_queuedState = null;
		}
		
		//
		// Ask the delegate if we should close
		//
		if (ASUtils.respondsToSelector(m_delegate, "drawerShouldClose")) {
			if (!m_delegate.drawerShouldClose(this)) {
				return;
			} 
		}
			
		//
		// Dispatch a notification and change the state.
		//
		m_state = NSDrawerState.NSDrawerClosingState;
		m_nc.postNotificationWithNameObject(NSDrawerWillCloseNotification, this);
		
		//
		// Determine the animation parameters
		//
		var startX:Number, startY:Number, endX:Number, endY:Number;
		var borderWidth:Number = ASTheme.current().drawerBorderWidth();
		var wndFrame:NSRect = parentWindow().frame();
		var sz:NSSize = contentSize();
		switch (m_edge) {
			case NSRectEdge.NSMinXEdge:
				startY = endY = wndFrame.origin.y + leadingOffset();
				startX = wndFrame.origin.x - sz.width + borderWidth;
				endX = wndFrame.origin.x;
				break;
				
			case NSRectEdge.NSMaxXEdge:
				startY = endY = wndFrame.origin.y + leadingOffset();
				endX = wndFrame.maxX() - sz.width - 2 * borderWidth;
				startX = wndFrame.maxX() - borderWidth;
				break;
				
			case NSRectEdge.NSMinYEdge:
				startX = endX = wndFrame.origin.x + leadingOffset();
				endY = wndFrame.origin.y;
				startY = endY - sz.height + borderWidth;
				break;
				
			case NSRectEdge.NSMaxYEdge:
				startX = endX = wndFrame.origin.x + leadingOffset();
				endY = wndFrame.maxY() - sz.height - 2 * borderWidth;
				startY = wndFrame.maxY() - borderWidth;
				break; 
		}
		
		//
		// Start the timer
		//
		m_timer.invalidate();
		m_timer.initWithFireDateIntervalTargetSelectorUserInfoRepeats(
			new Date(),
			.005,
			this,
			"_animateClosed",
			{
				startTime: getTimer(),
				iX: startX,
				iY: startY,
				fX: endX,
				fY: endY,
				ease: ASTheme.current().drawerEaseCloseFunction(),
				duration: ASTheme.current().drawerCloseDuration()
			},
			true);
	}
	
	/**
	 * <p>If the receiver is closed, this method opens it.</p>
	 * 
	 * <p>Calling open on an open drawer does nothing. You can get the state of a 
	 * drawer by calling {@link #state()}. If an edge is not specified, an 
	 * attempt will be made to choose an edge based on the space available to 
	 * display the drawer onscreen. If you need to ensure that a drawer opens 
	 * on a particular edge, use {@link #openOnEdge()}.</p>
	 * 
	 * <p><code>sender</code> is the user interface element that invoked this
	 * method. It can be omitted.</p>
	 * 
	 * @see #close()
	 */
	public function open(sender:Object):Void {		
		openOnEdge(m_preferredEdge);
	}
	
	/**
	 * Causes the receiver to open on the specified edge.
	 */
	public function openOnEdge(edge:NSRectEdge):Void {
		switch (m_state) {
			case NSDrawerState.NSDrawerOpenState:
			case NSDrawerState.NSDrawerOpeningState:
				return;
				
			case NSDrawerState.NSDrawerClosingState:
				m_queuedState = NSDrawerState.NSDrawerOpeningState;
				return;
		}
		
		//
		// Remove the queued closing state if one exists
		//
		if (m_queuedState == NSDrawerState.NSDrawerClosingState) {
			m_queuedState = null;
		}
		
		//
		// Ask the delegate if we should open
		//
		if (ASUtils.respondsToSelector(m_delegate, "drawerShouldOpen")) {
			if (!m_delegate.drawerShouldOpen(this)) {
				return;
			} 
		}
		
		//
		// Dispatch a notification and change the state.
		//
		m_edge = edge;
		m_state = NSDrawerState.NSDrawerOpeningState;
		m_nc.postNotificationWithNameObject(NSDrawerWillOpenNotification, this);
		
		//
		// Determine the animation parameters
		//
		var startX:Number, startY:Number, endX:Number, endY:Number, 
			width:Number, height:Number;
		var borderWidth:Number = ASTheme.current().drawerBorderWidth();
		var wndFrame:NSRect = parentWindow().frame();
		var dx:Number = 0;
		var dy:Number = 0;
		var dw:Number = 0;
		var dh:Number = 0;
		var sz:NSSize = contentSize();
		switch (m_edge) {
			case NSRectEdge.NSMinXEdge:
				startY = endY = wndFrame.origin.y + leadingOffset();
				startX = wndFrame.origin.x;
				endX = wndFrame.origin.x - sz.width - borderWidth;
				width = sz.width + borderWidth;
				height = wndFrame.size.height - leadingOffset() - trailingOffset();
				dw = borderWidth;
				break;
				
			case NSRectEdge.NSMaxXEdge:
				startY = endY = wndFrame.origin.y + leadingOffset();
				endX = wndFrame.maxX() + borderWidth;
				startX = endX - sz.width;
				width = sz.width + borderWidth;
				height = wndFrame.size.height - leadingOffset() - trailingOffset();
				dw = borderWidth;
				dx = -borderWidth;
				break;
				
			case NSRectEdge.NSMinYEdge:
				startX = endX = wndFrame.origin.x + leadingOffset();
				startY = wndFrame.origin.y;
				endY = startY - sz.height - borderWidth;
				width = wndFrame.size.width - leadingOffset() - trailingOffset();
				height = sz.height + borderWidth;
				dh = borderWidth;
				break;
				
			case NSRectEdge.NSMaxYEdge:
				startX = endX = wndFrame.origin.x + leadingOffset();
				endY = wndFrame.maxY() + borderWidth;
				startY = endY - sz.height + borderWidth;
				width = wndFrame.size.width - leadingOffset() - trailingOffset();
				height = sz.height + borderWidth;
				
				dh = borderWidth;
				dy = -borderWidth;
				break; 
		}
		
		startX += dx;
		startY += dy;
		endX += dx;
		endY += dy;
		
		//
		// Prepare for movement (size window)
		//
		var drawerRect:NSRect = new NSRect(startX, startY, width, height);
		m_drawerWindow.setFrame(drawerRect);
		m_drawerView.setFrame(NSRect.withOriginSize(new NSPoint(dx, dy),
			drawerRect.size.addSize(new NSSize(dw, dh))));

		m_drawerWindow.show();
		
		//
		// Start the timer
		//
		m_timer.invalidate();
		m_timer.initWithFireDateIntervalTargetSelectorUserInfoRepeats(
			new Date(),
			.005,
			this,
			"_animateOpen",
			{
				startTime: getTimer(),
				iX: startX,
				iY: startY,
				fX: endX,
				fY: endY,
				ease: ASTheme.current().drawerEaseOpenFunction(),
				duration: ASTheme.current().drawerOpenDuration()
			},
			true);
	}
	
	/**
	 * <p>If the receiver is closed, or in the process of either opening or 
	 * closing, it is opened. Otherwise, the drawer is closed.</p>
	 */
	public function toggle(sender:Object):Void {
		if (m_state == NSDrawerState.NSDrawerClosedState
				|| m_state == NSDrawerState.NSDrawerClosingState) {
			open();
		}
		else if (m_state == NSDrawerState.NSDrawerOpenState
				|| m_state == NSDrawerState.NSDrawerOpeningState) {
			close();
		}
	}
	
	//******************************************************
	//*               Managing drawer size
	//******************************************************
	
	/**
	 * Returns the size of the receiver’s content area.
	 * 
	 * @see #setContentSize()
	 */
	public function contentSize():NSSize {
		return m_contentSize.clone();
	}
	
	/**
	 * Sets the size of the receiver’s content area to <code>aSize</code>.
	 * 
	 * @see #contentSize()
	 * @see #setMaxContentSize()
	 * @see #setMinContentSize()
	 */
	public function setContentSize(aSize:NSSize):Void {
		m_contentSize = aSize.clone();
		
		//
		// Constrain
		//
		if (m_contentSize.width > m_maxContentSize.width) {
			m_contentSize.width = m_maxContentSize.width;
		}
		else if (m_contentSize.width < m_minContentSize.width) {
			m_contentSize.width = m_minContentSize.width;
		}
		
		if (m_contentSize.height > m_maxContentSize.height) {
			m_contentSize.height = m_maxContentSize.height;
		}
		else if (m_contentSize.width < m_minContentSize.height) {
			m_contentSize.height = m_minContentSize.height;
		}	
	}
	
	/**
	 * Returns the receiver’s leading offset.
	 * 
	 * @see #setLeadingOffset()
	 */
	public function leadingOffset():Number {
		return m_leadingOffset;
	}
	
	/**
	 * Sets the receiver’s leading offset to <code>offset</code>.
	 * 
	 * @see #leadingOffset()
	 * @see #setTrailingOffset()
	 */
	public function setLeadingOffset(offset:Number):Void {
		m_leadingOffset = offset;
	}
	
	/**
	 * <p>Returns the maximum allowed size of the content area.</p>
	 * 
	 * <p>Useful for determining if an opened drawer would fit onscreen given the 
	 * current window position.</p>
	 * 
	 * @see #setMaxContentSize()
	 */
	public function maxContentSize():NSSize {
		return m_maxContentSize.clone();
	}
	
	/**
	 * Specifies the maximum size of the receiver’s content area.
	 * 
	 * @see #maxContentSize()
	 */
	public function setMaxContentSize(aSize:NSSize):Void {
		m_maxContentSize = aSize.clone();
		
		if (m_contentSize == null) {
			return;
		}
		
		//
		// Constrain
		//
		if (m_contentSize.width > m_maxContentSize.width) {
			m_contentSize.width = m_maxContentSize.width;
		}
		if (m_contentSize.height > m_maxContentSize.height) {
			m_contentSize.height = m_maxContentSize.height;
		}
	}
	
	/**
	 * Returns the minimum allowed size of the receiver’s content area.
	 * 
	 * @see #setMinContentSize()
	 */
	public function minContentSize():NSSize {
		return m_minContentSize.clone();
	}
	
	/**
	 * Specifies the minimum size of the receiver’s content area.
	 */
	public function setMinContentSize(aSize:NSSize):Void {
		m_minContentSize = aSize.clone();
		
		if (m_contentSize == null) {
			return;
		}
		
		//
		// Constrain
		//
		if (m_contentSize.width < m_minContentSize.height) {
			m_contentSize.height = m_minContentSize.height;
		}
			
		if (m_contentSize.width < m_minContentSize.width) {
			m_contentSize.width = m_minContentSize.width;
		}
	}
	
	/**
	 * Returns the receiver’s trailing offset.
	 * 
	 * @see #setTrailingOffset()
	 */
	public function trailingOffset():Number {
		return m_trailingOffset;
	}
	
	/**
	 * Sets the receiver’s trailing offset to <code>offset</code>.
	 * 
	 * @see #trailingOffset()
	 */
	public function setTrailingOffset(offset:Number):Void {
		// TODO validate and constrain
		m_trailingOffset = offset;
	}
	
	//******************************************************
	//*              Managing drawer edges
	//******************************************************
	
	/**
	 * Returns the edge of the window that the receiver is connected to.
	 * 
	 * @see #openOnEdge()
	 * @see #preferredEdge()
	 */
	public function edge():NSRectEdge {
		return m_edge;
	}
	
	/**
	 * When the receiver is told to open and an edge is not specified at that 
	 * time, it opens on this value.
	 * 
	 * @see #setPreferredEdge()
	 */
	public function preferredEdge():NSRectEdge {
		return m_preferredEdge;
	}
	
	/**
	 * A drawer can be told to open on a specific edge. However, when the edge 
	 * is not specified, the drawer is opened on the <code>preferredEdge</code>.
	 */
	public function setPreferredEdge(preferredEdge:NSRectEdge):Void {
		m_preferredEdge = preferredEdge;
	}
	
	//******************************************************
	//*             Managing a drawer’s views
	//******************************************************
	
	/**
	 * Returns the receiver’s content view.
	 * 
	 * @see #setContentView()
	 */
	public function contentView():NSView {
		return m_contentView;
	}
	
	/**
	 * Sets the view the drawer displays to <code>aView</code>.
	 * 
	 * @see #contentView()
	 */
	public function setContentView(aView:NSView):Void {
		if (m_contentView != null) {
			m_contentView.removeFromSuperview();
		}
		
		m_contentView = aView;
		m_drawerView.addSubview(m_contentView);
	}
	
	/**
	 * <p>Returns the receiver’s parent window</p>
	 * 
	 * <p>By definition, a drawer can appear onscreen only if it has a parent.</p>
	 * 
	 * @see #setParentWindow()
	 */
	public function parentWindow():NSWindow {
		return m_parentWindow;
	}
	
	/**
	 * <p>Sets the receiver’s parent window to parent.</p>
	 * 
	 * <p>Every drawer must be associated with a parent window for a drawer to 
	 * appear onscreen. Calling {@link #setParentWindow} with a 
	 * <code>null</code> argument removes a drawer from its parent. Changes in a 
	 * drawer’s parent window do not take place while the drawer is onscreen; 
	 * they are delayed until the drawer next closes.</p>
	 */
	public function setParentWindow(parent:NSWindow):Void {
		if (m_parentWindow == parent) {
			return;
		}
		
		if (!m_parentDidChange) {
			m_parentDidChange = true;
		} else {
			m_parentWindow = m_lastParentWindow;
		}
		
		m_lastParentWindow = m_parentWindow;
		m_parentWindow = parent;
		
		//
		// Deal with parent change if we're closed.
		//
		if (state() == NSDrawerState.NSDrawerClosedState) {
			if (m_lastParentWindow != null) {
				removeFromLastParent();
			}
			
			if (m_parentWindow != null) {
				addToParent();
			}
		}
	}
	
	/**
	 * Removes the drawer from its last parent.
	 */
	private function removeFromLastParent():Void {
		m_lastParentWindow.removeDrawer(this);
		m_nc.removeObserverNameObject(this, null, m_lastParentWindow);
		
		m_lastParentWindow = null;
		m_parentDidChange = false;
	}
	
	/**
	 * Adds the drawer to the current parent.
	 */
	private function addToParent():Void {
		m_parentWindow.addDrawer(this);
		m_nc.addObserverSelectorNameObject(this, 
			"parentWindowDidResize",
			NSWindow.NSWindowDidResizeNotification,
			m_parentWindow);
	}
	
	//******************************************************
	//*          Accessing other drawer information
	//******************************************************
	
	/**
	 * Returns the state of the receiver.
	 */
	public function state():NSDrawerState {
		return m_state;
	}
	
	/**
	 * Returns the receiver’s delegate.
	 * 
	 * @see #setDelegate()
	 */
	public function delegate():Object {
		return m_delegate;
	}
	
	/**
	 * <p>You may find it useful to associate a delegate with a drawer, 
	 * especially since drawers do not open and close instantly. A drawer’s 
	 * delegate can better regulate drawer behavior. However, a drawer can be 
	 * used without a delegate.</p>
	 * 
	 * <p>For more information on how the drawer communicates with its delegate,
	 * or what functions the delegate can perform, please see the
	 * {@link org.actionstep.drawers.ASDrawerDelegate} interface. Please note
	 * that the delegate need not implement this interface, but can pick and
	 * choose from the methods it describes.</p>
	 * 
	 * @see #delegate()
	 */
	public function setDelegate(value:Object) {
		if(m_delegate != null) {
			m_nc.removeObserverNameObject(m_delegate, null, this);
		}
	
		m_delegate = value;
	
		if (value == null) {
			return;
		}
		
		mapDelegateNotification("DidClose");
		mapDelegateNotification("DidOpen");
		mapDelegateNotification("WillClose");
		mapDelegateNotification("WillOpen");
	}
	
	/**
	 * Maps a notification to a method on the delegate.
	 */
	private function mapDelegateNotification(name:String) {
		if(typeof(m_delegate["drawer"+name]) == "function") {
			m_nc.addObserverSelectorNameObject(
				m_delegate,
				"drawer"+name, // selector name
				ASUtils.intern("NSDrawer"+name+"Notification"), // notification name 
				this);
		}
	}
	
	//******************************************************
	//*              Internal properties
	//******************************************************
	
	/**
	 * For internal use only.
	 */
	public function drawerView():ASDrawerView {
		return m_drawerView;
	}
	
	/**
	 * For internal use only.
	 */
	public function drawerWindow():NSWindow {
		return m_drawerWindow;
	}
	
	//******************************************************
	//*                   Animation
	//******************************************************
	
	private function _animateClosed(timer:NSTimer):Void {
		var info:Object = timer.userInfo();
		var currentTime:Number = getTimer()-info.startTime;
		if (currentTime > info.duration) { 
			currentTime = info.duration;
		}
		
		var currentX:Number = Number(info.ease.call(null, currentTime, 
			info.iX, info.fX - info.iX, info.duration));
		var currentY:Number = Number(info.ease.call(null, currentTime, 
			info.iY, info.fY - info.iY, info.duration));
		m_drawerWindow.setFrameOrigin(new NSPoint(currentX, currentY));
		
		if (currentTime == info.duration) {
			timer.invalidate();
			_finishClose();
		}		
	}
	
	private function _finishClose():Void {
		m_drawerWindow.hide();
		m_state = NSDrawerState.NSDrawerClosedState;
		m_nc.postNotificationWithNameObject(
			NSDrawerDidCloseNotification,
			this);
		
		//
		// Deal with queued state
		//
		if (m_queuedState == NSDrawerState.NSDrawerOpeningState) {
			open();
		}
	}
	
	private function _animateOpen(timer:NSTimer):Void {
		var info:Object = timer.userInfo();
		var currentTime:Number = getTimer()-info.startTime;
		if (currentTime > info.duration) { 
			currentTime = info.duration;
		}
		
		var currentX:Number = Number(info.ease.call(null, currentTime, 
			info.iX, info.fX - info.iX, info.duration));
		var currentY:Number = Number(info.ease.call(null, currentTime, 
			info.iY, info.fY - info.iY, info.duration));
		m_drawerWindow.setFrameOrigin(new NSPoint(currentX, currentY));
		
		if (currentTime == info.duration) {
			timer.invalidate();
			_finishOpen();
		}
	}
	
	private function _finishOpen():Void {
		m_state = NSDrawerState.NSDrawerOpenState;
		m_nc.postNotificationWithNameObject(
			NSDrawerDidOpenNotification,
			this);
		
		//
		// Deal with queued state
		//
		if (m_queuedState == NSDrawerState.NSDrawerClosingState) {
			close();
		}
	}
	
	//******************************************************
	//*                 Notifications
	//******************************************************
	
	/**
	 * Posted whenever the NSDrawer is closed. The notification object is the 
	 * NSDrawer that closed. This notification does not contain a 
	 * <code>userInfo</code> dictionary.
	 */
	public static var NSDrawerDidCloseNotification:Number =
		ASUtils.intern("NSDrawerDidCloseNotification");
	
	/**
	 * Posted whenever the NSDrawer is opened. The notification object is the 
	 * NSDrawer that opened. This notification does not contain a 
	 * <code>userInfo</code> dictionary.
	 */
	public static var NSDrawerDidOpenNotification:Number =
		ASUtils.intern("NSDrawerDidOpenNotification");
		
	/**
	 * Posted whenever the NSDrawer is about to close. The notification 
	 * object is the NSDrawer about to close. This notification does not 
	 * contain a <code>userInfo</code> dictionary.
	 */
	public static var NSDrawerWillCloseNotification:Number =
		ASUtils.intern("NSDrawerWillCloseNotification");
		
	/**
	 * <p>Posted whenever the NSDrawer is about to open. The notification object 
	 * is the NSDrawer about to open. This notification does not contain a 
	 * userInfo dictionary.</p>
	 */
	public static var NSDrawerWillOpenNotification:Number =
		ASUtils.intern("NSDrawerWillOpenNotification");
}