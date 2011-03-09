﻿/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSBoxType;
import org.actionstep.constants.NSTitlePosition;
import org.actionstep.NSCell;
import org.actionstep.NSFont;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTextFieldCell;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;

/**
 * An NSBox object is a simple NSView that can do two things: It can draw a 
 * border around itself, and it can title itself. You can use an NSBox to 
 * group, visually, some number of other NSViews.
 * 
 * For an example of this class in use, see 
 * <code>org.actionstep.test.ASTestBox</code>.
 * 
 * Uses 
 * <code>ASThemeProtocol#drawBoxBorderWithRectInViewExcludeRectBorderType</code>
 * to draw its border.
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSBox extends NSView
{		
	//
	// Member variables
	//
	private var m_borderrect:NSRect;
	private var m_bordertype:NSBorderType;
	private var m_boxtype:NSBoxType;
	private var m_contentview:NSView;
	private var m_contentmargin:NSSize;
	private var m_titlecell:NSTextFieldCell;
	private var m_titleposition:NSTitlePosition;
	
	/**
	 * Creates a new instance of NSBox.
	 */
	public function NSBox()
	{	
		//
		// Create the default title cell.
		//
		m_titlecell = (new NSTextFieldCell()).initTextCell("Title");
		m_titlecell.setEditable(false);
		m_titlecell.setDrawsBackground(false);
		m_titlecell.setFont(NSFont.systemFontOfSize(12));
		
		//
		// Set the default properties of this object.
		//
		m_titleposition = NSTitlePosition.NSAtTop;
		m_bordertype = NSBorderType.NSGrooveBorder;
		m_boxtype = NSBoxType.NSBoxPrimary;
		m_contentmargin = new NSSize(5, 5);
	}
	
	
	/**
	 * @see org.actionstep.NSView#initWithFrame
	 */
	public function initWithFrame(newFrame:NSRect):NSBox 
	{
		super.initWithFrame(newFrame); // NECESSARY
		
		//
		// Create the default content view
		//
		m_contentview = (new NSView()).init();
		addSubview(m_contentview);
		
		return this;
	}
  
	//******************************************************															 
	//*                    Properties
	//******************************************************
	
	/** Returns the rectangle in which the receiver’s border is drawn. */
	public function borderRect():NSRect
	{
		return m_borderrect;
	}	
	
	
	/** 
	 * Returns the receiver’s border type. 
	 *
	 * By default, an NSBox’s border type is NSGrooveBorder.
	 */
	public function borderType():NSBorderType
	{
		return m_bordertype;
	}	
	
	
	/** 
	 * Returns the receiver’s box type. 
	 *
	 * By default, an NSBox’s box type is NSBoxPrimary.
	 */
	public function boxType():NSBoxType
	{
		return m_boxtype;
	}
		
		
	/**
	 * Returns the receiver’s content view. The content view is created 
	 * automatically when the box is created and resized as the box is 
	 * resized (you should never send frame-altering messages directly 
	 * to a box’s content view). You can replace it with an NSView of 
	 * your own through the setContentView: method.
	 */
	public function contentView():NSView
	{
		return m_contentview;
	}
	
	
	/**
	 * Returns the distances between the border and the content view. By 
	 * default, both the width (the horizontal distance between the 
	 * innermost edge of the border and the content view) and the height 
	 * (the vertical distance between the innermost edge of the border and the 
	 * content view) of the returned NSSize are 5.0 in the box’s coordinate 
	 * system.
	 */
	public function contentViewMargins():NSSize
	{
		return m_contentmargin;
	}
	
	
	/**
	 * Sets the border type to aType, which must be a valid border type.
	 */
	public function setBorderType(borderType:NSBorderType):Void
	{
		m_bordertype = borderType;
		
		setNeedsDisplay(true);
	}
	
	
	/**
	 * Sets the box type to boxType, which must be a valid box type.
	 *
	 * If the size of the new border is different from that of the 
	 * old border, the content view is resized to absorb the 
	 * difference, and the box is marked for redisplay.
	 */
	public function setBoxType(boxType:NSBoxType):Void
	{
		m_boxtype = boxType;
		
		setNeedsDisplay(true);
	}
	
	
	/**
	 * Sets the receiver’s content view to aView, resizing the NSView to fit 
	 * within the box’s current content area. The box is marked for redisplay.
	 */
	public function setContentView(aView:NSView):Void
	{
		//
		// Add the view (while removing the previous view if necessary.
		//
		if (m_contentview != null)
		{
			replaceSubviewWith(m_contentview, aView);
		}
		else
		{
			addSubview(aView);
		}

		m_contentview = aView;
				
		//
		// Mark the box for redisplay. 
		//
		setNeedsDisplay(true);
	}
	
	
	/**
	 * Sets the horizontal and vertical distance between the border of the 
	 * receiver and its content view. The horizontal value is applied 
	 * (reckoned in the box’s coordinate system) fully and equally to the 
	 * left and right sides of the box. The vertical value is similarly applied
	 * to the top and bottom.
	 *
	 * Unlike changing a box’s other attributes, such as its title position or
	 * border type, changing the offsets doesn’t automatically resize the 
	 * content view. In general, you should send a sizeToFit message to the 
	 * box after changing the size of its offsets. This message causes the 
	 * content view to remain unchanged while the box is sized to fit around it.
	 *
	 */
	public function setContentViewMargins(offsetSize:NSSize):Void
	{
		m_contentmargin = offsetSize;
		
		// Do nothing else, sizeToFit() should be called.
	}
		
		
	/**
	 * Places the receiver so its content view lies on contentFrame, reckoned 
	 * in the coordinate system of the box’s superview. The box is marked 
	 * for redisplay.
	 */
	public function setFrameFromContentFrame(contentFrame:NSRect):Void
	{
		//FIXME This isn't finished
		
		var txtSize:NSSize = titleFont().getTextExtent(title()); // Get the text size.
		txtSize.width+=1;
		
		var cntSize:NSSize = contentFrame.size;
		setFrameSize(new NSSize(cntSize.width + m_contentmargin.width * 2,
			cntSize.height + m_contentmargin.height * 2 + txtSize.height));
		
		setNeedsDisplay(true);
	}
	
	
	/**
	 * Sets the title to aString, and marks the region of the receiver within 
	 * the title rectangle as needing display. By default, an NSBox’s title 
	 * is “Title.” If the size of the new title is different from that of the 
	 * old title, the content view is resized to absorb the difference.
	 */
	public function setTitle(aString:String):Void
	{
		m_titlecell.setTitle(aString);
	}
	
	
	/**
	 * Sets aFont as the NSFont object used to draw the receiver’s title and 
	 * marks the region of the receiver within the title rectangle as needing
	 * display. The title is drawn using the 12.0-point system font by default.
	 * If the size of the new font is different from that of the old font, 
	 * the content view is resized to absorb the difference.
	 */
	public function setTitleFont(aFont:NSFont):Void
	{
		m_titlecell.setFont(aFont);
	}
	
	
	/**
	 * Sets the title position to aPosition, which can be one of the values 
	 * described in “Constants”. The default position is NSAtTop.
	 *
	 * If the new title position changes the size of the box’s border area, 
	 * the content view is resized to absorb the difference, and the box is 
	 * marked as needing redisplay.
	 */
	public function setTitlePosition(aPosition:NSTitlePosition):Void
	{
		m_titleposition = aPosition;
		
		setNeedsDisplay(true);
	}
	
	
	/**
	 * Sets the title of the receiver with a character denoted as an access key.
	 *
	 * By default, an NSBox’s title is “Title.” The content view is not 
	 * automatically resized, and the box is not marked for redisplay.
	 */
	public function setTitleWithMnemonic():Void 
	{
		//! is this required?
		
		setNeedsDisplay(true);
	}
	
	
	/** Returns the receiver’s title. By default, a box’s title is “Title.” */
	public function title():String
	{
		return m_titlecell.title();
	}
	
	
	/** Returns the NSCell used to display the receiver’s title. */
	public function titleCell():NSCell
	{
		return m_titlecell;
	}
	
	
	/** 
	 * Returns the NSFont used to draw the receiver’s title. The title is drawn
	 * using the 12.0-point system font by default.
	 */
	public function titleFont():NSFont
	{
		return m_titlecell.font();
	}
	
	
	/** Returns a constant representing the title position. */
	public function titlePosition():NSTitlePosition
	{
		return m_titleposition;
	}
	
	
	/** Returns the rectangle in which the receiver’s title is drawn. */
	public function titleRect():NSRect
	{
		//! figure out how to measure cell size.
		return null; 
	}
	
	//******************************************************															 
	//*                Public Methods
	//******************************************************
	
	/**
	 * Resizes and moves the receiver’s content view so it just encloses its 
	 * subviews. The receiver is then moved and resized to wrap around the 
	 * content view. The receiver’s width is constrained so its title will 
	 * be fully displayed.
	 *
	 * You should invoke this method after:
	 * <ul>
	 * <li> Adding a subview (to the content view)
	 * <li> Altering the size or location of such a subview
	 * <li> Setting the margins around the content view
	 * </ul>
	 *
	 * The mechanism by which the content view is moved and resized depends 
	 * on whether the object responds to its own sizeToFit message: If it 
	 * does respond, then that message is sent, and the content view is 
	 * expected to be so modified. If the content view doesn’t respond, the 
	 * box moves and resizes the content view itself.
	 */
	public function sizeToFit():Void
	{
		if (ASUtils.respondsToSelector(m_contentview, "sizeToFit"))
		{
			m_contentview["sizeToFit"]();
		}
		else
		{
			//
			// Size the view ourselves
			//
			var subviews:Array = m_contentview.subviews();
			var len:Number = subviews.length;
			var minX:Number = 0;
			var minY:Number = 0;
			var maxX:Number = 0;
			var maxY:Number = 0;
			
			for (var i:Number = 0; i < len; i++)
			{
				var v:NSView = NSView(subviews[i]);
				var f:NSRect = v.frame();
				
				if (minX > f.origin.x)
				{
					minX = f.origin.x;
				}
				
				if (minY > f.origin.y)
				{
					minY = f.origin.y;
				}
				
				if (maxX < f.maxX())
				{
					maxX = f.maxX();
				}
				
				if (maxY < f.maxY())
				{
					maxY = f.maxY();
				}
			}
			
			//
			// Shift the controls
			//
			var xShift:Number = -1 * minX;
			var yShift:Number = -1 * minY;
			
			for (var i:Number = 0; i < len; i++)
			{
				var v:NSView = NSView(subviews[i]);
				var f:NSRect = v.frame();
				v.setFrameOrigin(f.origin.addPoint(new NSPoint(xShift, yShift)));
			}
			
			//
			// Resize the content view
			//
			var w:Number = maxX - minX;
			var h:Number = maxY - minY;
			
			m_contentview.setFrameSize(new NSSize(w, h));
		}
		
		setFrameFromContentFrame(m_contentview.frame());
	}
	
	
	/**
	 * Draws the box.
	 *
	 * @see org.actionstep.NSView#drawRect
	 */
	public function drawRect(rect:NSRect):Void
	{
		mcBounds().clear(); // Clear the drawing context.
		
		var txtSize:NSSize = titleFont().getTextExtent(title()); // Get the text size.
		txtSize.width+=1;
		var txtLoc:NSPoint = new NSPoint((m_bounds.size.width - txtSize.width)/2, 0);
		var bdrRect:NSRect = m_bounds.clone();
		var cntRect:NSRect = m_bounds.clone();
		
		switch (m_titleposition)
		{
			case NSTitlePosition.NSAboveTop:
				bdrRect.origin.y += txtSize.height;
				bdrRect.size.height -= txtSize.height;
				cntRect = bdrRect.clone(); // content is the same as border
				break;
				
			case NSTitlePosition.NSAtTop:
				bdrRect.origin.y += txtSize.height / 2;
				bdrRect.size.height -= txtSize.height / 2;
				cntRect.origin.y += txtSize.height;
				cntRect.size.height -= txtSize.height;
				break;
				
			case NSTitlePosition.NSBelowTop:
				// bdrRect remains the same, content shrinks
				cntRect.origin.y += txtSize.height;
				cntRect.size.height -= txtSize.height;
				break;
				
			case NSTitlePosition.NSAboveBottom:
				// bdrRect remains the same, content shrinks
				txtLoc.y = bdrRect.size.height - txtSize.height;
				cntRect.size.height -= txtSize.height;
				break;
				
			case NSTitlePosition.NSAtBottom:
				txtLoc.y = bdrRect.size.height - txtSize.height;
				bdrRect.size.height -= txtSize.height / 2;
				cntRect.size.height -= txtSize.height;
				break;
				
			case NSTitlePosition.NSBelowBottom:
				txtLoc.y = bdrRect.size.height - txtSize.height;
				bdrRect.size.height -= txtSize.height;
				cntRect = bdrRect.clone();
				break;
				
			case NSTitlePosition.NSNoTitle:
				// do nothing (border is the same as bounds)
				break;
				
		}
		
		//
		// Size the content view based on box size and margins
		//
		cntRect.origin.x += m_contentmargin.width;
		cntRect.origin.y += m_contentmargin.height;
		cntRect.size.width -= (2 * m_contentmargin.width);
		cntRect.size.height -= (2 * m_contentmargin.height);
		
		m_contentview.setFrame(cntRect);
		
		//
		// Draw the border
		//
		var txtBounds:NSRect = NSRect.withOriginSize(txtLoc, txtSize);
		
		if (m_titleposition == NSTitlePosition.NSAtBottom ||
			m_titleposition == NSTitlePosition.NSAtTop)
		{
			drawBackgroundWithRectExcludeRectBorderType(bdrRect, txtBounds, borderType());
		}
		else
		{
			drawBackgroundWithRectExcludeRectBorderType(bdrRect, null, borderType());
		}
		
		//
		// Draw the title
		//
		if (m_titleposition != NSTitlePosition.NSNoTitle)
		{
			m_titlecell.drawWithFrameInView(txtBounds, this);
		}
	}
	
	private function drawBackgroundWithRectExcludeRectBorderType(
			rect:NSRect, exclude:NSRect, borderType:NSBorderType):Void {
		ASTheme.current().drawBoxBorderWithRectInViewExcludeRectBorderType(
			rect, this, exclude, borderType);	
	}
}
