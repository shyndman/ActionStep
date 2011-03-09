/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Represents a box type. //! Not sure what this actually does.
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSBoxType extends ASConstantValue 
{	
	public static var NSBoxPrimary:NSBoxType 	= new NSBoxType(0);
	public static var NSBoxSecondary:NSBoxType 	= new NSBoxType(1);
	public static var NSBoxSeparator:NSBoxType 	= new NSBoxType(2);
	public static var NSBoxOldStyle:NSBoxType 	= new NSBoxType(3);
		
	private function NSBoxType(value:Number)
	{
		super(value);
	}
}
