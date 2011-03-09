/* See LICENSE for copyright and terms of use */

import org.actionstep.*;

/**
 * Tests the <code>org.actionstep.ASTextRenderer</code> class.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.test.ASTestTextRenderer
{	
	public static function test():Void
	{
	  
	  var styleSheet:TextField.StyleSheet = new TextField.StyleSheet();
	  styleSheet.parseCSS( " contact {
            font-family: Verdana,Ariel;
            color: #000000;
            display: block;
          }
          name {
            font-weight: bold;
            font-size: 18;
          }
          label {
            color: #555555;
            font-weight: bold;
            font-size: 12;
            display: inline;
          }
          item {
            font-size: 12;
            display: block;
          }");
          
    var htmlText:String = "
      <contact>
        <name>Richard Kilmer</name>
        <item> President & CEO</item>
        <item> InfoEther, Inc.</item>
        <br><textformat tabstops='[60,200]'>
        <label> home \t</label> <item>555.555.1212</item>
        <label> work \t</label> <item>555.555.1313</item>
        </textformat>
      </contact>
      ";
	  
		var app:NSApplication = NSApplication.sharedApplication();
		var window:NSWindow = (new NSWindow()).initWithContentRect(
		  new NSRect(0,0,500,500));
		var view:NSView = (new NSView()).initWithFrame(new NSRect(0,0,500,500));
		var textRenderer:ASTextRenderer = (new ASTextRenderer()).initWithFrame(
		  new NSRect(10, 10, 300, 300));
		textRenderer.setStyleSheet(styleSheet);
		textRenderer.setText(htmlText);
		view.addSubview(textRenderer);
		window.setContentView(view);
		app.run();
	}
}
