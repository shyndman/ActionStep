/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.ASUtils;
import org.actionstep.browser.ASBrowserColumn;
import org.actionstep.browser.ASBrowserTitleCell;
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSBrowserColumnResizingType;
import org.actionstep.constants.NSMatrixMode;
import org.actionstep.constants.NSScrollerPart;
import org.actionstep.NSArray;
import org.actionstep.NSBrowserCell;
import org.actionstep.NSCell;
import org.actionstep.NSColor;
import org.actionstep.NSControl;
import org.actionstep.NSEnumerator;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSMatrix;
import org.actionstep.NSPoint;
import org.actionstep.NSRange;
import org.actionstep.NSRect;
import org.actionstep.NSResponder;
import org.actionstep.NSScroller;
import org.actionstep.NSScrollView;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.ASColors;
import org.actionstep.browser.ASBrowserMatrix;

/**
 * <p>
 * NSBrowser provides a user interface for displaying and selecting items 
 * from a list of data or from hierarchically organized lists of data such as 
 * directory paths. When working with a hierarchy of data, the levels are 
 * displayed in columns, which are numbered from left to right.
 * </p>
 * <p>
 * NSBrowser uses {@link NSBrowserCell} to implement its user interface.
 * </p>
 * <p>
 * If you wish to display XML data with the browser, you can choose to use
 * the {@link org.actionstep.browser.ASXmlBrowserDelegate} class, which can
 * be used as the browser's delegate using {@link #setDelegate()}.
 * </p>
 * 
 * <h3>TODO:</h3>
 * <ul>
 * <li>
 * Implement support for delegate's browserShouldSizeColumnForUserResizeToWidth()
 * method.
 * </li>
 * <li>
 * Implement support for delegate's browserSizeToFitWidthOfColumn()
 * method.
 * </li>
 * </ul>
 * 
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSBrowser extends NSControl {
	
	//******************************************************
	//*                    Constants
	//******************************************************

	//! FIXME abstract to theme
	private static var NSBR_COLUMN_SEP:Number = 4;
	private static var NSBR_VOFFSET:Number = 2;
	private static var CELL_HEIGHT:Number = 22;
	
	//******************************************************
	//*                  Class members
	//******************************************************
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	//
	// Browser classes
	//
	private var m_cellPrototype:NSCell;
	private var m_matrixClass:Function;
	
	//
	// Columns
	//
	private var m_selectedColumn:Number;
	private var m_columns:NSArray;
	private var m_lastColumnLoaded:Number;
	private var m_firstVisibleColumn:Number;
	private var m_lastVisibleColumn:Number;
	private var m_columnResizingType:NSBrowserColumnResizingType;
	private var m_prefersAllColumnUserResizing:Boolean;
	private var m_reusesColumns:Boolean;
	private var m_maxVisibleColumns:Number;
	private var m_minColumnWidth:Number;
	private var m_separatesColumns:Boolean;
	private var m_columnSize:NSSize;
	
	//
	// Pathing
	//
	private var m_pathSeparator:String;
	
	//
	// Selection
	//
	private var m_allowsBranchSelection:Boolean;
	private var m_allowsEmptySelection:Boolean;
	private var m_allowsMultipleSelection:Boolean;
	
	//
	// Titles
	//	
	private var m_takesTitleFromPreviousColumn:Boolean;
	private var m_isTitled:Boolean;
	private var m_titleHeight:Number;
	private var m_titles:NSArray;
	
	//
	// Horizontal scroller
	//
	private var m_hasHorizontalScroller:Boolean;
	private var m_horizontalScroller:NSScroller;
	private var m_skipUpdateScroller:Boolean;
	private var m_scrollerRect:NSRect;
	
	//
	// Keyboard navigation
	//
	private var m_acceptsArrowKeys:Boolean;
	private var m_sendsActionOnArrowKeys:Boolean;
	private var m_acceptsAlphaNumericalKeys:Boolean;
	private var m_lastKeyPressed:Number;
	private var m_charBuffer:String;
	private var m_sendsActionOnAlphaNumericalKeys:Boolean;
	private var m_alphaNumericalLastColumn:Number;
	
	//
	// Target-action
	//
	private var m_action:String;
	private var m_doubleAction:String;
	
	//
	// Delegate
	//
	private var m_delegate:Object;
	private var m_passiveDelegate:Boolean;
	
	//
	// Load state
	//
	private var m_isLoaded:Boolean;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSBrowser</code> class.
	 */
	public function NSBrowser() {
	}
	
	/**
	 * Initializes a browser with the frame of <code>rect</code>.
	 */
	public function initWithFrame(rect:NSRect):NSBrowser {
		var bs:NSSize;
		var scrollerWidth:Number = ASTheme.current().scrollerWidth();
		
		// Created the shared titleCell if it hasn't been created already.
		// titleCell = [GSBrowserTitleCell new];
	
		super.initWithFrame(rect);
	
		// Class setting
		m_cellPrototype = NSCell(ASUtils.createInstanceOf(NSBrowser.cellClass())).init();
		m_matrixClass = ASBrowserMatrix;
	
		// Default values
		m_pathSeparator = "/";
		m_allowsBranchSelection = true;
		m_allowsEmptySelection = true;
		m_allowsMultipleSelection = true;
		m_reusesColumns = false;
		m_separatesColumns = true;
		m_isTitled = true;
		m_selectedColumn = -1;
		m_takesTitleFromPreviousColumn = true;
		m_titles = NSArray.array();
		m_hasHorizontalScroller = true;
		m_isLoaded = false;
		m_acceptsArrowKeys = true;
		m_acceptsAlphaNumericalKeys = false;
		m_lastKeyPressed = 0;
		m_charBuffer = null;
		m_sendsActionOnArrowKeys = true;
		m_sendsActionOnAlphaNumericalKeys = true;
		m_delegate = null;
		m_passiveDelegate = true;
		m_doubleAction = null;  
		m_columnSize = NSSize.ZeroSize;
		bs = NSBorderType.NSBezelBorder.size;
		m_minColumnWidth = scrollerWidth + (2 * bs.width);
		if (m_minColumnWidth < 100.0) {
			m_minColumnWidth = 100.0;
		}
		
		// Horizontal scroller
		m_scrollerRect = NSRect.ZeroRect;
		m_scrollerRect.size.width = m_frame.size.width - (2 * bs.width);
		m_scrollerRect.size.height = scrollerWidth;
		m_scrollerRect.origin.x = bs.width;
		m_scrollerRect.origin.y = bs.height;
		m_horizontalScroller = (new NSScroller()).initWithFrame(m_scrollerRect);
		m_horizontalScroller.setTarget(this);
		m_horizontalScroller.setAction("scrollViaScroller");
		addSubview(m_horizontalScroller);
		m_skipUpdateScroller = false;
		
		// Columns
		m_columns = NSArray.array();
		
		// Create a single column
		m_lastColumnLoaded = -1;
		m_firstVisibleColumn = 0;
		m_lastVisibleColumn = 0;
		m_maxVisibleColumns = 3;
		_createColumn();
		
		return this;
	}

	/**
	 * Releases the browser's members from memory.
	 */
	public function release():Boolean {
		m_horizontalScroller.release();
		m_columns.release();		
		return super.release();
	}
	
	//******************************************************
	//*             Describing the browser
	//******************************************************
	
	/**
	 * Returns a string representation of the NSBrowser instance.
	 */
	public function description():String {
		return "NSBrowser()";
	}
	
	//******************************************************
	//*             Setting component classes
	//******************************************************
	
	/**
	 * Always returns <code>NSBrowserCell</code> (even if the developer has 
	 * called {@link #setCellClass} on a particular instance).
	 */
	public static function cellClass():Function {
		return NSBrowserCell;
	}
	
	/**
	 * <p>Sets the class of NSCell used by the matrices in the columns of the 
	 * receiver to <code>factoryId</code>.</p>
	 * 
	 * <p>This method creates an instance of the class and calls 
	 * {@link #setCellPrototype}.</p>
	 * 
	 * @throws An exception if <code>factoryId</code> is falset a subclass of
	 * <code>NSCell</code>.
	 */
	public function setCellClass(factoryId:Function):Void {
		var cell:NSCell = NSCell(ASUtils.createInstanceOf(factoryId, null));
		
		if (cell == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"factoryId is falset a subclass of NSCell",
				null);
			trace(e);
			throw e;
		}
		
		cell.init();
		setCellPrototype(cell);
	}
	
	/**
	 * Returns the receiver’s prototype NSCell.
	 * 
	 * @see #setCellPrototype()
	 */
	public function cellPrototype():NSCell {
		return m_cellPrototype;
	}
	
	/**
	 * Sets the NSCell instance copied to display items in the matrices in the 
	 * columns of the receiver.
	 * 
	 * @see #cellPrototype()
	 */
	public function setCellPrototype(cell:NSCell):Void {
		m_cellPrototype = cell;
	}
	
	/**
	 * Returns the class of NSMatrix used in the receiver’s columns.
	 * 
	 * @see #setMatrixClass()
	 */
	public function matrixClass():Function {
		return m_matrixClass;
	}
	
	/**
	 * Sets the matrix class (NSMatrix or an NSMatrix subclass) used in the 
	 * receiver’s columns.
	 * 
	 * @throws An exception if <code>factoryId</code> is falset a subclass of
	 * <code>NSMatrix</code>.
	 */
	public function setMatrixClass(factoryId:Function):Void {
		if (!(ASUtils.createInstanceOf(factoryId, null) instanceof NSMatrix)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"factoryId is falset a subclass of NSMatrix",
				null);
			trace(e);
			throw e;
		}
		
		m_matrixClass = factoryId;
	}
	
	//******************************************************
	//*         Getting matrices, cells, and rows
	//******************************************************
	
	/**
	 * Returns the last (rightmost and lowest) selected <code>NSCell</code>.
	 */
	public function selectedCell():NSCell {
		var i:Number = selectedColumn();
		if (i == -1) {
			return null;
		}
		var matrix:NSMatrix = matrixInColumn(i);
		if (matrix == null) {
			return null;
		}
		
		return matrix.selectedCell();
	}
	
	/**
	 * Returns the last (lowest) <code>NSCell</code> selected in 
	 * <code>column</code>.
	 */
	public function selectedCellInColumn(column:Number):NSCell {
		var matrix:NSMatrix = matrixInColumn(column);
		return matrix.selectedCell();
	}
	
	/**
	 * Returns all cells selected in the rightmost column.
	 */
	public function selectedCells():NSArray {
		var i:Number = selectedColumn();
		if (i == -1) {
			return null;
		}
		var matrix:NSMatrix = matrixInColumn(i);
		if (matrix == null) {
			return null;
		}
		
		return matrix.selectedCells();
	}
	
	/**
	 * Selects all <code>NSCells</code> in the last column of the receiver.
	 */
	public function selectAll(sender:Object):Void {
		var matrix:NSMatrix = matrixInColumn(m_lastColumnLoaded);
		matrix.selectAll();
	}
	
	/**
	 * Returns the row index of the selected cell in the column specified by 
	 * index <code>column</code>.
	 */
	public function selectedRowInColumn(column:Number):Number {
		var matrix:NSMatrix = matrixInColumn(column);
		if (matrix == null) {
			return -1;
		}
		
		return matrix.selectedRow();
	}
	
	/**
	 * Selects the cell at index <code>row</code> in the column identified by 
	 * index <code>column</code>.
	 */
	public function selectRowInColumn(row:Number, column:Number):Void {
		var didSelect:Boolean;
		var matrix:NSMatrix = matrixInColumn(column);
		if (matrix == null) {
			return;
		}
		
		var cell:NSCell = matrix.cellAtRowColumn(row, 0);
		if (cell == null) {
			return;
		}
		
		setLastColumn(column);
		
		if (!m_allowsMultipleSelection) {
			matrix.deselectAllCells();
		}
		
		if (ASUtils.respondsToSelector(m_delegate,
				"browserSelectRowInColumn")) {
			didSelect = m_delegate.browserSelectRowInColumn(
				this, row, column);
		} else {
			matrix.selectCellAtRowColumn(row, 0);
			didSelect = true;
		}
		
		if (didSelect && !NSBrowserCell(cell).isLeaf())
		{
			addColumn();
		}
	}
	
	/**
	 * Loads if necessary and returns the <code>NSCell</code> at 
	 * <code>row</code> in <code>column</code>.
	 */
	public function loadedCellAtRowColumn(row:Number, column:Number):NSCell {
		var matrix:NSMatrix;
		var cell:NSBrowserCell;
		
		if ((matrix = matrixInColumn(column)) == null) {
			return null;
		}
		
		// Get the cell
		if ((cell = NSBrowserCell(matrix.cellAtRowColumn(row, 0))) == null) {
			return null;
		}
		
		// Load if falset already loaded
		if (cell.isLoaded()) {
			return cell;
		} else {
			if (m_passiveDelegate || ASUtils.respondsToSelector(m_delegate, 
					"browserWillDisplayCellAtRowColumn")) {
				m_delegate.browserWillDisplayCellAtRowColumn(this, cell, row, column);
			}
			cell.setLoaded(true);
		}
		
		return cell;
	}
	
	/**
	 * Returns the matrix located in the column identified by index 
	 * <code>column</code>.
	 */
	public function matrixInColumn(column:Number):NSMatrix {
		var bc:ASBrowserColumn;
		
		if (column < 0 || column > m_lastColumnLoaded) {
			return null;
		}
		
		bc = ASBrowserColumn(m_columns.objectAtIndex(column));
		
		if (bc == null || !bc.isLoaded()) {
			return null;
		}
		
		return bc.matrix();
	}
	
	//******************************************************
	//*             Getting and setting paths
	//******************************************************
	
	/**
	 * <p>Returns the receiver’s current path.</p>
	 * 
	 * <p>The components are separated with the string returned by 
	 * {@link #pathSeparator()}.</p>
	 * 
	 * <p>Invoking this method is equivalent to invoking 
	 * {@link #pathToColumn()} for all columns.</p>
	 * 
	 * @see #setPath()
	 */
	public function path():String {
		return pathToColumn(m_lastColumnLoaded + 1);
	}
	
	/**
	 * <p>Sets the path displayed by the receiver to <code>path</code>.</p>
	 * 
	 * <p>If path is prefixed by the path separator, the path is absolute, 
	 * containing the full path from the receiver’s first column. Otherwise, 
	 * the path is relative, extending the receiver’s current path starting at 
	 * the last column. Returns <code>true</code> if path is valid.</p>
	 * 
	 * <p>While parsing <code>path</code>, the receiver compares each component
	 * with the entries in the current column. If an exact match is found, the 
	 * matching entry is selected, and the next component is compared to the 
	 * next column’s entries. If false match is found for a component, the method 
	 * exits and returns <code>false</code>; the final path is set to the valid 
	 * portion of path. If each component of path specifies a valid branch or 
	 * leaf in the receiver’s hierarchy, the method returns <code>true</code>.</p>
	 * 
	 * @see #path()
	 * @see #pathSeparator()
	 */
	public function setPath(path:String):Boolean {
		var subStrings:NSArray;
		var numberOfSubStrings:Number;
		var indexOfSubStrings:Number;
		var column:Number;
		var useDelegate:Boolean = false;
		
		if (ASUtils.respondsToSelector(m_delegate, 
				"browserSelectCellWithStringInColumn")) {
			useDelegate = true;
		}
		
		//
		// Ensure that our starting column is loaded.
		//
		if (m_lastColumnLoaded < 0) {
			loadColumnZero();
		}
		
		//
		// Decompose the path.
		//
		subStrings = NSArray.arrayWithArray(path.split(m_pathSeparator));
		subStrings.removeObject("");
		numberOfSubStrings = subStrings.count();
		
		if (path.indexOf(m_pathSeparator) == 0) {
			var i:Number;
			
			//
			// If the path begins with a separator, start at column 0.
			// Otherwise start at the currently selected column.
			//
			column = 0;
			
			//
			// Optimisation. If there are columns loaded, it may be that the
			// specified path is already partially selected.  If this is the
			// case, we can avoid redrawing those columns.
			//
			for (i = 0; i <= m_lastColumnLoaded && i < numberOfSubStrings; i++) {
				var c:String = selectedCellInColumn(i).stringValue();
			
				if (c == subStrings.objectAtIndex(i)) {
					column = i;
				} else {
					// Actually it's always called at 0 column
					matrixInColumn(i).deselectAllCells();
					break;
				}
			}
			
			setLastColumn(column);
			indexOfSubStrings = column;
		} else {
			column = m_lastColumnLoaded;
			indexOfSubStrings = 0;
		}
		
		// cycle thru str's array created from path
		while (indexOfSubStrings < numberOfSubStrings) {
			var aStr:String = subStrings.objectAtIndex(indexOfSubStrings).toString();
			var bc:ASBrowserColumn = ASBrowserColumn(m_columns.objectAtIndex(column));
			var matrix:NSMatrix = bc.matrix();
			var selectedCell:NSBrowserCell = null;
			var found:Boolean = false;
			
			if (useDelegate) {
				if (m_delegate.browserSelectCellWithStringInColumn(this, aStr, column)) {
					found = true;
					selectedCell = NSBrowserCell(matrix.selectedCell());
				}
			} else {
				var numOfRows:Number = matrix.numberOfRows();
				var row:Number;
				
				// find the cell in the browser matrix which is equal to aStr
				for (row = 0; row < numOfRows; row++) {
					selectedCell = NSBrowserCell(matrix.cellAtRowColumn(row, 0));
					
					if (selectedCell.stringValue() == aStr) {
						matrix.selectCellAtRowColumn(row, 0);
						found = true;
						break;
					}
				}
			}
			
			if (found) {
				indexOfSubStrings++;
			} else {
				// if unable to find a cell whose title matches aStr return NO
				asWarning("NSBrowser unable to find cell " + aStr + " in "
					+ "column " + column);
				break;
			}
			
			// if the cell is a leaf, we are finished setting the path
			if (selectedCell.isLeaf()) {
				break;
			}
			
			// else, it is not a leaf: get a column in the browser for it
			addColumn();
			column++;
		}
		
		if (indexOfSubStrings == numberOfSubStrings) {
			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * <p>Returns a string representing the path from the first column up to, but 
	 * not including, the column at index <code>column</code>.</p>
	 * 
	 * <p>The components are separated with the string returned by 
	 * {@link #pathSeparator()}.</p>
	 * 
	 * @see #path()
	 * @see #setPath()
	 */
	public function pathToColumn(column:Number):String {
		var s:String = m_pathSeparator;
		var string:String;
		var i:Number;
		
		/*
		* Cannot go past the number of loaded columns
		*/
		if (column > m_lastColumnLoaded) {
			column = m_lastColumnLoaded + 1;
		}
		
		for (i = 0; i < column; ++i) {
			var c:NSCell = selectedCellInColumn(i);
		
			if (i != 0) {
				s += m_pathSeparator;
			}
			
			string = c.stringValue();
			
			if (string == null) {
				/* This should happen only when c == nil, in which case it
				doesn't make sense to go with the path */
				break;
			} else {
				s += string;	  
			}
		}
				
		return s;
	}
	
	/**
	 * <p>Returns the path separator.</p>
	 * 
	 * <p>The default is "/".</p>
	 * 
	 * @see #setPathSeparator()
	 */
	public function pathSeparator():String {
		return m_pathSeparator;
	}
	
	/**
	 * Sets the path separator to <code>newString</code>.
	 * 
	 * @see #pathSeparator()
	 */
	public function setPathSeparator(newString:String):Void {
		m_pathSeparator = newString;
	}
	
	//******************************************************
	//*              Manipulating columns
	//******************************************************
	
	/**
	 * Creates an empty column.
	 */
	private function _createColumn():ASBrowserColumn {
		var bc:ASBrowserColumn;
		var sc:NSScrollView;
		var rect:NSRect = new NSRect(-110, -110, 100, 100);
		
		bc = (new ASBrowserColumn()).init();
				
		// Create a scrollview
		sc = (new NSScrollView()).initWithFrame(rect);
		sc.setHasHorizontalScroller(false);
		sc.setHasVerticalScroller(true);
		sc.setDrawsBackground(true);

		if (m_separatesColumns) {
			sc.setBorderType(NSBorderType.NSBezelBorder);
		} else {
			sc.setBorderType(NSBorderType.NSNoBorder);
		}
		
		bc.setScrollView(sc);
		this.addSubview(sc);
		m_columns.addObject(bc);
		
		return bc;
	}
	
	/**
	 * Adds a column to the right of the last column.
	 * 
	 * @see #columnOfMatrix()
	 * @see #displayColumn()
	 * @see #selectedColumn()
	 */
	public function addColumn():Void {
		var i:Number;
		
		if (m_lastColumnLoaded + 1 >= m_columns.count()) {
			i = m_columns.indexOfObject(_createColumn());
		} else {
			i = m_lastColumnLoaded + 1;
		}
		
		if (i < 0) {
			i = 0;
		}
		
		_performLoadOfColumn(i);
		setLastColumn(i);
		
		setLoaded(true);
		tile();
		
		if (i > 0 && i - 1 == m_lastVisibleColumn) {
			scrollColumnsRightBy(1);
		}
	}
	
	/**
	 * Updates the receiver to display all loaded columns.
	 */
	public function displayAllColumns():Void {
		tile();
	}
	
	/**
	 * Updates the receiver to display the column with the index 
	 * <code>column</code>.
	 */
	public function displayColumn(column:Number):Void {
		var bc:ASBrowserColumn;
		var sc:NSScrollView;
		
		//
		// If falset visible than falsething to display
		//
		if (column < m_firstVisibleColumn || column > m_lastVisibleColumn) {
			return;
		}
		
		tile();
		
		//
		// Display column title
		//
		if (m_isTitled) {
			drawTitleOfColumnInRect(column, titleFrameOfColumn(column));
		}
		
		//
		// Display column
		//
		if ((bc = ASBrowserColumn(m_columns.objectAtIndex(column))) == null) {
			return;
		}
		if ((sc = bc.scrollView()) == null) {
			return;
		}
		
		sc.setNeedsDisplay(true);
	}
	
	/**
	 * Returns the column number in which <code>matrix</code> is located.
	 */
	public function columnOfMatrix(matrix:NSMatrix):Number {
		var count:Number = m_columns.count();
		
		for (var i:Number = 0; i < count; i++) {
			if (matrix == matrixInColumn(i)) {
				return i;
			}
		}
		
		return -1;	
	}
	
	/**
	 * <code>Returns the index of the last column with a selected item.</code>
	 */
	public function selectedColumn():Number {
		return m_selectedColumn;
	}
	
	/**
	 * Returns the index of the last column loaded.
	 */
	public function lastColumn():Number {
		return m_lastColumnLoaded;
	}
	
	/**
	 * Sets the last column to <code>column</code>.
	 */
	public function setLastColumn(column:Number):Void {
		var bc:ASBrowserColumn;
		var sc:NSScrollView;

		if (column > m_lastColumnLoaded) {
			return;
		}

		if (column < 0) {
			column = -1;
			setLoaded(false);
		}

		m_lastColumnLoaded = column;

		//
		// Unloads columns.
		//
		var count:Number = m_columns.count();
		var num:Number = numberOfVisibleColumns();

		for (var i:Number = column + 1; i < count; ++i) {
			bc = ASBrowserColumn(m_columns.objectAtIndex(i));
			sc = bc.scrollView();

			if (bc.isLoaded()) {
				// Make the column appear empty by removing the matrix
				if (sc != null) {
					sc.setDocumentView(null);
				}

				bc.setLoaded(false);
				setTitleOfColumn(null, i);
			}

			if (!m_reusesColumns && i > m_lastVisibleColumn) {
				sc.removeFromSuperview();
				m_columns.removeObject(bc);
				count--;
				i--;
			}
		}

		scrollColumnToVisible(column);
	}

	/**
	 * Returns the index of the first visible column.
	 */
	public function firstVisibleColumn():Number {
		return m_firstVisibleColumn;
	}
	
	/**
	 * Returns the number of columns visible.
	 */
	public function numberOfVisibleColumns():Number {
		var num:Number = m_lastVisibleColumn - m_firstVisibleColumn + 1;
		return (num > 0) ? num : 1;
	}
	
	/**
	 * Returns the index of the last visible column.
	 */
	public function lastVisibleColumn():Number {
		return m_lastVisibleColumn;
	}
	
	/**
	 * Invokes delegate method 
	 * {@link org.actionstep.browser.ASBrowserDelegate#browserIsColumnValid()} 
	 * for visible columns.
	 */
	public function validateVisibleColumns():Void {
		if (!ASUtils.respondsToSelector(m_delegate, "browserIsColumnValid")) {
			return;
		}
		
		// Loop through the visible columns
		for (var i:Number = m_firstVisibleColumn; i <= m_lastVisibleColumn; ++i) {
			// Ask delegate if the column is valid and if falset
			// then reload the column
			if (!m_delegate.browserIsColumnValid(this, i)) {
				reloadColumn(i);
			}
    	}
	}
	
	//******************************************************
	//*                 Loading columns
	//******************************************************
	
	/**
	 * Returns whether column 0 is loaded.
	 */
	public function isLoaded():Boolean {
		return m_isLoaded;
	}
	
	/**
	 * <p>Sets whether column 0 is loaded.</p>
	 * 
	 * <p>This is used internally to allow databinding to the {@link #isLoaded}
	 * property.</p>
	 */
	private function setLoaded(flag:Boolean):Void {
		m_isLoaded = flag;
	}
	
	/**
	 * Loads column 0; unloads previously loaded columns.
	 */
	public function loadColumnZero():Void {
		// set last column loaded
		setLastColumn(-1);
		
		// load column 0
		addColumn();
		
		_remapColumnSubviews(true);
		_setColumnTitlesNeedDisplay();
	}
	
	/**
	 * Reloads <code>column</code> if it exists and sets it to be the last 
	 * column.
	 */
	public function reloadColumn(column:Number):Void {
		var matrix:NSMatrix = matrixInColumn(column);
		if (matrix == null) {
			return;
		}
    
		// Get the previously selected cells
		var selectedCells:NSArray = matrix.selectedCells();
		
		// Perform the data load
		_performLoadOfColumn(column);
		// set last column loaded
		setLastColumn(column);
		
		// Restore the selected cells
		matrix = matrixInColumn(column);
		var cell:NSCell;
		var it:NSEnumerator = selectedCells.objectEnumerator();
		while ((cell = NSCell(it.nextObject())) != null) {
			var loc:Object = matrix.getRowColumnOfCell(cell);
			if (loc != null) {
				matrix.selectCellAtRowColumn(loc.row, loc.column);
			}
		}	
	}
	
	//******************************************************
	//*          Setting selection characteristics
	//******************************************************
	
	/**
	 * Returns whether the user can select branch items when multiple 
	 * selection is enabled.
	 */
	public function allowsBranchSelection():Boolean {
		return m_allowsBranchSelection;
	}
	
	/**
	 * Sets whether the user can select branch items when multiple selection is 
	 * enabled, depending on the Boolean value passed in the 
	 * <code>flag</code>.
	 */
	public function setAllowsBranchSelection(flag:Boolean):Void {
		m_allowsBranchSelection = flag;
	}
	
	/**
	 * Returns whether there can be falsething selected.
	 */
	public function allowsEmptySelection():Boolean {
		return m_allowsEmptySelection;
	}
	
	/**
	 * Sets whether there can be falsething selected, depending on the Boolean 
	 * value passed in the <code>flag</code>.
	 */
	public function setAllowsEmptySelection(flag:Boolean):Void {
		m_allowsEmptySelection = flag;
	}
	
	/**
	 * Returns whether the user can select multiple items.
	 */
	public function allowsMultipleSelection():Boolean {
		return m_allowsMultipleSelection;
	}
	
	/**
	 * Sets whether the user can select multiple items, depending on the 
	 * Boolean value passed in the <code>flag</code>.
	 */
	public function setAllowsMultipleSelection(flag:Boolean):Void {
		m_allowsMultipleSelection = flag;
	}
	
	//******************************************************
	//*           Setting column characteristics
	//******************************************************
	
	/**
	 * Returns <code>true</code> if NSMatrix objects aren’t freed when their 
	 * columns are unloaded.
	 */
	public function reusesColumns():Boolean {
		return m_reusesColumns;
	}
	
	/**
	 * If <code>flag</code> is <code>true</code>, prevents NSMatrix objects from 
	 * being freed when their columns are unloaded, so they can be reused.
	 */
	public function setReusesColumns(flag:Boolean):Void {
		m_reusesColumns = flag;
	}
	
	/**
	 * Returns the maximum number of visible columns.
	 */
	public function maxVisibleColumns():Number {
		return m_maxVisibleColumns;
	}
	
	/**
	 * Sets the maximum number of columns displayed to <code>columnCount</code>.
	 */
	public function setMaxVisibleColumns(columnCount:Number):Void {
		if ((columnCount < 1) || (m_maxVisibleColumns == columnCount)) {
			return;
		}
		
		m_maxVisibleColumns = columnCount;
		
		// Redisplay
		tile();
	}
	
	/**
	 * Returns the minimum column width in pixels.
	 */
	public function minColumnWidth():Number {
		return m_minColumnWidth;
	}
	
	/**
	 * Sets the minimum column width to <code>columnWidth</code>, specified in 
	 * pixels.
	 */
	public function setMinColumnWidth(columnWidth:Number):Void {
		var sw:Number = ASTheme.current().scrollerWidth();
		
		// Take the border into account
		if (m_separatesColumns) {
			sw += 2 * NSBorderType.NSBezelBorder.size.width;
		}
		
		// Column width canfalset be less than scroller and border
		if (columnWidth < sw) {
			m_minColumnWidth = sw;
		} else {
			m_minColumnWidth = columnWidth;
		}
		
		tile();
	}
	
	/**
	 * Returns whether columns are separated by bezeled borders.
	 */
	public function separatesColumns():Boolean {
		return m_separatesColumns;
	}
	
	/**
	 * <p>Sets whether to separate columns with bezeled borders, depending on 
	 * the Boolean value <code>flag</code>.</p>
	 * 
	 * <p>This value is igfalsered if {@link #isTitled()} does falset return 
	 * <code>false</code>.</p>
	 */
	public function setSeparatesColumns(flag:Boolean):Void {
		// if this flag already set or browser is titled -- do falsething
		if (m_separatesColumns == flag || m_isTitled) {
			return;
		}
		
		var columnCount:Number = m_columns.count();
		var bt:NSBorderType = flag ? NSBorderType.NSBezelBorder 
			: NSBorderType.NSNoBorder;
			
		for (var i:Number = 0; i < columnCount; i++) {
			var bc:ASBrowserColumn = ASBrowserColumn(m_columns.objectAtIndex(i));
			var sc:NSScrollView = bc.scrollView();
			sc.setBorderType(bt);
		}
		
		m_separatesColumns = flag;
		setNeedsDisplay(true);;
		tile();
	}
	
	/**
	 * Returns <code>true</code> if the title of a column is set to the string 
	 * value of the selected NSCell in the previous column.
	 */
	public function takesTitleFromPreviousColumn():Boolean {
		return m_takesTitleFromPreviousColumn;
	}
	
	/**
	 * Sets whether the title of a column is set to the string value of the 
	 * selected NSCell in the previous column, depending on the Boolean 
	 * value <code>flag</code>.
	 */
	public function setTakesTitleFromPreviousColumn(flag:Boolean):Void {
		if (flag != m_takesTitleFromPreviousColumn) {
			m_takesTitleFromPreviousColumn = flag;
			setNeedsDisplay(true);
		}
	}
	
	//******************************************************
	//*             Manipulating column titles
	//******************************************************
	
	/**
	 * Returns the title displayed for the column at index column.
	 */
	public function titleOfColumn(column:Number):String {
		return ASBrowserColumn(m_columns.objectAtIndex(column)).title();
	}
	
	/**
	 * Sets the title of the column at index <code>column</code> to 
	 * <code>aString</code>.
	 */
	public function setTitleOfColumn(aString:String, column:Number):Void {
		var bc:ASBrowserColumn = ASBrowserColumn(m_columns.objectAtIndex(column));
		bc.setTitle(aString);
		
		if (!m_isTitled 
				&& (column >= m_firstVisibleColumn)
				&& (column <= m_lastVisibleColumn)) {
			return;
		}
		
		setNeedsDisplay(true);
	}
	
	/**
	 * Returns whether columns display titles.
	 */
	public function isTitled():Boolean {
		return m_isTitled;
	}
	
	/**
	 * Sets whether columns display titles, depending on the Boolean value 
	 * <code>flag</code>.
	 */
	public function setTitled(flag:Boolean):Void {
		if (m_isTitled == flag || !m_separatesColumns) {
			return;
		}
		
		m_isTitled = flag;
		tile();
		setNeedsDisplay(true);
	}
	
	/**
	 * Draws the title for the column at index <code>column</code> within the 
	 * rectangle defined by <code>aRect</code>.
	 */
	public function drawTitleOfColumnInRect(column:Number, aRect:NSRect):Void {
		var cell:ASBrowserTitleCell = ASBrowserTitleCell(
			m_titles.objectAtIndex(column - m_firstVisibleColumn));
		var str:String = titleOfColumn(column);
		if (str == null) {
			str = "";
		}
		cell.setStringValue(str);
		cell.drawWithFrameInView(aRect, this);
	}
	
	/**
	 * Returns the height of column titles.
	 */
	public function titleHeight():Number {
		// Nextish look requires 21 here
		// FIXME move to theme
		return 21;
	}
	
	/**
	 * Returns the bounds of the title frame for the column at index 
	 * <code>column</code>.
	 */
	public function titleFrameOfColumn(column:Number):NSRect {
		// falset titled then false frame
		if (!m_isTitled) {
			return NSRect.ZeroRect;
		} else {
			// Number of columns over from the first
			var n:Number = column - m_firstVisibleColumn;
			var h:Number = titleHeight();
			var r:NSRect = NSRect.ZeroRect;
		
			// Calculate origin
			if (m_separatesColumns) {
				r.origin.x = n * (m_columnSize.width + NSBR_COLUMN_SEP);
			} else {
				r.origin.x = n * m_columnSize.width;
			}
			
			r.origin.y = NSBR_VOFFSET;
			
			// Calculate size
			if (column == m_lastVisibleColumn) {
				r.size.width = m_frame.size.width - r.origin.x;
			} else {
				r.size.width = m_columnSize.width;
			}
			
			r.size.height = h;
			
			return r;
		}
	}
	
	//******************************************************
	//*               Scrolling an NSBrowser
	//******************************************************
	
	/**
	 * Scrolls to make the column at index <code>column</code> visible.
	 */
	public function scrollColumnToVisible(column:Number):Void {
		// If its the last visible column then we are there already
		if (m_lastVisibleColumn < column) {
			scrollColumnsRightBy(column - m_lastVisibleColumn);
		} 
		else if (m_firstVisibleColumn > column) {
			scrollColumnsLeftBy(m_firstVisibleColumn - column);
		} 	
	}
	
	/**
	 * Scrolls columns left by <code>shiftAmount</code> columns.
	 */
	public function scrollColumnsLeftBy(shiftAmount:Number):Void {
		// Canfalset shift past the zero column
		if ((m_firstVisibleColumn - shiftAmount) < 0) {
			shiftAmount = m_firstVisibleColumn;
		}
		
		// false amount to shift then falsething to do
		if (shiftAmount <= 0) {
			return;
		}
		
		// falsetify the delegate
		if (ASUtils.respondsToSelector(m_delegate, "browserWillScroll")) {
			m_delegate.browserWillScroll(this);
		}
		
		// Shift
		m_firstVisibleColumn = m_firstVisibleColumn - shiftAmount;
		m_lastVisibleColumn = m_lastVisibleColumn - shiftAmount;
		
		// Update the scroller
		updateScroller();
		
		// Update the scrollviews
		tile();
		_remapColumnSubviews(true);
		_setColumnTitlesNeedDisplay();
		
		// falsetify the delegate
		if (ASUtils.respondsToSelector(m_delegate, "browserDidScroll")) {
			m_delegate.browserDidScroll(this);
		}  
	}
	
	/** Scrolls columns right by shiftAmount columns. */
	public function scrollColumnsRightBy(shiftAmount:Number) {
		// Canfalset shift past the last loaded column
		if ((shiftAmount + m_lastVisibleColumn) > m_lastColumnLoaded) {
			shiftAmount = m_lastColumnLoaded - m_lastVisibleColumn;
		}
	
		// false amount to shift then falsething to do
		if (shiftAmount <= 0) {
			return;
		}
	
		// falsetify the delegate
		if (ASUtils.respondsToSelector(m_delegate, "browserWillScroll")) {
			m_delegate.browserWillScroll(this);
		}
		
		// Shift
		m_firstVisibleColumn = m_firstVisibleColumn + shiftAmount;
		m_lastVisibleColumn = m_lastVisibleColumn + shiftAmount;
		
		// Update the scroller
		updateScroller();
		
		// Update the scrollviews
		tile();
		_remapColumnSubviews(true);
		_setColumnTitlesNeedDisplay();
		
		// falsetify the delegate
		if (ASUtils.respondsToSelector(m_delegate, "browserDidScroll")) {
			m_delegate.browserDidScroll(this);
		}  
	}
	
	/** Updates the horizontal scroller to reflect column positions. */
	public function updateScroller() {
		var num:Number = numberOfVisibleColumns();
		var prop:Number = num / (m_lastColumnLoaded + 1);
		var uc:Number = (m_lastColumnLoaded + 1) - num; // Unvisible columns
		var f_step:Number = 1;
		var fv:Number = 0;
	
		if (uc > 0.0) {
			f_step = 1.0 / uc;
		}
		
		fv = m_firstVisibleColumn * f_step;
	
		if (m_lastVisibleColumn > m_lastColumnLoaded) {
			prop = num / (m_lastVisibleColumn + 1);
		}
	
		m_horizontalScroller.setFloatValueKnobProportion(fv, prop);
	}
	
	/** Scrolls columns left or right based on an NSScroller. */
	public function scrollViaScroller(sender:NSScroller) {
		var hit:NSScrollerPart = sender.hitPart();
			
		switch (hit) {
			// Scroll to the left
			case NSScrollerPart.NSScrollerDecrementLine:
			case NSScrollerPart.NSScrollerDecrementPage:
				scrollColumnsLeftBy(1);
				break;
	
			// Scroll to the right
			case NSScrollerPart.NSScrollerIncrementLine:
			case NSScrollerPart.NSScrollerIncrementPage:
				scrollColumnsRightBy(1);
				break;
	
			// The kfalseb or kfalseb slot
			case NSScrollerPart.NSScrollerKnob:
			case NSScrollerPart.NSScrollerKnobSlot:
				var f:Number = sender.floatValue();
				scrollColumnToVisible(Math.floor(f * m_lastColumnLoaded));
				break;
	
			// NSScrollerfalsePart ???
			default:
				break;
		}
	}
	
	//******************************************************
	//*           Showing a horizontal scroller
	//******************************************************

	/** Returns whether an NSScroller is used to scroll horizontally. */
	public function hasHorizontalScroller():Boolean {
	  return m_hasHorizontalScroller;
	}

	/** Sets whether an NSScroller is used to scroll horizontally. */
	public function setHasHorizontalScroller(flag:Boolean):Void {
		if (m_hasHorizontalScroller != flag) {
			m_hasHorizontalScroller = flag;
			
			if (!flag) {
      			m_horizontalScroller.removeFromSuperview();
			} else {
				addSubview(m_horizontalScroller);
			}
			
			tile();
			setNeedsDisplay(true);
		}
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
	//*               Getting column frames
	//******************************************************
	
	/** Returns the rectangle containing the column at index column. */
	public function frameOfColumn(column:Number):NSRect {
		var r:NSRect = NSRect.ZeroRect;
		var bs:NSSize = NSBorderType.NSBezelBorder.size.clone();
		var n:Number;
		var scrollerWidth:Number = ASTheme.current().scrollerWidth();
		
		// Number of columns over from the first
		n = column - m_firstVisibleColumn;
	
		// Calculate the frame
		r.size = m_columnSize.clone();
		r.origin.x = n * m_columnSize.width;
		r.origin.y = bs.width;
		
		if (m_isTitled) {
			r.origin.y += titleHeight();
		}
		
		if (m_separatesColumns) {
			r.origin.x += n * NSBR_COLUMN_SEP;
		} else {
			if (column == m_firstVisibleColumn) {
				r.origin.x = (n * m_columnSize.width) + 2;
			} else {
				r.origin.x = (n * m_columnSize.width) + (n + 2);
			}
		}
		
		// Padding : _columnSize.width is rounded in "tile" method
		if (column == m_lastVisibleColumn) {
			if (m_separatesColumns) {
				r.size.width = m_frame.size.width - r.origin.x;
			} else {
				r.size.width = m_frame.size.width - (r.origin.x + bs.width);
			}
		}
		
		if (r.size.width < 0) {
			r.size.width = 0;
		}
		if (r.size.height < 0) {
			r.size.height = 0;
		}
		
		return r;
	}
	
	/**
	 * Returns the rectangle containing the column at index <code>column</code>.
	 */
	public function frameOfInsideOfColumn(column:Number):NSRect {
		return frameOfColumn(column);
	}

	//******************************************************
	//*            Arranging browser components
	//******************************************************
	
	/**
	 * Adjusts the various subviews of NSBrowser-scrollers, columns, titles, and 
	 * so on-without redrawing. Your code shouldn't send this message.  It's 
	 * invoked any time the appearance of the NSBrowser changes.
	 */
	public function tile():Void {
		var columnCount:Number, delta:Number, frameWidth:Number;
		var bs:NSSize = NSBorderType.NSBezelBorder.size.clone();
		var scrollerWidth:Number = ASTheme.current().scrollerWidth();
		m_columnSize.height = m_frame.size.height;
		
		//
		// Titles (there is false real frames to resize)
		//
		if (m_isTitled) {
			m_columnSize.height -= titleHeight() + NSBR_VOFFSET;
		}
		
		//
		// Size the horizontal scroller
		//
		if (m_hasHorizontalScroller) {
			m_scrollerRect.origin.x = bs.width;
			m_scrollerRect.origin.y = m_frame.size.height - bs.height - scrollerWidth;
			m_scrollerRect.size.width = m_frame.size.width - (2 * bs.width);
			m_scrollerRect.size.height = scrollerWidth;
     		
			if (m_separatesColumns) {
				m_columnSize.height -= (scrollerWidth - 1) + (2 * bs.height) 
					+ NSBR_VOFFSET;
			} else {
				m_columnSize.height -= scrollerWidth + (2 * bs.height);
			}
		
			if (!m_scrollerRect.isEqual(m_horizontalScroller.frame())) {
				m_horizontalScroller.setFrame(m_scrollerRect);
			}
		} else {
			m_scrollerRect = NSRect.ZeroRect;
			m_columnSize.height -= 2 * bs.width;
		}
		
		//
		// Determine the number of columns to display
		//
		var num:Number = m_lastVisibleColumn - m_firstVisibleColumn + 1;
		
		if (m_minColumnWidth > 0) {
			var colWidth:Number = m_minColumnWidth + scrollerWidth;
					
			if (m_separatesColumns) {
				colWidth += NSBR_COLUMN_SEP;
			}
		
			if (m_frame.size.width > colWidth) {
				columnCount = Math.floor(m_frame.size.width / colWidth);
			} else {
				columnCount = 1;
			}
		} else {
			columnCount = num;
		}
		
		//
		// Limit at max visible columns
		//
		if (m_maxVisibleColumns > 0 && columnCount > m_maxVisibleColumns) {
			columnCount = m_maxVisibleColumns;
		}
		
		if (columnCount != num) {
			if (num > 0) {
				delta = columnCount - num;
			} else {
				delta = columnCount - 1;
			}
		
			if ((delta > 0) && (m_lastVisibleColumn <= m_lastColumnLoaded)) {
				m_firstVisibleColumn = (m_firstVisibleColumn - delta > 0) ?
					m_firstVisibleColumn - delta : 0;
			}
		
			for (var i:Number = m_columns.count(); i < columnCount; i++) {
				_createColumn();
			}
			
			m_lastVisibleColumn = m_firstVisibleColumn + columnCount - 1;
		}
		
		//
		// Adjust frame width if we separate columns
		//
		if (m_separatesColumns) {
			frameWidth = m_frame.size.width - ((columnCount - 1) * NSBR_COLUMN_SEP);
		} else {
			frameWidth = m_frame.size.width - ((columnCount - 1) + (2 * bs.width));
		}
		
		m_columnSize.width = Math.floor(frameWidth / columnCount);
		
		if (m_columnSize.height < 0) {
			m_columnSize.height = 0;
		}
		
		//
		// Position the columns
		//		
		var arr:Array = m_columns.internalList();
		var len:Number = arr.length;
		for (var i:Number = m_firstVisibleColumn; i <= m_lastVisibleColumn; i++) {
			var bc:ASBrowserColumn;
			var sc:NSScrollView;
			var matrix:NSMatrix;
		
			// FIXME: in some cases the column is falset loaded
			while (i >= len) {
				_createColumn();
			}
			
			bc = ASBrowserColumn(arr[i]);
		
			if (null == (sc = bc.scrollView())) {
				asWarning("NSBrowser error, sc != [bc columnScrollView]");
				return;
			}
		
			sc.setFrame(frameOfColumn(i));
			matrix = bc.matrix();
		
			// Adjust matrix to fit in scrollview if column has been loaded
			if (matrix && bc.isLoaded()) {
				var cs:NSSize, ms:NSSize;
			
				cs = sc.contentSize();
				ms = matrix.cellSize();
				ms.width = cs.width;
				matrix.setCellSize(ms);
				cs.height = matrix.numberOfRows() * CELL_HEIGHT;
				matrix.setFrameSize(cs);
				sc.setDocumentView(matrix);
				
				matrix.setNeedsDisplay(true);
			}
		}
		
		if (columnCount != num) {
			updateScroller();
			_remapColumnSubviews(true);
			setNeedsDisplay(true);
		}
	}
	
	/**
	 * Override from NSControl. Don't do anything to change the size of the 
	 * browser.
	 */
	public function sizeToFit():Void {
	}
	
	//******************************************************
	//*               Setting the delegate
	//******************************************************
	
	/** Returns the NSBrowser's delegate. */
	public function delegate():Object {
		return m_delegate;
	}
	
	/**
	 * <p>Sets the delegate of the receiver.</p>
	 * 
	 * <p>If <code>null</code>, the delegate must either be passive and 
	 * respond to {@link ASBrowserDelegate#browserNumberOfRowsInColumn()} or be active 
	 * and respond to {@link ASBrowserDelegate#browserCreateRowsForColumnInMatrix()}.</p>
	 * 
	 * <p>If the delegate is active it must also respond to
	 * {@link ASBrowserDelegate#browserWillDisplayCellAtRowColumn()}.</p>
	 * 
	 * <p>If the delegate is <code>null</code>, but does falset meet these 
	 * conditions, an {@link NSException} will be raised.</p>
	 */
	public function setDelegate(anObject:Object):Void {
		var flag:Boolean = false;
	
		// Default to true for nil delegate.
		m_passiveDelegate = true;
	
		if (ASUtils.respondsToSelector(anObject, "browserNumberOfRowsInColumn")) {
			flag = true;
			
			if (!ASUtils.respondsToSelector(anObject, "browserWillDisplayCellAtRowColumn")) {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSBrowserIllegalDelegate,
					"Delegate does falset respond to browserNumberOfRowsInColumn",
					null);
				trace(e);
				throw e;
			}
		}
		
		if (ASUtils.respondsToSelector(anObject, "browserCreateRowsForColumnInMatrix")) {
			m_passiveDelegate = false;
		
			//
			// If flag is already set then the delegate must respond to both 
			// methods
			//
			if (flag) {
				var e:NSException = NSException.exceptionWithNameReasonUserInfo(
					NSException.NSBrowserIllegalDelegate,
					"Delegate responds to both browserNumberOfRowsInColumn "
					+ "and browserCreateRowsForColumnInMatrix",
					null);
				trace(e);
				throw e;
			}
		
			flag = true;
		}
		
		if (!flag && anObject != null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSBrowserIllegalDelegate,
				"Delegate does falset respond to browserNumberOfRowsInColumn "
				+ "or browserCreateRowsForColumnInMatrix",
				null);
			trace(e);
			throw e;
		}
		
		m_delegate = anObject;
	}
	
	//******************************************************
	//*                Target and action
	//******************************************************
	
	/**
	 * Returns the target for this browser's actions.
	 * 
	 * @see #setTarget()
	 * @see #action()
	 * @see #doubleAction()
	 */
	public function target():Object {
		return m_target;
	}
	
	/**
	 * Sets the target of this browser's actions to <code>anObject</code>.
	 * 
	 * @see #setTarget()
	 * @see #action()
	 * @see #doubleAction()
	 */
	public function setTarget(anObject:Object):Void {
		m_target = anObject;
	}
	
	/**
	 * Returns the browser's action.
	 * 
	 * @see #setAction()
	 * @see doubleAction()
	 */
	public function action():String {
		return m_action;
	}
	
	/**
	 * Sets the browser's action to <code>aSelector</code>.
	 */
	public function setAction(aSelector:String):Void {
		m_action = aSelector;
	}
	
	/**
	 * Returns the NSBrowser's double-click action method.
	 * 
	 * @see #setDoubleAction()
	 * @see #action()
	 */
	public function doubleAction():String {
		return m_doubleAction;
	}
	
	/**
	 * Sets the NSBrowser's double-click action to <code>aSelector</code>.
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
	//*                  Event handling
	//******************************************************
	
	/**
	 * Responds to (single) mouse clicks in a column of the receiver.
	 * 
	 * @see #sendAction()
	 */
	public function doClick(sender:Object):Void {
		var a:NSArray;
		var selectedCells:NSArray;
		var enumerator:NSEnumerator;
		var cell:NSBrowserCell;
		var column:Number, aCount:Number, selectedCellsCount:Number;
		var m:NSMatrix = NSMatrix(sender);
				
		if (m == null) {
			return;
		}
					
		column = columnOfMatrix(m);
		
		// If the matrix isn't ours then just return
		if (column < 0 || column > m_lastColumnLoaded) {
			return;
		}
		
		m_selectedColumn = column;
		
		//
		// Handle selection
		//
		m_window.makeFirstResponder(m);
				
		a = m.selectedCells();
		aCount = a.count();
		if (aCount == 0) {
			return;
		}
		
		selectedCells = (new NSArray()).initWithArrayCopyItems(a, false);
		enumerator = a.objectEnumerator();
		
		while (null != (cell = NSBrowserCell(enumerator.nextObject()))) {
			if (!m_allowsBranchSelection && !cell.isLeaf()) {
				selectedCells.removeObject(cell);
			}
		}
		
		if (selectedCells.count() == 0 && m.selectedCells() != null) {
			selectedCells.addObject(m.selectedCell());
		}

		selectedCellsCount = selectedCells.count();
		
		//
		// Select cells that should be selected
		//
		if (selectedCellsCount > 0) {
			enumerator = selectedCells.objectEnumerator();
			while (null != (cell = NSBrowserCell(enumerator.nextObject()))) {
				m.selectCell(cell);
			}
		}
			
		setLastColumn(column);
		
		//
		// Single selection
		//
		if (selectedCellsCount == 1) {
			cell = NSBrowserCell(selectedCells.objectAtIndex(0));
			
			// If the cell is not a leaf we need to load a column
			if (!cell.isLeaf()) {
				addColumn();
			}
			
			m.scrollCellToVisibleAtRowColumn(m.selectedRow(), 0);
		}
		
		updateScroller();
		
		//
		// Send the action to target
		//
		sendAction();
	}
	
	/**
	 * Responds to double clicks in a column of the receiver.
	 * 
	 * @see #setDoubleAction()
	 */
	public function doDoubleClick(sender:Object):Void {
		sendActionTo(doubleAction(), target());
	}
	
	//******************************************************
	//*             Event handling overrides
	//******************************************************
	
	/** Overridden to do nothing. */
	public function mouseDown(theEvent:NSEvent):Void {
	}
	
	/**
	 * Moves selection left.
	 */
	public function moveLeft(sender:Object):Void {
		if (!m_acceptsArrowKeys) {
			return;
		}
		
		var matrix:NSMatrix;
		var selCol:Number;
		
		matrix = NSMatrix(m_window.firstResponder());
		selCol = columnOfMatrix(matrix);
		
		if (selCol == -1) {
			selCol = this.selectedColumn();
			matrix = matrixInColumn(selCol);
		}
		if (selCol > 0) {
			matrix.deselectAllCells();
			matrix.scrollCellToVisibleAtRowColumn(0, 0);
			setLastColumn(selCol);
			
			var prevMatrix:NSMatrix = matrixInColumn(selCol - 1);
			m_window.makeFirstResponder(prevMatrix);
			scrollColumnToVisible(selCol - 1);
		
			m_selectedColumn = selCol - 1;
			
			if (m_sendsActionOnArrowKeys) {
				sendActionTo(action(), target());
			}
		}
		
		
	}
	
	/**
	 * Moves the selection right.
	 */
	public function moveRight(sender:Object):Void {
		if (!m_acceptsArrowKeys) {
			return;
		}
		
		var matrix:NSMatrix;
		var selCol:Number;
		
		matrix = NSMatrix(m_window.firstResponder());
		selCol = columnOfMatrix(matrix);
		if (selCol == -1) {
			selCol = selectedColumn();
			matrix = matrixInColumn(selCol);
		}
		if (selCol == -1) {
			selCol = 0;
			matrix = matrixInColumn(0);
			
			if (matrix.cells().count() != 0) {
				matrix.selectCellAtRowColumn(0, 0);
			}
		} else {
			//
			// if there is one selected cell and it is a leaf, move right
			// (column is already loaded)
			//
			if (!NSBrowserCell(matrix.selectedCell()).isLeaf()
					&& matrix.selectedCells().count() == 1) {
				selCol++;
				matrix = matrixInColumn(selCol);
				
				if (matrix.cells().count() > 0 && matrix.selectedCell() == null) {
					matrix.selectCellAtRowColumn(0, 0);
				}
				
				//
				// if selected cell is a branch, we need to add a column
				//
				if (!NSBrowserCell(matrix.selectedCell()).isLeaf()
						&& matrix.selectedCells().count() == 1) {  
					addColumn();
				}
			}
		}
		
		m_selectedColumn = selCol;
		m_window.makeFirstResponder(matrix);
		
		if (m_sendsActionOnArrowKeys) {
			sendActionTo(action(), target());
		}
	}
	
	/**
	 * Responds to keyboard presses when the browser has focus.
	 */
	public function keyDown(theEvent:NSEvent):Void {
		
		var characters:String = theEvent.characters;
		var character:Number = theEvent.keyCode;
		
		//
		// Deal with arrow keys
		//		
		if (m_acceptsArrowKeys) {
			switch (character) {
				case NSUpArrowFunctionKey:
				case NSDownArrowFunctionKey:
					return;
					
				case NSLeftArrowFunctionKey:
					moveLeft(this);
					return;
					
				case NSRightArrowFunctionKey:
					moveRight(this);
					return;
					
				case NSTabCharacter:
				
					if (theEvent.modifierFlags & NSEvent.NSShiftKeyMask) {
						m_window.selectKeyViewPrecedingView(this);
					} else {
						m_window.selectKeyViewFollowingView(this);
					}
				
					return;
			}
		}
		
		if (m_acceptsAlphaNumericalKeys && (character < 0xF700)
				&& characters.length > 0) {
			var matrix:NSMatrix;
			var sv:String;
			var i:Number, n:Number, s:Number;
			var match:Number;
			var selCol:Number;
			var lcarcSel:String = "loadedCellAtRowColumn";
							
			selCol = selectedColumn();
			if (selCol != -1) {
				matrix = matrixInColumn(selCol);
				n = matrix.numberOfRows();
				s = matrix.selectedRow();
				
				//
				// Create or modify the char buffer
				//
				if (null == m_charBuffer) {
					m_charBuffer = characters.substring(0, 1);
				} else {
					if ((theEvent.timestamp - m_lastKeyPressed < 2000.0)
							&& (m_alphaNumericalLastColumn == selCol)) {
						m_charBuffer += characters.substring(0, 1); 
					} else {
						m_charBuffer = characters.substring(0, 1);
					}
				}
								
				m_alphaNumericalLastColumn = selCol;
				m_lastKeyPressed = theEvent.timestamp;
				sv = loadedCellAtRowColumn(s, selCol).stringValue();
				if ((sv.length > 0) && (sv.indexOf(m_charBuffer) == 0)) {
					return;
				}
				
				match = -1;
				for (i = s + 1; i < n; i++) {
					sv = loadedCellAtRowColumn(i, selCol).stringValue();
					if ((sv.length > 0) && (sv.indexOf(m_charBuffer) == 0)) {
						match = i;
						break;
					}
				}
				
				if (i == n) {
					for (i = 0; i < s; i++) {
						sv = loadedCellAtRowColumn(i, selCol).stringValue();
						if ((sv.length > 0) && (sv.indexOf(m_charBuffer) == 0)) {
							match = i;
							break;
						}
					}
				}
				if (match != -1) {
					if (m_allowsMultipleSelection) {
						matrix.deselectAllCells();
					}
					
					selectRowInColumn(match, selCol);
//					matrix.scrollCellToVisibleAtRowColumn(match, 0);
					doClick(matrix);
					return;
				}
			}
			m_lastKeyPressed = 0.;
		}
		
		super.keyDown(theEvent);
	}
	
	public function acceptsFirstMouse():Boolean {
		return true;
	}
	
	public function acceptsFirstResponder():Boolean {
		return true;
	}
	
	public function becomeFirstResponder():Boolean {
		var matrix:NSMatrix;
		var selCol:Number;
	
		selCol = this.selectedColumn();

		if (selCol == -1) {
			matrix = matrixInColumn(0); 
		} else {
			matrix = matrixInColumn(selCol);
		}
				
		if (matrix != null) {
			if (selectedRowInColumn(selCol) == -1) {
				matrix.selectCellAtRowColumn(0, 0);
				matrix.sendAction();
			}
			m_window.makeFirstResponder(matrix);
			matrix.setNeedsDisplay(true);
		}
	
		return true;
	}
	
	//******************************************************
	//*                 View overrides
	//******************************************************
	
	/**
	 * Draws the browser in <code>rect</code>.
	 */
	public function drawRect(rect:NSRect):Void {
		var scrollerWidth:Number = ASTheme.current().scrollerWidth();
		var g:ASGraphics = graphics();
		g.clear();
		
		var bg:NSColor = m_window.backgroundColor();
		g.brushDownWithBrush(bg);
		g.drawRectWithRect(rect);
		g.brushUp();
		
		// Load the first column if not already done
		if (!m_isLoaded) {
			loadColumnZero();
		}
		
		// Draws titles
		if (m_isTitled) {
			var i:Number;
			var titleCnt:Number = m_titles.count();
			if (numberOfVisibleColumns() != titleCnt) {
				_resizeTitleArray();
			}
			
			for (i = m_firstVisibleColumn; i <= m_lastVisibleColumn; ++i) {
				var titleRect:NSRect = titleFrameOfColumn(i);
			
				if (titleRect.intersectsRect(rect)) {
					drawTitleOfColumnInRect(i, titleRect);
				}
			}
		}
		
		// Draws scroller border
		if (m_hasHorizontalScroller && m_separatesColumns) {
			var scrollerBorderRect:NSRect = m_scrollerRect.clone();
			var bs:NSSize = NSBorderType.NSBezelBorder.size.clone();
			
			scrollerBorderRect.origin.x = 0;
			scrollerBorderRect.origin.y = 0;
			scrollerBorderRect.size.width += 2 * bs.width;
			scrollerBorderRect.size.height += (2 * bs.height) - 1;
			
			if (scrollerBorderRect.intersectsRect(rect) 
					&& m_window != null) {
				//! FIXME [GSDrawFunctions drawGrayBezel: scrollerBorderRect : rect];
			}
		}
		
		if (!m_separatesColumns) {
			var p1:NSPoint, p2:NSPoint;
			var visibleColumns:Number;
			var hScrollerWidth:Number = m_hasHorizontalScroller ? scrollerWidth : 0;
			
			// Columns borders
			//! FIXME [GSDrawFunctions drawGrayBezel: _bounds : rect];
			
			visibleColumns = numberOfVisibleColumns(); 
			for (var i:Number = 1; i < visibleColumns; i++) {
				p1 = new NSPoint((m_columnSize.width * i) + 2 + (i - 1), 
					m_columnSize.height + hScrollerWidth + 2);
				p2 = new NSPoint((m_columnSize.width * i) + 2 + (i - 1),
					hScrollerWidth + 2);
				
				g.drawLineWithPoints(p1, p2, ASColors.blackColor(), 1);
			}
			
			//
			// Horizontal scroller border
			//
			if (m_hasHorizontalScroller)
			{
				p1 = new NSPoint(2, hScrollerWidth + 2);
				p2 = new NSPoint(rect.size.width - 2, hScrollerWidth + 2);
				
				g.drawLineWithPoints(p1, p2, ASColors.blackColor(), 1);
			}
		}
	}
	
	/**
	 * Informs the receivers's subviews that the receiver's bounds rectangle 
	 * size has changed from <code>oldSize</code>.
	 */
	public function resizeSubviewsWithOldSize(oldSize:NSSize):Void {
		tile();
	}
	
	public function isOpaque():Boolean {
		return true;
	}
	
	//******************************************************
	//*                   Extensions
	//******************************************************
	
	/**
	 * Returns <code>true</code> if the alpha numerical keys are enabled.
	 */
	public function acceptsAlphaNumericalKeys():Boolean {
		return m_acceptsAlphaNumericalKeys;
	}
	
	/**
	 * Enables or disables the arrow keys as used for navigating within and
	 * between browsers.
	 */
	public function setAcceptsAlphaNumericalKeys(flag:Boolean):Void {
		m_acceptsAlphaNumericalKeys = flag;
	}
			
	//******************************************************
	//*                 Private methods
	//******************************************************
	
	private function _remapColumnSubviews(fromFirst:Boolean):Void {
		var bc:ASBrowserColumn;
		var sc:NSScrollView;
		var i:Number, count:Number;
		var firstResponder:NSResponder = null;
		var setFirstResponder:Boolean = false;
		var cols:Array = m_columns.internalList();
		
		//
		// Removes all column subviews.
		//
		count = cols.length;
		for (i = 0; i < count; i++) {
			bc = ASBrowserColumn(cols[i]);
			sc = bc.scrollView();
		
			if (firstResponder == null && bc.matrix() == m_window.firstResponder()) {
				firstResponder = bc.matrix();
			}
			
			if (sc) {
				sc.removeFromSuperviewWithoutNeedingDisplay();
			}
		}
		
		if (m_firstVisibleColumn > m_lastVisibleColumn) {
			return;
		}
		
		//
		// Sets columns subviews order according to fromFirst (display order...).
		// All added subviews are automaticaly marked as needing display (->
		// NSView).
		//
		if (fromFirst) {
			for (i = m_firstVisibleColumn; i <= m_lastVisibleColumn; i++) {
				bc = ASBrowserColumn(cols[i]);
				sc = bc.scrollView();
				addSubview(sc);
				
				if (bc.matrix() == firstResponder) {
					m_window.makeFirstResponder(firstResponder);
					setFirstResponder = true;
				}
			}
			
			if (firstResponder && !setFirstResponder) {
				m_window.makeFirstResponder(ASBrowserColumn(
					cols[m_firstVisibleColumn]).matrix());
			}
		} else {
			for (i = m_lastVisibleColumn; i >= m_firstVisibleColumn; i--) {
				bc = ASBrowserColumn(cols[i]);
				sc = bc.scrollView();
				addSubview(sc);
			
				if (bc.matrix() == firstResponder) {
					m_window.makeFirstResponder(firstResponder);
					setFirstResponder = true;
				}
			}
			
			if (firstResponder && !setFirstResponder) {
				m_window.makeFirstResponder(ASBrowserColumn(
					cols[m_lastVisibleColumn]).matrix());
			}
		}
	}
	
	private function _resizeTitleArray():Void {
		var cnt:Number = numberOfVisibleColumns();
		var titleCnt:Number = m_titles.count();
		
		if (cnt > titleCnt) {
			var add:Number = cnt - titleCnt;
			for (var i:Number = 0; i < add; i++) {
				m_titles.addObject((new ASBrowserTitleCell()).initTextCell(""));
			}
		}
		else if (cnt < titleCnt) {
			var remove:Number = titleCnt - cnt;
			var rng:NSRange = new NSRange(cnt - 1, remove);
			m_titles.subarrayWithRange(rng).makeObjectsPerformSelector("release");
			m_titles.removeObjectsInRange(rng);
		}
	}
	
	/**
	 * Loads column <code>column</code> (asking the delegate).
	 */
	private function _performLoadOfColumn(column:Number):Void {
		var bc:ASBrowserColumn;
		var sc:NSScrollView;
		var matrix:NSMatrix;
		var i:Number, rows:Number, cols:Number;
		
		if (m_passiveDelegate) {
			// Ask the delegate for the number of rows
			rows = m_delegate.browserNumberOfRowsInColumn(this, column);
			cols = 1;
		} else {
			rows = 0;
			cols = 0;
		}
		
		bc = ASBrowserColumn(m_columns.objectAtIndex(column));
		
		if (null == (sc = bc.scrollView())) {
			return;
		}
		
		matrix = bc.matrix();
		
		if (m_reusesColumns && matrix != null) {
			matrix.renewRowsColumns(rows, cols);
		
			// Mark all the cells as unloaded
			matrix.cells().makeObjectsPerformSelectorWithObject("setLoaded", false);
		} else {
			var bgColor:NSColor = ASTheme.current().colorWithName(
				ASThemeColorNames.ASBrowserMatrixBackground);
			var matrixRect:NSRect = new NSRect(0, 0, 100, 100);
			var matrixIntercellSpace:NSSize = new NSSize(0, 0);
			
			// create a new col matrix
			matrix = NSMatrix(ASUtils.createInstanceOf(m_matrixClass))
				.initWithFrameModePrototypeNumberOfRowsNumberOfColumns(
					matrixRect,
					NSMatrixMode.NSListModeMatrix,
					m_cellPrototype,
					rows,
					cols);
			
			//
			// Background color
			//
			if (bgColor != null) {
				matrix.setDrawsBackground(true);
				matrix.setBackgroundColor(NSColor(bgColor.copy()));
			} else {
				matrix.setDrawsBackground(false);
			}
			
			var cs:NSSize = matrix.cellSize();
			cs.height = CELL_HEIGHT;
			matrix.setCellSize(cs);
			matrix.setTabKeyTraversesCells(false);
			matrix.setIntercellSpacing(matrixIntercellSpace);
			matrix.setAllowsEmptySelection(m_allowsEmptySelection);
			matrix.setAutoscroll(true);
			if (!m_allowsMultipleSelection) {
				matrix.setMode(NSMatrixMode.NSRadioModeMatrix);
			}
			matrix.setTarget(this);
			matrix.setAction("doClick");
			matrix.setDoubleAction("doDoubleClick");
			bc.setMatrix(matrix);
		}
		sc.setDocumentView(matrix);
		matrix.setNextResponder(this);
		
		//
		// Loading is different based upon passive/active delegate
		//
		if (m_passiveDelegate) {
			//
			// Now loop through the cells and load each one
			//
			var aCell:NSBrowserCell;
			
			for (i = 0; i < rows; i++) {
				aCell = NSBrowserCell(matrix.cellAtRowColumn(i, 0));
				if (!aCell.isLoaded())
				{
					m_delegate.browserWillDisplayCellAtRowColumn(this, aCell, i, column);
					aCell.setLoaded(true);
				}
			}
		} else {
			//
			// Tell the delegate to create the rows
			//
			m_delegate.browserCreateRowsForColumnInMatrix(this, column, matrix);
		}
		
		sc.setNeedsDisplay(true);
		sc.contentView().setNeedsDisplay(true);
		bc.setLoaded(true);
		
		if (column > m_lastColumnLoaded) {
			m_lastColumnLoaded = column;
		}
		
		//
		// Determine the height of a cell in the matrix, and set that as the 
		// cellSize of the matrix.
		//
		var cs:NSSize, ms:NSSize;
		var b:NSBrowserCell = NSBrowserCell(matrix.cellAtRowColumn(0, 0)); 
		
		if (b != null) {
			ms = b.cellSize();
		} else {
			ms = matrix.cellSize();
		}
		cs = sc.contentSize();
		ms.width = cs.width;
		matrix.setCellSize(ms);
		matrix.setNeedsDisplay(true);
		
		//
		// Get the title even when untitled, as this may change later.
		//
		setTitleOfColumn(_getTitleOfColumn(column), column);
	}
	
	/**
	 * Get the title of a column indexed at <code>column</code>.
	 */
	private function _getTitleOfColumn(column:Number):String {
		// Ask the delegate for the column title
		if (ASUtils.respondsToSelector(m_delegate, "browserTitleOfColumn")) {
			var title:String = m_delegate.browserTitleOfColumn(this, column);
			if (title != null) {
				return title;
			}
		}
				
		// Check if we take title from previous column
		if (m_takesTitleFromPreviousColumn) {
			var c:NSBrowserCell;
		
			// If first column then use the path separator
			if (column == 0) {
				return m_pathSeparator;
			}
			
			// Get the selected cell
			// Use its string value as the title
			// Only if it is not a leaf
			if(!m_allowsMultipleSelection) {
				c = NSBrowserCell(selectedCellInColumn(column - 1));
			} else {
				var matrix:NSMatrix;
				var selectedCells:NSArray;
				
				if (null == (matrix = matrixInColumn(column - 1))) {
					return "";
				}
				
				selectedCells = matrix.selectedCells();
				
				if(selectedCells.count() == 1) {
					c = NSBrowserCell(selectedCells.objectAtIndex(0));
				} else {
					return "";
				}
			}
			
			if (c.isLeaf()) {
				return "";
			} else {
				var value:String = c.stringValue();
			
				if (value != null) {
					return value;
				} else {
					return "";
				}
			}
		}
		
		return "";
	}
	
	/**
	 * Marks all titles as needing to be redrawn.
	 */
	private function _setColumnTitlesNeedDisplay():Void {
		if (!m_isTitled) {
			return;
		}
		
		var r:NSRect = titleFrameOfColumn(m_firstVisibleColumn);
		r.size.width = m_frame.size.width;
		//!FIXME [self setNeedsDisplayInRect: r];
		setNeedsDisplay(true);
	}
}