/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Represents the position of a title on a box.
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSTitlePosition extends ASConstantValue 
{	    
	public static var NSNoTitle:NSTitlePosition 	= new NSTitlePosition(0);
	public static var NSAboveTop:NSTitlePosition 	= new NSTitlePosition(1);
	public static var NSAtTop:NSTitlePosition 		= new NSTitlePosition(2);
	public static var NSBelowTop:NSTitlePosition 	= new NSTitlePosition(3);
	public static var NSAboveBottom:NSTitlePosition = new NSTitlePosition(4);
	public static var NSAtBottom:NSTitlePosition 	= new NSTitlePosition(5);
	public static var NSBelowBottom:NSTitlePosition = new NSTitlePosition(6);
	
	private function NSTitlePosition(value:Number)
	{
		super(value);
	}
}
