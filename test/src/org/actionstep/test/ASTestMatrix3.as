/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.NSButtonType;
import org.actionstep.constants.NSMatrixMode;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSButtonCell;
import org.actionstep.NSCell;
import org.actionstep.NSColor;
import org.actionstep.NSComboBox;
import org.actionstep.NSMatrix;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSSliderCell;
import org.actionstep.NSStepperCell;
import org.actionstep.NSTextFieldCell;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.test.ASTestView;
import org.actionstep.constants.NSTickMarkPosition;
import org.actionstep.NSArray;

/**
 * More tests for <code>NSMatrix</code>...
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestMatrix3 
{	
	public static var g_app:NSApplication;
	public static var g_win:NSWindow;
	public static var g_matrix:NSMatrix;
	
	public static function test():Void
	{		
		var app:NSApplication;
		var window:NSWindow;
		var view:NSView;
		
		//  
		// Setup
		//
		app = g_app = NSApplication.sharedApplication();
		window = g_win = (new NSWindow()).initWithContentRect(new NSRect(0,0,800,600));
		app.run();
		view = (new ASTestView()).initWithFrame(new NSRect(0,0,800,600));
		window.setContentView(view);
		
		//
		// Create combobox for cells
		//
		var combo:NSComboBox = (new NSComboBox()).initWithFrame(
			new NSRect(10, 10, 160, 22));
		combo.setEditable(false);
		combo.addItemsWithObjectValues(NSArray.arrayWithArray([
			"Button", 
			"Checkbox", 
			"Radio button",
			"Stepper",
			"Slider",
			"TextField",
			"Editable TextField"])
			);
		combo.selectItemAtIndex(0);
		combo.setAction("combo_change");
		combo.setTarget(ASTestMatrix3);
		view.addSubview(combo);
		
		//
		// Add test button
		//
		var btn:NSButton = (new NSButton()).initWithFrame(new NSRect(180, 10, 100, 22));
		btn.setTitle("foo");
		view.addSubview(btn);
		
		//
		// Trigger a change
		//
		combo_change(combo);
	}
	
	private static function combo_change(combo:NSComboBox):Void {		
		//
		// Remove old matrix
		//
		g_matrix.release();
		g_matrix.removeFromSuperview();
		
		//
		// Create cell based on selected data
		//
		var cell:NSCell;
		var val:String = combo.objectValueOfSelectedItem().toString();
		
		switch (val) {
			case "Button":
				cell = (new NSButtonCell()).init();
				cell.setTitle("Button");
				NSButtonCell(cell).setButtonType(NSButtonType.NSPushOnPushOffButton);
				break; 
			case "Checkbox":
				cell = (new NSButtonCell()).init();
				NSButtonCell(cell).setButtonType(NSButtonType.NSSwitchButton);
				cell.setTitle("Checkbox");
				break;
			case "Radio button":
				cell = (new NSButtonCell()).init();
				NSButtonCell(cell).setButtonType(NSButtonType.NSRadioButton);
				cell.setTitle("Radio");
				break;
			case "Stepper":
				cell = (new NSStepperCell()).init();
				break;
			case "Slider":
				cell = (new NSSliderCell()).init();
				NSSliderCell(cell).setNumberOfTickMarks(5);
				NSSliderCell(cell).setTickMarkPosition(NSTickMarkPosition.NSTickMarkLeft);
				break;
			case "Editable TextField":
				cell = (new NSTextFieldCell()).initTextCell("Foo");
				cell.setEditable(true);
				break;
			case "TextField":
				cell = (new NSTextFieldCell()).initTextCell("Foo");
				break;
		}
		
		g_matrix = (new NSMatrix()).initWithFrameModePrototypeNumberOfRowsNumberOfColumns
			(new NSRect(10,90,200,270), NSMatrixMode.NSRadioModeMatrix,
			cell, 2, 2);
		g_matrix.setBackgroundColor(new NSColor(0x000099));
		g_matrix.setCellBackgroundColor(new NSColor(0xFFFFFF));
		g_matrix.setIntercellSpacing(new NSSize(3, 3));
		g_win.contentView().addSubview(g_matrix);
	}
}
