/* See LICENSE for copyright and terms of use */
 
import org.actionstep.*;
import org.actionstep.test.*;
import org.actionstep.constants.*;

/**
 * Tests the <code>org.actionstep.NSScroller</code> class.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.test.ASTestScrollers {
  public static function test() {
    
    var testObject:Object = new Object();
    testObject.vscroller = function(scroller:NSScroller) {
      switch(scroller.hitPart()) {
        case NSScrollerPart.NSScrollerIncrementPage:
        case NSScrollerPart.NSScrollerIncrementLine:
          scroller.setFloatValue(scroller.floatValue() + .02);
          break;
        case NSScrollerPart.NSScrollerDecrementPage:
        case NSScrollerPart.NSScrollerDecrementLine:
          scroller.setFloatValue(scroller.floatValue() - .02);
          break;
      }
    };
    testObject.hscroller = function(scroller:NSScroller) {
      switch(scroller.hitPart()) {
        case NSScrollerPart.NSScrollerIncrementPage:
        case NSScrollerPart.NSScrollerIncrementLine:
          scroller.setFloatValue(scroller.floatValue() + .02);
          break;
        case NSScrollerPart.NSScrollerDecrementPage:
        case NSScrollerPart.NSScrollerDecrementLine:
          scroller.setFloatValue(scroller.floatValue() - .02);
          break;
      }
    };
    
    var app:NSApplication = NSApplication.sharedApplication();
    var window1:NSWindow = (new NSWindow()).initWithContentRect(new NSRect(0,0,250,250));
    
    var view:ASTestView = new ASTestView();
    view.initWithFrame(new NSRect(0,0,250,250));
    
    var vscroller:NSScroller = new NSScroller();
    vscroller.initWithFrame(new NSRect(180, 0, 20, 180));
    vscroller.setTarget(testObject);
    vscroller.setAction("vscroller");
    
    var hscroller:NSScroller = new NSScroller();
    hscroller.initWithFrame(new NSRect(0, 180, 180, 20));
    hscroller.setTarget(testObject);
    hscroller.setAction("hscroller");

    view.addSubview(vscroller);
    view.addSubview(hscroller);
    window1.setContentView(view);
    app.run();
  }
}