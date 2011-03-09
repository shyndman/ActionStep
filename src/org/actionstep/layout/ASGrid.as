/* See LICENSE for copyright and terms of use */

import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;

/**
 * This is a layout container for laying out NSView instances in a grid. With
 * the ASGrid, there is no need to specify exact locations and sizes of
 * NSViews. Instead you specify their relative positions in the grid. Their
 * positions and sizes are then calculated automatically by the table.
 *
 * Notes:
 *  -Before adding a view to the table, it should be resized to its smallest
 *   comfortable size.
 *  -All rows and columns have resizing enabled by default.
 *  -If you wish for a view to expand to fill available space, its
 *   autoResizingMask must be set.
 *
 * To see an example using this class, take a look at
 * <code>org.actionstep.test.ASTestGrid</code>.
 *
 * @author Scott Hyndman
 */
class org.actionstep.layout.ASGrid extends NSView
{
	/**
	 * An array of NSViews. These NSViews are known as jails, and contain the
	 * views intended to be laid out by the table.
	 */
	private var m_jails:Array;

	/**
	 * An array of Booleans specifying if the column should be expanded/reduced
	 * if the table is expanded/reduced.
	 */
	private var m_expandCol:Array;

	/**
	 * An array of Booleans specifying if the row should be expanded/reduced
	 * if the table is expanded/reduced.
	 */
	private var m_expandRow:Array;

	/** The total number of columns with expand set to true. */
	private var m_expandingColNumber:Number;

	/** The total number of rows with expand set to true. */
	private var m_expandingRowNumber:Number;

	/** The dimensions of every column. */
	private var m_colDimension:Array;

	/** The dimensions of every row. */
	private var m_rowDimension:Array;

	/** The origin of every column. */
	private var m_colXOrigin:Array;

	/** The origin of every row. */
	private var m_rowYOrigin:Array;

	/** Minimum dimension each column is allowed to have. */
	private var m_minColDimension:Array;

	/** Minimum dimension each row is allowed to have. */
	private var m_minRowDimension:Array;

	/** The minimum allowed size of the table. */
	private var m_minimumSize:NSSize;

	/**
	 * An array of Boolean values specifying whether or not a prisoner exists
	 * at the specified location.
	 */
	private var m_havePrisoner:Array;
	
	/**
	 * If true, the grid, nor any of the jails, will have a frame mask.
	 */
	private var m_requiresMasks:Boolean;

	//
	// Row/Column Members
	//
	private var m_numRows:Number;
	private var m_numCols:Number;

	//
	// Border info (padding of the table)
	//
	private var m_minXBorder:Number;
	private var m_maxXBorder:Number;
	private var m_minYBorder:Number;
	private var m_maxYBorder:Number;

	//
	// Default margin info
	//
	private var m_defaultMinXMargin:Number;
	private var m_defaultMaxXMargin:Number;
	private var m_defaultMinYMargin:Number;
	private var m_defaultMaxYMargin:Number;

	//******************************************************
	//*                  Construction
	//******************************************************

	/**
	 * Creates a new instance of ASTableLayout
	 */
	public function ASGrid()
	{
		m_minXBorder = m_maxXBorder = m_minYBorder = m_maxYBorder =
			m_defaultMinXMargin = m_defaultMaxXMargin =
			m_defaultMinYMargin = m_defaultMaxYMargin= 0;
		m_requiresMasks = true;
	}

	/**
	 * Initializes a newly created instance with 2 rows and	2 columns.
	 */
	public function init():ASGrid
	{
		return initWithNumberOfRowsNumberOfColumns(2, 2);
	}

	/**
	 * Initializes a newly created instance with <code>rows</code> rows and
	 * <code>cols</code> columns.
	 *
	 * If <code>rows</code> or <code>cols</code> are less than or equal to 0,
	 * then they will default to 2.
	 */
	public function initWithNumberOfRowsNumberOfColumns(rows:Number,
		cols:Number):ASGrid
	{
		super.init();
		super.setAutoresizesSubviews(false);

		//
		// Argument checking
		//
		if (rows <= 0) {
			asWarning("argument rows <= 0");
			rows = 2;
		}
		if (cols <= 0) {
			asWarning("argument cols <= 0");
			cols = 2;
		}

		m_numRows = rows;
		m_numCols = cols;

		//
		// Setup
		//
		m_jails = new Array();
		m_expandRow = new Array();
		m_expandCol = new Array();
		m_rowDimension = new Array();
		m_colDimension = new Array();
		m_rowYOrigin = new Array();
		m_colXOrigin = new Array();
		m_minRowDimension = new Array();
		m_minColDimension = new Array();
		m_havePrisoner = new Array();

		//
		// Provide initial values
		//
		var n:Number = rows * cols;

		for (var i:Number = 0; i < n; i++)
		{
			m_jails[i] = null;
			m_havePrisoner[i] = false;
		}

		for (var i:Number = 0; i < rows; i++)
		{
			m_expandRow[i] = true;
			m_rowDimension[i] = 0;
			m_rowYOrigin[i] = 0;
			m_minRowDimension[i] = 0;
		}

		m_expandingRowNumber = rows;

		for (var i:Number = 0; i < cols; i++)
		{
			m_expandCol[i] = true;
			m_colDimension[i] = 0;
			m_colXOrigin[i] = 0;
			m_minColDimension[i] = 0;
		}

		m_expandingColNumber = cols;

		m_minimumSize = NSSize.ZeroSize;

		return this;
	}

	//******************************************************
	//*                  Properties
	//******************************************************

	/**
	 * Returns a string representation of the object.
	 */
	public function description():String
	{
		//! Fill this in a bit.
		return "ASGrid()";
	}

	/**
	 * This method is overridden because it should not do anything.
	 */
	public function setAutoresizesSubviews(flag:Boolean):Void
	{
		asWarning("Attempting to set setAutoresizesSubviews for an ASGrid");
	}

	//
	// Overridden to change behaviour
	//
	public function setFrame(aRect:NSRect):Void
	{
		updateForNewFrameSize(aRect.size);
		super.setFrame(aRect);
	}

	public function setFrameSize(aSize:NSSize):Void
	{
		updateForNewFrameSize(aSize);
		super.setFrameSize(aSize);
	}

	/** Returns the table's minimum size. */
	public function minimumSize():NSSize
	{
		return m_minimumSize.clone();
	}

	/** Returns the number of columns in the table. */
	public function numberOfColumns():Number
	{
		return m_numCols;
	}

	/** Returns the number of rows in the table. */
	public function numberOfRows():Number
	{
		return m_numRows;
	}
	
	/**
	 * Sets whether jails and the grid itself have masks.
	 */
	public function setRequiresMasks(val:Boolean):Void {
		m_requiresMasks = val;
	}
	
	/**
	 * Overridden by classes that wish to prevent masks creation for performance
	 * considerations.
	 */
	private function requiresMask():Boolean {
		return m_requiresMasks;
	}

	//******************************************************
	//*                   Resizing
	//******************************************************

	/**
	 * When the table is resized, all available horizontal space is divided
	 * amongst columns that have x-resizing enabled. The views are allowed to
	 * expand to fill that space. If <code>aFlag</code> is <code>true</code>,
	 * the views in <code>aColumn</code> will be allowed to expand into
	 * available space. If <code>aFlag</code> is <code>false</code>, they will
	 * not be.
	 */
	public function setXResizingEnabledForColumn(aFlag:Boolean, aColumn:Number)
		:Void
	{
		if (aColumn > (m_numCols - 1))
		{
			asWarning("Warning: argument column is > (numberOfColumns - 1)");
			return;
		}
		if (aColumn < 0)
		{
			asWarning("Warning: argument column is < 0");
			return;
		}
		if ((m_expandCol[aColumn] == true) && (aFlag == false))
		{
			m_expandingColNumber--;
			m_expandCol[aColumn] = aFlag;
		}
		else if ((m_expandCol[aColumn] == false) && (aFlag == true))
		{
			m_expandingColNumber++;
			m_expandCol[aColumn] = aFlag;
		}
	}

	/**
	 * Returns <code>true</code> if the views contained in <code>aColumn</code>
	 * are resized to fill available horizontal space when the table is resized.
	 */
	public function isXResizingEnabledForColumn(aColumn:Number):Boolean
	{
		if (aColumn > (m_numCols - 1))
		{
			asWarning("Warning: argument column is > (numberOfColumns - 1)");
			return false;
		}
		if (aColumn < 0)
		{
			asWarning("Warning: argument column is < 0");
			return false;
		}
		return m_expandCol[aColumn];
	}

	/**
	 * When the table is resized, all available vertical space is divided
	 * amongst rows that have y-resizing enabled. The views are allowed to
	 * expand to fill that space. If <code>aFlag</code> is <code>true</code>,
	 * the views in <code>aRow</code> will be allowed to expand into
	 * available space. If <code>aFlag</code> is <code>false</code>, they will
	 * not be.
	 */
	public function setYResizingEnabledForRow(aFlag:Boolean, aRow:Number)
		:Void
	{
		if (aRow > (m_numRows - 1))
		{
			trace(asWarning("Warning: argument row is > (numberOfRows - 1)"));
			return;
		}
		if (aRow < 0)
		{
			trace(asWarning("Warning: argument row is < 0"));
			return;
		}
		if ((m_expandRow[aRow] == true) && (aFlag == false))
		{
			m_expandingRowNumber--;
			m_expandRow[aRow] = aFlag;
		}
		else if ((m_expandRow[aRow] == false) && (aFlag == true))
		{
			m_expandingRowNumber++;
			m_expandRow[aRow] = aFlag;
		}
	}

	/**
	 * Returns <code>false</code> if the views contained in <code>aRow</code>
	 * are resized to fill available vertical space when the table is resized.
	 */
	public function isYResizingEnabledForRow(aRow:Number):Boolean
	{
		if (aRow > (m_numRows - 1))
		{
			trace(asWarning("Warning: argument row is > (numberOfRows - 1)"));
			return false;
		}
		if (aRow < 0)
		{
			trace(asWarning("Warning: argument row is < 0"));
			return false;
		}
		return m_expandRow[aRow];
	}

	/**
	 * Sizes the table to the minimum size required to fit all the subviews
	 * with their minimum sizes and margins.
	 */
	public function sizeToFit():Void
	{
		// This should never happen but anyway.
		if ((m_numCols == 0) || (m_numRows == 0))
		{
			super.setFrameSize(NSSize.ZeroSize);
			return;
		}

		var i:Number;

		m_colXOrigin[0] = m_minXBorder;
		m_colDimension[0] = m_minColDimension[0];
		m_rowYOrigin[0] = m_minYBorder;
		m_rowDimension[0] = m_minRowDimension[0];

		for (i = 1; i < m_numCols; i++)
		{
			m_colXOrigin[i] = m_colXOrigin[i - 1] + m_colDimension[i - 1];
			m_colDimension[i] = m_minColDimension[i];
		}

		for (i = 1; i < m_numRows; i++)
		{
			m_rowYOrigin[i] = m_rowYOrigin[i - 1] + m_rowDimension[i - 1];
			m_rowDimension[i] = m_minRowDimension[i];
		}

		updateWholeTable();
		super.setFrameSize(m_minimumSize);
	}

	//******************************************************
	//*             Adding Rows / Columns
	//******************************************************

	/**
	 * Adds a column to the table.
	 *
	 * Note: It is faster to create a table of the correct size from the get-go.
	 */
	public function addColumn():Void
	{
		m_numCols++;

		//
		// Re-order jails and havePrisoner arrays
		//
		for (var j:Number = m_numRows - 1; j >= 0; j--)
		{
			m_jails[m_numCols * (j + 1) - 1] = null;
			m_havePrisoner[m_numCols * (j + 1) - 1] = false;

			for (var i:Number = m_numCols - 2; i >= 0; i--)
			{
				m_jails[(m_numCols * j) + i]
					= m_jails[((m_numCols - 1) * j) + i];
				m_havePrisoner[(m_numCols * j) + i]
					= m_havePrisoner[((m_numCols - 1) * j) + i];
			}
		}

		m_expandCol[m_numCols - 1] = true;
		m_expandingColNumber++;
		m_colDimension[m_numCols - 1] = 0;
		m_colXOrigin[m_numCols - 1]
			= m_colXOrigin[m_numCols - 2] + m_colDimension[m_numCols - 2];
		m_minColDimension[m_numCols - 1] = 0;
	}

	/**
	 * Adds a row to the table.
	 *
	 * Note: It is faster to create a table of the correct size from the get-go.
	 */
	public function addRow():Void
	{
		m_numRows++;

		for (var j:Number = (m_numRows - 1) * m_numCols;
			j < (m_numRows * m_numCols); j++)
		{
			m_jails[j] = null;
			m_havePrisoner[j] = false;
		}

		m_expandRow[m_numRows - 1] = true;
		m_expandingRowNumber++;

		m_rowDimension[m_numRows - 1] = 0;
		m_rowYOrigin[m_numRows - 1] = (m_rowYOrigin[m_numRows - 2]
			+ m_rowDimension[m_numRows - 2]);
		m_minRowDimension[m_numRows - 1] = 0;
	}

	//******************************************************
	//*                    Getting Empty Rows and Columns
	//******************************************************

	public function emptyRowForColumn(col:Number):Number {
		var i:Number;
		for (i = 0; i < m_numRows; i++) {
			if(!m_havePrisoner[ i * m_numCols + col]) {
				break;
			}
		}
		return i;
	}

	public function emptyColumForRow(row:Number):Number {
		var i:Number;
		for (i = 0; i < m_numCols; i++) {
			if(!m_havePrisoner[i * m_numRows + row]) {
				break;
			}
		}
		return i;
	}

	//******************************************************
	//*                    Borders
	//******************************************************

	/**
	 * Sets all four borders to the <code>aBorder</code>.
	 */
	public function setBorder(aBorder:Number):Void
	{
		setMinXBorder(aBorder);
		setMaxXBorder(aBorder);
		setMinYBorder(aBorder);
		setMaxYBorder(aBorder);
	}

	/**
	 * Sets the <code>minXBorder</code> and the <code>maxXBorder</code> to
	 * <code>aBorder</code>.
	 */
	public function setXBorder(aBorder:Number):Void
	{
		setMinXBorder(aBorder);
		setMaxXBorder(aBorder);
	}

	/**
	 * Sets the <code>minYBorder</code> and the <code>maxYBorder</code> to
	 * <code>aBorder</code>.
	 */
	public function setYBorder(aBorder:Number):Void
	{
		setMinYBorder(aBorder);
		setMaxYBorder(aBorder);
	}

	/**
	 * Sets the minimum X border to <code>aBorder</code>.
	 */
	public function setMinXBorder(aBorder:Number):Void
	{
		var dBorder:Number;
		var tblSize:NSSize = frame().size;

		if (aBorder < 0) {
			aBorder = 0;
		}

		dBorder = aBorder - m_minXBorder;

		for (var i:Number = 0; i < m_numCols; i++)
		{
			m_colXOrigin[i] += dBorder;
			updateColumnOrigin(i);
		}

		m_minimumSize.width += dBorder;
		tblSize.width += dBorder;
		super.setFrameSize(tblSize);

		m_minXBorder = aBorder;

		if (m_maxXBorder < m_minXBorder) {
			m_maxXBorder = m_minXBorder;
		}
	}

	/**
	 * Sets the maximum X border to <code>aBorder</code>.
	 */
	public function setMaxXBorder(aBorder:Number):Void
	{
		var dBorder:Number; // delta border
		var tblSize:NSSize = frame().size;

		if (aBorder < 0) {
			aBorder = 0;
		}

		dBorder = aBorder - m_maxXBorder;

		m_minimumSize.width += dBorder;
		tblSize.width += dBorder;
		super.setFrameSize(tblSize);

		m_maxXBorder = aBorder;
	}

	/**
	 * Sets the minimum Y border to <code>aBorder</code>.
	 */
	public function setMinYBorder(aBorder:Number):Void
	{
		var dBorder:Number;
		var tblSize:NSSize = frame().size;

		if (aBorder < 0) {
			aBorder = 0;
		}

		dBorder = aBorder - m_minYBorder;

		for (var i:Number = 0; i < m_numRows; i++)
		{
			m_rowYOrigin[i] += dBorder;
			updateRowOrigin(i);
		}

		m_minimumSize.height += dBorder;
		tblSize.height += dBorder;
		super.setFrameSize(tblSize);

		m_minYBorder = aBorder;

		if (m_maxYBorder < m_minYBorder) {
			m_maxYBorder = m_minYBorder;
		}
	}

	/**
	 * Sets the maximum Y border to <code>aBorder</code>.
	 */
	public function setMaxYBorder(aBorder:Number):Void
	{
		var dBorder:Number;
		var tblSize:NSSize = frame().size;

		if (aBorder < 0) {
			aBorder = 0;
		}

		dBorder = aBorder - m_maxYBorder;

		m_minimumSize.height += dBorder;
		tblSize.height += dBorder;
		super.setFrameSize(tblSize);

		m_maxYBorder = aBorder;
	}

	//******************************************************
	//*                Default margins
	//******************************************************

	public function defaultMinXMargin():Number {
		return m_defaultMinXMargin;
	}

	public function setDefaultMinXMargin(value:Number):Void {
		m_defaultMinXMargin = value;
	}

	public function defaultMaxXMargin():Number {
		return m_defaultMaxXMargin;
	}

	public function setDefaultMaxXMargin(value:Number):Void {
		m_defaultMaxXMargin = value;
	}

	public function defaultMinYMargin():Number {
		return m_defaultMinYMargin;
	}

	public function setDefaultMinYMargin(value:Number):Void {
		m_defaultMinYMargin = value;
	}

	public function defaultMaxYMargin():Number {
		return m_defaultMaxYMargin;
	}

	public function setDefaultMaxYMargin(value:Number):Void {
		m_defaultMaxYMargin = value;
	}

	//******************************************************
	//*                  Adding Views
	//******************************************************

	/**
	 * Puts <code>aView</code> into the table at the specified row and column
	 * with no margins.
	 */
	public function putViewAtRowColumn(aView:NSView, row:Number, col:Number)
		:Void
	{
		putViewAtRowColumnWithMinXMarginMaxXMarginMinYMarginMaxYMargin(
			aView, row, col,
			m_defaultMinXMargin,
			m_defaultMaxXMargin,
			m_defaultMinYMargin,
			m_defaultMaxYMargin);
	}

	/**
	 * Puts <code>aView</code> into the table at the specified row and column
	 * with all margins set to <code>margins</code>.
	 */
	public function putViewAtRowColumnWithMargins(aView:NSView, row:Number,
		col:Number, margins:Number):Void
	{
		putViewAtRowColumnWithMinXMarginMaxXMarginMinYMarginMaxYMargin(
			aView, row, col, margins, margins, margins, margins);
	}

	/**
	 * Puts <code>aView</code> into the table at the specified row and column
	 * with all x margins set to <code>xMargins</code> and y margins set to
	 * <code>yMargins</code>.
	 */
	public function putViewAtRowColumnWithXMarginsYMargins(aView:NSView,
		row:Number, col:Number, xMargins:Number, yMargins:Number):Void
	{
		putViewAtRowColumnWithMinXMarginMaxXMarginMinYMarginMaxYMargin(
			aView, row, col, xMargins, xMargins, yMargins, yMargins);
	}

	/**
	 * Puts <code>aView</code> into the table at the specified row and column
	 * with the minimum x margin set to <code>minXMargin</code>, the maximum
	 * x margin set to <code>maxXMargin</code>, the minimum y margin set to
	 * <code>minYMargin</code> and the maximum y margin set to
	 * <code>maxYMargin</code>.
	 */
	public function putViewAtRowColumnWithMinXMarginMaxXMarginMinYMarginMaxYMargin(
		aView:NSView, row:Number, col:Number, minXMargin:Number,
		maxXMargin:Number, minYMargin:Number, maxYMargin:Number):Void
	{
		var jailNumber:Number;
		var oldFrame:NSRect;
		var theFrame:NSRect;
		var tblFrame:NSRect = frame();
		var tblNeedsResize:Boolean = false; // if true, the table will resize

		//
		// true if the prisoner (size + margins) need to be resized to fit the
		// jail
		//
		var prisonerNeedsResize:Boolean = false;

		//
		// Validate arguments
		//
		if (row > (m_numRows - 1))
		{
			asWarning("Warning: argument row is > (numberOfRows - 1)");
			return;
		}
		if (row < 0)
		{
			asWarning("Warning: argument row is < 0");
			return;
		}
		if (col > (m_numCols - 1))
		{
			asWarning("Warning: argument col is > (numberOfColumns - 1)");
			return;
		}
		if (col < 0)
		{
			asWarning("Warning: argument col is < 0");
			return;
		}

		oldFrame = aView.frame();
		oldFrame.size.width += minXMargin + maxXMargin;
		oldFrame.size.height += minYMargin + maxYMargin;
		theFrame = oldFrame.clone();

		jailNumber = row * m_numCols + col;

		//
		// Column
		//
		var coldim:Number = m_colDimension[col];

		if (theFrame.size.width > coldim)
		{
			var xShift:Number = theFrame.size.width - coldim;

			// compute new tblFrame.size
			tblFrame.size.width += xShift;
			tblNeedsResize = true;

			// resize the column
			m_colDimension[col] = theFrame.size.width;
			updateColumnSize(col);

			// shift the columns to the right of the one we resized
			for (var i:Number = col + 1; i < m_numCols; i++)
			{
				m_colXOrigin[i] += xShift;
				updateColumnOrigin(i);
			}
		}
		else
		{
			theFrame.size.width = coldim;
			prisonerNeedsResize = true;
		}

		//
		// Row
		//
		var rowdim:Number = m_rowDimension[row];

		if (theFrame.size.height > rowdim)
		{
			var yShift:Number = theFrame.size.height - rowdim;

			// compute new size
			tblFrame.size.height += yShift;
			tblNeedsResize = true;

			// resize the row
			m_rowDimension[row] = theFrame.size.height;
			updateRowSize(row);

			// shift the rows on top
			for (var i:Number = row + 1; i < m_numRows; i++)
			{
				m_rowYOrigin[i] += yShift;
				updateRowOrigin(i);
			}
		}
		else
		{
			theFrame.size.height = rowdim;
			prisonerNeedsResize = true;
		}

		//
		// Resize table if needed.
		//
		if (tblNeedsResize) {
			super.setFrameSize(tblFrame.size);
		}

		//
		// Deal with minimums
		//
		if (m_minColDimension[col] < theFrame.size.width)
		{
			m_minimumSize.width += (theFrame.size.width - m_minColDimension[col]);
			m_minColDimension[col] = theFrame.size.width;
		}

		if (m_minRowDimension[row] < theFrame.size.height)
		{
			m_minimumSize.height += (theFrame.size.height - m_minRowDimension[row]);
			m_minRowDimension[row] = theFrame.size.height;
		}

		//
		// Put the jail into the table
		//
		theFrame.origin = new NSPoint(tblFrame.origin.x + m_colXOrigin[col],
			tblFrame.origin.y + m_rowYOrigin[row]);

		if (m_havePrisoner[jailNumber])
		{
			if (prisonerNeedsResize) {
				NSView(m_jails[jailNumber]).setFrame(oldFrame);
			} else { // !prisonerNeedsResize
				NSView(m_jails[jailNumber]).setFrame(theFrame);
			}
		}
		else // !_havePrisoner
		{
			var jail:NSView;

			if (prisonerNeedsResize) {
				jail = (new NSView()).initWithFrame(oldFrame);
			} else { // !prisonerNeedResize
				jail = (new NSView()).initWithFrame(theFrame);
			}
			
			if (!m_requiresMasks) {
				jail.requiresMask = function():Boolean {
					return false;
				};
			}

			m_jails[jailNumber] = jail;
			jail.setAutoresizingMask(NotSizable);
			jail.setAutoresizesSubviews(true);
			addSubview(jail);
		}

		//
		// Put the prisoner in the jail.
		//
		var jail:NSView = NSView(m_jails[jailNumber]);

		if (!m_havePrisoner[jailNumber])
		{
			jail.addSubview(aView);
		}
		else
		{
			jail.replaceSubviewWith(jail.subviews()[0], aView);
		}

		//
		// Position view
		//
		aView.setFrameOrigin(new NSPoint(minXMargin, minYMargin));

		//
		// Resize view if necessary (by setting its jail's frame)
		//
		if (prisonerNeedsResize) {
			jail.setFrame(theFrame);
		}

		m_havePrisoner[jailNumber] = true;
	}

	//******************************************************
	//*                 Private Methods
	//******************************************************

	private function updateForNewFrameSize(newFrameSize:NSSize):Void
	{
		var oldFrameSize:NSSize = frame().size;
		var originShift:Number;
		var dimensionIncrement:Number;
		var tableNeedUpdate:Boolean = false; // true if table needs update

		//
		// Width
		//
		if (newFrameSize.width <= m_minimumSize.width)
		{
			if (oldFrameSize.width > m_minimumSize.width)
			{
				originShift = m_minXBorder;
				for (var i:Number = 0; i < m_numCols; i++)
				{
					m_colDimension[i] = m_minColDimension[i];
					m_colXOrigin[i] = originShift;
					originShift += m_minColDimension[i];
				}
				tableNeedUpdate = true;
			}
		}
		else // newFrameSize.width > m_minimumSize.width
		{
			if (oldFrameSize.width < m_minimumSize.width) {
				oldFrameSize.width = m_minimumSize.width;
			}

			if ((newFrameSize.width != oldFrameSize.width)
				&& m_expandingColNumber)
			{
				originShift = 0;
				dimensionIncrement = newFrameSize.width - oldFrameSize.width;
				dimensionIncrement = dimensionIncrement / m_expandingColNumber;
				for (var i:Number = 0; i < m_numCols; i++)
				{
					m_colXOrigin[i] += originShift;
					if (m_expandCol[i])
					{
						m_colDimension[i] += dimensionIncrement;
						originShift += dimensionIncrement;
					}
				}
				tableNeedUpdate = true;
			}
		}

		//
		// Height
		//
		if (newFrameSize.height <= m_minimumSize.height)
		{
			if (oldFrameSize.height > m_minimumSize.height)
			{
				originShift = m_minYBorder;
				for (var i:Number = 0; i < m_numRows; i++)
				{
					m_rowDimension[i] = m_minRowDimension[i];
					m_rowYOrigin[i] = originShift;
					originShift += m_minRowDimension[i];
				}
				tableNeedUpdate = true;
			}
		}
		else // newFrameSize.height > m_minimumSize.height
		{
			if (oldFrameSize.height < m_minimumSize.height) {
				oldFrameSize.height = m_minimumSize.height;
			}

			if ((newFrameSize.height != oldFrameSize.height) && m_expandingRowNumber)
			{
				originShift = 0;
				dimensionIncrement = newFrameSize.height - oldFrameSize.height;
				dimensionIncrement = dimensionIncrement / m_expandingRowNumber;
				for (var i:Number = 0; i < m_numRows; i++)
				{
					m_rowYOrigin[i] += originShift;
					if (m_expandRow[i])
					{
						m_rowDimension[i] += dimensionIncrement;
						originShift += dimensionIncrement;
					}
				}
				tableNeedUpdate = true;
			}
		}

		//
		// Update table if required.
		//
		if (tableNeedUpdate) {
			updateWholeTable();
		}
	}

	private function updateRowSize(row:Number):Void
	{
		var startIdx:Number = row * m_numCols;

		for (var i:Number = 0; i < m_numCols; i++)
		{
			if (m_havePrisoner[startIdx + i])
			{
				NSView(m_jails[startIdx + i]).setFrameSize(new NSSize(
					m_colDimension[i], m_rowDimension[row]));
			}
		}
	}

	private function updateColumnSize(col:Number):Void
	{
		for (var i:Number = 0; i < m_numRows; i++)
		{
			if (m_havePrisoner[(i * m_numCols) + col])
			{
				NSView(m_jails[(i * m_numCols) + col]).setFrameSize(new NSSize(
					m_colDimension[col], m_rowDimension[i]));
			}
		}
	}

	private function updateRowOrigin(row:Number):Void
	{
		var startIdx:Number = row * m_numCols;

		for (var i:Number = 0; i < m_numCols; i++)
		{
			if (m_havePrisoner[startIdx + 1])
			{
				NSView(m_jails[startIdx + 1]).setFrameOrigin(new NSPoint(
					m_colXOrigin[i],
					m_rowYOrigin[row]));
			}
		}
	}

	private function updateColumnOrigin(col:Number):Void
	{
		for (var i:Number = 0; i < m_numRows; i++)
		{
			var idx:Number = i * m_numCols + col;
			if (m_havePrisoner[idx])
			{
				NSView(m_jails[idx]).setFrameOrigin(new NSPoint(
					m_colXOrigin[col],
					m_rowYOrigin[i]));
			}
		}
	}

	private function updateWholeTable():Void
	{
		for (var j:Number = 0; j < m_numCols; j++)
		{
			for (var i:Number = 0; i < m_numRows; i++)
			{
				var idx:Number = i * m_numCols + j;

				if (m_havePrisoner[idx])
				{
					NSView(m_jails[idx]).setFrameOrigin(new NSPoint(
						m_colXOrigin[j], m_rowYOrigin[i]));

					NSView(m_jails[idx]).setFrameSize(new NSSize(
						m_colDimension[j], m_rowDimension[i]));
				}
			}
		}
	}
}