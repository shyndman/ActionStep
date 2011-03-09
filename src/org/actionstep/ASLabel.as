/* See LICENSE for copyright and terms of use */

import org.actionstep.NSRect;
import org.actionstep.NSTextField;
import org.actionstep.NSTextFieldCell;
import org.actionstep.themes.ASTheme;

/**
 * An un-editable NSTextField with no background. 
 * 
 * This class is represented by the <code>label</code> tag in ASML.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.ASLabel extends NSTextField {
	  
	//******************************************************															 
	//*               Overridden methods
	//******************************************************
	
	/**
	 * Overrides to set label specific properties.
	 */
	public function initWithFrame(aRect:NSRect):ASLabel
	{
		super.initWithFrame(aRect);
		
		m_cell.setEditable(false);
		NSTextFieldCell(m_cell).setDrawsBackground(false);
		setFont(ASTheme.current().labelFontOfSize(0)); // default label font
		
		return this;
	}
	
	/**
	 * Labels don't accept first responder.
	 */
	public function acceptsFirstResponder():Boolean
	{
		return false;
	}

	//******************************************************															 
	//*              Required methods
	//******************************************************
	
	private static var g_cellClass:Function = org.actionstep.NSTextFieldCell;
		
	public static function cellClass():Function {
		return g_cellClass;
	}
	
	public static function setCellClass(cellClass:Function) {
		if (cellClass == null) {
			g_cellClass = org.actionstep.NSTextFieldCell;
		} else {
			g_cellClass = cellClass;
		}
	}
}