/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Defines return code constants for modal loops.
 * All functions refer to <code>org.actionstep.NSApplication</code>.
 */
class org.actionstep.constants.NSRunResponse extends ASConstantValue {
	
	//******************************************************
	//*                   Constants
	//******************************************************
	
	/** Modal session was broken with <code>stopModal</code>. */
	public static var NSStopped:NSRunResponse	= new NSRunResponse(-1000);
	
	/** Modal session was broken with <code>abortModal</code>. */
	public static var NSAborted:NSRunResponse	= new NSRunResponse(-1001);
	
	/** Modal session is continuing (returned by <code>runModalSession</code> only). */
	public static var NSContinues:NSRunResponse	= new NSRunResponse(-1002);

	//******************************************************
	//*                  Construction
	//******************************************************

	private function NSRunResponse(value:Number) {
		super(value);
	}
}
