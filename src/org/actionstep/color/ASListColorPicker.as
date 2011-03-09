/* See LICENSE for copyright and terms of use */

import org.actionstep.color.view.ASListColorPickerView;
import org.actionstep.NSColorPanel;
import org.actionstep.NSColorPicker;
import org.actionstep.NSColorPicking;
import org.actionstep.NSControl;
import org.actionstep.NSImage;
import org.actionstep.NSSize;

/**
 * Implementation of the list color picker.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.color.ASListColorPicker extends NSColorPicker {
	
	//******************************************************
	//*                    Constants
	//******************************************************
	
	private static var MIN_CONTENT_WIDTH:Number = 100;
	private static var MIN_CONTENT_HEIGHT:Number = 180;
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	/** View used internally */
	private var m_view:ASListColorPickerView;
	
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
			
		m_mode = NSColorPanel.NSColorListModeColorPanel;
		
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
		} else {
			super.colorChanged(sender);
		}
	}
	
	//******************************************************
	//*              Getting the identifier
	//******************************************************
	
	/**
	 * <p>Returns a unique name for this picker.</p>
	 */
	public function identifier():String {
		return "ASListColorPicker";	
	}
	
	//******************************************************
	//*                 Getting the view
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
			m_view = (new ASListColorPickerView()).initWithPicker(this);
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
		return (new NSImage()).initWithContentsOfURL("test/picker_lists.png");
	}
	
	/**
	 * <p>Returns the tool tip text for this picker's button.</p>
	 */
	public function buttonToolTip():String {
		return "Color Lists";
	}
	
	//******************************************************
	//*                Class construction
	//******************************************************
	
	/**
	 * Adds a slider color picker to the global definitions.
	 */
	private static function initialize():Void {
		var picker:NSColorPicking = new ASListColorPicker();
		NSColorPicker._addPicker(picker);
	}
}