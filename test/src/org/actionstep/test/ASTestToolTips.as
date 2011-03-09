/* See LICENSE for copyright and terms of use */

import org.actionstep.ASTextRenderer;
import org.actionstep.NSApplication;
import org.actionstep.NSBox;
import org.actionstep.NSButton;
import org.actionstep.NSColor;
import org.actionstep.NSRect;
import org.actionstep.NSTextField;
import org.actionstep.NSWindow;
import org.actionstep.test.ASTestView;

/**
 * Tests tooltips on <code>NSView</code>s.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestToolTips {
	public static function test():Void {
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
			new NSRect(10, 10, 480, 100));
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
		description.setText("<desc>Test tooltips by entering text in the " +
			"'Tip Text:' field below and pressing the button. The tooltip " +
			"is applied to the green square, which is a subclass of NSView " +
			"(the base class for all controls). Try hovering over the other " +
			"controls as well.<br><br>" +
			"These tooltips are 100% themable through the ActionStep theming API, " +
			"and support various CSS styles.</desc>");
			
		view.addSubview(description);
		
		//
		// Create view who's tip text is changed.
		//
		var testView:ASTestView = ASTestView((new ASTestView()).initWithFrame(
			new NSRect(260, 116, 225, 175)));
		testView.setBackgroundColor(new NSColor(0x009900));
		view.addSubview(testView);	
		
		//
		// Create box with textfield inside
		//
		var tfBox:NSBox = (new NSBox()).initWithFrame(new NSRect(10, 110, 225, 80));
		tfBox.setTitle("ToolTip Controls");
		view.addSubview(tfBox);
		
		var tipText:NSTextField = (new NSTextField()).initWithFrame(new NSRect(75,20,140,22));
		tfBox.addSubview(tipText);
		
		var lblTipText:NSTextField = (new NSTextField()).initWithFrame(new NSRect(10,20,65,22));
		lblTipText.setDrawsBackground(false);
		lblTipText.setStringValue("Tip Text:");
		lblTipText.setEditable(false);
		lblTipText.setSelectable(false);
		tfBox.addSubview(lblTipText);
		
		//
		// Create apply button.
		//
		var btnApply:NSButton = (new NSButton()).initWithFrame(new NSRect(75, 47, 140, 22));
		btnApply.setStringValue("Change Tip Text");
		tfBox.addSubview(btnApply);
		
		var delApply:Object = {};
		delApply.applyToolTip = function() {
			testView.setToolTip(tipText.stringValue());
		};
		
		btnApply.setTarget(delApply);
		btnApply.setAction("applyToolTip");
		
		//
		// Tabbing and default push button stuff
		//
		//window.setInitialFirstResponder(tipText);
		//tipText.setNextResponder(btnApply);
		//btnApply.setNextResponder(tipText);
		//window.setDefaultButtonCell(NSButtonCell(btnApply.cell()));	
				
		app.run();

		//
		// This must follow app.run()
		//
		tipText.setToolTip("The tip text to apply to the test control.");
		btnApply.setToolTip("Click here to change the test control's tip text.<br><br>" +
		"The code actually used is:<br>" +
		"\tview.setToolTip(String);");
	}
}