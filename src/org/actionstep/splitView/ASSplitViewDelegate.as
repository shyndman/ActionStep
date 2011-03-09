/* See LICENSE for copyright and terms of use */

import org.actionstep.NSNotification;
import org.actionstep.NSSize;
import org.actionstep.NSSplitView;
import org.actionstep.NSView;

/**
 * <p>This is not an interface that you actually need to implement. Rather, these
 * are the method signatures that the splitview will expect on its delegate</p>
 * 
 * <p>You can implement as few or as many of these methods as you like, and the
 * splitview will accomodate the delegate as required.</p>
 * 
 * @see NSSplitView
 * @see NSSplitView#setDelegate()
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.splitView.ASSplitViewDelegate {
	
	//******************************************************
	//*                Resizing subviews
	//******************************************************
	
	/**
	 * <p>Allows the delegate to specify custom sizing behavior for the subviews 
	 * of the NSSplitView <code>sender</code>.</p>
	 * 
	 * <p>If the delegate implements this method, 
	 * {@link #splitViewResizeSubviewsWithOldSize()} is invoked after the 
	 * NSSplitView is resized. The size of the NSSplitView before the user 
	 * resized it is indicated by <code>oldSize</code>; the subviews should be 
	 * resized such that the sum of the sizes of the subviews plus the sum of 
	 * the thickness of the dividers equals the size of the NSSplitView’s new 
	 * frame. You can get the thickness of a divider through the 
	 * {@link NSSplitView#dividerThickness()} method.</p>
	 * 
	 * <p>Note that if you implement this delegate method to resize subviews on 
	 * your own, the NSSplitView does not perform any error checking for you. 
	 * However, you can invoke {@link NSSplitView#adjustSubviews} to perform the
	 * default sizing behavior.</p>
	 */
	public function splitViewResizeSubviewsWithOldSize(sender:NSSplitView,
		oldSize:NSSize):Void;
		
	/**
	 * Sent by the default notification center to the delegate; 
	 * <code>aNotification</code> is always an 
	 * {@link NSSplitView#NSSplitViewWillResizeSubviewsNotification}. If the 
	 * delegate implements this method, the delegate is automatically 
	 * registered to receive this notification. This method is invoked before 
	 * the NSSplitView resizes two of its subviews in response to the 
	 * repositioning of a divider.
	 */
	public function splitViewWillResizeSubviews(aNotification:NSNotification):Void;
	
	/**
	 * Sent by the default notification center to the delegate; 
	 * <code>aNotification</code> is always an 
	 * {@link NSSplitView#NSSplitViewDidResizeSubviewsNotification}. If the 
	 * delegate implements this method, the delegate is automatically 
	 * registered to receive this notification. This method is invoked after the
	 * NSSplitView resizes two of its subviews in response to the repositioning 
	 * of a divider.
	 */
	public function splitViewDidResizeSubviews(aNotification:NSNotification):Void;
	
	//******************************************************
	//*           Constraining split position
	//******************************************************
	
	/**
	 * <p>Allows the delegate for <code>sender</code> to constrain the maximum 
	 * coordinate limit of a divider when the user drags it.</p>
	 * 
	 * <p>This method is invoked before the NSSplitView begins tracking the mouse 
	 * to position a divider. You may further constrain the limits that have 
	 * been already set, but you cannot extend the divider limits. 
	 * <code>proposedMax</code> is specified in the NSSplitView’s flipped 
	 * coordinate system. If the split bars are horizontal (views are one on top 
	 * of the other), <code>proposedMax</code> is the bottom limit. If the split 
	 * bars are vertical (views are side by side), <code>proposedMax</code> is 
	 * the right limit. The initial value of <code>proposedMax</code> is the 
	 * bottom (or right side) of the subview after the divider. <code>offset</code> 
	 * specifies the divider the user is moving, with the first divider being 0 
	 * and going up from top to bottom (or left to right).</p>
	 */
	public function splitViewConstrainMaxCoordinateOfSubviewAt(
		sender:NSSplitView, proposedMax:Number, offset:Number):Number;
		
	/**
	 * <p>Allows the delegate for <code>sender</code> to constrain the minimum 
	 * coordinate limit of a divider when the user drags it.</p>
	 * 
	 * <p>This method is invoked before the NSSplitView begins tracking the 
	 * cursor to position a divider. You may further constrain the limits that 
	 * have been already set, but you cannot extend the divider limits. 
	 * <code>proposedMin</code> is specified in the NSSplitView’s flipped 
	 * coordinate system. If the split bars are horizontal (views are one on top 
	 * of the other), <code>proposedMin</code> is the top limit. If the split 
	 * bars are vertical (views are side by side), <code>proposedMin</code> is 
	 * the left limit. The initial value of <code>proposedMin</code> is the top 
	 * (or left side) of the subview before the divider. <code>offset</code> 
	 * specifies the divider the user is moving, with the first divider being 
	 * 0 and going up from top to bottom (or left to right).</p>
	 */
	public function splitViewConstrainMinCoordinateOfSubviewAt(
		sender:NSSplitView, proposedMin:Number, offset:Number):Number;
		
	/**
	 * <p>Allows the delegate for <code>sender</code> to constrain the divider 
	 * to certain positions.</p>
	 * 
	 * <p>If the delegate implements this method, the NSSplitView calls it 
	 * repeatedly as the user moves the divider. This method returns where 
	 * you want the divider to be, given <code>proposedPosition</code>, the 
	 * cursor’s current position. <code>offset</code> is the divider the user 
	 * is moving, with the first divider being 0 and going up from top to 
	 * bottom (or from left to right).</p>
	 * 
	 * <p>For example, if a subview’s height must be a multiple of a certain 
	 * number, use this method to return the multiple nearest to 
	 * <code>proposedPosition</code>.</p>
	 */
	public function splitViewConstrainSplitPositionOfSubviewAt(
		sender:NSSplitView, proposedPosition:Number, offset:Number):Number;
		
	//******************************************************
	//*               Collapsing subview
	//******************************************************
	
	/**
	 * <p>Allows the delegate to determine whether the user can collapse and 
	 * uncollapse <code>subview</code>.</p>
	 * 
	 * <p>If this method returns <code>false</code> or is undefined, subview can’t 
	 * be collapsed. If this method returns <code>true</code>, 
	 * <code>subview</code> collapses when the user drags a divider beyond the 
	 * halfway mark between its minimum size and its edge. <code>subview</code> 
	 * uncollapses when the user drags the divider back beyond that point. To 
	 * specify the minimum size, define the methods 
	 * {@link #splitViewConstrainMaxCoordinateOfSubviewAt} and 
	 * {@link #splitViewConstrainMinCoordinateOfSubviewAt}. Note that a subview 
	 * can collapse only if you also define 
	 * {@link #splitViewConstrainMinCoordinateOfSubviewAt}.</p>
	 */
	public function splitViewCanCollapseSubview(sender:NSSplitView,
		subview:NSView):Boolean;
}