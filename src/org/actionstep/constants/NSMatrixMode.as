/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue; 

/**
 * These constants determine how {@link org.actionstep.NSCell}s behave when the 
 * {@link org.actionstep.NSMatrix} is tracking the mouse.
 *
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSMatrixMode extends ASConstantValue {
		
	/**
	 * The <code>NSCell</code>s are asked to track the mouse with 
	 * {@link org.actionstep.NSCell#trackMouseInRectOfViewUntilMouseUp} whenever
	 * the cursor is inside their bounds. No highlighting is performed.
	 */
	public static var NSTrackModeMatrix:NSMatrixMode 		= new NSMatrixMode(0);
	
	/**
	 * An <code>NSCell</code> is highlighted before it’s asked to track the mouse, 
	 * then unhighlighted when it’s done tracking.
	 */
	public static var NSHighlightModeMatrix:NSMatrixMode 	= new NSMatrixMode(1);
	
	/** 
	 * Selects no more than one <code>NSCell</code> at a time. Any time an 
	 * <code>NSCell</code> is selected, the previously selected 
	 * <code>NSCell</code> is unselected.
	 */
	public static var NSRadioModeMatrix:NSMatrixMode 		= new NSMatrixMode(2);
	
	/**
	 * <code>NSCell</code>s are highlighted, but don’t track the mouse.
	 */
	public static var NSListModeMatrix:NSMatrixMode 		= new NSMatrixMode(3);
	
	/**
	 * Creates a new instance of the <code>NSMatrixMode</code> class.
	 */
	private function NSMatrixMode(value:Number)
	{
		super(value);
	}
}
