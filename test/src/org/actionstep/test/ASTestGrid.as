/* See LICENSE for copyright and terms of use */
 
import org.actionstep.ASTextRenderer;
import org.actionstep.layout.ASGrid;
import org.actionstep.layout.ASHBox;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSColor;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTextField;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.test.ASTestView;

/**
 * Test for <code>org.actionstep.layout.ASGrid</code>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestGrid {
	public static function test() {
		//
		// Create app and content view
		//
		var app:NSApplication = NSApplication.sharedApplication();
		var window:NSWindow = (new NSWindow()).initWithContentRect(new NSRect(0,0,500,310));
		var view:ASTestView = ASTestView((new ASTestView()).initWithFrame(new NSRect(0,0,500,310)));
		view.setBackgroundColor(new NSColor(0x999999));
		window.setContentView(view);
		
		//
		// Create description text
		//
		var description:ASTextRenderer = (new ASTextRenderer()).initWithFrame(
			new NSRect(10, 10, 480, 50));
		description.setTopMargin(0);
		description.setBottomMargin(0);
		description.setRightMargin(0);
		description.setLeftMargin(0);
		description.setDrawsBackground(false);
		description.setWordWrap(true);

		description.setStyleCSS(
			"desc {" +
			"	font-family: Verdana;" +
			"	font-size: 11;" +
			"}");
		description.setText("<desc>Test the ASTable by changing its size " +
			"using the 'Width' and 'Height' fields below, then press the " +
			"'Apply' button.");
		view.addSubview(description);
		
		//
		// Create width and height controls.
		//			
		var hb:ASHBox = (new ASHBox()).init();
		hb.setBorder(4);
		view.addSubview(hb);
		
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
		
		var btnApply:NSButton = (new NSButton()).initWithFrame(new NSRect(220, 60, 60, 23));
		btnApply.setStringValue("Apply");
		hb.addViewWithMinXMargin(btnApply,15);
		
		hb.setFrameOrigin(new NSPoint(10, 60));
		
		//
		// Create table
		//
		var tblHolder:ASTestView = ASTestView((new ASTestView()).initWithFrame(
			new NSRect(10, 110, 476, 190)));
		tblHolder.setBackgroundColor(new NSColor(0x009900));
		view.addSubview(tblHolder);
		
		var tbl:ASGrid = (new ASGrid()).initWithNumberOfRowsNumberOfColumns(3, 3);
		tbl.setBorder(3);
		tbl.setXResizingEnabledForColumn(false, 0);
		tbl.setXResizingEnabledForColumn(true, 1);
		tbl.setXResizingEnabledForColumn(false, 2);
		tbl.setYResizingEnabledForRow(true, 0);
		tbl.setYResizingEnabledForRow(false, 1);
		tbl.setYResizingEnabledForRow(true, 2);
		tblHolder.addSubview(tbl);
		
		var btn1:NSButton = (new NSButton()).initWithFrame(new NSRect(0,0,60,22));
		btn1.setAutoresizingMask(NSView.HeightSizable);
		tbl.putViewAtRowColumn(btn1, 0, 0);

		var btn2:NSButton = (new NSButton()).initWithFrame(new NSRect(0,0,60,22));
		btn2.setAutoresizingMask(NSView.WidthSizable);
		tbl.putViewAtRowColumn(btn2, 1, 1);
		
		var btn3:NSButton = (new NSButton()).initWithFrame(new NSRect(0,0,60,22));
		btn3.setAutoresizingMask(NSView.HeightSizable);
		tbl.putViewAtRowColumn(btn3, 2, 2);
		
		//
		// Prepopulate text fields
		//
		txtWidth.setStringValue(tbl.frame().size.width.toString());
		txtHeight.setStringValue(tbl.frame().size.height.toString());
		
		//
		// Set delgate
		//
		var del:Object = {};
		del.changeTableSize = function() {
			tbl.setFrameSize(new NSSize(Number(txtWidth.stringValue()), 
				Number(txtHeight.stringValue())));
		};
		btnApply.setTarget(del);
		btnApply.setAction("changeTableSize");
		
		app.run();
	}
}