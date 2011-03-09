/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSCell;
import org.actionstep.NSColor;
import org.actionstep.NSEvent;
import org.actionstep.NSMatrix;
import org.actionstep.NSRange;
import org.actionstep.NSRect;
import org.actionstep.NSTableColumn;
import org.actionstep.NSTableView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.ASThemeProtocol;

/**
 * An NSMatrix that supports alternating background colours. An instance of this
 * class represents a single column in the table.
 * 
 * This class is typically instantiated by the NSTableView, not directly.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.table.ASTableMatrix extends NSMatrix {
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private var m_tableView:NSTableView;
	private var m_tableColumn:NSTableColumn;
	private var m_wasSelected:Boolean;
	private var m_cachedFontColor:NSColor;
	private var m_isMoving:Boolean;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASTableMatrix</code> class.
	 */
	public function ASTableMatrix() {
		m_wasSelected = false;
		m_isMoving = false;
	}
	
	//******************************************************
	//*          Releasing the object from memory
	//******************************************************
	
	/**
	 * Releases the object from memory.
	 */
	public function release():Boolean {
		super.release();
		
		m_tableView = null;
		m_tableColumn = null;
		
		return true;
	}
	
	//******************************************************
	//*              Setting the table view
	//******************************************************
	
	/**
	 * Returns this matrix's table view.
	 */
	public function tableView():NSTableView {
		return m_tableView;
	}
	
	/**
	 * Sets this matrix's table view.
	 */
	public function setTableView(tableView:NSTableView):Void {
		m_tableView = tableView;
	}
	
	//******************************************************
	//*            Setting the table column
	//******************************************************

	/**
	 * Sets the column who's data this matrix shows.
	 */	
	public function tableColumn():NSTableColumn {
		return m_tableColumn;
	}
	
	/**
	 * Sets the column who's data this matrix shows.
	 */
	public function setTableColumn(aColumn:NSTableColumn):Void {
		m_tableColumn = aColumn;
	}
	
	//******************************************************
	//*              Setting the move flag
	//******************************************************
	
	public function setMoving(flag:Boolean):Void {
		m_isMoving = flag;
	}
	
	//******************************************************
	//*                 Event handling
	//******************************************************
	
	public function mouseDown(event:NSEvent):Void {
		//super.mouseDown(event);
		m_nextResponder.mouseDown(event);
	}
	
	public function matrixMouseDown(event:NSEvent):Void {
		super.mouseDown(event);
	}
	
	/**
	 * Called by the cell during tracking
	 */
	private function cellTrackingCallbackRadioMode(mouseUp:Boolean):Void {
		if (mouseUp) {
			mouseUpForCell(m_app.currentEvent(), 
				NSCell(m_trackingData.affectedCell), true);
		}
						
		super.cellTrackingCallbackRadioMode(mouseUp);
	}
	
	/**
	 * Called by the control during tracking
	 */
	private function mouseTrackingCallbackRadioMode(event:NSEvent):Void {
		if (event.type == NSEvent.NSLeftMouseUp) {
			mouseUpForCell(event, NSCell(m_trackingData.affectedCell), false);
		}
		
		super.mouseTrackingCallbackRadioMode(event);
	}
	
	/**
	 * Called when the mouse is released after cell tracking
	 */
	private function mouseUpForCell(event:NSEvent, cell:NSCell, inCell:Boolean):Void {
		var untilMouseUp:Boolean = cell.getClass().prefersTrackingUntilMouseUp();
		var ret:Boolean = untilMouseUp || inCell;
		
		m_tableView.mouseUpInCellDidTrack(event, cell, ret);
	}
	
	/**
	 * Overridden to prevent text selection on click.
	 */
	public function selectTextAtRowColumn(row:Number, column:Number):NSCell {		
		return null;
	}
	
	//******************************************************
	//*            Getting specific data cells
	//******************************************************
	
	public function dataCellForRow(rowIdx:Number):NSCell {
		var dataRange:NSRange = m_tableView.displayedDataRange();
		if (!dataRange.containsValue(rowIdx)) {
			return null;
		}
		
		var idx:Number = rowIdx - dataRange.location;			
		return NSCell(m_cells.objectAtIndex(idx));
	}
	
	//******************************************************															 
	//*                 Drawing Methods
	//******************************************************
	  
	public function drawRect(aRect:NSRect):Void {		
		m_graphics.clear();		
				
		var grid:Number = m_tableView.gridStyleMask();
		
		//
		// Draw grid
		//
		var gridColor:NSColor = m_tableView.gridColor();
		var g:ASGraphics = m_graphics;
		var theme:ASThemeProtocol = ASTheme.current();

		var drawHGrid:Boolean = (grid & NSTableView.NSTableViewSolidHorizontalGridLineMask) != 0;
		var selCellColor:NSColor = theme.colorWithName(
			m_window.firstResponder() == m_tableView 
				? ASThemeColorNames.ASTableCellFirstResponderSelectionBackground
				: ASThemeColorNames.ASTableCellSelectionBackground
			);
		var selTextColor:NSColor = theme.colorWithName(
					ASThemeColorNames.ASTableCellFirstResponderSelectionText);
					
		var cells:Array = m_cells.internalList();
		var visRows:NSRange = m_tableView.displayedDataRange();
		var x:Number = aRect.origin.x;
		var w:Number = aRect.size.width;
		var y:Number = aRect.origin.y;
		var yInc:Number = m_cellSize.height + m_cellSpacing.height;
		var len:Number = m_numRows;
		var row:Number;
		var alt:Number = m_tableView.rowColorCount();
		var drawRows:Boolean = m_isMoving && m_tableView.usesAlterningRowBackgroundColors();
		var altRowColor:NSColor;
		var rowColor:NSColor;
		if (drawRows) {
			rowColor = ASColors.whiteColor();
			altRowColor = theme.colorWithName(ASThemeColorNames.ASAlternatingRowColor);
		}		
		var isSelCols:Boolean = m_tableView.isSelectedColumns();
		
		//
		// Draw background
		//
		drawBackground(aRect, isSelCols);
		
		//
		// Draw vertical grid lines
		//
		if (grid & NSTableView.NSTableViewSolidVerticalGridLineMask) {
			var gridX:Number = aRect.maxX() - 1;
			var gridY:Number = aRect.origin.y;
			var gridH:Number = aRect.size.height;
			g.drawLine(gridX, gridY, gridX, gridY + gridH, gridColor, 1);
		}
		
		//
		// Draw rows
		//
		for (var i:Number = 0; i < len; i++) {
			row = visRows.location + i;
			if (!isSelCols && m_tableView.isRowSelected(row)) {
				g.brushDownWithBrush(selCellColor);
				g.drawRect(x, y + (yInc * i), w, yInc, null);
				g.brushUp();
				NSCell(cells[i]).setFontColor(selTextColor.copyWithZone());		
			} else {
				if (drawRows) {
					g.brushDownWithBrush(alt == 0 ? rowColor : altRowColor);
					g.drawRect(x, y + (yInc * i), w, yInc, null);
					g.brushUp();
				}
				
				NSCell(cells[i]).setFontColor(m_wasSelected 
					? m_cachedFontColor.copyWithZone()
					: m_prototype.fontColor().copyWithZone());	
			}
			
			alt = (alt + 1) % 2;
				
			if (drawHGrid) {
				g.drawLine(x, y + (yInc * i), x + w, y + (yInc * i), gridColor, 1);
			}
		}
			
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
	 * Draws alternating row colours and selection.
	 */
	private function drawBackground(rect:NSRect, isSelectingColumns:Boolean):Void {
		if (!isSelectingColumns || !m_tableView.isColumnSelected(
				m_tableView.tableColumns().indexOfObject(m_tableColumn))) {
			if (m_wasSelected) {
				setCellFontColor(m_cachedFontColor);
				m_wasSelected = false;
			}
			return;
		}
				
		var selCellColor:NSColor = ASTheme.current().colorWithName(
			m_window.firstResponder() == m_tableView 
				? ASThemeColorNames.ASTableCellFirstResponderSelectionBackground
				: ASThemeColorNames.ASTableCellSelectionBackground
			);
		var g:ASGraphics = m_graphics;
		g.brushDownWithBrush(selCellColor);
		g.drawRectWithRect(rect, null);
		g.brushUp();
		
		if (m_wasSelected) {
			return;
		}
		
		m_wasSelected = true;
		m_cachedFontColor = m_prototype.fontColor();		
		setCellFontColor(ASTheme.current().colorWithName(
					ASThemeColorNames.ASTableCellFirstResponderSelectionText));	
	}
	
	private function setCellFontColor(color:NSColor):Void {
		var arr:Array = m_cells.internalList();
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			NSCell(arr[i]).setFontColor(color);
		}
		
		m_prototype.setFontColor(color.copyWithZone());
	}
}