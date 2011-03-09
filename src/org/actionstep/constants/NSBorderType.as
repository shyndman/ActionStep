/* See LICENSE for copyright and terms of use */
 
import org.actionstep.NSSize;
import org.actionstep.constants.ASConstantValue;

/**
 * Represents a border type which describes how a border should be drawn.
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSBorderType extends ASConstantValue
{
	public static var NSNoBorder:NSBorderType 		= new NSBorderType(0, NSSize.ZeroSize);
	public static var NSLineBorder:NSBorderType 	= new NSBorderType(0, new NSSize(1,1));
	public static var NSBezelBorder:NSBorderType 	= new NSBorderType(0, new NSSize(3,3));
	public static var NSGrooveBorder:NSBorderType 	= new NSBorderType(0, new NSSize(3,3));
	
	public var size:NSSize;
	
	private function NSBorderType(value:Number, size:NSSize)
	{
		super(value);
		this.size = size;
	}
	
	public function toString():String
	{
		return "NSBorderType(size=" + size + ")";
	}
}
