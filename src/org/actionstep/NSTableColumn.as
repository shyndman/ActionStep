/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSLineBreakMode;
import org.actionstep.NSCell;
import org.actionstep.NSDictionary;
import org.actionstep.NSImage;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSRange;
import org.actionstep.NSSortDescriptor;
import org.actionstep.NSTableHeaderCell;
import org.actionstep.NSTableView;
import org.actionstep.table.ASTableMatrix;

/**
 * Stores the characteristics of a column in an NSTableView. This includes:
 *
 * <ul>
 * <li>The attribute identifier (in the datasource).
 * <li>Width and width limits.
 * <li>Editability
 * <li>Resizability
 * <li>The cell used to draw the header.
 * <li>The cell used to render the data.
 * </ul>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSTableColumn extends org.actionstep.NSObject
{	
	//******************************************************															 
	//*                    Constants
	//******************************************************
	
	/** Prevents the table from resizing. */
	public static var NSTableColumnNoResizing:Number = 0; // do not change, must be 0
	
	/** 
	 * Allows the table column to resize automatically in response 
	 * to resizing the tableview. 
	 */
	public static var NSTableColumnAutoresizingMask:Number = 1;
	
	/**
	 * Allows the table column to be resized explicitly by the user.
	 */
	public static var NSTableColumnUserResizingMask:Number = 2;
		
	//******************************************************															 
	//*                 Member Variables
	//******************************************************
	
	private var m_headerCell:NSCell;
	private var m_dataCell:NSCell;
	private var m_identifier:Object;
	private var m_resizingMask:Number;
	private var m_isEditable:Boolean;
	private var m_maxWidth:Number;
	private var m_minWidth:Number;
	private var m_sortDescriptor:NSSortDescriptor;
	private var m_width:Number;
	private var m_indicator:NSImage;
	private var m_tableView:NSTableView;
	private var m_matrix:ASTableMatrix;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
		
	/**
	 * Constructs a new instance of NSTableColumn.
	 */
	public function NSTableColumn() {
		m_headerCell = (new NSTableHeaderCell()).initWithTextCell("");
		m_headerCell.setLineBreakMode(
			NSLineBreakMode.NSLineBreakByTruncatingTail);
		m_minWidth = 0;
		m_maxWidth = 8000;
		m_resizingMask = NSTableColumnNoResizing;
		m_isEditable = false;
		m_sortDescriptor = null;
	}	
	
	/**
	 * Initializes the column using an identifier of anObject.
	 */
	public function initWithIdentifier(anObject:Object):NSTableColumn {
		setIdentifier(anObject);
		return this;
	}
	
	//******************************************************
	//*               Describing the object
	//******************************************************

	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String {
		return "NSTableColumn(" + 
			"identifier=" + identifier() + ", " + 
			"width=" + width() + 
			")";
	}
	
	//******************************************************
	//*               Setting the identifier
	//******************************************************
	
	/**
	 * Returns the object used by the data source to identify the attribute 
	 * which is to be rendered by this column's data cells.
	 */
	public function identifier():Object {
		return m_identifier;
	}
	
	/**
	 * Sets the object used by the data source to identify the attribute
	 * which is to be rendered by this column's data cells.
	 */
	public function setIdentifier(anObject:Object):Void {
		m_identifier = anObject;
	}
	
	//******************************************************
	//*              Setting the NSTableView
	//******************************************************
	
	/**
	 * Returns this column's table view.
	 */
	public function tableView():NSTableView {
		return m_tableView;
	}
	
	/**
	 * <p>
	 * Associates this column with the table aTableView.
	 * </p>
	 * <p>
	 * This method is invoked automatically when a column is added to a table 
	 * view.
	 * </p>
	 */
	public function setTableView(aTableView:NSTableView):Void {
		m_tableView = aTableView;
	}
	
	//******************************************************
	//*                 Controlling size
	//******************************************************
	
	/**
	 * Returns the width of this column.
	 */
	public function width():Number {
		return m_width;
	}
	
	/**
	 * <p>
	 * Sets the width of this column.
	 * </p>
	 * <p>
	 * If this width exceeds the maximum width, it is set to maxWidth.
	 * If it is less than the minimum width, it is set to minWidth.
	 * </p>
	 * <p>
	 * Marks the table view as needing display.
	 * Posts a NSTableViewColumnDidResizeNotification notification on behalf of the
	 * column's table.
	 * </p>
	 */
	public function setWidth(width:Number):Void {
		var oldWidth:Number;
		var tv:NSTableView;
		var nc:NSNotificationCenter;
		var info:NSDictionary;
		
		//
		// If no change, do nothing.
		//
		if (width == m_width) {
			return;
		}
		
		//
		// Limit the width.
		//
		if (width > maxWidth()) {
			width = maxWidth();
		}
		else if (width < minWidth()) {
			width = minWidth();
		}
			
		//
		// Change width
		//
		oldWidth = m_width;
		m_width = width;
		
		//
		// Invalidate table
		//
		tv = tableView();
		tv.tile();
		
		//
		// Post notification
		//
		info = NSDictionary.dictionaryWithObjectsAndKeys(this, "NSTableColumn", oldWidth, "NSOldWidth");
		
		nc = NSNotificationCenter.defaultCenter();
		nc.postNotificationWithNameObjectUserInfo(
			NSTableView.NSTableViewColumnDidResizeNotification,
			tv,
			info);

	}
	
	/**
	 * Returns the minimum width of this column. The column cannot be less than 
	 * this width through user interaction or programmatically.
	 */	
	public function minWidth():Number {
		return m_minWidth;
	}
	
	/**
	 * Sets the min width of this column and expands the column if it is less 
	 * than this value.
	 */
	public function setMinWidth(minWidth:Number):Void {
		m_minWidth = minWidth;
	}
	
	/**
	 * Returns the maximum width of this column. The column cannot exceed this
	 * width through user interaction or programmatically.
	 */
	public function maxWidth():Number {
		return m_maxWidth;
	}
	
	/**
	 * Sets the max width of this column and shrinks the column if it exceeds 
	 * this value.
	 */
	public function setMaxWidth(maxWidth:Number):Void {
		m_maxWidth = maxWidth;
	}
	
	/**
	 * <p>
	 * Returns the receiver’s resizing mask.
	 * </p> 
	 * <p>
	 * See this class' constants for more information.
	 * </p>
	 */
	public function resizingMask():Number {
		return m_resizingMask;
	}
	
	/**
	 * <p>
	 * Sets the column's resizing mask.
	 * </p> 
	 * <p>
	 * See NSTableColumn.NSTableColumn* constants for more information.
	 * </p>
	 */
	public function setResizingMask(resizingMask:Number):Void {
		m_resizingMask = resizingMask;
	}
	
	/**
	 * Resizes the column to completely fit its header cell.
	 *
	 * Limits (minWidth and maxWidth) will change to accommodate the width
	 * of the header if it does not fit within them.
	 *
	 * Marks the table as needing display.
	 */
	public function sizeToFit():Void
	{
		var headerWidth:Number = m_headerCell.cellSize().width;
		
		if (headerWidth == width()) // Do nothing if no change.
			return;
			
		//
		// Change limits if necessary.
		//
		if (headerWidth > maxWidth())
			setMaxWidth(headerWidth);
		else if (headerWidth < minWidth())
			setMinWidth(headerWidth);
			
		setWidth(headerWidth); // results in table needing display and notification
	}
	
	//******************************************************
	//*              Controlling editability
	//******************************************************
	
	/**
	 * Returns if the data cells in the column are editable through a double click.
	 */
	public function isEditable():Boolean {
		return m_isEditable;
	}
	
	/**
	 * If TRUE, the column's data cells are editable when double clicked. If flag is NO it
	 * merely sends the double-click action to the NSTableView’s target. 
	 */
	public function setEditable(flag:Boolean):Void {
		m_isEditable = flag;
	}
	
	//******************************************************
	//*              Setting component cells
	//******************************************************
	
	/**
	 * Returns the cell used to draw the column's header.
	 */
	public function headerCell():NSCell {
		return m_headerCell;
	}
	
	/**
	 * Sets the cell used to draw the column's header.
	 */
	public function setHeaderCell(aCell:NSCell):Void {
		m_headerCell = aCell;	
	}
	
	/**
	 * Returns the cell used to render data cells.
	 */
	public function dataCell():NSCell {
		return m_dataCell;
	}
	
	/**
	 * Sets the cell used to render data cells.
	 */
	public function setDataCell(aCell:NSCell):Void {
		m_dataCell = aCell;
	}
	
	/**
	 * <p>Returns dataCell() by default.</p>
	 *
	 * <p>Can be overridden by subclasses for row-specific cell handling.</p>
	 */
	public function dataCellForRow(row:Number):NSCell {
		var cell:NSCell = m_matrix.dataCellForRow(row);
		if (cell != null) {
			return cell;
		}
		
		return dataCell();
	}

	//******************************************************
	//*                    Sorting
	//******************************************************
	
	/**
	 * Returns the column's sort descriptor.
	 */
	public function sortDescriptorPrototype():NSSortDescriptor {
		return m_sortDescriptor;
	}
	
	/**
	 * Sets the receiver’s sort descriptor prototype. A table column is
	 * considered sortable if it has a sort descriptor that specifies the
	 * sorting direction, a key to sort by, and a selector defining how to sort.
	 */
	public function setSortDescriptorPrototype(sortDescriptor:NSSortDescriptor):Void {
		var sel:String = sortDescriptor.selector();
		var key:String = sortDescriptor.key();
		
		if (sel == undefined || sel.length == 0 || key == undefined 
				|| key.length == 0) {
			return;
		}
			
		m_sortDescriptor = sortDescriptor;
	}
		
	//******************************************************															 
	//*                 Internal Methods
	//******************************************************
	
	/**
	 * <p>Stores a special indicator image for the column.</p>
	 * 
	 * <p>For internal use only.</p>
	 */
	public function indicatorImage():NSImage {
		return m_indicator;
	}
	
	/**
	 * <p>Stores a special indicator image for the column.</p>
	 * 
	 * <p>For internal use only.</p>
	 */
	public function setIndicatorImage(anImage:NSImage):Void	{
		m_indicator = anImage;
	}
	
	/**
	 * <p>Returns the matrix used by this column.</p>
	 * 
	 * <p>For internal use only.</p>
	 */
	public function columnMatrix():ASTableMatrix {		
		return m_matrix;
	}
	
	/**
	 * <p>Sets the matrix used by this column.</p>
	 * 
	 * <p>For internal use only.</p>
	 */
	public function setColumnMatrix(matrix:ASTableMatrix):Void {
		m_matrix = matrix;
	}
}
