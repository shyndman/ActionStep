/* See LICENSE for copyright and terms of use */

import org.actionstep.ASLabel;
import org.actionstep.NSApplication;
import org.actionstep.ASColors;
import org.actionstep.NSFont;
import org.actionstep.NSRect;
import org.actionstep.NSWindow;
import org.actionstep.constants.NSLineBreakMode;
import org.actionstep.NSButton;
import org.actionstep.NSPoint;
import org.actionstep.NSTextField;
import org.actionstep.layout.ASHBox;
import org.actionstep.NSView;
import org.actionstep.ASColoredView;
import org.actionstep.NSMatrix;
import org.actionstep.constants.NSMatrixMode;
import org.actionstep.NSButtonCell;
import org.actionstep.constants.NSButtonType;
import org.actionstep.NSCell;
import org.actionstep.layout.ASVBox;
import org.actionstep.NSSize;

class org.actionstep.test.ASTestTruncation
{
	public static function test()
	{
		//
		// Build app
		//
		var window:NSWindow = new NSWindow();
		window.initWithContentRect(new NSRect(0, 0, 400, 300));
		window.setBackgroundColor(ASColors.lightGrayColor());

		NSApplication.sharedApplication().run();

		var view:NSView = window.contentView();

		//
		// Create width and height controls.
		//
		var vbox:ASVBox = (new ASVBox()).init();

		var hb:ASHBox = (new ASHBox()).init();
		hb.setBorder(4);

		var lblWidth:NSTextField = (new NSTextField()).initWithFrame(new NSRect(10,60,40,22));
		lblWidth.setDrawsBackground(false);
		lblWidth.setStringValue("Width:");
		lblWidth.setEditable(false);
		lblWidth.setSelectable(false);
		hb.addView(lblWidth);

		var txtWidth:NSTextField = (new NSTextField()).initWithFrame(new NSRect(55,60,50,22));
		hb.addView(txtWidth);

		var lblHeight:NSTextField = (new NSTextField()).initWithFrame(new NSRect(110,60,45,22));
		lblHeight.setDrawsBackground(false);
		lblHeight.setStringValue("Height:");
		lblHeight.setEditable(false);
		lblHeight.setSelectable(false);
		hb.addViewWithMinXMargin(lblHeight,15);

		var txtHeight:NSTextField = (new NSTextField()).initWithFrame(new NSRect(160,60,50,22));
		hb.addView(txtHeight);

		vbox.addView(hb);

		//
		// Label for truncation type
		//
		var lblTruncType:ASLabel = new ASLabel();
		lblTruncType.initWithFrame(new NSRect(10, 45, 150, 20));
		lblTruncType.setStringValue("Truncation type:");
		vbox.addViewWithMinYMargin(lblTruncType, 5);

		//
		// Create truncation type selector.
		//
		var hb2:ASHBox = (new ASHBox()).init();
		hb2.setBorder(4);

		//
		// Create the matrix and its cell class.
		//
		var proto:NSButtonCell = new NSButtonCell();
		proto.setButtonType(NSButtonType.NSRadioButton);
		var typeSelector:NSMatrix = new NSMatrix();
		typeSelector.initWithFrameModePrototypeNumberOfRowsNumberOfColumns(
			new NSRect(0, 0, 372, 23), NSMatrixMode.NSRadioModeMatrix,
			proto, 1, 4);
		typeSelector.setDrawsBackground(false);
		typeSelector.cellAtRowColumn(0, 0).setStringValue("None");
		typeSelector.cellAtRowColumn(0, 1).setStringValue("Head");
		typeSelector.cellAtRowColumn(0, 2).setStringValue("Tail");
		typeSelector.cellAtRowColumn(0, 3).setStringValue("Middle");
		typeSelector.setToolTipForCell(
			"This is some tip text.", typeSelector.cellAtRowColumn(0, 3));
		hb2.addView(typeSelector);

		vbox.addView(hb2);

		//
		// Create the apply button
		//
		var btnApply:NSButton = (new NSButton()).initWithFrame(new NSRect(220, 60, 60, 23));
		btnApply.setStringValue("Apply");
		vbox.addView(btnApply);

		//
		// Create the canvas for the label.
		//
		var canvas:ASColoredView = new ASColoredView();
		canvas.initWithFrame(new NSRect(10, 95, 380, 50));
		canvas.setBackgroundColor(ASColors.greenColor());
		vbox.addViewWithMinYMargin(canvas, 10);

		//
		// Create the font for the label
		//
		var maxWidth:Number = 200;
		var font:NSFont = NSFont.fontWithNameSize("Georgia", 18);

		//
		// Create the label.
		//
		var lbl:ASLabel = new ASLabel();
		lbl.initWithFrame(new NSRect(10, 10, 360, 30));
		lbl.setStringValue("This is an incredibly long and wordy sentence that doesn't actually say anything.");
		lbl.setToolTip("This is an incredibly long and wordy sentence that doesn't actually say anything.");
		lbl.setFont(font);
		lbl.setTextColor(ASColors.whiteColor());
		canvas.addSubview(lbl);

		//
		// Set the initial values for Width and Height
		//
		txtWidth.setStringValue(lbl.frame().width().toString());
		txtHeight.setStringValue(lbl.frame().height().toString());

		//
		// Add the vbox to the container.
		//
		vbox.setFrameOrigin(new NSPoint(10, 10));
		view.addSubview(vbox);

		//
		// Create controller
		//
		var controller:Object = {};
		controller.apply = function():Void
		{
			var width:Number = Number(txtWidth.stringValue());
			var height:Number = Number(txtHeight.stringValue());

			if (!isNaN(width) && !isNaN(height))
			{
				lbl.setFrameSize(new NSSize(width, height));
			}

			var cell:NSCell = typeSelector.selectedCell();
			switch(cell.stringValue())
			{
				case "None":
					lbl.cell().setLineBreakMode(NSLineBreakMode.NSDefaultLineBreak);
					break;

				case "Head":
					lbl.cell().setLineBreakMode(NSLineBreakMode.NSLineBreakByTruncatingHead);
					break;

				case "Tail":
					lbl.cell().setLineBreakMode(NSLineBreakMode.NSLineBreakByTruncatingTail);
					break;

				case "Middle":
					lbl.cell().setLineBreakMode(NSLineBreakMode.NSLineBreakByTruncatingMiddle);
					break;
			}

			lbl.setNeedsDisplay(true);
		};

		btnApply.setTarget(controller);
		btnApply.setAction("apply");
	}
}