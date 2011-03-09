/* See LICENSE for copyright and terms of use */

import org.actionstep.*;
import org.actionstep.test.*;
import org.actionstep.constants.*;

/**
 * Tests the <code>org.actionstep.NSScrollView</code> class.
 *
 * @author Richard Kilmer
 */
class org.actionstep.test.ASTestScrollView {
  public static function test() {
    var app:NSApplication = NSApplication.sharedApplication();
    var window1:NSWindow = (new NSWindow()).initWithContentRect(new NSRect(0,0,500,500));

    var view:ASTestView = new ASTestView();
    view.initWithFrame(new NSRect(0, 0, 1024, 350));
    view.setBorderColor(new NSColor(0xff0000));
    view.addHeaderView();
    view.addCornerView();

	var img:NSImage = (new NSImage()).initWithContentsOfURL(
		"http://www.cs.virginia.edu/~sullivan/sdsis/Photos/Landscape%20Airlie%20House.JPG");
	var imgView:NSImageView = (new NSImageView()).initWithFrame(
		new NSRect(0, 0, 2560, 1920));
	imgView.setImage(img);
	
    var scrollView:NSScrollView = (new NSScrollView()).initWithFrame(new NSRect(0,0,500,500));
    scrollView.setBorderType(NSBorderType.NSBezelBorder);
    scrollView.setDocumentView(imgView);
    scrollView.setHasHorizontalScroller(true);
    scrollView.setHasVerticalScroller(true);	
	
    var btn:NSButton = (new NSButton()).initWithFrame(new NSRect(10, 60, 100, 25));
    btn.setTitle("FOO");
    view.addSubview(btn);
    
    var grow:NSButton = (new NSButton()).initWithFrame(new NSRect(260,10,70,30));
    grow.setTitle("Grow!");
    var shrink:NSButton = (new NSButton()).initWithFrame(new NSRect(260,90,70,30));
    shrink.setTitle("Shrink!");

    var target:Object = new Object();
    target.shrink = function(button:NSButton) {
      view.setFrameSize(new NSSize(200, 300));
      scrollView.display();
    };
    target.grow = function(button:NSButton) {
      view.setFrameSize(new NSSize(1024, 350));
      scrollView.display();
    };

    shrink.setTarget(target);
    shrink.setAction("shrink");
    grow.setTarget(target);
    grow.setAction("grow");

    
    var view2:ASTestView = new ASTestView();
    view2.initWithFrame(new NSRect(0, 0, 500,500));
    view2.addSubview(scrollView);
    view2.addSubview(grow);
    view2.addSubview(shrink);

    window1.setContentView(view2);
    window1.setInitialFirstResponder(shrink);
    app.run();
  }
}