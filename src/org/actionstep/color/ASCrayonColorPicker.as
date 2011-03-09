/* See LICENSE for copyright and terms of use */

import org.actionstep.color.view.ASColorPickerView;
import org.actionstep.color.view.ASCrayonColorPickerView;
import org.actionstep.NSColor;
import org.actionstep.NSColorList;
import org.actionstep.NSColorPanel;
import org.actionstep.NSColorPicker;
import org.actionstep.NSColorPicking;
import org.actionstep.NSControl;
import org.actionstep.NSImage;
import org.actionstep.NSSize;

/**
 * Implementation of the wheel color picker.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.color.ASCrayonColorPicker extends NSColorPicker {
	
	//******************************************************
	//*                    Constants
	//******************************************************
	
	private static var MIN_CONTENT_WIDTH:Number = 189;
	private static var MIN_CONTENT_HEIGHT:Number = 208;
	
	//******************************************************
	//*                  Class members
	//******************************************************
	
	private static var g_crayonColors:NSColorList;
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	/** View used internally */
	private var m_view:ASCrayonColorPickerView;
	
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
			
		m_mode = NSColorPanel.NSCrayonModeColorPanel;
		
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
	//*              Getting the identifier
	//******************************************************
	
	/**
	 * <p>Returns a unique name for this picker.</p>
	 */
	public function identifier():String {
		return "ASCrayonColorPicker";	
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
			m_view = (new ASCrayonColorPickerView()).initWithPicker(this);
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
		return (new NSImage()).initWithContentsOfURL("test/picker_crayons.png");
	}
	
	/**
	 * <p>Returns the tool tip text for this picker's button.</p>
	 */
	public function buttonToolTip():String {
		return "Crayon Box";
	}
	
	//******************************************************
	//*                Class construction
	//******************************************************
	
	/**
	 * Adds a slider color picker to the global definitions.
	 */
	private static function initialize():Void {
		var picker:NSColorPicking = new ASCrayonColorPicker();
		NSColorPicker._addPicker(picker);
		
		//
		// Create crayon list
		//
		g_crayonColors = (new NSColorList()).initWithName("Crayons");
		
		// Row 1
		addColor(0x930000, "Cayenne");
		addColor(0x7F8100, "Asparagus");
		addColor(0x008400, "Clover");
		addColor(0x008281, "Teal");
		addColor(0x060083, "Midnight");
		addColor(0x930082, "Plum");
		addColor(0x7F7F7F, "Tin");
		addColor(0x808080, "Nickel");
		
		// Row 2
		addColor(0x8E3D00, "Mocha");
		addColor(0x1E8300, "Fern");
		addColor(0x00843E, "Moss");
		addColor(0x003F83, "Ocean");
		addColor(0x4A0083, "Eggplant");
		addColor(0x93003F, "Maroon");
		addColor(0x666666, "Steel");
		addColor(0x999999, "Aluminum");
		
		// Row 3
		addColor(0xFF0000, "Maraschino");
		addColor(0xFEFF00, "Lemon");
		addColor(0x00FF00, "Spring");
		addColor(0x0000FF, "Turquoise");
		addColor(0x0C00FF, "Blueberry");
		addColor(0xFF00FF, "Magenta");
		addColor(0x4C4C4C, "Iron");
		addColor(0xB3B3B3, "Magnesium");
		
		// Row 4
		addColor(0xFF7A00, "Tangerine");
		addColor(0x3DFF00, "Lime");
		addColor(0x00FF7C, "Sea Foam");
		addColor(0x007EFF, "Aqua");
		addColor(0x9400FF, "Grape");
		addColor(0xFF007E, "Strawberry");
		addColor(0x333333, "Tungsten");
		addColor(0xCCCCCC, "Silver");
		
		// Row 5
		addColor(0xFF5B60, "Salmon");
		addColor(0xFEFF58, "Banana");
		addColor(0x00FF5E, "Flora");
		addColor(0x00FFFF, "Ice");
		addColor(0x665FFF, "Orchid");
		addColor(0xFF54FF, "Bubblegum");
		addColor(0x191919, "Lead");
		addColor(0xE6E6E6, "Mercury");
		
		// Row 6
		addColor(0xFFCB5C, "Cantaloupe");
		addColor(0xBAFF5B, "Honeydew");
		addColor(0x00FFCC, "Spindrift");
		addColor(0x32CDFF, "Sky");
		addColor(0xE359FF, "Lavender");
		addColor(0xFF62D0, "Carnation");
		addColor(0x000000, "Licorice");
		addColor(0xFFFFFF, "Snow");
		
		g_crayonColors.addToAvailableColorLists();
	}
	
	private static function addColor(value:Number, name:String):Void {
		g_crayonColors.setColorForKey(new NSColor(value), name);
	}
}