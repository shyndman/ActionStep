/* See LICENSE for copyright and terms of use */
 
import org.actionstep.*;
import org.actionstep.test.*;

/**
 * Tests the <code>org.actionstep.ASAnimatedTabView</code> class.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.test.ASTestAnimatedTabView {
  
  public static function test() {
  	//
  	// Create the app an window
  	//
    var app:NSApplication = NSApplication.sharedApplication();
    var window1:NSWindow = (new NSWindow()).initWithContentRect(new NSRect(0,0,500,500));
    
    //
    // Create the tab view
    //
    var tabView:ASAnimatedTabView = ASAnimatedTabView(
		(new ASAnimatedTabView()).initWithFrame(new NSRect(10,10,400,400)));
    tabView.setTabViewType(org.actionstep.constants.NSTabViewType.NSNoTabsNoBorder);

	//
	// Add some tab items
	//
    var tabItem1:NSTabViewItem = (new NSTabViewItem()).initWithIdentifier(1);
    tabItem1.setLabel("This is a long tab");
    var tabItemView1:ASTestView = new ASTestView();
    tabItemView1.initWithFrame(new NSRect(0,0,10,10));
    tabItemView1.setBackgroundColor(new NSColor(0xffff00));
    tabItem1.setView(tabItemView1);
    
    var nextButton:NSButton = (new NSButton()).initWithFrame(new NSRect(80,80,70,30));
    nextButton.setTitle("Next Tab");
    tabItemView1.addSubview(nextButton);
    nextButton.setTarget(tabView);
    nextButton.setAction("selectNextTabViewItem");

    var tabItem2:NSTabViewItem = (new NSTabViewItem()).initWithIdentifier(2);
    tabItem2.setLabel("Short tab");
    var tabItemView2:ASTestView = new ASTestView();
    tabItemView2.initWithFrame(new NSRect(0,0,10,10));
    tabItemView2.setBackgroundColor(new NSColor(0x00ff00));
    tabItem2.setView(tabItemView2);

    var prevButton:NSButton = (new NSButton()).initWithFrame(new NSRect(80,80,70,30));
    prevButton.setTitle("Prev Tab");
    tabItemView2.addSubview(prevButton);
    prevButton.setTarget(tabView);
    prevButton.setAction("selectPreviousTabViewItem");

    tabView.addTabViewItem(tabItem1);
    tabView.addTabViewItem(tabItem2);
    tabView.selectFirstTabViewItem(null);
    window1.setContentView(tabView);
    app.run();
  }
}