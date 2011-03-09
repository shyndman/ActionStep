/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSApplication;
import org.actionstep.NSButtonCell;
import org.actionstep.NSRect;
import org.actionstep.NSScrollView;
import org.actionstep.NSSortDescriptor;
import org.actionstep.NSTableColumn;
import org.actionstep.NSTableView;
import org.actionstep.NSTextFieldCell;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.test.ASTestView;
import org.actionstep.test.table.ASTestTableDataSource;
import org.actionstep.NSSliderCell;
import org.actionstep.constants.NSControlSize;
import org.actionstep.NSImageCell;
import org.actionstep.constants.NSImageScaling;
import org.actionstep.constants.NSImageFrameStyle;
import org.actionstep.NSCell;
import org.actionstep.constants.NSButtonType;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestTable 
{
	public static function test():Void
	{		
		var app:NSApplication = NSApplication.sharedApplication();
		var window1:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0,0,800,600));
		var view:NSView = (new ASTestView()).initWithFrame(
			new NSRect(0,0,800,600));
				
		//
		// Run application
		//
		window1.setContentView(view);
		app.run();
		
		//
		// Create table
		//
		var sv:NSScrollView = (new NSScrollView()).initWithFrame(
			new NSRect(10, 10, 500, 310));
		sv.setHasHorizontalScroller(true);
		sv.setHasVerticalScroller(true);
		view.addSubview(sv);
		
		var table:NSTableView = (new NSTableView()).initWithFrame(
			new NSRect(0, 0, 500, 310));
		table.setGridStyleMask(NSTableView.NSTableViewSolidHorizontalGridLineMask
			| NSTableView.NSTableViewSolidVerticalGridLineMask);
		table.setGridColor(ASColors.grayColor());
		table.setBackgroundColor(ASColors.whiteColor());
		table.setDataSource((new ASTestTableDataSource()).initWithCount(100));
		table.setUsesAlterningRowBackgroundColors(true);
		table.setAllowsColumnSelection(true);
		table.setAllowsMultipleSelection(true);
		
		var col:NSTableColumn;
		var sd:NSSortDescriptor;
		var nameCol:NSTableColumn;
		
		//
		// Blank column
		//
//		col = new NSTableColumn();
//		col.setWidth(20);
//		col.headerCell().setStringValue("");
//				
//		table.addTableColumn(col);
		
		//
		// First name column (text cell)
		//
		nameCol = col = new NSTableColumn();
		col.setWidth(130);
		col.headerCell().setStringValue("First Name");
		col.setIdentifier("firstName");
		col.setResizingMask(NSTableColumn.NSTableColumnUserResizingMask);
		col.setDataCell((new NSTextFieldCell()).initTextCell(""));
		sd = (new NSSortDescriptor()).initWithKeyAscending("firstName", true);
		col.setSortDescriptorPrototype(sd);
		
		table.addTableColumn(col);
		
		//
		// Last name column (text cell)
		//
		col = new NSTableColumn();
		col.setWidth(130);
		col.headerCell().setStringValue("Last Name");
		col.setIdentifier("lastName");
		col.setResizingMask(NSTableColumn.NSTableColumnUserResizingMask);
		col.setDataCell((new NSTextFieldCell()).initTextCell(""));
		col.setEditable(true);
		table.addTableColumn(col);
		
		//
		// Gender column (image cell)
		// 
		col = new NSTableColumn();
		col.setWidth(50);
		col.headerCell().setStringValue("Gender");
		col.setIdentifier("sex");
		col.setResizingMask(NSTableColumn.NSTableColumnNoResizing);
		var cell:NSCell = NSImageCell((new NSImageCell()).initImageCell(null));
		col.setDataCell(cell);
		table.addTableColumn(col);
		
		//
		// View column
		//
		col = new NSTableColumn();
		col.setWidth(50);
		col.headerCell().setStringValue("View");
		cell = (new NSButtonCell()).initTextCell("View");
		NSButtonCell(cell).setButtonType(NSButtonType.NSMomentaryPushInButton);
		cell.setControlSize(NSControlSize.NSSmallControlSize);
		col.setDataCell(cell);
		col.setResizingMask(NSTableColumn.NSTableColumnUserResizingMask);
		table.addTableColumn(col);

		//
		// Mark column
		//
		col = new NSTableColumn();
		col.setWidth(60);
		col.headerCell().setStringValue("Mark");
		cell = (new NSButtonCell()).initTextCell("Mark");
		NSButtonCell(cell).setButtonType(NSButtonType.NSSwitchButton);
		cell.setControlSize(NSControlSize.NSSmallControlSize);
		col.setDataCell(cell);
		col.setResizingMask(NSTableColumn.NSTableColumnUserResizingMask);
		table.addTableColumn(col);
		
		//
		// Age
		//
		col = new NSTableColumn();
		col.setWidth(60);
		col.headerCell().setAlignment(NSTextAlignment.NSRightTextAlignment);
		col.headerCell().setStringValue("Age");
		col.setIdentifier("age");
		col.setEditable(true);
		col.setDataCell((new NSTextFieldCell()).init());
		col.setResizingMask(NSTableColumn.NSTableColumnUserResizingMask);
		sd = (new NSSortDescriptor()).initWithKeyAscending("age", true);
		col.setSortDescriptorPrototype(sd);
		
		table.addTableColumn(col);

		//
		// Set the table data source
		//
		sv.setDocumentView(table);
		
		//
		// Size last column
		//
		//table.sizeLastColumnToFit();
	}
}