/* See LICENSE for copyright and terms of use */

import org.actionstep.*;
import org.actionstep.test.*;

/**
 * Tests for key loops. This is what handles tabbing in the ActionStep 
 * framework.
 * 
 * @author Richard Kilmer 
 */
class org.actionstep.test.ASTestKeyEvents {

  public static function test() {
    var window1:NSWindow;
    var window2:NSWindow;
    var view1:NSView;
    var view2:NSView;
    var textField1:NSTextField;
    var textField2:NSTextField;
    var button:NSButton;

    var textField3:NSTextField;
    var textField4:NSTextField;
    var button2:NSButton;

    var app:NSApplication = NSApplication.sharedApplication();
    window1 = (new NSWindow()).initWithContentRectStyleMask(new NSRect(10,25,250,250), NSWindow.NSTitledWindowMask  | NSWindow.NSResizableWindowMask);
    window2 = (new NSWindow()).initWithContentRectStyleMask(new NSRect(262,25,250,250), NSWindow.NSTitledWindowMask  | NSWindow.NSResizableWindowMask);

    view1 = (new ASTestView()).initWithFrame(new NSRect(0,0,250,250));
    view2 = (new ASTestView()).initWithFrame(new NSRect(0,0,250,250));

    textField1 = (new NSTextField()).initWithFrame(new NSRect(10,20,120,30));
    textField2 = (new NSTextField()).initWithFrame(new NSRect(10,60,120,30));
    button = (new NSButton()).initWithFrame(new NSRect(10,100,70,30));
    button.setTitle("Submit");

    textField1.setNextKeyView(textField2);
    textField2.setNextKeyView(button);
    button.setNextKeyView(textField1);

    textField3 = (new NSTextField()).initWithFrame(new NSRect(10,20,120,30));
    textField4 = (new NSTextField()).initWithFrame(new NSRect(10,60,120,30));
    button2 = (new NSButton()).initWithFrame(new NSRect(10,100,70,30));
    button2.setTitle("Submit 2");

    textField3.setNextKeyView(textField4);
    textField4.setNextKeyView(button2);
    button2.setNextKeyView(textField3);

    
    var o:Object = new Object();
    o.click = function(b:NSButton) {
      trace("Clicked");
    };
    
    button.setTarget(o);
    button.setAction("click");

    view1.addSubview(textField1);
    view1.addSubview(textField2);
    view1.addSubview(button);

    view2.addSubview(textField3);
    view2.addSubview(textField4);
    view2.addSubview(button2);


    window1.setContentView(view1);
    window1.setInitialFirstResponder(button);
    window2.setContentView(view2);
    app.run();
  }

}
