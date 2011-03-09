/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.constants.NSImageAlignment;
import org.actionstep.constants.NSImageFrameStyle;
import org.actionstep.constants.NSImageScaling;
import org.actionstep.NSCell;
import org.actionstep.NSImage;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;

/**
 * This class displays a single NSImage in a frame. It has the ability to
 * scale and align the image.
 * 
 * This class' object value must be an NSImage. If you call
 * <code>NSImageCell.setObjectValue</code>, make sure the argument is an
 * instance of NSImage.
 * 
 * This class does not use formatters.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSImageCell extends NSCell {
	
	private var m_frameStyle:NSImageFrameStyle;
	private var m_imageAlignment:NSImageAlignment;
	private var m_imageScaling:NSImageScaling;
	private var m_imageRect:NSRect;
	
	/**
	 * Creates a new instance of NSImageCell
	 */
	public function NSImageCell() {
		super();
		
		m_imageAlignment = NSImageAlignment.NSImageAlignCenter;
		m_imageScaling = NSImageScaling.NSScaleNone;
		m_frameStyle = NSImageFrameStyle.NSImageFrameNone;
	}

	//******************************************************															 
	//*                Choosing the frame
	//******************************************************
	
	/**
	 * Returns the type of frame that borders the image.
	 */
	public function imageFrameStyle():NSImageFrameStyle {
		return m_frameStyle;		
	}
	
	/**
	 * Sets the type of frame that borders the image to <code>frameStyle</code>.
	 */
	public function setImageFrameStyle(frameStyle:NSImageFrameStyle):Void {
		m_frameStyle = frameStyle;
	}
	
	//******************************************************															 
	//*                  Common Methods
	//******************************************************
	
	/**
	 * Returns a string representation of the object.
	 */
	public function description():String {
		return "NSImageCell(image=" + image() + ")";
	}
	
	//******************************************************
	//*           Getting the image rectangle
	//******************************************************
	
	/**
	 * Returns the rectangle in which the image is drawn.
	 */
	public function imageRect():NSRect {
		return m_imageRect;
	}
	
	//******************************************************															 
	//*           Aligning and scaling the image
	//******************************************************
	
	/**
	 * Returns the position of the image within the frame.
	 */
	public function imageAlignment():NSImageAlignment {
		return m_imageAlignment;
	}
	
	/**
	 * Sets the position of the image within the frame to 
	 * <code>alignment</code>.
	 */
	public function setImageAlignment(alignment:NSImageAlignment):Void {
		m_imageAlignment = alignment;
	}
	
	/**
	 * Returns the way the image will alter to fit the frame.
	 */
	public function imageScaling():NSImageScaling {
		return m_imageScaling;
	}
	
	/**
	 * Sets the way the image will alter to fit the frame to
	 * <code>scaling</code>.
	 */
	public function setImageScaling(scaling:NSImageScaling):Void {
		m_imageScaling = scaling;
	}
	
	//******************************************************															 
	//*                   Drawing
	//******************************************************
	
	/**
	 * Draws the cell's border.
	 */
	public function drawWithFrameInView(frame:NSRect, inView:NSView):Void {
		//
		// Set the control view. This is required.
		//
		setControlView(inView);
		
		//
		// Draw the frame.
		//
		ASTheme.current().drawImageFrameWithRectInViewStyle(
			frame, inView, m_frameStyle);
		
		if (m_showsFirstResponder) {
			ASTheme.current().drawFirstResponderWithRectInView(frame, inView);
		}
		
		//
		// Draw the image
		//
		drawInteriorWithFrameInView(frame, inView);
	}
	
	/**
	 * Draws the image part of the cell.
	 */
	public function drawInteriorWithFrameInView(frame:NSRect, view:NSView):Void {
		var rect:NSRect = m_imageRect = scaledImageFrameForRect(frame);
		
		//
		// Draw the image
		//
		m_image.lockFocus(imageCanvas());
		m_image.drawInRect(rect);
		m_image.unlockFocus();
	}
	
	private function imageCanvas():MovieClip {
		return m_controlView.mcBounds();
	}
	
	//******************************************************															 
	//*               Overridden Methods
	//******************************************************
	
	/**
	 * Overridden to ignore formatters.
	 */
	public function setObjectValue(obj:Object):Void {
		setImage(NSImage(obj));
	}
	
	//******************************************************
	//*                   Internal
	//******************************************************
	
	/**
	 * Returns the frame of the scaled image as it appears in rect.
	 */
	public function scaledImageFrameForRect(rect:NSRect):NSRect {
		rect = rect.insetRect(4, 4);
		
		var size:NSSize = m_image.size().clone();
		var x:Number = rect.origin.x;
		var y:Number = rect.origin.y;
		
		//
		// Determine size based on scaling
		//
		switch (m_imageScaling) {
			case NSImageScaling.NSScaleNone:
				// do nothing
				break;
				
			case NSImageScaling.NSScaleProportionally:
				size = ASUtils.scaleSizeToSize(size, rect.size);
				break;
				
			case NSImageScaling.NSScaleToFit:
				size.width = rect.size.width;
				size.height = rect.size.height;
				break;
			
		}
		
		//
		// Determine position
		//
		var position:NSPoint;
		
		switch (m_imageAlignment) {				
			case NSImageAlignment.NSImageAlignTop:
				position = new NSPoint(rect.midX() - (size.width/2), y);
				break;
				
			case NSImageAlignment.NSImageAlignTopLeft:
				position = new NSPoint(x, y);
				break;
								
			case NSImageAlignment.NSImageAlignTopRight:
				position = new NSPoint(rect.maxX() - size.width, y);
				break;
				
			case NSImageAlignment.NSImageAlignLeft:
				position = new NSPoint(x, 
					rect.midY() - (size.height/2));
				break;
				
			case NSImageAlignment.NSImageAlignBottom:
				position = new NSPoint(rect.midX() - (size.width/2), 
					rect.maxY() - size.height);
				break;
				
			case NSImageAlignment.NSImageAlignBottomLeft:
				position = new NSPoint(x, rect.maxY() - size.height);
				break;	
		
			case NSImageAlignment.NSImageAlignBottomRight:
				position = new NSPoint(rect.maxX() - size.width, 
					rect.maxY() - size.height);
				break;
				
			case NSImageAlignment.NSImageAlignRight:
				position = new NSPoint(rect.maxX() - size.width, 
					rect.midY() - (size.height/2));
				break;
			
			case NSImageAlignment.NSImageAlignCenter:
			default:
				position = new NSPoint(rect.midX() - (size.width/2), 
					rect.midY() - (size.height/2));
				break;
		}
		
		return NSRect.withOriginSize(position, size);
	}
}