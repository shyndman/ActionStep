/* See LICENSE for copyright and terms of use */

import org.actionstep.NSButtonCell;
import org.actionstep.NSColor;
import org.actionstep.NSColorList;
import org.actionstep.NSColorPanel;
import org.actionstep.NSImage;
import org.actionstep.NSView;
import org.actionstep.NSSize;

/**
 * <code>NSColorPickingCustom</code> provides a way to add color pickers—custom 
 * user interfaces for color selection—to an application’s 
 * {@link org.actionstep.NSColorPanel}.
 * 
 * @author Scott Hyndman
 */
interface org.actionstep.NSColorPicking {
	
	//******************************************************
	//*             Initializing a color picker
	//******************************************************
	
	/**
	 * <p>Notifies the color picker of the color panel’s mask and initializes the 
	 * color picker.</p>
	 * 
	 * <p>This method is sent by the {@link NSColorPanel} to all implementors of 
	 * the color-picking protocols when the application’s color panel is first 
	 * initialized.</p>
	 * 
	 * TODO Figure out how we'll know what panels implement this.
	 */
	public function initWithPickerMaskColorPanel(mask:Number, 
		owningColorPanel:NSColorPanel):NSColorPicking;
	
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
	public function setColor(color:NSColor):Void;
	
	//******************************************************
	//*              Getting the identifier
	//******************************************************
	
	/**
	 * <p>Returns a unique name for this picker.</p>
	 */
	public function identifier():String;
	
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
	public function mode():Number;
	
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
	public function supportsMode(mode:Number):Boolean;
	
	//******************************************************
	//*                 Getting the view
	//******************************************************
	
	/**
	 * <p>
	 * Returns the color picker's minimum content size.
	 * </p>
	 */
	public function minContentSize():NSSize;
	
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
	 */
	public function provideNewView(initialRequest:Boolean):NSView;
		
	//******************************************************
	//*                 Setting the mode
	//******************************************************
	
	/**
	 * <p>Sets the color picker’s mode.</p>
	 * 
	 * <p>This method is invoked by {@link NSColorPanel#setMode} method to ensure 
	 * the color picker reflects the current mode. For example, invoke this 
	 * method during color picker initialization to ensure that all color 
	 * pickers are restored to the mode the user left them in the last time an 
	 * <code>NSColorPanel</code> was used.</p>
	 */
	public function setMode(mode:Number):Void;
	
	//******************************************************
	//*                 Using color lists
	//******************************************************
	
	/**
	 * <p>Tells the color picker to attach the given <code>colorList</code>, if it 
	 * isn’t already displaying the list.</p>
	 * 
	 * <p>You never invoke this method; it’s invoked automatically by the 
	 * {@link NSColorPanel} when its {@link NSColorPanel#attachColorList} method
	 * is invoked. Because <code>NSColorPanel</code>’s list mode manages 
	 * <code>NSColorLists</code>, this method need only be implemented by a 
	 * custom color picker that manages <code>NSColorLists</code> itself.</p>
	 */
	public function attachColorList(colorList:NSColorList):Void;
	
	/**
	 * <p>Tells the color picker to detach the given <code>colorList</code>, unless
	 * the receiver isn’t displaying the list.</p>
	 * 
	 * <p>You never invoke this method; it’s invoked automatically by the 
	 * {@link NSColorPanel} when its {@link NSColorPanel#detachColorList} method
	 * is invoked. Because <code>NSColorPanel</code>’s list mode manages 
	 * <code>NSColorLists</code>, this method need only be implemented by a 
	 * custom color picker that manages <code>NSColorLists</code> itself.</p>
	 */
	public function detachColorList(colorList:NSColorList):Void;
	
	//******************************************************
	//*                   Button images
	//******************************************************
	
	/**
	 * <p>Sets <code>newButtonImage</code> as the image of <code>buttonCell</code>.</p>
	 * 
	 * <p><code>buttonCell</code> is the <code>NSButtonCell</code> object that lets
	 * the user choose the picker from the color panel—the color picker’s 
	 * representation in the {@link NSColorPanel}’s picker 
	 * {@link org.actionstep.NSMatrix}. This method should perform 
	 * application-specific manipulation of the image before it’s inserted and 
	 * displayed by the button cell.</p>
	 * 
	 * @see #provideNewButtonImage()
	 */
	public function insertNewButtonImageIn(newButtonImage:NSImage, 
		buttonCell:NSButtonCell):Void;
		
	/**
	 * <p>Returns the image for the mode button the user uses to select this 
	 * picker in the color panel, that is, the color picker’s representation in 
	 * the {@link NSColorPanel}’s picker {@link org.actionstep.NSMatrix}.</p>
	 * 
	 * <p>(This image is the same one the color panel uses as an argument when 
	 * sending the {@link #insertNewButtonImageIn} message.)</p>
	 */
	public function provideNewButtonImage():NSImage;
	
	/**
	 * <p>Returns the tool tip text for this picker's button.</p>
	 */
	public function buttonToolTip():String;
	
	//******************************************************
	//*             Showing opacity controls
	//******************************************************
	
	/**
	 * <p>Sent by the <code>sender</code> color panel when the opacity controls 
	 * have been hidden or displayed. Invoked automatically when the 
	 * {@link NSColorPanel}’s opacity slider is added or removed; you never 
	 * invoke this method directly.</p>
	 * 
	 * <p>If the color picker has its own opacity controls, it should hide or 
	 * display them, depending on whether the <code>sender</code>’s 
	 * {@link NSColorPanel#showsAlpha} method returns <code>false</code> or 
	 * <code>true</code>.</p>
	 */
	public function alphaControlAddedOrRemoved(sender:Object):Void;
	
	//******************************************************
	//*            Responding to a resized view
	//******************************************************
	
	/**
	 * <p>Tells the color picker when the {@link NSColorPanel}’s view size changes 
	 * in a way that might affect the color picker.</p>
	 * 
	 * <p><code>sender</code> is the <code>NSColorPanel</code> that contains the 
	 * color picker. Use this method to perform special preparation when 
	 * resizing the color picker’s view. Because this method is invoked only as 
	 * appropriate, it’s better to implement this method than to override the 
	 * method {@link org.actionstep.NSView#superviewSizeChanged} for the 
	 * <code>NSView</code> in which the color picker’s user interface is 
	 * contained.</p>
	 * 
	 * @see org.actionstep.NSColorPickingCustom#provideNewView
	 */
	public function viewSizeChanged(sender:Object):Void;
	
}