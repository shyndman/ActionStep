/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * The following constants specify the autoresizing styles.
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSTableResizingStyle extends ASConstantValue
{	    
	/**
	 * Disable table column autoresizing.
	 */
	public static var NSTableViewNoColumnAutoresizinge:NSTableResizingStyle 
		= new NSTableResizingStyle(0);
		
	/**
	 * Autoresize all columns by distributing space equally, simultaeously.
	 */
	public static var NSTableViewUniformColumnAutoresizingStyle:NSTableResizingStyle 
		= new NSTableResizingStyle(1);
		
	/**
	 * Autoresize each table column sequentially, from left to right. Proceed
	 * to the next column when the current column has reached its minimum or
	 * maximum size. 
	 */
	public static var NSTableViewSequentialColumnAutoresizingStyle:NSTableResizingStyle 
		= new NSTableResizingStyle(2);
		
	/**
	 * Autoresize each table column sequentially, from right to left. Proceed
	 * to the next column when the current column has reached its minimum or
	 * maximum size.
	 */
	public static var NSTableViewReverseSequentialColumnAutoresizingStyle:NSTableResizingStyle
	 	= new NSTableResizingStyle(3);
	 	
	/**
	 * Autoresize only the last table colum. When that table column can no
	 * longer be resized, stop autoresizing.
	 */
	public static var NSTableViewLastColumnOnlyAutoresizingStyle:NSTableResizingStyle 
		= new NSTableResizingStyle(4);
		
	/**
	 * Autoresize only the first table colum. When that table column can no
	 * longer be resized, stop autoresizing. 
	 */
	public static var NSTableViewFirstColumnOnlyAutoresizingStyle:NSTableResizingStyle
	 	= new NSTableResizingStyle(5);
		
	/**
	 * Creates a new instance of NSTableResizingStyle
	 */
	private function NSTableResizingStyle(value:Number)
	{		
		super(value);
	}
}
