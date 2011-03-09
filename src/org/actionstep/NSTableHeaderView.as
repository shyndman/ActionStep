/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.graphics.ASGraphicUtils;
import org.actionstep.graphics.ASLinearGradient;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSCell;
import org.actionstep.NSCursor;
import org.actionstep.NSEvent;
import org.actionstep.NSMatrix;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSSortDescriptor;
import org.actionstep.NSTableColumn;
import org.actionstep.NSTableHeaderCell;
import org.actionstep.NSTableView;
import org.actionstep.NSTextField;
import org.actionstep.table.ASTableMatrix;
import org.actionstep.themes.ASTheme;

/**
 * Used by an NSTableView to draw headers for columns and to handle mouse
 * events in the column headers.
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSTableHeaderView extends org.actionstep.NSView {	
	private var m_tableView:NSTableView;
	private var m_sortedCol:NSTableColumn;
	private var m_pressedCol:Number;
	private var m_resizedCol:Number;
	private var m_isResizing:Boolean;
	private var m_draggedCol:Number;
	private var m_draggedDistance:Number;
	private var m_draggedTextField:NSTextField;
	private var m_draggedMatrix:NSMatrix;
	private var m_draggedMatrixFrame:NSRect;
	private var m_draggedTFOffset:NSPoint;
	private var m_draggedMatrixOffset:NSPoint;
	private var m_missingCol:Number;
	private var m_isMoving:Boolean;
	private var m_trackingData:Object;
	
	/**
	 * Creates a new instance of NSTableHeaderView.
	 */
	public function NSTableHeaderView()
	{	
		super();
		m_isMoving = false;
		m_isResizing = false;
		m_draggedCol = -1;
		m_resizedCol = -1;
		m_pressedCol = -1;
		m_missingCol = -1;
		m_draggedDistance = 0;
		
		//
		// Register for column drag types.
		//
		registerForDraggedTypes(NSArray.arrayWithArray(
			["NSTableColumnPboardType"]));
	}
	
	
	/**
	 * Default initializer for the NSTableHeaderView.
	 */
	public function init():NSTableHeaderView
	{
		return initWithFrame(NSRect.ZeroRect);
	}
	
	
	/**
	 * Initializes teh NSTableHeaderView with a frame rectangle.
	 */
	public function initWithFrame(frame:NSRect):NSTableHeaderView
	{
		super.initWithFrame(frame);
		m_tableView = null;
		return this;
	}
	
	//******************************************************															 
	//*                    Properties
	//******************************************************
	
	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String 
	{
		return "NSTableHeaderView()";
	}
	
	
	/**
	 * If the user is currently dragging a column, this returns the index
	 * of the column currently being dragged, otherwise it returns -1.
	 */
	public function draggedColumn():Number
	{
		return m_draggedCol;
	}
	
	
	/**
	 * If the user is currently dragging a column, this returns the distance
	 * the column has been dragged horizontally from its original position.
	 */
	public function draggedDistance():Number
	{		
		return m_draggedDistance;
	}
	
	
	/**
	 * Returns the rectangle containing the tile for the column at index 
	 * columnIdx. If columnIdx is out of bounds, an exception is raised.
	 */
	public function headerRectOfColumn(columnIdx:Number):NSRect
	{
		var rect:NSRect;
		var tv:NSTableView;
		
		if (m_tableView == null)
		{
			return NSRect.ZeroRect;
		}
				
		tv = tableView();
		rect = tv.rectOfColumn(columnIdx);
		//rect = convertRectFromView(rect, tv);
		rect.origin.y = m_bounds.origin.y;
		rect.size.height = m_bounds.size.height;

		return rect;
	}
	
	
	/**
	 * If the user is resizing a column, this method returns the index of that
	 * column. If no column is being resized, -1 is returned.
	 */
	public function resizedColumn():Number
	{
		return m_resizedCol;
	}
	
	
	/**
	 * Returns the NSTableView this is currently handling table headers for.
	 */
	public function tableView():NSTableView
	{
		return m_tableView;
	}
	

	/**
	 * Sets the NSTableView this is currently handling table headers for. This
	 * method doesn't ordinarily have to be invoked by the user, as it is 
	 * invoked automatically when you set the header view for a table.
	 */	
	public function setTableView(aTable:NSTableView):Void
	{
		m_tableView = aTable;
	}
	
	//******************************************************															 
	//*                 Public Methods
	//******************************************************
	
	/**
	 * Returns the column index who's header exists at the specified point, or
	 * -1 if no such column exists. The point should be expressed in this
	 * view's coordinate system.
	 */
	public function columnAtPoint(aPoint:NSPoint):Number
	{
		var pt:NSPoint;
		var tv:NSTableView;
		
		if (m_tableView == null)
		{
			return -1;
		}
		
		tv = tableView();
		pt = aPoint.clone();
		pt.y = 0;
		return tv.columnAtPoint(pt);
	}
	
	//******************************************************															 
	//*                     Events
	//******************************************************
	
	/**
	 * Figures out what has been clicked, and whether resizing or moving should
	 * begin.
	 */
	private function mouseDown(event:NSEvent):Void
	{
		var tv:NSTableView = tableView();
		var resize:Boolean = false;
		var pt:NSPoint;
		var col:NSTableColumn;
		var colidx:Number;
		var resizeColidxCheck:Number;
		
		//
		// Do nothing if not enabled.
		//
		if (!tv.isEnabled()) {
			return;
		}
		
		//
		// Make the tableview first responder
		//
		tv.window().makeFirstResponder(tv); 
		
		//
		// Convert the point.
		//				
		pt = convertPointFromView(event.mouseLocation, null);
						
		//
		// Get the column index and the column.
		//
		colidx = columnAtPoint(pt);
		col = NSTableColumn(tv.tableColumns().internalList()
			[colidx]);
		
		//
		// Double click handling
		//
		if (event.clickCount >= 2) {
			tv.sendDoubleActionForColumn(colidx);
		}
		
		//
		// Determine whether we should be resizing.
		//
		if (tv.allowsColumnResizing()) {
			resizeColidxCheck = columnAtPoint(pt.translate(4, 0));
			resize = colidx != resizeColidxCheck;
						
			if (resize) {
				m_resizedCol = colidx;
			}
			
			if (!resize)
			{
				resizeColidxCheck = columnAtPoint(pt.translate(-4, 0));
				resize = colidx != resizeColidxCheck;
				
				if (resize) {
					m_resizedCol = resizeColidxCheck;
				}
			}
			
			//
			// If we're resizing, start the magic.
			//
			if (resize)
			{
				var resizeCol:NSTableColumn = NSTableColumn(tv.tableColumns().
					internalList()[m_resizedCol]);
					
				if (resizeCol.resizingMask() 
					& NSTableColumn.NSTableColumnUserResizingMask)
				{
					resizeColumn(event, resizeCol);
					return;
				}
			}
		}
				
		//
		// We aren't resizing, so let's notify the table.
		//
		m_pressedCol = colidx;
		tv.postMouseDownInHeaderOfTableColumn(col);
		setNeedsDisplay(true);
		
		//
		// If we can move, let's do it.
		//
		if (tv.allowsColumnReordering()) {
			moveColumn(event, colidx);
		}
	}
	
	/**
	 * If the conditions are correct, this will sort the column.
	 */
	private function mouseUp(event:NSEvent):Void
	{		
		if (!m_isMoving && !m_isResizing && m_pressedCol != -1) {
			//
			// Select column
			//
			var pt:NSPoint = convertPointFromView(event.mouseLocation, null);
			var colIdx:Number = columnAtPoint(pt);
			
			if (colIdx == m_pressedCol) {
				var colRect:NSRect = headerRectOfColumn(m_pressedCol);
				if (colRect.pointInRect(pt)) {
					var tv:NSTableView = tableView();
					tv._selectColumn(m_pressedCol, event.modifierFlags);
					
					//
					// Sort?
					//
					var col:NSTableColumn = NSTableColumn(tv.tableColumns()
						.objectAtIndex(m_pressedCol));
					var sort:NSSortDescriptor = col.sortDescriptorPrototype();
					if (sort != null) {
						tv.setSortDescriptors(NSArray.arrayWithObject(sort));
						m_sortedCol = col;
					} else {
						m_sortedCol = null;
					}
				}
			}
		}
		else if (m_isMoving) {
			//
			// Perform cleanup
			//
			var col:NSTableColumn = NSTableColumn(tableView().tableColumns().
				objectAtIndex(m_trackingData.endColIdx));
			col.headerCell().setStringValue(m_draggedTextField.stringValue());
			
			m_isMoving = false;
			m_draggedCol = -1;
			m_draggedDistance = 0;
			m_draggedTextField.removeFromSuperview();
			m_draggedTextField.release();
			m_draggedTextField = null;
			m_draggedMatrix = null;
			m_missingCol = -1;
		}
		
		m_trackingData = null;
		m_resizedCol = -1;
		m_pressedCol = -1;
		m_isResizing = false;
		resetCursorRects();
		NSCursor.pop();
		setNeedsDisplay(true);
	}

	//******************************************************															 
	//*                  Column Resizing
	//******************************************************
	
	/**
	 * Sets up the mouse tracking for column resizing.
	 */
	private function resizeColumn(event:NSEvent, col:NSTableColumn):Void 
	{
		m_updateCount = 0;
		m_isResizing = true;
		
		var point:NSPoint = convertPointFromView(event.mouseLocation, null);
		m_trackingData = { 
			offsetX: point.x,
			offsetY: point.y,
			mouseDown: true, 
			eventMask: NSEvent.NSLeftMouseDownMask | NSEvent.NSLeftMouseUpMask 
			| NSEvent.NSLeftMouseDraggedMask | NSEvent.NSMouseMovedMask 
			| NSEvent.NSOtherMouseDraggedMask | NSEvent.NSRightMouseDraggedMask
			| NSEvent.NSPeriodicMask,
			complete: false,
			column: col, // This is added by me
			iniWidth: col.width()
		};
		
		NSEvent.startPeriodicEventsAfterDelayWithPeriod(0.2, 0.1);
		
		resizeColumnCallback(event);
	}
	
	private var m_updateCount:Number;
	
	/**
	 * This method is called on every mouse event and resizes the column
	 * currently being resized appropriately.
	 */
	private function resizeColumnCallback(event:NSEvent):Void
	{
		if (m_updateCount++ % 2 == 0 || event.type == NSEvent.NSLeftMouseUp) {
			//
			// Calculate width
			//
			var pt:NSPoint = convertPointFromView(event.mouseLocation, null);
			var w:Number = m_trackingData.iniWidth + (pt.x - m_trackingData.offsetX);
					
			//
			// Column widths can't be negative.
			//
			if (w <= 0) {
				w = 0;
			}
			
			//
			// Set the width on the column.
			//
			NSTableColumn(m_trackingData.column).setWidth(w);
		}
		
		//
		// If the mouse went up, end this.
		//
		if (event.type == NSEvent.NSLeftMouseUp) {
			//
			// Notify the table.
			//
			NSEvent.stopPeriodicEvents();
			tableView().postColumnDidResize(m_trackingData.column, 
				m_trackingData.iniWidth);
			mouseUp(event);
			return;
		}
		
		NSApplication.sharedApplication().
			callObjectSelectorWithNextEventMatchingMaskDequeue(
				this, "resizeColumnCallback", m_trackingData.eventMask, false);
	}
	
	//******************************************************															 
	//*                  Column Moving
	//******************************************************
	
	/**
	 * Sets up the mouse tracking for moving a column.
	 */
	private function moveColumn(event:NSEvent, colidx:Number):Void 
	{
		var point:NSPoint = convertPointFromView(event.mouseLocation, null);
		m_trackingData = { 
			offsetX: point.x,
			offsetY: point.y,
			mouseDown: true, 
			eventMask: NSEvent.NSLeftMouseDownMask | NSEvent.NSLeftMouseUpMask 
			| NSEvent.NSLeftMouseDraggedMask | NSEvent.NSMouseMovedMask 
			| NSEvent.NSOtherMouseDraggedMask | NSEvent.NSRightMouseDraggedMask,
			complete: false,
			startColIdx: colidx, // The starting column index of the move
			endColIdx: colidx // The ending column index of the move.
		};
		discardCursorRects();
		moveColumnCallback(event);
	}
	
	/**
	 * This method performs the column moving. It is called on every mouse 
	 * event until the movement is complete.
	 */
	private function moveColumnCallback(event:NSEvent):Void
	{
		//
		// If the mouse went up, end this.
		//
		if (event.type == NSEvent.NSLeftMouseUp) {
			var tv:NSTableView = tableView();
			var col:NSTableColumn = NSTableColumn(tv.tableColumns().
				objectAtIndex(m_trackingData.startColIdx));
			
			if (m_isMoving) {
				var colidx:Number = columnAtPoint(new NSPoint(_root._xmouse, 
					_root._ymouse));
				m_trackingData.endColIdx = colidx;
				if (m_trackingData.startColIdx == colidx) {
					m_draggedMatrix.setFrame(m_draggedMatrixFrame);
					mouseUp(event);
					return;
				}
				
				//
				// Restore matrix properties
				//
				ASTableMatrix(m_draggedMatrix).setMoving(false);
				m_draggedMatrix.mcFrame()._alpha = 100;
				m_draggedMatrix.display();
				
				//
				// Move the column
				//
				tv.moveColumnToColumn(m_trackingData.startColIdx, colidx);
		
				//
				// Column drag
				//
				tv.postDidDragTableColumn(col);
			}
			
			mouseUp(event);
			return;
		}
		
		//
		// Figure out how far in the x direction the mouse has moved.
		//
		var point:NSPoint = convertPointFromView(event.mouseLocation, null);
		var deltaX:Number = point.x - m_trackingData.offsetX;
		
		if (!m_isMoving && Math.abs(deltaX) > 20) {
			m_isMoving = true;
			m_draggedCol = m_missingCol = m_trackingData.startColIdx;
			var col:NSTableColumn = NSTableColumn(tableView().tableColumns().
				objectAtIndex(m_trackingData.startColIdx));
			var headerRect:NSRect = headerRectOfColumn(
				m_trackingData.startColIdx);

			//
			// Create a new textfield with a copy of the header cell.
			//
			var headerCell:NSCell = col.headerCell().copyWithZone();
			var tf:NSTextField = m_draggedTextField = (new NSTextField()).initWithFrame(
				headerRect);
			tf.setCell(headerCell);
			addSubview(tf);
			tf.mcFrame()._alpha = 70;
			
			//
			// Get the matrix we'll be working with
			//
			m_draggedMatrix = col.columnMatrix();
			ASTableMatrix(m_draggedMatrix).setMoving(true);
			m_draggedMatrix.display();
			m_draggedMatrix.mcFrame().swapDepths(
				m_draggedMatrix.superview().getNextDepth());
			m_draggedMatrix.mcFrame()._alpha = 70;
			m_draggedMatrixFrame = m_draggedMatrix.frame();
			var matrixRect:NSRect = convertRectFromView(m_draggedMatrixFrame,
				m_draggedMatrix.superview());
			
			//
			// Clear out the old cell value
			//
			col.headerCell().setStringValue("");
			NSTableHeaderCell(col.headerCell()).validateTextField(headerRect);

			//
			// Calculate image position. 
			//
			m_draggedTFOffset = new NSPoint(m_trackingData.offsetX - headerRect.origin.x,
				m_trackingData.offsetY - headerRect.origin.y);
			m_draggedMatrixOffset = new NSPoint(m_trackingData.offsetX - matrixRect.origin.x,
				m_trackingData.offsetY - matrixRect.origin.y);
			
			//
			// Mark header as needing redisplay
			//
			setNeedsDisplay(true);
		}
		
		//
		// Record the necessary drag values.
		//
		if (m_isMoving) {
			m_draggedCol = m_trackingData.startColIdx;
			m_draggedDistance = deltaX;
			m_draggedTextField.setFrameXOrigin(point.x - m_draggedTFOffset.x);
			m_draggedMatrix.setFrameXOrigin(
				convertPointToView(point.subtractPoint(m_draggedMatrixOffset),
					m_draggedMatrix.superview()).x);
		}
		
		NSApplication.sharedApplication().
			callObjectSelectorWithNextEventMatchingMaskDequeue(
				this, "moveColumnCallback", m_trackingData.eventMask, false);
	}
	
	
	
	//******************************************************															 
	//*                 Protected Methods
	//******************************************************
	
	/**
	 * Sets up the various header cursors.
	 */
	public function resetCursorRects():Void 
	{
		if (m_isResizing)
			return;
			
		var tv:NSTableView = tableView(); // the table view
		var cols:Array = tv.tableColumns().internalList();
		var rect:NSRect = new NSRect(0, 0, 7, m_bounds.size.height);

		//
		// If the table doesn't allow column resizing, don't do it.
		//
		if (!tv.allowsColumnResizing()) {
			return;
		}
		
		for (var i:Number = 0; i < cols.length; i++) 
		{
			rect.origin.x += NSTableColumn(cols[i]).width() - 2;
			
			if ((NSTableColumn(cols[i]).resizingMask() 
				& NSTableColumn.NSTableColumnUserResizingMask) != 0)
			{	
				addCursorRectCursor(rect, NSCursor.resizeLeftRightCursor());
			}
		}
	}

  	
	/**
	 * Draws the thing.
	 *
	 * Also sets cell highlighting based on table data.
	 */
	public function drawRect(rect:NSRect):Void
	{		
		var tv:NSTableView = tableView(); // the table view
		var firstCol:Number; // the first column to draw
		var lastCol:Number; // the last column to draw
		var drawingLastCol:Boolean = false;
		var list:Array; // the array of table columns
		var col:NSTableColumn; // the current table column (in the loop)
		var colWidth:Number; // the current column's width
		var colCell:NSTableHeaderCell; // the current column's header cell
		var headerRect:NSRect; // the rectangle used to draw the current column
		var highlightedCol:NSTableColumn; // the table's highlighted column
		var selectedCol:Number;
		
		if (tv == null) // we don't have anything to draw
		{
			return;
		}
		
		//
		// Calculate first and last columns to draw.
		//
		firstCol = 0; //columnAtPoint(new NSPoint(rect.origin.x, rect.origin.y));
		lastCol = tv.numberOfColumns() - 1;
		drawingLastCol = true;
		
		//
		// Get the necessary stuff.
		//
		list = tv.tableColumns().internalList();
		headerRect = headerRectOfColumn(firstCol);
		
		headerRect.size.height--;
		highlightedCol = tv.highlightedTableColumn();
		selectedCol = tv.selectedColumn();
		
		mcBounds().clear();
		
		//
		// Draw the column headers (except last)
		//
		for (var i:Number = firstCol; i <= lastCol; i++)
		{
			col = NSTableColumn(list[i]);
			colWidth = col.width();
			colCell = NSTableHeaderCell(col.headerCell());
					
			//
			// Set width
			//
			headerRect.size.width = colWidth;
			
			if (i == lastCol && drawingLastCol)
			{
				headerRect.size.width--;
			}
			
			//
			// Set cell highlighting
			//			
			colCell.setHighlighted(tv.isColumnSelected(i));
			colCell.setState(i == m_pressedCol ? NSCell.NSOnState
				: NSCell.NSOffState);
			
			//
			// Draw the cell.
			//
			if (m_missingCol != i) {
				colCell.drawWithFrameInView(headerRect, this); // Draw cell
				
				if (col == m_sortedCol) {
					colCell.drawSortIndicatorWithFrameInViewAscendingPriority(
						colCell.sortIndicatorRectForBounds(headerRect),
						this, col.sortDescriptorPrototype().ascending(), 0);
				}
			} else {
				drawMissingColumnInRect(headerRect);
			}
			
			headerRect.origin.x += colWidth; // update origin
		}
		
		//
		// Fill in the rest of the background (if we need to)
		//
		var visRect:NSRect = tv.enclosingClipView().bounds();
		if (headerRect.origin.x < visRect.size.width)
		{
			var remArea:NSRect = visRect.clone();
			remArea.origin.y = 0;
			remArea.origin.x = headerRect.origin.x - 1;
			remArea.size.width -= headerRect.origin.x;
			remArea.size.height = headerRect.size.height;
			
			ASTheme.current().drawTableHeaderWithRectInViewHighlightedSelected(
				remArea, this, false, false);
			
			headerRect.origin.x = visRect.size.width;
			
			setFrameSize(new NSSize(headerRect.origin.x, 
				headerRect.size.height + 1));
		}
	}
	
	private var m_missingColBackground:ASLinearGradient;
	
	private function drawMissingColumnInRect(rect:NSRect):Void {
		var g:ASGraphics = graphics();
		if (m_missingColBackground == null) {
			m_missingColBackground = new ASLinearGradient(
				[ASColors.darkGrayColor(), 
				ASColors.grayColor().adjustColorBrightnessByFactor(0.9), 
				ASColors.darkGrayColor()],
				[30, 130, 225], 
				ASGraphicUtils.linearGradientMatrixWithRectDegrees(
					rect, ASLinearGradient.ANGLE_TOP_TO_BOTTOM));
		}
		
		g.brushDownWithBrush(m_missingColBackground);
		g.drawRectWithRect(rect, null, null);
		g.brushUp();
	}
}
