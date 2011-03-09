/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.constants.NSButtonType;
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.constants.NSControlSize;
import org.actionstep.layout.ASGrid;
import org.actionstep.NSApplication;
import org.actionstep.NSButton;
import org.actionstep.NSImage;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;

/**
 * This class tests the <code>NSButton</code> class and all of its button
 * types.
 *
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestButtonTypes {

	public static function test() {		
		//
		// Create the application and the window
		//
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = new NSWindow();
		wnd.initWithContentRect(new NSRect(0, 0, 500, 500));
		wnd.setBackgroundColor(ASColors.greenColor().adjustColorBrightnessByFactor(1.5));
		var cnt:NSView = wnd.contentView();

		//
		// Create grid to contain buttons
		//
		var grid:ASGrid = (new ASGrid()).initWithNumberOfRowsNumberOfColumns(
			8, 2);
		grid.setBorder(5);
		cnt.addSubview(grid);

		//
		// Create buttons
		//
		var btnRect:NSRect = new NSRect(0, 0, 175, 25);

		//
		// Create NSMomentaryLightButton button
		//
		var btn1:NSButton = new NSButton();
		btn1.initWithFrame(btnRect);
		btn1.setButtonType(NSButtonType.NSMomentaryLightButton);
		btn1.setTitle("NSMomentaryLightButton");
		grid.putViewAtRowColumnWithMargins(btn1, 0, 0, 3);

		//
		// Create NSPushOnPushOffButton button
		//
		var btn2:NSButton = new NSButton();
		btn2.initWithFrame(btnRect);
		btn2.setButtonType(NSButtonType.NSPushOnPushOffButton);
		btn2.setTitle("NSPushOnPushOffButton");
		grid.putViewAtRowColumnWithMargins(btn2, 0, 1, 3);
		btn2.setEnabled(false);

		//
		// Create NSToggleButton button
		//
		var btn3:NSButton = new NSButton();
		btn3.initWithFrame(btnRect);
		btn3.setButtonType(NSButtonType.NSToggleButton);
		btn3.setTitle("NSToggleButton");
		btn3.setAlternateTitle("alt NSToggleButton");
		grid.putViewAtRowColumnWithMargins(btn3, 1, 0, 3);

		//
		// Create NSSwitchButton button
		//
		var btn4:NSButton = new NSButton();
		btn4.initWithFrame(btnRect);
		btn4.setButtonType(NSButtonType.NSSwitchButton);
		btn4.setTitle("NSSwitchButton");
		btn4.setAlternateTitle("alt NSSwitchButton");
		grid.putViewAtRowColumnWithMargins(btn4, 1, 1, 3);

		//
		// Create NSSwitchButton button
		//
		var btn12:NSButton = new NSButton();
		btn12.initWithFrame(btnRect);
		btn12.setButtonType(NSButtonType.NSSwitchButton);
		btn12.cell().setControlSize(NSControlSize.NSSmallControlSize);
		btn12.setFont(ASTheme.current().systemFontOfSize(
			ASTheme.current().systemFontSizeForControlSize(
				NSControlSize.NSSmallControlSize)));
		btn12.setTitle("NSSwitchButton");
		btn12.setAlternateTitle("alt NSSwitchButton");
		grid.putViewAtRowColumnWithMargins(btn12, 2, 0, 3);
		
		//
		// Create NSSwitchButton button
		//
		var btn13:NSButton = new NSButton();
		btn13.initWithFrame(btnRect);
		btn13.setButtonType(NSButtonType.NSSwitchButton);
		btn13.cell().setControlSize(NSControlSize.NSMiniControlSize);
		btn13.setFont(ASTheme.current().systemFontOfSize(
			ASTheme.current().systemFontSizeForControlSize(
				NSControlSize.NSMiniControlSize)));
		btn13.setTitle("NSSwitchButton");
		btn13.setAlternateTitle("alt NSSwitchButton");
		grid.putViewAtRowColumnWithMargins(btn13, 2, 1, 3);

		//
		// Create NSMomentaryChangeButton button
		//
		var btn6:NSButton = new NSButton();
		btn6.initWithFrame(btnRect);
		btn6.setButtonType(NSButtonType.NSMomentaryChangeButton);
		btn6.setTitle("NSMomentaryChangeButton");
		btn6.setAlternateTitle("NEVER SHOWN");
		grid.putViewAtRowColumnWithMargins(btn6, 3, 1, 3);

		//
		// Create NSOnOffButton button
		//
		var btn7:NSButton = new NSButton();
		btn7.initWithFrame(btnRect);
		btn7.setButtonType(NSButtonType.NSOnOffButton);
		btn7.setTitle("NSOnOffButton");
		btn7.setAlternateTitle("alt NSOnOffButton");
		grid.putViewAtRowColumnWithMargins(btn7, 4, 0, 3);

		//
		// Create NSMomentaryPushInButton button
		//
		var btn8:NSButton = new NSButton();
		btn8.initWithFrame(btnRect);
		btn8.setButtonType(NSButtonType.NSMomentaryPushInButton);
		btn8.setTitle("NSMomentaryPushInButton");
		btn8.setAlternateTitle("NEVER SHOWN");
		grid.putViewAtRowColumnWithMargins(btn8, 4, 1, 3);

		var obj:Object = new Object();
		obj.toggle = function() {
			btn2.setEnabled(!btn2.isEnabled());
		};
		btn8.setTarget(obj);
		btn8.setAction("toggle");

		//
		// Create a button that uses an external icon
		//
		var img:NSImage = (new NSImage()).initWithContentsOfURL
		("test/ultrashock07_800x600.jpg");
		img.setSize(new NSSize(26, 26));
		img.setScalesWhenResized(true);

		var alt:NSImage = (new NSImage()).initWithContentsOfURL
		("test/ultrashock05_800x600.jpg");
		alt.setSize(img.size());
		alt.setScalesWhenResized(img.scalesWhenResized());

		var btn9:NSButton = new NSButton();
		btn9.initWithFrame(btnRect);
		btn9.setImage(img);
		btn9.setImagePosition(NSCellImagePosition.NSImageLeft);
		btn9.setButtonType(NSButtonType.NSToggleButton);
		btn9.setTitle("External Icon");
		btn9.setAlternateTitle("alt External Icon");
		btn9.setAlternateImage(alt);
		grid.putViewAtRowColumnWithMargins(btn9, 5, 0, 3);

		//
		// Create another button that uses the same external icon
		//
		var btn10:NSButton = new NSButton();
		btn10.initWithFrame(btnRect);
		btn10.setImage(img);
		btn10.setImagePosition(NSCellImagePosition.NSImageRight);
		btn10.setButtonType(NSButtonType.NSToggleButton);
		btn10.setTitle("External Icon");
		btn10.setAlternateTitle("alt External Icon");
		btn10.setAlternateImage(alt);
		grid.putViewAtRowColumnWithMargins(btn10, 5, 1, 3);

		//
		// showsBorderOnlyOnMouseInside button
		//
		var btn11:NSButton = new NSButton();
		btn11.initWithFrame(btnRect);
		btn11.setButtonType(NSButtonType.NSMomentaryLightButton);
		btn11.setTitle("Border when mouse inside");
		btn11.setShowsBorderOnlyWhileMouseInside(true);
		btn11.setTag(44);
		grid.putViewAtRowColumnWithMargins(btn11, 3, 0, 3);

		//
		// Create NSRadioButton button
		//
		var btn5:NSButton = new NSButton();
		btn5.initWithFrame(btnRect);
		btn5.setButtonType(NSButtonType.NSRadioButton);
		btn5.setTitle("NSRadioButton");
		btn5.setAlternateTitle("alt NSRadioButton");
		grid.putViewAtRowColumnWithMargins(btn5, 6, 0, 3);
		
		//
		// Create NSRadioButton button
		//
		var btn14:NSButton = new NSButton();
		btn14.initWithFrame(btnRect);
		btn14.setButtonType(NSButtonType.NSRadioButton);
		btn14.cell().setControlSize(NSControlSize.NSSmallControlSize);
		btn14.setFont(ASTheme.current().systemFontOfSize(
			ASTheme.current().systemFontSizeForControlSize(
				NSControlSize.NSSmallControlSize)));
		btn14.setTitle("NSRadioButton");
		btn14.setAlternateTitle("alt NSRadioButton");
		grid.putViewAtRowColumnWithMargins(btn14, 6, 1, 3);
		
		//
		// Create NSRadioButton button
		//
		var btn15:NSButton = new NSButton();
		btn15.initWithFrame(btnRect);
		btn15.setButtonType(NSButtonType.NSRadioButton);
		btn15.cell().setControlSize(NSControlSize.NSMiniControlSize);
		btn15.setFont(ASTheme.current().systemFontOfSize(
			ASTheme.current().systemFontSizeForControlSize(
				NSControlSize.NSMiniControlSize)));
		btn15.setTitle("NSRadioButton");
		btn15.setAlternateTitle("alt NSRadioButton");
		grid.putViewAtRowColumnWithMargins(btn15, 7, 0, 3);
		
		//
		// Run the application
		//
		app.run();
	}
}