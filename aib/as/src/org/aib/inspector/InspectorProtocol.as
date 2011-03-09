/* See LICENSE for copyright and terms of use */

import org.actionstep.NSView;
import org.aib.EditableObjectProtocol;
import org.aib.InspectorController;

/**
 * Defines methods to be implemented by an inspector.
 * 
 * @author Scott Hyndman
 */
interface org.aib.inspector.InspectorProtocol {
	/**
	 * Initializes the inspector with the inspector controller 
	 * <code>insepctor</code>.
	 */	
	function initWithInspectorController(inspector:InspectorController)
		:InspectorProtocol;
	
	/**
	 * Sets the directory from which inspectors can read information to
	 * <code>path</code>.
	 */
	function setSourceDirectory(path:String):Void;
	
	/**
	 * Returns the name of this inspector. This value is displayed in
	 * the inspector types combobox.
	 * 
	 * The return value should typically be fetched from the Application string
	 * table, that can be accessed using 
	 * <code>AIBApplication#stringForKeyPath</code>.
	 * 
	 * As an example, the attributes inspector 
	 * <code>org.aib.inspector.AIBAttributeInspector</code> returns the value 
	 * returned from 
	 * <code>org.aib.AIBApplication.stringWithName("Inspectors.Attributes.Name")</code>.
	 */
	function inspectorName():String;
	
	/**
	 * Returns the contents of this inspector that will be displayed when the
	 * inspector is selected.
	 */
	function inspectorContents():NSView;
	
	/**
	 * Instructs the inspector to update the display related to the 
	 * {@link EditableObjectProtocol} instances in <code>selection</code>. 
	 */
	function updateInspectorWithSelection(selection:EditableObjectProtocol):Boolean;
}