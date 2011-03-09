/* See LICENSE for copyright and terms of use */

//import org.actionstep.ASDraw;
import org.actionstep.ASColoredView;
import org.actionstep.ASColors;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSComboBox;
import org.actionstep.NSRect;
import org.actionstep.NSScrollView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.plastic.ASPlasticTheme;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.ASTestPlasticTheme {
	public static function test():Void {
		ASTheme.setCurrent(new ASPlasticTheme());
		var app:NSApplication = NSApplication.sharedApplication();
		var wnd:NSWindow = (new NSWindow()).initWithContentRect(
			new NSRect(0, 0, 500, 300));

		var combo:NSComboBox = (new NSComboBox()).initWithFrame(
			new NSRect(10, 10, 120, 22));
		combo.setEditable(false);
		combo.addItemsWithObjectValues(
			NSArray.arrayWithArray(["foo", "bar", "man", "chu"]));
		combo.selectItemAtIndex(0);
		wnd.contentView().addSubview(combo);

		var scroller:NSScrollView = (new NSScrollView()).initWithFrame(
			new NSRect(10, 40, 200, 200));
		scroller.setHasVerticalScroller(true);
		scroller.setHasHorizontalScroller(true);
		wnd.contentView().addSubview(scroller);

		var view:ASColoredView = new ASColoredView();
		view.initWithFrame(new NSRect(0, 0, 400, 400));
		view.setBorderColor(ASColors.magentaColor());
		view.setBackgroundColor(ASColors.martiniGlassColor());
		scroller.setDocumentView(view);

		app.run();
	}
}