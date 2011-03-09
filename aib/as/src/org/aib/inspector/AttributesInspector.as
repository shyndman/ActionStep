/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlReader;
import org.actionstep.constants.NSProgressIndicatorStyle;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPoint;
import org.actionstep.NSProgressIndicator;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.aib.AIBApplication;
import org.aib.inspector.InspectorBase;
import org.aib.inspector.InspectorProtocol;
import org.aib.InspectorController;
import org.aib.inspector.attributes.ButtonAttributesInspector;
import org.aib.EditableObjectProtocol;
import org.aib.inspector.attributes.ObjectAttributesInspector;
import org.actionstep.asml.ASAsmlFile;
import org.actionstep.constants.ASAsmlParsingMode;
import org.aib.inspector.attributes.WindowAttributesInspector;

/**
 * The attributes inspector.
 * 
 * @author Scott Hyndman
 */
class org.aib.inspector.AttributesInspector extends InspectorBase {

	private static var g_inspectors:NSDictionary;
	private var m_curInspector:ObjectAttributesInspector;
	private var m_contents:NSView;
	private var m_loadIndicator:NSProgressIndicator;
	private var m_asmlReader:ASAsmlReader;
	private var m_nc:NSNotificationCenter;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Initializes the attributes inspector.
	 */
	public function initWithInspectorController(inspector:InspectorController)
			:InspectorProtocol {
		super.initWithInspectorController(inspector);
		
		m_nc = NSNotificationCenter.defaultCenter();
		
		registerInspectors();
		createAsmlReader();
		createContents();
		return this;
	}
	
	/**
	 * Registers all {@link ObjectAttributesInspector}s.
	 */
	private function registerInspectors():Void {
		g_inspectors = NSDictionary.dictionary();
		
		var btnInsp:ButtonAttributesInspector = new ButtonAttributesInspector();
		btnInsp.init();
		g_inspectors.setObjectForKey(btnInsp, "org.actionstep.NSButton");
		g_inspectors.setObjectForKey(btnInsp, "org.actionstep.NSButtonCell");
		
		var wndInsp:WindowAttributesInspector = new WindowAttributesInspector();
		wndInsp.init();
		g_inspectors.setObjectForKey(wndInsp, "org.actionstep.NSWindow");
	}
	
	/**
	 * Creates the ASML file reader.
	 */
	private function createAsmlReader():Void {
		m_asmlReader = (new ASAsmlReader()).init();
		m_nc.addObserverSelectorNameObject(
			this, "asmlFileDidLoad",
			ASAsmlReader.ASAsmlFileDidLoadNotification,
			m_asmlReader);
		m_nc.addObserverSelectorNameObject(
			this, "asmlFileDidParse",
			ASAsmlReader.ASAsmlFileDidParseNotification,
			m_asmlReader);	
	}
	
	/**
	 * Creates the top level inspector contents.
	 */
	private function createContents():Void {
		var contentSize:NSSize = m_inspector.contentSize();
		m_contents = (new NSView()).initWithFrame(NSRect.withOriginSize(
			NSPoint.ZeroPoint, contentSize));
		
		//
		// Build progress indicator
		//
		m_loadIndicator = new NSProgressIndicator();
		m_loadIndicator.initWithFrame(new NSRect(0, 0, 30, 30));
		m_loadIndicator.setStyle(NSProgressIndicatorStyle.NSProgressIndicatorSpinningStyle);
		m_loadIndicator.setDisplayedWhenStopped(false);
		m_contents.addSubview(m_loadIndicator);
	}
	
	//******************************************************															 
	//*                Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the AttributesInspector instance.
	 */
	public function description():String {
		return "AttributesInspector()";
	}
	
	//******************************************************
	//*           Setting the current inspector
	//******************************************************
	
	public function setCurrentInspector(inspector:ObjectAttributesInspector):Void {
		if (m_curInspector != null) {
			if (m_curInspector.isLoaded()) {
				m_curInspector.inspectorContents().removeFromSuperview();
			}
		}
		
		m_curInspector = inspector;
		
		if (!m_curInspector.isLoaded()) {
			beginLoadingWithInspector(m_curInspector);
		} else {
			//! probably have to do more here
			var inspContents:NSView = m_curInspector.inspectorContents();
			m_contents.addSubview(inspContents);
			inspContents.setFrameSize(m_contents.frame().size);
		}
	}
	
	//******************************************************
	//*                Inspector loading
	//******************************************************
	
	private function beginLoadingWithInspector(inspector:ObjectAttributesInspector):Void {
		m_loadIndicator.startAnimation();
		m_asmlReader.beginLoadingWithUrlParsingMode(m_src + inspector.asmlFilePath(),
			ASAsmlParsingMode.ASPartialObjects);
	}
	
	//******************************************************
	//*                   ASML parsing
	//******************************************************
	
	/**
	 * Fired when the asml file finishes loading.
	 */
	private function asmlFileDidLoad(ntf:NSNotification):Void {
		if (!ntf.userInfo.objectForKey("success")) {
			trace(ntf.userInfo);
		}
	}
	
	/**
	 * Fired when the asml file finishes parsing.
	 */
	private function asmlFileDidParse(ntf:NSNotification):Void {
		m_loadIndicator.stopAnimation();
		var file:ASAsmlFile = ASAsmlFile(
			ntf.userInfo.objectForKey("file"));
		file.applyReferenceProperties();
		m_curInspector.setLoadedWithAsmlFile(file);
		var inspContents:NSView = m_curInspector.inspectorContents();
		m_contents.addSubview(inspContents);
		inspContents.setFrameSize(m_contents.frame().size);
	}
	
	//******************************************************											 
	//*                 InspectorProtocol
	//******************************************************
	
	public function inspectorName():String {
		return AIBApplication.stringForKeyPath("Inspectors.Attributes.Name");
	}

	public function inspectorContents():NSView {
		return m_contents;
	}

	/**
	 * Instructs the inspector to display the data related to 
	 * <code>selection</code>.
	 */
	public function updateInspectorWithSelection(selection:EditableObjectProtocol):Boolean {
		var insp:ObjectAttributesInspector = ObjectAttributesInspector(
			g_inspectors.objectForKey(selection.className()));
				
		if (insp == null) {
			return false;
		}
		
		//
		// Check to see that the inspector's contents have loaded
		//
		setCurrentInspector(insp);
		
		return true;
	}
}