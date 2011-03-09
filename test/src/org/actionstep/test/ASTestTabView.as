/* See LICENSE for copyright and terms of use */
 
import org.actionstep.*;
import org.actionstep.constants.*;
import org.actionstep.test.*;

/**
 * Test for the <code>org.actionstep.NSTabView</code> class.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.test.ASTestTabView {
  public static function test() {
    var app:NSApplication = NSApplication.sharedApplication();
    var window1:NSWindow = (new NSWindow()).initWithContentRect(new NSRect(0,0,500,500));
    var tabView:NSTabView = new NSTabView();
    tabView.initWithFrame(new NSRect(10,10,400,400));
    
    // tabView.setTabViewType(org.actionstep.constants.NSTabViewType.NSNoTabsNoBorder);
    //tabView.setTabViewType(org.actionstep.constants.NSTabViewType.NSNoTabsLineBorder);

    var tabItem1:NSTabViewItem = (new NSTabViewItem()).initWithIdentifier(1);
    tabItem1.setLabel("This is a long tab");
    var tabItemView1:ASTestView = new ASTestView();
    tabItemView1.initWithFrame(new NSRect(0,0,10,10));
    tabItemView1.setBackgroundColor(new NSColor(0xffff00));
    tabItem1.setView(tabItemView1);
    
    var tabItem2:NSTabViewItem = (new NSTabViewItem()).initWithIdentifier(2);
    tabItem2.setLabel("Short tab");
    var tabItemView2:ASTestView = new ASTestView();
    tabItemView2.initWithFrame(new NSRect(0,0,10,10));
    tabItemView2.setBackgroundColor(new NSColor(0x00ff00));
    tabItem2.setView(tabItemView2);
    
    tabView.addTabViewItem(tabItem1);
    tabView.addTabViewItem(tabItem2);
    
    tabItem2 = (new NSTabViewItem()).initWithIdentifier(3);
    tabItem2.setLabel("Short tab");
    tabItemView2 = new ASTestView();
    tabItemView2.initWithFrame(new NSRect(0,0,10,10));
    tabItemView2.setBackgroundColor(new NSColor(0x00ff00));
    tabItem2.setView(tabItemView2);
    
    tabView.addTabViewItem(tabItem2);
    
    tabItem2 = (new NSTabViewItem()).initWithIdentifier(4);
    tabItem2.setLabel("Short test test test");
    tabItemView2 = new ASTestView();
    tabItemView2.initWithFrame(new NSRect(0,0,10,10));
    tabItemView2.setBackgroundColor(new NSColor(0x00ff00));
    tabItem2.setView(tabItemView2);
    
    tabView.addTabViewItem(tabItem2);
    
    tabItem2 = (new NSTabViewItem()).initWithIdentifier(3);
    tabItem2.setLabel("Short tab");
    tabItemView2 = new ASTestView();
    tabItemView2.initWithFrame(new NSRect(0,0,10,10));
    tabItemView2.setBackgroundColor(new NSColor(0x00ff00));
    tabItem2.setView(tabItemView2);
    
    tabView.addTabViewItem(tabItem2);
    
    tabItem2 = (new NSTabViewItem()).initWithIdentifier(3);
    tabItem2.setLabel("Another short tab");
    tabItemView2 = new ASTestView();
    tabItemView2.initWithFrame(new NSRect(0,0,10,10));
    tabItemView2.setBackgroundColor(new NSColor(0x00ff00));
    tabItem2.setView(tabItemView2);
    
    tabView.addTabViewItem(tabItem2);
    
    tabItem2 = (new NSTabViewItem()).initWithIdentifier(5);
    tabItem2.setLabel("Short tab");
    tabItemView2 = new ASTestView();
    tabItemView2.initWithFrame(new NSRect(0,0,10,10));
    tabItemView2.setBackgroundColor(new NSColor(0x00ff00));
    tabItem2.setView(tabItemView2);
    
    tabView.addTabViewItem(tabItem2);
    
    var view:ASTestView = new ASTestView();
    view.initWithFrame(new NSRect(0, 0, 1024, 350));
    view.setBorderColor(new NSColor(0xff0000));

    var scrollView:NSScrollView = (new NSScrollView()).initWithFrame(new NSRect(0,0,250,250));
    scrollView.setBorderType(NSBorderType.NSLineBorder);
    scrollView.setDocumentView(view);
    scrollView.setHasHorizontalScroller(true);
    scrollView.setHasVerticalScroller(true);
    scrollView.contentView().scrollToPoint(new NSPoint(0,100));
    tabItemView2.addSubview(scrollView);

    tabView.setScrollable(true);
    
    tabView.selectFirstTabViewItem(null);
    window1.setContentView(tabView);
    app.run();
  }
}