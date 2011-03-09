/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.ASStringFormatter;
import org.actionstep.ASTextEditor;
import org.actionstep.layout.ASHBox;
import org.actionstep.layout.ASVBox;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSButton;
import org.actionstep.NSComboBox;
import org.actionstep.NSDictionary;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTextField;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.ASColors;

/**
 * @author Scott Hyndman
 */
class org.actionstep.debug.ASDebuggingPanel extends NSView {

	private static var ALL_CLASSES:String = "All";
	private static var DEFAULT_MAX_LINES:Number = 100;
	private static var TRACE_DATA_MAX_LENGTH:Number = 250;
	private static var LINE_SEPARATOR:String = "<debug><br/></debug>";
	private static var PANEL_CONTENT_HEIGHT:Number = 200;

	private static var g_instance:ASDebuggingPanel;
	private static var g_format:String;

	private var m_textRenderer:ASTextEditor;
	private var m_linesShown:NSComboBox;
	private var m_levelFilter:NSComboBox;
	private var m_classFilter:NSComboBox;
	private var m_clear:NSButton;

	private var m_lineCnt:Number;

	private var m_traceData:Array;
	private var m_maxLines:Number;
	private var m_level:Number;
	private var m_class:String;

	//******************************************************
	//*                   Construction
	//******************************************************

	/**
	 * Creates a new instance of <code>ASDebuggingPanel</code>.
	 *
	 * <code>ASDebuggingPanel#trace</code> automatically creates an instance
	 * when needed, hence the private access.
	 */
	private function ASDebuggingPanel()
	{
		super();

		m_traceData = new Array();
		m_lineCnt = 0;
		m_maxLines = DEFAULT_MAX_LINES;
		m_class = ALL_CLASSES;
		m_level = ASDebugger.ALL;
	}

	/**
	 * Initializes the <code>ASDebuggingPanel</code> with the frame rectangle
	 * <code>frame</code>.
	 */
	public function initWithFrame(frame:NSRect):ASDebuggingPanel
	{
		super.initWithFrame(frame);

		var spring:NSView;
		var desc:NSTextField;

		//
		// Create the vBox
		//
		var vBox:ASVBox = (new ASVBox()).init();
		vBox.setAutoresizingMask(NSView.WidthSizable | NSView.HeightSizable);

		//
		// Create the filters
		//
		var filtersHBox:ASHBox = (new ASHBox()).init();
		filtersHBox.setAutoresizingMask(NSView.WidthSizable);

		spring = new NSView();
		spring.setAutoresizingMask(NSView.WidthSizable);
		filtersHBox.addViewEnableXResizing(spring, true);

		//
		// Create lines shown filter
		//
		desc = NSTextField((new NSTextField()).initWithFrame(
			new NSRect(0, 0, 80, 24)));
		desc.setStringValue("Lines Shown: ");
		desc.setEditable(false);
		desc.setDrawsBackground(false);
		desc.setSelectable(false);
		filtersHBox.addViewEnableXResizing(desc, false);

		m_linesShown = (new NSComboBox()).initWithFrame(
			new NSRect(0, 0, 100, 24));
		m_linesShown.addItemsWithObjectValues((new NSArray()).initWithArray([10, 20, 30, 50, 100, 200]));
		m_linesShown.setEditable(false);
		m_linesShown.selectItemWithObjectValue(DEFAULT_MAX_LINES);
		m_linesShown.setTarget(this);
		m_linesShown.setAction("linesShown_change");
		filtersHBox.addViewEnableXResizingWithMinXMargin(m_linesShown, false,
			5);

		//
		// Create level filter
		//
		desc = NSTextField((new NSTextField()).initWithFrame(
			new NSRect(0, 0, 40, 24)));
		desc.setStringValue("Level: ");
		desc.setEditable(false);
		desc.setDrawsBackground(false);
		desc.setSelectable(false);
		filtersHBox.addViewEnableXResizingWithMinXMargin(desc, false, 10);

		m_levelFilter = (new NSComboBox()).initWithFrame(
			new NSRect(0, 0, 100, 24));
		m_levelFilter.addItemsWithObjectValues((new NSArray()).initWithArray([
			"All",
			"Debug",
			"Info",
			"Warning",
			"Error",
			"Fatal",
			"None"]));
		m_levelFilter.setEditable(false);
		m_levelFilter.selectItemWithObjectValue("All");
		m_level = ASDebugger.ALL;
		m_levelFilter.setTarget(this);
		m_levelFilter.setAction("levelFilter_change");
		filtersHBox.addViewEnableXResizing(m_levelFilter, false);

		//
		// Create class filter
		//
		desc = NSTextField((new NSTextField()).initWithFrame(
			new NSRect(0, 0, 40, 24)));
		desc.setStringValue("Class: ");
		desc.setEditable(false);
		desc.setSelectable(false);
		desc.setDrawsBackground(false);
		filtersHBox.addViewEnableXResizingWithMinXMargin(desc, false, 10);

		m_classFilter = (new NSComboBox()).initWithFrame(
			new NSRect(0, 0, 180, 24));
		m_classFilter.addItemsWithObjectValues((new NSArray()).initWithArray(["All"]));
		m_classFilter.setEditable(false);
		m_classFilter.selectItemWithObjectValue("All");
		m_class = "All";
		m_classFilter.setTarget(this);
		m_classFilter.setAction("classFilter_change");
		filtersHBox.addViewEnableXResizing(m_classFilter, false);

		vBox.addViewEnableYResizing(filtersHBox, false); // add hbox to vbox

		//
		// Create trace window
		//
		m_textRenderer = new ASTextEditor();
		m_textRenderer.initWithFrame(new NSRect(0, 0, frame.size.width, 80));
		m_textRenderer.setAutoresizingMask(
			NSView.HeightSizable | NSView.WidthSizable);
		m_textRenderer.setEditable(false);
		m_textRenderer.setSelectable(true);
		m_textRenderer.setHasVerticalScroller(true);
		m_textRenderer.setAutohidesScrollers(true);
		vBox.addViewEnableYResizingWithMinYMargin(m_textRenderer, true, 4);

		//
		// Create clear button
		//
		var clearHBox:ASHBox = (new ASHBox()).init();
		clearHBox.setAutoresizingMask(NSView.WidthSizable);

		spring = new NSView();
		spring.setAutoresizingMask(NSView.WidthSizable);
		clearHBox.addViewEnableXResizing(spring, true);

		m_clear = NSButton((new NSButton()).init());
		m_clear.setTitle("Clear");
		m_clear.sizeToFit();
		m_clear.setTarget(this);
		m_clear.setAction("clear_click");
		clearHBox.addViewEnableXResizing(m_clear, false);

		vBox.addViewEnableYResizingWithMinYMargin(clearHBox, false, 4);

		//
		// Add the vbox last.
		//
		this.addSubview(vBox);

		return this;
	}

	//******************************************************
	//*              Adding trace messages
	//******************************************************

	/**
	 * Traces out a line to the panel based on the data contained in
	 * <code>data</code>. The data is only written to the panel if it conforms
	 * to the panel's filters.
	 *
	 * This method is called by <code>#traceLine</code>.
	 */
	public function writeLineForData(data:Object):Void
	{
		m_traceData.push(data);

		//
		// Add class name to class filter
		//
		var parts:Array = data.klass.split(".");
		var className:String = parts[parts.length - 1];

		if (!m_classFilter.objectValues().containsObject(className)) {
			m_classFilter.addItemWithObjectValue(className);
		}

		//
		// Filter
		//
		if (m_class != ALL_CLASSES
			&& className != m_class)
		{
			return;
		}

		if (data.level > m_level)
		{
			return;
		}

		//
		// Produce the message
		//
		m_textRenderer.setHtmlString(m_textRenderer.string()
			+ createLineForData(data) + LINE_SEPARATOR);

		m_lineCnt++;
		trimLinesIfNecessary();

		m_textRenderer.moveToEndOfDocument(this);
	}

	/**
	 * Creates the line of text that is shown on the panel for the trace
	 * data contained in <code>data</code>.
	 */
	private function createLineForData(data:Object):String
	{
		//
		// Handle null and undefined values
		//
		if (data.obj === null) {
			data.obj = "null";
		}
		else if (data.obj === undefined) {
			data.obj = "undefined";
		}

		var str:String = data.obj.toString();
		str = str.split("<").join("&lt;").split(">").join("&gt;");
		return ASStringFormatter.formatString(
			format(), NSArray.arrayWithArray([
				ASDebugger.LEVELS[data.level],
				str,
				data.klass,
				data.func,
				data.line]));
	}

	/**
	 * Ensures the number of lines displayed by the panel does not exceed the
	 * maximum.
	 */
	private function trimLinesIfNecessary():Void
	{
		if (m_lineCnt > m_maxLines)
		{
			var linesToStrip:Number = m_lineCnt - m_maxLines;
			var lines:Array = m_textRenderer.string().split(LINE_SEPARATOR);
			lines.splice(0, linesToStrip);

			m_textRenderer.setHtmlString(lines.join(LINE_SEPARATOR));
			m_lineCnt = m_maxLines;
		}

		if (m_traceData.length > TRACE_DATA_MAX_LENGTH) {
			m_traceData.splice(0, m_traceData.length - TRACE_DATA_MAX_LENGTH);
		}
	}

	//******************************************************
	//*               Clearing the panel
	//******************************************************

	public function clear():Void
	{
		m_traceData = new Array();
		m_textRenderer.setString("");
		m_lineCnt = 0;
	}

	//******************************************************
	//*                   Filtering
	//******************************************************

	private function performFilter():Void
	{
		var filteredLines:Array = new Array();
		var lineCount:Number = m_maxLines;
		var idx:Number = m_traceData.length - 1;

		while (lineCount > 0 && idx >= 0)
		{
			var data:Object = m_traceData[idx--];
			var parts:Array = data.klass.split(".");
			var className:String = parts[parts.length - 1];

			if (data.level <= m_level
				&& (m_class == ALL_CLASSES || m_class == className))
			{
				filteredLines.splice(0, 0, createLineForData(data));
				lineCount--;
			}
		}

		m_textRenderer.setHtmlString(filteredLines.join(LINE_SEPARATOR));
		m_textRenderer.moveToEndOfDocument(this);
	}

	//******************************************************
	//*              Responding to events
	//******************************************************

	/**
	 * Fired when the lines shown combobox's value changes.
	 */
	private function linesShown_change(sender:NSComboBox):Void
	{
		m_maxLines = sender.floatValue();
		trimLinesIfNecessary();
	}

	/**
	 * Triggered when the clear button is pressed.
	 */
	private function clear_click(sender:NSButton):Void
	{
		clear();
	}

	/**
	 * Changes the minimum level displayed in the panel.
	 */
	private function levelFilter_change(sender:NSComboBox):Void
	{
		m_level = ASDebugger[sender.stringValue().toUpperCase()];

		performFilter();
	}

	/**
	 * Changes the class filter applied to traces.
	 */
	private function classFilter_change(sender:NSComboBox):Void
	{
		m_class = sender.stringValue();

		performFilter();
	}

	//******************************************************
	//*                  Static stuff
	//******************************************************

	/**
	 * Clears the panel of all lines.
	 */
	public static function clearPanel():Void {
		g_instance.clear();
	}

	/**
	 * This is the method that is called by ASDebugger.
	 */
	public static function traceLine(level:Number, obj:String, klass:String,
		func:String, line:Number):Void
	{
		if (null == g_instance)
		{
			createDebugPanel();
		}

		g_instance.writeLineForData({
			level: level,
			obj: obj,
			klass: klass,
			func: func,
			line: line
			});
	}

	/**
	 * Sets the format string to be applied to the trace data before writing
	 * it to the panel.
	 *
	 * Format strings are applied using <code>ASStringFormatter</code>.
	 */
	public static function setFormatString(format:String):Void
	{
		g_format = format;
	}

	/**
	 * Returns the format string used to transform the trace data before writing
	 * to the panel.
	 */
	public static function format():String
	{
		if (g_format == null)
		{
			return "<font color='#FF0000'>%s </font><b>%s</b> -- %s:%s (%s)";
		}

		return g_format;
	}

	/**
	 * Creates the debug panel.
	 */
	private static function createDebugPanel():Void
	{
		//
		// Register the status bar as an observer for stage resize events.
		//
		NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
			ASDebuggingPanel, "stageDidResize",
			NSApplication.ASStageDidResizeNotification,
			null);

		//
		// Create the debugging panel
		//
		g_instance = new ASDebuggingPanel();
		g_instance.initWithFrame(new NSRect(10, 10, Stage.width - 20, PANEL_CONTENT_HEIGHT - 20));
		g_instance.setAutoresizingMask(NSView.HeightSizable | NSView.WidthSizable);
		
		var wnd:NSWindow = (new NSWindow()).initWithContentRectStyleMask(
			new NSRect(0, Stage.height - PANEL_CONTENT_HEIGHT,
			Stage.width, PANEL_CONTENT_HEIGHT),
			NSWindow.NSMiniaturizableWindowMask
			| NSWindow.NSTitledWindowMask
			| NSWindow.NSNotDraggableWindowMask);
		wnd.setBackgroundColor(ASColors.lightGrayColor());
		wnd.setTitle("Debugging Panel");
		wnd.setLevel(NSWindow.NSFloatingWindowLevel);
		wnd.contentView().addSubview(g_instance);
		wnd.contentView().setPostsFrameChangedNotifications(true);
		wnd.display();

		//
		// Observe notifications from the window's contentView, so we can
		// detect mini and deminiturizations.
		//
		NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
			ASDebuggingPanel, "contentFrameDidChange",
			NSView.NSViewFrameDidChangeNotification,
			wnd.contentView());

		g_instance.m_textRenderer.tile(); // get the thing to draw
	}

	/**
	 * Resizes the debugging panel based on the stage size.
	 */
	private static function stageDidResize(ntf:NSNotification):Void
	{
		var wnd:NSWindow = g_instance.window();
		var stageSize:NSSize =
			NSSize(NSDictionary(ntf.userInfo).objectForKey("ASNewSize"));
		wnd.setFrameOrigin(
			new NSPoint(0, stageSize.height 
				- g_instance.window().frame().height()));
				
		var rect:NSRect = wnd.frame();
		rect.size.width = stageSize.width;
		wnd.setFrame(rect);
	}

	/**
	 * Fired when the panel's window miniaturizes or deminiaturizes.
	 */
	private static function contentFrameDidChange(ntf:NSNotification):Void
	{
		g_instance.window().setFrameOrigin(
			new NSPoint(0, Stage.height 
				- g_instance.window().frame().height()));
	}
}