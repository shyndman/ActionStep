/* See LICENSE for copyright and terms of use */

import org.actionstep.NSDrawer;
import org.actionstep.NSNotification;
import org.actionstep.NSSize;

/**
 * <p>This is not an interface that you actually need to implement. Rather, these
 * are the method signitures that the drawer will expect on its delegate</p>
 * 
 * <p>You can implement as few or as many of these methods as you like, and the
 * drawer will accomodate the delegate as required.</p>
 * 
 * @see NSDrawer
 * @see NSDrawer#setDelegate()
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.drawers.ASDrawerDelegate {
	
	//******************************************************
	//*                Opening a drawer
	//******************************************************
	
	/**
	 * Sent by the default notification center with the 
	 * {@link NSDrawer#NSDrawerDidOpenNotification} in notification immediately 
	 * after an <code>NSDrawer</code> has opened.
	 */
	public function drawerDidOpen(notification:NSNotification):Void;
	
	/**
	 * Invoked on user-initiated attempts to open a drawer by dragging it or 
	 * when the {@link NSDrawer#open} method is called. The delegate can 
	 * return <code>false</code> to prevent the sender from opening.
	 */
	public function drawerShouldOpen(sender:NSDrawer):Boolean;
	
	/**
	 * Sent by the default notification center with the 
	 * {@link NSDrawer#NSDrawerWillOpenNotification} in notification immediately 
	 * before an <code>NSDrawer</code> is opened.
	 */
	public function drawerWillOpen(notification:NSNotification):Void;
	
	//******************************************************
	//*                Resizing a drawer
	//******************************************************
	
	/**
	 * Invoked when the user resizes the drawer or parent. 
	 * <code>contentSize</code> contains the size <code>sender</code> will be 
	 * resized to. To resize to a different size, simply return the desired 
	 * size from this method; to avoid resizing, return the current size. 
	 * The receiver’s minimum and maximum size constraints have already been 
	 * applied when this method is invoked. While the user is resizing an 
	 * <code>NSDrawer</code> or its parent, the delegate is sent a series of 
	 * windowWillResize messages as the <code>NSDrawer</code> or parent window 
	 * is dragged.
	 */
	public function drawerWillResizeContentsToSize(sender:NSDrawer, 
		contentSize:NSSize):NSSize;
		
	//******************************************************
	//*                  Closing a drawer
	//******************************************************
	
	/**
	 * Sent by the default notification center with the 
	 * {@link NSDrawer#NSDrawerDidCloseNotification} in notification immediately 
	 * after an <code>NSDrawer</code> has closed.
	 */
	public function drawerDidClose(notification:NSNotification):Void;
	
	/**
	 * Invoked on user-initiated attempts to close a drawer by dragging it or 
	 * when the {@link NSDrawer#close()} method is called. The delegate can 
	 * return <code>false</code> to prevent sender from closing.
	 */
	public function drawerShouldClose(sender:NSDrawer):Boolean;
	
	/**
	 * Sent by the default notification center with the 
	 * {@link NSDrawer#NSDrawerWillCloseNotification} in notification 
	 * immediately before an <code>NSDrawer</code> is closed.
	 */
	public function drawerWillClose(notification:NSNotification):Void;
}