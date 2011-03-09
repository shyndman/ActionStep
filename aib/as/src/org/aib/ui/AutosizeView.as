/* See LICENSE for copyright and terms of use */

import org.actionstep.ASLabel;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSColor;
import org.actionstep.NSEvent;
import org.actionstep.NSFont;
import org.actionstep.NSImage;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.aib.AIBApplication;
import org.aib.ui.AIBColors;
import org.actionstep.NSPoint;
import org.actionstep.ASBitmapImageRep;
import org.actionstep.ASUtils;
import org.actionstep.NSException;

/**
 * Used by the {@link org.aib.inspector.SizeInspector} class to an interface
 * represent a view's autoresizingMask.
 * 
 * @author Scott Hyndman
 */
class org.aib.ui.AutosizeView extends NSView {
	
	private static var CLICK_TOLERANCE:Number = 12;
	
	private var m_delegate:Object;
	private var m_titleLabel:ASLabel;
	private var m_springImage:NSImage;
	private var m_mask:Number;
	
	//******************************************************
	//*                    Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>AutosizeView</code> class.
	 */
	public function AutosizeView() {
		m_mask = 0;
		m_springImage = NSImage.imageNamed("Spring");
	}
	
	/**
	 * Initializes and returns the <code>AutosizeView</code> instance with a frame
	 * area of <code>aRect</code>.
	 */
	public function initWithFrame(aRect:NSRect):AutosizeView {
		super.initWithFrame(aRect);
		m_titleLabel = (new ASLabel()).initWithFrame(
			new NSRect(4, 2, 130, 22));
		m_titleLabel.setStringValue(AIBApplication.stringForKeyPath(
			"Inspectors.Size.Autosizing"));
		m_titleLabel.setFont(NSFont.systemFontOfSize(13));
		addSubview(m_titleLabel);
		return this;
	}
	
	//******************************************************
	//*               Setting the delegate
	//******************************************************
	
	/**
	 * Returns the delegate.
	 */
	public function delegate():Object {
		return m_delegate;
	}
	
	/**
	 * <p>Sets the delegate.</p>
	 * 
	 * <p>The delegate must respond to {@link resizeMaskDidChange(newMask:Number)}
	 * or an exception is thrown.</p>
	 */
	public function setDelegate(object:Object):Void {
		if (!ASUtils.respondsToSelector(object, "resizeMaskDidChange")) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"delegate must implement resizeMaskDidChange(mask:Number)",
				null);
			trace(e);
			throw e;
		}
		
		m_delegate = object;
	}
	
	//******************************************************
	//*            Getting and setting the mask
	//******************************************************
	
	public function resizingMask():Number {
		return m_mask;
	}
	
	public function setResizingMask(value:Number):Void {
		m_mask = value;
	}
	
	//******************************************************
	//*              Responding to events
	//******************************************************
	
	public function mouseDown(event:NSEvent):Void {
		var partWidth:Number = m_frame.size.width / 4;
		var partHeight:Number = m_frame.size.height / 4;
		
		//
		// Determine location
		//
		var clickedArea:Number = 0;
		var pt:NSPoint = convertPointFromView(event.mouseLocation, null);
		var xSquare:Number = Math.floor(pt.x / partWidth);
		var ySquare:Number = Math.floor(pt.y / partHeight);
		
		if ((xSquare == 0 || xSquare == 3) && (ySquare == 1 || ySquare == 2)) {
			var d:Number = pt.y % partHeight;
			if (ySquare == 1) {
				d = -(d - partHeight);
			}
			
			if (d <= CLICK_TOLERANCE) {
				clickedArea = (xSquare == 0) ? NSView.MinXMargin : NSView.MaxXMargin;
			}
		}
		else if (xSquare == 1 || xSquare == 2) {
			switch (ySquare) {
				case 0:
				case 3:
					var d:Number = pt.x % partWidth;
					if (xSquare == 1) {
						d = -(d - partWidth);
					}
					
					if (d <= CLICK_TOLERANCE) {
						clickedArea = (ySquare == 0) ? NSView.MinYMargin : NSView.MaxYMargin;
					}
					
					break;
					
				case 1:
				case 2:
					var d:Number = pt.x % partWidth;
					if (xSquare == 1) {
						d = -(d - partWidth);
					}
					
					if (d <= CLICK_TOLERANCE) {
						clickedArea = NSView.HeightSizable;
						break;
					}
					
					d = pt.y % partHeight;
					if (ySquare == 1) {
						d = -(d - partHeight);
					}
					
					if (d <= CLICK_TOLERANCE) {
						clickedArea = NSView.WidthSizable;
					}
					
					break;
			}
		}
		
		if (clickedArea != 0) {
			if (m_mask & clickedArea) {
				m_mask &= ~clickedArea;
			} else {
				m_mask |= clickedArea;
			}
			m_delegate.resizeMaskDidChange(m_mask);
			setNeedsDisplay(true);
		}
	}
	
	//******************************************************
	//*                Drawing the view
	//******************************************************
	
	public function drawRect(aRect:NSRect):Void {
		var g:ASGraphics = graphics();
		aRect = aRect.insetRect(1, 1);
		var partWidth:Number = aRect.size.width / 4;
		var partHeight:Number = aRect.size.height / 4;
		
		//
		// Get the colors
		//
		var lineColor:NSColor = AIBColors.controlDarkShadowColor();
		var outerBorderColor:NSColor = AIBColors.controlDarkShadowColor();
		var outerFill:NSColor = AIBColors.controlDarkColor();
		var innerBorderColor:NSColor = AIBColors.controlShadowColor();
		var innerFill:NSColor = AIBColors.controlColor();
		
		//
		// Clear the graphics context
		//
		g.clear();
		
		//
		// Draw outer area.
		//
		g.brushDownWithBrush(outerFill);
		g.drawRoundedRectWithRect(aRect, 11, outerBorderColor, 1.5);
		g.brushUp();
		
		//
		// Draw inner area
		//
		g.brushDownWithBrush(innerFill);
		g.drawRect(partWidth, partHeight, 2 * partWidth, 2 * partHeight,
			innerBorderColor, 1);
		g.brushUp();
		
		//
		// Draw horizontal cross lines
		//
		ASBitmapImageRep(m_springImage.bestRepresentationForDevice()).setRotation(-90);
		var yPos:Number = 2 * partHeight;
		for (var i:Number = 0; i < 4; i++) {
			var bit:Number;
			switch (i) {
				case 0:
					bit = NSView.MinXMargin;
					break;
					
				case 1:
				case 2:
					bit = NSView.WidthSizable;
					break;
					
				case 3:
					bit = NSView.MaxXMargin;
					break;
			}
			
			var isOn:Boolean = (m_mask & bit != 0);
			if (isOn) { // draw spring
				m_springImage.lockFocus(mcBounds());
				m_springImage.drawInRect(new NSRect(
					i * partWidth, partHeight * 1.5, partWidth, partHeight));
				m_springImage.unlockFocus();
			} else {
				g.drawLine(i * partWidth, yPos, (i + 1) * partWidth, yPos,
					lineColor, 1);
			}
		}
		
		//
		// Draw vertical cross lines
		//
		ASBitmapImageRep(m_springImage.bestRepresentationForDevice()).setRotation(0);
		var xPos:Number = 2 * partWidth;
		for (var i:Number = 0; i < 4; i++) {
			var bit:Number;
			switch (i) {
				case 0:
					bit = NSView.MinYMargin;
					break;
					
				case 1:
				case 2:
					bit = NSView.HeightSizable;
					break;
					
				case 3:
					bit = NSView.MaxYMargin;
					break;
			}
			
			var isOn:Boolean = (m_mask & bit != 0);
			if (isOn) { // draw spring
				m_springImage.lockFocus(mcBounds());
				m_springImage.drawInRect(new NSRect(
					partWidth * 1.5, i * partHeight, partWidth, partHeight));
				m_springImage.unlockFocus();
			} else {
				g.drawLine(xPos, i * partHeight, xPos, (i + 1) * partHeight,
					lineColor, 1);
			}
		}
	}
}