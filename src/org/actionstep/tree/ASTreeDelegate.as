/* See LICENSE for copyright and terms of use */

import org.actionstep.ASTreeView;
import org.actionstep.NSArray;
import org.actionstep.NSCell;
import org.actionstep.ASTreeCell;

/**
 * <p>This is not an interface that you actually need to implement. Rather, these
 * are the method signitures that the tree will expect on its delegate</p>
 * 
 * <p>You can implement as few or as many of these methods as you like (read
 * the method comments for special requirements), and the tree will 
 * accomodate the delegate as required.</p>
 * 
 * @see ASTree
 * @see ASTree#setDelegate()
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.tree.ASTreeDelegate {
	
	/**
	 * <p>Returns an array of <code>item</code>'s children for the tree view
	 * <code>tree</code>.</p>
	 * 
	 * <p>If <code>item</code> is <code>null</code>, the root nodes will be
	 * returned.</p>
	 * 
	 * <p>This method must be implemented.</p>
	 */
	public function treeViewChildrenOfItem(tree:ASTreeView, item:Object):NSArray;
	
	/**
	 * <p>Returns <code>true</code> if the item <code>item</code> is 
	 * expandable.</p>
	 * 
	 * <p>This method must be implemented.</p>
	 */
	public function treeViewIsItemExpandable(tree:ASTreeView, item:Object):Boolean;
	
	/**
	 * <p>Returns the depth level of the item in the tree.</p>
	 * 
	 * <p>If the item cannot be found, -1 is returned.</p>
	 * 
	 * <p>This method must be implemented.</p>
	 */
	public function treeViewLevelOfItem(tree:ASTreeView, item:Object):Number;
	
	/**
	 * <p>Returns the tree cell associated with the tree node item.</p>
	 * 
	 * <p>If no cell exists, <code>null</code> is returned.</p>
	 * 
	 * <p>This method must be implemented.</p>
	 */
	public function treeViewCellOfItem(tree:ASTreeView, item:Object):ASTreeCell;
	
	/**
	 * <p>Prepares a cell to display a tree node <code>item</code> in the tree
	 * <code>tree</code>.</p>
	 * 
	 * <p>This method must be implemented.</p>
	 */
	public function treeViewWillDisplayCellWithItem(tree:ASTreeView, cell:NSCell, 
		item:Object):Void;
}