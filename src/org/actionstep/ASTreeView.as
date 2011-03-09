/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASTreeCell;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSMatrixMode;
import org.actionstep.NSArray;
import org.actionstep.NSCell;
import org.actionstep.NSColor;
import org.actionstep.NSControl;
import org.actionstep.NSDictionary;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSMatrix;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSScroller;
import org.actionstep.NSScrollView;
import org.actionstep.NSSize;

/**
 * <p>This control displays a hierarchical set of data as a tree.</p>
 * 
 * <p>This class' {@link #delegate()} supplies its data. Please see the
 * {@link #setDelegate()} method's documentation to learn how this works,
 * or see the {@link org.actionstep.tree.ASTreeDelegate} interface.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.ASTreeView extends NSControl {

	//******************************************************
	//*                    Notifications
	//******************************************************
	
	/**
	 * <p>Posted whenever an item is collapsed in an ASTreeView object.</p>
	 * 
	 * <p>The notification object is the ASTreeView object in which an item was 
	 * collapsed. A collapsed item’s children lose their status as being 
	 * selected. The <code>userInfo</code> dictionary contains the following 
	 * information:</p>
	 * 
	 * <p><strong>"NSObject"</strong> - The item that was collapsed.</p>
	 */
	public static var ASTreeViewItemDidCollapseNotification:Number
		= ASUtils.intern("ASTreeViewItemDidCollapseNotification");
		
	/**
	 * <p>Posted whenever an item is expanded in an ASTreeView object.</p>
	 * 
	 * <p>The notification object is the ASTreeView object in which an item was 
	 * expanded. An expanded item’s children lose their status as being 
	 * selected. The <code>userInfo</code> dictionary contains the following 
	 * information:</p>
	 * 
	 * <p><strong>"NSObject"</strong> - The item that was expanded.</p>
	 */
	public static var ASTreeViewItemDidExpandNotification:Number
		= ASUtils.intern("ASTreeViewItemDidExpandNotification");
		
	/**
	 * <p>Posted whenever an item will collapse in an ASTreeView object.</p>
	 * 
	 * <p>The notification object is the ASTreeView object in which an item will 
	 * collapse. A collapsed item’s children lose their status as being 
	 * selected. The <code>userInfo</code> dictionary contains the following 
	 * information:</p>
	 * 
	 * <p><strong>"NSObject"</strong> - The item that will collapse.</p>
	 */
	public static var ASTreeViewItemWillCollapseNotification:Number
		= ASUtils.intern("ASTreeViewItemWillCollapseNotification");
		
	/**
	 * <p>Posted whenever an item is about to be expanded in an ASTreeView 
	 * object.</p>
	 * 
	 * <p>The notification object is the ASTreeView object in which an item
	 * will be expanded. An expanded item’s children lose their status as being 
	 * selected. The <code>userInfo</code> dictionary contains the following 
	 * information:</p>
	 * 
	 * <p><strong>"NSObject"</strong> - The item that will expand.</p>
	 */
	public static var ASTreeViewItemWillExpandNotification:Number
		= ASUtils.intern("ASTreeViewItemWillExpandNotification");
	
	/**
	 * <p>Posted after the tree view's selection changes.</p>
	 * 
	 * <p>No <code>userInfo</code> dictionary.</p>
	 */
	public static var ASTreeViewSelectionDidChangeNotification:Number 
		= ASUtils.intern("ASTreeViewSelectionDidChangeNotification");

	/**
	 * <p>
	 * Posted while the tree view's selection changes (mouse is still down).
	 * </p>
	 * 
	 * <p>No <code>userInfo</code> dictionary.</p>
	 */		
	public static var ASTreeViewSelectionIsChangingNotification:Number
		= ASUtils.intern("ASTreeViewSelectionIsChangingNotification");
		
	//******************************************************
	//*                      Members
	//******************************************************
	
	//
	// The internal matrix
	//
	private var m_matrix:NSMatrix;
	
	//
	// Loading related variables
	//
	/** <code>true</code> if nodes at depth 0 are loaded */
	private var m_isLoaded:Boolean;
	private var m_insertIdx:Number;
	
	//
	// Visual
	//
	private var m_backgroundColor:NSColor;
	private var m_indentPerLevel:Number;
	private var m_autoResize:Boolean;
	private var m_maxWidth:Number;
	private var m_rowHeight:Number;
	private var m_sizesToScrollView:Boolean;
	
	//
	// Pathing
	//
	private var m_expandedItems:NSArray;
	
	//
	// Target-action
	//
	private var m_target:Object;
	private var m_action:String;
	private var m_doubleAction:String;
	
	//
	// Keyboard related
	//
	private var m_acceptsArrowKeys:Boolean;
	private var m_sendsActionOnArrowKeys:Boolean;
	private var m_acceptsAlphaNumericalKeys:Boolean;
	private var m_sendsActionOnAlphaNumericalKeys:Boolean;
	private var m_charBuffer:String;
	private var m_lastKeyPressed:Number;
	
	//
	// Delegate
	//
	private var m_delegate:Object;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASTree</code> class.
	 */
	public function ASTreeView() {
		m_isLoaded = false;
		m_insertIdx = 0;
		m_indentPerLevel = 14; // TODO add to theme
		m_expandedItems = NSArray.array();
		m_acceptsArrowKeys = true;
		m_sendsActionOnArrowKeys = true;
		m_acceptsAlphaNumericalKeys = false;
		m_sendsActionOnAlphaNumericalKeys = true;
		m_autoResize = true;
		m_rowHeight = 25;
		m_backgroundColor = ASColors.whiteColor();
		m_sizesToScrollView = true;
	}

	/**
	 * Initializes the tree with a frame rectangle of <code>rect</code>.
	 */
	public function initWithFrame(rect:NSRect):ASTreeView {
		super.initWithFrame(rect);
	
		//
		// Trigger the building of the matrix
		//
		addSubview(treeMatrix());
		
		return this;
	}
	
	/**
	 * Returns the matrix used internally by the tree.
	 */
	private function treeMatrix():NSMatrix {
		if (m_matrix == null) {
			var rect:NSRect = m_frame;
			m_matrix = (new NSMatrix()).initWithFrameModeCellClassNumberOfRowsNumberOfColumns(
				NSRect.withOriginSize(NSPoint.ZeroPoint, rect.size), 
				NSMatrixMode.NSRadioModeMatrix, 
				getClass().cellClass(), 
				0, 1);
			m_maxWidth = rect.size.width;
			m_matrix.setCellSize(new NSSize(m_maxWidth, m_rowHeight));
			m_matrix.setTabKeyTraversesCells(false);
			m_matrix.setTarget(this);
			m_matrix.setAction("doClick");
			m_matrix.setDoubleAction("doDoubleClick");
			m_matrix.setAutoscroll(true);
		}
		
		return m_matrix;
	}

	//******************************************************
	//*		         Describing the object
	//******************************************************

	/**
	* Returns a string representation of the object.
	*/
	public function description():String {
		return "ASTree()";
	}

	//******************************************************
	//*              Setting the indentation
	//******************************************************
	
	/**
	 * <p>Returns the indentation level for <code>item</code>.</p>
	 * 
	 * <p>The levels are zero-based—that is, the first level of displayed items 
	 * is level 0. If item is <code>null</code> (which is the root item), –1 
	 * is returned.</p>
	 * 
	 * @see #indentationPerLevel()
	 * @see #levelForRow()
	 */
	public function levelForItem(item:Object):Number {
		if (item == null) {
			return -1;
		}
		
		return m_delegate.treeViewLevelOfItem(this, item);
	}
	
	/**
	 * <p>Returns the indentation level for <code>row</code>.</p>
	 * 
	 * <p>The levels are zero-based—that is, the first level of displayed items 
	 * is level 0. For an invalid row, –1 is returned.</p>
	 * 
	 * @see #indentationPerLevel()
	 * @see #levelForItem()
	 */
	public function levelForRow(row:Number):Number {
		var c:ASTreeCell = ASTreeCell(m_matrix.cellAtRowColumn(row, 0));
		if (c == null) {
			return -1;
		}
		
		return c.level();
	}
	
	/**
	 * <p>Returns the x-offset applied to the contents of the cell for every 
	 * level of indentation.</p>
	 * 
	 * <p>For example, if a cell has an {@link ASTreeCell#level()} value of 
	 * <code>2</code>, the contents of this cell will be offset by
	 * {@link #indentationPerLevel()} * 2 pixels to the right.</p>
	 * 
	 * @see ASTreeCell#level()
	 * @see #setIndentationPerLevel()
	 */	
	public function indentationPerLevel():Number {
		return m_indentPerLevel;
	}
	
	/**
	 * <p>Sets the x-offset applied to the contents of the cell for every level
	 * of indentation.</p>
	 * 
	 * <p>For example, if a cell has an {@link ASTreeCell#level()} value of 
	 * <code>2</code>, the contents of this cell will be offset by
	 * {@link #indentationPerLevel()} * 2 pixels to the right.</p>
	 * 
	 * @see ASTreeCell#setLevel()
	 * @see #indentationPerLevel()
	 */
	public function setIndentationPerLevel(value:Number):Void {
		m_indentPerLevel = value;
	}
	
	//******************************************************
	//*                Display properties
	//******************************************************
	
	/**
	 * <p>
	 * Returns whether the width of the tree's rows should increase and decrease
	 * automatically.
	 * </p>
	 * <p>
	 * Returns <code>true</code> when auto-resizing is enabled.
	 * </p>
	 * 
	 * @see #setAutoResize()
	 */
	public function autoResize():Boolean {
		return m_autoResize;
	}
	
	/**
	 * <p>
	 * Sets whether the width of the tree's rows should increase and decrease
	 * automatically.
	 * </p>
	 * <p>
	 * If <code>flag</code> is <code>true</code>, auto-resizing is enabled.
	 * </p>
	 * 
	 * @see #autoResize()
	 */
	public function setAutoResize(flag:Boolean):Void {
		m_autoResize = flag;
	}
	
	/**
	 * Returns the background color of the tree.
	 * 
	 * @see #setBackgroundColor()
	 */
	public function backgroundColor():NSColor {
		return m_backgroundColor;
	}
	
	/**
	 * Sets the background color of the tree.
	 * 
	 * @see #backgroundColor()
	 */
	public function setBackgroundColor(color:NSColor):Void {
		m_backgroundColor = color;
		m_matrix.setBackgroundColor(color);
	}
	
	/**
	 * <p>
	 * Returns whether the minimum width of the tree's rows should be that of
	 * its enclosing scroll view.
	 * </p>
	 * 
	 * @see #setSizeToScrollView()
	 */
	public function sizesToScrollView():Boolean {
		return m_sizesToScrollView;
	}
	
	/**
	 * <p>
	 * Sets whether the minimum width of the tree's rows should be that of
	 * its enclosing scroll view.
	 * </p>
	 * 
	 * @see #sizesToScrollView()
	 */
	public function setSizesToScrollView(flag:Boolean):Void {
		m_sizesToScrollView = flag;
	}
	
	//******************************************************
	//*               Setting the delegate
	//******************************************************
	
	/**
	 * Returns the tree's delegate.
	 */
	public function delegate():Object {
		return m_delegate;
	}
	
	/**
	 * <p>Sets the delegate of the receiver.</p>
	 * 
	 * <p><code>anObject</code> must implement a methods named 
	 * <code>treeViewChildrenOfObject()</code>,
	 * <code>treeViewWillDisplayCellWithItem()</code>,
	 * <code>treeViewLevelOfItem()</code> and
	 * <code>treeViewIsItemExpandable()</code> as described in the
	 * {@link org.actionstep.tree.ASTreeDelegate} interface or an exception is 
	 * raised.</p>
	 */
	public function setDelegate(anObject:Object):Void {
		//
		// Make sure the delegate responds to the necessary methods
		//
		var requiredMethods:Array = [
			"treeViewCellOfItem",
			"treeViewChildrenOfItem",
			"treeViewIsItemExpandable",
			"treeViewWillDisplayCellWithItem",
			"treeViewLevelOfItem"];
		var len:Number = requiredMethods.length;
		
		for (var i:Number = 0; i < len; i++) {
			if (!ASUtils.respondsToSelector(anObject, requiredMethods[i])) {				
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSInvalidArgument,
					"Delegate does respond to required method " 
						+ requiredMethods[i],
					null);
				trace(e);
				throw e;
			}	
		}		

		m_delegate = anObject;
		
		_loadDepthZero();
	}
	
	//******************************************************
	//*        Setting the behavior of arrow keys
	//******************************************************

	/** Returns <code>true</code> if the arrow keys are enabled. */
	public function acceptsArrowKeys():Boolean {
		return m_acceptsArrowKeys;
	}

	/**
	 * Enables or disables the arrow keys as used for navigating within and 
	 * between browsers.
	 */
	public function setAcceptsArrowKeys(flag:Boolean):Void {
		m_acceptsArrowKeys = flag;
	}

	/**
	 * Returns <code>false</code> if pressing an arrow key only scrolls the 
	 * browser, <code>true</code> if it also sends the action message specified 
	 * by {@link #setAction()}.
	 */
	public function sendsActionOnArrowKeys():Boolean {
		return m_sendsActionOnArrowKeys;
	}

	/**
	 * Sets whether pressing an arrow key will cause the action message to be 
	 * sent (in addition to causing scrolling). 
	 */
	public function setSendsActionOnArrowKeys(flag:Boolean):Void {
		m_sendsActionOnArrowKeys = flag;
	}
	
	//******************************************************
	//*           Selection by typing node title
	//******************************************************
	
	/**
	 * Returns <code>true</code> if the alpha numerical keys are enabled.
	 */
	public function acceptsAlphaNumericalKeys():Boolean {
		return m_acceptsAlphaNumericalKeys;
	}
	
	/**
	 * <p>Sets whether the tree allows selection by typing partial row titles
	 * on the keyboard.</p>
	 * 
	 * <p>The default is <code>false</code>.</p>
	 */
	public function setAcceptsAlphaNumericalKeys(flag:Boolean):Void {
		m_acceptsAlphaNumericalKeys = flag;
	}
	
	//******************************************************
	//*                Target and action
	//******************************************************
	
	/**
	 * Returns the target for this tree's actions.
	 * 
	 * @see #setTarget()
	 * @see #action()
	 * @see #doubleAction()
	 */
	public function target():Object {
		return m_target;
	}
	
	/**
	 * Sets the target of this tree's actions to <code>anObject</code>.
	 * 
	 * @see #setTarget()
	 * @see #action()
	 * @see #doubleAction()
	 */
	public function setTarget(anObject:Object):Void {
		m_target = anObject;
	}
	
	/**
	 * Returns the tree's action.
	 * 
	 * @see #setAction()
	 * @see doubleAction()
	 */
	public function action():String {
		return m_action;
	}
	
	/**
	 * Sets the tree's action to <code>aSelector</code>.
	 */
	public function setAction(aSelector:String):Void {
		m_action = aSelector;
	}
	
	/**
	 * Returns the tree's double-click action method.
	 * 
	 * @see #setDoubleAction()
	 * @see #action()
	 */
	public function doubleAction():String {
		return m_doubleAction;
	}
	
	/**
	 * Sets the tree's double-click action to <code>aSelector</code>.
	 */
	public function setDoubleAction(aSelector:String):Void {
		m_doubleAction = aSelector;
	}
	
	/**
	 * Sends the action message to the target. Returns <code>true</code> upon 
	 * success, <code>false</code> if no target for the message could be found.
	 */
	public function sendAction():Boolean {
		return sendActionTo(action(), target());
	}
	
	//******************************************************
	//*                  Selecting rows
	//******************************************************
	
	/**
	 * <p>Returns the row of the selected item.</p>
	 * 
	 * @see #selectRow()
	 */
	public function selectedRow():Number {
		return m_matrix.selectedRow();
	}
	
	/**
	 * Selects the item at row <code>row</code>.
	 * 
	 * @see #selectedRow()
	 */
	public function selectRow(row:Number):Void {
		m_matrix.selectCellAtRowColumn(row, 0);
	}
	
	//******************************************************
	//*          Converting between items and rows
	//******************************************************
	
	/**
	 * <p>Returns the item associated with <code>row</code>.</p>
	 * 
	 * <p>
	 * If <code>row</code> is out of bounds, <code>null</code> is returned.
	 * </p>
	 */
	public function itemAtRow(row:Number):Object {
		return ASTreeCell(m_matrix.cellAtRowColumn(row, 0)).treeNode();
	}
	
	/**
	 * <p>Returns the row associated with <code>item</code>.</p>
	 * 
	 * <p>Returns –1 if item is <code>null</code> or cannot be found.</p>
	 * 
	 * @see #itemAtRow()
	 */
	public function rowForItem(item:Object):Number {
		if (item == null) {
			return -1;
		}
		
		var cells:Array = m_matrix.cells().internalList();
		var len:Number = cells.length;
		
		for (var i:Number = 0; i < len; i++) {
			if (ASTreeCell(cells[i]).treeNode() == item) {
				return i;
			}
		}
		
		return -1;
	}
	
	//******************************************************
	//*         Expanding and collapsing the outline
	//******************************************************
	
	/**
	 * <p>Returns <code>true</code> if <code>item</code> is expandable.</p>
	 * 
	 * @see #expandItem()
	 * @see #isItemExpanded()
	 */
	public function isExpandable(item:Object):Boolean {
		return m_delegate.treeViewIsItemExpandable(this, item);
	}
	
	/**
	 * <p>Expands <code>item</code> if <code>item</code> is expandable and is not 
	 * already expanded; otherwise, does nothing.</p>
	 * 
	 * <p>If expanding takes place, posts item expanded notification.</p>
	 * 
	 * @see #expandItemExpandChildren()
	 * @see #collapseItem()
	 */
	public function expandItem(item:Object):Void {
		expandItemExpandChildren(item, false);
	} 
	
	/**
	 * <p>Expands a specified item and, optionally, its children.</p>
	 * <p>
	 * If <code>expandChildren</code> is set to <code>false</code>, expands item 
	 * only (identical to {@link #expandItem()}). If <code>expandChildren</code>
	 * is set to <code>true</code>, recursively expands item and its children. 
	 * For each item expanded, posts item expanded notification.
	 * </p>
	 * 
	 * @see #collapseItemCollapseChildren()
	 */
	public function expandItemExpandChildren(item:Object, 
			expandChildren:Boolean):Void {		
		//
		// Make sure the object is expandable and not already expanded
		//
		if (isItemExpanded(item) || !isExpandable(item)) {
			return;
		}
		
		//
		// Post will expand notification
		//
		m_notificationCenter.postNotificationWithNameObjectUserInfo(
			ASTreeViewItemWillExpandNotification,
			this,
			NSDictionary.dictionaryWithObjectForKey(item, "NSObject"));
			
		//
		// Expand node
		//
		var children:Array = m_delegate.treeViewChildrenOfItem(this, item).internalList();
		var cell:ASTreeCell = m_delegate.treeViewCellOfItem(this, children[0]);
		if (cell == null) {
			_performLoadWithItem(item, true);
		} else {
			_displayChildrenWithItem(item);
		}
		m_expandedItems.addObject(item);
		
		//
		// Post did expand notification
		//
		m_notificationCenter.postNotificationWithNameObjectUserInfo(
			ASTreeViewItemDidExpandNotification,
			this,
			NSDictionary.dictionaryWithObjectForKey(item, "NSObject"));
		
		//
		// Expand children if necessary
		//
		if (expandChildren) {
			var len:Number = children.length;
			for (var i:Number = 0; i < len; i++) {
				expandItemExpandChildren(children[i], true);
			}
		}
	}
	
	/**
	 * <p>Collapses item if item is expanded and expandable; otherwise does 
	 * nothing.</p>
	 * 
	 * <p>If collapsing takes place, posts item collapse notification.</p>
	 * 
	 * @see #expandItem()
	 */
	public function collapseItem(item:Object):Void {
		collapseItemCollapseChildren(item, false);
	}
	
	/**
	 * <p>Collapses a given item and, optionally, its children.</p>
	 * <p>
	 * If <code>collapseChildren</code> is set to <code>false</code>, collapses 
	 * item only (identical to {@link #collapseItem()}). If 
	 * <code>collapseChildren</code> is set to <code>true</code>, recursively 
	 * collapses item and its children. For each item collapsed, posts item 
	 * collapsed notification.
	 * </p>
	 * 
	 * @see #expandItemExpandChildren()
	 */
	public function collapseItemCollapseChildren(item:Object, 
			collapseChildren:Boolean):Void {
		//
		// Make sure the object isn't already collapsed
		//
		if (!isItemExpanded(item) || !isExpandable(item)) {
			return;
		}
		
		//
		// Post the will collapse notification
		//
		m_notificationCenter.postNotificationWithNameObjectUserInfo(
			ASTreeViewItemWillCollapseNotification,
			this,
			NSDictionary.dictionaryWithObjectForKey(item, "NSObject"));
			
		//
		// Collapse the item
		//
		_removeChildrenOfItem(item);
		m_expandedItems.removeObject(item);
		
		//
		// Post the did collapse notification
		//
		m_notificationCenter.postNotificationWithNameObjectUserInfo(
			ASTreeViewItemDidCollapseNotification,
			this,
			NSDictionary.dictionaryWithObjectForKey(item, "NSObject"));
			
		//
		// Recursively collapse if necessary
		//
		if (collapseChildren) {
			var children:Array = m_delegate.treeViewChildrenOfItem(this, item).internalList();
			var len:Number = children.length;
			for (var i:Number = 0; i < len; i++) {
				collapseItemCollapseChildren(children[i], true);
			}
		}
	}
	
	/**
	 * <p>Returns <code>true</code> if the item is expanded.</p>
	 * 
	 * @see #expandItem()
	 * @see #isExpandable()
	 */
	public function isItemExpanded(item:Object):Boolean {
		return item == null || m_expandedItems.containsObject(item);
	}
	
	//******************************************************
	//*                 Action handlers
	//******************************************************
	
	/**
	 * Invoked when the matrix is clicked.
	 */
	private function doClick(sender:NSMatrix):Void {
		//
		// Make this first responder
		//
		if (m_window.firstResponder() != this) {
			m_window.makeFirstResponder(this);
		}
		
		var c:ASTreeCell = ASTreeCell(sender.cell());
		if (c.isLeaf()) {
			sendAction();
			return;
		}
		
		//
		// Get everything we need
		//
		var hitRect:NSRect = c.branchHitRect();
		var pt:NSPoint = convertPointToView(
			convertPointFromView(
				m_app.currentEvent().mouseLocation, 
				null), sender); 

		//
		// See if the branch was clicked
		//
		if (hitRect.pointInRect(pt)) {
			//
			// Toggle children visibility
			//
			var node:Object = c.treeNode();
			m_insertIdx = sender.selectedRow();
			if (isItemExpanded(node)) {
				collapseItem(node);
			} else {
				expandItem(node);
			}
			
			setNeedsDisplay(true);
		} else {
			sendAction();
		}
	}
	
	/**
	 * Invoked when the matrix is double-clicked.
	 */
	private function doDoubleClick(sender:NSMatrix):Void {
		m_target[m_doubleAction](this);
	}
	
	//******************************************************
	//*                 Keyboard events
	//******************************************************
	
	public function keyDown(theEvent:NSEvent):Void {	
		var characters:String = theEvent.characters;
		var character:Number = theEvent.keyCode;
		
		//
		// Deal with arrow keys
		//		
		if (m_acceptsArrowKeys) {
			switch (character) {
				//
				// Up and down are handled by matrix
				//
				case NSUpArrowFunctionKey:
				case NSDownArrowFunctionKey:
					return;
					
				case NSLeftArrowFunctionKey: // collapse
					m_insertIdx = m_matrix.selectedRow();
					var tc:ASTreeCell = ASTreeCell(m_matrix.cell());
					var level:Number;
					var item:Object = tc.treeNode();
					if (isItemExpanded(item)) {
						collapseItem(item);
					} 
					else if ((level = tc.level()) > 0) {
						//
						// Select parent
						//
						for (var i:Number = m_insertIdx - 1; i >= 0; i--) {
							tc = ASTreeCell(m_matrix.cellAtRowColumn(i, 0));
							if (tc.level() < level) {
								selectRow(i);
								break;
							}
						}
					}
					
					return;
					
				case NSRightArrowFunctionKey: // expand
					m_insertIdx = m_matrix.selectedRow();
					var tc:ASTreeCell = ASTreeCell(m_matrix.cell());
					var item:Object = tc.treeNode();
					
					if (!isItemExpanded(item)) {
						expandItem(item);
					} else {
						//
						// Select first child, if any
						//
						var level:Number = tc.level();
						tc = ASTreeCell(m_matrix.cellAtRowColumn(m_insertIdx + 1, 0));
						if (tc.level() > level) {
							selectRow(m_insertIdx + 1);
						}
					}
					
					return;
					
				case NSTabCharacter: // tab to next/previous control
					if (theEvent.modifierFlags & NSEvent.NSShiftKeyMask) {
						m_window.selectKeyViewPrecedingView(this);
					} else {
						m_window.selectKeyViewFollowingView(this);
					}
				
					return;
			}
		}
		
		//
		// Selection by partial title matching
		//
		if (m_acceptsAlphaNumericalKeys && (character < 0xF700)
				&& characters.length > 0) {
			var m:NSMatrix = m_matrix;
			var cs:Array = m.cells().internalList();
			var c:NSCell;
			var n:Number = cs.length;
			var sv:String;
			var i:Number, s:Number;
			var match:Number;
						
			s = selectedRow();
				
			//
			// Create or modify the char buffer
			//
			if (null == m_charBuffer) {
				m_charBuffer = characters.substring(0, 1);
			} else {
				if (theEvent.timestamp - m_lastKeyPressed < 2000.0) {
					m_charBuffer += characters.substring(0, 1); 
				} else {
					m_charBuffer = characters.substring(0, 1);
				}
			}

			m_lastKeyPressed = theEvent.timestamp;
			
			//
			// See if the buffer continues to match the current selection
			//
			c = NSCell(cs[s]);
			sv = c.stringValue();
			if ((sv.length > 0) && (sv.indexOf(m_charBuffer) == 0)) {
				return;
			}
			
			//
			// Attempt to match a string value
			//	
			match = -1;
			
			//
			// Go forward
			//
			for (i = s + 1; i < n; i++) {
				c = NSCell(cs[i]);
				sv = c.stringValue();
				if ((sv.length > 0) && (sv.indexOf(m_charBuffer) == 0)) {
					match = i;
					break;
				}
			}
			
			//
			// Go backward (if we didn't match going forward)
			//
			if (match == -1) {
				for (i = 0; i < s; i++) {
					c = NSCell(cs[i]);
					sv = c.stringValue();
					if ((sv.length > 0) && (sv.indexOf(m_charBuffer) == 0)) {
						match = i;
						break;
					}
				}
			}
			
			if (match != -1) {
				m.deselectAllCells();
				selectRow(match);
				m.scrollCellToVisibleAtRowColumn(match, 0);
				return;
			}
			
			m_lastKeyPressed = 0.;
		}
		
		super.keyDown(theEvent);
	}
	
	//******************************************************
	//*                 First responder
	//******************************************************
	
	/**
	 * Always returns <code>true</code>.
	 */
	public function acceptsFirstMouse(event:NSEvent):Boolean {
		return true;
	}
	
	/**
	 * Always returns <code>true</code>.
	 */
	public function acceptsFirstResponder():Boolean {
		return true;
	}
	
	/**
	 * Passes first responder status off to the matrix.
	 */
	public function becomeFirstResponder():Boolean {
		var matrix:NSMatrix;
		var selCol:Number;
	
		if (selectedRow() == -1) {
			selectRow(0);
		}
		
		m_window.makeFirstResponder(m_matrix);
		m_matrix.setNeedsDisplay(true);
		
		return true;
	}
	
	//******************************************************
	//*                    Drawing
	//******************************************************
	
	/**
	 * Draws the tree.
	 */
	public function drawRect(rect:NSRect):Void {
		
		//
		// Load the tree roots if we haven't already
		//
		if (!m_isLoaded) {
			_loadDepthZero();
			rect.size = m_frame.size;
		}
	}
	
	/**
	 * Sizes the tree to the size of its rows.
	 */
	public function sizeToFit():Void {
		m_matrix.sizeToCells();
		var sz:NSSize = m_matrix.frame().size;
		
		if (m_sizesToScrollView) {
			var sv:NSScrollView = enclosingScrollView();
			if (sv != null) {
				var width:Number = sv.visibleRect().size.width;
				width -= NSScroller.scrollerWidth();
				if (sz.width < width) {
					sz.width = width;
					m_matrix.setFrameWidth(width);
				}
			}
		}
		
		setFrameSize(sz);
	}
	
	//******************************************************
	//*          Loading display and removing nodes
	//******************************************************
	
	/**
	 * <p>Reloads a given item and, optionally, its children.</p>
	 * <p>
	 * If <code>flag</code> is set to <code>false</code>, reloads and redisplays
	 * the data for item only. If <code>flag</code> is set to <code>true</code>,
	 * recursively reloads and redisplays the data for item and its children. It
	 * is not necessary, or efficient, to reload children if the item is not 
	 * expanded.
	 * </p>
	 */
	public function reloadItemReloadChildren(item:Object, flag:Boolean):Void {		
		var idx:Number;
		var cell:ASTreeCell;
		var toInsert:Array = [];
		m_insertIdx = -1;
		var itemHasCell:Boolean = false;
				
		if (item != null) {	
			//
			// Get the new cell
			//
			cell = m_delegate.treeViewCellOfItem(this, item);
			
			if (cell != null) {
				m_delegate.treeViewWillDisplayCellWithItem(this, cell, item);
				
				//
				// Get the insert index
				//
				idx = rowForItem(item);
				if (idx != -1) {
					toInsert.push(cell);
					itemHasCell = true;
				}
			} else {
				idx = -1;
			}
		} else {
			idx = 0;
		}
		
		//
		// If the child flag is false, do no more
		//
		if (flag) {		
			//
			// Remove all the children
			//
			_removeChildrenOfItem(item);
						
			//
			// Get the child cells
			//
			var del:Object = m_delegate;
			var items:Array = _descendantItemsForItem(item, isItemExpanded(item));
			var cnt:Number = items.length;
			for (var i:Number = 0; i < cnt; i++) {
				//
				// Get and reload the cell
				//
				cell = del.treeViewCellOfItem(this, items[i].item);
				if (cell == null) {
					cell = ASTreeCell(m_matrix.makeCell());
					cell.setTree(this);
					cell.setLoaded(true);
				}
				del.treeViewWillDisplayCellWithItem(this, cell, items[i].item);
								
				//
				// Only insert if visible
				//
				if (items[i].expanded) {
					toInsert.push(cell);
				}
			}
		}
		
		//
		// Insert the children
		//
		if (idx != -1) {
			if (itemHasCell) {
				m_matrix.removeRow(idx - 1);
			}
			
			_insertCellsAtIndex(toInsert, idx);
		} else {
			
		}
		
		m_matrix.setNeedsDisplay(true);
	}
	
	/**
	 * Loads the root nodes. 
	 */
	private function _loadDepthZero():Void {
		m_insertIdx = 0; // just to be sure
		_performLoadWithItem(null, true);
		m_isLoaded = true;
	}
	
	/**
	 * Displays the already created child cells of item in the matrix.
	 */
	private function _displayChildrenWithItem(item:Object):Void {
		var del:Object = m_delegate;
		var children:Array = del.treeViewChildrenOfItem(this, item).internalList(); 
		var count:Number = children.length;
		
		//
		// Determine insert index
		//
		m_insertIdx = _insertIndexForItem(item);
		if (m_insertIdx == -1) {
			trace(asWarning("Could not load item " + item + ". Not found."));
			return;
		}
		
		//
		// Get and insert cells
		//
		var cells:Array = _expandedChildCellsForItem(item);
		_insertCellsAtIndex(cells, m_insertIdx);
		
		//
		// Resize tree
		//
		sizeToFit();
	}
	
	/**
	 * Returns an array of cells representing the children of <code>item</code>. 
	 */
	private function _expandedChildCellsForItem(item:Object):Array {
		var del:Object = m_delegate;
		var children:Array = del.treeViewChildrenOfItem(this, item).internalList(); 
		var count:Number = children.length;
		var cells:Array = [];
		
		for (var i:Number = 0; i < count; i++) {
			var cell:ASTreeCell = del.treeViewCellOfItem(this, children[i]);
			cell.setTree(this);
			cell.setTreeNode(children[i]);
			cells.push(cell);
			
			if (isItemExpanded(children[i])) {
				cells = cells.concat(_expandedChildCellsForItem(children[i]));
			}
		}
		
		return cells;
	}
	
	/**
	 * <p>Returns an array of objects structured as follows:</p>
	 * <p><code>{expanded:Boolean, item:Object}</code></p>
	 */
	private function _descendantItemsForItem(item:Object, expanded:Boolean):Array {
		var del:Object = m_delegate;
		var children:Array = del.treeViewChildrenOfItem(this, item).internalList(); 
		var count:Number = children.length;
		var items:Array = [];
		
		for (var i:Number = 0; i < count; i++) {
			var exp:Boolean = expanded ? isItemExpanded(children[i]) : false;
			items.push({expanded: expanded, item: children[i]});
			if (del.treeViewIsItemExpandable(this, children[i])) {
				items = items.concat(_descendantItemsForItem(children[i], 
					exp));
			}
		}
		
		return items;
	}
	
	/**
	 * Removes the children of item from the tree.
	 */
	private function _removeChildrenOfItem(item:Object):Void {
		var count:Number;
		if (item == null) {
			count = m_matrix.numberOfRows();
		} else {
			count = _visibleChildCountForItem(item);
		}
				
		//
		// Determine removal index
		//
		m_insertIdx = _insertIndexForItem(item);
		
		if (m_insertIdx == -1) {
			trace(asWarning("Could not load item " + item + ". Not found."));
			return;
		}
		
		//
		// Remove rows
		//
		for (var i:Number = 0; i < count; i++) {
			m_matrix.removeRow(m_insertIdx);
		}
		
		//
		// Resize tree
		//
		if (m_matrix.numberOfRows() != 0) {
			sizeToFit();
		}
	}
	
	/**
	 * Returns the number of visible children of item.
	 */
	private function _visibleChildCountForItem(item:Object):Number {
		if (!isItemExpanded(item)) {
			return 0;
		}
		
		//
		// Get item's level
		//
		var cells:Array = m_matrix.cells().internalList();
		var level:Number;
		var idx:Number = rowForItem(item);
		if (idx == -1) {
			level = -1;
		} else {
			level = ASTreeCell(cells[idx]).level();
		}
		
		//
		// Count children who's level is higher than item's
		//
		var total:Number = 0;				
		var len:Number = cells.length;
		
		for (var i:Number = idx + 1; i < len; i++) {
			var l:Number = ASTreeCell(cells[i++]).level();
			if (l > level) {
				total++;
			} else {
				break;
			}
		}
				
		return total;
	}
	
	/**
	 * Loads the child nodes of the node represented by <code>item</code>. If
	 * <code>insert</code> is <code>true</code>, the children will also be
	 * inserted into the tree.
	 */
	private function _performLoadWithItem(item:Object, insert:Boolean):Void {
		var del:Object = m_delegate;
		var children:Array = del.treeViewChildrenOfItem(this, item).internalList(); 
		var count:Number = children.length;
		
		//
		// Determine insert index
		//
		m_insertIdx = _insertIndexForItem(item);
		if (m_insertIdx == -1) {
			trace(asWarning("Could not load item " + item + ". Not found."));
			return;
		}
		
		//
		// Build and insert cells
		//
		var cells:Array = [];
		for (var i:Number = 0; i < count; i++) {
			var cell:ASTreeCell = ASTreeCell(m_matrix.makeCell());
			cell.setTree(this);
			cell.setLoaded(true);
			del.treeViewWillDisplayCellWithItem(this, cell, children[i]);
			cells.push(cell);
		}
		
		//
		// Do nothing if we're not inserting
		//
		if (!insert) {
			return;
		}
		
		//
		// Insert the cells and resize the tree.
		//
		_insertCellsAtIndex(cells, m_insertIdx);
		sizeToFit();
	}
	
	/**
	 * Inserts cells into the matrix at index.
	 */
	private function _insertCellsAtIndex(cells:Array, index:Number):Void {
		var len:Number = cells.length;
		
		//
		// Determine if any of the new cells exceed the current max
		//
		var oldMax:Number = m_maxWidth;
		if (m_autoResize) {
			for (var i:Number = 0; i < len; i++) {
				var size:NSSize = NSCell(cells[i]).cellSize();
				if (m_maxWidth == null || size.width > m_maxWidth) {
					m_maxWidth = size.width;
				}
			}	
		}
		
		//
		// Insert the cells
		//
		for (var i:Number = 0; i < len; i++) {
			m_matrix.insertRowWithCells(m_insertIdx + i, 
				NSArray.arrayWithObject(cells[i]));
		}
		
		//
		// Change the cell size if necessary
		//
		if (m_autoResize && oldMax != m_maxWidth) {
			m_matrix.setCellSize(new NSSize(m_maxWidth, m_rowHeight));
		}
	}
	
	/**
	 * Determines the insertion index for item.
	 */
	private function _insertIndexForItem(item:Object):Number {
		var idx:Number;
		if (item == null) {
			return 0;
		}
		else if ((m_insertIdx != 0 && item != null) 
				&& ASTreeCell(m_matrix.cellAtRowColumn(m_insertIdx, 0))
					.treeNode() != item) {
			idx = rowForItem(item);
			
			if (idx == -1) {
				return -1;
			}
			
			return idx + 1;
		} else {
			return m_insertIdx + 1;
		}	
	}
	
	//******************************************************
	//*             Setting the cell class
	//******************************************************
	
	/**
	 * <p>Sets the cell class to <code>klass</code> (must be a subclass of
	 * {@link ASTreeCell}). An instance of the cell class is instantiated for
	 * every new control.</p>
	 * 
	 * <p>If <code>klass</code> does not represent a subclass of 
	 * <code>ASTreeCell</code>, an exception will be raised.</p>
	 * 
	 * @see ASTreeCell
	 */
	public static function setCellClass(klass:Function) {
		//
		// Make sure the cell class represents a subclass of ASTreeCell
		//
		var test:Object = new klass();
		if (!(test instanceof ASTreeCell)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"klass must be a subclass of ASTreeCell",
				null);
			trace(e);
			throw e;
		}
		
		g_cellClass = klass;
	}

	/**
	 * <p>Returns the cell class.</p>
	 */	
	public static function cellClass():Function {
		if (g_cellClass == undefined) {
			g_cellClass = ASTreeCell;
		}
		
		return g_cellClass;
	}
}