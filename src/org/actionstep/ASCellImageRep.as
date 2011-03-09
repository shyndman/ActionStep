/* See LICENSE for copyright and terms of use */

import org.actionstep.NSCell;
import org.actionstep.NSImageRep;
import org.actionstep.NSRect;
import org.actionstep.NSSize;

/**
 * This image rep uses cells to draw on the screen.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.ASCellImageRep extends NSImageRep 
{
	private var m_cell:NSCell;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of ASCellImageRep with the cell it will
	 * use to draw itself at the specified size <code>size</code>.
	 */
	public function ASCellImageRep(cell:NSCell, size:NSSize)
	{
		m_cell = cell;
		m_size = size;
	}
	
	//******************************************************															 
	//*                     Drawing
	//******************************************************
	
	/**
	 * Draws the image at location (0,0). This method returns <code>true</code>
	 * if the image was successfully drawn, or <code>false</code> if it
	 * wasn't. 
	 */
	public function draw():Boolean {
		if (m_drawClip == null) {
			return false;
		}
		
		//
		// Override the draw clip's clear method if necessary.
		//
		super.decorateDrawClipIfNeeded();
		
		//
		// Create the clip to draw on.
		//
		var clip:MovieClip;
		var level:Number = super.getClipDepth();
		
		clip = m_lastCanvas = m_drawClip.createEmptyMovieClip("__cellImageRep" 
			+ level, level);
		clip.view = m_drawClip.view;
		super.addImageRepToDrawClip(clip);
		
		//
		// Create a fake view to satisfy the cell's drawing methods.
		//
		var fakeView:Object = {};
		fakeView.mcBounds = function()
		{
			return clip;
		};
		fakeView.m_mcDepth = 0;
		fakeView.createBoundsTextField = function():TextField {
			return clip.view.createBoundsTextField();
		};
		
		//
		// Tell the cell to draw.
		//
		Object(m_cell).drawWithFrameInView(NSRect.withOriginSize(m_drawPoint,
			m_size), fakeView);
			
		//! FIXME This should be handled by the cell, not the rep.
		Object(m_cell).drawInteriorWithFrameInView(NSRect.withOriginSize(m_drawPoint,
			m_size), fakeView);
	}
}