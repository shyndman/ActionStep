/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlFile;
import org.actionstep.NSException;
import org.actionstep.NSView;
import org.aib.AIBObject;
import org.aib.inspector.attributes.ObjectAttributesInspector;

/**
 * The attributes inspector for windows.
 * 
 * @author Scott Hyndman
 */
class org.aib.inspector.attributes.WindowAttributesInspector extends AIBObject 
		implements ObjectAttributesInspector {

	private var m_loaded:Boolean;
	private var m_file:ASAsmlFile;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>WindowAttributesInspector</code> class.
	 */
	public function WindowAttributesInspector() {
		m_loaded = false;
	}
	
	//******************************************************
	//*     ObjectAttributesInspector implementation
	//******************************************************
	
	/**
	 * Returns <code>"org.actionstep.NSWindow.asml"</code>.
	 */
	public function asmlFilePath():String {
		return "org.actionstep.NSWindow.asml";
	}

	/**
	 * Registers the contents of <code>file</code> with the inspector.
	 */
	public function setLoadedWithAsmlFile(file:ASAsmlFile):Void {
		m_loaded = true;
		m_file = file;
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

}