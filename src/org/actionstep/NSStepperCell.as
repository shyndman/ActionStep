/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSBezelStyle;
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSActionCell;
import org.actionstep.NSButtonCell;
import org.actionstep.NSCell;
import org.actionstep.NSDictionary;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSImage;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSStepper;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;

/**
 * This class controls the appearance and behaviour of an
 * <code>NSStepper</code>.
 *
 * @author Tay Ray Chuan
 */
class org.actionstep.NSStepperCell extends NSActionCell {

	private static var g_upCell:NSButtonCell;
	private static var g_downCell:NSButtonCell;

	private var m_maxValue:Number;
	private var m_minValue:Number;
	private var m_increment:Number;
	private var m_autorepeat:Boolean;
	private var m_valueWraps:Boolean;
	private var m_mc:MovieClip;
	private var m_cell:NSCell;
	private var m_rect:NSRect;
	private var m_value:Number;
	private var m_textField:TextField;
	private var m_periodicDelay:Number;
	private var m_periodicInterval:Number;
	private var $m_trackingCallback:Object;
	private var $m_trackingCallbackSelector:String;

	var highlightUp:Boolean;

	//******************************************************
	//*                  Construction
	//******************************************************

	/**
	 * Creates a new instance of <code>NSStepperCell</code>.
	 */
	public function NSStepperCell() {
		m_textField = null;
		m_autorepeat = true;
		m_valueWraps = true;
		m_maxValue = 59;
		m_minValue = 0;
		setIntValue(0);
		m_increment = 1;
		highlightUp = false;

		m_trackingCallback = this;
		m_trackingCallbackSelector = "trackBtn";

		drawParts();
	}

	/**
	 * Initializes a newly created <code>NSStepperCell</code>.
	 */
	public function init():NSStepperCell {
		super.init();
		setAlignment(NSTextAlignment.NSRightTextAlignment);
		setContinuous(true);
		sendActionOn(NSEvent.NSLeftMouseDownMask | NSEvent.NSLeftMouseUpMask | NSEvent.NSPeriodicMask);
		setPeriodicDelayInterval(0.5, 0.1);
		setBezelStyle(NSBezelStyle.NSShadowlessSquareBezelStyle);
		setBezeled(true);
		setHighlighted(false);
		return this;
	}

	//******************************************************
	//*             Specifying value range
	//******************************************************

	/**
	 * Returns the maximum value of the stepper.
	 */
	public function maxValue():Number {
		return m_maxValue;
	}

	/**
	 * Sets the maximum value of the stepper to <code>maxValue</code>.
	 */
	public function setMaxValue (maxValue:Number):Void {
		m_maxValue = maxValue;
	}

	/**
	 * Returns the minimum value of the stepper.
	 */
	public function minValue():Number {
		return m_minValue;
	}

	/**
	 * Sets the minimum value of the stepper to <code>minValue</code>.
	 */
	public function setMinValue(minValue:Number):Void {
		if (m_value < minValue) {
			m_value = minValue;
		}
		m_minValue = minValue;
	}

	/**
	 * Returns the amount by which the stepper will change on every
	 * increment/decrement.
	 *
	 * The default is 1.
	 */
	public function increment ():Number {
		return m_increment;
	}

	/**
	 * Sets the amount by which the stepper will change on every
	 * increment/decrement to <code>increment</code>.
	 */
	public function setIncrement(increment:Number):Void	{
		m_increment = increment;
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
		return m_autorepeat;
	}

	/**
	 * Sets whether the stepper will autorepeat increment/decrements after
	 * waiting 0.5 seconds following the first mouse down. If <code>true</code>
	 * it will.
	 *
	 * @see #autorepeat
	 */
	public function setAutorepeat(autorepeat:Boolean):Void {
		m_autorepeat = autorepeat;
	}

	/**
	 * Returns whether the stepper will wrap around minimum and maximum values.
	 */
	public function valueWraps():Boolean {
		return m_valueWraps;
	}

	/**
	 * Sets whether the stepper will wrap around minimum and maximum values to
	 * <code>valueWraps</code>.
	 */
	public function setValueWraps(valueWraps:Boolean):Void {
		m_valueWraps = valueWraps;
	}

	/**
	 * Returns an object with delay and interval properties
	 */
	public function getPeriodicDelayInterval():Object {
		return {delay:m_periodicDelay, interval:m_periodicInterval};
	}

	public function setPeriodicDelayInterval(delay:Number, interval:Number) {
		m_periodicDelay = delay;
		m_periodicInterval = interval;
	}

	//******************************************************
	//*            Setting the cell's value
	//******************************************************

	public function setDoubleValue(n:Number):Void {
		if(n<m_minValue || n>m_maxValue) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo
			(NSException.NSInvalidArgument, "value out of range",
			(new NSDictionary()).initWithObjectsAndKeys(n, "value"));
			trace(e);
			e.raise();
		}
		m_value = n;
		m_textField.text = n.toString();
	}

	public function doubleValue():Number {
		return m_value;
	}

	public function setIntValue(n:Number):Void {
		setDoubleValue(n);
	}

	public function intValue():Number {
		return m_value;
	}

	//******************************************************
	//*         Setting the appearance of the cell
	//******************************************************

	//
	// Note: We assume that both up/down have same props.
	//

	public function setBordered(f:Boolean) {
		g_upCell.setBordered(f);
		g_downCell.setBordered(f);
	}

	public function isBordered():Boolean {
		return g_upCell.isBordered();
	}

	public function setBezeled(f:Boolean) {
		g_upCell.setBezeled(f);
		g_downCell.setBezeled(f);
	}

	public function isBezeled():Boolean {
		return g_upCell.isBezeled();
	}

	public function setBezelStyle(f:NSBezelStyle) {
		g_upCell.setBezelStyle(f);
		g_downCell.setBezelStyle(f);
	}

	public function bezelStyle():NSBezelStyle {
		return g_upCell.bezelStyle();
	}

	public function setHighlighted (sel:Boolean) {
		super.setHighlighted(sel);
		if(m_highlighted) {
			g_upCell.setHighlighted(highlightUp);
			g_downCell.setHighlighted(!highlightUp);
		} else {
			g_upCell.setHighlighted(false);
			g_downCell.setHighlighted(false);
		}
		//don't draw immediately; setNeedsDisplay first
	}

	public function setEnabled(value:Boolean) {
		super.setEnabled(value);
		g_upCell.setEnabled(value);
		g_downCell.setEnabled(value);
	}

	//******************************************************
	//*                Drawing the cell
	//******************************************************

	public function drawParts():Void {
		if (g_upCell != null) {
			return;
		}
		g_upCell = new NSButtonCell();
		g_upCell.setHighlightsBy(NSCell.NSChangeBackgroundCellMask | NSCell.NSContentsCellMask);
		g_upCell.setImage(NSImage.imageNamed("NSStepperUpArrow"));
		g_upCell.setAlternateImage(NSImage.imageNamed("NSHighlightedStepperUpArrow"));
		g_upCell.setImagePosition(NSCellImagePosition.NSImageOnly);
		g_upCell.setTrackingCallbackSelector(this, "trackButton");

		g_downCell = new NSButtonCell();
		g_downCell.setHighlightsBy(NSCell.NSChangeBackgroundCellMask | NSCell.NSContentsCellMask);
		g_downCell.setImage(NSImage.imageNamed("NSStepperDownArrow"));
		g_downCell.setAlternateImage(NSImage.imageNamed("NSHighlightedStepperDownArrow"));
		g_downCell.setImagePosition(NSCellImagePosition.NSImageOnly);
		g_downCell.setTrackingCallbackSelector(this, "trackButton");
	}

	public function drawInteriorWithFrameInView(cellFrame:NSRect, inView:NSView):Void {
		var upRect:NSRect = upButtonRectWithFrame(cellFrame);
		var downRect:NSRect = downButtonRectWithFrame(cellFrame);
		var txtRect:NSRect = textRectWithFrame(cellFrame);
		var m_bezelStyle:NSBezelStyle = bezelStyle();
		var m_bezeled:Boolean = isBezeled();
		var m_bordered:Boolean = isBordered();
		var m_textFormat:TextFormat;

		var x:Number = cellFrame.origin.x;
		var y:Number = cellFrame.origin.y;
		var width:Number = cellFrame.size.width;
		var height:Number = cellFrame.size.height;
		var tf:TextField;

		if (m_textField == null || m_textField._parent == undefined) {
			m_textField = inView.createBoundsTextField();
			tf = m_textField;
			m_textFormat = m_font.textFormatWithAlignment(m_alignment);
			//tf.selectable = false;

			tf._width = txtRect.size.width;
			tf._height = txtRect.size.height;
			tf._x = txtRect.origin.x;
			tf._y = txtRect.origin.y;
			tf.setNewTextFormat(m_textFormat);
		}
		
		//! FIXME Make this into something stepper specific
		ASTheme.current().drawStepperCellBorderInRectOfView(this, cellFrame, inView);

		if(!g_upCell.isHighlighted() && !g_downCell.isHighlighted()) {
			//m_rect = null;
			//m_cell = null;
		}

		setDoubleValue(doubleValue());

		g_upCell.drawWithFrameInView(upRect, inView);
		g_downCell.drawWithFrameInView(downRect, inView);
		
	    //
	    // Draw first responder
	    //
	    if (m_showsFirstResponder) {
	    	ASTheme.current().drawFirstResponderWithRectInView(cellFrame, inView);
	    }
	}

	public function highlightUpButtonWithFrameInView (hlt:Boolean, upButton:Boolean, frame:NSRect, controlView:NSView):Void {
		var upRect:NSRect = upButtonRectWithFrame(frame);
		var downRect:NSRect = downButtonRectWithFrame(frame);

		m_rect = (upButton) ? upRect : downRect;
		m_cell = (upButton) ? g_upCell : g_downCell;

		highlightUp = upButton;

		NSStepper(m_controlView).__incdec((highlightUp ? 1 : -1));
	}

	public function upButtonRectWithFrame(f:NSRect):NSRect {
		return new NSRect(
		f.maxX() - 16, f.minY() + (f.size.height / 2) - 10,
		15, 10);
	}

	public function downButtonRectWithFrame(f:NSRect):NSRect {
		return new NSRect(
		f.maxX() - 16, f.minY() + (f.size.height / 2),
		15, 10);
	}

	public function textRectWithFrame (f:NSRect):NSRect {
		return new NSRect(
		f.minX()+2, f.minY() + (f.size.height - 20)/2,
		f.maxX() - 23, 20);
	}

	//******************************************************
	//*               Mouse tracking
	//******************************************************

	public function setTrackingCallbackSelector(callback:Object, selector:String) {
		$m_trackingCallback = callback;
		$m_trackingCallbackSelector = selector;
	}

	public function continueTrackingAtInView(lastPoint:NSPoint, currentPoint:NSPoint, controlView:NSView):Boolean {
		if(m_rect.pointInRect(currentPoint)) {
			return true;
		} else {
			return false;
		}
	}

	public function stopTrackingAtInViewMouseIsUp(lastPoint:NSPoint, stopPoint:NSPoint, controlView:NSView, mouseIsUp:Boolean) {
		if(!mouseIsUp) {
			//trackBtn(false);
			//NSControl takes care of highlighting
			//$m_trackingCallback[$m_trackingCallbackSelector].call($m_trackingCallback, true);
			setHighlighted(false);
		}
	}

	/**
	 * param is actually isMouseUp
	 */
	public function trackBtn(mouse:Boolean, p:Boolean) {
		if(mouse && !isHighlighted())	{
			setHighlighted(false);
		} else if(p) {
			highlightUpButtonWithFrameInView (highlightUp, highlightUp, m_controlView.bounds(), m_controlView);
		}
		$m_trackingCallback[$m_trackingCallbackSelector].call($m_trackingCallback, mouse);
	}
}