/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSTickMarkPosition;
import org.actionstep.NSCell;
import org.actionstep.NSControl;
import org.actionstep.NSEvent;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSliderCell;
import org.actionstep.NSView;

/**
 * <p>This class displays a range of values. It can be a vertical or horizontal
 * bar, or a dial. The user can change the value of the slider by dragging
 * the slider knob.</p>
 * 
 * <p>This class uses an NSSliderCell to implement its interface.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSSlider extends NSControl {

	//******************************************************															 
	//*                  Class members
	//******************************************************  
	
	private static var g_cellClass:Function;
	private static var g_actionCellClass:Function;
	
	//******************************************************
	//*                   Removing
	//******************************************************
	
	public function removeMovieClips():Void {
		super.removeMovieClips();
						
		//! FIXME Hackorifica!
		m_cell["m_knobClip"].removeMovieClip();
		m_cell["m_knobClip"] = null;
	}
	
	//******************************************************															 
	//*       Asking about the slider’s appearance
	//******************************************************
	
	/**
	 * Returns the amount the slider will change its value by when the user
	 * drags the knob with the option key held.
	 */
	public function altIncrementValue():Number {
		return NSSliderCell(m_cell).altIncrementValue();
	}
	
	/**
	 * <p>Returns the knob's thickness in pixels.</p>
	 * 
	 * <p>A knob's thickness is the length of the knob along the slider's long 
	 * dimension.</p>
	 */
	public function knobThickness():Number {
		return NSSliderCell(m_cell).knobThickness();
	}
	
	/**
	 * <p>Returns 1 if the slider is vertical, 0 if it is horizontal and -1 if the
	 * orientation cannot be determined.</p>
	 * 
	 * <p>A slider is vertical if its height is greater than its width.</p>
	 */
	public function isVertical():Number {
		return NSSliderCell(m_cell).isVertical();
	}
	
	//******************************************************															 
	//*         Changing the slider’s appearance
	//******************************************************
	
	/**
	 * Sets the amount by which the slider changes its value when the user
	 * drags the knob with the option key held.
	 */
	public function setAltIncrementValue(value:Number):Void {
		NSSliderCell(m_cell).setAltIncrementValue(value);
	}
	
	//******************************************************
	//*          Asking about the slider’s title
	//******************************************************
	
	/**
	 * <p>Returns the receiver’s title.</p>
	 * 
	 * <p>Default is ""</p>
	 */
	public function title():String {
		return m_cell.title();
	}
	
	//******************************************************															 
	//*             Modifying value limits
	//******************************************************
	
	/**
	 * Returns the minimum value of the slider.
	 */
	public function minValue():Number {
		return NSSliderCell(m_cell).minValue();
	}
	
	/**
	 * Sets the minimum value of the slider to <code>value</code>.
	 */
	public function setMinValue(value:Number):Void {
		NSSliderCell(m_cell).setMinValue(value);
	}
	
	/**
	 * Returns the maximum value of the slider.
	 */
	public function maxValue():Number {
		return NSSliderCell(m_cell).maxValue();
	}
	
	/**
	 * Sets the maximum value of the slider to <code>value</code>.
	 */
	public function setMaxValue(value:Number):Void {
		NSSliderCell(m_cell).setMaxValue(value);
	}
	
	//******************************************************															 
	//*           Handling mouse-down events
	//******************************************************
	
	/**
	 * Always returns <code>true</code>.
	 */
	public function acceptsFirstMouse(event:NSEvent):Boolean {
		return true;
	}
	
	/**
	 * Returns the rectangle that is used to track the mouse.
	 */
	private function cellTrackingRect():NSRect {
		return NSSliderCell(m_cell).trackRect();
	}
  
	//******************************************************															 
	//*              Managing tick marks
	//******************************************************
	
	/**
	 * Returns <code>true</code> if the slider can only be set to values
	 * associated with tick marks, and nothing in between.
	 * 
	 * @see #setAllowsTickMarkValuesOnly()
	 */
	public function allowsTickMarkValuesOnly():Boolean {
		return NSSliderCell(m_cell).allowsTickMarkValuesOnly();
	}
	
	/**
	 * Sets whether the receiver’s values are fixed to the values represented 
	 * by the tick marks to <code>flag</code>.
	 */
	public function setAllowsTickMarkValuesOnly(flag:Boolean):Void {
		NSSliderCell(m_cell).setAllowsTickMarkValuesOnly(flag);
	}
	
	/**
	 * Returns the value of the tick mark closest to <code>value</code>.
	 */
	public function closestTickMarkValueToValue(value:Number):Number {
		return NSSliderCell(m_cell).closestTickMarkValueToValue(value);
	}
	
	/**
	 * <p>Returns the index of the tick mark closest to the location specified
	 * by <code>point</code>.</p>
	 * 
	 * <p>If point is not within the bounding rectangle of any tick, this method
	 * returns {@link #NSNotFound}.</p>
	 */
	public function indexOfTickMarkAtPoint(point:NSPoint):Number {
		return NSSliderCell(m_cell).indexOfTickMarkAtPoint(point);
	}
	
	/**
	 * Returns the number of tick marks in the slider.
	 * 
	 * @see #setNumberOfTickMarks()
	 */
	public function numberOfTickMarks():Number {
		return NSSliderCell(m_cell).numberOfTickMarks();
	}
	
	/**
	 * Sets the number of tick marks in the slider to <code>count</code>.
	 * 
	 * @see #numberOfTickMarks()
	 */
	public function setNumberOfTickMarks(count:Number):Void {
		NSSliderCell(m_cell).setNumberOfTickMarks(count);
	}
	
	/**
	 * <p>Returns the bounding rectangle of the tick identified by
	 * <code>index</code>.</p>
	 * 
	 * <p>If no tick mark is associated with <code>index</code>, the method raises 
	 * an {@link NSException}.</p>
	 */
	public function rectOfTickMarkAtIndex(index:Number):NSRect {
		return NSSliderCell(m_cell).rectOfTickMarkAtIndex(index);
	}
	
	/**
	 * Returns the position of the tick marks on the slider.
	 */
	public function tickMarkPosition():NSTickMarkPosition {
		return NSSliderCell(m_cell).tickMarkPosition();
	}
	
	/**
	 * Sets how tick marks are aligned with the slider to <code>position</code>.
	 */
	public function setTickMarkPosition(position:NSTickMarkPosition):Void {
		NSSliderCell(m_cell).setTickMarkPosition(position);
	}
	
	/**
	 * <p>Returns the value of the tick mark associated with <code>index</code>.</p>
	 * 
	 * <p>If no tick mark is associated with <code>index</code>, the method raises 
	 * an {@link NSException}.</p>
	 */
	public function tickMarkValueAtIndex(index:Number):Number {
		return NSSliderCell(m_cell).tickMarkValueAtIndex(index);
	}

	//******************************************************
	//*             MovieClip (ActionStep-only)
	//******************************************************
	
	private function requiresMask():Boolean {
		return false;
	}
	
	//******************************************************															 
	//*                Updating the cell
	//******************************************************
	
	public function updateCell(cell:NSCell):Void {
		var c:NSSliderCell = NSSliderCell(cell);
		c.drawKnob();
	}
	
	//******************************************************															 
	//*             Setting the cell class
	//******************************************************
	
	/**
	 * <p>Sets the cell class to <code>klass</code> (must be a subclass of
	 * <code>NSSliderCell</code>). An instance of the cell class is instantiated 
	 * for every new control.</p>
	 *
	 * <p>NOTE: Must be overridden in subclasses.</p>
	 */
	public static function setCellClass(klass:Function):Void {
		g_cellClass = klass;
	}
	
	/**
	 * <p>Returns the cell class.</p>
	 *
	 * <p>NOTE: Must be overridden in subclasses.</p>
	 */  
	public static function cellClass():Function {
		if (g_cellClass == undefined) {
			g_cellClass = org.actionstep.NSSliderCell;
		}
		return g_cellClass;
	}
	
	/**
	 * Sets the action cell class to <code>klass</code>.
	 */
	public static function setActionCellClass(klass:Function):Void {
		g_actionCellClass = klass;
	}
	
	/**
	 * Returns the action cell class.
	 */
	public static function actionCellClass():Function {
		if (g_actionCellClass == undefined) {
			g_actionCellClass = org.actionstep.NSSliderCell;
		}
		return g_actionCellClass;
	}
}