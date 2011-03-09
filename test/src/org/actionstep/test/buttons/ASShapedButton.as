import org.actionstep.NSButton;
import org.actionstep.NSEvent;

/**
 * @author Scott Hyndman
 */
class org.actionstep.test.buttons.ASShapedButton extends NSButton {
	
	public function mouseDown(event:NSEvent):Void {
		if (event.flashObject == m_mcBounds
				|| event.flashObject._parent == m_mcBounds) {
			super.mouseDown(event);	
		}
	}
	
	public function mouseTrackingCallback(event:NSEvent) {
		if (event.type == NSEvent.NSLeftMouseUp) {
			m_cell.setHighlighted(false);
			setNeedsDisplay(true);
			//m_cell.sendActionOn(m_trackingData.actionMask);
			m_cell.setTrackingCallbackSelector(null, null);
			m_cell.mouseTrackingCallback(event);
			return;
		}
		if(event.view == this && cellTrackingRect().pointInRect(
				convertPointFromView(event.mouseLocation, null))
				&& (event.flashObject == m_mcBounds
					|| event.flashObject._parent == m_mcBounds)) {
			m_cell.setHighlighted(true);
			setNeedsDisplay(true);
			m_cell.trackMouseInRectOfViewUntilMouseUp(event, m_trackingData.bounds, 
				this, m_cell.getClass().prefersTrackingUntilMouseUp());
			return;
		}
		m_app.callObjectSelectorWithNextEventMatchingMaskDequeue(this, 
			"mouseTrackingCallback", m_trackingData.eventMask, true);
	}
  
	//******************************************************
	//*	            Required by NSControl
	//******************************************************
	
	private static var g_cellClass:Function;
	
	public static function cellClass():Function {
		if (g_cellClass == null) {
			g_cellClass = org.actionstep.NSButtonCell;
		}
		return g_cellClass;
	}

	public static function setCellClass(cellClass:Function) {
		if (cellClass == null) {
			g_cellClass = org.actionstep.NSButtonCell;
		} else {
			g_cellClass = cellClass;
		}
	}
}