/* See LICENSE for copyright and terms of use */

import org.aib.EditableObjectProtocol;

/**
 * @author Scott Hyndman
 */
interface org.aib.inspector.size.SizeInspectorContents {
	public function setWidthTextHeightText(width:String, height:String):Void;
	public function setSelection(selection:EditableObjectProtocol):Void;
}