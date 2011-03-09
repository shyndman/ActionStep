/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASUpDownCellPart;
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.NSButtonCell;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;

/**
 * This cell is contains 2 buttons, and will send messages when either one is highlighted or
 * de-highlighted, thus relieving the user of the burden of tracking these buttons.
 *
 * The "parent" cell will refer to the ASUpDownCell, while the "composite" cell will refer to the
 * up and down button cells that the parent cell contains.
 *
 * @author Tay Ray Chuan
 */

class org.actionstep.ASUpDownCell extends NSButtonCell {

	//******************************************************
	//*                   Class Members
	//******************************************************

	/**
	 * The default size of the image for the up stepper/scroller arrow. Here we assume that both
	 * the up and down arrow images are of the same size. This assumption currently holds.
	 */
	private static var IMG_SIZE:NSSize;

	//******************************************************
	//*                   Member Variables
	//******************************************************

	private var m_upCell:NSButtonCell;
	private var m_downCell:NSButtonCell;

	private var m_cells:Object;
	private var m_trackingCell:NSButtonCell;

	public function ASUpDownCell() {
		if(!IMG_SIZE) {
			IMG_SIZE = NSImage.imageNamed("NSStepperUpArrow").size();
		}
	}

	public function init():ASUpDownCell {
		m_upCell = (new NSButtonCell()).initImageCell(null);
		m_upCell.setHighlighted(false);
		m_upCell.setHighlightsBy(m_highlightsBy);
		m_upCell.setImage(NSImage.imageNamed("NSStepperUpArrow"));
		m_upCell.setAlternateImage(NSImage.imageNamed("NSHighlightedStepperUpArrow"));
		m_upCell.setImagePosition(NSCellImagePosition.NSImageOnly);
		m_upCell.setTrackingCallbackSelector(this, "trackBtn");

		m_downCell = (new NSButtonCell()).initImageCell(null);
		m_downCell.setHighlighted(false);
		m_downCell.setHighlightsBy(m_highlightsBy);
		m_downCell.setImage(NSImage.imageNamed("NSStepperDownArrow"));
		m_downCell.setAlternateImage(NSImage.imageNamed("NSHighlightedStepperDownArrow"));
		m_downCell.setImagePosition(NSCellImagePosition.NSImageOnly);
		m_downCell.setTrackingCallbackSelector(this, "trackBtn");

		m_cells = {};
		m_cells[ASUpDownCellPart.ASUpCell.value] = m_upCell;
		m_cells[ASUpDownCellPart.ASDownCell.value] = m_downCell;

		return this;
	}

	//******************************************************
	//*                   Composited Methods
	//******************************************************

	/**
	 * Sets the way this and the composite cell highlights when pressed.
	 */
	public function setHighlightsBy(n:Number):Void {
		super.setHighlightsBy(n);
		m_upCell.setHighlightsBy(n);
		m_downCell.setHighlightsBy(n);
	}

	/**
	 * Sets the conditions on which the receiver and the button cells sends action messages to its
	 * target.
	 *
	 * The previous action mask of the receiver is returned.
	 */
	public function sendActionOn(n:Number):Number {
		m_upCell.sendActionOn(n);
		m_downCell.sendActionOn(n);
		return super.sendActionOn(n);
	}

	/**
	 * Sets the message delay and interval to <code>delay</code> and <code>interval</code>
	 * respectively for the receiver and the composite cells.
	 */
	public function setPeriodicDelayInterval(delay:Number, interval:Number) {
		super.setPeriodicDelayInterval(delay, interval);
		m_upCell.setPeriodicDelayInterval(delay, interval);
		m_downCell.setPeriodicDelayInterval(delay, interval);
	}

	//******************************************************
	//*                   Frames for composite cells
	//******************************************************

	public function upButtonRectWithFrame(cellFrame:NSRect):NSRect {
		return new NSRect(
		cellFrame.maxX() - IMG_SIZE.width, cellFrame.minY(),
		IMG_SIZE.width, IMG_SIZE.height);
	}

	public function downButtonRectWithFrame(cellFrame:NSRect):NSRect {
		return new NSRect(
		cellFrame.maxX() - IMG_SIZE.width, cellFrame.maxY() - IMG_SIZE.height,
		IMG_SIZE.width, IMG_SIZE.height);
	}

	/**
	 * Sets whether this and the tracked composite cell has a highlighted appearance, depending on
	 * the Boolean value <code>flag</code>.
	 */
	public function setHighlighted(n:Boolean):Void {
		super.setHighlighted(n);
		m_trackingCell.setHighlighted(n);
	}

	/**
	 * Overrides the current implementation, so that the parent cell will receive messages from the
	 * tracked composite cell during tracking.
	 *
	 * We assume that the control associated with this cell will pass a <code>false</code> value to
	 * <code>setHighlighted()</code>, before invoking this method with <code>null</code> arguments.
	 * This will cause the reciever to note that no composite cell is being tracked.
	 */
	public function setTrackingCallbackSelector(callback:Object, selector:String) {
		super.setTrackingCallbackSelector(callback, selector);
		if(callback==null && selector==null) {
			m_trackingCell = null;
		}
	}

	/**
	 * The callback for the tracked composite cell.
	 */
	public function trackBtn(isMouseUp:Boolean, isPeriodic:Boolean):Void {
		m_trackingCallback[m_trackingCallbackSelector].call(m_trackingCallback,
			isMouseUp, isPeriodic);
	}

	/**
	 * Draws the receiver as well as both the composite cells.
	 */
	public function drawInteriorWithFrameInView(cellFrame:NSRect, inView:NSView):Void {
		var img:NSImage = NSImage.imageNamed("NSStepperUpArrow");
		var upFrame:NSRect = upButtonRectWithFrame(cellFrame);
		var downFrame:NSRect = downButtonRectWithFrame(cellFrame);

		m_upCell.drawWithFrameInView(upFrame, inView);
		m_downCell.drawWithFrameInView(downFrame, inView);
	}

	/**
	 * Overrides the current implementation.
	 *
	 * If one of the composite cells is clicked, the reciever takes note of the composite cell currently
	 * being tracked internally , before invoking the same method on that cell. We assume that the
	 * <code>isHighlighted</code> property is updated by the control before invoking this method.
	 *
	 * If none of the composite cells are clicked, a <code>"mouse up"</code> message is sent to the
	 * control, to stop tracking.
	 */
	public function trackMouseInRectOfViewUntilMouseUp(event:NSEvent, rect:NSRect,
		view:NSView, untilMouseUp:Boolean):Void {
		var part:ASUpDownCellPart = detCellPart(event);
		if(part==null) {
			m_trackingCallback[m_trackingCallbackSelector].call(m_trackingCallback,
				true, m_actionMask & NSEvent.NSPeriodicMask);
		} else {
			m_trackingCell = NSButtonCell(m_cells[part.value]);
			m_trackingCell.setHighlighted(isHighlighted());
			m_trackingCell.trackMouseInRectOfViewUntilMouseUp(
				event, trackedRectForCellPart(rect, part), view, untilMouseUp);
		}
	}

	/**
	 * Overrides the current implementation, although it may be redundant.
	 *
	 * The receiver takes note of the cell being tracked
	 */
	public function mouseTrackingCallback(event:NSEvent):Void {
		m_trackingCell = NSButtonCell(m_cells[detCellPart(event).value]);
		m_trackingCell.setHighlighted(false);
		m_trackingCell.mouseTrackingCallback(event);
	}

	//******************************************************
	//*                   Target-action for composite cells
	//******************************************************

	public function setTargetForCellPart(target:Object, part:ASUpDownCellPart):Void {
		NSButtonCell(m_cells[part.value]).setTarget(target);
	}

	public function targetForCellPart(part:ASUpDownCellPart):Object {
		return NSButtonCell(m_cells[part.value]).target();
	}

	 public function setActionForCellPart(action:String, part:ASUpDownCellPart):Void {
		NSButtonCell(m_cells[part.value]).setAction(action);
	}

	public function actionForCellPart(part:ASUpDownCellPart):String {
		return NSButtonCell(m_cells[part.value]).action();
	}

	//******************************************************
	//*                   Helper methods
	//******************************************************

	/**
	 * Returns a constant from <code>ASUpDownCellPart</code> to indicate the composite cell
	 * <code>event.mouseLocation()</code> is over.
	 */
	private function detCellPart(event:NSEvent):ASUpDownCellPart {
		var pt:NSPoint = NSPoint(event.mouseLocation.copy());
		controlView().mcBounds().globalToLocal(pt);
		if(upButtonRectWithFrame(controlView().frame()).pointInRect(pt)) {
			return ASUpDownCellPart.ASUpCell;
		} else if(downButtonRectWithFrame(controlView().frame()).pointInRect(pt)) {
			return ASUpDownCellPart.ASDownCell;
		} else {
			return null;
		}
	}

	/**
	 * Returns an instance of <code>NSRect</code> which contains the composite cell
	 * <code>part</code> refers to, relative to <code>cellFrame</code>.
	 */
	private function trackedRectForCellPart(cellFrame:NSRect, part:ASUpDownCellPart):NSRect {
		if(part == ASUpDownCellPart.ASUpCell) {
			return upButtonRectWithFrame(cellFrame);
		} else if (part == ASUpDownCellPart.ASDownCell) {
			return downButtonRectWithFrame(cellFrame);
		} else {
			return null;
		}
	}

	/**
	 * Returns a string for a composite cell.
	 */
	private function cellNameForCell(cell:NSButtonCell):String {
		if(cell==m_upCell) {
			return "up cell";
		} else if(cell==m_downCell) {
			return "down cell";
		} else {
			return "none";
		}
	}
}