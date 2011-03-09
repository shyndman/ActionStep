/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSTextAlignment;
import org.actionstep.constants.NSWritingDirection;
import org.actionstep.NSArray;
import org.actionstep.NSColor;
import org.actionstep.NSEnumerator;
import org.actionstep.NSException;
import org.actionstep.NSFont;
import org.actionstep.NSFormCell;
import org.actionstep.NSMatrix;
import org.actionstep.NSRect;
import org.actionstep.NSSize;

/**
 * An <code>NSForm</code> is a vertical <code>NSMatrix</code> of 
 * <code>NSFormCell</code>s.
 *
 * <code>NSForm</code> uses <code>NSFormCell</code> to implement its user 
 * interface.
 * 
 * Some important things to note:
 * When an entry is added to the form, it is not immediately visible. You must
 * call <code>formInstance.setNeedsDisplay(true);</code> to trigger the redraw.
 * 
 * For an example of this class' usage, please see
 * <code>org.actionstep.test.ASTestForm</code>.
 * 
 * @see org.actionstep.NSFormCell
 * @author Scott Hyndman
 */
class org.actionstep.NSForm extends NSMatrix {
	
	//******************************************************
	//*                     Members
	//******************************************************
		
	private var m_largesttitlewidth:Number;
	private var m_cellwritingdirection:NSWritingDirection;
	private var m_celltextwritingdirection:NSWritingDirection;
	private var m_cellfont:NSFont;
	private var m_celltextalignment:NSTextAlignment;
	private var m_cellalignment:NSTextAlignment;
	private var m_celltextfont:NSFont;
	private var m_bordered:Boolean;
	private var m_bezeled:Boolean;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of <code>NSForm</code>.
	 */	
	public function NSForm() {
		m_cellClass = NSFormCell;
		m_cellSize = new NSSize(100, 22);     
		m_largesttitlewidth = 0;
		m_bgColor = new NSColor(0xE3E3E3);
		m_cellSpacing = new NSSize(1, 1);
	}
	
	/**
	 * Initializes the form with the frame as specified by 
	 * <code>frameRect</code>.
	 *
	 * Entry width is set to the frame's width.
	 */
	public function initWithFrame(frameRect:NSRect):NSForm {
		super.initWithFrame(frameRect);
		setAllowsEmptySelection(true);
		
		m_cellSize.width = frameRect.size.width;
				
		return this;
	}
	
	//******************************************************
	//*              Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the <code>NSForm</code> instance.
	 */
	public function description():String {
		return "NSForm()";
	}
	
	//******************************************************
	//*            Adding and removing entries
	//******************************************************
	
	/**
	 * Adds a new entry to the end of the receiver and gives it the title
	 * <code>title</code>. The new entry has no tag, target, or action, but is 
	 * enabled and editable.
	 * 
	 * Returns the newly added <code>NSFormCell</code>.
	 */
	public function addEntry(title:String):NSFormCell {
		return insertEntryAtIndex(title, numberOfRows());
	}
	
	/**
	 * Inserts an entry with the title <code>title</code> at the position in the
	 * receiver specified by <code>entryIndex</code>. The new entry has no tag, 
	 * target, or action, and, as explained in the class description, it won’t 
	 * appear on the screen automatically.
	 *
	 * Returns the newly inserted NSFormCell.
	 */
	public function insertEntryAtIndex(title:String, 
			entryIndex:Number):NSFormCell {
		//
		// Build and insert the cell
		//
		var cell:NSFormCell = (new NSFormCell()).initTextCell(title);
		prepareCell(cell);
		recalcTitleWidthWithNewWidth(cell.titleWidth());
		cell.setTitleWidth(m_largesttitlewidth);
		insertRowWithCells(entryIndex, NSArray.arrayWithObject(cell));		
		
		return cell;
	}
	
	/**
	 * Removes the entry at <code>entryIndex</code> and frees it. If 
	 * <code>entryIndex</code> is not a valid position in the receiver, does 
	 * nothing.
	 */
	public function removeEntryAtIndex(entryIndex:Number):Void {
		removeRow(entryIndex);
		recalcTitleWidth();
	}
	
	//******************************************************
	//*     Changing the appearance of all the entries
	//******************************************************
	
	/**
	 * If <code>flag</code> is <code>true</code>, sets all the entries in the 
	 * receiver to show a bezel around their editable text; if <code>flag</code>
	 * is <code>false</code>, sets all the entries to show no bezel.
	 */
	public function setBezeled(flag:Boolean):Void {
		m_bezeled = flag;
		
		//
		// Loop through the cells, setting the flag.
		//
		var cells:NSArray = m_cells;
		var itr:NSEnumerator = cells.objectEnumerator();
		var cell:NSFormCell;
		
		while (null != (cell = NSFormCell(itr.nextObject()))) {
			cell.setBezeled(flag);
		}
	}
	
	/** 
	 * Sets whether the entries in the receiver display a border—that is, a
	 * thin line—around their editable text fields. If <code>flag</code> is 
	 * <code>true</code>, they display a border; otherwise, they don’t. An entry
	 * can have a border or a bezel, but not both.
	 */
	public function setBordered(flag:Boolean):Void {
		m_bordered = flag;
		
		//
		// Loop through the cells, setting the flag.
		//
		var cells:NSArray = m_cells;
		var itr:NSEnumerator = cells.objectEnumerator();
		var cell:NSFormCell;
		
		while (null != (cell = NSFormCell(itr.nextObject()))) {
			cell.setBordered(flag);
		}
	}
	
	/**
	 * Sets the width (in pixels) of all the entries in the receiver. This
	 * width includes both the title and the text field. 
	 */
	public function setEntryWidth(width:Number):Void {
		m_cellSize.width = width;
	}
	
	/**
	 * Sets the receiver’s frame size to be <code>newSize</code>. The width of 
	 * <code>NSFormCells</code> always match the width of the 
	 * <code>NSForm</code>. The cell width is always changed to match the view 
	 * regardless of the value returned by <code>#autosizesCells()</code>.
	 */
	public function setFrameSize(newSize:NSSize):Void {
		m_cellSize.width = newSize.width;
		super.setFrameSize(newSize);
	}
	
	/**
	 * Sets the number of pixels between entries in the receiver to 
	 * <code>spacing</code>.
	 */
	public function setInterlineSpacing(spacing:Number):Void {
		setIntercellSpacing(new NSSize(0, spacing));
	}
	
	/**
	 * Sets the alignment for all of the entry titles. <code>alignment</code> 
	 * can be one of three constants: <code>NSRightTextAlignment</code>, 
	 * <code>NSCenterTextAlignment</code>, or the default, 
	 * <code>NSLeftTextAlignment</code>.
	 */
	public function setTitleAlignment(alignment:NSTextAlignment):Void {
		//
		// Not valid arguments
		//
		if (alignment == NSTextAlignment.NSJustifiedTextAlignment 
				|| alignment == NSTextAlignment.NSNaturalTextAlignment) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"Only supported alignment values are NSRightTextAlignment "
				+ ", NSCenterTextAlignment, or NSLeftTextAlignment.",
				null);
			trace(e);
			throw e;
		}
		
		m_cellalignment = alignment;
		
		//
		// Loop through the cells, setting the title alignment.
		//
		var cells:NSArray = m_cells;
		var itr:NSEnumerator = cells.objectEnumerator();
		var cell:NSFormCell;
		
		while (null != (cell = NSFormCell(itr.nextObject()))) {
			cell.setTitleAlignment(alignment);
		}
	}
	
	/**
	 * Sets the writing direction for the title of every control embedded in
	 * the form.
	 */
	public function setTitleBaseWritingDirection(
			writingDirection:NSWritingDirection):Void {
		m_cellwritingdirection = writingDirection;
		
		//
		// Loop through the cells, setting the writing direction.
		//
		var cells:NSArray = m_cells;
		var itr:NSEnumerator = cells.objectEnumerator();
		var cell:NSFormCell;
		
		while (null != (cell = NSFormCell(itr.nextObject()))) {
			cell.setTitleBaseWritingDirection(writingDirection);
		}
	}
	
	/**
	 * Sets the alignment for all of the receiver’s editable text. 
	 * <code>alignment</code> can be one of three constants: 
	 * <code>NSRightTextAlignment</code>, <code>NSCenterTextAlignment</code>, or
	 * <code>NSLeftTextAlignment</code> (the default).
	 */
	public function setTextAlignment(alignment:NSTextAlignment):Void {
		//
		// Not valid arguments
		//
		if (alignment == NSTextAlignment.NSJustifiedTextAlignment ||
				alignment == NSTextAlignment.NSNaturalTextAlignment) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"setTextAlignment can only take alignment " +
				"values of NSRightTextAlignment, NSCenterTextAlignment, or " +
				"NSLeftTextAlignment", null);
			trace(e); // annotate the exception
			throw e;
		}
			
		m_celltextalignment = alignment;
			
		//
		// Loop through the cells, setting the alignment.
		//
		var cells:NSArray = m_cells;
		var itr:NSEnumerator = cells.objectEnumerator();
		var cell:NSFormCell;
		
		while (null != (cell = NSFormCell(itr.nextObject()))) {
			cell.setAlignment(alignment);
		}
	}
	
	
	/**
	 * Sets the writing direction for the text content of every control
	 * embedded in the form.
	 */
	public function setTextBaseWritingDirection(
			writingDirection:NSWritingDirection):Void {
		m_celltextwritingdirection = writingDirection;
		
		//
		// Loop through the cells, setting the title font.
		//
		var cells:NSArray = m_cells;
		var itr:NSEnumerator = cells.objectEnumerator();
		var cell:NSFormCell;
		
		while (null != (cell = NSFormCell(itr.nextObject()))) {
			//! TODO cell.setBaseWritingDirection(writingDirection);
		}
	}
	
	/**
	 * Sets the font for all of the entry titles to <code>font</code>.
	 */
	public function setTitleFont(font:NSFont):Void {
		m_cellfont = font;
		
		//
		// Loop through the cells, setting the title font.
		//
		var cells:NSArray = m_cells;
		var itr:NSEnumerator = cells.objectEnumerator();
		var cell:NSFormCell;
		
		while (null != (cell = NSFormCell(itr.nextObject()))) {
			cell.setTitleFont(font);
		}
	}
	
	/**
	 * Sets the font for all of the receiver’s editable text fields to 
	 * <code>font</code>.
	 */
	public function setTextFont(font:NSFont):Void {
		m_celltextfont = font;
		
		//
		// Loop through the cells, setting the title font.
		//
		var cells:NSArray = m_cells;
		var itr:NSEnumerator = cells.objectEnumerator();
		var cell:NSFormCell;
		
		while (null != (cell = NSFormCell(itr.nextObject()))) {
			cell.setFont(font);
		}
	}
	
	//******************************************************
	//*            Getting cells and indices
	//******************************************************
	
	/**
	 * Returns the index of the entry whose tag is <code>anInt</code>.
	 */
	public function indexOfCellWithTag(anInt:Number):Number {
		//
		// Loop through the cells, setting the title font.
		//
		var cells:NSArray = m_cells;
		var itr:NSEnumerator = cells.objectEnumerator();
		var cell:NSFormCell;
		var cnt:Number = 0;
		
		while (null != (cell = NSFormCell(itr.nextObject()))) {
			if (cell.tag() == anInt) {
				return cnt;
			}
				
			cnt++;
		}
		
		return null;
	}
	
	/**
	 * Returns the index of the selected entry. If no entry is selected,
	 * <code>#indexOfSelectedItem</code> returns <code>NSNotFound</code>.
	 */ 
	public function indexOfFirstSelectedItem():Number {
		if (m_sel.count() == 0) {
			return NSNotFound;
		} 
		
		return m_sel.lastObject().row;
	}
	
	/**
	 * Returns the entry specified by <code>entryIndex</code>.
	 */
	public function cellAtIndex(entryIndex:Number):NSFormCell {
		return NSFormCell(m_cells.objectAtIndex(entryIndex).objectAtIndex(0));
	}
	
	//******************************************************
	//*                  Displaying a cell
	//******************************************************
	
	/**
	 * Displays the entry specified by <code>entryIndex</code>. Because this 
	 * method is called automatically whenever a cell needs drawing, you never 
	 * need to invoke it explicitly. It is included in the API so you can 
	 * override it if you subclass <code>NSFormCell</code>.
	 */
	public function drawCellAtIndex(entryIndex:Number):Void {
		drawCellAtRowColumn(entryIndex, 0);
	}
	
	//******************************************************
	//*                   Editing text
	//******************************************************
	
	/**
	 * Selects the entry at <code>entryIndex</code>. If <code>entryIndex</code> 
	 * is not a valid position in the receiver, does nothing.
	 */
	public function selectTextAtIndex(entryIndex:Number):Void {
		selectTextAtRowColumn(entryIndex, 0);
	}
	
	//******************************************************
	//*                  Helper methods
	//******************************************************
	
	/**
	 * Prepares a cell for insertion based on the properties of the form.
	 */
	private function prepareCell(aCell:NSFormCell):Void {
		if (m_cellwritingdirection != undefined) {
			aCell.setTitleBaseWritingDirection(m_cellwritingdirection);
		}
					
		if (m_cellfont != undefined) {
			aCell.setTitleFont(m_cellfont);
		}
		
		if (m_cellalignment != undefined) {
			aCell.setTitleAlignment(m_cellalignment);
		}
			
		if (m_bordered != undefined) {
			aCell.setBordered(m_bordered);
		}
			
		if (m_bezeled != undefined) {
			aCell.setBezeled(m_bezeled);
		}
		
		if (m_celltextalignment != undefined) {
			aCell.setAlignment(m_celltextalignment);
		}
		
		if (m_celltextfont != undefined) {
			aCell.setFont(m_celltextfont);
		}
		
		//! FIXME if (m_celltextwritingdirection != undefined)
	}
	
	/**
	 * Recalculates the desired width of this form's titles.
	 */
	private function recalcTitleWidth():Void {
		var cells:Array = m_cells.internalList();
		var len:Number = cells.length;
		var wdth:Number = 0;
		var cell:NSFormCell;
		var cellwdth:Number;
		
		for (var i:Number = 0; i < len; i++) {
			cell = NSFormCell(cells[i]);
			cellwdth = cell.titleWidth();
			
			if (cellwdth > wdth) {
				wdth = cellwdth;
			}
		}
		
		setTitleWidth(wdth);
	}
	
	/**
	 * Sets the title widths of this form's cells to <code>newWidth</code> if
	 * it is greater than the current value.
	 */
	private function recalcTitleWidthWithNewWidth(newWidth:Number):Void {
		if (newWidth <= m_largesttitlewidth) {
			return;
		}
			
		setTitleWidth(newWidth);
	}
	
	/**
	 * Sets the width of all this form's cell titles to <code>newWidth</code>.
	 */
	private function setTitleWidth(newWidth:Number):Void {
		var cells:Array = m_cells.internalList();
		var len:Number = cells.length;
		var cell:NSFormCell;
		
		for (var i:Number = 0; i < len; i++) {
			cell = NSFormCell(cells[i]);
			cell.setTitleWidth(newWidth);
		}
		
		m_largesttitlewidth = newWidth;
	}
}
