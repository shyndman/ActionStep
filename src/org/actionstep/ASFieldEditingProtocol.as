/* See LICENSE for copyright and terms of use */

import org.actionstep.ASFieldEditor;

/**
 * Defines methods that handle text editing.
 * 
 * TODO Write better comment
 *
 * @author Scott Hyndman
 */
interface org.actionstep.ASFieldEditingProtocol 
{	
	function beginEditingWithDelegate(delegate:Object):ASFieldEditor;
	function endEditingWithDelegate(delegate:Object):Void;
}
