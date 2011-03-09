/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlFile;
import org.actionstep.NSView;
import org.aib.AIBObject;
import org.aib.inspector.attributes.ObjectAttributesInspector;
import org.actionstep.NSException;
import org.actionstep.NSTextField;
import org.actionstep.NSComboBox;
import org.actionstep.NSButton;
import org.actionstep.NSMatrix;
import org.actionstep.NSNotification;

/**
 * The attributes inspector for buttons and button cells.
 * 
 * @author Scott Hyndman
 */
class org.aib.inspector.attributes.ButtonAttributesInspector extends AIBObject 
		implements ObjectAttributesInspector {

	private var m_loaded:Boolean;
	private var m_file:ASAsmlFile;
	
	//
	// Controls
	//
	private var m_title:NSTextField;
	private var m_altTitle:NSTextField;
	private var m_icon:NSTextField;
	private var m_altIcon:NSTextField;
	private var m_keyEquiv:NSTextField;
	private var m_keyEquivPresets:NSComboBox;
	private var m_keyModCtrl:NSButton;
	private var m_keyModShift:NSButton;
	private var m_keyModAlt:NSButton;
	private var m_type:NSComboBox;
	private var m_behavior:NSComboBox;
	private var m_size:NSComboBox;
	private var m_inset:NSComboBox;
	private var m_tag:NSTextField;
	private var m_alignment:NSMatrix;
	private var m_iconPos:NSMatrix;
	private var m_bordered:NSButton;
	private var m_transparent:NSButton;
	private var m_continuous:NSButton;
	private var m_enabled:NSButton;
	private var m_selected:NSButton;
	private var m_hidden:NSButton;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ButtonAttributesInspector</code> class.
	 */
	public function ButtonAttributesInspector() {
		m_loaded = false;
	}
	
	private function registerWithUI():Void {		
		m_title = NSTextField(m_file.objectForId("title"));
		m_title.setDelegate(this);
		
		m_altTitle = NSTextField(m_file.objectForId("altTitle"));
		m_altTitle.setDelegate(this);
		
		m_icon = NSTextField(m_file.objectForId("icon"));
		m_icon.setDelegate(this);
		
		m_altIcon = NSTextField(m_file.objectForId("altIcon"));
		m_altIcon.setDelegate(this);
		
		m_keyEquiv = NSTextField(m_file.objectForId("keyEquiv"));
		m_keyEquiv.setDelegate(this);
		
		m_keyEquivPresets = NSComboBox(m_file.objectForId("keyEquivPresets"));
		m_keyEquivPresets.setTarget(this);
		m_keyEquivPresets.setAction("keyEquivPresetDidSelect");
		
		m_keyModCtrl = NSButton(m_file.objectForId("keyModCtrl"));
		m_keyModCtrl.setTarget(this);
		m_keyModCtrl.setAction("keyModDidChange");
		
		m_keyModShift = NSButton(m_file.objectForId("keyModShift"));
		m_keyModShift.setTarget(this);
		m_keyModShift.setAction("keyModDidChange");
		
		m_keyModAlt = NSButton(m_file.objectForId("keyModAlt"));
		m_keyModAlt.setTarget(this);
		m_keyModAlt.setAction("keyModDidChange");
		
		m_type = NSComboBox(m_file.objectForId("type"));
		m_type.setTarget(this);
		m_type.setAction("typeDidChange");
		
		m_behavior = NSComboBox(m_file.objectForId("behavior"));
		m_behavior.setTarget(this);
		m_behavior.setAction("behaviorDidChange");
		
		m_size = NSComboBox(m_file.objectForId("size"));
		m_size.setTarget(this);
		m_size.setAction("sizeDidChange");
		
		m_inset = NSComboBox(m_file.objectForId("inset"));
		m_inset.setTarget(this);
		m_inset.setAction("insetDidChange");
		
		m_tag = NSTextField(m_file.objectForId("tag"));
		m_tag.setDelegate(this);
		
		m_alignment = NSMatrix(m_file.objectForId("alignment"));
		m_alignment.setTarget(this);
		m_alignment.setAction("alignmentDidChange");
	
		m_iconPos = NSMatrix(m_file.objectForId("iconPos"));
		m_iconPos.setTarget(this);
		m_iconPos.setAction("iconPosDidChange");
		
		m_bordered = NSButton(m_file.objectForId("bordered"));
		m_bordered.setTarget(this);
		m_bordered.setAction("borderedDidChange");
		
		m_transparent = NSButton(m_file.objectForId("transparent"));
		m_transparent.setTarget(this);
		m_transparent.setAction("transparentDidChange");
		
		m_continuous = NSButton(m_file.objectForId("continuous"));
		m_continuous.setTarget(this);
		m_continuous.setAction("continuousDidChange");
		
		m_enabled = NSButton(m_file.objectForId("enabled"));
		m_enabled.setTarget(this);
		m_enabled.setAction("enabledDidChange");
		
		m_selected = NSButton(m_file.objectForId("selected"));
		m_selected.setTarget(this);
		m_selected.setAction("selectedDidChange");
		
		m_hidden = NSButton(m_file.objectForId("hidden"));
		m_hidden.setTarget(this);
		m_hidden.setAction("hiddenDidChange");
	}
	
	//******************************************************
	//*     ObjectAttributesInspector implementation
	//******************************************************
	
	/**
	 * Returns <code>"org.actionstep.NSButton.asml"</code>.
	 */
	public function asmlFilePath():String {
		return "org.actionstep.NSButton.asml";
	}

	/**
	 * Registers the contents of <code>file</code> with the inspector.
	 */
	public function setLoadedWithAsmlFile(file:ASAsmlFile):Void {
		m_loaded = true;
		m_file = file;
		registerWithUI();
	}

	/**
	 * Returns <code>true</code> if the inspector is loaded.
	 */
	public function isLoaded():Boolean {
		return m_loaded;
	}

	/**
	 * Returns the inspector's contents.
	 */
	public function inspectorContents():NSView {
		if (!m_loaded) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				"InvalidOperationException",
				"inspector must be loaded before its contents can be accessed",
				null);
			trace(e);
			throw e;
		}
		
		return NSView(m_file.rootObjects().objectAtIndex(0));
	}

	//******************************************************
	//*                 Textfield delegate
	//******************************************************
	
	private function controlTextDidEndEditing(ntf:NSNotification):Void {
		
	}
	
	//******************************************************
	//*                  Action messages
	//******************************************************
	
	private function keyEquivPresetDidSelect(cmb:NSComboBox):Void {
		
	}
	
	private function keyModDidChange(btn:NSButton):Void {
		
	}
	
	private function typeDidChange(cmb:NSComboBox):Void {
		
	}
	
	private function behaviorDidChange(cmb:NSComboBox):Void {
		
	}
	
	private function sizeDidChange(cmb:NSComboBox):Void {
		
	}
	
	private function insetDidChange(cmb:NSComboBox):Void {
		
	}
	
	private function alignmentDidChange(matrix:NSMatrix):Void {
		
	}
	
	private function iconPosDidChange(matrix:NSMatrix):Void {
		
	}
		
	private function borderedDidChange(btn:NSButton):Void {
		
	}
	
	private function transparentDidChange(btn:NSButton):Void {
		
	}
	
	private function continuousDidChange(btn:NSButton):Void {
		
	}
	
	private function enabledDidChange(btn:NSButton):Void {
		
	}
	
	private function selectedDidChange(btn:NSButton):Void {
		
	}
	
	private function hiddenDidChange(btn:NSButton):Void {
		
	}
}