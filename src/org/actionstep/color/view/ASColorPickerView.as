/* See LICENSE for copyright and terms of use */

import org.actionstep.NSColorPicker;
import org.actionstep.NSControl;
import org.actionstep.NSEvent;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSColor;

/**
 * Base class for color picker views.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.color.view.ASColorPickerView extends NSControl {
	
	/**
	 * This view's color picker.
	 */
	private var m_picker:NSColorPicker;
	
	/**
	 * This view's color.
	 */
	private var m_color:NSColor;
	
	/**
	 * Current color mode of the view.
	 */
	private var m_mode:Number;
	
	/**
	 * true if alpha is being shown.
	 */
	private var m_showsAlpha:Boolean;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASColorPickerView</code> class.
	 */
	public function ASColorPickerView() {
	}
	
	/**
	 * Initializes and returns the <code>ASColorPickerView</code> instance with a frame
	 * area of <code>aRect</code>.
	 */
	public function initWithPicker(picker:NSColorPicker):ASColorPickerView {
		super.initWithFrame(NSRect.withOriginSize(NSPoint.ZeroPoint, 
			picker.minContentSize()));
		
		m_picker = picker;
		
		return this;
	}
	
	//******************************************************
	//*            Setting and getting the mode
	//******************************************************
	
	/**
	 * Returns the mode this view is displaying.
	 */
	public function mode():Number {
		return m_mode;
	}
	
	/**
	 * Sets the mode and alpha of the view. This method retiles the view.
	 */
	public function setModeShowsAlpha(mode:Number, flag:Boolean):Void {
		if (m_mode == mode && m_showsAlpha == flag) {
			return;
		}
		
		m_mode = mode;
		m_showsAlpha = flag;
		
		tile();
	}
	
	//******************************************************
	//*            Setting the current color
	//******************************************************
	
	/**
	 * Returns this view's color.
	 */
	public function color():NSColor {
		return m_color;
	}
	
	/**
	 * <p>Adjusts the receiver to make <code>color</code> the currently selected 
	 * color.</p>
	 * <p>
	 * The view should be marked as needing a redisplay after this method
	 * is invoked.
	 * </p>
	 */
	public function setColor(color:NSColor):Void {
		if (m_color.isEqual(color)) {
			return;
		}
		
		m_color = color.copyWithZone();
	}
	
	//******************************************************
	//*                     Events
	//******************************************************
	
	/**
	 * Calls the color picker's <code>colorChanged()</code> method.
	 */
	public function mouseUp(event:NSEvent):Void {
		m_picker["colorChanged"](this);
	}
	
	//******************************************************
	//*                 Tiling the view
	//******************************************************
	
	/**
	 * Tiles the contents of this view. To be overridden by subclasses.
	 */
	public function tile():Void {
		
	}
}