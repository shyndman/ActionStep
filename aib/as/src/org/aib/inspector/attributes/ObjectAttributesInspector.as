/* See LICENSE for copyright and terms of use */

import org.actionstep.asml.ASAsmlFile;
import org.actionstep.NSView;

/**
 * An object that supplies and interacts with the attributes editor for
 * a type (or multiple types) of editable objects.
 * 
 * @author Scott Hyndman
 */
interface org.aib.inspector.attributes.ObjectAttributesInspector {
	
	/**
	 * Returns the path to the ASML file used by this UI, or <code>null</code>
	 * if this UI does not use an asml file.
	 */
	public function asmlFilePath():String;
	
	/**
	 * Sets the UI's load state to <code>true</code> and passes the loaded
	 * asml file so that the UI can register necessary listeners.
	 */
	public function setLoadedWithAsmlFile(file:ASAsmlFile):Void;
	
	/**
	 * Returns <code>true</code> if the UI is loaded.
	 */
	public function isLoaded():Boolean;
	
	/**
	 * Returns this inspectors contents. If the inspector has not finished
	 * loading, an exception is thrown.
	 */
	public function inspectorContents():NSView;
}