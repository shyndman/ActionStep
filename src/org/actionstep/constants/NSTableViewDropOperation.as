/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Used by NSTableView to define drop operations.
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSTableViewDropOperation extends ASConstantValue
{	    
	/**
	 * Specifies that the drop should occur on the specified row.
	 */
	public static var NSTableViewDropOn:NSTableViewDropOperation 		= new NSTableViewDropOperation(0);
	
	/**
	 * Specifies that the drop should occur above the specified row.
	 */
	public static var NSTableViewDropAbove:NSTableViewDropOperation 	= new NSTableViewDropOperation(1);
	
	/**
	 * Creates a new instance of NSTableViewDropOperation
	 */
	private function NSTableViewDropOperation(value:Number)
	{		
		super(value);
	}
}
