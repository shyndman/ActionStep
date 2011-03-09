/* See LICENSE for copyright and terms of use */

import org.actionstep.color.view.ASSliderColorPickerView;
import org.actionstep.NSColorPanel;
import org.actionstep.NSColorPicker;
import org.actionstep.NSColorPicking;
import org.actionstep.NSControl;
import org.actionstep.NSSize;
import org.actionstep.NSImage;
import org.actionstep.color.view.ASColorPickerView;

/**
 * Implementation of the slider color picker.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.color.ASSliderColorPicker extends NSColorPicker {
	
	//******************************************************
	//*                    Constants
	//******************************************************
	
	private static var MIN_CONTENT_WIDTH:Number = 150;
	private static var MIN_CONTENT_HEIGHT:Number = 180;
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	/** View used internally */
	private var m_view:ASSliderColorPickerView;
	
	//******************************************************
	//*            Initializing an NSColorPicker
	//******************************************************
	
	/**
	 * Sets the receiver’s color panel to <code>owningColorPanel</code>, caching
	 * the <code>owningColorPanel</code> value so it can later be returned by 
	 * the {@link #colorPanel} method.
	 * 
	 * @see #colorPanel
	 */
	public function initWithPickerMaskColorPanel(mask:Number, 
			owningColorPanel:NSColorPanel):NSColorPicking {
		super.initWithPickerMaskColorPanel(mask, owningColorPanel);
			
		m_mode = NSColorPanel.NSColorPanelGrayModeMask;
		m_modeMask = NSColorPanel.NSColorPanelGrayModeMask 
			| NSColorPanel.NSColorPanelRGBModeMask
			| NSColorPanel.NSColorPanelCMYKModeMask
			| NSColorPanel.NSColorPanelHSBModeMask;
			
		return this;
	}
	
	//******************************************************
	//*                  Current Color
	//******************************************************
	
	/**
	 * Invoked when the color changes.
	 */
	private function colorChanged(sender:Object):Void {
		if (sender == this) {
			m_view.setColor(m_color);
		} 
		else if (sender == m_view) {
			m_owningColorPanel.setColor(ASColorPickerView(sender).color());
		} else {
			super.colorChanged(sender);
		}
	}
	
	//******************************************************
	//*                 Mode changes
	//******************************************************
	
	/**
	 * Overwritten to inform the view.
	 */
	private function modeDidChange(oldMode:Number):Void {
		m_view.modeDidChange(oldMode);
	}
	
	//******************************************************
	//*              Getting the identifier
	//******************************************************
	
	/**
	 * <p>Returns a unique name for this picker.</p>
	 */
	public function identifier():String {
		return "ASSliderColorPicker";	
	}
	
	//******************************************************
	//*               Getting the view
	//******************************************************
	
	/**
	 * Returns the slider picker's minimum content size.
	 */
	public function minContentSize():NSSize {
		return new NSSize(MIN_CONTENT_WIDTH, MIN_CONTENT_HEIGHT);
	}
		
	/**
	 * Returns the ASSliderColorPickerView instance.
	 */
	public function pickerView():NSControl {
		if (m_view == null) {
			m_view = (new ASSliderColorPickerView()).initWithPicker(this);
		}
		
		return m_view;
	}
	
	//******************************************************
	//*                  Button stuff
	//******************************************************
	
	/**
	 * <p>Returns the button image for the receiver.</p>
	 * 
	 * <p>The color panel will place this image in the mode button the user uses
	 * to select this picker.</p>
	 * 
	 * @see #insertNewButtonImageIn 
	 */
	public function provideNewButtonImage():NSImage {
		return (new NSImage()).initWithContentsOfURL("test/picker_sliders.png");
	}
	
	/**
	 * <p>Returns the tool tip text for this picker's button.</p>
	 */
	public function buttonToolTip():String {
		return "Sliders";
	}
	
	//******************************************************
	//*                Class construction
	//******************************************************
	
	/**
	 * Adds a slider color picker to the global definitions.
	 */
	private static function initialize():Void {
		var picker:NSColorPicking = new ASSliderColorPicker();
		NSColorPicker._addPicker(picker);
	}
}