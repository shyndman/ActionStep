/* See LICENSE for copyright and terms of use */

import org.actionstep.ASFieldEditor;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSMatrixMode;
import org.actionstep.constants.NSTableViewColumnAutoresizingStyle;
import org.actionstep.constants.NSTextMovement;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSArray;
import org.actionstep.NSCell;
import org.actionstep.NSClipView;
import org.actionstep.NSColor;
import org.actionstep.NSDictionary;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSImage;
import org.actionstep.NSIndexSet;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPoint;
import org.actionstep.NSRange;
import org.actionstep.NSRect;
import org.actionstep.NSScroller;
import org.actionstep.NSScrollView;
import org.actionstep.NSSize;
import org.actionstep.NSTableColumn;
import org.actionstep.NSTableHeaderView;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.table.ASTableMatrix;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.ASThemeProtocol;

/**
 * An NSTableView object displays record-oriented data in a table and allows
 * the user to edit values and resize and rearrange columns.
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSTableView extends org.actionstep.NSControl {
				
	//******************************************************															 
	//*                    Constants
	//******************************************************

	/**
	 * Specifies that no grid lines should be displayed.
	 */
	public static var NSTableViewGridNone:Number 					= 0;
	
	/**
	 * Specifies that vertical grid lines should be displayed.
	 */
	public static var NSTableViewSolidVerticalGridLineMask:Number 	= 1 << 0;
		
	/**
	 * Specifies that horizontal grid lines should be displayed.
	 */
	public static var NSTableViewSolidHorizontalGridLineMask:Number = 1 << 1;

	//******************************************************
	//*                  Class members
	//******************************************************
	
	private static var g_comparisonColumn:NSTableColumn;

	//******************************************************															 
	//*                 Member Variables
	//******************************************************
	
	private var m_columns:NSArray; // array of NSTableColumn objects
	private var m_columnOrigins:Array;
	
	//
	// Data related
	// 
	private var m_dataSource:Object; 
	private var m_editableDataSource:Boolean;
	private var m_reloadDataFlag:Boolean;
	private var m_displayedDataRange:NSRange;
	
	//
	// Counts
	//
	private var m_numCols:Number;
	private var m_numRows:Number;
	private var m_numRowsPerMatrix:Number;
	
	//
	// Enclosing scroll view
	//
	private var m_scrollView:NSScrollView;
	private var m_clipView:NSClipView;
	
	//
	// Auxiliary views
	//
	private var m_headerView:NSTableHeaderView;
	private var m_cornerView:NSView;
	
	//
	// Selection
	//
	private var m_selectedCol:Number;
	private var m_selectedCols:NSIndexSet;
	private var m_selectedRow:Number;
	private var m_selectedRows:NSIndexSet;
	private var m_highlightedCol:NSTableColumn;
	private var m_selectingCols:Boolean;
	
	//
	// Other
	//
	private var m_delegate:Object;
	private var m_delegateWatchesDisplay:Boolean;
	private var m_allowsColReorder:Boolean;
	private var m_allowsColResize:Boolean;
	private var m_allowsColSelection:Boolean;
	private var m_allowsEmptySelection:Boolean;
	private var m_allowsMultiSelection:Boolean;
	private var m_colAutoresizeStyle:NSTableViewColumnAutoresizingStyle;
	private var m_vertMotionBeginsDrag:Boolean;
	private var m_bgColor:NSColor;
	private var m_intercellSpacing:NSSize;
	private var m_rowHeight:Number;
	private var m_tableSize:NSSize;
	private var m_usesAlternatingRowColors:Boolean;
	private var m_rowColorCount:Number;
	private var m_enabled:Boolean;
	private var m_sortDescriptors:NSArray;
	private var m_gridStyleMask:Number;
	private var m_gridColor:NSColor;
	
	//
	// Target-action stuff
	//
	private var m_dblAction:String;
	private var m_clickedCol:Number;
	private var m_clickedRow:Number;
	private var m_clickedValue:Object;
	
	//
	// Editing
	//
	private var m_editedCell:NSCell;
	private var m_editedCol:Number;
	private var m_editedRow:Number;
	
	//
	// For drawing
	//
	private var m_invalidParts:Object;
	
	//
	// Movieclips
	//
	private var m_mcAltRows1:MovieClip;
	private var m_mcAltRows2:MovieClip;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of NSTableView.
	 */
	public function NSTableView() {
		m_columns = NSArray.array();
		m_selectedCols = NSIndexSet.indexSet();
		m_selectedRows = NSIndexSet.indexSet();
		m_columnOrigins = [];
		
		//
		// Defaults
		//
		m_numCols = 0;
		m_numRows = 0;
		m_rowHeight = 22;
		m_allowsColReorder = true;
		m_allowsColResize = true;
		m_allowsColSelection = true;
		m_allowsEmptySelection = true;
		m_allowsMultiSelection = false;
		m_vertMotionBeginsDrag = false;
		m_intercellSpacing = new NSSize(3, 2);
		m_usesAlternatingRowColors = false;
		m_enabled = true;
		m_clickedCol = m_clickedRow = -1;
		m_invalidParts = {};
		m_rowColorCount = 0;
		m_gridColor = new NSColor(0xCCCCCC);
		m_gridStyleMask = NSTableViewGridNone;
		m_editedCol = m_editedRow = -1;
		m_selectingCols = false;
		m_colAutoresizeStyle = NSTableViewColumnAutoresizingStyle.NSTableViewLastColumnOnlyAutoresizingStyle;
		
		m_scrollPoint = NSPoint.ZeroPoint;
	}
	
	/**
	 * Initializes and returns the table view.
	 */
	public function init():NSTableView {
		return initWithFrame(NSRect.ZeroRect);
	}
	
	/**
	 * Initializes and returns the table view with the frame size of frame.
	 */	
	public function initWithFrame(frame:NSRect):NSTableView {
		super.initWithFrame(frame);
				
		//
		// Create default header view
		//
		setHeaderView((new NSTableHeaderView()).initWithFrame(
			new NSRect(0, 0, 
				frame.size.width - NSScroller.scrollerWidth() - 2, 
				m_rowHeight)));
		
		//
		// Create default corner view
		// 
		setCornerView(m_cornerView);
				
		//
		// Make sure we don't post automatic frame notifications
		//
		setPostsBoundsChangedNotifications(false);
		setPostsFrameChangedNotifications(false);
		
		return this;
	}
	
	//******************************************************															 
	//*             Describing the object
	//******************************************************
	
	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String {
		return "NSTableView(columns=" + m_columns + ")";
	}
	
	//******************************************************
	//*           ActionStep MovieClip Methods
	//******************************************************
	
	public function initializeBoundsMovieClip():Void {
		m_mcAltRows1 = m_mcBounds.createEmptyMovieClip("m_mcAltRows1", 0);
		m_mcAltRows1._visible = false;
		m_mcAltRows1.view = this;
		m_mcDepth++;
		m_mcAltRows2 = m_mcBounds.createEmptyMovieClip("m_mcAltRows2", 1);
		m_mcAltRows2._visible = false;
		m_mcAltRows2.view = this;
		m_mcDepth++;
		
		super.initializeBoundsMovieClip();
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
		setNeedsDisplay(true);
		
		return true;
	}
	
	//******************************************************															 
	//*                   Data Source
	//******************************************************
	
	/**
	 * Returns the data provider for the table.
	 */
	public function dataSource():Object {
		return m_dataSource;
	}
	
	/**
	 * <p>
	 * Sets the data provider for the table. After being set, a call to tile()
	 * is made.
	 * </p>
	 * <p>
	 * This object must at the least implement 
	 * <code>numberOfRowsInTableView()</code> and 
	 * <code>tableViewObjectValueForTableColumnRow()</code>.
	 * </p>
	 * <p>
	 * See the <code>org.actionstep.NSTableDataSource</code> interface for
	 * information about all methods available to a table's data source.
	 * </p>
	 */	
	public function setDataSource(dataSource:Object):Void {
		if (dataSource == m_dataSource) {
			return;
		}
		
		//
		// Method check
		//
		if (!ASUtils.respondsToSelector(dataSource, "numberOfRowsInTableView")) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"Data source must implement numberOfRowsInTableView()",
				null);
			trace(e);
			throw e;
		}
		if (!ASUtils.respondsToSelector(dataSource, "tableViewObjectValueForTableColumnRow")) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"Data source must implement tableViewObjectValueForTableColumnRow()",
				null);
			trace(e);
			throw e;
		}
		
		//
		// Check if the data source is editable
		//
		m_editableDataSource = ASUtils.respondsToSelector(dataSource, 
			"tableViewSetObjectValueForTableColumnRow");
			
		//
		// Set the data source
		//
		m_dataSource = dataSource;
		reloadData();
	}
	
	//******************************************************
	//*                  Loading data
	//******************************************************
	
	/**
	 * Sets the table as needing redisplay so that data will be reloaded
	 * for all visible cells.
	 */
	public function reloadData():Void {
		if (m_dataSource == null) {
			return;
		}
		
		noteNumberOfRowsChanged();
		m_reloadDataFlag = true;
		setNeedsDisplay(true);
	}
	
	//******************************************************															 
	//*             Target-action Behaviour
	//******************************************************
	
	/**
	 * Sets the message (method) that is sent to the target (called) when the
	 * user double clicks an uneditable cell or a column header.
	 * 
	 * You must set the target for any message to be sent.
	 * 
	 * @see #doubleAction
	 * @see NSControl#setAction
	 * @see NSControl#setTarget
	 */
	public function setDoubleAction(aSelector:String):Void {
		m_dblAction = aSelector;
	}
	
	/**
	 * Returns the name of the method that is called when the user double clicks
	 * on an uneditable cell or a column header.
	 */
	public function doubleAction():String {
		return m_dblAction;
	}
	
	/**
	 * Returns the index of the column used to trigger the last action message
	 * sent to the target.
	 * 
	 * -1 is returned if the area clicked is not occupied by columns.
	 */ 
	public function clickedColumn():Number {
		return m_clickedCol;
	}
	
	/**
	 * Returns the index of the row used to trigger the last action message
	 * sent to the target. 
	 * 
	 * Returns -1 if the user clicked in an area not occupied by table rows.
	 */
	public function clickedRow():Number {
		return m_clickedRow;
	}
	
	//******************************************************															 
	//*                Configuring behavior
	//******************************************************
			
	/**
	 * Returns TRUE if the table allows columns to be re-ordered by dragging
	 * the column headers, or FALSE otherwise. The default is TRUE.
	 *
	 * Columns can be reordered using moveColumnToColumn regardless of this
	 * setting.
	 *
	 * @see setAllowsColumnReordering
	 * @see moveColumnToColumn
	 */
	public function allowsColumnReordering():Boolean {
		return m_allowsColReorder;
	}
	
	/**
	 * If set to TRUE, the table will allow columns to be re-ordered by dragging
	 * the column headers. The default is TRUE.
	 *
	 * Columns can be reordered using moveColumnToColumn regardless of this
	 * setting.
	 *
	 * @see allowsColumnReordering
	 * @see moveColumnToColumn
	 */
	public function setAllowsColumnReordering(flag:Boolean):Void {
		m_allowsColReorder = flag;
	}
	
	/**
	 * Returns TRUE if the table allows columns to be resized by grabbing the
	 * horizontal boundaries of column headers, or FALSE otherwise. The default
	 * is TRUE. 
	 *
	 * Columns can be resized using NSTableColumn::setWidth() regardless of this
	 * setting.
	 *
	 * @see setAllowsColumnResizing
	 * @see org.actionstep.NSTableColumn#setWidth
	 */
	public function allowsColumnResizing():Boolean {
		return m_allowsColResize;
	}
	
	/**
	 * If set to TRUE, the table will allow columns to be resized by grabbing 
	 * the horizontal boundaries of column headers. The default is TRUE. 
	 *
	 * Columns can be resized using NSTableColumn::setWidth() regardless of this
	 * setting.
	 *
	 * @see allowsColumnResizing
	 * @see org.actionstep.NSTableColumn#setWidth
	 */
	public function setAllowsColumnResizing(flag:Boolean):Void {
		m_allowsColResize = flag;
	}
	
	/**
	 * Returns TRUE if the table allows columns to be selected by clicking on 
	 * their headers, or FALSE otherwise. The default is TRUE. 
	 *
	 * Columns can be resized using selectColumnByExtendingSelection regardless
	 * of this setting.
	 *
	 * @see setAllowsColumnSelection
	 * @see selectColumnByExtendingSelection
	 */
	public function allowsColumnSelection():Boolean {
		return m_allowsColSelection;
	}
	
	/**
	 * If set to TRUE, the table will allow columns to be selected by clicking on 
	 * their headers. The default is TRUE. 
	 *
	 * Columns can be resized using selectColumnByExtendingSelection regardless
	 * of this setting.
	 *
	 * @see setAllowsColumnSelection
	 * @see selectColumnByExtendingSelection
	 */
	public function setAllowsColumnSelection(flag:Boolean):Void {
		m_allowsColSelection = flag;
	}
	
	/**
	 * Returns TRUE if the table allows no selected rows or columns, or FALSE
	 * if something must always be selected.
	 *
	 * If FALSE, selection cannot be empty even if set programmatically.
	 *
	 * @see setAllowsEmptySelection
	 */
	public function allowsEmptySelection():Boolean {
		return m_allowsEmptySelection;
	}
	
	/**
	 * If set to TRUE, the table will allow no selection. If FALSE, something
	 * must always have selection.
	 *
	 * @see allowsEmptySelection
	 */
	public function setAllowsEmptySelection(flag:Boolean):Void {
		m_allowsEmptySelection = flag;
	}
	
	/**
	 * Returns TRUE if the table allows multiple rows/columns to be selected,
	 * or FALSE otherwise. The default is FALSE.
	 *
	 * Multiple columns/rows can be selected programmatically regardless
	 * of this setting.
	 *
	 * @see setAllowsMultipleSelection
	 * @see selectColumnByExtendingSelection
	 * @see selectRowByExtendingSelection
	 */
	public function allowsMultipleSelection():Boolean {
		return m_allowsMultiSelection;
	}
	
	/**
	 * If set to TRUE, the table allows multiple row/columns to be selected.
	 * The default is FALSE.
	 *
	 * Multiple columns/rows can be selected programmatically regardless
	 * of this setting.
	 *
	 * @see allowsMultipleSelection
	 * @see selectColumnByExtendingSelection
	 * @see selectRowByExtendingSelection
	 */
	public function setAllowsMultipleSelection(flag:Boolean):Void {
		m_allowsMultiSelection = flag;
	}	
	
	//******************************************************															 
	//*            Setting display attributes
	//******************************************************

	/**
	 * Returns the width and height between cells and sets the table needing
	 * a redraw. The default spacing is NSSize(3, 2).
	 *
	 * @see setIntercellSpacing
	 */
	public function intercellSpacing():NSSize {
		return m_intercellSpacing.clone();
	}
	
	/**
	 * Sets the width and height between cells and sets the table needing
	 * a redraw. The default spacing is NSSize(3, 2).
	 *
	 * @see intercellSpacing
	 */	
	public function setIntercellSpacing(spacing:NSSize):Void {
		if (m_intercellSpacing == spacing) {
			return;
		}
		
		m_intercellSpacing = spacing;
		
		m_invalidParts.intercellSpacing = true; 
	}
	
	/**
	 * Returns the height of rows in the table.
	 *
	 * @see setRowHeight.
	 */
	public function rowHeight():Number {
		return m_rowHeight;
	}

	/**
	 * Sets the height of rows in the table, and calls tile.
	 *
	 * @see setRowHeight
	 * @see tile
	 */	
	public function setRowHeight(height:Number):Void {
		if (m_rowHeight == height) {
			return;
		}
		
		m_rowHeight = height;
		
		m_invalidParts.rowHeight = true;
		
		tile();
	}
	
	/**
	 * Returns whether the table uses alternating row colors (TRUE), or a solid
	 * background (FALSE). The default is FALSE.
	 *
	 * @see usesAlterningRowBackgroundColors
	 */
	public function usesAlterningRowBackgroundColors():Boolean {
		return m_usesAlternatingRowColors;
	}
	
	/**
	 * Sets whether the table uses alternating row colors (TRUE), or a solid
	 * background (FALSE). The default is FALSE.
	 *
	 * @see usesAlterningRowBackgroundColors
	 */
	public function setUsesAlterningRowBackgroundColors(flag:Boolean):Void {
		if (m_usesAlternatingRowColors == flag) {
			return;
		}
		
		m_usesAlternatingRowColors = flag;
		
		if (m_usesAlternatingRowColors) {
			if (m_rowColorCount % 2 == 0) {
				m_mcAltRows1._visible = true;
				m_mcAltRows2._visible = false;
			} else {
				m_mcAltRows1._visible = false;
				m_mcAltRows2._visible = true;
			}
		} else {
			m_mcAltRows1._visible = false;
			m_mcAltRows2._visible = false;
		}
	}
	
	/**
	 * Returns the background color of the table.
	 *
	 * @see setBackgroundColor
	 */	
	public function backgroundColor():NSColor {
		return m_bgColor;
	}
	
	/**
	 * Sets the background color of the table.
	 *
	 * @see backgroundColor
	 */
	public function setBackgroundColor(aColor:NSColor):Void {
		if (aColor.isEqual(m_bgColor)) {
			return;
		}
		
		m_bgColor = aColor;
		
		m_invalidParts.bgColor = true;
	}
	
	/**
	 * For internal use only.
	 */
	public function rowColorCount():Number {
		return m_rowColorCount;
	}
	
	//******************************************************
	//*             Manipulating columns
	//******************************************************
	
	/**
	 * Adds aColumn as the last column of the receiver.
	 *
	 * @see removeTableColumn
	 */
	public function addTableColumn(aColumn:NSTableColumn):Void {
		aColumn.setTableView(this);
		m_columns.addObject(aColumn);
		m_numCols++;
		
		//
		// Build matrices if we're in a scrollview
		//
		if (m_scrollView != null) {
			buildMatrixForColumn(aColumn);
		}
		
		//
		// Retile
		//
		tile();
	}
	
	/**
	 * Removes aColumn from the receiver.
	 *
	 * @see removeTableColumn
	 */
	public function removeTableColumn(aColumn:NSTableColumn):Void {
		//
		// Avoid any unnecessary work
		//
		var loc:Number = m_columns.indexOfObject(aColumn);
		if (loc == NSNotFound || aColumn.tableView() != this) {
			trace(asWarning("aColumn does not belong to table"));
			return;
		}
		
		//
		// Selection change
		//
		deselectColumn(loc);
		if (m_selectedCol > loc) {
			m_selectedCol--;
		}
		m_selectedCols.removeIndex(loc);
		
		//
		// Remove the column
		//
		aColumn.setTableView(null);
		m_columns.removeObjectAtIndex(loc);
		m_numCols--;
		
		//
		// Remove matrices
		//
		destroyMatrixForColumn(aColumn);
		
		//
		// Retile
		//
		tile();
	}
	
	/**
	 * <p>Moves the column and heading at columnIdx to newIdx.</p>
	 * <p>
	 * This method posts NSTableViewColumnDidMoveNotification to the default 
	 * notification center.
	 * </p>
	 */
	public function moveColumnToColumn(columnIdx:Number, newIdx:Number):Void {
		var col:NSTableColumn = NSTableColumn(m_columns.objectAtIndex(columnIdx));
				
		//
		// Deal with selection
		//
		var selNew:Boolean = isColumnSelected(columnIdx);
		var selOld:Boolean = isColumnSelected(newIdx);
		
		if (selNew && !selOld) {
			deselectColumn(columnIdx);
			selectColumnIndexesByExtendingSelection(
				NSIndexSet.indexSetWithIndex(newIdx), true);
		}
		else if (!selNew && selOld) {
			deselectColumn(newIdx);
			if (newIdx == numberOfColumns() - 1) {
				selectColumnIndexesByExtendingSelection(
					NSIndexSet.indexSetWithIndex(newIdx - 1), true);
			} else {
				selectColumnIndexesByExtendingSelection(
					NSIndexSet.indexSetWithIndex(newIdx + 1), true);
			}
		}
		
		//
		// Move column
		//
		try {
			m_columns.removeObjectAtIndex(columnIdx); // remove
		} catch(e:NSException) {
			var e2:NSException = NSException.exceptionWithNameReasonInnerExceptionUserInfo(
				e.name(),
				"No column exists at index " + columnIdx,
				e,
				null);
			trace(e2);
			throw e2;
		}

		try {
			m_columns.insertObjectAtIndex(col, newIdx); // insert
		} catch(e:NSException) {
			var e2:NSException = NSException.exceptionWithNameReasonInnerExceptionUserInfo(
				e.name(),
				newIdx + " is not a valid move position",
				e,
				null);
			trace(e2);
			throw e2;
		}
				
		tile();
		postColumnDidMove(columnIdx, newIdx);	
	}
	
	/**
	 * Returns an array of this table's columns.
	 */
	public function tableColumns():NSArray {
		return NSArray.arrayWithNSArray(m_columns);
	}
	
	/**
	 * Returns the index of the column who's identifier matches anObject 
	 * (through an isEqual call if possible, falling back on ==), or -1
	 * if no match can be found.
	 *
	 * @see tableColumnWithIdentifier
	 */
	public function columnWithIdentifier(anObject:Object):Number {
		//
		// Create (or modify) our global comparison column.
		//
		if (g_comparisonColumn == undefined) {
			g_comparisonColumn = (new NSTableColumn())
				.initWithIdentifier(anObject);
		} else {
			g_comparisonColumn.setIdentifier(anObject);
		}
			
		return m_columns.indexOfObjectWithCompareFunction(
			g_comparisonColumn, compareTableColumnIdentifiers);
	}

	/**
	 * Returns a reference to the column who's identifier matches anObject 
	 * (through an isEqual call if possible, falling back on ==), or null
	 * if no match can be found.
	 *
	 * @see columnWithIdentifier
	 */
	public function tableColumnWithIdentifier(anObject:Object):NSTableColumn {
		var idx:Number;
		
		return -1 == (idx = columnWithIdentifier(anObject)) ? null : 
			m_columns.objectAtIndex(idx);
	}
	
	//******************************************************
	//*            Selecting columns and rows
	//******************************************************
		
	/**
	 * Sets column selection using indexes. If extend is TRUE, the current
	 * column selection is merged with indexes. If extend is false, indexes
	 * replaces the current selection.
	 */
	public function selectColumnIndexesByExtendingSelection(indexes:NSIndexSet,
			extend:Boolean):Void {
		if (!m_allowsColSelection || !shouldSelectionChange()) {
			return;
		}
		
		//
		// Flag us as selecting a column
		//		
		if (!m_selectingCols) {
			m_selectingCols = true;
			if (m_headerView != null) {
				m_headerView.setNeedsDisplay(true);
			}
		}
		
		//
		// Stop editing if any
		//
		if (currentEditor() != null) {
			validateEditing();
			abortEditing();
		}
		
		//
		// Determine if we're empty or if we're going to change the
		// selection.
		//
		var empty:Boolean = indexes.firstIndex() == NSNotFound;
		var changed:Boolean = false;
				
		if (!empty) {			
			if (extend) {
				//
				// Remove all duplicate indexes if we're extending
				//
				var col:Number = indexes.firstIndex();
				
				while (col != NSNotFound) {
					if (!m_selectedCols.containsIndex(col)) {
						changed = true;
					} else {
						indexes.removeIndex(col);
					}
					
					col = indexes.indexGreaterThanIndex(col);
				}
			}
			
			//
			// Make sure the delegate allows us to select all the new
			// columns.
			//
			var cols:Array = m_columns.internalList();
			var col:Number = indexes.firstIndex();
			while (col != NSNotFound) {
				if (!shouldSelectTableColumn(NSTableColumn(cols[col]))) {
					indexes.removeIndex(col);
				}
				
				col = indexes.indexGreaterThanIndex(col);
			} 
		}
		
		//
		// Test for emptyness again
		//
		empty = indexes.firstIndex() == NSNotFound;
		
		//
		// Deselect columns
		//
		if (!extend) {
			if (m_selectedCols.isEqualToIndexSet(indexes)) {
				if (!empty) {
					m_selectedCol = m_selectedCols.lastIndex();
				}
				
				return;
			}
			
			_deselectAllColumns();
			changed = true;
		}
		
		//
		// Select columns
		//
		if (!empty) {
			if (indexes.lastIndex() == m_numCols) {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSInternalInconsistency,
					"Column index out of table",
					null);
				trace(e);
				throw e;
			}
			
			if (!m_allowsMultiSelection &&
					m_selectedCols.count() + indexes.count() > 1) {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSInternalInconsistency,
					"Cannot select multiple columns in a non-multiselect table",
					null);
				trace(e);
				throw e;
			}
			
			
						
			m_selectedCols.addIndexes(indexes);
			m_selectedCol = indexes.lastIndex();
		}
		
		//
		// If we changed, do some stuff
		//
		if (changed) {
			setNeedsDisplay(true);
			if (m_headerView != null) {
				m_headerView.setNeedsDisplay(true);
			}
			
			var arr:Array = m_columns.internalList();
			var len:Number = arr.length;
			for (var i:Number = 0; i < len; i++) {
				NSTableColumn(arr[i]).columnMatrix().display();
			}
			
			postSelectionDidChangeNotification();
		}
	}
	
	/**
	 * Used internally to select a column.
	 */
	public function _selectColumn(index:Number, modifiers:Number):Void {
		if (!m_allowsColSelection) {
			return;
		}
		
		var toggleSel:Boolean = (modifiers & NSEvent.NSCommandKeyMask) != 0;
		var multiSel:Boolean = (modifiers & NSEvent.NSShiftKeyMask) != 0;
		
		if (isColumnSelected(index)) {
			if (numberOfSelectedColumns() == 1) {
				//
				// No change
				//
				if (toggleSel && !m_allowsEmptySelection) {
					return;
				}
				if (!toggleSel) {
					return;
				}
			}
			
			//
			// If the toggle button is on, toggle selection. If it isn't, and
			// the shift key isn't pressed, deselect all other columns.
			//
			if (toggleSel) {
				deselectColumn(index);
			} 
			else if (!multiSel) {
				selectColumnIndexesByExtendingSelection(
					NSIndexSet.indexSetWithIndex(index), false);
			}
		} else {
			var selCol:Number = selectedColumn();
			
			if (!multiSel || !m_allowsMultiSelection || selCol == -1) {
				selectColumnIndexesByExtendingSelection(
					NSIndexSet.indexSetWithIndex(index), toggleSel && m_allowsMultiSelection);
			} else {
				var range:NSRange = new NSRange(Math.min(selCol, index), 
					Math.abs(selCol - index) + 1);
				selectColumnIndexesByExtendingSelection(
					NSIndexSet.indexSetWithIndexesInRange(
						range),
						true);
			}
		}
	}
	
	/**
	 * Deselects all columns in the table.
	 */
	private function _deselectAllColumns():Void {
		m_selectedCols.removeAllIndexes();
		m_selectedCol = -1;
		m_headerView.setNeedsDisplay(true);
	}

	/**
	 * Sets row selection using indexes. If extend is TRUE, the current
	 * row selection is merged with indexes. If extend is false, indexes
	 * replaces the current selection.
	 */	
	public function selectRowIndexesByExtendingSelection(indexes:NSIndexSet,
		extend:Boolean):Void
	{
		if (!shouldSelectionChange()) {
			return;
		}
		
		//
		// Stop selection of columns
		//		
		if (m_selectingCols) {
			m_selectingCols = false;
			if (m_headerView != null) {
				m_headerView.setNeedsDisplay(true);
			}
		}
		
		//
		// Stop editing if any
		//
		if (currentEditor() != null) {
			validateEditing();
			abortEditing();
		}
		
		//
		// Determine if we're empty or if we're going to change the
		// selection.
		//
		var empty:Boolean = indexes.firstIndex() == NSNotFound;
		var changed:Boolean = false;
		
		if (!empty) {			
			if (extend) {
				//
				// Remove all duplicate indexes if we're extending
				//
				var row:Number = indexes.firstIndex();
				
				while (row != NSNotFound) {
					if (!m_selectedRows.containsIndex(row)) {
						changed = true;
					} else {
						indexes.removeIndex(row);
					}
					
					row = indexes.indexGreaterThanIndex(row);
				}
			}
			
			//
			// Make sure the delegate allows us to select all the new
			// rows.
			//
			var row:Number = indexes.firstIndex();
			while (row != NSNotFound) {
				if (!shouldSelectRow(row)) {
					indexes.removeIndex(row);
				}
				
				row = indexes.indexGreaterThanIndex(row);
			} 
		}
		
		//
		// Test for emptyness again
		//
		empty = indexes.firstIndex() == NSNotFound;
		changed = !empty;
		
		//
		// Deselect rows
		//
		if (!extend) {
			if (m_selectedRows.isEqualToIndexSet(indexes)) {
				if (!empty) {
					m_selectedRow = m_selectedRows.lastIndex();
				}
				
				return;
			}
			
			_deselectAllRows();
			changed = true;
		}
		
		//
		// Select rows
		//
		if (!empty) {
			if (indexes.lastIndex() == m_numRows) {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSInternalInconsistency,
					"Row index out of table",
					null);
				trace(e);
				throw e;
			}
			
			if (!m_allowsMultiSelection &&
					m_selectedRows.count() + indexes.count() > 1) {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSInternalInconsistency,
					"Cannot select multiple rows in a non-multiselect table",
					null);
				trace(e);
				throw e;
			}
									
			m_selectedRows.addIndexes(indexes);
			m_selectedRow = indexes.lastIndex();
		}
		
		//
		// If we changed, do some stuff
		//
		if (changed) {
			setNeedsDisplay(true);
			
			var arr:Array = m_columns.internalList();
			var len:Number = arr.length;
			for (var i:Number = 0; i < len; i++) {
				NSTableColumn(arr[i]).columnMatrix().display();
			}
			
			postSelectionDidChangeNotification();
		}
	}

	/**
	 * Deselects all rows in the table.
	 */
	private function _deselectAllRows():Void {
		m_selectedRows.removeAllIndexes();
		m_selectedRow = -1;
		setNeedsDisplay(true);
	}

    /**
     * Returns an array of columns that are selected in this table, ordered
     * by the order of selection.
     */    
	public function selectedColumnIndexes():NSIndexSet {
		return NSIndexSet(m_selectedCols.copy()); 
	}
    
    /**
     * Returns an array of rows that are selected in this table, ordered
     * by the order of selection.
     */
	public function selectedRowIndexes():NSIndexSet {
		return NSIndexSet(m_selectedRows.copy());
	}
    
    /**
     * Deselects the column at columnIdx if it is selected. If this results in
     * a change, NSTableViewSelectionDidChangeNotification is posted to the 
     * default notification center. 
     *
     * If the deselected column was selectedColumn, then the previously 
     * selected column becomes selectedColumn.
     *
     * This method doesn't check with the delegate before changing selection.
     */
	public function deselectColumn(columnIdx:Number):Void {
		if (!m_selectedCols.containsIndex(columnIdx)) {
			return;
		}
		
		//
		// Stop editing if any
		//
		if (currentEditor() != null) {
			validateEditing();
			abortEditing();
		}
		
		m_selectingCols = true;
		m_selectedCols.removeIndex(columnIdx);
		
		if (m_selectedCol == columnIdx) {
			var less:Number = m_selectedCols.indexLessThanIndex(columnIdx);
			if (less == NSNotFound) {
				var greater:Number = m_selectedCols.indexGreaterThanIndex(columnIdx);
				if (greater == NSNotFound) {
					m_selectedCol = -1;
				} else {
					m_selectedCol = greater;
				}
			} else {
				m_selectedCol = less;
			}
		}
		
		if (m_headerView != null) {
			m_headerView.setNeedsDisplay(true);
		}
		
		postSelectionDidChangeNotification();
	}

    /**
     * Deselects the row at rowIdx if it is selected. If this results in
     * a change, NSTableViewSelectionDidChangeNotification is posted to the 
     * default notification center. 
     *
     * If the deselected row was selectedRow, then the previously 
     * selected row becomes selectedRow.
     *
     * This method doesn't check with the delegate before changing selection.
     */	
	public function deselectRow(rowIdx:Number):Void {
		if (!m_selectedRows.containsIndex(rowIdx)) {
			return;
		}
		
		//
		// Stop editing if any
		//
		if (currentEditor() != null) {
			validateEditing();
			abortEditing();
		}
		
		m_selectingCols = false;
		m_selectedRows.removeIndex(rowIdx);
		
		if (m_selectedRow == rowIdx) {
			var less:Number = m_selectedRows.indexLessThanIndex(rowIdx);
			if (less == NSNotFound) {
				var greater:Number = m_selectedRows.indexGreaterThanIndex(rowIdx);
				if (greater == NSNotFound) {
					m_selectedRow = -1;
				} else {
					m_selectedRow = greater;
				}
			} else {
				m_selectedRow = less;
			}
		}
		
		setNeedsDisplay(true);			
		postSelectionDidChangeNotification();
	}

    /**
     * Returns the number of selected columns in this table.
     */
	public function numberOfSelectedColumns():Number {
		return m_selectedCols.count();
	}
    
    /**
     * Returns the number of selected rows in this table.
     */
	public function numberOfSelectedRows():Number {
		return m_selectedRows.count();
	}
    
    /**
     * Returns the index of the last selected column, or -1 if no columns
     * are selected.
     */
	public function selectedColumn():Number {
		return m_selectedCol;
	}
    
    /**
     * Returns the index of the last selected row, or -1 if no row are
     * selected.
     */    
	public function selectedRow():Number {
		return m_selectedRow;
	}
    
	/**
	 * Returns TRUE if the column at columnIdx is selected, or FALSE otherwise.
	 */
	public function isColumnSelected(columnIdx:Number):Boolean {
		return m_selectedCols.containsIndex(columnIdx);
	}
	
	/**
	 * Returns TRUE if the row at rowIdx is selected, or FALSE otherwise.
	 */	
	public function isRowSelected(rowIdx:Number):Boolean {
		return m_selectedRows.containsIndex(rowIdx);
	}
	
	/**
     * This method selects all rows and columns if multiple selection is
     * allowed.
     *
	 * If the selection does change, this method posts 
	 * NSTableViewSelectionDidChangeNotification to the default notification
	 * center.
     *
     * This method checks with the delegate selectionShouldChangeInTableView
     * before changing the selection.
     */	
	public function selectAll(sender:Object):Void {
		var i:Number;
		
		if (!m_allowsMultiSelection || !shouldSelectionChange()) {
			return;
		}
		
		//
		// Select all columns
		//
		m_selectedCols.removeAllIndexes();
		
		var colLen:Number = m_columns.count();
		for (i = 0; i < colLen; i++) {
			m_selectedCols.addIndex(i);
		}		
		
		//
		// Select all rows
		//
		m_selectedRows.removeAllIndexes();
		
		var rowLen:Number = m_dataSource.numberOfRowsInTableView(this);
		for (i = 0; i < rowLen; i++)
		{
			m_selectedRows.addIndex(i);
		}
				
		setNeedsDisplay(true);
		//!
	}
	
	/**
	 * Deselects all rows and columns if empty selection is allowed.
	 *
	 * If the selection does change, this method posts 
	 * NSTableViewSelectionDidChangeNotification to the default notification
	 * center.
	 *
     * This method checks with the delegate selectionShouldChangeInTableView
     * before changing the selection.
	 */
	public function deselectAll(sender:Object):Void {
		if (!m_allowsEmptySelection) {
			return;
		}
		
		if (!shouldSelectionChange()) {
			return;
		}
				
		m_selectedCols.removeAllIndexes();
		m_selectedRows.removeAllIndexes();
		
		setNeedsDisplay(true);
		
		//!
	}
	
	//******************************************************
	//*         Getting the dimensions of the table
	//******************************************************
	
	/**
	 * Returns the number of columns in the table.
	 */
	public function numberOfColumns():Number {
		return m_numCols;
	}
	
	/**
	 * Returns the number of rows in the table data source.
	 */
	public function numberOfRows():Number {
		return m_numRows;
	}
	
	//******************************************************
	//*              Setting grid attributes
	//******************************************************
	
	/**
	 * <p>Sets the color used to draw grid lines to <code>color</code>.</p>
	 * 
	 * <p>The default color is gray.</p>
	 * 
	 * @see #gridColor()
	 * @see #setGridStyleMask()
	 */
	public function setGridColor(color:NSColor):Void {
		m_gridColor = color;
	}
	
	/**
	 * <p>Returns the color used to draw grid lines.</p>
	 * 
	 * @see #setGridColor()
	 * @see #gridStyleMask()
	 */
	public function gridColor():NSColor {
		return m_gridColor;
	}
	
	/**
	 * <p>
	 * Sets the grid style mask to specify if no grid lines, vertical grid 
	 * lines, or horizontal grid lines should be displayed.
	 * </p>
	 * 
	 * @see #gridStyleMask()
	 * @see #NSTableViewGridNone
	 * @see #NSTableViewSolidVerticalGridLineMask
	 * @see #NSTableViewSolidHorizontalGridLineMask
	 */
	public function setGridStyleMask(mask:Number):Void {
		m_gridStyleMask = mask;
	}
	
	/**
	 * <p>Returns the receiver’s grid style mask.</p>
	 * 
	 * @see #setGridStyleMask()
	 */
	public function gridStyleMask():Number {
		return m_gridStyleMask;
	}
	
	//******************************************************
	//*                 Editing cells
	//******************************************************
	
	/**
	 * <p>
	 * Edits the cell at <code>columnIdx</code> and <code>rowIdx</code>, 
	 * selecting its entire contents if <code>flag</code> is <code>true</code>.
	 * </p>
	 * <p>
	 * This method is invoked automatically in response to user actions; you 
	 * should rarely need to invoke it directly. <code>theEvent</code> is 
	 * usually the mouse event that triggered editing; it can be nil when 
	 * starting an edit programmatically.
	 * </p>
	 * <p>
	 * The row at <code>rowIdx</code> must be selected prior to calling 
	 * this method, or an exception will be raised.
	 * </p>
	 * 
	 * @see #editedColumn()
	 * @see #editedRow()
	 */
	public function editColumnRowWithEventSelect(columnIdx:Number, 
			rowIdx:Number, theEvent:NSEvent, flag:Boolean):Void {
		if (!m_editableDataSource) {
			return;
		}
		
		//
		// Make sure we're in range
		//
		if (rowIdx < 0 || rowIdx >= m_numRows || columnIdx < 0 || columnIdx >= m_numCols) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"row/column out of range in edit",
				null);
			trace(e);
			throw e;
		}
		
		var t:ASFieldEditor;
		var tc:NSTableColumn;
		
		//
		// Scroll
		//
		scrollRowToVisible(rowIdx);
		scrollColumnToVisible(columnIdx);
		
		//
		// Complete any previous edits
		//
		t = currentEditor();
		if (t != null) {
			validateEditing();
			abortEditing();
		}
		
		t = ASFieldEditor.instance();
		m_editedRow = rowIdx;
		m_editedCol = columnIdx;
		
		//
		// Prepare the cell
		//
		tc = NSTableColumn(m_columns.objectAtIndex(columnIdx));
		m_editedCell = tc.dataCellForRow(rowIdx);
		m_editedCell.setEditable(true);
		m_editedCell.setObjectValue(objectValueForTableColumnRow(tc, rowIdx));
		
		//
		// Notify delegate
		//
		willDisplayCellForTableColumnRow(m_editedCell, tc, rowIdx);
		
		//
		// Select or edit
		//
		if (flag) { 
			m_editedCell.selectWithEditorDelegateStartLength(t, this, null, null);
		} else {
			m_editedCell.editWithEditorDelegateEvent(t, this, theEvent);
		}
	}

	/**
	 * If currently editing, returns the index of the row being edited,
	 * otherwise returns -1. 
	 */	
	public function editedRow():Number {
		return m_editedRow;
	}
	
	/**
	 * If currently editing, returns the index of the column being edited,
	 * otherwise returns -1. 
	 */
	public function editedColumn():Number {
		return m_editedCol;
	}
	
	//******************************************************
	//*              Setting auxiliary views
	//******************************************************
	
	/**
	 * Returns the view used to draw headers above columns, or null if none
	 * exists.
	 *
	 * @see setHeaderView
	 */
	public function headerView():NSTableHeaderView {
		return m_headerView;
	}
	
	/**
	 * Sets the view used to draw headers above columns. If headerView is null,
	 * the current header is removed.
	 *
	 * @see setHeaderView
	 */	
	public function setHeaderView(headerView:NSTableHeaderView):Void {
		if (m_headerView != null) {
			m_headerView.setTableView(null);
		}
		
		m_headerView = headerView;
		m_headerView.setTableView(this);	
		enclosingScrollView().tile();
	}
	
	/**
	 * Returns the view used to render the space above the vertical scrollbar.
	 */
	public function cornerView():NSView {
		return m_cornerView;
	}
	
	/**
	 * Sets the view used to render the space above the vertical scrollbar.
	 *
	 * This view should be as wide as the vertical scrollbar, and as high
	 * as the table header.
	 */
	public function setCornerView(cornerView:NSView):Void {		
		m_cornerView = cornerView;
		enclosingScrollView().tile();
	}

	//******************************************************															 
	//*                  Layout Support
	//******************************************************
	
	/**
	 * <p>
	 * Returns the rectangle containing the column at <code>columnIdx</code>.
	 * </p>
	 * <p>
	 * Returns {@link NSRect#ZeroRect} if <code>columnIdx</code> is out of bounds.
	 * </p>
	 * 
	 * @see #frameOfCellAtColumnRow()
	 * @see #rectOfRow()
	 */
	public function rectOfColumn(columnIdx:Number):NSRect {
		if (columnIdx < 0) {
			return NSRect.ZeroRect;
		}
		else if (columnIdx >= m_numCols) {
			return NSRect.ZeroRect;
		}
		
		var rect:NSRect = scrollingFrame();
		return new NSRect(m_columnOrigins[columnIdx], rect.origin.y,
			m_columns.internalList()[columnIdx].width(),
			rect.size.height);
	}
	
	/**
	 * <p>
	 * Returns the rectangle containing the row at <code>rowIdx</code>.
	 * </p>
	 * <p>
	 * Returns {@link NSRect#ZeroRect} if <code>rowIdx</code> is out of bounds.
	 * </p>
	 * 
	 * @see #frameOfCellAtColumnRow()
	 * @see #rectOfColumn()
	 */
	public function rectOfRow(rowIdx:Number):NSRect {
		if (rowIdx < 0) {
			return NSRect.ZeroRect;
		}
		else if (rowIdx >= m_numRows) {
			return NSRect.ZeroRect;
		}
		
		var rect:NSRect = scrollingFrame();
		return new NSRect(rect.origin.x, rect.origin.y + (m_rowHeight * rowIdx),
			rect.size.width, m_rowHeight);
	}
	
	/**
	 * <p>
	 * Returns a range of indices for the receiver’s columns that lie wholly or 
	 * partially within the horizontal boundaries of <code>aRect</code>.
	 * </p>
	 * <p>
	 * The location of the range is the first such column’s index, and the 
	 * length is the number of columns that lie in <code>aRect</code>. Both the 
	 * width and height of <code>aRect</code> must be nonzero values, or 
	 * {@link #columnsInRect()} returns an NSRange whose length is 0.
	 * </p>
	 * 
	 * @see #rowsInRect()
	 */
	public function columnsInRect(aRect:NSRect):NSRange {
		var range:NSRange = NSRange.ZeroRange;
		range.location = columnAtPoint(aRect.origin);
		range.length = columnAtPoint(new NSPoint(aRect.maxX(), aRect.origin.y))
			- range.location;
		range.length += 1;
		
		return range;
	}
	
	/**
	 * <p>
	 * Returns a range of indices for the rows that lie wholly or partially 
	 * within the vertical boundaries of <code>aRect</code>.
	 * </p>
	 * <p>
	 * The location of the range is the first such row’s index, and the length 
	 * is the number of rows that lie in <code>aRect</code>. Both the width and 
	 * height of <code>aRect</code> must be nonzero values, or this method 
	 * returns an NSRange whose length is 0.
	 * </p>
	 * 
	 * @see #columnsInRect()
	 */
	public function rowsInRect(aRect:NSRect):NSRange {
		var range:NSRange = NSRange.ZeroRange;
		range.location = rowAtPoint(aRect.origin);
		range.length = rowAtPoint(new NSPoint(aRect.origin.x, aRect.maxY()))
			- range.location;
		range.length += 1;
		
		return range;
	}

	/**
	 * <p>
	 * Returns the index of the column <code>aPoint</code> lies in, or –1 if 
	 * <code>aPoint</code> lies outside the receiver’s bounds.
	 * </p>
	 * <p>
	 * <code>aPoint</code> is in the coordinate system of the receiver.
	 * </p>
	 * 
	 * @see #rowAtPoint()
	 */
	public function columnAtPoint(aPoint:NSPoint):Number {
		var rect:NSRect = scrollingFrame();

		if (!rect.pointInRect(aPoint)) {
			return -1;
		}
		
		var i:Number;
		var col:Number = 0;
		var len:Number = m_columnOrigins.length;
		for (i = 0; i < len; i++) {
			if (m_columnOrigins[i] > aPoint.x) {
				return i - 1;
			}
		}
		
		//
		// Check the last column
		//
		i--;		
		if (m_columnOrigins[i] + m_columns.internalList()[i].width() > aPoint.x) {
			return i;
		}
		
		return -1;
	}

	/**
	 * <p>
	 * Returns the index of the row <code>aPoint</code> lies in, or –1 if 
	 * <code>aPoint</code> lies outside the receiver’s bounds.
	 * </p>
	 * <p>
	 * <code>aPoint</code> is in the coordinate system of the receiver.
	 * </p>
	 * 
	 * @see #columnAtPoint()
	 */
	public function rowAtPoint(aPoint:NSPoint):Number {
		
		var rect:NSRect = scrollingFrame();
		if (!rect.pointInRect(aPoint)) {
			return -1;
		}
						
		var row:Number = _rowAtPoint(aPoint);
		if (row > m_numRows) {
			row = m_numRows - 1;
		}
		
		return row;	
	}
	
	/**
	 * Returns the row at <code>aPoint</code> without performing any bounds
	 * checking.
	 */
	private function _rowAtPoint(aPoint:NSPoint):Number {
		return Math.floor(aPoint.y / m_rowHeight);
	}
	
	/**
	 * <p>
	 * Returns a rectangle locating the cell that lies at the intersection of 
	 * <code>columnIndex</code> and <code>rowIndex</code>.
	 * </p>
	 * <p>
	 * Returns {@link NSRect#ZeroRect} if <code>columnIndex</code> or 
	 * <code>rowIndex</code> is greater than the number of columns or rows in 
	 * the NSTableView.
	 * </p>
	 * <p>
	 * The result of this method is used in an 
	 * {@link NSCell#drawWithFrameInView()} method call to the NSTableColumn’s 
	 * data cell.
	 * </p>
	 * 
	 * @see #rectOfColumn()
	 * @see #rectOfRow()
	 */
	public function frameOfCellAtColumnRow(columnIdx:Number, 
			rowIdx:Number):NSRect {
		if (columnIdx < 0 
				|| columnIdx >= m_numCols
				|| rowIdx < 0
				|| rowIdx >= m_numRows) {
			return NSRect.ZeroRect;		
		}
		
		return _frameOfCellAtColumnRow(columnIdx, rowIdx);
	}
	
	/**
	 * Returns the frame of the cell at the specified column and row without
	 * performing any checking.
	 */
	private function _frameOfCellAtColumnRow(columnIdx:Number, 
			rowIdx:Number):NSRect {
		var frameRect:NSRect = NSRect.ZeroRect;
		
		//
		// Build frame rect
		//
		var b:NSRect = scrollingBounds();
		frameRect.origin.y = b.origin.y + (rowIdx * m_rowHeight);
		frameRect.origin.y += m_intercellSpacing.height / 2;
		frameRect.origin.x = m_columnOrigins[columnIdx];
		frameRect.origin.x += m_intercellSpacing.width / 2;
		frameRect.size.height = m_rowHeight - m_intercellSpacing.height;
		frameRect.size.width = NSTableColumn(m_columns.objectAtIndex(columnIdx)).width();
		frameRect.size.width -= m_intercellSpacing.width;
		
		//
		// Grid
		//
		if (m_gridStyleMask != NSTableViewGridNone) {
			frameRect.size.width -= 4;
			frameRect.origin.x += 2;
		}
		
		//
		// Safety check
		//
		if (frameRect.size.width < 0) {
			frameRect.size.width = 0;
		}
		
		return frameRect;
	}
			
	/**
	 * <p>Returns the tables’s column autoresizing style.</p>
	 * <p>
	 * The default is 
	 * <code>NSTableViewColumnAutoresizingStyle.NSTableViewLastColumnOnlyAutoresizingStyle</code>.
	 * </p>
	 * 
	 * @see setColumnAutoresizingStyle
	 */
	public function columnAutoresizingStyle():NSTableViewColumnAutoresizingStyle {
		return m_colAutoresizeStyle;
	}

	/**
	 * <p>Sets the tables’s column autoresizing style.</p>
	 * <p>
	 * The default is 
	 * <code>NSTableViewColumnAutoresizingStyle.NSTableViewLastColumnOnlyAutoresizingStyle</code>.
	 * </p>
	 *
	 * @see columnAutoresizingStyle
	 */	
	public function setColumnAutoresizingStyle(
			style:NSTableViewColumnAutoresizingStyle):Void {
		m_colAutoresizeStyle = style;
	}
	
	/**
	 * Resizes the last column in the table if there is room so that the
	 * column will occupy all of the available space (if the column's
	 * maxWidth() allows).
	 */
	public function sizeLastColumnToFit():Void {
		if (m_clipView == null) {
			return;
		}
		
		var col:NSTableColumn = NSTableColumn(m_columns.objectAtIndex(m_numCols - 1));
		var x:Number = m_columnOrigins[m_numCols - 1];
		var w:Number = m_clipView.frame().size.width;
		if (x > w) {
			return;
		}
		
		col.setWidth(w - x);
	}
	
	/**
	 * <p>
	 * Informs the receiver that the number of records in its data source has 
	 * changed, allowing the receiver to update the scrollers in its 
	 * NSScrollView without actually reloading data into the receiver.
	 * </p>
	 * <p>
	 * It’s useful for a data source that continually receives data in the 
	 * background over a period of time, in which case the NSTableView can 
	 * remain responsive to the user while the data is received.
	 * </p>
	 * 
	 * @see #reloadData()
	 */
	public function noteNumberOfRowsChanged():Void {
		var rows:Number = m_dataSource.numberOfRowsInTableView(this);
		if (rows == m_numRows) {
			return;
		}
						
		m_numRows = rows;		
		tile();
		
		//
		// If we're shorter than the enclosing clip view, trigger a redraw
		//
		if (m_superview != null) {
			//! TODO implement
		}
	}
	
	//! TODO -(void)noteHeightOfRowsWithIndexesChanged:(NSIndexSet *)indexSet
	
	/**
	 * Resizes all columns in the table to make them all visible within the
	 * table. All columns are resized to the same size, up to their maximum
	 * width.
	 */
	public function sizeToFit():Void {
		
	}
	
	/**
	 * Resizes the columns and their header views, and marks the table as
	 * needing display.
	 */
	public function tile():Void {
		var tableW:Number = 0;
		var tableH:Number;
		
		if (m_numCols > 0) {
			var w:Number;
			var col:NSTableColumn;
			var matrix:ASTableMatrix;
			var arr:Array = m_columns.internalList();
			var len:Number = arr.length;
			
			//
			// Determine column origins
			//
			m_columnOrigins[0] = m_bounds.origin.x;
			col = NSTableColumn(arr[0]);
			matrix = col.columnMatrix();
			w = col.width();
			tableW += w;
			
			//
			// Position matrices
			//
			if (matrix.frame().size.width != w) {
				positionMatrixForColumn(col, m_columnOrigins[0], w);
			}
			
			for (var i:Number = 1; i < len; i++) {
				m_columnOrigins[i] = m_columnOrigins[i - 1] + w;
				
				col = NSTableColumn(arr[i]);
				matrix = col.columnMatrix();
				var matrixFrm:NSRect = matrix.frame();
				w = col.width();
				tableW += w;
				
				//
				// Position matrices
				//
				if (matrixFrm.size.width != w || m_columnOrigins[i] != matrixFrm.origin.x) {
					positionMatrixForColumn(col, m_columnOrigins[i], w);
				}
			}
		}
		
		tableH = m_numRows * m_rowHeight + 1;
		
		//
		// Update the size and post a notification
		//
		setTableSize(new NSSize(tableW, tableH));
				
		//
		// Deal with header
		//
		if (m_headerView != null) {
			var cFrame:NSRect = m_clipView.frame();
			if (cFrame != null && cFrame.size.width > tableW) {
				m_headerView.setFrameWidth(cFrame.size.width);
			} else {
				m_headerView.setFrameWidth(tableW);
			}
			m_headerView.display();
			m_cornerView.setFrameWidth(NSScroller.scrollerWidth() + 1);
			m_cornerView.setNeedsDisplay(true);
		}
		
		//
		// Deal with alternating row colors
		//
		if (m_usesAlternatingRowColors) {
			if (m_rowColorCount % 2 == 0) {
				m_mcAltRows1._visible = true;
				m_mcAltRows2._visible = false;
			} else {
				m_mcAltRows1._visible = false;
				m_mcAltRows2._visible = true;
			}
		}
	}
	
	/**
	 * Recalculates the size of the table's contents.
	 */
	private function updateSize():Void {
		var width:Number = 0;
		var height:Number = 0;
		var arr:Array;
		var len:Number;
		var col:NSTableColumn;
		
		//
		// Compute width
		//
		arr = m_columns.internalList();
		len = arr.length;
		
		for (var i:Number = 0; i < arr.length; i++) {
			col = NSTableColumn(arr[i]);
			width += col.width();
		}
				
		//
		// Compute height
		//
		height = m_numRows * m_rowHeight;
					
		m_tableSize = new NSSize(width, height);
	}
	
	/**
	 * Sets the table size to <code>size</code>.
	 */
	private function setTableSize(size:NSSize):Void {
		if (size == null || m_tableSize.isEqual(size)) {
			return;
		}
		
		m_tableSize = size;
		setFrameWidth(size.width);
		m_mcAltRows1._width = size.width;
		m_mcAltRows2._width = size.width;
		
		m_notificationCenter.postNotificationWithNameObject(
			NSViewFrameDidChangeNotification, this);	
	}
	
	//******************************************************															 
	//*                    Drawing
	//******************************************************
	
	public function drawRect(aRect:NSRect):Void {
		//
		// Do nothing if empty
		//
		if (m_numRows == 0 || m_numCols == 0) {
			return;
		}

		//
		// Declare variables
		//		
		var visible:NSRect = visibleScrollRect();
		var topRow:Number = _rowAtPoint(
			new NSPoint(0, visible.size.height));
		var numRows:Number = topRow + 1;
		var first:Number = _rowAtPoint(m_scrollPoint.clone());
		var range:NSRange = validateDataDisplayRange(new NSRange(first, numRows));
		
		//
		// Reload data if needed
		//
		if (m_reloadDataFlag && m_dataSource != null && m_clipView != null) {
			m_reloadDataFlag = false;
				
			//
			// Reload the data for each column
			//
			var arr:Array = m_columns.internalList();
			var len:Number = arr.length;
			
			for (var i:Number = 0; i < len; i++) {
				var col:NSTableColumn = NSTableColumn(arr[i]);
				reloadDataForMatrixWithColumnInRange(
					col.columnMatrix(), col, range);
			}
		}
	}
	
	/**
	 * Draws an alternating row pattern on a movieclip.
	 */
	private function drawAlternatingRowsWithMovieClip(mc:MovieClip,
			offset:Number, numRows:Number):Void {
		//
		// Get graphics stuff
		//
		var g:ASGraphics = graphics();
		var oldClip:MovieClip = g.clip();
		g.setClip(mc);
		g.clear();
		var theme:ASThemeProtocol = ASTheme.current();
		var altRowColor:NSColor = theme.colorWithName(ASThemeColorNames.ASAlternatingRowColor);
		
		//
		// Get geometry
		//
		var matrix:ASTableMatrix = m_columns.internalList()[0].columnMatrix();
		var rowRect:NSRect = rectOfRow(0);
		rowRect.origin.y = 0;
		rowRect.size.height = matrix.intercellSpacing().height + matrix.cellSize().height;
				
		for (var i:Number = 0; i < numRows; i++) {
			if (offset++ % 2 == 1) {
				g.brushDownWithBrush(altRowColor);
				g.drawRectWithRect(rowRect, null);
				g.brushUp();
			}
						
			rowRect.origin.y += rowRect.size.height;		
		}
		
		g.setClip(oldClip);
	}
	
	//******************************************************
	//*                  Scrolling
	//******************************************************
	
	/**
	 * <p>
	 * Scrolls the receiver vertically in an enclosing NSClipView so the row 
	 * specified by <code>rowIdx</code> is visible.
	 * </p>
	 * 
	 * @see #scrollColumnToVisible()
	 */
	public function scrollRowToVisible(rowIdx:Number):Void {
		if (m_superview == null) { // do nothing
			return;
		}
		
		var cv:NSClipView = m_clipView;
		var rowRect:NSRect = rectOfRow(rowIdx);
		var visRect:NSRect = visibleScrollRect();
		
		if (rowRect.origin.y < visRect.origin.y) {
			var newOrigin:NSPoint = new NSPoint(visRect.origin.x,
				rowRect.origin.y);
			cv.scrollToPoint(newOrigin);
			return;
		}
		
		var diff:Number = rowRect.maxY() - visRect.maxY();
		if (diff > 0) {
			var newOrigin:NSPoint = new NSPoint(visRect.origin.x,
				visRect.origin.y);
			newOrigin.y += diff;
			cv.scrollToPoint(newOrigin);
			return;
		}
	}
	
	/**
	 * <p>
	 * Scrolls the receiver and header view horizontally in an enclosing 
	 * NSClipView so the column specified by <code>columnIdx</code> is visible.
	 * </p>
	 * 
	 * @see #scrollRowToVisible()
	 */
	public function scrollColumnToVisible(columnIdx:Number):Void {
		if (m_superview == null) { // do nothing
			return;
		}
		
		var cv:NSClipView = m_clipView;
		var colRect:NSRect = rectOfColumn(columnIdx);
		var visRect:NSRect = visibleScrollRect();
		
		if (colRect.origin.y < visRect.origin.y) {
			var newOrigin:NSPoint = new NSPoint(colRect.origin.x,
				visRect.origin.y);
			cv.scrollToPoint(newOrigin);
			return;
		}
		
		var diff:Number = colRect.maxX() - visRect.maxX();
		
		if (diff > 0) {
			var newOrigin:NSPoint = new NSPoint(visRect.origin.x,
				visRect.origin.y);
			newOrigin.x += diff;
			cv.scrollToPoint(newOrigin);
			return;
		}
	}
	
	//******************************************************
	//*             Text delegate methods
	//******************************************************
	
	/**
	 * Invoked when <code>notification</code> is posted indicating that there’s 
	 * a change in the text after the matrix gains first responder status.
	 * 
	 * This method’s default behavior is to post an 
	 * <code>NSControlTextDidBeginEditingNotification</code> along with the 
	 * receiving object to the default notification center. The posted 
	 * notification’s user info contains the contents of notification’s user 
	 * info dictionary, plus an additional key-value pair. The additional key is
	 * <code>"NSFieldEditor"</code>; the value for this key is the text object 
	 * that began editing.
	 */
	public function textDidBeginEditing(notification:NSNotification):Void {
		
		//
		// Build the user info dictionary
		//
		var userInfo:NSDictionary = NSDictionary.dictionaryWithDictionary(
			notification.userInfo);
		userInfo.setObjectForKey(notification.object, "NSFieldEditor");
		
		//
		// Post notification
		//
		m_notificationCenter.postNotificationWithNameObjectUserInfo(
			NSControlTextDidBeginEditingNotification, 
			this, 
			userInfo);
	}
	
	/**
	 * Invoked when <code>notification</code> is posted indicating a key-down 
	 * event or paste operation that changes the matrix’s contents.
	 * 
	 * This method’s default behavior is to pass this message on to the selected
	 * cell (if the selected cell responds to {@link #textDidChange}) and 
	 * then to post an <code>NSControlTextDidChangeNotification</code> along 
	 * with the receiving object to the default notification center. The posted 
	 * notification’s user info contains the contents of notification’s user 
	 * info dictionary, plus an additional key-value pair. The additional key is
	 * <code>"NSFieldEditor"</code>; the value for this key is the text object 
	 * that changed.
	 */
	public function textDidChange(notification:NSNotification):Void {
		//
		// Inform cell
		//
		var cell:NSCell = m_editedCell;
		if (cell.respondsToSelector("textDidChange")) {
			cell["textDidChange"](notification);
		}
		
		//
		// Build the user info dictionary
		//
		var userInfo:NSDictionary = NSDictionary.dictionaryWithDictionary(
			notification.userInfo);
		userInfo.setObjectForKey(notification.object, "NSFieldEditor");
		
		//
		// Post notification
		//
		m_notificationCenter.postNotificationWithNameObjectUserInfo(
			NSControlTextDidChangeNotification, 
			this, 
			userInfo);
	}
	
	/**
	 * Invoked when <code>notification</code> is posted indicating that text 
	 * editing ends.
	 * 
	 * This method’s default behavior is to post an 
	 * <code>NSControlTextDidEndEditingNotification</code> along with the 
	 * receiving object to the default notification center. The posted 
	 * notification’s user info contains the contents of notification’s user 
	 * info dictionary, plus an additional key-value pair. The additional key is
	 * <code>"NSFieldEditor"</code>; the value for this key is the text object 
	 * that began editing. After posting the notification, 
	 * {@link #textDidEndEditing()} sends an {@link #endEditing()} 
	 * message to the selected cell, draws and makes the selected cell key, and 
	 * then takes the appropriate action based on which key was used to end 
	 * editing (Return, Tab, or Back-Tab).
	 */
	public function textDidEndEditing(notification:NSNotification) {

		var r:Number, c:Number;

		validateEditing();
		m_editedCell.endEditing(ASFieldEditor(notification.object));
		NSTableColumn(m_columns.objectAtIndex(m_editedCol)).columnMatrix().setNeedsDisplay(true);
		m_editedCell = null;
		
		r = m_editedRow;
		c = m_editedCol;
		m_editedCol = -1;
		m_editedRow = -1;
		
		var d:NSDictionary = NSDictionary.dictionaryWithDictionary(notification.userInfo);
		d.setObjectForKey(notification.object, "NSFieldEditor");
		m_notificationCenter.postNotificationWithNameObjectUserInfo(
			NSControlTextDidEndEditingNotification,
			this, d);
			
		var textMovement:NSTextMovement = NSTextMovement(
			notification.userInfo.objectForKey("NSTextMovement"));
			
		if (textMovement != null) {
			switch (textMovement) {
				case NSTextMovement.NSReturnTextMovement:
				
					break;
					
				case NSTextMovement.NSTabTextMovement:
//					if (_editNextEditableCellAfterRowColumn(r, c)) {
//						break;
//				    }				
					m_window.selectKeyViewFollowingView(this);
					break;
					
				case NSTextMovement.NSBacktabTextMovement:
//					if (_editPreviousEditableCellBeforeRowColumn(r, c)) {
//						break;
//				    }
	    			m_window.selectKeyViewPrecedingView(this);
					break;
			}
		}
	}
	
	/**
	 * This method’s default behavior is to call 
	 * {@link #controlTextShouldBeginEditing()} on the matrix's delegate
	 * (passing the receiver and <code>editor</code> as parameters). The 
	 * {@link #textShouldBeginEditing()} method returns the value obtained 
	 * from {@link #controlTextShouldBeginEditing()}, unless the delegate 
	 * doesn’t respond to that method, in which case it returns 
	 * <code>true</code>, thereby allowing text editing to proceed.
	 */
	public function textShouldBeginEditing(editor:Object):Boolean {
		//trace("NSMatrix.textShouldBeginEditing(editor)");
		
		var del:Object = delegate();
		if (del != null && ASUtils.respondsToSelector(del, 
				"controlTextShouldBeginEditing")) {
			return del["controlTextShouldBeginEditing"](this, editor);
		}
		
		return true;
	}
	
	/**
	 *  This method’s default behavior checks the text field for validity; 
	 *  providing that the field contents are deemed valid, and providing that 
	 *  the delegate responds, {@link #controlTextShouldEndEditing()} is 
	 *  called on the matrix's delegate (passing the receiver and editor as 
	 *  parameters). If the contents of the text field aren’t valid, 
	 *  {@link #textShouldEndEditing()} sends the error action to the 
	 *  selected cell’s target.
	 *  
	 *  The {@link #textShouldEndEditing()} method returns 
	 *  <code>false</code> if the text field contains invalid contents; 
	 *  otherwise it returns the value passed back from 
	 *  {@link #controlTextShouldEndEditing()}.
	 */
	public function textShouldEndEditing(editor:Object):Boolean {		
		//! TODO validate text field
		
		var del:Object = delegate();
		if (del != null && ASUtils.respondsToSelector(del, 
				"controlTextShouldEndEditing")) {
			return del["controlTextShouldEndEditing"](this, editor);	
		}
		
		return true;
	}
	
	//******************************************************
	//*                  Cell editing
	//******************************************************
	
	/**
	 * If the receiver is being edited—that is, it has a field editor and is the 
	 * first responder of its <code>NSWindow</code>—this method returns the field 
	 * editor; otherwise, it returns <code>null</code>.
	 */
	public function currentEditor():ASFieldEditor {
		var fe:ASFieldEditor = ASFieldEditor.instance();    
		if (fe.isEditing() && fe.cell() == m_editedCell) {
			return fe;
		}
		    
		return null;
	}
	
	/**
	 * Validates the user’s changes to text in a cell of the receiving control.
	 * 
	 * Validation sets the object value of the cell to the current contents of the
	 * cell’s editor, storing it as a string or an attributed string object based 
	 * on the attributes of the editor.
	 */
	public function validateEditing():Void {
		var editor:ASFieldEditor = currentEditor();
		if (editor == null) {
			return;
		}
		
		// TODO Deal with custom formatter stuff
		
		m_editedCell.setObjectValue(editor.string());
		
		if (m_editableDataSource) {
			setObjectValueForTableColumnRow(
				editor.string(),
				NSTableColumn(m_columns.objectAtIndex(m_editedCol)),
				m_editedRow);
			
		}
	}
	
	/**
	 * Terminates and discards any editing of text displayed by the receiver and 
	 * removes the field editor’s delegate.
	 * 
	 * Returns <code>true</code> if there was a field editor associated with the 
	 * control, <code>false</code> otherwise.
	 */
	public function abortEditing():Boolean {
	    var editor:ASFieldEditor = currentEditor();
	    if (editor == null) {
			return false;
		}
		
		m_editedCell.endEditing(editor);
		m_editedCell = null;
		m_editedRow = -1;
		m_editedCol = -1;

		return true;
	}
	
	//******************************************************															 
	//*               Setting the delegate
	//******************************************************
	
	/**
	 * Returns the table's delegate.
	 * 
	 * @see #setDelegate
	 */
	public function delegate():Object {
		return m_delegate;
	}
	
	
	/**
	 * Sets this table's delegate to delegate.
	 * 
	 * @see #setDelegate
	 */
	public function setDelegate(delegate:Object):Void {
		m_delegate = delegate;
		m_delegateWatchesDisplay = ASUtils.respondsToSelector(m_delegate, 
			"tableViewWillDisplayCellForTableColumnRow");
	}
	
	//******************************************************															 
	//*            Setting the indicator image
	//******************************************************
	
	/**
	 * Returns the sort indicator image for <code>aTableColumn</code>.
	 */
	public function indicatorImageInTableColumn(aTableColumn:NSTableColumn):NSImage {
		return aTableColumn.indicatorImage();
	}
	
	/**
	 * Sets the sort indicator image for <code>aTableColumn</code> to
	 * <code>anImage</code>.
	 */
	public function setIndicatorImageInTableColumn(anImage:NSImage,
			aTableColumn:NSTableColumn):Void {
		//! TODO Figure out how to use these
		aTableColumn.setIndicatorImage(anImage);
	}
	
	//******************************************************															 
	//*       Supporting highlightable column headers
	//******************************************************
	
	/**
	 * Returns the column highlighted in this table.
	 */
	public function highlightedTableColumn():NSTableColumn {
		return m_highlightedCol;
	}
	
	/**
	 * Sets aTableColumn to be the currently highlighted column header.
	 */
	public function setHighlightedTableColumn(aTableColumn:NSTableColumn):Void {
		m_highlightedCol = aTableColumn;		
		m_headerView.setNeedsDisplay(true);
	}
	
	//******************************************************															 
	//*                    Dragging
	//******************************************************
	
//TODO	– dragImageForRowsWithIndexes:tableColumns:event:offset:
//TODO	– canDragRowsWithIndexes:atPoint:
//TODO	– setDraggingSourceOperationMask:forLocal:
//TODO	– setDropRow:dropOperation:

	/**
	 * Returns whether a click and drag motion vertically instructs a drag or
	 * a selection change. TRUE begins a drag.
	 *
	 * Horizontal motion always begins a drag.
	 */
	public function verticalMotionCanBeginDrag():Boolean {
		return m_vertMotionBeginsDrag;
	}
	
	/**
	 * Sets whether a click and drag motion vertically instructs a drag or
	 * a selection change. TRUE begins a drag.
	 *
	 * Horizontal motion always begins a drag.
	 */	
	public function setVerticalMotionCanBeginDrag(flag:Boolean):Void {
		m_vertMotionBeginsDrag = flag;
	}

	//******************************************************															 
	//*                     Sorting
	//******************************************************
	
	/**
	 * Sets the table's sort descriptors to the contents of <code>array</code>.
	 */
	public function setSortDescriptors(array:NSArray):Void {
		if (m_sortDescriptors.isEqualToArray(array)) {
			return;
		}
		
		var oldDescriptors:NSArray = sortDescriptors();
		m_sortDescriptors = array;
		
		//
		// Notify the data source that the sort descriptors changed.
		//
		if (m_dataSource != null && ASUtils.respondsToSelector(m_dataSource,
				"tableViewSortDescriptorsDidChange")) {
			m_dataSource.tableViewSortDescriptorsDidChange(
				this, oldDescriptors);
		}
	}
	
	/**
	 * Returns this table's sort descriptors.
	 */
	public function sortDescriptors():NSArray {
		return m_sortDescriptors;
	}
	
	//******************************************************															 
	//*            Delegate method dispatchers
	//*     (These methods are internal, so don't touch)
	//******************************************************
	
	/**
	 * <p>
	 * Invokes the <code>tableViewDidDragTableColumn()</code> method on the 
	 * delegate.
	 * </p>
	 * <p>
	 * The method signature should be:<br/>
	 * <code>tableViewDidDragTableColumn(NSTableView, NSTableColumn)</code>.
	 * </p>
	 */
	public function postDidDragTableColumn(column:NSTableColumn):Void {
		if (ASUtils.respondsToSelector(m_delegate, 
				"tableViewDidDragTableColumn")) {
			m_delegate["tableViewDidDragTableColumn"](this,	column);	
		}
	}
    
	/**
	 * <p>
	 * Invokes the <code>tableViewColumnDidMove()</code> method on the 
	 * delegate and posts an <code>NSTableViewColumnDidMoveNotification</code> 
	 * to the default notification center. 
	 * </p>
	 * <p>
	 * The method signiture of the message is:<br/>
	 * <code>tableViewColumnDidMove(NSNotification)</code>
	 * </p>
	 * <p>
	 * The NSNotification sent to the delegate is an 
	 * <code>NSTableViewColumnDidMoveNotification</code>.
	 * </p> 
	 */    
    public function postColumnDidMove(oldIdx:Number, newIdx:Number):Void {
    	//
    	// Build the notification.
    	//
    	var notf:NSNotification = NSNotification.withNameObjectUserInfo(
    		NSTableViewColumnDidMoveNotification,
    		this,
    		NSDictionary.dictionaryWithObjectsAndKeys(
    			oldIdx, "NSOldColumn",
    			newIdx, "NSNewColumn"));
    	
    	//
    	// Post it to the default notification center.
    	//
    	NSNotificationCenter.defaultCenter().postNotification(
    		notf);
    		
    	//
    	// Dispatch it to the delegate.
    	//
		if (ASUtils.respondsToSelector(m_delegate, "tableViewColumnDidMove")) {
			m_delegate["tableViewColumnDidMove"](notf);	
		}
    }

	/**
	 * <p>
	 * Invokes the <code>tableViewColumnDidResize()</code> method on the 
	 * delegate and posts an <code>NSTableViewColumnDidMoveNotification</code> 
	 * to the default notification center.
	 * </p>
	 * <p>
	 * The method signiture of the message is:<br/>
	 * <code>tableViewColumnDidResize(NSNotification)</code>
	 * </p>
	 * <p>
	 * The NSNotification sent to the delegate is an 
	 * <code>NSTableViewColumnDidMoveNotification</code>.
	 * </p> 
	 */
    public function postColumnDidResize(column:NSTableColumn, 
    		oldWidth:Number):Void {
    	//
    	// Build the notification.
    	//
    	var notf:NSNotification = NSNotification.withNameObjectUserInfo(
    		NSTableViewColumnDidMoveNotification,
    		this,
    		NSDictionary.dictionaryWithObjectsAndKeys(
    			column, "NSTableColumn",
    			oldWidth, "NSOldWidth"));
    	
    	//
    	// Post it to the default notification center.
    	//
    	NSNotificationCenter.defaultCenter().postNotification(
    		notf);
    		
    	//
    	// Dispatch it to the delegate.
    	//
		if (ASUtils.respondsToSelector(m_delegate, "tableViewColumnDidResize")) 
		{
			m_delegate["tableViewColumnDidResize"](notf);	
		}
    }
      
	/**
	 * <p>
	 * Invokes the <code>tableViewMouseDownInHeaderOfTableColumn()</code> 
	 * method on the delegate.
	 * </p>
	 * <p>
	 * The method signiture of the message is:<br/>
	 * <code>tableViewMouseDownInHeaderOfTableColumn(NSTableView, NSTableColumn)</code>
	 * </p>
	 */
	public function postMouseDownInHeaderOfTableColumn(column:NSTableColumn)
			:Void {
		if (ASUtils.respondsToSelector(m_delegate, 
				"tableViewMouseDownInHeaderOfTableColumn")) {
			m_delegate["tableViewMouseDownInHeaderOfTableColumn"](this,	column);	
		}
	}
	
	/**
	 * Posts a notification when selection changes.
	 */
	private function postSelectionDidChangeNotification():Void {
		m_notificationCenter.postNotificationWithNameObject(
			NSTableViewSelectionDidChangeNotification,
			this);
	}
	
	/**
	 * Wraps around the <code>tableViewShouldSelectTableColumn()</code>
	 * delegate method.
	 */
	private function shouldSelectTableColumn(col:NSTableColumn):Boolean {
		if (m_delegate != null && ASUtils.respondsToSelector(m_delegate, 
				"tableViewShouldSelectTableColumn")) {
			return m_delegate["tableViewShouldSelectTableColumn"](this, col);	
		}
		return true;
	}
	
	/**
	 * Wraps around the <code>tableViewShouldSelectRow()</code>
	 * delegate method.
	 */
	private function shouldSelectRow(row:Number):Boolean {
		if (m_delegate != null && ASUtils.respondsToSelector(m_delegate, 
				"tableViewShouldSelectRow")) {
			return m_delegate["tableViewShouldSelectRow"](this, row);	
		}
		return true;
	}
	
	/**
	 * Wraps around the <code>selectionShouldChangeInTableView()</code>
	 * delegate method.
	 */
	private function shouldSelectionChange():Boolean {
		if (m_delegate != null && ASUtils.respondsToSelector(m_delegate, 
				"selectionShouldChangeInTableView")) {
			return m_delegate["selectionShouldChangeInTableView"](this);	
		}
		return true;
	}
	
	/**
	 * Wraps around the <code>tableViewShouldEditTableColumnRow()</code>
	 * delegate method.
	 */
	private function shouldEditTableColumnRow(column:NSTableColumn, row:Number):Boolean {
		if (m_delegate != null && ASUtils.respondsToSelector(m_delegate, 
				"tableViewShouldEditTableColumnRow")) {
			return m_delegate["tableViewShouldEditTableColumnRow"](this, column, row);	
		}
		return true;
	}
	
	/**
	 * Wraps around the <code>tableViewWillDisplayCellForTableColumnRow()</code>
	 * delegate method.
	 */
	private function willDisplayCellForTableColumnRow(cell:NSCell, 
			column:NSTableColumn, row:Number):Void {
		if (m_delegateWatchesDisplay) {
			m_delegate["tableViewWillDisplayCellForTableColumnRow"](this, cell, column, row);
		}
	}
	
	/**
	 * Wraps around the <code>tableViewObjectValueForTableColumnRow()</code>
	 * delegate method.
	 */
	private function objectValueForTableColumnRow(column:NSTableColumn, row:Number):Object {
		var res:Object = null;
		if (m_delegate != null && ASUtils.respondsToSelector(m_delegate,
				"tableViewObjectValueForTableColumnRow")) {
			res = m_delegate["tableViewObjectValueForTableColumnRow"](this, column, row);	
		}
		
		return res;
	}
	
	/**
	 * Used to modify an editable datasource.
	 */
	private function setObjectValueForTableColumnRow(val:Object, col:NSTableColumn,
			row:Number):Void {
		m_dataSource["tableViewSetObjectValueForTableColumnRow"](
			this, val, col, row);		
	}
	
	//******************************************************
	//*                  Event handling
	//******************************************************
	
	/**
	 * Invoked when the mouse is clicked on the table.
	 */
	public function mouseDown(event:NSEvent):Void {
		//
		// Make the tableview first responder
		//
		window().makeFirstResponder(this);
		
		
		var loc:NSPoint;
		var clickCount:Number;
		var tblcol:NSTableColumn;
				
		//
		// Empty table
		//
		if (m_numRows == 0 || m_numCols == 0) {
			super.mouseDown(event);
			return;
		}
		
		//
		// Ignore multi-click (more than 2)
		//
		clickCount = event.clickCount;
		if (clickCount > 2) {
			return;
		}
				
		//
		// Record necessary information
		//
		loc = convertExternalPointFromView(event.mouseLocation, null);
		m_clickedCol = columnAtPoint(loc);
		m_clickedRow = rowAtPoint(loc);
		tblcol = NSTableColumn(m_columns.objectAtIndex(m_clickedCol));
		
		//
		// Perform action
		//
		if (clickCount == 2) {
			if (!isRowSelected(m_clickedRow)) {
				return;
			}
			
			if (!tblcol.isEditable() 
					|| !shouldEditTableColumnRow(tblcol, m_clickedRow)) {
				sendActionTo(m_dblAction, m_target);
			} else {
				editColumnRowWithEventSelect(m_clickedCol, m_clickedRow,
					event, true);
			}
		} 
		else if (m_clickedRow != -1) {
			var mods:Number = event.modifierFlags;
			var selRow:Number = m_selectedRow;
			var selRows:NSIndexSet = m_selectedRows;
			var numSelRows:Number = selRows.count();
			var addToSel:Boolean = m_allowsMultiSelection 
				&& (mods & NSEvent.NSCommandKeyMask) != 0;
			var remFromSel:Boolean = (m_allowsEmptySelection || numSelRows > 1) 
				&& (mods & NSEvent.NSCommandKeyMask) != 0;
			var addListToSel:Boolean = m_allowsMultiSelection
				&& (mods & NSEvent.NSCommandKeyMask) == 0
				&& (mods & NSEvent.NSShiftKeyMask) != 0
				&& selRow != -1;
				
			if (selRows.containsIndex(m_clickedRow)) { // selected
				if (remFromSel) {
					deselectRow(m_clickedRow);
				} else {
					selectRowIndexesByExtendingSelection(
						NSIndexSet.indexSetWithIndex(m_clickedRow), false);
				}
			} else { // not selected
				if (addListToSel) {
					var range:NSIndexSet = NSIndexSet.indexSetWithIndexesInRange(
						new NSRange(Math.min(m_clickedRow, selRow),
							Math.abs(m_clickedRow - selRow)), true);
				} else {
					selectRowIndexesByExtendingSelection(
						NSIndexSet.indexSetWithIndex(m_clickedRow), addToSel);
				}
			}
			
			//
			// Allow cell to be pressed
			//
			m_clickedValue = tblcol.dataCellForRow(m_clickedRow).objectValue();
			tblcol.columnMatrix().matrixMouseDown(event);
			return;
		}
	}
	
	/**
	 * Performs the mouse up action.
	 */
	public function mouseUpInCellDidTrack(event:NSEvent, cell:NSCell, 
			didTrack:Boolean):Void {
		trace(didTrack);
		trace(m_clickedValue);
		trace(cell.objectValue());
		
		var col:NSTableColumn = NSTableColumn(m_columns.objectAtIndex(m_clickedCol));
		
		//
		// Change the cell value in the dataprovider
		//
		if (didTrack) {
			if (cell.objectValue() == null && m_clickedValue != null) {
				cell.setObjectValue(m_clickedValue);
			}
			else if (col.isEditable() && m_editableDataSource) { 
				setObjectValueForTableColumnRow(cell.objectValue(),
					col, m_clickedRow);
			}
		}
		

	}
	
	//******************************************************
	//*                 Keyboard events
	//******************************************************
	
	/**
	 * Handles the keyboard selection mechanism
	 */
	public function keyDown(event:NSEvent):Void {
		var code:Number = event.keyCode;
		
		if (code != Key.UP && code != Key.DOWN || m_numRows == 0 
				|| m_numCols == 0) {
			return;
		}
		
		//
		// Determine the next row
		//
		var nextRow:Number;
		if (code == Key.UP) {
			if (m_selectedRow == -1) {
				nextRow = m_numRows - 1;
			}
			else if (m_selectedRow == 0) {
				nextRow = 0;
			} else {
				nextRow = m_selectedRow - 1;
			}
		}
		else if (code == Key.DOWN) {
			if (m_selectedRow == -1) {
				nextRow = 0;
			}
			else if (m_selectedRow == m_numRows - 1) {
				nextRow = m_numRows - 1;
			} else {
				nextRow = m_selectedRow + 1;
			}
		}
				
		//
		// Add the indexes to the selection, and extend the current selection
		// if shift is pressed.
		//
		selectRowIndexesByExtendingSelection(
			NSIndexSet.indexSetWithIndex(nextRow),
			(event.modifierFlags & NSEvent.NSShiftKeyMask) != 0);
		scrollRowToVisible(nextRow);
	}
	
	//******************************************************
	//*                 Sizing events
	//******************************************************
	
	/**
	 * Invoked when the clip view's size changes.
	 */
	private function superviewFrameChanged(ntf:NSNotification):Void {
		
		var cHeight:Number = m_clipView.frame().size.height;
		var visible:NSRect = visibleScrollRect();
		var topRow:Number = _rowAtPoint(new NSPoint(0, visible.size.height));
		var numRows:Number = topRow + 1;
				
		if (numRows != m_numRowsPerMatrix) {	
			if (numRows <= m_numRows) {
				var delta:Number = numRows - m_numRowsPerMatrix;
				changeMatrixRowCountByDelta(delta);
			}	
		}
				
		drawAlternatingRowsWithMovieClip(m_mcAltRows1, 0, numRows);
		drawAlternatingRowsWithMovieClip(m_mcAltRows2, 1, numRows);
		
		setFrameHeight(visible.size.height);
	}
	
	//******************************************************
	//*                    Overrides
	//******************************************************
	
	/**
	 * Returns <code>true</code> if the table is enabled, or <code>false</code> 
	 * otherwise.
	 */
	public function isEnabled():Boolean {
		return m_enabled;
	}
	
	/**
	 * Sets the enabled property of the table to <code>flag</code>.
	 */
	public function setEnabled(flag:Boolean):Void {
		if (flag == m_enabled) {
			return;
		}
		
		m_enabled = flag;
		
		m_invalidParts.enabledState = true;
	}
	
	private function convertExternalPointFromView(point:NSPoint, view:NSView):NSPoint {
		var pt:NSPoint = super.convertPointFromView(point, view);
		pt.y += m_scrollPoint.y;
		return pt;
	}
	
	private function convertExternalRectFromView(rect:NSRect, view:NSView):NSRect {
		rect = super.convertRectFromView(rect, view);
		rect.origin.y += m_scrollPoint.y;
		return rect;
	}
	
	private function viewWillMoveToWindow(window:NSWindow):Void {
		super.viewWillMoveToWindow(window);
		tile();
	}
	
	/**
	 * This method ensures we are contained within a scrollview.
	 */
	private function viewDidMoveToSuperview():Void {
		//
		// Cleanup
		//
		if (m_clipView != null) {
			m_notificationCenter.removeObserverNameObject(this,
				null, m_clipView);
		}
		
		//
		// Check that we're in a scroll view
		//
		var sv:NSScrollView = enclosingScrollView();
		if (sv == null) {
			m_clipView = null;
			m_scrollView = null;
			trace(asError("Table views can only be used inside scroll views"));
			return;
		}
		
		//
		// Set up incremental scrolling
		//
		m_scrollView = sv;
		m_scrollView.setScrollsByLineIncrementsOnly(true);
		m_scrollView.setVerticalLineScroll(m_rowHeight);
		m_scrollView.setHorizontalLineScroll(5);
		
		//
		// Watch clip view for size changes
		//
		m_clipView = m_scrollView.contentView();
		m_clipView.setPostsFrameChangedNotifications(true);
		m_notificationCenter.addObserverSelectorNameObject(
			this, "superviewFrameChanged",
			NSView.NSViewFrameDidChangeNotification,
			m_clipView);
			
		//
		// Set up matrices
		//
		var arr:Array = m_columns.internalList();
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			buildMatrixForColumn(NSTableColumn(arr[i]));
		}
		tile();
		
		//
		// Draw alternating rows
		//
		var visible:NSRect = visibleScrollRect();
		var topRow:Number = _rowAtPoint(new NSPoint(0, visible.size.height));
		drawAlternatingRowsWithMovieClip(m_mcAltRows1, 0, topRow);
		drawAlternatingRowsWithMovieClip(m_mcAltRows2, 1, topRow);
	}
			
	//******************************************************															 
	//*             Internal ActionStep Methods
	//*           (This is plumbing, don't touch)
	//******************************************************
	
	/**
	 * Used internally by the table header to send double actions.
	 */
	public function sendDoubleActionForColumn(colIdx:Number):Void {
		m_clickedCol = colIdx;
		sendActionTo(m_dblAction, m_target);
	}
	
	/**
	 * <p>Returns the data range currently being displayed.</p>
	 * 
	 * <p>For internal use only.</p>
	 */
	public function displayedDataRange():NSRange {
		return m_displayedDataRange.clone();
	}
	
	/**
	 * <p>Returns whether the table is currently selecting columns.</p>
	 * 
	 * <p>For internal use only.</p>
	 */
	public function isSelectedColumns():Boolean {
		return m_selectingCols;
	}
	
	//******************************************************
	//*               Active Scroll Document
	//******************************************************
	
	private var m_scrollPoint:NSPoint;
	
	/**
	 * Returns <code>true</code> to indicate to the clip view that this
	 * object includes special methods to override scrolling behaviour.
	 */
	private function isActiveScrollDocument():Boolean {
		return true;
	}
	
	/**
	 * Returns the upper left hand corner of the displayed table area.
	 */
	private function scrollPoint():NSPoint {
		return m_scrollPoint;
	}
	
	/**
	 * <p>Scrolls the table to <code>point</code>.</p>
	 * 
	 * <p>This method sets the table's frame origin internally.</p>
	 */
	private function scrollToPoint(point:NSPoint):Void {
		point.y = Math.round(point.y / m_rowHeight) * m_rowHeight;
		
		m_scrollPoint = point;
		setFrameXOrigin(-point.x);
						
		//
		// Determine if the first row is different.
		//
		var first:Number = rowAtPoint(point);
		var change:Number = first - m_displayedDataRange.location;
		m_rowColorCount += change;
		if (change != 0) {
			scrollMatrixDataByAmount(change);
			
			if (m_usesAlternatingRowColors) {
				if (m_rowColorCount % 2 == 0) {
					m_mcAltRows1._visible = true;
					m_mcAltRows2._visible = false;
				} else {
					m_mcAltRows1._visible = false;
					m_mcAltRows2._visible = true;
				}
			}
		}
	}
	
	/**
	 * Returns the scrolling frame.
	 */
	public function scrollingFrame():NSRect {
		return new NSRect(0, 0, m_tableSize.width, m_tableSize.height);
	}
	
	/**
	 * Returns a rectangle representing what the bounds would be if the
	 * tableview were not an active scrolling document.
	 */
	public function scrollingBounds():NSRect {
		return new NSRect(-m_scrollPoint.x, -m_scrollPoint.y,
			Math.max(m_frame.size.width, m_tableSize.width), 
			Math.max(m_tableSize.height, m_frame.size.height));
	}
	
	/**
	 * Returns the table's visible area.
	 */
	public function visibleScrollRect():NSRect {
		if (m_clipView == null) {
			return null;
		}
		
		var clipFrm:NSRect = m_clipView.frame();
		return NSRect.withOriginSize(m_scrollPoint, clipFrm.size);
	}
	
	//******************************************************															 
	//*                  Private Methods
	//******************************************************
	
	/**
	 * Constrains and sets the data display range, then returns a copy.
	 */
	private function validateDataDisplayRange(proposedRange:NSRange):NSRange {
		if (proposedRange.upperBound() >= m_numRows) {
			proposedRange.length = m_numRows - proposedRange.location;	
		}
		
		m_displayedDataRange = proposedRange;
		return proposedRange.clone();
	}
	
	/**
	 * Builds the matrix to be used by the column <code>col</code>.
	 */
	private function buildMatrixForColumn(col:NSTableColumn):Void {
		//
		// Remove current matrix if any
		//
		destroyMatrixForColumn(col);
		
		//
		// Build new matrices
		//
		var matrix:ASTableMatrix;
		var visible:NSRect = visibleScrollRect();
		var y:Number = 0;
		var w:Number = col.width();
		var h:Number = visible.size.height;
		var intercell:NSSize = intercellSpacing();
		var topRow:Number = _rowAtPoint(new NSPoint(0, h));
		var numRows:Number = m_numRowsPerMatrix = topRow + 1;
		if (numRows > m_numRows) {
			numRows = m_numRowsPerMatrix = m_numRows;
			topRow = numRows - 1;
		}
		
		var topRowFrame:NSRect = _frameOfCellAtColumnRow(0, topRow);
		h = topRowFrame.maxY() + intercell.height;
				
		//
		// Build matrix
		//
		var matrixFrame:NSRect = new NSRect(0, y, w, h);
		matrix = ASTableMatrix((new ASTableMatrix())
			.initWithFrameModePrototypeNumberOfRowsNumberOfColumns(
				matrixFrame,
				NSMatrixMode.NSHighlightModeMatrix,
				col.dataCell(),
				numRows, 1));
		matrix.setAllowsEmptySelection(true);
		matrix.setCellSize(topRowFrame.size);
		matrix.setIntercellSpacing(new NSSize(intercell.width / 2, intercell.height));
		matrix.setTableView(this);
		matrix.setTableColumn(col);
		matrix.setDrawsBackground(false);
		
		//
		// Add the matrix as a subview
		//
		addSubview(matrix);
					
		//
		// Associate the matrix with the column
		//
		col.setColumnMatrix(matrix);
		
		//
		// If we have a datasource, fill the matrix
		//
		if (m_dataSource != null) {
			var first:Number = rowAtPoint(m_scrollPoint.clone());
			var range:NSRange = validateDataDisplayRange(new NSRange(first, numRows));
			reloadDataForMatrixWithColumnInRange(
				matrix, col, range);
		}
	}
	
	/**
	 * Destroys the matrix associated with a column.
	 */
	private function destroyMatrixForColumn(col:NSTableColumn):Void {
		var matrix:ASTableMatrix = col.columnMatrix();
		matrix.removeFromSuperview();
		matrix.release();
	}
	
	/**
	 * Horizontally positions and scales the matrix for a column.
	 */
	private function positionMatrixForColumn(col:NSTableColumn, x:Number,
			width:Number):Void {
		var matrix:ASTableMatrix = col.columnMatrix();
		matrix.setFrameXOrigin(x);
		if (width != null) {
			matrix.setFrameWidth(width);
			matrix.display();
		}
	}
	
	/**
	 * Changes the number of rows shown in column matrices by a delta amount.
	 */
	private function changeMatrixRowCountByDelta(delta:Number):Void {				
		var cols:Array = m_columns.internalList();
		var len:Number = cols.length;
		var col:NSTableColumn;
		var matrix:ASTableMatrix;
		
		if (delta < 0) {
			var removeIndex:Number = m_numRowsPerMatrix + delta;
			
			for (var i:Number = 0; i < len; i++) {
				col = cols[i];
				matrix = col.columnMatrix();
				
				var cnt:Number = Math.abs(delta);
				while (cnt > 0) {
					matrix.removeRow(removeIndex);
					cnt--;	
				}
			}
		} else {
			var rowRange:NSRange = new NSRange(m_numRowsPerMatrix, delta);
			
			for (var i:Number = 0; i < len; i++) {
				col = cols[i];
				matrix = col.columnMatrix();
				
				var data:Array = m_dataSource["tableViewObjectValuesForTableColumnRange"](
					this, col, rowRange).internalList();
				var j:Number = 0;
				var cnt:Number = Math.abs(delta);
				while (cnt > 0) {
					matrix.addRow();
					matrix.cellAtRowColumn(m_numRowsPerMatrix + j, 0)
						.setObjectValue(data[i++]);
					cnt--;	
				}
			}
		}
		
		m_numRowsPerMatrix += delta;
		m_displayedDataRange.length = m_numRowsPerMatrix;
	}
	
	/**
	 * Scrolls the table matrices by <code>amount</code> number of rows. If
	 * amount is positive, the matrices scroll down. If it is negative, it
	 * scrolls up.
	 */
	private function scrollMatrixDataByAmount(amount:Number):Void {
		if (amount == 0) {
			return;
		}
						
		var scrollDown:Boolean = amount > 0;
		var mag:Number = Math.abs(amount);
		var rowRange:NSRange;
		if (scrollDown) { 
			rowRange = new NSRange(m_displayedDataRange.location + amount, 
				m_displayedDataRange.length);
			if (rowRange.upperBound() >= m_numRows) {
				rowRange.length = m_numRows - rowRange.location;
				mag = rowRange.length;
			}
		} else {
			rowRange = new NSRange(m_displayedDataRange.location + amount, 
				m_displayedDataRange.length);
			
			if (rowRange.location < 0) {
				rowRange.location = 0;
			}
		}		
		
		var arr:Array = m_columns.internalList(); // column list
		var visRowCount:Number = arr[0].columnMatrix().numberOfRows();
		
		//
		// If we have to reload everything, we might as well use reloadData.
		//
		if (visRowCount <= mag) {
			reloadData();
			displayIfNeeded();
			return;
		}
		
		//
		// Update the data range
		//
		m_displayedDataRange.location += amount;
		if (m_displayedDataRange.location < 0) {
			m_displayedDataRange.location = 0;
		}
		validateDataDisplayRange(m_displayedDataRange);
		
		var len:Number = arr.length;
		var col:NSTableColumn;
		var matrix:ASTableMatrix;
		
		for (var i:Number = 0; i < len; i++) {
			col = arr[i];
			matrix = col.columnMatrix();
						
			var data:Array = m_dataSource["tableViewObjectValuesForTableColumnRange"](
				this, col, rowRange).internalList();
			var cells:Array = matrix.cells().internalList();
			
			for (var j:Number = 0; j < visRowCount; j++) {
				if (j < data.length) {
					var cell:NSCell = NSCell(cells[j]);
					// TODO deal with state
					cell.setObjectValue(data[j]);
				}
			}
			
			matrix.display();
		}
	}
	
	/**
	 * Sets the data contents of a matrix to a range of data from the specified
	 * column.
	 */
	private function reloadDataForMatrixWithColumnInRange(matrix:ASTableMatrix, 
			column:NSTableColumn, rowRange:NSRange):Void {
		var data:Array = m_dataSource["tableViewObjectValuesForTableColumnRange"](
			this, column, rowRange).internalList();

		if (data == null) {
			return;
		}
					
		var arr:Array = matrix.cells().internalList();
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			if (i < data.length) {
				NSCell(arr[i]).setObjectValue(data[i]);
			}
		}

		matrix.setNeedsDisplay(true);
	}
	
	/**
	 * A compare function (for NSArray) used by 
	 * NSTableView::columnWithIdentifier to match column identifiers.
	 */
	private function compareTableColumnIdentifiers(a:NSTableColumn, 
			b:NSTableColumn):Boolean {		
		var aId:Object = a.identifier();
		var bId:Object = b.identifier();
		
		//
		// Test for existence of isEqual methods.
		//! This is all probably slow. Figure out something better.
		//
		if (aId.isEqual != undefined && 
			aId.isEqual instanceof Function)
		{
			return aId.isEqual(bId);
		}
		else if (bId.isEqual != undefined && 
			bId.isEqual instanceof Function)
		{
			return bId.isEqual(aId);
		}
		
		//
		// Fall back on equality operator.
		//
		return aId == bId;
	}
	
	//******************************************************															 
	//*                  Notifications
	//******************************************************
	
	/**
	 * <p>Posted whenever a column is moved by user action.</p>
	 *
	 * <p>The userInfo dictionary contains the following:</p>
	 *
	 * <p>
	 * "NSOldColumn": The column's original index. (Number)<br/>
	 * "NSNewColumn": The column's new index. (Number)
	 * </p>
	 */
	public static var NSTableViewColumnDidMoveNotification:Number 
		= ASUtils.intern("NSTableViewColumnDidMoveNotification");
		
		
	/**
	 * <p>Posted whenever a column is resized.</p>
	 *
	 * <p>The userInfo dictionary contains the following:</p>
	 * <p>
	 * "NSTableColumn": The column that was resized. (NSTableColumn)<br/>
	 * "NSOldWidth": The column's old width. (Number)
	 * </p>
	 * <p>
	 * <strong>NOTE:</strong><br/>
	 * 	This notification is posted on behalf of the table by the column that
	 *	resized.
	 * </p>
	 */
	public static var NSTableViewColumnDidResizeNotification:Number 
		= ASUtils.intern("NSTableViewColumnDidResizeNotification");
		
		
	/**
	 * Posted after an NSTableView’s selection changes. 
	 */
	public static var NSTableViewSelectionDidChangeNotification:Number 
		= ASUtils.intern("NSTableViewSelectionDidChangeNotification");
		
		
	/**
	 * Posted as an NSTableView’s selection changes (while the mouse button is still down).
	 */
	public static var NSTableViewSelectionIsChangingNotification:Number 
		= ASUtils.intern("NSTableViewSelectionIsChangingNotification");
}
