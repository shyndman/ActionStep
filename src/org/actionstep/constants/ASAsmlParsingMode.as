/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Used by the <code>ASAsmlReader</code> class to describe what type of 
 * parsing should occur one the asml file has finished loading.
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.ASAsmlParsingMode extends ASConstantValue 
{	
	/**
	 * The loaded file will be parsed as a complete file (ie. the root node is 
	 * the asmarkup node).
	 */
	public static var ASFullFile:ASAsmlParsingMode 			= new ASAsmlParsingMode(0);
	
	/**
	 * The loaded file will be parsed as a file containing an object tree. 
	 */
	public static var ASPartialObjects:ASAsmlParsingMode 	= new ASAsmlParsingMode(1);
	
	/**
	 * The loaded file will be parsed as a file containing a connectors tree.
	 */
	public static var ASPartialConnectors:ASAsmlParsingMode = new ASAsmlParsingMode(2);
			
	/**
	 * Creates a new instance of ASAsmlParsingMode.
	 */
	private function ASAsmlParsingMode(value:Number)
	{
		super(value);
	}
}
