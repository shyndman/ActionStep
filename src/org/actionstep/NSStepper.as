/* See LICENSE for copyright and terms of use */

import org.actionstep.NSControl;
import org.actionstep.NSEvent;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSStepperCell;

/**
 * A stepper is a control for incrementing or decrementing values, such as
 * dates or numbers.
 *
 * <code>NSStepperCell</code> is used to implement this class' user interface.
 *
 * For an example of this class' usage, please see
 * <code>org.actionstep.test.ASTestStepper</code>.
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.NSStepper extends NSControl {

	private static var g_cellClass:Function = org.actionstep.NSStepperCell;

	private var m_enabled:Boolean;
	private var m_rect:NSRect;
	private var m_down:Boolean;

	//******************************************************
	//*                  Construction
	//******************************************************

	/**
	 * Initializes a newly created stepper with a frame of ZeroRect.
	 */
	public function init():NSStepper {
		return initWithFrame(NSRect.ZeroRect);
	}

	/**
	 * Initializes a newly created stepper with the frame of <code>f</code>.
	 */
	public function initWithFrame(f:NSRect):NSStepper {
		super.initWithFrame(f);
		setEnabled(true);
		m_cell.setControlView(this);
		return this;
	}

	//******************************************************
	//*               Describing the object
	//******************************************************

	public function description ():String {
		return "NSStepper(doubleValue="+doubleValue()+")";
	}

	//******************************************************
	//*              Specifying value range
	//******************************************************

	/**
	 * Returns the maximum value of the stepper.
	 */
	public function maxValue():Number {
		return NSStepperCell(m_cell).maxValue();
	}

	/**
	 * Sets the maximum value of the stepper to <code>maxValue</code>.
	 */
	public function setMaxValue(maxValue:Number):Void {
		NSStepperCell(m_cell).setMaxValue(maxValue);
	}

	/**
	 * Returns the minimum value of the stepper.
	 */
	public function minValue():Number {
		return NSStepperCell(m_cell).minValue();
	}

	/**
	 * Sets the minimum value of the stepper to <code>minValue</code>.
	 */
	public function setMinValue(minValue:Number):Void {
		NSStepperCell(m_cell).setMinValue(minValue);
	}

	/**
	 * Returns the amount by which the stepper will change on every
	 * increment/decrement.
	 *
	 * The default is 1.
	 */
	public function increment():Number {
		return NSStepperCell(m_cell).increment();
	}

	/**
	 * Sets the amount by which the stepper will change on every
	 * increment/decrement to <code>increment</code>.
	 */
	public function setIncrement(increment:Number):Void {
		NSStepperCell(m_cell).setIncrement(increment);
	}

	//******************************************************
	//*        Specifying how the stepper responds
	//******************************************************

	/**
	 * Returns <code>true</code> if the first mouse down will perform a single
	 * increment/decrement, then after waiting 0.5 seconds, will perform
	 * 10 increments/decrements per second until the mouse is released. If
	 * <code>false</code>, only the first mouse will result in an increment/
	 * decrement.
	 *
	 * @see #setAutorepeat
	 */
	public function autorepeat():Boolean {
		return NSStepperCell(m_cell).autorepeat();
	}

	/**
	 * Sets whether the stepper will autorepeat increment/decrements after
	 * waiting 0.5 seconds following the first mouse down. If <code>true</code>
	 * it will.
	 *
	 * @see #autorepeat
	 */
	public function setAutorepeat(autorepeat:Boolean):Void {
		NSStepperCell(m_cell).setAutorepeat(autorepeat);
	}

	/**
	 * Returns whether the stepper will wrap around minimum and maximum values.
	 */
	public function valueWraps():Boolean {
		return NSStepperCell(m_cell).valueWraps();
	}

	/**
	 * Sets whether the stepper will wrap around minimum and maximum values to
	 * <code>valueWraps</code>.
	 */
	public function setValueWraps(valueWraps:Boolean):Void {
		NSStepperCell(m_cell).setValueWraps(valueWraps);
	}

	//******************************************************
	//*                    Drawing
	//******************************************************

	/**
	 * Draws the stepper in the area defined by <code>rect</code>.
	 */
	public function drawRect(rect:NSRect) {
		m_mcBounds.clear();
		m_cell.drawWithFrameInView(rect, this);
	}

	//******************************************************
	//*                 Event handling
	//******************************************************

	public function acceptsFirstMouse(theEvent:NSEvent):Boolean {
		return true;
	}

	public function becomeFirstResponder():Boolean {
		m_cell.setShowsFirstResponder(true);
		setNeedsDisplay(true);
		return true;
	}

	public function resignFirstResponder():Boolean {
		m_cell.setShowsFirstResponder(false);
		setNeedsDisplay(true);
		return true;
	}

	public function keyDown(theEvent:NSEvent):Void {
		
		switch (theEvent.keyCode) {
			case Key.UP:
				NSStepperCell(m_cell).highlightUpButtonWithFrameInView(true, 
					true, m_bounds, this);
				break;
			case Key.DOWN:
				NSStepperCell(m_cell).highlightUpButtonWithFrameInView(true, 
					false, m_bounds, this);
				break;
				
			default:
				super.keyDown(theEvent);
				break;
		}
	}

	public function setEnabled(value:Boolean) {
		super.setEnabled(value);
		setNeedsDisplay(true);
	}

	public function mouseDown(event:NSEvent):Void {
		var point:NSPoint = convertPointFromView(event.mouseLocation, null);
		var isDirectionUp:Boolean;
		var autorepeat:Boolean = NSStepperCell(m_cell).autorepeat();

		if(m_cell.isEnabled() == false) {
			return;
		}

		//don't do anyhing if it is not a left mouse click
		if(event.type != NSEvent.NSLeftMouseDown) {
			return;
		}

		var upRect:NSRect = NSStepperCell(m_cell).upButtonRectWithFrame(m_bounds);
		var downRect:NSRect = NSStepperCell(m_cell).downButtonRectWithFrame(m_bounds);

		if (upRect.pointInRect(point)) {
			isDirectionUp = true;
			m_rect = upRect;
		} else if (downRect.pointInRect(point)) {
			isDirectionUp = false;
			m_rect = downRect;
		} else {
			//not in both up/down button
			return;
		}

		//pass control to cell
		NSStepperCell(m_cell).highlightUpButtonWithFrameInView(true, isDirectionUp, m_bounds, this);

		//use NSControl.mouseDown, which supports periodic events
		if(NSStepperCell(m_cell).autorepeat()) {
			super.mouseDown(event);
		}

		setNeedsDisplay(true);
	}

	//not needed because cell will use pointInRect on up/down cell
	private function cellTrackingRect():NSRect {
		return m_rect;
	}

	/**
	 * <p>Either increases or decreases current value of the control. Its behaviour
	 * is controlled by <code>dir</code>, or the "direction" of change, ie.
	 * up (increase) or down (decrease).</p>
	 *
	 * <p>This function should be private, but if it was, 
	 * <code>NSStepperCell</code> won't be able to change its value. Thus the 
	 * "__" prefix.</p>
	 */
	public function __incdec (dir:Number) {
		var newValue:Number,
			maxValue:Number = NSStepperCell(m_cell).maxValue(),
			minValue:Number = NSStepperCell(m_cell).minValue(),
			increment:Number = NSStepperCell(m_cell).increment();

		newValue = m_cell.doubleValue() + (dir * increment);
		if (NSStepperCell(m_cell).valueWraps()) {
			if (newValue > maxValue)	m_cell.setDoubleValue(minValue);
			else if (newValue < minValue)	m_cell.setDoubleValue(maxValue);
			else m_cell.setDoubleValue(newValue);
		} else {
			if (newValue > maxValue)	m_cell.setDoubleValue(maxValue);
			else if (newValue < minValue)	m_cell.setDoubleValue(minValue);
			else	m_cell.setDoubleValue(newValue);
		}
		//don't send target, cell will do it
	}

	//******************************************************
	//*            Required NSControl methods
	//******************************************************

	public static function cellClass():Function {
		return g_cellClass;
	}

	public static function setCellClass(cellClass:Function) {
		if (cellClass == null) {
			g_cellClass = org.actionstep.NSStepperCell;
		} else {
			g_cellClass = cellClass;
		}
	}
}