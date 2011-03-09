/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSButtonCell;
import org.actionstep.NSColor;
import org.actionstep.NSColorList;
import org.actionstep.NSColorPanel;
import org.actionstep.NSColorPicking;
import org.actionstep.NSControl;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSImage;
import org.actionstep.NSObject;
import org.actionstep.NSSize;
import org.actionstep.NSView;

/**
 * <code>NSColorPicker</code> is an abstract superclass that implements the 
 * {@link NSColorPickingDefault} protocol. The 
 * <code>NSColorPickingDefault</code> and 
 * {@link org.actionstep.NSColorPickingCustom} protocols define a way to add 
 * color pickers (custom user interfaces for color selection) to the 
 * {@link NSColorPanel}.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSColorPicker extends NSObject implements NSColorPicking {
		
	//******************************************************
	//*                    Members
	//******************************************************
	
	private static var g_pickers:NSArray;
	
	private var m_owningColorPanel:NSColorPanel;
	private var m_mask:Number; 
	private var m_modeMask:Number;
	private var m_mode:Number;
	private var m_color:NSColor;
	
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
		m_owningColorPanel = owningColorPanel;
		m_mask = mask;
		m_mode = 0;
		return this;
	}

	//******************************************************
	//*               Getting the color panel
	//******************************************************
	
	/**
	 * Returns the <code>NSColorPanel</code> that owns the receiver.
	 */
	public function colorPanel():NSColorPanel {
		return m_owningColorPanel;
	}
	
	//******************************************************
	//*                  Button images
	//******************************************************
	
	/**
	 * <p>Sets <code>newButtonImage</code> as <code>buttonCell</code>’s image by 
	 * invoking {@link NSButtonCell#setImage}.</p>
	 * 
	 * <p>Called by the color panel to insert a new image into the specified cell. 
	 * Override this method to customize <code>newButtonImage</code> before 
	 * insertion in <code>buttonCell</code>.</p>
	 * 
	 * @see #provideNewButtonImage
	 */
	public function insertNewButtonImageIn(newButtonImage:NSImage, buttonCell:NSButtonCell):Void {
		buttonCell.setImage(newButtonImage);
	}

	/**
	 * <p>Returns the button image for the receiver.</p>
	 * 
	 * <p>The color panel will place this image in the mode button the user uses
	 * to select this picker.</p>
	 * 
	 * @see #insertNewButtonImageIn 
	 */
	public function provideNewButtonImage():NSImage {
		return null;
	}
	
	/**
	 * <p>Returns the tool tip text for this picker's button.</p>
	 */
	public function buttonToolTip():String {
		
		return "";
	}
	
	//******************************************************
	//*              Getting the identifier
	//******************************************************
	
	/**
	 * <p>Returns a unique name for this picker.</p>
	 * 
	 * <p>Must be overridden by subclasses.</p>
	 */
	public function identifier():String {
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			NSException.ASAbstractMethod,
			"identifier() is a required method - picker: " + this);
		trace(e);
		throw e;
		
		return "";	
	}
	
	//******************************************************
	//*                  Setting the mode
	//******************************************************
	
	/**
	 * <p>Sets the mode.</p>
	 * 
	 * Calls <code>#modeDidChange</code> when mode changes.
	 */
	public function setMode(mode:Number):Void {
		if (m_mode == mode) {
			return;
		}
		
		var old:Number = m_mode;
		m_mode = mode;
		
		modeDidChange(old);
	}
	
	/**
	 * Overwrite to handle mode changes.
	 */
	private function modeDidChange(oldMode:Number):Void {
		
	}

	//******************************************************
	//*                 Using color lists
	//******************************************************

	/**
	 * Does nothing. Override to attach a color list to a color picker.
	 * 
	 * @see #detachColorList
	 */
	public function attachColorList(colorList:NSColorList):Void {
	}

	/**
	 * Does nothing. Override to detach a color list from a color picker.
	 * 
	 * @see #attachColorList
	 */
	public function detachColorList(colorList:NSColorList):Void {
	}

	//******************************************************
	//*             Responding to view changes
	//******************************************************

	/**
	 * Does nothing. Override to respond to a size change.
	 */
	public function viewSizeChanged(sender:Object):Void {
	}

	//******************************************************
	//*              Showing opacity controls
	//******************************************************
	
	public function alphaControlAddedOrRemoved(sender:Object):Void {
		
	}
	
	//******************************************************
	//*            Setting the current color
	//******************************************************
	
	/**
	 * <p>Adjusts the receiver to make <code>color</code> the currently selected 
	 * color.</p>
	 * 
	 * <p>This method is invoked on the current color picker each time 
	 * {@link org.actionstep.NSColorPanel}’s {@link #setColor} method is 
	 * invoked. If color is actually different from the color picker’s color (as
	 * it would be if, for example, the user dragged a color into 
	 * <code>NSColorPanel</code>’s color well), this method could be used to 
	 * update the color picker’s color to reflect the change.</p>
	 */
	public function setColor(color:NSColor):Void {
		if (m_color.isEqual(color)) {
			return;
		}
		
		m_color = color;
		colorChanged(this);
	}
	
	/**
	 * Invoked when the color changes.
	 */
	private function colorChanged(sender:Object):Void {
		if (sender != this) {
			setColor(sender["color"]());
		}
	}
	
	//******************************************************
	//*                 Getting the mode
	//******************************************************
	
	/**
	 * <p>Returns the receiver’s current mode (or submode, if applicable).</p>
	 * 
	 * <p>The returned value should be unique to your color picker. </p>
	 * 
	 * @see #supportsMode()
	 */
	public function mode():Number {
		return m_mode;
	}
	
	/**
	 * <p>Returns whether or not the receiver supports the specified picking 
	 * <code>mode</code>.</p>
	 * 
	 * <p>This method is invoked when the {@link org.actionstep.NSColorPanel} is 
	 * first initialized. It is used to attempt to restore the user’s previously
	 * selected mode. It is also invoked by <code>NSColorPanel</code>’s 
	 * {@link org.actionstep.NSColorPanel#setMode} method to find the color 
	 * picker that supports a particular mode.</p>
	 */
	public function supportsMode(mode:Number):Boolean {
		if (m_modeMask == null) {
			return m_mode & mode != 0;
		}
		
		return m_modeMask & mode != 0;
	}
	
	//******************************************************
	//*                 Getting the view
	//******************************************************
	
	/**
	 * <p>
	 * Returns the color picker's minimum content size.
	 * </p>
	 * <p>
	 * The default implementation returns <code>NSSize.ZeroSize</code>
	 * </p>
	 */
	public function minContentSize():NSSize {
		return NSSize.ZeroSize;
	}
	
	/**
	 * <p>Returns the view containing the receiver’s user interface.</p>
	 * 
	 * <p>This message is sent to the color picker whenever the color panel 
	 * attempts to display it. This may be when the panel is first presented, 
	 * when the user switches pickers, or when the picker is switched through 
	 * an API. The argument <code>initialRequest</code> is <code>true</code> 
	 * only when this method is first invoked for your color picker. If 
	 * <code>initialRequest</code> is <code>true</code>, the method should 
	 * perform any initialization required (such as lazily loading a nib file, 
	 * initializing the view, or performing any other custom initialization 
	 * required for your picker). The <code>NSView</code> returned by this 
	 * method should be set to automatically resize both its width and height.</p>
	 * <p>
	 * Do not override this method. Override <code>#pickerView</code> instead.
	 * </p>
	 */
	public function provideNewView(initialRequest:Boolean):NSView {
		var view:NSControl = pickerView();
		
		if (initialRequest) {
			view.setAutoresizingMask(NSView.WidthSizable, NSView.HeightSizable);
			view.setTarget(this);
			view.setAction("colorChanged");
			view.sendActionOn(NSEvent.NSLeftMouseUpMask);
		}
		
		setColor(m_owningColorPanel.color());
		
		return view;
	}
	
	/**
	 * This view should be overridden by subclasses to provide the picker's
	 * control.
	 */
	private function pickerView():NSControl {
		return null;
	}
	
	//******************************************************
	//*                 Adding pickers
	//******************************************************
	
	/**
	 * <p>Adds a picker instance to the global picker definitions.</p>
	 * 
	 * <p>For internal use only</p>
	 */
	public static function _addPicker(picker:NSColorPicking):Void {
		if (g_pickers == null) {
			g_pickers = NSArray.array();
		}
		
		g_pickers.addObject(picker);
	}
	
	/**
	 * <p>Returns all the pickers.</p>
	 * 
	 * <p>For internal use only</p>
	 */
	public static function _allPickers():NSArray {
		return g_pickers;
	}
}