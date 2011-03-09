/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColoredView;
import org.actionstep.ASDraw;
import org.actionstep.graphics.ASGradient;
import org.actionstep.NSArray;
import org.actionstep.NSColor;
import org.actionstep.NSException;
import org.actionstep.NSRect;

import flash.geom.Matrix;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.graphics.ASPen;

/**
 * <p>A view with a linear gradient background.</p>
 * 
 * @see #setColorsWithRatios()
 * @author Scott Hyndman
 */
class org.actionstep.ASGradientView extends ASColoredView {

	private var m_gradient:ASGradient;
	
	//******************************************************
	//*                    Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASGradientView</code> class.
	 */
	public function ASGradientView() {
	}
	
	//******************************************************
	//*                Setting the gradient
	//******************************************************
	
	public function setGradient(gradient:ASGradient):Void {
		m_gradient = gradient;
	}
	
	public function gradient():ASGradient {
		return m_gradient;
	}
	
	//******************************************************
	//*               Setting the view's colors
	//******************************************************
	
	/**
	 * Access change (from public to private)
	 */
	private function setBackgroundColor(color:NSColor):Void
	{
		m_backgroundColor = color;
	}

	/**
	 * Access change (from public to private)
	 */
	private function backgroundColor():NSColor
	{
		return m_backgroundColor;
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
		return m_backgroundColor != null && m_gradient != null;
	}
	
	/**
	 * <p>Begins a background fill on <code>mc</code>.</p>
	 * 
	 * <p>To be overridden by subclasses.</p>
	 */
	private function beginBackgroundFill(g:ASGraphics):Void {
		if (m_gradient == null) {
			super.beginBackgroundFill(g);
		} else {
			g.beginFill(m_gradient);
		}
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
	private function borderPen():ASPen {
		return m_borderColor;
	}
		
}