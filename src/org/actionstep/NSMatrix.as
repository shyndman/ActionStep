/* See LICENSE for copyright and terms of use */

import org.actionstep.ASFieldEditingProtocol;
import org.actionstep.ASFieldEditor;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSCellType;
import org.actionstep.constants.NSMatrixMode;
import org.actionstep.constants.NSTextMovement;
import org.actionstep.NSActionCell;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSCell;
import org.actionstep.NSColor;
import org.actionstep.NSControl;
import org.actionstep.NSDictionary;
import org.actionstep.NSEnumerator;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPoint;
import org.actionstep.NSRange;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTextFieldCell;
import org.actionstep.NSToolTipOwner;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.ASDebugger;

/**
 * <p>NSMatrix is a class used for creating groups of NSCells that work together 
 * in various ways.</p>
 * 
 * <p>The cells in an NSMatrix are numbered by row and column, each starting with
 * 0; for example, the top left NSCell would be at (0, 0), and the NSCell 
 * that’s second down and third across would be at (1, 2).</p>
 * 
 * <p>Matrices typically are used for radio groups.</p>
 *
 * <p>For an example of this class' usage, please see 
 * {@link org.actionstep.test.ASTestMatrix}.</p>
 * 
 * <p><strong>Differences from Cocoa:</strong>
 * <ul>
 * <li>{@link #defaultCellClass} and {@link #setDefaultCellClass}() are 
 * ActionStep's equivalents to <code>cellClass()</code> and 
 * <code>setCellClass()</code>.</li>
 * </ul>
 * </p>
 * 
 * <p><strong>Class TODO:</strong>
 * <ul>
 * <li>Fix mouse and keyboard handling</li>
 * <li>Look into selection by rect</li>
 * </ul>
 * </p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSMatrix extends NSControl implements NSToolTipOwner {
	
	//******************************************************
	//*                     Members
	//******************************************************
		
	private var m_cellClass:Function;
	private var m_prototype:NSCell;	
	private var m_cells:NSArray; 
	private var m_numRows:Number;
	private var m_numCols:Number;
	private var m_maxRows:Number = 0;
	private var m_maxCols:Number = 0;
	private var m_mode:NSMatrixMode;
	private var m_allowsEmptySel:Boolean;
	private var m_bgColor:NSColor;
	private var m_cellBgColor:NSColor;
	private var m_cellSize:NSSize;
	private var m_delegate:Object;
	private var m_doubleAction:String;
	private var m_drawsBg:Boolean;
	private var m_autosizeCells:Boolean;
	private var m_cellSpacing:NSSize;
	private var m_autoscroll:Boolean;
	private var m_isSelByRect:Boolean;
	private var m_keyCell:NSCell;
	private var m_mouseDownFlags:Number;
	private var m_sel:NSArray;
	//private var m_selCell:NSCell; // The selected cell.
	private var m_selCell_row:Number; // holds the row of m_selCell
	private var m_selCell_column:Number; // holds the column of m_selCell
	private var m_target:Object;
	private var m_action:String;
	private var m_useTabKey:Boolean;
	private var m_editor:ASFieldEditor;
	
	private var m_dottedRow:Number = -1; // the row in which the highlighted cell exists
	private var m_dottedCol:Number = -1; // the column in which the highlighted cell exists
	
	/** 
	 * The reason this is here, and not in a cell, is because a matrix can 
	 * exist with no cells, and we wouldn't have a cell to ask.
	 *
	 * @see org.actionstep.NSMatrix#drawsCellBackground()
	 * @see org.actionstep.NSMatrix#setDrawsCellBackground()
	 */
	private var m_drawsCellBg:Boolean;
	
	/** 
	 * True if using copies of a cell instance to fill cells, and false 
	 * otherwise. The default is false.
	 */
	private var m_usingCellInstance:Boolean;
	
	/**
	 * Holds cell tooltip information.
	 */
	private var m_toolTips:NSArray;
	
	/**
	 * <code>true</code> if any of the matrix's cells have tooltips.
	 */
	private var m_hasToolTips:Boolean;
	
	/**
	 * Tag for the matrix's cell tool tips.
	 */
	private var m_cellToolTipTag:Number;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Constructs a new instance of <code>NSMatrix</code>.
	 */
	public function NSMatrix() {	
		m_cellClass = NSActionCell;
		m_sel = new NSArray();
		m_cells = new NSArray();
		m_toolTips = new NSArray();
		m_numRows = 0;
		m_numCols = 0;
		m_drawsBg = true;
		m_drawsCellBg = false;
		m_hasToolTips = false;
		m_autosizeCells = true;
		m_usingCellInstance = false;
		m_allowsEmptySel = false;
		m_cellSpacing = new NSSize(1, 1);
		m_cellSize = new NSSize(100, 17);
		m_autoscroll = false;
		m_isSelByRect = true;
		m_useTabKey = true;  
	}
	
	/**
	 * Basic init.
	 */
	public function init():NSMatrix {
		initWithFrame(NSRect.ZeroRect);
		return this;
	}
	
	/**
	 * Initializes and returns the receiver, a newly allocated instance of 
	 * <code>NSMatrix</code>, with default parameters in the frame specified by 
	 * <code>frameRect</code>. The new <code>NSMatrix</code> contains no rows or
	 * columns. The default mode is <code>NSRadioModeMatrix</code>. The default 
	 * cell class is <code>NSActionCell</code>.
	 */
	public function initWithFrame(frameRect:NSRect):NSMatrix {
		initWithFrameModeCellClassNumberOfRowsNumberOfColumns(frameRect, 
			NSMatrixMode.NSRadioModeMatrix, m_cellClass, 0, 0);
				
		return this;
	}
	
	/**
	 * <p>Initializes and returns the receiver, a newly allocated instance of 
	 * <code>NSMatrix</code>, in the frame specified by <code>frameRect</code>. 
	 * The new <code>NSMatrix</code> contains <code>numRows</code> rows and 
	 * <code>numColumns</code> columns. <code>aMode</code> is set as the 
	 * tracking mode for the <code>NSMatrix</code> and can be one of the modes 
	 * described in "Constants".</p>
	 *
	 * <p>The new <code>NSMatrix</code> creates and uses cells of class 
	 * <code>cellClass</code>.</p>
	 *
	 * <p>This method is the designated initializer for matrices that add cells 
	 * by creating instances of an <code>NSCell</code> subclass.</p>
	 */
	public function initWithFrameModeCellClassNumberOfRowsNumberOfColumns(
			frameRect:NSRect, aMode:NSMatrixMode, cellClass:Function, 
			numRows:Number, numColumns:Number):NSMatrix {
		super.initWithFrame(frameRect);
	
		m_cellClass = cellClass;
  		renewRowsColumnsRowSpaceColSpace(numRows, numColumns, 0, 0);
  		m_mode = aMode;
		postInit();
		
		return this;
	}
	
	/**
	 * <p>Initializes and returns the receiver, a newly allocated instance of 
	 * <code>NSMatrix</code>, in the frame specified by <code>frameRect</code>. 
	 * The new <code>NSMatrix</code> contains <code>numRows</code> rows and 
	 * <code>numColumns</code> columns. <code>aMode</code> is set as the
	 * tracking mode for the <code>NSMatrix</code> and can be one of the modes 
	 * described in "Constants".</p>
	 *
	 * <p>The new matrix creates cells by copying <code>aCell</code>, which 
	 * should be an instance of a subclass of <code>NSCell</code>.</p>
	 *
	 * <p>This method is the designated initializer for matrices that add cells
	 * by copying an instance of an <code>NSCell</code> subclass.</p>
	 */
	public function initWithFrameModePrototypeNumberOfRowsNumberOfColumns(
			frameRect:NSRect, aMode:NSMatrixMode, aCell:NSCell, 
			numRows:Number, numColumns:Number):NSMatrix {
		super.initWithFrame(frameRect);
		
		m_prototype = aCell;
		m_usingCellInstance = true;
		renewRowsColumnsRowSpaceColSpace(numRows, numColumns, 0, 0);
		m_mode = aMode;
		
		postInit();
		
		return this;
	}
	
	/**
	 * A few common operations between the inits.
	 */
	private function postInit():Void
	{		
  		//
  		// Set cell size if applicable.
  		//
  		if (m_numRows > 0 && m_numCols > 0) {
 			recalcCellSize();	 		
 		}
  		
  		//
  		// Make initial selection.
  		//
		if (m_mode == NSMatrixMode.NSRadioModeMatrix && m_numRows > 0 
				&& m_numCols > 0) {
			this.selectCellAtRowColumn(0, 0);
		} else {
			m_selCell_row = m_selCell_column = -1;
			m_cell = null;
		}
	}
	
	//******************************************************
	//*                Releasing the matrix
	//******************************************************
	
	public function release():Boolean {
		var arr:Array = m_cells.internalList();
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			NSCell(arr[i]).release();
		}
		
		m_cells.removeAllObjects();
		m_cells = null;
		m_sel.removeAllObjects();
		m_sel = null;
		
		return super.release();
	}
	
	//******************************************************
	//*               Describing the matrix
	//******************************************************
	
	/**
	 * Returns a string representation of the NSMatrix instance.
	 */
	public function description():String
	{
		return "NSMatrix(numberOfColumns=" + m_numCols 
			+ ", numberOfRows=" + m_numRows + ")";
	}
	
	//******************************************************
	//*             Setting the selection mode
	//******************************************************
	
	/**
	 * Returns the selection mode of the receiver.
	 */
	public function mode():NSMatrixMode {
		return m_mode;
	}
	
	/**
	 * Sets the selection mode of the matrix to <code>aMode</code>.
	 */
	public function setMode(aMode:NSMatrixMode):Void {
		m_mode = aMode;
		//! FIXME Should we stop current tracking?
	}
	
	//******************************************************
	//*             Configuring the NSMatrix
	//******************************************************
	
	/**
	 * Returns whether it’s possible to have no cells selected in a 
	 * radio-mode matrix.
	 */
	public function allowsEmptySelection():Boolean {	
		return m_allowsEmptySel;
	}
	
	/**
	 * If <code>flag</code> is <code>true</code>, then the receiver will allow 
	 * one or zero cells to be selected. If <code>flag</code> is 
	 * <code>false</code>, then the receiver will allow one and only
	 * one cell (not zero cells) to be selected. This setting has effect only
	 * in the <code>NSRadioModeMatrix</code> selection mode.
	 */
	public function setAllowsEmptySelection(flag:Boolean):Void {
		m_allowsEmptySel = flag;
	}
	
	/**
	 * Returns <code>true</code> if the user can select a rectangle of cells in 
	 * the receiver by dragging the cursor, <code>false</code> otherwise.
	 */
	public function isSelectionByRect():Boolean {
		return m_isSelByRect;
	}
	
	/**
	 * Sets whether the user can select a rectangle of cells in the matrix by 
	 * dragging the cursor.
	 */
	public function setSelectionByRect(flag:Boolean):Void {
		m_isSelByRect = flag;
	}
	
	//******************************************************
	//*              Setting the cell class
	//******************************************************
	
	/**
	 * <p>Returns the subclass of <code>NSCell</code> that the receiver uses 
	 * when creating new (empty) cells.</p>
	 * 
	 * <p>This method is named {@link #cellClass} in Cocoa.</p>
	 */
	public function defaultCellClass():Function {
		return m_cellClass;
	}
	
	/**
	 * <p>Configures the receiver to use instances of <code>aClass</code> when 
	 * creating new cells. <code>aClass</code> should be the id of a subclass of
	 * <code>NSCell</code>, which can be obtained by calling the the 
	 * {@link #className()} message to either the <code>NSCell</code> 
	 * subclass object or to an instance of that subclass. The default cell 
	 * class is that set with the class method {@link #setCellClass}, or 
	 * <code>NSActionCell</code> if no other default cell class has been 
	 * specified.</p>
	 *
	 * <p>You need to use this method only with matrices initialized with
	 * {@link #initWithFrame}, because the other initializers allow you to 
	 * specify an instance-specific cell class or cell prototype.</p>
	 * 
	 * <p>This method is named {@link #setCellClass} in Cocoa.</p>
	 */
	public function setDefaultCellClass(aClass:Function):Void {
		m_cellClass = aClass;
		m_usingCellInstance = false;
	}
	
	/**
	 * Returns the prototype cell that’s copied whenever a new cell needs to be
	 * created, or <code>null</code> if there is none.
	 */
	public function prototype():NSCell {
		return m_prototype;
	}
	
	/**
	 * Sets the prototype cell that’s copied whenever a new cell needs to be 
	 * created.
	 */
	public function setPrototype(aCell:NSCell):Void {
		m_prototype = aCell;
		m_usingCellInstance = true;
	}
	
	//******************************************************
	//*              Laying out the NSMatrix
	//******************************************************
	
	/**
	 * Returns the frame rectangle of the cell that would be drawn at the 
	 * location specified by <code>row</code> and <code>column</code> (whether 
	 * or not the specified cell actually exists).	
	 */
	public function cellFrameAtRowColumn(row:Number, column:Number):NSRect {
		var iniX:Number = 0;
		var iniY:Number = 0;
		var incX:Number = m_cellSpacing.width + m_cellSize.width;
		var incY:Number = m_cellSpacing.height + m_cellSize.height;
		
		return new NSRect(iniX + column * incX, iniY + row * incY,
			m_cellSize.width, m_cellSize.height);
	}
	
	/**
	 * Returns the width and the height of each cell in the receiver (all 
	 * cells in an <code>NSMatrix</code> are the same size).
	 */
	public function cellSize():NSSize {
		return m_cellSize;
	}
	
	/**
	 * <p>Sets the width and height of each of the cells in the receiver to
	 * those in <code>aSize</code>. This method may change the size of the 
	 * receiver.</p>
	 * 
	 * <p>Does not redraw the receiver.</p>
	 */
	public function setCellSize(aSize:NSSize):Void {
		m_cellSize = aSize;
	}
	
	/**
	 * Returns the vertical and horizontal spacing between cells in the receiver.
	 */
	public function intercellSpacing():NSSize {
		return m_cellSpacing;
	}
	
	/**
	 * Sets the vertical and horizontal spacing between cells in the receiver
	 * to <code>aSize</code>. By default, both values are <code>1.0</code> in 
	 * the receiver’s coordinate system.
	 */
	public function setIntercellSpacing(aSize:NSSize):Void {
		m_cellSpacing = aSize;
		recalcCellSize();
	}
	
	/**
	 * <p>Returns a simple object with a <code>columnCount</code> and 
	 * <code>rowCount</code> properties which correspond to the number of 
	 * columns and the number of rows in the reciever respectively.</p>
	 *
	 * <p><strong>Note:</strong> This implementation is different than that 
	 * specified by the Cocoa documentation, as ActionScript does not have the 
	 * concept of pointers.</p>
	 */
	public function getNumberOfRowsColumns():Object {
		return {rowCount:m_numRows, columnCount:m_numCols};
	}
	
	/**
	 * Returns the number of columns in the receiver.
	 */
	public function numberOfColumns():Number {
		return m_numCols;
	}
	
	/**
	 * Returns the number of rows in the receiver.
	 */
	public function numberOfRows():Number {
		return m_numRows;
	}
	
	/**
	 * <p>Adds a new column of cells to the right of the last column, creating
	 * new cells as needed with {@link #makeCellAtRowColumn}.</p>
	 *
	 * <p>This method raises an exception if there are 0 rows or 0 columns. Use 
	 * {@link #renewRowsColumns} to add new cells to an empty matrix.</p>
	 *
	 * <p>If the number of rows or columns in the receiver has been changed 
	 * with {@link #renewRowsColumns}, new cells are created only if they 
	 * are needed. This fact allows you to grow and shrink an 
	 * <code>NSMatrix</code> without repeatedly creating and freeing the cells.
	 * </p>
	 *
	 * <p>This method redraws the receiver. Your code may need to send 
	 * {@link #sizeToCells} after sending this method to resize the 
	 * receiver to fit the newly added cells.</p>
	 */
	public function addColumn():Void {
		insertColumn(m_numCols);
	}
	
	/**
	 * <p>Adds a new column of cells to the right of the last column. The 
	 * new column is filled with objects from <code>newCells</code>, starting 
	 * with the object at index <code>0</code>. Each object in 
	 * <code>newCells</code> should be an instance of <code>NSCell</code> or one
	 * of its subclasses (usually <code>NSActionCell</code>). 
	 * <code>newCells</code> should have a sufficient number of cells to fill 
	 * the entire column. Extra cells are ignored, unless the matrix is empty. 
	 * In that case, a matrix is created with one column and enough rows for all
	 * the elements of <code>newCells</code>.</p>
	 *
	 * <p>This method redraws the receiver. Your code may need to send 
	 * {@link #sizeToCells} after sending this method to resize the 
	 * receiver to fit the newly added cells.</p>
	 */
	public function addColumnWithCells(newCells:NSArray):Void {
		insertColumnWithCells(m_numCols, newCells);
	}
	
	/**
	 * <p>Adds a new row of cells below the last row, creating new cells as 
	 * needed with {@link #makeCellAtRowColumn}.</p>
	 *
	 * <p>This method raises an exception if there are 0 rows or 0 columns.
	 * Use {@link #renewRowsColumns} to add new cells to an empty matrix.
	 * </p>
	 *
	 * <p>If the number of rows or columns in the receiver has been changed with 
	 * {@link #renewRowsColumns}, then new cells are created only if they 
	 * are needed. This fact allows you to grow and shrink an 
	 * <code>NSMatrix</code> without repeatedly creating and freeing the cells.
	 * </p>
	 *
	 * <p>This method redraws the receiver. Your code may need to send 
	 * {@link #sizeToCells} after sending this method to resize the 
	 * receiver to fit the newly added cells.</p>
	 */
	public function addRow():Void {
		insertRow(m_numRows);
	}
	
	/**
	 * <p>Adds a new row of cells below the last row. The new row is filled with 
	 * objects from <code>newCells</code>, starting with the object at index 
	 * <code>0</code>. Each object in <code>newCells</code> should be an 
	 * instance of <code>NSCell</code> or one of its subclasses (usually 
	 * <code>NSActionCell</code>). <code>newCells</code> should have a 
	 * sufficient number of cells to fill the entire row. Extra cells are 
	 * ignored, unless the matrix is empty. In that case, a matrix is created 
	 * with one row and enough columns for all the elements of 
	 * <code>newCells</code>.</p>
	 *
	 * <p>This method redraws the receiver. Your code may need to send 
	 * {@link #sizeToCells} after sending this method to resize the 
	 * receiver to fit the newly added cells.</p>
	 */
	public function addRowWithCells(newCells:NSArray):Void {
		insertRowWithCells(m_numRows, newCells);
	}
	
	/**
	 * <p>Inserts a new column of cells before <code>column</code>, creating new
	 * cells if needed with {@link #makeCellAtRowColumn}. If 
	 * <code>column</code> is greater than the number of columns in the 
	 * receiver, enough columns are created to expand the receiver to be
	 * <code>column</code> columns wide. This method redraws the receiver. Your 
	 * code may need to send {@link #sizeToCells} after sending this method
	 * to resize the receiver to fit the newly added cells.</p>
	 *
	 * <p>If the number of rows or columns in the receiver has been changed with 
	 * {@link #renewRowsColumns}, new cells are created only if they’re 
	 * needed. This fact allows you to grow and shrink an <code>NSMatrix</code> 
	 * without repeatedly creating and freeing the cells.</p>
	 */
	public function insertColumn(column:Number):Void {
		insertColumnWithCells(column, null);
	}
	
	/**
	 * <p>Inserts a new column of cells before <code>column</code>. The new 
	 * column is filled with objects from <code>newCells</code>, starting with 
	 * the object at index <code>0</code>. Each object in <code>newCells</code> 
	 * should be an instance of <code>NSCell</code> or one of its subclasses 
	 * (usually <code>NSActionCell</code>). If <code>column</code> is greater 
	 * than the number of columns in the receiver, enough columns are created to
	 * expand the receiver to be <code>column</code> columns wide. 
	 * <code>newCells</code> should either be empty or contain a sufficient 
	 * number of cells to fill each new column. If <code>newCells</code> is null
	 * or an array with no elements, the call is equivalent to calling
	 * {@link #insertColumn}. Extra cells are ignored, unless the matrix is
	 * empty. In that case, a matrix is created with one column and enough rows 
	 * for all the elements of <code>newCells</code>.</p>
	 *
	 * <p>This method redraws the receiver. Your code may need to send 
	 * {@link #sizeToCells} after sending this method to resize the 
	 * receiver to fit the newly added cells.</p>
	 */
	public function insertColumnWithCells(column:Number, newCells:NSArray):Void	{
		var cnt:Number = newCells.count();
		var i:Number = m_numCols + 1;
		
		if (cnt == undefined) {
			cnt = 0;
		}
		
  		//
  		// Check for illegal argument (negative column).
  		//  
		if (column < 0) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSRangeException",
				"NSMatrix::insertColumnWithCells - " + column + 
				" was specified as the column parameter. Negative indices are " +
				"not allowed.");
			trace(e);
			throw e;
		}
		
		//
		// If column is more than the number of columns, then increase i.
		//
		if (column >= i) {
			i = column + 1;
		}
		
		//
		// Use renewRowsColumnsRowSpaceColSpace to grow the matrix as necessary.
		// The docs say that if the matrix is empty, we make it have one column
		// and enough rows for all the elements.
		//
		if (cnt > 0 && (m_numRows == 0 || m_numCols == 0)) {
			//trace("cnt > 0 && (m_numRows == 0 || m_numCols == 0)");
			renewRowsColumnsRowSpaceColSpace(cnt, 1, 0, cnt);
		} else {
			//trace("num rows: " + m_numRows + ", column: " + i);
			renewRowsColumnsRowSpaceColSpace(m_numRows == 0 ? 1 : m_numRows,
				i, 0, cnt);
		}
		
		//
		// Push all the existing cells one column forward.
		//
		if (m_numCols != column) {
			for (i = 0; i < m_numRows; i++) {
				var j:Number = m_numCols;
				var old:NSCell = cellAtRowColumn(i, j-1);
			
				while (--j > column) {
					assignCell(cellAtRowColumn(i, j-1), i, j, false);
				}
				
				assignCell(old, i, column, false);
			}
			
			if (m_cell && (m_selCell_column >= column)) {
				m_selCell_column++;
			}
			if (m_dottedCol >= column) {
				m_dottedCol++;
			}
		}
		
		//
		// Since a new column is added, the current selections who's column's
		// are higher than column must be incremented.
		//
		updateSelWithColumnAdded(column);
		
		//
		// Put the new cells into the matrix (if there are any).
		//
		if (cnt > 0) {			
			for (i = 0; i < m_numRows && i < cnt; i++) {
				//
				// Use this call so the old cell is property released.
				//
				assignCell(NSCell(newCells.objectAtIndex(i)), i, column);
			}
		}
		
		//
		// If we are in radio matrix mode without allowed empty cell 
		// selection and there is no current selection, then we select
		// the first cell.
		//
		if (m_mode == NSMatrixMode.NSRadioModeMatrix && 
				m_allowsEmptySel == false && 
				selectedCell() == null) {
			selectCellAtRowColumn(0, 0);
		}
		
		setNeedsDisplay(true);
	}
	
	/**
	 * <p>Inserts a new row of cells before <code>row</code>, creating new cells
	 * if needed with {@link #makeCellAtRowColumn}. If <code>row</code> is 
	 * greater than the number of rows in the receiver, enough rows are created 
	 * to expand the receiver to be <code>row</code> rows high. This method 
	 * redraws the receiver. Your code may need to call 
	 * {@link #sizeToCells} after sending this method to resize the 
	 * receiver to fit the newly added cells.</p>
	 *
	 * <p>If the number of rows or columns in the receiver has been changed with
	 * {@link #renewRowsColumns}, then new cells are created only if 
	 * they’re needed. This fact allows you to grow and shrink an 
	 * <code>NSMatrix</code> without repeatedly creating and freeing the cells.
	 * </p>
	 */
	public function insertRow(row:Number):Void {
		insertRowWithCells(row, null);
	}
	
	/**
	 * <p>Inserts a new row of cells before <code>row</code>. The new row is 
	 * filled with objects from <code>newCells</code>, starting with the object 
	 * at index <code>0</code>. Each object in <code>newCells</code> should be 
	 * an instance of <code>NSCell</code> or one of its subclasses (usually 
	 * <code>NSActionCell</code>). If <code>row</code> is greater than the
	 * number of rows in the receiver, enough rows are created to expand
	 * the receiver to be <code>row</code> rows high. <code>newCells</code> 
	 * should either be empty or contain a sufficient number of cells to fill 
	 * each new row. If <code>newCells</code> is <code>null</code> or an array 
	 * with no elements, the call is equivalent to calling 
	 * {@link #insertRow}. Extra cells are ignored, unless the matrix is
	 * empty. In that case, a matrix is created with one row and enough
	 * columns for all the elements of <code>newCells</code>.</p>
	 *
	 * <p>This method redraws the receiver. Your code may need to send 
	 * {@link #sizeToCells} after sending this method to resize the 
	 * receiver to fit the newly added cells.</p>
	 */
	public function insertRowWithCells(row:Number, newCells:NSArray):Void {
		var cnt:Number = newCells.count();
		var i:Number = m_numRows + 1;
		
		if (cnt == undefined) {
			cnt = 0;
		}

		if (row < 0) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSRangeException",
				"NSMatrix::insertRowWithCells - " + row + 
				" was specified as the row parameter. Negative indices are " +
				"not allowed.");
			trace(e);
			throw e;
		}
		
		if (row >= i) {
			i = row + 1;
		}
				
		//
		// Use renewRowsColumnsRowSpaceColSpace to grow the matrix as necessary.
		// The docs say that if the matrix is empty, we make it have one column
		// and enough rows for all the elements.
		//
		if (cnt > 0 && (m_numRows == 0 || m_numCols == 0)) {
			renewRowsColumnsRowSpaceColSpace(1, cnt, cnt, 0);
		} else {
			renewRowsColumnsRowSpaceColSpace(i,
				m_numCols == 0 ? 1 : m_numCols, cnt, 0);
		}

		//
		// Push all currently existing rows downwards
		//
		if (m_numRows != row) {
			for (i = 0; i < m_numCols; i++) {
				var j:Number = m_numRows;
				var old:NSCell = cellAtRowColumn(j - 1, i);
			
				while (--j > row) {
					assignCell(cellAtRowColumn(j - 1, i), j, i, false);
				}
				
				assignCell(old, row, i, false);
			}
			
			if (m_cell && (m_selCell_row >= row)) {
				m_selCell_row++;
			}
			if (m_dottedRow >= row) {
				m_dottedRow++;
			}
		}
		
		//
		// Update selection
		//
		updateSelWithRowAdded(row);
		
		//
		// Put the new cells into the matrix (if there are any).
		//
		if (cnt > 0) {			
			for (var j:Number = 0; j < cnt; j++) {
				//
				// Use this call so the old cell is property released.
				//
				assignCell(NSCell(newCells.objectAtIndex(j)), row, j);				
			}
		}
		
		//
		// If we are in radio matrix mode without allowed empty cell 
		// selection and there is no current selection, then we select
		// the first cell.
		//
		if (m_mode == NSMatrixMode.NSRadioModeMatrix && 
				m_allowsEmptySel == false && 
				selectedCell() == null) {
			selectCellAtRowColumn(0, 0);
		}
		
		setNeedsDisplay(true);
	}

	/**
	 * <p>Creates a new cell at the location specified by <code>row</code> and 
	 * <code>column</code> in the receiver. If the receiver has a prototype 
	 * cell, it’s copied to create the new cell. If not, and if the receiver has 
	 * a cell class set, it allocates and initializes (with {@link #init}) 
	 * an instance of that class. If the receiver hasn’t had either a prototype 
	 * cell or a cell class set, {@link #makeCellAtRowColumn} creates an 
	 * <code>NSActionCell</code>. Returns the newly created cell.</p>
	 *
	 * <p>Your code should never invoke this method directly; it’s used by 
	 * {@link #addRow} and other methods when a cell must be created. It 
	 * may be overridden to provide more specific initialization of cells.</p>
	 */
	public function makeCellAtRowColumn(row:Number, column:Number):NSCell {		
		var cell:NSCell = makeCell();
		putCellAtRowColumn(cell, row, column);	
				
		return cell;	
	}
	
	/**
	 * Replaces the cell at the location specified by <code>row</code> and 
	 * <code>column</code> with <code>newCell</code> and redraws the cell.
	 */
	public function putCellAtRowColumn(newCell:NSCell, row:Number, column:Number):Void {
		var idx:Number;
		var cell:NSCell;
		
		//
		// Check if row and column are in bounds.
		//
		if (row >= m_numRows || row < 0 || column >= m_numCols || column < 0) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSOutOfRangeException",
				"NSMatrix::putCellAtRowColumn - row: " + row + 
				", column: " + column + " - Out of bounds.",
				null);
			trace(e);
			throw e;
		}
		
		//
		// Assign the cell
		//
		assignCell(newCell, row, column);
		
		//! What should we do about selection?
		
		//
		// Draw it.
		//
		drawCellAtRowColumn(row, column);
	}
		
	/**
	 * Removes the column at position <code>column</code> from the receiver and 
	 * autoreleases the column’s cells. Redraws the receiver. Your code should 
	 * normally call {@link #sizeToCells} after invoking this method to 
	 * resize the receiver so it fits the reduced cell count.
	 */
	public function removeColumn(column:Number):Void {
		//
		// Check if row and column are in bounds.
		//
		if (column >= m_numCols || column < 0) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSIndexOutOfRangeException",
				"NSMatrix::removeColumn - column: " + column + " - Out of bounds.",
				null);
			trace(e);
			throw e;
		}
		
		var i:Number;
		
		//
		// Shift cells
		//
		for (i = 0; i < m_maxRows; i++) {
			var j:Number;
			
			var cell:NSCell = NSCell(cellAtRowColumn(i, column));
			cell.release();
			
			
			for (j = column + 1; j < m_maxCols; j++) {
				assignCell(cellAtRowColumn(i, j), i, j-1, false);
			}
		}
		
		//
		// Update array (remove last column from each row)
		//
		for (i = m_maxRows - 1; i >= 0; i--) {
			m_cells.removeObjectAtIndex(indexFromRowColumn(i, m_numCols - 1));
		}
					
		updateSelWithColumnRemoved(column);
		m_numCols--;
		m_maxCols--;
		
		if (m_maxCols == 0)	{
			m_numRows = m_maxRows = 0;
		}
		
		if (column == m_selCell_column)	{
			m_cell = null;
			selectCellAtRowColumn(m_selCell_row, 0);
		}
		
		if (column == m_dottedCol) {
			if (m_numCols != 0 
					&& cellAtRowColumn(m_dottedRow, 0).acceptsFirstResponder()) {
				m_dottedCol = 0;
			} else {
				m_dottedRow = m_dottedCol = -1;
			}
		}
		
		setNeedsDisplay(true);
	}
	
	/**
	 * Removes the row at position <code>row</code> from the receiver and 
	 * autoreleases the row’s cells. Redraws the receiver. Your code should 
	 * normally call {@link #sizeToCells} after invoking this method to 
	 * resize the receiver so it fits the reduced cell count.
	 */
	public function removeRow(row:Number):Void {
		//
		// Check if row and column are in bounds.
		//
		if (row >= m_numRows || row < 0) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSIndexOutOfRangeException",
				"NSMatrix::removeRow - row: " + row + " - Out of bounds.",
				null);
			trace(e);
			throw e;
		}
		
		var removalPoint:Number = row * m_numCols;
		var numToRemove:Number = m_numCols;
				
		while (numToRemove-- > 0) {
			var cell:NSCell = NSCell(m_cells.objectAtIndex(removalPoint));
			m_cells.removeObjectAtIndex(removalPoint);
			cell.release();
		}
		
		updateSelWithRowRemoved(row);
		m_numRows--;
		m_maxRows--;
		
		if (m_maxRows == 0) {
			m_numCols = m_maxCols = 0;
		}
		
		if (row == m_selCell_row) {
			m_cell = null;
			selectCellAtRowColumn(0, m_selCell_column);
		}
		
		if (row == m_dottedRow) {
			if (m_numRows != 0 
					&& cellAtRowColumn(0, m_dottedCol).acceptsFirstResponder()) {
				m_dottedRow = 0;
			} else {
				m_dottedRow = m_dottedCol = -1;
			}
		}
		
		setNeedsDisplay(true);
	}
	
	/**
	 * Changes the number of rows and columns in the receiver. This method uses
	 * the same cells as before, creating new cells only if the new size is
	 * larger; it never frees cells. Doesn’t redisplay the receiver. Your code
	 * should normally send {@link #sizeToCells} after invoking this method
	 * to resize the receiver so it fits the changed cell arrangement. This 
	 * method deselects all cells in the receiver.
	 */
	public function renewRowsColumns(newRows:Number, newColumns:Number):Void {	
		renewRowsColumnsRowSpaceColSpace(newRows, newColumns, 0, 0);
	}
	
	//! TODO - (void)sortUsingFunction:(int (*)(id, id, void *))comparator context:(void *)context
	//! TODO - (void)sortUsingSelector:(SEL)comparator
	
	//******************************************************
	//*            Finding matrix coordinates
	//******************************************************
	
	/**
	 * <p>Returns a simple object with <code>row</code> and <code>column</code> 
	 * properties if <code>aPoint</code> lies within one of the cells in the 
	 * receiver, and sets <code>row</code> and <code>column</code> to 
	 * the row and column for the cell within which the specified point lies.
	 * If <code>aPoint</code> falls outside the bounds of the receiver or lies 
	 * within an intercell spacing, {@link #getRowColumnForPoint} returns 
	 * <code>null</code>.</p>
	 *
	 * <p>Make sure <code>aPoint</code> is in the coordinate system of the 
	 * receiver.</p>
	 *
	 * <p><strong>Note:</strong> This implementation is different than that 
	 * specified by the Cocoa documentation, as ActionScript does not have the 
	 * concept of pointers.</p>
	 */
	public function getRowColumnForPoint(aPoint:NSPoint):Object {
		aPoint = convertPointFromView(aPoint, null);	
		var colWidth:Number = m_cellSize.width + m_cellSpacing.width;
		var rowHeight:Number = m_cellSize.height + m_cellSpacing.height;
		
		//
		// Build the location object.
		//
		var loc:Object = {};
		loc.column = Math.floor(aPoint.x / colWidth);
		loc.row = Math.floor(aPoint.y / rowHeight);
		
		//
		// If row or column is out of bounds, return null.
		//
		if (loc.row >= m_numRows || 
				loc.row < 0 || 
				loc.column >= m_numCols ||
				loc.column < 0) {
			return null;
		}
		
		//
		// Return the location if the cell if the point doesn't lie on
		// intercell spacing.
		//
		return ((aPoint.x % colWidth) > m_cellSpacing.width &&
			(aPoint.y % rowHeight) > m_cellSpacing.height) ? loc : null;
	}
	
	/**
	 * <p>Searches the receiver and returns a simple object with <code>row</code> 
	 * and <code>column</code> properties if <code>aCell</code> is one of the 
	 * cells in the receiver, and sets <code>row</code> and <code>column</code> 
	 * to the row and column of the cell. If <code>aCell</code> is not found 
	 * within the receiver, {@link #getRowColumnOfCell} returns 
	 * <code>null</code>.</p>
	 *
	 * <p><strong>Note:</strong> This implementation is different than that 
	 * specified by the Cocoa documentation, as ActionScript does not have the 
	 * concept of pointers.</p>
	 */
	public function getRowColumnOfCell(aCell:NSCell):Object {		
		//
		// Cycle through until we make a match
		//
		var len:Number = m_cells.count();
		
		for (var i:Number = 0; i < len; i++) {
			//
			// If match, calculate row and column from index, and return.
			//
			if (m_cells.objectAtIndex(i) == aCell) {
				return rowColumnFromIndex(i);
			}
		}
		
		return null;
	}
	
	//******************************************************
	//*            Modifying individual cells
	//******************************************************
	
	/**
	 * <p>Sets the state of the cell at <code>row</code> <code>column</code> to
	 * value.</p>
	 * 
	 * <p>If this matrix is in radio mode, the cell is selected before the state
	 * is set.</p>
	 */
	public function setStateAtRowColumn(value:Number, row:Number, column:Number)
			:Void {
		var cell:NSCell = cellAtRowColumn(row, column);
		
		if (cell == null) {
			return;
		}
		
		if (m_mode == NSMatrixMode.NSRadioModeMatrix && value != 0) {
			selectCell(cell);
		}	
		
		cell.setState(value);
		drawCellAtRowColumn(row, column);
	}
	
	/**
	 * <p>Sets the tool tip of <code>cell</code> to <code>toolTipString</code>.
	 * </p>
	 * 
	 * <p>If <code>toolTipString</code> is <code>null</code>, no tool tip will 
	 * be displayed for <code>cell</code>.</p>
	 */
	public function setToolTipForCell(toolTipString:String, cell:NSCell):Void {
		var loc:Object = getRowColumnOfCell(cell);
		
		if (loc == null) {
			return;
		}
		
		var tt:Object = null;
		
		//
		// Remove current tooltip if one exists.
		//
		var ttIdx:Number;
		if (m_hasToolTips && NSNotFound != (ttIdx = 
			m_toolTips.indexOfObjectWithCompareFunction(cell, __toolTipCompare)))
		{
			tt = m_toolTips.objectAtIndex(ttIdx);
		}
		
		//
		// Tooltip removal (if null)
		//
		if (toolTipString == null) {
			if (tt != null) {
				m_toolTips.removeObjectAtIndex(ttIdx);
				
				//
				// We might want to remove the tracking rect
				//
				if (m_toolTips.count() == 0) {
					removeToolTip(m_cellToolTipTag);
					m_hasToolTips = false;
				}
			}
			
			return;
		}
		
		//
		// Create / modify tooltip data for cell
		//
		if (tt == null) {
			m_toolTips.addObject({cell: cell, string: toolTipString});
		} else {
			tt.string = toolTipString;
		}
		
		//
		// Set up matrix tracking rect if necessary
		//	
		if (!m_hasToolTips) {
			m_cellToolTipTag = addToolTipRectOwnerUserDataHideOnMouseMove(
				NSRect.withOriginSize(NSPoint.ZeroPoint, frame().size), 
				this, // tool tip owner
				null, // user data
				true); // hide on mouse move
			m_hasToolTips = true;
		}
	}
	
	/**
	 * Returns the tooltip text for <code>cell</code> or null if 
	 * <code>cell</code> does not have a tooltip.
	 */
	public function toolTipForCell(cell:NSCell):String {
		var ttIdx:Number = m_toolTips.indexOfObjectWithCompareFunction(
			{cell: cell}, __toolTipCompare);

		if (ttIdx == NSNotFound) {
			return null;
		}
		
		return m_toolTips.objectAtIndex(ttIdx).string;
	}
	
	/**
	 * <p>Returns the tooltip for the cell at <code>point</code>, or 
	 * <code>null</code> if none exists.</p>
	 * 
	 * <p>This is an implementation of the <code>NSToolTipOwner</code> protocol,
	 * and should not be called.</p>
	 */
	public function viewStringForToolTipPointUserData(view:NSView, tag:Number, 
			point:NSPoint, userData:Object):String {
		var loc:Object = getRowColumnForPoint(point);
		
		if (loc == null) { // Not found, return null (no tool tip)
			return null;
		}
		
		var cell:NSCell = cellAtRowColumn(loc.row, loc.column);
		
		if (cell == null) { // Not found
			return null;
		}
		
		return toolTipForCell(cell);
	}
	
	//******************************************************
	//*                 Selecting cells
	//******************************************************
	
	/** 
	 * Deselects all cells in the receiver and, if necessary, redisplays the 
	 * receiver. If the selection mode is <code>NSRadioModeMatrix</code> and 
	 * empty selection is not allowed, this method does nothing.
	 */
	public function deselectAllCells():Void {		
		if (m_mode == NSMatrixMode.NSRadioModeMatrix && !m_allowsEmptySel) {
			return;
		}

		//
		// If nothing is selected, return.
		//
		if (m_sel.count() == 0) {
			return;
		}
			
		//
		// Cycle through cells, deselecting as we go.
		//			
		var arr:Array = m_sel.internalList();
		var len:Number = arr.length;
		var cell:NSCell;
		var loc:Number;
		
		for (var i:Number = 0; i < len; i++) {	
			cell = NSCell(m_cells.objectAtIndex(arr[i]));
			cell.setState(NSCell.NSOffState);
			cell.setHighlighted(false);
			cell.setShowsFirstResponder(false);
		}
		
		m_sel.removeAllObjects();
		m_dottedRow = m_dottedCol = -1;
		m_cell = null;
		m_selCell_row = m_selCell_column = -1;
		setNeedsDisplay(true);
	}
	
	/**
	 * Deselects the selected cell or cells. If the selection mode is 
	 * <code>NSRadioModeMatrix</code> and empty selection is not allowed, or if 
	 * nothing is currently selected, this method does nothing. This method 
	 * doesn’t redisplay the receiver.
	 */
	public function deselectSelectedCell():Void {
		if (m_mode == NSMatrixMode.NSRadioModeMatrix && !m_allowsEmptySel) {
			return;
		}

		//
		// Cycle through cells, deselecting as we go.
		//			
		var cellItr:NSEnumerator = m_sel.objectEnumerator();
		var cell:NSCell;
		var loc:Object;
		
		while (null != (loc = cellItr.nextObject())) {			
			cell = cellAtRowColumn(loc.row, loc.column);
			cell.setHighlighted(false);
		}
				
		m_sel.removeAllObjects();
	}
	
	/**
	 * Selects and highlights all cells in the receiver, except for editable
	 * text cells and disabled cells. Redisplays the receiver. sender is ignored.
	 */
	public function selectAll():Void {
		if (m_mode == NSMatrixMode.NSRadioModeMatrix) {
			return;
		}
		
		//
		// Cycle through cells, selecting and highlighting as we go.
		//
		var cellItr:NSEnumerator = cells().objectEnumerator();
		var cell:NSCell;
		var cnt:Number = 0;
		
		while (null != (cell = NSCell(cellItr.nextObject()))) {
			if ((cell.type() == NSCellType.NSTextCellType && cell.isEditable())
				|| !cell.isEnabled()) {
				continue;
			}
			
			cell.setHighlighted(true);
			m_sel.addObject({row: Math.floor(cnt / m_numCols), column: cnt % m_numCols});
			
			cnt++;
		}
		
		setNeedsDisplay(true); // mark the reciever for redraw.
	}
	
	/**
	 * Selects <code>aCell</code> if it exists within the matrix.
	 */
	public function selectCell(aCell:NSCell):Void {
		var loc:Object = getRowColumnOfCell(aCell);
		
		if (loc != null) {
			selectCellAtRowColumn(loc.row, loc.column);
		}
	}
	/**
	 * Selects the cell at the specified row and column within the receiver.
	 * If the specified cell is an editable text cell, its text is selected. If
	 * either <code>row</code> or <code>column</code> is <code>–1</code>, then 
	 * the current selection is cleared (unless the receiver is an 
	 * <code>NSRadioModeMatrix</code> and doesn’t allow empty selection). 
	 * Redraws the affected cells.
	 */
	public function selectCellAtRowColumn(row:Number, column:Number):Void {
		if (row == -1 || column == -1) {
			deselectAllCells();
			return;
		}
		
		if (m_selCell_row == row && m_selCell_column == column) {
			return;
		}
		
		var cell:NSCell = cellAtRowColumn(row, column);
				
		if (cell != null) {	
			var rect:NSRect;
			
			//
			// For NSRadioModeMatrix - Deselect the old selection if not the
			// same as the new one.
			//
			if (m_mode == NSMatrixMode.NSRadioModeMatrix &&
					m_cell != null && cell != m_cell) {
				clearCurrentRadioSelection(false);
			}
			
			if (m_cell != null && cell != m_cell) {
				m_cell.setShowsFirstResponder(false);
				//! setNeedsDisplayInRect
				drawCellAtRowColumn(m_selCell_row, m_selCell_column);
			}
			
			if (m_cell != cell) {
				var idx:Number = indexFromRowColumn(row, column);
				m_sel.addObject(idx);
			}
			
			//
			// Record the new selection
			//
			m_cell = cell;
			m_selCell_row = row;
			m_selCell_column = column;
			
			//
			// Update visual representation
			// 
			m_cell.setState(NSCell.NSOnState);
			setKeyRowColumn(row, column);
						
			if (m_mode == NSMatrixMode.NSListModeMatrix) {
				m_cell.setHighlighted(true);
			}
				
			rect = cellFrameAtRowColumn(row, column);
			
			if (m_autoscroll) {				
				scrollRectToVisible(rect);
			}
						
			//
			// Draw.
			//
			setNeedsDisplay(true);
						
			//
			// Select text if we can
			//
			selectTextAtRowColumn(row, column);
		} else {
			m_cell = null;
			m_selCell_row = m_selCell_column = -1;
		}
	}
	
	/**
	 * If the receiver has at least one cell whose tag is equal to 
	 * <code>anInt</code>, the last cell (when viewing the matrix as a 
	 * row-ordered array) is selected. If the specified cell is an editable text
	 * cell, its text is selected. Returns <code>true</code> if the receiver 
	 * contains a cell whose tag matches <code>anInt</code>, or <code>false</code> 
	 * if no such cell exists.
	 */
	public function selectCellWithTag(anInt:Number):Boolean {
		var cell:NSCell = cellWithTag(anInt);
		if (cell == null) {
			return false;
		}
		
		var loc:Object = getRowColumnOfCell(cell);
		selectCellAtRowColumn(loc.row, loc.column);
		return true;
	}
	
	/**
	 * Returns the most recently selected cell, or nil if no cell is selected.
	 * If more than one cell is selected, this method returns the cell that is
	 * lowest and farthest to the right in the receiver.	
	 */
	public function selectedCell():NSCell {
		switch (m_sel.count()) {
			case 0:
				return null;
				
			case 1:
				return m_cell;		
		}
		
		return m_cell;
		
		// FIXME
//		//
//		// default case (selections > 1)
//		//
//		var selLoc:Number = getLowestRightmostSelectionLocation();
//		return NSCell(m_cells.objectAtIndex(selLoc));
	}
	
	/**
	 * Returns an array containing all of the receiver’s highlighted cells.
	 */
	public function selectedCells():NSArray {
		var ret:NSArray = NSArray.array();
		var arr:Array = m_sel.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			ret.addObject(m_cells.objectAtIndex(arr[i]));
		}
		
		return ret;
	}
	
	/**
	 * Returns the column number of the selected cell, or <code>–1</code> if no 
	 * cells are selected. If cells in multiple columns are selected, this 
	 * method returns the number of the last (rightmost) column containing a 
	 * selected cell.
	 */
	public function selectedColumn():Number {
		if (m_sel.count() == 0) {
			return -1;
		}
			
		//
		// Radio mode
		//
		if (m_mode == NSMatrixMode.NSRadioModeMatrix) {
			return m_selCell_column;
		}
			
		//
		// Non-radio mode
		//
		var cellItr:NSEnumerator = m_sel.objectEnumerator();
		var selLoc:Object;
		var resLoc:Object;
		
		while (null != (selLoc = cellItr.nextObject())) {
			//
			// Set resLoc to the first item in the list.
			//
			if (resLoc == null) {
				resLoc = selLoc;
				continue;
			}
			
			resLoc = resLoc.column > selLoc.column ? resLoc : selLoc;
		}
		
		return resLoc.column;
	}
	
	/**
	 * Returns the row number of the selected cell, or <code>–1</code> if no 
	 * cells are selected. If cells in multiple rows are selected, this method 
	 * returns the number of the last row containing a selected cell.
	 */
	public function selectedRow():Number {
		if (m_sel.count() == 0) {
			return -1;
		}
		
		//
		// Radio mode
		//
		if (m_mode == NSMatrixMode.NSRadioModeMatrix) {
			return m_selCell_row;
		}

		//
		// Non-radio mode
		//
		var loc:Object = getLowestRightmostSelectionLocation();
		return loc.row;
	}
	
	/** 
	 * Sets selection, counting from 0 (upper-left corner) in row order.
	 * 
	 * TODO Fill in comment
	 */	
	public function setSelectionFromToAnchorHighlight(start:Number, 
			delta:Number, pivot:Number, lit:Boolean):Void {
		// TODO this is wrong
		selectCell(NSCell(m_cells.objectAtIndex(start)));
	}
	
	/**
	 * Returns the cell that will be clicked when the user presses the Space bar.
	 */
	public function keyCell():NSCell {
		return m_keyCell;
	}
	
	/**
	 * Sets the cell that will be clicked when the user presses the Space bar to
	 * <code>aCell</code>.
	 */
	public function setKeyCell(aCell:NSCell):Void {
		m_keyCell = aCell;
	}
	
	//******************************************************
	//*                  Finding cells
	//******************************************************
	
	/**
	 * Returns the NSCell object at the location specified by row and column,
	 * or null if either row or column is outside the bounds of the receiver.
	 */
	public function cellAtRowColumn(row:Number, column:Number):NSCell {
		return NSCell(m_cells.objectAtIndex(indexFromRowColumn(row, column)));
	}	
	
	/**
	 * Searches the receiver and returns the last (when viewing the matrix 
	 * as a row-ordered array) NSCell object that has a tag matching anInt, 
	 * or null if no such cell exists.
	 */
	public function cellWithTag(anInt:Number):NSCell {
		//
		// Using a reverse enumerator, because this method returns the
		// 'last' NSCell that has the matching tag.
		//
		var itrRows:NSEnumerator = m_cells.reverseObjectEnumerator();
		
		//
		// Cycle through cells
		//
		var cell:NSCell;
		while (null != (cell = NSCell(itrRows.nextObject()))) {			
			if (cell.tag() == anInt)
				return cell;
		}
		
		return null; // cell doesn't exist
	}
	
	/**
	 * Returns an NSArray that contains the receiver’s cells. The cells in the 
	 * array are row-ordered; that is, the first row of cells appears first in 
	 * the array, followed by the second row, and so forth.
	 */
	public function cells():NSArray {		
		return m_cells;
	}
	
	//******************************************************
	//*           Modifying graphics attributes
	//******************************************************
	
	/**
	 * Returns the color used to draw the background of the receiver (the space between 
	 * the cells).
	 */
	public function backgroundColor():NSColor {
		return m_bgColor;
	}
	
	/**
	 * Sets the background color for the receiver to aColor and redraws the
	 * receiver. This color is used to fill the space between cells or the
	 * space behind any nonopaque cells. The default background color is
	 * NSColor’s controlColor.
	 */
	public function setBackgroundColor(aColor:NSColor):Void {
		m_bgColor = aColor;
		
		setNeedsDisplay(true);
	}
	
	/**
	 * Returns the color used to fill the background of the receiver’s cells.
	 */
	public function cellBackgroundColor():NSColor {
		return m_cellBgColor;
	}

	/**
	 * Sets the background color for the cells in the receiver to aColor. This
	 * color is used to fill the space behind nonopaque cells. The default cell
	 * background color is NSColor’s controlColor.
	 */
	public function setCellBackgroundColor(aColor:NSColor):Void {
		m_cellBgColor = aColor;
	}
	
	/**
	 * Returns whether the receiver draws its background (the space between the cells).
	 */
	public function drawsBackground():Boolean {
		return m_drawsBg;
	}
	
	/**
	 * Sets whether the receiver draws its background (the space between the cells) to flag.
	 */
	public function setDrawsBackground(flag:Boolean):Void {
		m_drawsBg = flag;
	}
	
	/**
	 * Returns whether the receiver draws the background within each of its cells.
	 */
	public function drawsCellBackground():Boolean {
		//
		// Should be member variable, and not dependant on cell instances,
		// because matrix can by 0x0.
		//
		return m_drawsCellBg;
	}
	
	/**
	 * Sets whether the receiver draws the background within each of its cells to flag.
	 */
	public function setDrawsCellBackground(flag:Boolean):Void {
		m_drawsCellBg = flag;
	}
	
	//******************************************************															 
	//*                Editing text in cells
	//******************************************************
	  
	/**
	 * If the currently selected cell is editable and enabled, its text is
	 * selected. Otherwise, the key cell is selected.
	 */
	public function selectText(sender:Object):Void {
		selectTextWithCell(selectedCell());
	}
	
	/**
	 * If row and column indicate a valid cell within the receiver, and that
	 * cell is both editable and selectable, this method selects and then
	 * returns the specified cell. If the cell specified by row and column is
	 * either not editable or not selectable, this method does nothing, and
	 * returns nil. Finally, if row and column indicate a cell that is outside
	 * the receiver, this method does nothing and returns the receiver.
	 */
	public function selectTextAtRowColumn(row:Number, column:Number):NSCell {
		var cell:NSCell = cellAtRowColumn(row, column);
				
		if (cell == null || !selectTextWithCell(cell)) {
			return null;
		}
		
		return cell;
	}
	
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
		//trace("NSMatrix.textDidBeginEditing(notification)");
		
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
		//trace("NSMatrix.textDidChange(notification)");
		
		//
		// Inform cell
		//
		var cell:NSCell = selectedCell();
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
		//trace("NSMatrix.textDidEndEditing(notification)");
		
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
			NSControlTextDidEndEditingNotification, 
			this, 
			userInfo);
		
		//
		// Inform the cell.
		//
		validateEditing();
		NSTextFieldCell(m_cell).endEditingWithDelegate(this);
		setKeyCell(m_cell);

		//
		// Mark for redraw
		//
		setNeedsDisplay(true);
		
		//
		// Perform the appropriate action based on which key was used to end
		// editing.
		//
		switch(notification.userInfo.objectForKey("NSTextMovement")) {
			case NSTextMovement.NSReturnTextMovement:
				sendAction();
				break;
				
			case NSTextMovement.NSTabTextMovement:
				//
				// Tabbing
				//
				if (tabKeyTraversesCells()) {
					selectNextSelectableCellAfterRowColumn(m_selCell_row,
							m_selCell_column);	
				} else {
					m_window.selectKeyViewFollowingView(this);
				}
				
				//
				// Text selection
				//
				if (m_window.firstResponder() == m_window) {
					selectText(this);
				}
				break;
				
			case NSTextMovement.NSBacktabTextMovement:
				//
				// Tabbing
				//
				if (tabKeyTraversesCells()) {
					selectPreviousSelectableCellAfterRowColumn(m_selCell_row,
							m_selCell_column);	
				} else {
					m_window.selectKeyViewPrecedingView(this);
				}
				
				if (m_window.firstResponder() == m_window) {
					selectText(this);
				}
				break;
				
			case NSTextMovement.NSIllegalTextMovement:
				break;
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
	public function textShouldEndEditing(editor:Object):Boolean 
	{
		//trace("NSMatrix.textShouldEndEditing(editor)");
		
		//! TODO validate text field
		
		var del:Object = delegate();
		if (del != null && ASUtils.respondsToSelector(del, 
				"controlTextShouldEndEditing")) {
			return del["controlTextShouldEndEditing"](this, editor);	
		}
		
		return true;
	}
	
	/**
	 * Called when an action interrupts the editing of a cell.
	 */
	public function abortEditing():Boolean {
		//trace("NSMatrix.abortEditing()");
		
		if (m_editor) {
			m_editor = null;
			ASFieldEditingProtocol(m_cell).endEditingWithDelegate(this);
			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * Called by the cell when the string value is being requested.
	 */
	public function validateEditing():Void {
		//trace("NSMatrix.validateEditing()");
		
		var sel:NSCell = selectedCell();
	    if (m_editor != null && m_editor.cell() == sel) {
	    	sel.setStringValue(m_editor.string());
	    }
	}
	
	//******************************************************
	//*             Setting tab key behavior
	//******************************************************
	
	/**
	 * Returns whether pressing the Tab key advances the key cell to the next
	 * selectable cell in the receiver.
	 */
	public function tabKeyTraversesCells():Boolean {
		return m_useTabKey;
	}
	
	/**
	 * Sets whether pressing tab will move focus to the next selectable cell.
	 * If flag is false, or there are no more selectable cells, the window
	 * becomes key. Pressing shift and tab moves the advances the focus in the
	 * opposite direction.
	 */
	public function setTabKeyTraversesCells(flag:Boolean):Void {
		m_useTabKey = flag;
	}
	
	//******************************************************
	//*               Assigning a delegate
	//******************************************************
	
	/**
	 * Returns the delegate for messages from the field editor.
	 */
	public function delegate():Object {
		return m_delegate;
	}
	
	/**
	 * Sets the delegate for messages from the field editor to anObject.
	 */
	public function setDelegate(anObject:Object):Void {
		//
		// Remove existing delegate
		//
		if (m_delegate != null) {
			NSNotificationCenter.defaultCenter().removeObserverNameObject(
				m_delegate, null, this);
		}
		
		m_delegate = anObject;
		
		if (m_delegate == null) {
			return;
		}
		
		mapDelegateNotification("DidBeginEditing");
		mapDelegateNotification("DidEndEditing");
		mapDelegateNotification("DidChange");
	}

	/**
	 * Maps the notification named 
	 * <code>"NSControlText"+name+"Notification"</code> to the delegate's
	 * <code>"controlText" + name</code> method.
	 */
	private function mapDelegateNotification(name:String) {
		if(typeof(m_delegate["controlText"+name]) == "function") {
			m_notificationCenter.addObserverSelectorNameObject(
				m_delegate, 
				"controlText" + name, 
				ASUtils.intern("NSControlText"+name+"Notification"), 
				this);
    	}
  	}
	
	//******************************************************
	//*         Resizing the matrix and its cells
	//******************************************************
	
	/**
	 * Returns true if cells are resized proportionally to the receiver when 
	 * its size changes (and intercell spacing is kept constant). Returns false
	 * if the cell size and intercell spacing remain constant.
	 */
	public function autosizesCells():Boolean {
		return m_autosizeCells;
	}
	
	/**
	 * Sets whether the cell sizes change when the matrix is resized.
	 * 
	 * If <code>flag</code> is <code>true</code>, then whenever the matrix is 
	 * resized, the sizes of the cells change in proportion, keeping the 
	 * intercell space constant; further, this method verifies that the cell 
	 * sizes and intercell spacing add up to the exact size of the receiver, 
	 * adjusting the size of the cells and updating the receiver if they don’t. 
	 * If <code>flag</code> is <code>false</code>, then the intercell spacing 
	 * and cell size remain constant.
	 */
	public function setAutosizesCells(flag:Boolean):Void {
		if (m_autosizeCells = flag) {
			return;
		}
		
		m_autosizeCells = flag;
	}
	
	/**
	 * Sizes the matrix to the exact size required to view all the cells.
	 */
	public function sizeToCells():Void
	{
		var frameSize:NSSize = NSSize.ZeroSize;
		var cs:NSSize = m_cellSize;
		var ss:NSSize = m_cellSpacing;
		
		frameSize.width += cs.width * m_numCols + ss.width * (m_numCols - 1);
		frameSize.height += cs.height * m_numRows + ss.height * (m_numRows - 1);
		
		this.setFrameSize(frameSize);
	}
	
	/**
	 * Calls {@link #sizeToCells}.
	 */
	public function sizeToFit():Void {
		sizeToCells();
	}
	
	//! TODO - (void)setValidateSize:(BOOL)flag

	//******************************************************
	//*                  Scrolling
	//******************************************************
		
	/**
	 * Returns whether the receiver will be automatically scrolled whenever the 
	 * cursor is dragged outside the receiver after a mouse-down event within 
	 * its bounds.
	 */
	public function isAutoscroll():Boolean {
		return m_autoscroll;
	}
	
	/**
	 * True if the receiver should scroll when the cursor is dragged outside
	 * the receiver after a mouse-down event within its bounds.
	 */
	public function setAutoscroll(flag:Boolean):Void {
		m_autoscroll = flag;
	}
	
	/**
	 * If the receiver is in a scrolling view, and row and column represent a 
	 * valid cell within the receiver, this method scrolls the receiver so the 
	 * specified cell is visible.
	 */
	public function scrollCellToVisibleAtRowColumn(row:Number, column:Number):Void {
		if (row == null || column == null) {
			return;
		}
		
		scrollRectToVisible(cellFrameAtRowColumn(row, column));
	}
	
	/**
	 * If <code>flag</code> is <code>true</code>, makes all the cells 
	 * scrollable, so the text they contain scrolls to remain in view if the 
	 * user types past the edge of the cell. If <code>flag</code> is 
	 * <code>false</code>, all cells are made nonscrolling. The prototype cell, 
	 * if there is one, is also set accordingly.
	 */
	public function setScrollable(flag:Boolean):Void {
		var arr:Array = m_cells.internalList();
		var len:Number = arr.length;
		
		for (var i:Number = 0; i < len; i++) {
			NSCell(arr[i]).setScrollable(flag);
		}
		
		m_prototype.setScrollable(flag);
	}
	
	//******************************************************
	//*                  Displaying
	//******************************************************
	
	/**
	 * Displays the cell at the specified row and column, providing that row 
	 * and column reference a cell within the receiver.
	 */
	public function drawCellAtRowColumn(row:Number, column:Number):Void {
		
		if (m_mcBounds == null) {
			return;
		}
			
		var cell:NSCell = cellAtRowColumn(row, column);		
				
		if (cell == null) { // if cell doesn't exist, we can't draw it
			return;
		}
			
		var frame:NSRect = cellFrameAtRowColumn(row, column);
				
		//
		// Draw the cell background.
		//
		if (m_drawsCellBg) {
			ASTheme.current().drawFillWithRectColorInView(frame, m_cellBgColor, this);
		} 
		
		//
		// First responder
		//
		if (m_dottedRow == row && m_dottedCol == column 
				&& cell.acceptsFirstResponder()
				&& m_window.isKeyWindow()
				&& m_window.firstResponder() == this) {
			cell.setShowsFirstResponder(true);
			cell.drawWithFrameInView(frame, this);
			cell.setShowsFirstResponder(false);
		} else {
			cell.setShowsFirstResponder(false);
			cell.drawWithFrameInView(frame, this);
		}		
	}
	
	/**
	 * Assuming that row and column indicate a valid cell within the receiver,
	 * this method highlights (if flag is YES) or unhighlights (if flag is NO)
	 * the specified cell.
	 */
	public function highlightCellAtRowColumn(flag:Boolean, row:Number, 
			column:Number):Void {
		var cell:NSCell = cellAtRowColumn(row, column);
		if (cell == null) { // can't highlight it if it doesn't exist
			return;
		}
			
		cell.setHighlighted(flag);
	}
	
	//******************************************************
	//*               Target and action
	//******************************************************
	
	/**
	 * Returns the the method name that is called on this control's target
	 * when a double click occurs.
	 *
	 * @see org.actionstep.NSMatrix#setDoubleAction
	 * @see org.actionstep.NSMatrix#sendDoubleAction
	 */
	public function doubleAction():String {
		return m_doubleAction;
	}
	
	/**
	 * If the selected cell has a target and an action, a message is sent
	 * to the target.
	 *
	 * If the cell's target is null, this control's target is used.
	 *
	 * If there is no selected cell or the selected cell has no action, this
	 * control triggers its target's action.
	 *
	 * This method returns <code>true</code> if a target responds to the 
	 * message, and <code>false</code> otherwise.
	 */
	public function sendAction():Boolean {
		var selcell:NSCell = selectedCell();
		if (selcell == null || selcell.action() == null) {
			//
			// No selection or selection has no action, so use this control's
			// target and action.
			//
			return sendActionTo(m_action, m_target);
		}
		else if (selcell.target() == null) {
			//
			// Selection has no target, so use this control's target.
			//
			return sendActionTo(selcell.action(), m_target); //! is this right?
		} else {
			//
			// Selection has target and action, so send it.
			//
			return sendActionTo(selcell.action(), selcell.target()); //! is this right?
		}
	}
	
	/**
	 * Iterates through all cells if toAllCells is true or selected cells if
	 * toAllCells is false, calling aSelector on anObject for each cell
	 * passing the current cell as the only parameter.
	 *
	 * The return type for anObject::aSelector() must be boolean. When 
	 * anObject::aSelector returns true, iteration continues to the next cell.
	 * When it returns false, the iteration halts immediately.
	 */
	public function sendActionToForAllCells(aSelector:String, anObject:Object,
			toAllCells:Boolean):Void {
		var cells:NSArray = toAllCells ? cells() : selectedCells();
		var app:NSApplication = NSApplication.sharedApplication();
		var itr:NSEnumerator = cells.objectEnumerator();
		var cell:NSCell;
		var cont:Boolean = true;
		
		while ((null != (cell = NSCell(itr.nextObject()))) && cont) {
			cont = app.sendActionToFrom(aSelector, anObject, cell);
		}
	}
	
	/**
	 * This method does the following in the specified order, until
	 * success is reached:
	 *
	 * 	1. If doubleAction is set, a message will be sent to this control's
	 *	   target.
	 *  2. If the selected cell has an action set, that message will be sent
	 *	   to the cell's target.
	 *	3. A single-click action will be sent to this control's target.
	 *		
	 *
	 * If the selected cell is disabled, no action is sent. 
	 *
	 * This method should not be called directly (from the outside of this 
	 * object), but can be overridden by subclasses for specialized 
	 * behaviour.
	 */
	public function sendDoubleAction():Boolean {
		// Step 1.
		if (m_doubleAction != null) {
			return sendActionTo(m_doubleAction, m_target);
		}
			
		// Step 2.
		var selcell:NSCell = selectedCell();
		if (selcell != null) {
			if (!selcell.isEnabled()) {
				return false;
			}
				
			if (selcell.action() != undefined) {
				return sendActionTo(selcell.action(), selcell.target()); //! is this right?
			}
		}
		
		// Step 3.
		//! TODO How do I do this?
		
		return false;
	}
	
	/**
	 * @see org.actionstep.NSControl#setAction
	 */
	public function setAction(aSelector:String):Void {
		m_action = aSelector;
	}
	
	/**
	 * Makes aSelector the action sent to the target of the receiver when the
	 * user double-clicks a cell. A double-click action is always sent after
	 * the appropriate single-click action, which is the cell’s single-click
	 * action, if it has one, or the receiver single-click action, otherwise.
	 * If aSelector is a non-NULL selector, this method also sets the
	 * ignoresMultiClick flag to true; otherwise, it leaves the flag unchanged.
	 * 
	 * If an NSMatrix has no double-click action set, then by default a double
	 * click is treated as a single click.
	 *
	 * For the method to have any effect, the receiver’s action and target must
	 * be set to the class in which the selector is declared.
	 */
	public function setDoubleAction(aSelector:String):Void {
		m_doubleAction = aSelector;
	}
	
	/**
	 * @see org.actionstep.NSControl#setTarget
	 */
	public function setTarget(target:Object):Void {
		m_target = target;
	}
	
	//******************************************************
	//*         Handling event and action messages
	//******************************************************
	
	/**
	 * Returns the flags in effect at the mouse-down event that started the 
	 * current tracking session. NSMatrix’s mouseDown: method obtains these
	 * flags by sending a modifierFlags message to the event passed into
	 * mouseDown:. Use this method if you want to access these flags. This
	 * method is valid only during tracking; it isn’t useful if the target of
	 * the receiver initiates another tracking loop as part of its action
	 * method (as a cell that pops up a pop-up list does, for example).	
	 */
	public function mouseDownFlags():Number {
		return m_mouseDownFlags;
	}
	
	/**
	 * If there’s a cell in the receiver that has a key equivalent equal to the 
	 * character in <code>theEvent.charactersIgnoringModifiers</code> (taking 
	 * into account any key modifier flags) and that cell is enabled, that cell 
	 * is made to react as if the user had clicked it: by highlighting, changing
	 * its state as appropriate, sending its action if it has one, and then 
	 * unhighlighting. Returns <code>true</code> if a cell in the receiver 
	 * responds to the key equivalent in theEvent, <code>no</code> if no cell 
	 * responds.
	 */
	public function performKeyEquivalent(theEvent:NSEvent):Boolean {
		var itr:NSEnumerator = cells.objectEnumerator();
		var cell:NSCell;
		
		while (null != (cell = NSCell(itr.nextObject()))) {
			var ke:String = cell.keyEquivalent();
			
			if (ke != "" && theEvent.charactersIgnoringModifiers == ke) {
				cell.performClick();
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Returns <code>false</code> if the selection mode of the receiver is 
	 * <code>NSListModeMatrix</code>, <code>true</code> if the receiver is in 
	 * any other selection mode. The receiver does not accept first mouse in 
	 * <code>NSListModeMatrix</code> to prevent the loss of multiple selections.
	 * The NSEvent parameter, <code>theEvent</code>, is ignored.
	 */
	public function acceptsFirstMouse(theEvent:NSEvent):Boolean {
		return m_mode != NSMatrixMode.NSListModeMatrix;
	}
	
	/**
	 * The matrix always wants to be first responder.
	 */
	public function acceptsFirstResponder():Boolean {
		return true;
	}
	
	public function becomeFirstResponder():Boolean {
  		if (m_dottedRow != -1 && m_dottedCol != -1) {
  			setNeedsDisplay(true);
  			//! setNeedsDisplayInRect
  		}
  			
		return true;
	}
	
	public function resignFirstResponder():Boolean {
		if (m_dottedRow != -1 && m_dottedCol != -1) {
  			setNeedsDisplay(true);
  			//! setNeedsDisplayInRect
		}
  			
		return true;
	}
  	
	/**
	 * @see org.actionstep.NSControl#cellTrackingRect
	 */
	private function cellTrackingRect():NSRect {

		
		return m_bounds;
	}
			
	/**
	 * Responds to theEvent mouse-down event. A mouse-down event in a text 
	 * cell initiates editing mode. A double click in any cell type except 
	 * a text cell sends the double-click action of the receiver (if there 
	 * is one) in addition to the single-click action.
	 *
	 * Your code should never invoke this method, but you may override it 
	 * to implement different mouse tracking than NSMatrix does. The 
	 * response of the receiver depends on its selection mode, as explained 
	 * in the class description.
	 */
	public function mouseDown(theEvent:NSEvent):Void {		
		//
		// Ignore mouse down
		//
		if (m_numRows == 0 || m_numCols == 0) {
			super.mouseDown(theEvent);
			return;
		}
		
		//
		// Handle clicks
		//
		if (theEvent.clickCount > 2) {
			return;
		}
		if (theEvent.clickCount == 2 && !m_ignoresMultiClick) {
			sendDoubleAction();
			return;
		}
				
		//
		// Record flags (used by cell tracking callbacks)
		//
		m_mouseDownFlags = theEvent.modifierFlags;

		//
		// Set up tracking data
		//
		m_trackingData = { 
			mouseDown: true, 
			eventMask: 
				NSEvent.NSLeftMouseDownMask | 
				NSEvent.NSLeftMouseUpMask | 
				NSEvent.NSLeftMouseDraggedMask | 
				NSEvent.NSMouseMovedMask | 
				NSEvent.NSOtherMouseDraggedMask | 
				NSEvent.NSRightMouseDraggedMask,
			mouseUp: false, 
			complete: false,
			bounds: cellTrackingRect()};
    		
		var pt:NSPoint = convertPointFromView(theEvent.mouseLocation);
		m_isselecting = false;
		switch (m_mode) {				
			case NSMatrixMode.NSTrackModeMatrix:
				mouseDownTrackMode(theEvent);
				break;
								
			case NSMatrixMode.NSListModeMatrix:
				m_isselecting = true;
    			mouseDownListMode(theEvent);
				break;
				
			case NSMatrixMode.NSHighlightModeMatrix:
				mouseDownRadioMode(theEvent);
				break;
				
			case NSMatrixMode.NSRadioModeMatrix:
				mouseDownRadioMode(theEvent);
				break;
			
		}
	}
	
	//******************************************************
	//*              List mode mouse tracking
	//******************************************************
	
	/**
	 * 
	 */
	private function mouseTrackingCallbackListMode(theEvent:NSEvent):Void {		
		if (theEvent.type == NSEvent.NSLeftMouseUp) { // send action, stop tracking
			m_cell.setTrackingCallbackSelector(null, null);
			this.sendAction();
		} else { // continue tracking
			mouseDownListMode(theEvent);
		}
	}
	
	//
	// Variables used by cell tracking
	//
	private var m_isselecting:Boolean;
	
	/**
	 * Handles NSListModeMatrix mousedown logic.
	 */
	private function mouseDownListMode(theEvent:NSEvent):Void {
				
		var pt:NSPoint; // The location in the frame
		var cellLoc:Object; // The location of the cell that is currently being hovered over
		var mouseCell:NSCell; // The cell that is currently being hovered over
		var eventMask:Number = 
			NSEvent.NSLeftMouseUpMask | 
			NSEvent.NSLeftMouseDownMask | 
			NSEvent.NSMouseMovedMask | 
			NSEvent.NSLeftMouseDraggedMask |
			NSEvent.NSPeriodicMask;

		pt = convertPointFromView(theEvent.mouseLocation);
		cellLoc = this.getRowColumnForPoint(theEvent.mouseLocation);
		
		//
		// If we're currently over a cell...
		//		
		if (cellLoc != null) {
			var mouseIdx:Number = indexFromRowColumn(cellLoc.row, cellLoc.column);
			mouseCell = NSCell(m_cells.objectAtIndex(mouseIdx));
						
			//
			// Autoscroll if necessary
			//
			if (m_autoscroll) {
				var scrollRect:NSRect = cellFrameAtRowColumn(cellLoc.row, cellLoc.column);
				scrollRectToVisible(scrollRect);
			}
			
			//
			// If a new, enabled cell is under the mouse
			//
			if (mouseCell != m_trackingData.lastCell && mouseCell.isEnabled()) {
				if (m_trackingData.lastCell == null) {
					var altDown:Boolean = (m_mouseDownFlags & NSEvent.NSAlternateKeyMask) != 0;
					var shiftDown:Boolean = (m_mouseDownFlags & NSEvent.NSShiftKeyMask) != 0;
										
					//
					// When a new cell is pressed, and the Alt and Shift keys
					// are up, we deselect all cells.
					//
					if (!altDown && !shiftDown) {
						this.deselectAllCells();
					}
					
					//
					// The clicked cell is the anchor of the selection, unless
					// alt is down.
					//
					if (!altDown) {
						m_trackingData.anchor = mouseIdx;
					} else {
						if (m_dottedCol == -1) {
							m_trackingData.anchor = 0; // = indexFromRowColumn(0, 0);
						} else {
							m_trackingData.anchor = indexFromRowColumn(m_dottedRow, m_dottedCol);
						}
					}
					
					//
					// With the shift key pressed, clicking on a selected cell
					// deselects it (and inverts the selection on mouse dragging).
					//
					if (shiftDown) {
						m_isselecting = mouseCell.state() == NSCell.NSOffState;
					} else {
						m_isselecting = true;
					}
					
					m_trackingData.lastIndex = mouseIdx;
				}
								
				this.setSelectionFromToAnchorHighlight(
					mouseIdx,
					m_trackingData.lastIndex, 
					m_trackingData.anchor,
					m_isselecting);
					
				m_trackingData.lastIndex = mouseIdx;
				m_trackingData.lastCell = mouseCell;
			}
		}
		
		NSApplication.sharedApplication().callObjectSelectorWithNextEventMatchingMaskDequeue(this, 
			"mouseTrackingCallbackListMode", m_trackingData.eventMask, true);
	}
	
	//******************************************************
	//*              Radio mode mouse tracking
	//******************************************************
	
	/**
	 * Handles radio mode mousedown logic.
	 */
	private function mouseDownRadioMode(theEvent:NSEvent):Void {				
		if (theEvent.type == NSEvent.NSLeftMouseUp) {
			return;
		}
		
		var scrolling:Boolean = false;
		var frame:NSRect;
		var cell:NSCell;
		var highlight:NSCell;
		var firstTime:Boolean = false;
		var pt:NSPoint = theEvent.mouseLocation;
		var loc:Object = getRowColumnForPoint(pt);
		
		if (m_trackingData.originalSelectedCell == null) {
			m_trackingData.originalSelectedCell = selectedCell();
		}
		
		if (loc == null) {
			scrolling = false;
		}
		
		if (loc != null) {
			cell = cellAtRowColumn(loc.row, loc.column);
			
			//
			// Deal with the affected cell
			//
			if (m_trackingData.affectedCell == null) {
				m_trackingData.affectedCell = cell;
				frame = m_trackingData.affectedCellFrame 
					= cellFrameAtRowColumn(loc.row, loc.column);
				m_trackingData.affectedCellCol = loc.column;
				m_trackingData.affectedCellRow = loc.row;
				firstTime = true;
			}
			else if (m_trackingData.affectedCell != cell) {
				//return;
			} else {
				frame = m_trackingData.affectedCellFrame;
			}
			
			//
			// Autoscroll if necessary
			//						
			if (m_autoscroll) {
				scrolling = scrollRectToVisible(frame);
			}

			//
			// If the cell is enabled, select it.
			//
			if (cell.isEnabled()) {
				//
				// Select cell and set state
				//
				if (firstTime) {
					var oldState:Number = cell.state();	
					selectCellAtRowColumn(loc.row, loc.column);
					if (m_mode == NSMatrixMode.NSRadioModeMatrix 
							&& !m_allowsEmptySel) {
						cell.setState(NSCell.NSOffState);
					} else {
						trace(oldState);
						cell.setState(oldState);
					}
					
					//
					// Highlight
					//
					highlightCellAtRowColumn(true, loc.row, loc.column);
					setNeedsDisplay(true);
				}
				
				//
				// Begin tracking the mouse
				//
				if(theEvent.view == this && frame.pointInRect(
						convertPointFromView(theEvent.mouseLocation, null))) {
					cell.setTrackingCallbackSelector(this, 
						"cellTrackingCallbackRadioMode");
					cell.trackMouseInRectOfViewUntilMouseUp(theEvent, 
						frame, 
						this, 
						cell.getClass().prefersTrackingUntilMouseUp());
					
					return;
				}
			}
		}
		
		NSApplication.sharedApplication().callObjectSelectorWithNextEventMatchingMaskDequeue(
			this, "mouseTrackingCallbackRadioMode", 
			m_trackingData.eventMask, true);
	}
	
	private function cellTrackingCallbackRadioMode(mouseUp:Boolean):Void {		
		if (mouseUp) { // stop tracking
			m_trackingData.affectedCell.setTrackingCallbackSelector(null, null);
			highlightCellAtRowColumn(false, m_trackingData.affectedCellRow,
				m_trackingData.affectedCellCol);
			sendAction();
			setNeedsDisplay(true);
		} else { // continue tracking
			NSApplication.sharedApplication().callObjectSelectorWithNextEventMatchingMaskDequeue(
				this, "mouseDownRadioMode", m_trackingData.eventMask, true);
		}
	}
	
	private function mouseTrackingCallbackRadioMode(theEvent:NSEvent):Void {
		if (theEvent.type == NSEvent.NSLeftMouseUp) {
			//
			// Clean up. No selection change.
			//
		    m_trackingData.affectedCell.setTrackingCallbackSelector(null, null);
		    m_trackingData.affectedCell.mouseTrackingCallback(theEvent);
		    if (!m_allowsEmptySel) {
		    	selectCell(m_trackingData.originalSelectedCell);
		    }
			sendAction();
			setNeedsDisplay(true);
		    return;
		}
		if(theEvent.view == this && m_trackingData.affectedCellFrame.pointInRect(
				convertPointFromView(theEvent.mouseLocation, null))) {
			//
			// Start cell tracking again.
			//
			highlightCellAtRowColumn(true, m_trackingData.affectedCellRow,
				m_trackingData.affectedCellCol);
			setNeedsDisplay(true);
			m_trackingData.affectedCell.trackMouseInRectOfViewUntilMouseUp(
				theEvent, 
				m_trackingData.affectedCellFrame,
				this, 
				m_cell.getClass().prefersTrackingUntilMouseUp());
			return;
		} else {
			highlightCellAtRowColumn(false, m_trackingData.affectedCellRow,
				m_trackingData.affectedCellCol);
			setNeedsDisplay(true);
		}
		//
		// Continue calling this method until something happens.
		//
		m_app.callObjectSelectorWithNextEventMatchingMaskDequeue(this, 
			"mouseTrackingCallbackRadioMode", m_trackingData.eventMask, true);
	}
	
	//******************************************************
	//*              Track mode mouse tracking
	//******************************************************
	
	/**
	 * Handles track mode mousedown logic.
	 */
	private function mouseDownTrackMode(theEvent:NSEvent):Void {
		var scrolling:Boolean = false;
		var frame:NSRect;
		var cell:NSCell;
		var highlight:NSCell;
		var pt:NSPoint = theEvent.mouseLocation;
		var loc:Object = getRowColumnForPoint(pt);
		
		if (loc == null) {
			scrolling = false;
		}
		
		if (loc != null) {
			cell = cellAtRowColumn(loc.row, loc.column);
			
			//
			// Make sure we're not doing more work than we have to be
			//
			if (cell == m_trackingData.lastCell) {
				return;
			}
			
			m_trackingData.lastCell = m_trackingData.currentCell;
			m_trackingData.currentCell = cell;
			
			//
			// Get the frame
			//
			frame = cellFrameAtRowColumn(loc.row, loc.column);
			
			if (m_autoscroll) {
				scrolling = scrollRectToVisible(frame);
			}

			m_trackingData.currentCellFrame = frame;
			
			//
			// If the cell is enabled, select it.
			//
			if (cell.isEnabled()) {
				var oldState:Number = m_trackingData.oldState = cell.state();
				selectCellAtRowColumn(loc.row, loc.column);
				cell.setState(oldState);
												
				//
				// Begin tracking the mouse
				//
				if(theEvent.view == this && frame.pointInRect(
						convertPointFromView(theEvent.mouseLocation, null))) {
					cell.setTrackingCallbackSelector(this, 
						"cellTrackingCallbackTrackMode");
					cell.trackMouseInRectOfViewUntilMouseUp(theEvent, 
						frame, 
						this, 
						cell.getClass().prefersTrackingUntilMouseUp());
				
					return;
				}
			}
		}

		NSApplication.sharedApplication().callObjectSelectorWithNextEventMatchingMaskDequeue(this, 
			"mouseTrackingCallbackTrackMode", m_trackingData.eventMask, true);
	}
	
	private function cellTrackingCallbackTrackMode(mouseUp:Boolean):Void {			
		if (mouseUp) { // stop tracking
			m_trackingData.currentCell.setState(NSCell.NSOffState);
			m_trackingData.currentCell.setTrackingCallbackSelector(null, null);
			setNeedsDisplay(true);
			sendAction();
		} else {
			m_trackingData.currentCell.setTrackingCallbackSelector(null, null);
			m_app.callObjectSelectorWithNextEventMatchingMaskDequeue(this, 
				"mouseTrackingCallbackTrackMode", m_trackingData.eventMask, true);
		}
	}
	
	private function mouseTrackingCallbackTrackMode(theEvent:NSEvent):Void {		
		if (theEvent.type == NSEvent.NSLeftMouseUp) {
			m_trackingData.currentCell.setTrackingCallbackSelector(null, null);
			setNeedsDisplay(true);
			return;
		}
		
		if (m_trackingData.currentCell.state() != m_trackingData.oldState) {
			setNeedsDisplay(true);
		}
		if(theEvent.view == this && m_bounds.pointInRect(
				convertPointFromView(theEvent.mouseLocation, null))) {
			m_app.callObjectSelectorWithNextEventMatchingMaskDequeue(this, 
				"mouseDownTrackMode", m_trackingData.eventMask, true);

			return;
		}
		//
		// Continue calling this method until something happens.
		//
		m_app.callObjectSelectorWithNextEventMatchingMaskDequeue(this, 
			"mouseTrackingCallbackTrackMode", m_trackingData.eventMask, true);
	}
	
	//******************************************************
	//*                 Keyboard events
	//******************************************************
		
	/**
	 * @see org.actionstep.NSResponder#keyDown
	 */
	public function keyDown(event:NSEvent):Void {
		var chars:String = event.characters;
		var mods:Number = event.modifierFlags;
		var char:Number = event.keyCode;
				
		switch (char) {
			//
			// Select text
			//
			case NSCarriageReturnCharacter:
			case NSNewlineCharacter:
			case NSEnterCharacter:
				selectText(this);
				break;
				
			//
			// Perform an action based on mode.
			//
			// NSTrackModeMatrix or NSHighlightModeMatrix:
			//		Set the current cell to the next state.
			//
			// NSListModeMatrix:
			//		Deselect all cells
			//
			// NSRadioModeMatrix:
			//		Select the focused cell
			//
			case 32: //! This is a space, it should be a constant somewhere
				
				if (m_dottedRow != -1 && m_dottedCol != -1) {
					if (mods & NSEvent.NSAlternateKeyMask) {
						//_altModifier = character;
					} else {
						var cell:NSCell;
						switch (m_mode) {
							case NSMatrixMode.NSTrackModeMatrix:
							case NSMatrixMode.NSHighlightModeMatrix:
								cell = cellAtRowColumn(m_dottedRow, m_dottedCol);
								cell.setNextState();
								//! setNeedsDisplayInRect();
								setNeedsDisplay(true);
								
								break;
								
							case NSMatrixMode.NSListModeMatrix:
								if (!(mods & NSEvent.NSShiftKeyMask)) {
									deselectAllCells();
								}
								
								break;
								
							case NSMatrixMode.NSRadioModeMatrix:
								selectCellAtRowColumn(m_dottedRow, m_dottedCol);
								
								break;
								
						}
						
						displayIfNeeded();
						performClick(this);
					}
					
					return;
				}
				
				break;
				
			//
			// Move focus
			//
			case NSLeftArrowFunctionKey:
			case NSRightArrowFunctionKey:
				if (m_numCols <= 1) {
					break;
				}
					
			case NSUpArrowFunctionKey:
			case NSDownArrowFunctionKey:
				
				if (mods & NSEvent.NSShiftKeyMask) {
					//! TODO implement
				}
				else if (mods & NSEvent.NSAlternateKeyMask) {
					//! TODO implement
				} else {
					var didMove:Boolean = false;
					switch (char) {
						case NSLeftArrowFunctionKey:
							didMove = moveLeft(this);
							break;
							
						case NSRightArrowFunctionKey:
							didMove = moveRight(this);
							break;
							
						case NSUpArrowFunctionKey:
							didMove = moveUp(this);
							break;
							
						case NSDownArrowFunctionKey:
							didMove = moveDown(this);
							break;
					}
					
					if (didMove) {
						sendAction();
					} else {
						super.keyDown(event);
					}
				}
				
				return;
		
			//
			// Handle tabbing
			//
			case NSTabCharacter:
				if (m_useTabKey) {
					if (mods & NSEvent.NSShiftKeyMask) { // go backwards
						if (selectPreviousSelectableCellAfterRowColumn(
								m_selCell_row, m_selCell_column)) {
							return; // MUST have this (to indicate the key was handled)
						}
					} else {
						if (selectNextSelectableCellAfterRowColumn(
								m_selCell_row, m_selCell_column)) {
							return; // MUST have this (to indicate the key was handled)
						}
					}	
				}
				
				break;
				
			default:
				break;
				
		}
		
		super.keyDown(event);
	}
	
	//******************************************************
	//*               Managing the cursor
	//******************************************************
	
	//! TODO public function resetCursorRects
	
	//******************************************************															 
	//*                 Moving Selection
	//******************************************************
	
	/**
	 * Moves the current focus up.
	 */
	public function moveUp(sender:Object):Boolean {
		return moveFocusOrSel(NSUpArrowFunctionKey);
	}

	/**
	 * Moves the current focus down.
	 */	
	public function moveDown(sender:Object):Boolean {
		return moveFocusOrSel(NSDownArrowFunctionKey);
	}
	
	/**
	 * Moves the current focus left.
	 */
	public function moveLeft(sender:Object):Boolean {
		return moveFocusOrSel(NSLeftArrowFunctionKey);
	}
	
	/**
	 * Moves the current focus right.
	 */
	public function moveRight(sender:Object):Boolean {
		return moveFocusOrSel(NSRightArrowFunctionKey);
	}	
	
	//******************************************************															 
	//*             Overridden view methods
	//******************************************************
	
	/**
	 * Draws the thing.
	 */
	public function drawRect(rect:NSRect):Void {
		m_graphics.clear();		
		
		drawBackground(rect);
			
		//
		// Draw the cells
		//
		for (var i:Number = 0; i < m_numRows; i++) {
			for (var j:Number = 0; j < m_numCols; j++) {
				drawCellAtRowColumn(i, j);
			}
		}
	}
	
	/**
	 * Draws the background of the matrix.
	 * 
	 * This method can be overridden for more advanced background drawing.
	 */
	private function drawBackground(rect:NSRect):Void {
		if (m_drawsBg) {
			ASTheme.current().drawFillWithRectColorInView(rect, m_bgColor, this);
		}
	}
	
	/**
	 * Re-lays out cells if necessary.
	 */
	public function setFrame(frame:NSRect):Void {
		super.setFrame(frame);
	}
	
	/**
	 * Re-lays out cells if necessary.
	 */	
	public function setFrameSize(size:NSSize):Void {
		super.setFrameSize(size);
	}
	
	private function frameDidChange(oldFrame:NSRect):Void {
		if (oldFrame == null || oldFrame.origin.isEqual(m_frame.origin)
				|| oldFrame.size.isEqual(m_frame.size)) {
			return;
		}
		
		_rebuildLayoutAfterResizing();
	}
	
	//******************************************************															 
	//*	                Private Methods
	//******************************************************
	
	/**
	 * Renew rows and columns.	
	 *
	 * @param rows 		The new number of rows in the matrix.
	 * @param columns 	The new number of columns in the matrix.
	 * @param rowSpace	
	 * @param colSpace	
	 */
	private function renewRowsColumnsRowSpaceColSpace(
		rows:Number, columns:Number, rowSpace:Number, colSpace:Number):Void
	{			
		var oldMaxC:Number, oldMaxR:Number;
  		var i:Number, j:Number;
		
		//
  		// Check for illegal arguments (negative column or row).
  		//  
 		if (rows < 0)
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSRangeException",
				"NSMatrix::renewRowsColumnsRowSpaceColSpace - " 
				+ rows + 
				" was specified as the row parameter. Negative indices are " +
				"not allowed.");
			trace(e);
			throw e;
		}
		
		if (columns < 0)
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSRangeException",
				"NSMatrix::renewRowsColumnsRowSpaceColSpace - " 
				+ columns + 
				" was specified as the column parameter. Negative indices are " +
				"not allowed.");
			trace(e);
			throw e;
		}
		
		//
		// Modify array size
		//
		if (columns > m_numCols)
		{
			for (i = m_numCols; i < columns; i++)
			{
				for (j = 0; j < m_numRows; j++)
				{
					m_cells.insertObjectAtIndex(null, i + (i + 1) * j);
				}
			}
		}
		
		//
		// Set matrix bounds
		//
		oldMaxC = m_maxCols;
		m_numCols = columns;
		if (columns > m_maxCols)
			m_maxCols = columns;
		
		oldMaxR = m_maxRows;
		m_numRows = rows;
		if (rows > m_maxRows)
			m_maxRows = rows;
					
		//
		// Resize
		//
		if (columns > oldMaxC)
		{
			var end:Number = columns - 1;
			
			// Allocate the new columns and fill them
			for (i = 0; i < oldMaxR; i++)
			{		
				for (j = oldMaxC; j < columns; j++)
				{
					assignCell(null, i, j, false);
					
					if (j == end && colSpace > 0)
					{
						colSpace--;
					}
					else
					{
						assignCell(makeCell(), i, j, false);
					}
				}
			}
		}
				
		if (rows > oldMaxR)
		{
			//trace("rows > oldMaxR");
			var end:Number = rows - 1;
		
			// Allocate the new rows and fill them
			for (i = oldMaxR; i < rows; i++)
			{		
				if (i == end)
				{
					for (j = 0; j < m_maxCols; j++)
					{
						assignCell(null, i, j, false);
						
						if (rowSpace > 0)
						{
							rowSpace--;
						}
						else
						{
							assignCell(makeCell(), i, j, false);
						}
					}
				}
				else
				{
					for (j = 0; j < m_maxCols; j++)
					{
						assignCell(null, i, j, false);
						assignCell(makeCell(), i, j, false);
					}
				}
			}
		}
		
		/*
		//
 		// Expand columns
		//
		if (columns > m_numCols) // Only expand if necessary
		{						
			//
			// Loop through the rows, adding the column to each.
			//
			for (var i:Number = m_numRows; i > 0; i--)
			{	
				var numNewCols:Number = columns - m_numCols;
				
				var insertPoint:Number = i * m_numCols;

				while (numNewCols-- > 0)
					m_cells.insertObjectAtIndex(makeCell(), insertPoint);
			}
		}
		else if (columns < m_numCols)
		{
			var numColsToRemove:Number =  m_numCols - columns;
			
			//
			// Loop through the rows, removing the column from each.
			//
			for (var i:Number = m_numRows; i > 0; i--)
			{
				var removalPoint:Number = i * m_numCols;

				while (numColsToRemove-- > 0)
				{
					var cell:NSCell = NSCell(m_cells.objectAtIndex(removalPoint));
					cell.release();
					m_cells.removeObjectAtIndex(removalPoint);
				}
			}
		}
		
		m_numCols = columns;
		
		//
		// Expand rows
		//
		if (rows > m_numRows) // Only expand if necessary.
		{
			var numCellsToInsert:Number = (rows - m_numRows) * m_numCols;
			
			while (numCellsToInsert-- > 0)
				m_cells.addObject(makeCell());
		}
		else if (rows < m_numRows)
		{
			var numCellsToRemove:Number = (m_numRows - rows) * m_numCols;
			var removalPoint:Number = m_numCols * m_numRows;
			
			while (numCellsToRemove-- > 0)
			{
				var cell:NSCell = NSCell(m_cells.objectAtIndex(removalPoint));

				cell.release();
				m_cells.removeObjectAtIndex(removalPoint);
			}
		}

		m_numRows = rows;
		*/
		
		deselectAllCells();
	}
	
	private function _rebuildLayoutAfterResizing():Void {
		if (m_autosizeCells) {
			// Keep the intercell as it is, and adjust the cell size to fit.
			if (m_numRows > 1) {
				m_cellSize.height = m_frame.size.height - ((m_numRows - 1) * m_cellSpacing.height);
				m_cellSize.height /= m_numRows;
				if (m_cellSize.height < 0) {
					m_cellSize.height = 0;
				}
			} else {
				m_cellSize.height = m_frame.size.height;
			}
			
			if (m_numCols > 1) {
				m_cellSize.width = m_frame.size.width - ((m_numCols - 1) * m_cellSpacing.width);
				m_cellSize.width /= m_numCols;
				if (m_cellSize.width < 0) {
					m_cellSize.width = 0;
				}
			} else {
				m_cellSize.width = m_frame.size.width;
			}
		} else { // !autosizesCells
			// Keep the cell size as it is, and adjust the intercell to fit.
			if (m_numRows > 1) {
				m_cellSpacing.height = m_frame.size.height - (m_numRows * m_cellSize.height);
				m_cellSpacing.height = m_cellSpacing.height / (m_numRows - 1);
				if (m_cellSpacing.height < 0) {
					m_cellSpacing.height = 0;
				}
			} else {
				m_cellSpacing.height = 0;
			}
			
			if (m_numCols > 1) {
				m_cellSpacing.width = m_frame.size.width - (m_numCols * m_cellSize.width);
				m_cellSpacing.width = m_cellSpacing.width / (m_numCols - 1);
				if (m_cellSpacing.width < 0) {
					m_cellSpacing.width = 0;
				}
			} else {
				m_cellSpacing.width = 0;
			}
		}
	}

	/**
	 * Clears the current selection when in NSRadioModeMatrix.
	 */
	private function clearCurrentRadioSelection(clearVars:Boolean):Void
	{
		if (m_mode != NSMatrixMode.NSRadioModeMatrix || m_cell == null)
			return;
			
		if (clearVars == undefined)
			clearVars = true;
			
		m_sel.removeAllObjects();				
		m_cell.setState(NSCell.NSOffState);
		//! setNeedsDisplayInRect
		drawCellAtRowColumn(m_selCell_row, m_selCell_column);
		
		if (!clearVars)
			return;
		
		m_cell = null;
		m_selCell_row = m_selCell_column = -1;
	}
	
	/**
	 * Replaces the cell that previously occupied row and column with
	 * newCell. This method releases the old cell.
	 */
	private function assignCell(newCell:NSCell, row:Number, column:Number, release:Boolean):Void
	{				
		if (release == undefined)
			release = true;
			
		var idx:Number = indexFromRowColumn(row, column);
		var oldCell:NSCell = NSCell(m_cells.objectAtIndex(idx));
			
		if (release)
			oldCell.release(); // Release the old cell.
			
		m_cells.replaceObjectAtIndexWithObject(idx, newCell);
	}
		
	/**
	 * Gets the range of cells that are currently visible to the user.
	 */
	private function getVisibleRanges():Object
	{
		//! add code to account for scrolling
		return {rows: new NSRange(0, m_numRows), columns: new NSRange(0, m_numCols)};
	}
	
	/**
	 * Updates selection after a column has been removed.
	 *
	 * This method will decrement all selections with columns greater than
	 * the column that has been removed, and will remove selections that existed
	 * within the column.
	 *
	 * If there are no selections as a result of the removal, and allowEmptySelection
	 * is false, (0,0) will be selected.
	 */
	private function updateSelWithColumnRemoved(column:Number):Void
	{		
		var loc:Object;
		var sel:Array = m_sel.internalList();
		
		//
		// Loop through backwards.
		//
		for (var i:Number = sel.length - 1; i >= 0; i--)
		{
			loc = rowColumnFromIndex(sel[i]);
					
			if (loc.column == column)
			{
				cell.setHighlighted(false);
				sel.splice(i, 1);
			}
			else if (loc.column > column)
			{
				sel[i]--;
			}
		}
				
		//
		// If there is no more selection, and we don't allow no selection,
		// select 0, 0.
		//
		if (sel.length == 0 && !m_allowsEmptySel)
		{
			selectCellAtRowColumn(0, 0);
		}
	}
	
	/**
	 * Updates selection after a row has been removed.
	 *
	 * This method will decrement all selections with rows greater than
	 * the row that has been removed, and will remove selections that existed
	 * within the row.
	 *
	 * If there are no selections as a result of the removal, and allowEmptySelection
	 * is false, (0,0) will be selected.
	 */
	private function updateSelWithRowRemoved(row:Number):Void
	{
		var loc:Object;
		var sel:Array = m_sel.internalList();
		
		//
		// Loop through backwards.
		//
		for (var i:Number = sel.length - 1; i >= 0; i--)
		{
			loc = rowColumnFromIndex(sel[i]);
			
			if (loc.row == row)
			{
				cell.setHighlighted(false);
				sel.splice(i, 1); // remove selection from array
			}
			else if (loc.row > row)
			{
				//
				// decrement the selection index if necessary
				//
				sel[i] = sel[i] - m_numCols;
			}
		}
		
		//
		// If there is no more selection, and we don't allow no selection,
		// select 0, 0.
		//
		if (sel.length == 0 && !m_allowsEmptySel)
		{
			selectCellAtRowColumn(0, 0);
		}
	}
	
	/**
	 * Updates the selection array when a column is added. All selections in columns
	 * that are greater than the column that has been added are incremented.
	 */	
	private function updateSelWithColumnAdded(column:Number):Void
	{
		var loc:Object;
		var sel:Array = m_sel.internalList();
		var len:Number = sel.length;
		
		for (var i:Number = 1; i < len; i++)
		{
			loc = rowColumnFromIndex(sel[i]);
			
			if (loc.column >= column)
			{
				sel[i]++;
			}
		}
	}
	
	/**
	 * Updates the selection array when a row is added. All selections in rows
	 * that are greater than the row that has been added are incremented.
	 */
	private function updateSelWithRowAdded(row:Number):Void
	{
		var loc:Object;
		var sel:Array = m_sel.internalList();
		var len:Number = sel.length;
		
		for (var i:Number = 1; i < len; i++)
		{
			loc = rowColumnFromIndex(sel[i]);
			
			if (loc.row >= row)
			{
				sel[i] += m_numCols;
			}
		}		
	}
	
	/**
	 * Returns the lowest, rightmost selected cell, with row taking precedence.
	 */
	private function getLowestRightmostSelectionLocation():Number
	{
		var cellItr:NSEnumerator = m_sel.objectEnumerator();
		var selLoc:Object;
		var resLoc:Object;
		var resIdx:Number;
		var index:Number;
		
		while (!isNaN (index = Number(cellItr.nextObject())))
		{
			selLoc = rowColumnFromIndex(index);
			
			if (resLoc == null) // Set resLoc to the first item in the list.
			{
				resLoc = selLoc;
				resIdx = index;
				continue;
			}
			
			if (selLoc.row < resLoc.row) // not a candidate
			{
				continue;
			}
			else if (selLoc.row > resLoc.row) // if lower, choose it
			{
				resLoc = selLoc;
				resIdx = index;
			}
			else // == pick farthest to right
			{
				resLoc = resLoc.column > selLoc.column ? resLoc : selLoc;				
				resIdx = indexFromRowColumn(resLoc.row, resLoc.column);
			}
		}
		
		return resIdx;
	}
		
	/**
	 *	Recalculates the cell size.
	 */ 	 
	private function recalcCellSize():Void 	 
	{ 	 
		if (m_numCols > 0 && m_numRows > 0)
		{
			m_cellSize = new NSSize( 	 
				(m_frame.size.width - (m_cellSpacing.width * (m_numCols - 1))) / m_numCols, 	 
				(m_frame.size.height - (m_cellSpacing.height * (m_numRows - 1))) / m_numRows); 	 
		}
	}
            
	/**
	 * <p>Makes a cell based on the prototype instance or the cell class,
	 * depending on the value of m_usingCellInstance.</p>
	 * 
	 * <p>For internal use only.</p>
	 */
	public function makeCell():NSCell {
		var cell:NSCell;
		
		//
		// Build the cell from the existing cell instance, or the cell
		// class, depending on usingCellInstance.
		//
		if (m_usingCellInstance) {
			cell = NSCell(m_prototype.memberwiseClone());
		} else {
			if (m_cellClass != undefined) {
				cell = NSCell(ASUtils.createInstanceOf(m_cellClass));
			} else {
				cell = NSCell(ASUtils.createInstanceOf(NSActionCell));
			}
			
			cell.init();
		}
		
		return cell;
	}
	
	/**
	 * Given a row and column, will return the corresponding index into
	 * the underlying data structure.
	 */         
	private function indexFromRowColumn(row:Number, column:Number):Number {
		return (row * m_numCols) + column;
	}
	
	/**
	 * Given an index, returns an object with row and column properties.
	 */
	private function rowColumnFromIndex(index:Number):Object {
		var ret:Object = new Object();
		
		ret.row = Math.floor(index / m_numCols);
		ret.column = index % m_numCols;
		
		return ret;
	}
	
	/**
	 * Selects the text in the cell aCell if the cell is editable
	 * and selectable.
	 *
	 * Returns true if text is successfully selected, and false otherwise.
	 */
	private function selectTextWithCell(aCell:NSCell):Boolean {
		if (aCell == null) // You can only select a cell that exists
			return false;
			
		//
		// Cell must be editable and selectable.
		//
		if (!aCell.isEditable() && !aCell.isSelectable()) {
			return false;
		}
		
//		aCell.editWithEditorDelegateEvent(ASFieldEditor.instance(), this, null);
		m_editor = ASFieldEditingProtocol(aCell).beginEditingWithDelegate(this);
		
		if (m_editor == null)
			return false;
			
		m_editor.select();
				
		return true;
	}
	
	/**
	 * Selects the next selectable cell after the specified row and column.
	 *
	 * This occurs on a tab press.
	 */
	private function selectNextSelectableCellAfterRowColumn(row:Number, 
		column:Number):Boolean
	{
		var cell:NSCell;
		var j:Number = column + 1; // make sure inner loop starts after column
		
		for (var i:Number = row; i < m_numRows; i++)
		{
			for (; j < m_numCols; j++)
			{
				cell = cellAtRowColumn(i, j);
				
				//
				// Select cell if we can
				//
				if (cell.isEditable() && cell.isEnabled())
				{
					selectCellAtRowColumn(i, j);
					return true;
				}
				
			}
			
			j = 0; // all rows after the first should start at column 0
		}
		
		return false;
	}
	
	/**
	 * Selects the previous selectable cell after the specified row and column.
	 *
	 * This occurs on a shift+tab press.
	 */
	private function selectPreviousSelectableCellAfterRowColumn(row:Number, 
		column:Number):Boolean
	{
		var cell:NSCell;
		var j:Number = column - 1; // make sure inner loop starts before column
		
		for (var i:Number = row; i >= 0; i--)
		{
			for (; j >= 0; j--)
			{
				cell = cellAtRowColumn(i, j);
				
				//
				// Select cell if we can
				//
				if (cell.isEditable() && cell.isEnabled())
				{
					selectCellAtRowColumn(i, j);
					return true;
				}
				
			}
			
			j = m_numCols - 1; // all rows after the first should start at column 0
		}
		
		return false;
	}
	
	/**
	 * Moves the focus or selection (depending on mode) in the direction
	 * specified by direction. direction can be one of the following:
	 *
	 * NSObject.NSUpArrowFunctionKey
	 * NSObject.NSDownArrowFunctionKey
	 * NSObject.NSRightArrowFunctionKey
	 * NSObject.NSLeftArrowFunctionKey
	 */
	private function moveFocusOrSel(direction:Number):Boolean
	{
		var selectCell:Boolean = false;
		var cell:NSCell;
		var i:Number, j:Number, lastDottedRow:Number, lastDottedCol:Number;
		
		//
		// Check for valid input
		//
		if (direction != NSUpArrowFunctionKey &&
			direction != NSDownArrowFunctionKey &&
			direction != NSLeftArrowFunctionKey &&
			direction != NSRightArrowFunctionKey)
		{
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"NSInvalidArgumentException",
				"NSMatrix::moveFocusOrSel - " + direction + " is not a valid direction",
				null);
			trace(e);
			throw e;
		}
		
		//
		// List and radio modes select their cells
		//
		if (m_mode == NSMatrixMode.NSRadioModeMatrix ||
			m_mode == NSMatrixMode.NSListModeMatrix)
		{
			selectCell = true;
		}
		
		if (m_dottedCol == -1 || m_dottedRow == -1) // No focus yet.
		{
			if (direction == NSUpArrowFunctionKey || direction == NSDownArrowFunctionKey)
			{
				//
				// Traverse cells vertically to find one that accepts first responder
				//
				for (i = 0; i < m_numCols; i++)
				{
					for (j = 0; j < m_numRows; j++)
					{
						cell = cellAtRowColumn(j, i);
						
						if (cell.acceptsFirstResponder())
						{
							m_dottedRow = j;
							m_dottedCol = i;
						}
					}
				}
			}
			else // NSLeftArrowFunctionKey || NSRightArrowFunctionKey
			{
				//
				// Traverse cells horizontally to find one that accepts first responder
				//
				for (i = 0; i < m_numRows; i++)
				{
					for (j = 0; j < m_numCols; j++)
					{
						cell = cellAtRowColumn(i, j);
						
						if (cell.acceptsFirstResponder())
						{
							m_dottedRow = i;
							m_dottedCol = j;
						}
					}
				}				
			}
			
			if (m_dottedRow == -1 || m_dottedCol == -1) // no selection found
				return false;
				
			if (selectCell)
			{
				if (m_cell != null)
					deselectAllCells();
				
				selectCellAtRowColumn(m_dottedRow, m_dottedCol);
			}
			else
			{
				//! setNeedsDisplayInRect
				setNeedsDisplay(true);
			}
		}
		else // A selected or focused row already exists
		{
			lastDottedRow = m_dottedRow;
			lastDottedCol = m_dottedCol;
			
			//
			// Move focus based on direction
			//
			switch (direction)
			{
				case NSUpArrowFunctionKey:
					
					if (m_dottedRow <= 0) // can't move up
						return false;
						
					//
					// Move up until a cell can acceptFirstResponder
					//
					for (i = m_dottedRow - 1; i >= 0; i--)
					{
						cell = cellAtRowColumn(i, m_dottedCol);
						
						if (cell.acceptsFirstResponder())
						{
							m_dottedRow = i;
							break;
						}
					}
						
					break;
					
				case NSDownArrowFunctionKey:

					if (m_dottedRow >= m_numRows - 1) // can't move down
						return false;
						
					//
					// Move down until a cell can acceptFirstResponder
					//
					for (i = m_dottedRow + 1; i < m_numRows; i++)
					{
						cell = cellAtRowColumn(i, m_dottedCol);
						
						if (cell.acceptsFirstResponder())
						{
							m_dottedRow = i;
							break;
						}
					}
					
					break;
					
				case NSLeftArrowFunctionKey:
				
					if (m_dottedCol <= 0) // can't move left
						return false;

					//
					// Move left until a cell can acceptFirstResponder
					//
					for (i = m_dottedCol - 1; i >= 0; i--)
					{
						cell = cellAtRowColumn(m_dottedRow, i);
						
						if (cell.acceptsFirstResponder())
						{
							m_dottedCol = i;
							break;
						}
					}
					
					break;
								
				case NSRightArrowFunctionKey:
				
					if (m_dottedCol >= m_numCols - 1) // can't move right
						return false;

					//
					// Move right until a cell can acceptFirstResponder
					//
					for (i = m_dottedCol + 1; i < m_numCols; i++)
					{
						cell = cellAtRowColumn(m_dottedRow, i);
						
						if (cell.acceptsFirstResponder())
						{
							m_dottedCol = i;
							break;
						}
					}
					
					break;
					
			}
			
			//
			// Can't move in direction, so return.
			//
			if ((direction == NSUpArrowFunctionKey || direction == NSDownArrowFunctionKey) &&
				m_dottedRow != i)
			{
				return false;
			}
			
			if ((direction == NSLeftArrowFunctionKey || direction == NSRightArrowFunctionKey) &&
				m_dottedCol != i)
			{
				return false;
			}
			
			//
			// Do selection / drawing
			//
			if (selectCell)
			{
				if (m_mode == NSMatrixMode.NSRadioModeMatrix)
				{
					//! Do something here. Ask Rich.
				}
				else
					deselectAllCells();
					
				selectCellAtRowColumn(m_dottedRow, m_dottedCol);
			}
			else
			{
				//! setNeedsDisplayInRect - for both old and new dotted cols
				setNeedsDisplay(true);
			}
			
			return selectCell;
		}
	}

	/**
	 * Sets the row and column under keyboard control.
	 */
	private function setKeyRowColumn(row:Number, column:Number):Void
	{
		if (m_dottedRow == row && m_dottedCol == column)
			return;
			
		var cell:NSCell = cellAtRowColumn(row, column);
		
		if (cell.acceptsFirstResponder())
		{
			if (m_dottedRow != -1 && m_dottedCol != -1)
			{
				//! setNeedsDisplayInRect(cellFrameAtRowColumn(m_dottedRow, m_dottedCol));
			}
			
			m_dottedRow = row;
			m_dottedCol = column;
			
			//! setNeedsDisplayInRect(cellFrameAtRowColumn(m_dottedRow, m_dottedCol));
			setNeedsDisplay(true);
		}
	}
		
	//******************************************************															 
	//*                Compare methods
	//******************************************************	
	
	private static function __compareRowColumnObject(rc1:Object, rc2:Object):Boolean
	{
		return rc1.row == rc2.row && rc1.column == rc2.column;
	}
	
	/**
	 * Used internally for tooltip data comparison.
	 */
	private static function __toolTipCompare(obj1:Object, obj2:Object):Boolean {
		return obj1.cell == obj2.cell;
	}	
	
	//******************************************************
	//*               NSControl override
	//******************************************************
	
	public static function cellClass():Function 
	{
		if (g_cellClass == undefined) 
		{
			g_cellClass = org.actionstep.NSCell;
		}
		
		return g_cellClass;
	}
}
