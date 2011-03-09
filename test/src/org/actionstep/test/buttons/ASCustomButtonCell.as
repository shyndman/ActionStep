/* See LICENSE for copyright and terms of use */

import org.actionstep.NSButtonCell;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.ASDraw;
import org.actionstep.NSEvent;
import org.actionstep.NSPoint;

/**
 * <p>Custom button drawing.</p>
 * <p><strong>Usage:</strong></p>
 * <code>
 * var btn:NSButton = (new NSButton()).initWithFrame(new NSRect(0, 0, 100, 22));
 * btn.setCell((new ASCustomButtonCell()).initTextCell("Foo"));
 * </code>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.test.buttons.ASCustomButtonCell extends NSButtonCell {
	
	public function mouseTrackingCallback(event:NSEvent):Void {
		//trace("NSCell.mouseTrackingCallback(event)");
		var point:NSPoint = event.mouseLocation.clone();
		//optional cast -- apparently, mtasc's && returns last value
		var periodic:Boolean = Boolean((event.type == NSEvent.NSPeriodic) 
			&& (m_actionMask & NSEvent.NSPeriodicMask));
		m_trackingData.view.mcBounds().globalToLocal(point);
		if(!m_trackingData.untilMouseUp
				&& event.view != m_trackingData.view) { //moved out of view
			stopTrackingAtInViewMouseIsUp(m_trackingData.lastPoint, point, 
				controlView(), false);
			//stimulate mouseUp
			m_trackingCallback[m_trackingCallbackSelector].call(m_trackingCallback, 
				false, periodic);
			//
			// Stop sending periodic when mouse up **very impt**
			//
			if (m_actionMask & NSEvent.NSPeriodicMask) {	
				NSEvent.stopPeriodicEvents();
			}
		} else { // still in view
			if (event.type == NSEvent.NSLeftMouseUp) { // mouse up?
				stopTrackingAtInViewMouseIsUp(m_trackingData.lastPoint, point, 
					controlView(), true);
				m_trackingCallback[m_trackingCallbackSelector].call(m_trackingCallback, 
					true, periodic);

				setNextState();
				if(m_actionMask & NSEvent.NSLeftMouseUpMask) {
					m_trackingData.view.sendActionTo(m_trackingData.action, 
						m_trackingData.target);
				}
				
				//
				// Stop sending periodic when mouse up **very impt**
				//
				if (m_actionMask & NSEvent.NSPeriodicMask) {
					NSEvent.stopPeriodicEvents();
				}
			} else { // no mouse up
				if (periodic) { //! Dragged too?
					m_trackingData.view.sendActionTo(m_trackingData.action, 
						m_trackingData.target);
				}
				
				var mcbnds:MovieClip = controlView().mcBounds();
				if (continueTrackingAtInView(m_trackingData.lastPoint, point, 
						controlView()) && (event.flashObject == mcbnds || event.flashObject._parent == mcbnds)
						) {
					m_trackingData.lastPoint = point;
					m_trackingCallback[m_trackingCallbackSelector].call(
						m_trackingCallback, false, periodic);
							
					m_app.callObjectSelectorWithNextEventMatchingMaskDequeue(this, 
						"mouseTrackingCallback", m_trackingData.eventMask, true);
				} else { // don't continue...no mouse up
					stopTrackingAtInViewMouseIsUp(m_trackingData.lastPoint, point, 
						controlView(), false);
					m_trackingCallback[m_trackingCallbackSelector].call(
						m_trackingCallback, false, periodic);
							
					if (m_actionMask & NSEvent.NSPeriodicMask) {
						NSEvent.stopPeriodicEvents();
					}
				}
			}
		}
	}
  
	private function drawBezelWithFrameInView(cellFrame:NSRect, 
			inView:NSView):Void {
		
		var highlighted:Boolean = isHighlighted(); // highlight means pressed
		var mc:MovieClip = inView.mcBounds(); // the drawing surface
		
		if (highlighted) {
			mc.beginFill(0x666666, 100);
		} else {
			mc.beginFill(0x888888, 100);
		}
		ASDraw.drawEllipseWithRect(mc, cellFrame);
		mc.endFill();
	}
}