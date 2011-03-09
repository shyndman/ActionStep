/* See LICENSE for copyright and terms of use */

import org.actionstep.ASLabel;
import org.actionstep.constants.NSButtonType;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.layout.ASGrid;
import org.actionstep.layout.ASVBox;
import org.actionstep.NSButton;
import org.actionstep.NSComboBox;
import org.actionstep.NSDictionary;
import org.actionstep.NSFont;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTabView;
import org.actionstep.NSTabViewItem;
import org.actionstep.NSTextField;
import org.actionstep.NSView;
import org.aib.AIBApplication;
import org.aib.constants.OriginType;
import org.aib.constants.SizeType;
import org.aib.EditableObjectProtocol;
import org.aib.inspector.size.SizeInspectorContents;
import org.aib.inspector.SizeInspector;
import org.aib.ui.AutosizeView;

/**
 * @author Scott Hyndman
 */
class org.aib.inspector.size.ViewSizeContentView extends NSView
	implements SizeInspectorContents {
	
	private var m_inspector:SizeInspector;
	
	//
	// Controls
	//
	private var m_sizeTabs:NSTabView;
	private var m_sizeLock:NSButton;
	private var m_originList:NSComboBox;
	private var m_originX:NSTextField;
	private var m_originY:NSTextField;
	private var m_sizeList:NSComboBox;
	private var m_sizeWLabel:ASLabel;
	private var m_sizeHLabel:ASLabel;
	private var m_sizeW:NSTextField;
	private var m_sizeH:NSTextField;
	private var m_autosize:AutosizeView;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ViewSizeContentView</code> class.
	 */
	public function ViewSizeContentView() {
		
	}
	
	/**
	 * Initializes and returns the <code>ViewSizeContentView</code> instance with a frame
	 * area of <code>aRect</code>.
	 */
	public function initWithFrameInspector(aRect:NSRect,
			inspector:SizeInspector):ViewSizeContentView {
		super.initWithFrame(aRect);
		m_inspector = inspector;
		buildContents();
		return this;
	}
	
	/**
	 * Builds the contents of this inspector (when a view is selected).
	 */
	private function buildContents():Void {
		var strings:NSDictionary = AIBApplication.stringTable().internalDictionary();
		var origin:NSPoint = m_frame.origin;
		var contentSize:NSSize = m_frame.size;
		var vbox:ASVBox = (new ASVBox()).init();
		var lblFont:NSFont = NSFont.systemFontOfSize(11);
		var lblRect:NSRect = new NSRect(0, 0, 34, 22);
		this.addSubview(vbox);
		
		//
		// Build tab contents
		//
		var tabContents:ASGrid = (new ASGrid()).initWithNumberOfRowsNumberOfColumns(
			6, 4);
		tabContents.setXResizingEnabledForColumn(false, 0);
		tabContents.setXResizingEnabledForColumn(true, 1);
		tabContents.setXResizingEnabledForColumn(false, 2);
		tabContents.setXResizingEnabledForColumn(false, 3);
		
		//
		// Add the spacer
		//
		var spacer:NSView = (new NSView()).initWithFrame(new NSRect(0,0,30,1));
		spacer.setAutoresizingMask(NSView.WidthSizable);
		tabContents.putViewAtRowColumn(spacer, 0, 1);
		
		//
		// Lock checkbox
		//
		m_sizeLock = (new NSButton()).initWithFrame(new NSRect(0, 0, SizeInspector.TEXT_WIDTH, 22));
		m_sizeLock.setButtonType(NSButtonType.NSSwitchButton);
		m_sizeLock.setTitle(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".sizelock").toString());
		m_sizeLock.setTarget(m_inspector);
		m_sizeLock.setAction("lockDidChange");
		m_sizeLock.setFont(NSFont.systemFontOfSize(11));
		
		tabContents.putViewAtRowColumnWithMargins(m_sizeLock, 0, 3, SizeInspector.MARGINS);
		
		//TODO limit all text boxes to numbers
		
		//
		// Origin controls
		//
		m_originList = (new NSComboBox()).initWithFrame(
			new NSRect(0, 0, SizeInspector.COMBO_WIDTH, 22));
		m_originList.addItemsWithObjectValues(OriginType.allTypes);
		m_originList.selectItemAtIndex(0);
		m_originList.setToolTip(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".origin").toString());
		m_originList.setTarget(m_inspector);
		m_originList.setAction("originTypeDidChange");
		tabContents.putViewAtRowColumnWithMargins(m_originList, 1, 0, SizeInspector.MARGINS);
		
		var lbl:ASLabel = (new ASLabel()).initWithFrame(lblRect);
		lbl.setFont(lblFont);
		lbl.setAlignment(NSTextAlignment.NSRightTextAlignment);
		lbl.setStringValue(
			strings.objectForKey(SizeInspector.STRING_GROUP + ".originx").toString());
		tabContents.putViewAtRowColumnWithMargins(lbl, 1, 2, SizeInspector.MARGINS);
		
		m_originX = (new NSTextField()).initWithFrame(new NSRect(0, 0, SizeInspector.TEXT_WIDTH, 22));
		m_originX.setDrawsBackground(true);
		m_originX.setDelegate(m_inspector);
		tabContents.putViewAtRowColumnWithMargins(m_originX, 1, 3, SizeInspector.MARGINS);

		lbl = (new ASLabel()).initWithFrame(lblRect);
		lbl.setFont(lblFont);
		lbl.setAlignment(NSTextAlignment.NSRightTextAlignment);
		lbl.setStringValue(
			strings.objectForKey(SizeInspector.STRING_GROUP + ".originy").toString());
		tabContents.putViewAtRowColumnWithMargins(lbl, 2, 2, SizeInspector.MARGINS);
		
		m_originY = (new NSTextField()).initWithFrame(new NSRect(0, 0, SizeInspector.TEXT_WIDTH, 22));
		m_originY.setDrawsBackground(true);
		m_originY.setDelegate(m_inspector);
		tabContents.putViewAtRowColumnWithMargins(m_originY, 2, 3, SizeInspector.MARGINS);
		
		//
		// Spacer
		//
		spacer = (new NSView()).initWithFrame(new NSRect(0,0,1,15));
		spacer.setAutoresizingMask(NSView.WidthSizable);
		tabContents.putViewAtRowColumn(spacer, 3, 0);
		
		//
		// Size controls
		//
		m_sizeList = (new NSComboBox()).initWithFrame(
			new NSRect(0, 0, SizeInspector.COMBO_WIDTH, 22));
		m_sizeList.addItemsWithObjectValues(SizeType.allTypes);
		m_sizeList.selectItemAtIndex(0);
		m_sizeList.setToolTip(
			strings.objectForKey(SizeInspector.STRING_GROUP + ".size").toString());
		m_sizeList.setTarget(m_inspector);
		m_sizeList.setAction("sizeTypeDidChange");
		tabContents.putViewAtRowColumnWithMargins(m_sizeList, 4, 0, SizeInspector.MARGINS);
		
		m_sizeWLabel = (new ASLabel()).initWithFrame(lblRect);
		m_sizeWLabel.setFont(lblFont);
		m_sizeWLabel.setAlignment(NSTextAlignment.NSRightTextAlignment);
		m_sizeWLabel.setStringValue(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".sizewidth").toString());
		tabContents.putViewAtRowColumnWithMargins(m_sizeWLabel, 4, 2, SizeInspector.MARGINS);
		
		m_sizeW = (new NSTextField()).initWithFrame(new NSRect(0, 0, SizeInspector.TEXT_WIDTH, 22));
		m_sizeW.setDelegate(m_inspector);
		tabContents.putViewAtRowColumnWithMargins(m_sizeW, 4, 3, SizeInspector.MARGINS);

		m_sizeHLabel = (new ASLabel()).initWithFrame(lblRect);
		m_sizeHLabel.setFont(lblFont);
		m_sizeHLabel.setAlignment(NSTextAlignment.NSRightTextAlignment);
		m_sizeHLabel.setStringValue(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".sizeheight").toString());
		tabContents.putViewAtRowColumnWithMargins(m_sizeHLabel, 5, 2, SizeInspector.MARGINS);
		
		m_sizeH = (new NSTextField()).initWithFrame(new NSRect(0, 0, SizeInspector.TEXT_WIDTH, 22));
		m_sizeH.setDelegate(m_inspector);
		tabContents.putViewAtRowColumnWithMargins(m_sizeH, 5, 3, SizeInspector.MARGINS);
		
		//
		// Build tab view
		//
		var sz:NSSize = new NSSize(contentSize.width - 8, 
			tabContents.frame().size.height);
		m_sizeTabs = (new NSTabView()).initWithOriginContentSize(NSPoint.ZeroPoint, 
			tabContents.frame().size);
		m_sizeTabs.setDelegate(m_inspector);
		m_sizeTabs.setDrawsBackground(false);
		vbox.addView(m_sizeTabs);
		
		//
		// Build tab items
		//
		var tabItem:NSTabViewItem = (new NSTabViewItem()).initWithIdentifier(
			"frame");
		tabItem.setLabel(
			strings.objectForKey(SizeInspector.STRING_GROUP + ".frame").toString());
		tabItem.setView(tabContents);
		m_sizeTabs.addTabViewItem(tabItem);
		
		tabItem = (new NSTabViewItem()).initWithIdentifier(
			"layout");
		tabItem.setLabel(
			strings.objectForKey(SizeInspector.STRING_GROUP + ".layout").toString());
		m_sizeTabs.addTabViewItem(tabItem);
		tabItem.setView(tabContents);		
		m_sizeTabs.selectFirstTabViewItem(this);
		
		//
		// Build autosize view
		//
		m_autosize = (new AutosizeView()).initWithFrame(
			new NSRect((contentSize.width - SizeInspector.AUTOSIZE_EDGE_LENGTH) / 2, 0, 
				SizeInspector.AUTOSIZE_EDGE_LENGTH, SizeInspector.AUTOSIZE_EDGE_LENGTH));
		m_autosize.setAutoresizingMask(NSView.MaxXMargin | NSView.MinXMargin);
		m_autosize.setDelegate(m_inspector);
		
		vbox.addViewWithMinYMargin(m_autosize, SizeInspector.SECTION_SPACING);
		origin.x = (contentSize.width - vbox.frame().size.width) / 2;
		vbox.setFrameOrigin(origin);
	}
	
	//******************************************************
	//*                   Description
	//******************************************************
	
	/**
	 * Returns a string representation of the ViewSizeContentView instance.
	 */
	public function description():String {
		return "ViewSizeContentView()";
	}
	
	//******************************************************
	//*                    Interface
	//******************************************************
	
	public function setWidthTextHeightText(width:String, height:String):Void {
		m_sizeWLabel.setStringValue(width);
		m_sizeHLabel.setStringValue(height);
		m_sizeWLabel.setNeedsDisplay(true);
		m_sizeHLabel.setNeedsDisplay(true);
	}
	
	public function setSelection(selection:EditableObjectProtocol):Void {
		
	}
}