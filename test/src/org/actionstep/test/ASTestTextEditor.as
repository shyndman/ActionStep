/* See LICENSE for copyright and terms of use */

import org.actionstep.*;

/**
 * Test for the <code>org.actionstep.ASTextEditor</code> class.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.test.ASTestTextEditor {

  public static function test() {
    var app:NSApplication = NSApplication.sharedApplication();
    var window:NSWindow = (new NSWindow()).initWithContentRect(new NSRect(0,0,500,500));
    var view:NSView = (new NSView()).initWithFrame(new NSRect(0,0,500,500));
    var textEditor:ASTextEditor = new ASTextEditor();
    textEditor.initWithFrame(new NSRect(0,0,200,200));
    textEditor.setHasVerticalScroller(true);
    textEditor.setHasHorizontalScroller(true);
    textEditor.setAutohidesScrollers(true);
    view.addSubview(textEditor);
    
    var clearButton:NSButton = new NSButton();
    clearButton.initWithFrame(new NSRect(210,10,100,25));
    clearButton.setTitle("Clear");
    clearButton.setTarget(textEditor);
    clearButton.setAction("clear");
    view.addSubview(clearButton);

    var list:ASList = (new ASList()).initWithFrame(new NSRect(210, 45, 150, 200));
    list.setFont(NSFont.fontWithNameSizeEmbedded("Arial", 14, false));
    list.setFontColor(new NSColor(0x50545d));
    var labels:Array = new Array();
    var data:Array = new Array();
    for(var i:Number = 0;i<40;i++) {
      labels[i] = "Test Item "+i;
      data[i] = i;
    }
    list.addItemsWithLabelsData(labels, data);
    view.addSubview(list);
    
    list.setNextKeyView(textEditor);
    textEditor.setNextKeyView(clearButton);
    clearButton.setNextKeyView(list);
    

    window.setContentView(view);
    app.run();
    textEditor.setString("This is a test of the emergency broadcast system");
  }
}