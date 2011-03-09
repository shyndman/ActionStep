/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.ASConstantValue;

/**
 * Dictates the way a cell's text should truncate.
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSLineBreakMode extends ASConstantValue
{
	/**
	 * The default line break mode. It defaults to how the cell determines
	 * its drawing.
	 */
	public static var NSDefaultLineBreak:NSLineBreakMode
		= new NSLineBreakMode(0);
		
	/**
	 * Each line is displayed so that the end fits in the container and the 
	 * missing text is indicated by some kind of ellipsis glyph.
	 */
	public static var NSLineBreakByTruncatingHead:NSLineBreakMode
		= new NSLineBreakMode(1);
		
	/**
	 * Each line is displayed so that the beginning fits in the container and 
	 * the missing text is indicated by some kind of ellipsis glyph.
	 */
	public static var NSLineBreakByTruncatingTail:NSLineBreakMode 
		= new NSLineBreakMode(2);
		
	/**
	 * Each line is displayed so that the beginning and end fit in the container
	 * and the missing text is indicated by some kind of ellipsis glyph in the 
	 * middle.
	 */
	public static var NSLineBreakByTruncatingMiddle:NSLineBreakMode 
		= new NSLineBreakMode(3);

	/**
	 * Creates a new instance of <code>ASTruncatingType</code>.
	 */
	private function NSLineBreakMode(value:Number)
	{
		super(value);
	}
}
