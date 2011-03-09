/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSColor;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.graphics.ASPen;

/**
 * <p>A view with a colored background and optionally a colored border. The 
 * default background color is white. There is no border by default.</p>
 *
 * <p>The alpha values of the colors are used when drawing.</p>
 * 
 * <p>To change the view's color, use {@link #setBackgroundColor()}.</p>
 * 
 * <p>To change the view's border color, use {@link #setBorderColor}.</p>
 * 
 * <p>This class can be subclassed to provide more interesting fills and 
 * borders. Please view the code under the "Drawing the view" heading,
 * or look at {@link org.actionstep.ASGradientView} for an example.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.ASColoredView extends NSView {

	private var m_backgroundColor:NSColor;
	private var m_borderColor:NSColor;

	//******************************************************
	//*                    Construction
	//******************************************************

	/**
	 * Creates a new instance of <code>ASColoredView</code> with a white
	 * background color.
	 */
	public function ASColoredView()
	{
		m_backgroundColor = ASColors.whiteColor();
	}

	//******************************************************
	//*               Setting the view's color
	//******************************************************

	/**
	 * Sets the background color of the view to <code>color</code>.
	 */
	public function setBackgroundColor(color:NSColor):Void
	{
		m_backgroundColor = color;
	}

	/**
	 * Returns this view's background color.
	 */
	public function backgroundColor():NSColor
	{
		return m_backgroundColor;
	}

	/**
	 * Sets the border color of the view to <code>color</code>. If
	 * <code>color</code> is <code>null</code>, then no border will be drawn.
	 */
	public function setBorderColor(color:NSColor):Void
	{
		m_borderColor = color;
	}

	/**
	 * Returns this view's border color. A value of <code>null</code> means
	 * that no border is drawn on this view.
	 */
	public function borderColor():NSColor
	{
		return m_borderColor;
	}

	//******************************************************
	//*                  Drawing the view
	//******************************************************

	/**
	 * <p>Returns <code>true</code> if this view draws a background.</p>
	 * 
	 * <p>To be overridden by subclasses.</p>
	 */
	private function hasBackgroundFill():Boolean {
		return m_backgroundColor != null;
	}
	
	/**
	 * <p>Begins a background fill on <code>mc</code>.</p>
	 * 
	 * <p>To be overridden by subclasses.</p>
	 */
	private function beginBackgroundFill(g:ASGraphics):Void {
		g.beginFill(m_backgroundColor);
	}
	
	/**
	 * <p>Returns <code>true</code> if this view draws a border.</p>
	 * 
	 * <p>To be overridden by subclasses.</p>
	 */
	private function hasBorder():Boolean {
		return m_borderColor != null;
	}
	
	/**
	 * <p>Sets the lineStyle on <code>mc</code>.</p>
	 * 
	 * <p>To be overridden by subclasses.</p>
	 */
	private function borderPen(g:ASGraphics):ASPen {
		return m_borderColor;
		
		var foo = "";
	}
	
	/**
	 * Returns the clip upon which the ASColoredView draws.
	 */
	public function mcDraw():MovieClip {
		return mcBounds();
	}
	
	/**
	 * Draws the view.
	 */
	public function drawRect(rect:NSRect):Void {
		var g:ASGraphics = graphics();
		g.clear();
		var pen:ASPen = null;
		
		if (hasBorder()) {
			pen = borderPen();
		}

		if (hasBackgroundFill()) {
			beginBackgroundFill(g);
		}

		g.drawRectWithRect(rect.scaledRect(-1, -1), pen, 1);
		g.endFill();		
	}
	
	//******************************************************
	//*             MovieClip (ActionStep-only)
	//******************************************************
	
	private function requiresMask():Boolean {
		return false;
	}
}