/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColoredView;
import org.actionstep.ASColors;
import org.actionstep.ASDebugger;
import org.actionstep.ASStringFormatter;
import org.actionstep.ASUtils;
import org.actionstep.NSArray;
import org.actionstep.NSColor;
import org.actionstep.NSComboBox;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.aib.AIBApplication;
import org.aib.AIBObject;
import org.aib.EditableObjectProtocol;
import org.aib.inspector.InspectorProtocol;
import org.aib.inspector.MessageContentView;
import org.aib.SelectionManager;
import org.aib.ui.ToolWindow;

/**
 * The inspector controller.
 * 
 * @author Scott Hyndman
 */
class org.aib.InspectorController extends AIBObject {
	
	//******************************************************															 
	//*                    Constants
	//******************************************************
	
	private static var DEFAULT_WIDTH:Number = 320;
	private static var DEFAULT_HEIGHT:Number = 470;
	private static var CONTENT_WIDTH:Number = 300;
	
	//******************************************************															 
	//*                 Class variables
	//******************************************************
	
	private static var g_instance:InspectorController;
	
	//******************************************************															 
	//*                 Member variables
	//******************************************************
	
	private var m_window:NSWindow;
	private var m_typeSelector:NSComboBox;
	private var m_inspectors:NSArray;
	private var m_inspectorContentView:NSView;
	private var m_curInspector:InspectorProtocol;
	private var m_curContents:NSView;
	private var m_messageContent:MessageContentView;
	private var m_showingMessage:Boolean;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>Inspector</code> class.
	 * 
	 * The class is a singleton. Access the window using {@link #instance()}.
	 */
	private function InspectorController() {
		m_inspectors = NSArray.array();
		m_showingMessage = false;
	}
	
	/**
	 * Initializes the inspector.
	 */
	public function init():InspectorController {
		super.init();
		createWindow();
		createContentView();
		var wndFrm:NSRect = m_window.frame();
		m_window.setFrame(NSRect.withOriginSize(wndFrm.origin,
			new NSSize(DEFAULT_WIDTH, DEFAULT_HEIGHT)));
			
		//
		// Observe selection changes
		//
		NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
			this,
			"selectionDidChange",
			SelectionManager.SelectionDidChangeNotification,
			SelectionManager.instance());
		
		return this;
	}
	
	/**
	 * Creates the window for the inspector.
	 */
	private function createWindow():Void {
		m_window = (new ToolWindow()).initWithContentRectStyleMask(
			new NSRect(300, 60, CONTENT_WIDTH, DEFAULT_HEIGHT),
			NSWindow.NSClosableWindowMask 
			| NSWindow.NSMiniaturizableWindowMask
			| NSWindow.NSResizableWindowMask
			| NSWindow.NSTitledWindowMask);
		m_window.rootView().setHasShadow(true);
		m_window.setMinSize(new NSSize(CONTENT_WIDTH, DEFAULT_HEIGHT));
		m_window.setTitle(AIBApplication.stringForKeyPath(
				"Inspectors.BasicWindowTitle"));
		m_window.display();
		m_window.setBackgroundColor(ASColors.lightGrayColor().adjustColorBrightnessByFactor(1.5));
	}
	
	/**
	 * Creates the content view for the inspector window.
	 */
	private function createContentView():Void {
		var stg:NSView = m_window.contentView();
		var stgFrm:NSRect = stg.frame();
		var stgSz:NSSize = m_window.contentSize();
		var typeHolderHeight:Number = 36;
		
		//
		// Create holder
		//		
		var typeHolder:ASColoredView = new ASColoredView();
		typeHolder.initWithFrame(new NSRect(-2,0,stgSz.width+4,typeHolderHeight));
		typeHolder.setAutoresizingMask(NSView.WidthSizable);
		typeHolder.setBackgroundColor(null);
		typeHolder.setBorderColor(ASColors.blackColor());
		stg.addSubview(typeHolder);	
		
		//
		// Create combobox
		//						
		var frm:NSRect = typeHolder.frame();
		m_typeSelector = new NSComboBox();
		m_typeSelector.initWithFrame(new NSRect(
			(frm.size.width - 200) / 2, 8, 200, 22));
		m_typeSelector.setEditable(false);
		m_typeSelector.setTarget(this);
		m_typeSelector.setAction("typeDidChange");
		m_typeSelector.setAutoresizingMask(NSView.MinXMargin | NSView.MaxXMargin);
		typeHolder.addSubview(m_typeSelector);
		
		//
		// Create content view
		//
		m_inspectorContentView = new NSView();
		m_inspectorContentView.initWithFrame(new NSRect(
			(stgSz.width - CONTENT_WIDTH) / 2 - 4, typeHolderHeight + 8,
			CONTENT_WIDTH, stgSz.height - typeHolderHeight - 8));
		m_inspectorContentView.setAutoresizingMask(
			NSView.MinXMargin | NSView.MaxXMargin);
		stg.addSubview(m_inspectorContentView);
		
		//
		// Create message content
		//
		m_messageContent = (new MessageContentView()).initWithFrame(
			NSRect.withOriginSize(NSPoint.ZeroPoint,
			m_inspectorContentView.frame().size));
		m_messageContent.setAutoresizingMask(
			NSView.MinXMargin | NSView.MaxXMargin);
	}
	
	//******************************************************
	//*              Getting the content area
	//******************************************************
	
	/**
	 * Returns the content size of the 
	 */
	public function contentSize():NSSize {
		return m_inspectorContentView.frame().size;
	}
	
	//******************************************************															 
	//*               Setting the inspectors
	//******************************************************
	
	/**
	 * Creates inspectors for this window using the class names found in
	 * <code>types</code>.
	 */
	public function createInspectorsWithTypes(types:NSArray):Void {
		var arr:Array = types.internalList();
		var len:Number = arr.length;
		
		//
		// Create the inspectors
		//
		for (var i:Number = 0; i < len; i++) {
			var cls:Function = eval(arr[i].type);
			var insp:InspectorProtocol = InspectorProtocol(
				ASUtils.createInstanceOf(cls));
			
			if (arr[i].src != null) {
				insp.setSourceDirectory(AIBApplication.AIB_URL 
					+ AIBApplication.RESOURCES_PATH + arr[i].src);
			}
			
			//
			// Make sure the palette was created.
			//
			if (insp == null) {
				trace("The inspector named " + arr[i] + " could not be created.",
					ASDebugger.WARNING);
				continue;
			}
			   
			//
			// Initialize and add the palette
			//
			insp.initWithInspectorController(this);
			m_inspectors.addObject(insp);
			
			//
			// Add the item to the combobox.
			//
			m_typeSelector.addItemWithObjectValue(insp.inspectorName());
		}
		
		m_typeSelector.selectItemAtIndex(0);
		m_curInspector = InspectorProtocol(m_inspectors.objectAtIndex(0));
	}
	
	//******************************************************
	//*              Setting the content view
	//******************************************************
	
	private function setCurrentContents(contents:NSView):Void {
		if (contents == m_curContents) {
			return;
		}
		
		if (m_curContents != null) {
			if (contents == null) {
				m_curContents.removeFromSuperview();
			}
			else if (contents == m_messageContent && m_showingMessage) {
				return;
			} else {
				m_inspectorContentView.replaceSubviewWith(m_curContents,
					contents);
			}
		} else {
			m_inspectorContentView.addSubview(contents);
		}
		
		m_showingMessage = m_curContents == m_messageContent;		
		m_curContents = contents;
		
		if (!m_curContents != null) {
			var frmSz:NSSize = m_inspectorContentView.frame().size;
			var cntFrm:NSRect = m_curContents.frame();
			cntFrm.origin.x = (frmSz.width - cntFrm.size.width) / 2;
			m_curContents.setFrameOrigin(cntFrm.origin);
		}
	}
	
	private function setMessageContent(message:String):Void {
		m_messageContent.setMessage(message);
		setCurrentContents(m_messageContent);
		m_messageContent.setNeedsDisplay(true);
	}
	
	//******************************************************															 
	//*                 Window properties
	//******************************************************

	/**
	 * Resets this window's title.
	 */	
	private function resetTitle():Void {
		//
		// Get the selection
		//
		var sel:NSArray = SelectionManager.instance().currentSelection();
				
		//
		// Build and set the title
		//
		var title:String;
		if (sel.count() == 1) {
			var format:String = AIBApplication.stringForKeyPath(
				"Inspectors.WindowTitle");
			var cls:String = sel.objectAtIndex(0).className();
			var parts:Array = cls.split(".");
			cls = parts[parts.length - 1];
			title = ASStringFormatter.formatString(format,
				NSArray.arrayWithObject(cls));
		} else {
			title = AIBApplication.stringForKeyPath(
				"Inspectors.BasicWindowTitle");
		}

		m_window.setTitle(title);
	}
	
	//******************************************************															 
	//*                 Selection changes
	//******************************************************
	
	/**
	 * Fired when the selected inspector changes.
	 */
	private function typeDidChange(sender:Object):Void {		
		//
		// Get the selected inspector
		//
		var idx:Number = m_typeSelector.indexOfSelectedItem();
		m_curInspector = InspectorProtocol(
			m_inspectors.objectAtIndex(idx));
		
		//
		// Trigger a selection change
		//
		setSelection(SelectionManager.instance().currentSelection());
	}
	
	/**
	 * Fired when the selection changes.
	 */
	private function selectionDidChange(ntf:NSNotification):Void {
		resetTitle();
		setSelection(SelectionManager.instance().currentSelection());
	}
	
	private function setSelection(selection:NSArray):Void {
		if (selection.count() > 1) {
			setMessageContent(AIBApplication.stringForKeyPath(
				"Inspectors.MultiSel"));
			return;
		}
		else if (selection.count() == 0) {
			setMessageContent(AIBApplication.stringForKeyPath(
				"Inspectors.NoSel"));
			return;
		}
		
		//
		// Invalid selection
		//
		var sel:EditableObjectProtocol = EditableObjectProtocol(
			selection.objectAtIndex(0)); 
		if (!sel.supportsInspector(m_curInspector)) {
			setMessageContent(AIBApplication.stringForKeyPath(
				"Inspectors.NotApplicable"));
			return;
		}
		
		//
		// Validate with inspector
		//
		var valid:Boolean = m_curInspector.updateInspectorWithSelection(sel);
		if (!valid) {
			setMessageContent(AIBApplication.stringForKeyPath(
				"Inspectors.NotApplicable"));
			return;
		}
		
		setCurrentContents(m_curInspector.inspectorContents());
	}
	
	//******************************************************
	//*                Getting the window
	//******************************************************
	
	/**
	 * Returns the window used by the inspector window.
	 */
	public function window():NSWindow {
		return m_window;
	}
	
	//******************************************************															 
	//*               Getting the instance
	//******************************************************
	
	/**
	 * Returns the inspector window instance.
	 */
	public static function instance():InspectorController {
		if (null == g_instance) {
			g_instance = (new InspectorController()).init();
		}
		
		return g_instance;
	}
}