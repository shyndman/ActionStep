/* See LICENSE for copyright and terms of use */

import org.actionstep.NSBrowser;
import org.actionstep.NSCell;
import org.actionstep.NSMatrix;

/**
 * <p>This is not an interface that you actually need to implement. Rather, these
 * are the method signitures that the browser will expect on its delegate</p>
 * 
 * <p>You can implement as few or as many of these methods as you like (read
 * the method comments for special requirements), and the browser will 
 * accomodate the delegate as required.</p>
 * 
 * <p>For an example of a passive browser delegate, see the 
 * {@link org.actionstep.browser.ASXmlBrowserDelegate} class.</p>
 * 
 * @see NSBrowser
 * @see NSBrowser#setDelegate()
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.browser.ASBrowserDelegate {
	
	//******************************************************
	//*                  Creating rows
	//******************************************************
	
	/**
	 * <p>Creates a row in <code>matrix</code> for each row of data to be 
	 * displayed in <code>column</code> of the browser.</p>
	 * 
	 * <p>Either this method or {@link #browserNumberOfRowsInColumn} must be 
	 * implemented, but not both (or an <code>NSException</code> will be 
	 * raised).</p>
	 * 
	 * @see #browserWillDisplayCellAtRowColumn()
	 */
	public function browserCreateRowsForColumnInMatrix(sender:NSBrowser,
		column:Number,
		matrix:NSMatrix):Void;
		
	//******************************************************
	//*                 Displaying a cell
	//******************************************************
	
	/**
	 * <p>This method gives the delegate the opportunity to modify the specified 
	 * <code>cell</code> at <code>row</code> in <code>column</code> before it’s 
	 * displayed by the <code>NSBrowser</code>.</p>
	 * 
	 * <p>The delegate should set any state necessary for the correct display of 
	 * the cell.</p>
	 * 
	 * @see #browserCreateRowsForColumnInMatrix()
	 * @see #browserNumberOfRowsInColumn()
	 */
	public function browserWillDisplayCellAtRowColumn(sender:NSBrowser,
		cell:NSCell,
		row:Number,
		column:Number):Void;
		
	//******************************************************
	//*         Getting information about a browser
	//******************************************************
	
	/**
	 * <p>Returns whether the contents of the column, specified by 
	 * <code>column</code>, are valid.</p>
	 * 
	 * <p>If <code>false</code> is returned, <code>sender</code> reloads the 
	 * column. This method is invoked in response to 
	 * {@link NSBrowser#validateVisibleColumns()} being sent to sender.</p>
	 */
	public function browserIsColumnValid(sender:NSBrowser,
		column:Number):Boolean;
		
	/**
	 * <p>Returns the number of rows of data in the column at index 
	 * <code>column</code>.</p>
	 * 
	 * <p>Either this method or {@link #browserCreateRowsForColumnInMatrix()} 
	 * must be implemented, but not both.</p>
	 * 
	 * @see #browserWillDisplayCellAtRowColumn()
	 */
	public function browserNumberOfRowsInColumn(sender:NSBrowser,
		column:Number):Number;
		
	/**
	 * <p>Asks the delegate for the title to display above the column at index 
	 * <code>column</code>.</p>
	 * 
	 * <p>This method is completely optional.</p>
	 * 
	 * @see NSBrowser#setTitleOfColumn()
	 * @see NSBrowser#titleOfColumn()
	 */
	public function browserTitleOfColumn(sender:NSBrowser,
		column:Number):String;
		
	//******************************************************
	//*                    Selecting
	//******************************************************
	
	/**
	 * <p>Asks the delegate to select the NSCell with title <code>title</code> 
	 * in the column at index <code>column</code>.</p>
	 * 
	 * <p>It is the delegate’s responsibility to select the cell, rather than 
	 * the browser. If the delegate returns <code>false</code>, the NSCell was 
	 * not selected; otherwise <code>true</code> is returned. Invoked in 
	 * response to {@link NSBrowser#setPath()} being received by 
	 * <code>sender</code>.</p>
	 * 
	 * @see NSBrowser#selectedCellInColumn()
	 */
	public function browserSelectCellWithStringInColumn(sender:NSBrowser,
		title:String,
		column:Number):Boolean;
		
	/**
	 * <p>Asks the delegate to select the NSCell at row <code>row</code> in the 
	 * column at index <code>column</code>.</p>
	 * 
	 * <p>It is the delegate’s responsibility to select the cell, rather than 
	 * the browser. If the delegate returns <code>false</code>, the NSCell was 
	 * not selected; otherwise <code>true</code> is returned. Invoked in 
	 * response to {@link NSBrowser#selectRowInColumn()} being received by 
	 * <code>sender</code>.</p>
	 * 
	 * @see NSBrowser#selectedRowInColumn()
	 * @see NSBrowser#selectRowInColumn()
	 */
	public function browserSelectRowInColumn(sender:NSBrowser,
		row:Number,
		column:Number):Boolean;
		
	//******************************************************
	//*                    Scrolling
	//******************************************************
	
	/**
	 * Notifies the delegate when the NSBrowser has scrolled.
	 */
	public function browserDidScroll(sender:NSBrowser):Void;
	
	/**
	 * Notifies the delegate when the NSBrowser will scroll.
	 */
	public function browserWillScroll(sender:NSBrowser):Void;
	
	//******************************************************
	//*                 Resizing columns
	//******************************************************
	
	/**
	 * <p>Used for determining a column’s initial size.</p>
	 * 
	 * <p>Implementation is optional and applies only to browsers with resize 
	 * type 
	 * {@link org.actionstep.constants.NSBrowserColumnResizingType#NSBrowserNoColumnResizing} 
	 * or {@link NSBrowserColumnResizingType#NSBrowserUserColumnResizing}. 
	 * When this method is called, it includes a suggested width for the column.
	 * This method should return your desired initial width for a newly added 
	 * column. If you want to accept the suggested width, return 
	 * <code>suggestedWidth</code>. If you return <code>0</code> or a size too 
	 * small to display the resize handle and a portion of the column, the 
	 * actual size used will be larger than you requested.</p>
	 * 
	 * <p>As currently implemented, this method is always called with 
	 * <code>forUserResize</code> set to <code>false</code>.</p>
	 * 
	 * @see NSBrowser#setWidthOfColumn()
	 */
	public function browserShouldSizeColumnForUserResizeToWidth(
		sender:NSBrowser,
		columnIndex:Number,
		forUserResize:Boolean,
		suggestedWidth:Number):Number;
		
	/**
	 * <p>Returns the ideal width for a column.</p>
	 * 
	 * <p>Implementation is optional and is for browsers with resize type 
	 * {@link NSBrowserColumnResizingType#NSBrowserUserColumnResizing} only. 
	 * This method is used when performing a "right-size" operation; that is, 
	 * when sizing a column to the smallest width that contains all the content 
	 * without clipping or truncating. If <code>columnIndex</code> is 
	 * <code>–1</code>, the result is used for a "right-size-all" operation. 
	 * In that case, you should return a size that can be uniformly applied to 
	 * all columns (that is, every column will be set to this size). It is 
	 * assumed that the implementation may be expensive, so it will be called 
	 * only when necessary.</p>
	 */
	public function browserSizeToFitWidthOfColumn(
		sender:NSBrowser,
		columnIndex:Number):Number;
}