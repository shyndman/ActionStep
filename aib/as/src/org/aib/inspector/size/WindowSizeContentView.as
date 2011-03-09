/* See LICENSE for copyright and terms of use */

import org.actionstep.ASLabel;
import org.actionstep.constants.NSButtonType;
import org.actionstep.constants.NSControlSize;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.layout.ASGrid;
import org.actionstep.layout.ASVBox;
import org.actionstep.NSButton;
import org.actionstep.NSCell;
import org.actionstep.NSComboBox;
import org.actionstep.NSDictionary;
import org.actionstep.NSFont;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTextField;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.aib.AIBApplication;
import org.aib.constants.OriginType;
import org.aib.constants.SizeType;
import org.aib.controls.EditableViewProtocol;
import org.aib.EditableObjectProtocol;
import org.aib.inspector.size.SizeInspectorContents;
import org.aib.inspector.SizeInspector;
import org.actionstep.NSNotification;

/**
 * @author Scott Hyndman
 */
class org.aib.inspector.size.WindowSizeContentView extends NSView 
		implements SizeInspectorContents {
	private var m_inspector:SizeInspector;
	private var m_selectedWindow:NSWindow;
	private var m_selectedWindowRootView:EditableViewProtocol;
	
	//
	// Controls
	//
	private var m_sizeLock:NSButton;
	private var m_originList:NSComboBox;
	private var m_originXLabel:ASLabel;
	private var m_originYLabel:ASLabel;
	private var m_originX:NSTextField;
	private var m_originY:NSTextField;
	private var m_sizeList:NSComboBox;
	private var m_sizeWLabel:ASLabel;
	private var m_sizeHLabel:ASLabel;
	private var m_sizeW:NSTextField;
	private var m_sizeH:NSTextField;
	private var m_minWLabel:ASLabel;
	private var m_minW:NSTextField;
	private var m_minHLabel:ASLabel;
	private var m_minH:NSTextField;
	private var m_setMinToCurrent:NSButton;
	private var m_maxWLabel:ASLabel;
	private var m_maxW:NSTextField;
	private var m_maxHLabel:ASLabel;
	private var m_maxH:NSTextField;
	private var m_setMaxToCurrent:NSButton;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>WindowSizeContentView</code> class.
	 */
	public function WindowSizeContentView() {
		
	}
	
	/**
	 * Initializes and returns the <code>WindowSizeContentView</code> instance with a frame
	 * area of <code>aRect</code>.
	 */
	public function initWithFrameInspector(aRect:NSRect,
			inspector:SizeInspector):WindowSizeContentView {
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
		var smallLblRect:NSRect = new NSRect(0, 0, 20, 22);
		var largeLblRect:NSRect = new NSRect(0, 0, 43, 22);
				
		//
		// Build title
		//
		var title:ASLabel = (new ASLabel()).initWithFrame(
			new NSRect(0, 0, 140, 26));
		title.setStringValue(strings.objectForKey(SizeInspector.STRING_GROUP
			+ ".contentrect").toString());
		title.setFont(NSFont.systemFontOfSize(15));
		vbox.addView(title);
		
		//
		// Build content rect stuff
		//
		var rectGrid:ASGrid = (new ASGrid()).initWithNumberOfRowsNumberOfColumns(
			6, 4);
		rectGrid.setXResizingEnabledForColumn(false, 0);
		rectGrid.setXResizingEnabledForColumn(true, 1);
		rectGrid.setXResizingEnabledForColumn(false, 2);
		rectGrid.setXResizingEnabledForColumn(false, 3);
		
		//
		// Add the spacer
		//
		var spacer:NSView = (new NSView()).initWithFrame(new NSRect(0,0,30,1));
		spacer.setAutoresizingMask(NSView.WidthSizable);
		rectGrid.putViewAtRowColumn(spacer, 0, 1);
		
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
		m_originList.setTarget(this);
		m_originList.setAction("originTypeDidChange");
		rectGrid.putViewAtRowColumnWithMargins(m_originList, 0, 0, SizeInspector.MARGINS);
		
		var lbl:ASLabel = m_originXLabel = (new ASLabel()).initWithFrame(largeLblRect);
		lbl.setFont(lblFont);
		lbl.setAlignment(NSTextAlignment.NSRightTextAlignment);
		lbl.setStringValue(
			strings.objectForKey(SizeInspector.STRING_GROUP + ".originx").toString());
		rectGrid.putViewAtRowColumnWithMargins(lbl, 0, 2, SizeInspector.MARGINS);
		
		m_originX = (new NSTextField()).initWithFrame(new NSRect(0, 0, SizeInspector.TEXT_WIDTH, 22));
		m_originX.setDrawsBackground(true);
		m_originX.setDelegate(this);
		rectGrid.putViewAtRowColumnWithMargins(m_originX, 0, 3, SizeInspector.MARGINS);

		lbl = m_originYLabel = (new ASLabel()).initWithFrame(largeLblRect);
		lbl.setFont(lblFont);
		lbl.setAlignment(NSTextAlignment.NSRightTextAlignment);
		lbl.setStringValue(
			strings.objectForKey(SizeInspector.STRING_GROUP + ".originy").toString());
		rectGrid.putViewAtRowColumnWithMargins(lbl, 1, 2, SizeInspector.MARGINS);
		
		m_originY = (new NSTextField()).initWithFrame(new NSRect(0, 0, SizeInspector.TEXT_WIDTH, 22));
		m_originY.setDrawsBackground(true);
		m_originY.setDelegate(this);
		rectGrid.putViewAtRowColumnWithMargins(m_originY, 1, 3, SizeInspector.MARGINS);
		
		//
		// Spacer
		//
		spacer = (new NSView()).initWithFrame(new NSRect(0,0,1,15));
		spacer.setAutoresizingMask(NSView.WidthSizable);
		rectGrid.putViewAtRowColumn(spacer, 2, 0);
		
		//
		// Size controls
		//
		m_sizeList = (new NSComboBox()).initWithFrame(
			new NSRect(0, 0, SizeInspector.COMBO_WIDTH, 22));
		m_sizeList.addItemsWithObjectValues(SizeType.allTypes);
		m_sizeList.selectItemAtIndex(0);
		m_sizeList.setToolTip(
			strings.objectForKey(SizeInspector.STRING_GROUP + ".size").toString());
		m_sizeList.setTarget(this);
		m_sizeList.setAction("sizeTypeDidChange");
		rectGrid.putViewAtRowColumnWithMargins(m_sizeList, 3, 0, SizeInspector.MARGINS);
		
		m_sizeWLabel = (new ASLabel()).initWithFrame(largeLblRect);
		m_sizeWLabel.setFont(lblFont);
		m_sizeWLabel.setAlignment(NSTextAlignment.NSRightTextAlignment);
		m_sizeWLabel.setStringValue(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".sizewidth").toString());
		rectGrid.putViewAtRowColumnWithMargins(m_sizeWLabel, 3, 2, SizeInspector.MARGINS);
		
		m_sizeW = (new NSTextField()).initWithFrame(new NSRect(0, 0, SizeInspector.TEXT_WIDTH, 22));
		m_sizeW.setDelegate(this);
		rectGrid.putViewAtRowColumnWithMargins(m_sizeW, 3, 3, SizeInspector.MARGINS);

		m_sizeHLabel = (new ASLabel()).initWithFrame(largeLblRect);
		m_sizeHLabel.setFont(lblFont);
		m_sizeHLabel.setAlignment(NSTextAlignment.NSRightTextAlignment);
		m_sizeHLabel.setStringValue(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".sizeheight").toString());
		rectGrid.putViewAtRowColumnWithMargins(m_sizeHLabel, 4, 2, SizeInspector.MARGINS);
		
		m_sizeH = (new NSTextField()).initWithFrame(new NSRect(0, 0, SizeInspector.TEXT_WIDTH, 22));
		m_sizeH.setDelegate(this);
		rectGrid.putViewAtRowColumnWithMargins(m_sizeH, 4, 3, SizeInspector.MARGINS);
		
		//
		// Lock checkbox
		//
		m_sizeLock = (new NSButton()).initWithFrame(new NSRect(0, 0, SizeInspector.TEXT_WIDTH, 22));
		m_sizeLock.setButtonType(NSButtonType.NSSwitchButton);
		m_sizeLock.setTitle(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".sizelock").toString());
		m_sizeLock.setTarget(this);
		m_sizeLock.setAction("lockDidChange");
		m_sizeLock.cell().setControlSize(NSControlSize.NSMiniControlSize);
		m_sizeLock.setFont(NSFont.systemFontOfSize(9));
		rectGrid.putViewAtRowColumnWithMargins(m_sizeLock, 5, 0, SizeInspector.MARGINS);
		vbox.addView(rectGrid);
		
		//
		// Separator
		//
		vbox.addSeparatorWithMinYMargin(5);
		
		//
		// Min / max width
		//
		var minMaxGrid:ASGrid = (new ASGrid()).initWithNumberOfRowsNumberOfColumns(
			2, 5);
		minMaxGrid.setXResizingEnabledForColumn(false, 0);
		minMaxGrid.setXResizingEnabledForColumn(false, 1);
		minMaxGrid.setXResizingEnabledForColumn(false, 2);
		minMaxGrid.setXResizingEnabledForColumn(false, 3);
		minMaxGrid.setXResizingEnabledForColumn(true, 3);
		
		//
		// Build controls
		//
		lbl = m_minWLabel = (new ASLabel()).initWithFrame(largeLblRect);
		lbl.setFont(lblFont);
		lbl.setAlignment(NSTextAlignment.NSRightTextAlignment);
		lbl.setStringValue(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".minwidth").toString());
		minMaxGrid.putViewAtRowColumnWithMargins(lbl, 0, 0, SizeInspector.MARGINS);
			
		m_minW = (new NSTextField()).initWithFrame(new NSRect(0, 0, 
			45, 22));
		m_minW.setDelegate(m_inspector);
		minMaxGrid.putViewAtRowColumnWithMargins(m_minW, 0, 1, SizeInspector.MARGINS);
		
		lbl = m_minHLabel = (new ASLabel()).initWithFrame(smallLblRect);
		lbl.setFont(lblFont);
		lbl.setAlignment(NSTextAlignment.NSRightTextAlignment);
		lbl.setStringValue(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".sizeheight").toString());
		minMaxGrid.putViewAtRowColumnWithMargins(lbl, 0, 2, SizeInspector.MARGINS);
		
		m_minH = (new NSTextField()).initWithFrame(new NSRect(0, 0, 
			45, 22));
		m_minW.setDelegate(m_inspector);
		minMaxGrid.putViewAtRowColumnWithMargins(m_minH, 0, 3, SizeInspector.MARGINS);
		
		m_setMinToCurrent = (new NSButton()).initWithFrame(
			new NSRect(0, 0, SizeInspector.TEXT_WIDTH, 22));
		m_setMinToCurrent.setTitle(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".current").toString());
		m_setMinToCurrent.setAutoresizingMask(NSView.MinXMargin);
		m_setMinToCurrent.setTarget(this);
		m_setMinToCurrent.setAction("setMinToCurrent");
		minMaxGrid.putViewAtRowColumnWithMargins(m_setMinToCurrent, 0, 4, 
			SizeInspector.MARGINS);
		
		lbl = m_maxWLabel = (new ASLabel()).initWithFrame(largeLblRect);
		lbl.setFont(lblFont);
		lbl.setAlignment(NSTextAlignment.NSRightTextAlignment);
		lbl.setStringValue(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".maxwidth").toString());
		minMaxGrid.putViewAtRowColumnWithMargins(lbl, 1, 0, SizeInspector.MARGINS);
		
		m_maxW = (new NSTextField()).initWithFrame(new NSRect(0, 0, 
			45, 22));
		m_maxW.setDelegate(m_inspector);
		minMaxGrid.putViewAtRowColumnWithMargins(m_maxW, 1, 1, SizeInspector.MARGINS);
		
		lbl = m_maxHLabel = (new ASLabel()).initWithFrame(smallLblRect);
		lbl.setFont(lblFont);
		lbl.setAlignment(NSTextAlignment.NSRightTextAlignment);
		lbl.setStringValue(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".sizeheight").toString());
		minMaxGrid.putViewAtRowColumnWithMargins(lbl, 1, 2, SizeInspector.MARGINS);
		
		m_maxH = (new NSTextField()).initWithFrame(new NSRect(0, 0, 
			45, 22));
		m_maxH.setDelegate(m_inspector);
		minMaxGrid.putViewAtRowColumnWithMargins(m_maxH, 1, 3, SizeInspector.MARGINS);
		
		m_setMaxToCurrent = (new NSButton()).initWithFrame(
			new NSRect(0, 0, SizeInspector.TEXT_WIDTH, 22));
		m_setMaxToCurrent.setTitle(strings.objectForKey(
			SizeInspector.STRING_GROUP + ".current").toString());
		m_setMaxToCurrent.setAutoresizingMask(NSView.MinXMargin);
		m_setMaxToCurrent.setTarget(this);
		m_setMaxToCurrent.setAction("setMaxToCurrent");
		minMaxGrid.putViewAtRowColumnWithMargins(m_setMaxToCurrent, 1, 4, 
			SizeInspector.MARGINS);
		minMaxGrid.setFrameSize(new NSSize(
			rectGrid.frame().size.width, minMaxGrid.frame().size.height));
		
		vbox.addViewWithMinYMargin(minMaxGrid, 8);
		addSubview(vbox);
		
		origin.x = (contentSize.width - vbox.frame().size.width) / 2;
		vbox.setFrameOrigin(origin);
		
		//
		// Set tab order
		//
		m_originX.setNextKeyView(m_originY);
		m_originY.setNextKeyView(m_sizeW);
		m_sizeW.setNextKeyView(m_sizeH);
		m_sizeH.setNextKeyView(m_minW);
		m_minW.setNextKeyView(m_minH);
		m_minH.setNextKeyView(m_maxW);
		m_maxW.setNextKeyView(m_maxH);
		m_maxH.setNextKeyView(m_originX);
	}
	
	//******************************************************
	//*                  Description
	//******************************************************
	
	/**
	 * Returns a string representation of the WindowSizeContentView instance.
	 */
	public function description():String {
		return "WindowSizeContentView()";
	}
	
	//******************************************************
	//*                  Target actions
	//******************************************************
	
	private function controlTextDidEndEditing(ntf:NSNotification):Void {
		trace(ntf.object);
	}
	
	private function lockDidChange(btn:NSButton):Void {
		var locked:Boolean = btn.cell().state() == NSCell.NSOnState;
		setFrameLocked(locked);
		m_inspector.modifySelectionWithObjectForKeyPath(locked, "frameLocked");
	}
	
	private function sizeTypeDidChange(cmb:NSComboBox):Void {
		var width:String;
		var height:String;
		
		if (cmb.objectValueOfSelectedItem() == SizeType.MaxXMaxY) {
			width = AIBApplication.stringForKeyPath(
				SizeInspector.STRING_GROUP + ".SizeMaxX");
			height = AIBApplication.stringForKeyPath(
				SizeInspector.STRING_GROUP + ".SizeMaxY");
		} else {
			width = AIBApplication.stringForKeyPath(
				SizeInspector.STRING_GROUP + ".SizeWidth");
			height = AIBApplication.stringForKeyPath(
				SizeInspector.STRING_GROUP + ".SizeHeight");
		}
		
		setWidthTextHeightText(width, height);
		updateSizeFields();
	}
	
	private function originTypeDidChange(cmb:NSComboBox):Void {
		updateOriginFields();
		updateSizeFields();
	}
	
	//******************************************************
	//*                 Updating the UI
	//******************************************************
	
	private function setMinToCurrent(btn:NSButton):Void {
		var sz:NSSize = m_selectedWindow.frame().size;
		m_minW.setStringValue(sz.width.toString());
		m_minH.setStringValue(sz.height.toString());
		m_minW.setNeedsDisplay(true);
		m_minH.setNeedsDisplay(true);
		m_inspector.modifySelectionWithObjectForKeyPath(
			sz, "minSize");
	}
	
	private function setMaxToCurrent(btn:NSButton):Void {
		var sz:NSSize = m_selectedWindow.frame().size;
		m_maxW.setStringValue(sz.width.toString());
		m_maxH.setStringValue(sz.height.toString());
		m_maxW.setNeedsDisplay(true);
		m_maxH.setNeedsDisplay(true);
		m_inspector.modifySelectionWithObjectForKeyPath(
			sz, "maxSize");
	}
	
	private function setFrameLocked(flag:Boolean):Void {
		m_originX.setEnabled(!flag);
		m_originY.setEnabled(!flag);
		m_sizeW.setEnabled(!flag);
		m_sizeH.setEnabled(!flag);
		m_minW.setEnabled(!flag);
		m_minH.setEnabled(!flag);
		m_maxW.setEnabled(!flag);
		m_maxH.setEnabled(!flag);
		m_originXLabel.setEnabled(!flag);
		m_originYLabel.setEnabled(!flag);
		m_sizeWLabel.setEnabled(!flag);
		m_sizeHLabel.setEnabled(!flag);
		m_minWLabel.setEnabled(!flag);
		m_minHLabel.setEnabled(!flag);
		m_maxWLabel.setEnabled(!flag);
		m_maxHLabel.setEnabled(!flag);
		m_setMinToCurrent.setEnabled(!flag);
		m_setMaxToCurrent.setEnabled(!flag);
		
		m_originX.setNeedsDisplay(true);
		m_originY.setNeedsDisplay(true);
		m_sizeW.setNeedsDisplay(true);
		m_sizeH.setNeedsDisplay(true);
		m_minW.setNeedsDisplay(true);
		m_minH.setNeedsDisplay(true);
		m_maxW.setNeedsDisplay(true);
		m_maxH.setNeedsDisplay(true);
		m_originXLabel.setNeedsDisplay(true);
		m_originYLabel.setNeedsDisplay(true);
		m_sizeWLabel.setNeedsDisplay(true);
		m_sizeHLabel.setNeedsDisplay(true);
		m_minWLabel.setNeedsDisplay(true);
		m_minHLabel.setNeedsDisplay(true);
		m_maxWLabel.setNeedsDisplay(true);
		m_maxHLabel.setNeedsDisplay(true);
		m_setMinToCurrent.setNeedsDisplay(true);
		m_setMaxToCurrent.setNeedsDisplay(true);
	}
	
	private function updateOriginFields():Void {
		var type:OriginType = OriginType(m_originList.objectValueOfSelectedItem());
		var frm:NSRect = m_selectedWindow.contentRectForFrameRect(m_selectedWindow.frame());
		var x:Number, y:Number;
		
		switch (type) {
			case OriginType.TopLeft:
				x = frm.origin.x;
				y = frm.origin.y;
				break;
				
			case OriginType.BottomLeft:
				x = frm.origin.x;
				y = Stage.height - frm.maxY();
				break;
				
			case OriginType.TopRight:
				x = Stage.width - frm.maxX();
				y = frm.origin.y;
				break;
				
			case OriginType.BottomRight:
				x = Stage.width - frm.maxX();
				y = Stage.height - frm.maxY();
				break;
		}
				
		m_originX.setStringValue(x.toString());
		m_originY.setStringValue(y.toString());
		m_originX.setNeedsDisplay(true);
		m_originY.setNeedsDisplay(true);
	}
	
	private function updateSizeFields():Void {
		var frm:NSRect = m_selectedWindow.contentRectForFrameRect(m_selectedWindow.frame());
		var w:Number, h:Number;
		var sType:SizeType = SizeType(m_sizeList.objectValueOfSelectedItem());
		if (sType == SizeType.WidthHeight) {
			w = frm.size.width;
			h = frm.size.height;
		} else { // SizeType.MaxXMaxY
			var oType:OriginType = OriginType(m_originList.objectValueOfSelectedItem());
			var x:Number, y:Number;
			
			switch (oType) {
				case OriginType.TopLeft:
					w = frm.maxX();
					h = frm.maxY();
					break;
					
				case OriginType.BottomLeft:
					w = frm.maxX();
					h = Stage.height - frm.minY();
					break;
					
				case OriginType.TopRight:
					w = Stage.width - frm.minX();
					h = frm.maxY();
					break;
					
				case OriginType.BottomRight:
					w = Stage.width - frm.minX();
					h = Stage.height - frm.minY();
					break;
			}
		}
		
		m_sizeW.setStringValue(w.toString());
		m_sizeH.setStringValue(h.toString());
		m_sizeW.setNeedsDisplay(true);
		m_sizeH.setNeedsDisplay(true);
	}
	
	//******************************************************
	//*                   Interface
	//******************************************************
	
	public function setWidthTextHeightText(width:String, height:String):Void {
		m_sizeWLabel.setStringValue(width);
		m_sizeHLabel.setStringValue(height);
		m_sizeWLabel.setNeedsDisplay(true);
		m_sizeHLabel.setNeedsDisplay(true);
	}
	
	public function setSelection(selection:EditableObjectProtocol):Void {
		var view:NSView = NSView(selection);
		m_selectedWindowRootView = EditableViewProtocol(selection);
		m_selectedWindow = view.window();
		
		//
		// Lock
		//
		var locked:Boolean = m_selectedWindowRootView.isFrameLocked();
		m_sizeLock.cell().setState(locked ? NSCell.NSOnState : NSCell.NSOffState);
		m_sizeLock.setNeedsDisplay(true);
		setFrameLocked(locked);
		
		//
		// Origin
		//
		updateOriginFields();
		
		//
		// Size
		//
		updateSizeFields();
		
		//
		// Min
		//
		var min:NSSize = m_selectedWindow.minSize();
		var w:String, h:String;
		if (min.width != 1 && min.height != 1) {
			w = min.width.toString();
			h = min.height.toString();
		} else {
			w = "";
			h = "";
		}
		m_minW.setStringValue(w);
		m_minH.setStringValue(h);
		m_minW.setNeedsDisplay(true);
		m_minH.setNeedsDisplay(true);
		
		//
		// Max
		//
		var max:NSSize = m_selectedWindow.maxSize();
		if (max.width != 10000 && max.height != 10000) {
			w = max.width.toString();
			h = max.height.toString();
		} else {
			w = "";
			h = "";
		}
		
		m_maxW.setStringValue(w);
		m_maxH.setStringValue(h);
		m_maxW.setNeedsDisplay(true);
		m_maxH.setNeedsDisplay(true);
	}
}