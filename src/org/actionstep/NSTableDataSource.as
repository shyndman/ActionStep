/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSDragOperation;
import org.actionstep.constants.NSTableViewDropOperation;
import org.actionstep.NSArray;
import org.actionstep.NSDraggingInfo;
import org.actionstep.NSIndexSet;
import org.actionstep.NSPasteboard;
import org.actionstep.NSRange;
import org.actionstep.NSTableColumn;
import org.actionstep.NSTableView;

/**
 * Declares methods that an NSTableView uses to access data.
 *
 * Note:  
 * 	Some of the methods in this protocol, such as 
 *	tableViewObjectValueForTableColumnRow and numberOfRowsInTableView along
 *	with other methods that return data, are called very frequently, so they 
 *	must be efficient.
 *
 * @author Scott Hyndman
 */
interface org.actionstep.NSTableDataSource {
	
	//******************************************************
	//*                  Getting values
	//******************************************************
			
	/**
	 * <p>
	 * Returns the number of rows in the data source managed for aTableView.
	 * </p>
	 * <p>
	 * This method must be FAST.
	 * </p>
	 */
	public function numberOfRowsInTableView(aTableView:NSTableView):Number;
	
	/**
	 * <p>
	 * Returns the value for aTableView at rowIndex. The column aTableColumn 
	 * contains the identifier (NSTableColumn::identifier()) for the attribute.
	 * </p>
	 * <p>
	 * This method must be efficient.
	 * </p>
	 */
	public function tableViewObjectValueForTableColumnRow(
		aTableView:NSTableView, aTableColumn:NSTableColumn, rowIndex:Number
		):Object;
		
	/**
	 * <p>
	 * Returns the values for aTableView at in a row range. The column aTableColumn 
	 * contains the identifier (NSTableColumn::identifier()) for the attribute.
	 * </p>
	 * <p>
	 * This method must be efficient.
	 * </p>
	 */
	public function tableViewObjectValuesForTableColumnRange(
		aTableView:NSTableView, aTableColumn:NSTableColumn, range:NSRange
		):NSArray;
		
	//******************************************************
	//*                Setting values
	//******************************************************
	
	/**
	 * <p>
	 * Sets the value for an object in <code>aTableView</code> at rowIndex. The 
	 * column <code>aTableColumn</code> contains the identifier 
	 * (<code>NSTableColumn::identifier()</code>) for the attribute.
	 * </p>
	 */
	public function tableViewSetObjectValueForTableColumnRow(
		aTableView:NSTableView, anObject:Object, aTableColumn:NSTableColumn, 
		rowIndex:Number):Void;
		
	//******************************************************
	//*                  Dragging
	//******************************************************
	
	/**
	 * <p>
	 * Invoked by <code>aTableView</code> when the mouse button is released over
	 * a table view that previously decided to allow a drop.
	 * </p>
	 * <p>
	 * <code>info</code> contains details on this dragging operation. The 
	 * proposed location is <code>row</code> and action is 
	 * <code>operation</code>. The data source should incorporate the data from 
	 * the dragging pasteboard at this time.
	 * </p>
	 * <p>
	 * To accept a drop on the second row, <code>row</code> would be 2 and 
	 * operation would be <code>NSTableViewDropOn</code>. To accept a drop below 
	 * the last row, row would be {@link aTableView#numberOfRows()} and 
	 * operation would be <code>NSTableViewDropAbove</code>.
	 * </p>
	 * <p>
	 * Implementation of this method is optional.
	 * </p>
	 */
	public function tableViewAcceptDropRowDropOperation(
		aTableView:NSTableView, info:NSDraggingInfo, row:Number, 
		operation:NSTableViewDropOperation):Boolean;
	
	/**
	 * <p>
	 * Used by <code>aTableView</code> to determine a valid drop target.
	 * </p>
	 * <p>
	 * <code>info</code> contains details on this dragging operation. The 
	 * proposed location is <code>row</code> and the proposed action is 
	 * <code>operation</code>. Based on the mouse position, the table view will 
	 * suggest a proposed drop location. This method must return a value that 
	 * indicates which dragging operation the data source will perform. The data 
	 * source may “retarget” a drop if desired by calling 
	 * {@link NSTableView#setDropRowDropOperation()} and returning something 
	 * other than <code>NSDragOperationNone</code>. One may choose to retarget 
	 * for various reasons (e.g. for better visual feedback when inserting into 
	 * a sorted position).
	 * </p>
	 * <p>
	 * Implementation of this method is optional.
	 * </p>
	 */
	public function tableViewValidateDropProposedRowProposedDropOperation(
		aTableView:NSTableView, validateDrop:NSDraggingInfo, row:Number,
		operation:NSTableViewDropOperation):NSDragOperation;
	
	/**
	 * <p>
	 * Invoked by the table view after it has been determined that a drag should 
	 * begin, but before the drag has been started.
	 * </p>
	 * <p>
	 * The <code>aTableView</code> parameter represents the table view. To 
	 * refuse the drag, return <code>false</code>. To start a drag, return 
	 * <code>true</code> and place the drag data onto pboard (data, owner, and 
	 * so on). The drag image and other drag-related information will be set up 
	 * and provided by the table view once this call returns with 
	 * <code>true</code>. <code>rowIndexes</code> is an index set of row numbers
	 * that will be participating in the drag.
	 * </p>
	 * <p>
	 * Implementation of this method is optional.
	 * </p> 
	 */
	public function tableViewWriteRowsWithIndexesToPasteboard(
		aTableView:NSTableView, rowIndexes:NSIndexSet, pboard:NSPasteboard):Boolean;
	
	//******************************************************
	//*                    Sorting
	//******************************************************
	
	/**
	 * <p>
	 * Invoked by <code>aTableView</code> to indicate that sorting may need to 
	 * be done.
	 * </p>
	 * <p>
	 * Typically the receiver will sort its data, reload, and adjust selections.
	 * Implementation of this method is optional.
	 * </p>
	 */
	public function tableViewSortDescriptorsDidChange(
		aTableView:NSTableView, oldDescriptors:NSArray):Void;
}
