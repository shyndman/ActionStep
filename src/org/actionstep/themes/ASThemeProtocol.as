/* See LICENSE for copyright and terms of use */

import org.actionstep.ASTextEditor;
import org.actionstep.constants.NSAnimationCurve;
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSControlSize;
import org.actionstep.constants.NSImageFrameStyle;
import org.actionstep.menu.NSMenuView;
import org.actionstep.NSAlert;
import org.actionstep.NSButtonCell;
import org.actionstep.NSColor;
import org.actionstep.NSColorList;
import org.actionstep.NSColorWell;
import org.actionstep.NSFont;
import org.actionstep.NSImage;
import org.actionstep.NSParagraphStyle;
import org.actionstep.NSRect;
import org.actionstep.NSScroller;
import org.actionstep.NSSize;
import org.actionstep.NSSliderCell;
import org.actionstep.NSStepperCell;
import org.actionstep.NSTabViewItem;
import org.actionstep.NSTextFieldCell;
import org.actionstep.NSTextView;
import org.actionstep.NSToolbar;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.scroller.ASScrollerButtonCell;

/**
 * <p>Describes methods that should be implemented by any "Theme" object, the core
 * object for theming, as all control drawing is done through classes that 
 * implement this protocol.</p>
 * 
 * <p>To set the current theme, use {@link org.actionstep.ASTheme#setCurrent()}.
 * </p>
 *
 * @author Scott Hyndman
 */
interface org.actionstep.themes.ASThemeProtocol 
{		  
	/**
 	 * Sets this theme to the be active theme
 	 */
	function setActive(value:Boolean):Void;
  
	//******************************************************
	//*                   Basic fills
	//******************************************************
	
	/**
	 * Draws a filled rectangle with the color aColor in the view inView.
	 */
	function drawFillWithRectColorInView(aRect:NSRect, aColor:NSColor, 
	  inView:NSView):Void;
	
	//******************************************************
	//*                   First responder
	//******************************************************
	
	/**
	 * First responder color
	 */
	function firstResponderColor():NSColor;

	/**
	 * Draws the border around the button when it has key focus
	 */
	function drawFirstResponderWithRectInView(rect:NSRect, 
	  view:NSView):Void;

	/**
	 * Draws the border around the button when it has key focus
	 */
	function drawFirstResponderWithRectInClip(rect:NSRect, 
	  clip:MovieClip):Void;
	  
	//******************************************************
	//*                     Images
	//******************************************************
	
	/**
	 * <p>Dims the clip last drawn with <code>image</code> by a factor of
	 * <code>factor</code>.</p>
	 * 
	 * <p>No operation is performed if <code>image</code>'s 
	 * {@link NSImage#lastCanvas()} is <code>null</code> or the
	 * {@link NSView#mcBounds()} of <code>view</code>.</p> 
	 */
	function dimImageCanvasInViewWithFactor(image:NSImage, view:NSView, 
		factor:Number):Void;
	
	//******************************************************
	//*                    NSButton
	//******************************************************
	  
	/**
	 * Draws a button border of the provided type and style
	 */
	function drawButtonCellBorderInRectOfView(cell:NSButtonCell, rect:NSRect, 
		view:NSView):Void;

	/**
	 * Draws a button interior of the provided color, type and style
	 */
	function drawButtonCellInteriorInRectOfView(cell:NSButtonCell, rect:NSRect, 
		view:NSView):Void;
	
	/**
	 * <p>Returns the size of the "switch" image given a size.</p>
	 * 
	 * <p>The switch image is also known as the checkbox.</p>
	 */
	function switchImageSizeForControlSize(size:NSControlSize):NSSize;
		
	/**
	 * <p>Returns the size of the "radio" image given a size.</p>
	 */
	function radioImageSizeForControlSize(size:NSControlSize):NSSize;
		
	//******************************************************
	//*                    NSAlert
	//******************************************************
	
	function buttonTextColorForAlert(alert:NSAlert):NSColor;
		
	//******************************************************
	//*                     ASList
	//******************************************************
	
	/**
	 * Draws the the ASList background
	 */
	function drawListWithRectInView(rect:NSRect, view:NSView):Void;
	
	/**
	 * Draws a list's selected item.
	 */
	function drawListSelectionWithRectInView(rect:NSRect, aView:NSView):Void;
	
	//******************************************************
	//*                    ASToolTip
	//******************************************************
	
	/**
	 * Draws the ASToolTip background.
	 */
	function drawToolTipWithRectInView(rect:NSRect, view:NSView):Void;
	
	/**
	 * <p>Returns the CSS style string that will be used by tooltips in the
	 * application.</p>
	 * 
	 * <p>Please not that the style the tooltip uses is called "tipText". The
	 * "tipText" tag is automatically inserted by the tooltip when its text is 
	 * set.</p>
	 */
	function toolTipStyleCss():String;
	
	/**
	 * Returns <code>true</code> if the tool tip's font is embedded.
	 */
	function isToolTipFontEmbedded():Boolean;
	
	/**
	 * The amount of time (in seconds) a tooltip will wait (without the mouse 
	 * moving) before displaying.
	 */
	function toolTipInitialDelay():Number;
	
	/**
	 * The amount of time (in seconds) a tooltip will remain shown.
	 */
	function toolTipAutoPopDelay():Number;
	
	/**
	 * <p>The URL of the swf loaded into the tooltip window. The swf can contain
	 * assets for the tooltips to use.</p>
	 * 
	 * <p>If <code>null</code>, no external swf is used.</p>
	 */
	function toolTipSwf():String;
	
	//******************************************************
	//*                     NSDrawer
	//******************************************************
	
	/**
	 * <p>Draws the drawer.</p>
	 */
	function drawDrawerWithRectInView(aRect:NSRect, view:NSView):Void;

	/**
	 * Returns the amount of time (in milliseconds) the drawer takes to open.
	 */	
	function drawerOpenDuration():Number;
	
	/**
	 * Returns the amount of time (in milliseconds) the drawer takes to close.
	 */
	function drawerCloseDuration():Number;
	
	/**
	 * Returns the function the drawer uses to ease open.
	 */
	function drawerEaseOpenFunction():Function;
	
	/**
	 * Returns the function the drawer uses to ease close.
	 */
	function drawerEaseCloseFunction():Function;
	
	/**
	 * Returns the width of the drawer's borders.
	 */
	function drawerBorderWidth():Number;
	
	//******************************************************
	//*                    NSWindow
	//******************************************************
	
	/**
	 * Draws the window as it should appear while resizing.
	 */
	function drawResizingWindowWithRectInView(aRect:NSRect, 
	  view:NSView):Void;
	
	/**
	 * Draws a windows title bar.
	 */
	function drawWindowTitleBarWithRectInViewIsKey(aRect:NSRect, 
	  view:NSView, isKey:Boolean):Void;
	  	
	/**
	 * Returns the amount of time <code>wnd</code>'s resize animation should
	 * take. The time should be expressed in seconds.
	 */
	function windowAnimationResizeTime(wnd:NSWindow):Number;

	/**
	 * Returns the animation curve of <code>wnd</code>'s resize animation.
	 */
	function windowAnimationResizeCurve(wnd:NSWindow):NSAnimationCurve;
	
	/**
	 * Returns the height of a window's title bar.
	 */
	function windowTitleBarHeight():Number;
	
	//******************************************************
	//*                      NSMenu
	//******************************************************
	
	/**
	 * Draws a menu background on <code>view</code> in the area defined by
	 * <code>aRect</code>.
	 */
	function drawMenuBackgroundWithRectInView(aRect:NSRect, view:NSMenuView):Void;
	
	/**
	 * Draws a menu bar background on <code>view</code> in the area defined by
	 * <code>aRect</code>.
	 */	
	function drawMenuBarBackgroundWithRectInView(aRect:NSRect, view:NSMenuView):Void;
	
	/**
	 * Draws a menu separator on <code>view</code> in the area defined by 
	 * <code>rect</code>.
	 */
	function drawMenuSeparatorWithRectInView(aRect:NSRect, view:NSMenuView):Void;
	
	//******************************************************
	//*                    NSTextField
	//******************************************************
	
	/**
	 * Draws the NSTextFieldCell <code>cell</code>.
	 */
	function drawTextFieldCellInRectOfView(cell:NSTextFieldCell, 
		rect:NSRect, view:NSView):Void;
		
	//******************************************************
	//*                     NSStepper
	//******************************************************
	
	function drawStepperCellBorderInRectOfView(cell:NSStepperCell,
		rect:NSRect, view:NSView):Void;
	
	//******************************************************
	//*                     NSTextView
	//******************************************************
	
	function drawTextViewWithRectInView(rect:NSRect, view:NSTextView):Void;
	
	//******************************************************
	//*                    ASTextEditor
	//******************************************************
	
	function drawTextEditorWithRectInView(rect:NSRect, view:ASTextEditor):Void;
	
	//******************************************************
	//*                      NSBox
	//******************************************************
	
	/**
	 * <p>Draws the border of an <code>NSBox</code> in the area defined by 
	 * <code>rect</code> inside <code>view</code> (which is typically an 
	 * <code>NSBox</code>).</p>
	 * 
	 * <p>The method takes an exclude rectangle <code>exclude</code>, which is the
	 * title area. If <code>exclude</code> is <code>null</code>, no exclusion
	 * is necessary.</p>
	 */
	function drawBoxBorderWithRectInViewExcludeRectBorderType(rect:NSRect, 
		view:NSView, exclude:NSRect, border:NSBorderType):Void;
	
	//******************************************************
	//*                   NSColorWell
	//******************************************************
	
	/**
	 * Draws the color well border on <code>well</code> inside the rectangle 
	 * <code>rect</code>, and returns the width of the borders.
	 */
	function drawColorWellBorderWithRectInWell(rect:NSRect,
		well:NSColorWell):Number;
		
	//******************************************************
	//*                    NSScroller
	//******************************************************
	
	/**
	 * Draws an NSScroller slot in the view.
	 */
	function drawScrollerSlotWithRectInView(rect:NSRect, 
	  view:NSView):Void;

	/**
	 * Draws an NSScroller slot in the view.
	 */
	function drawScrollerWithRectInClip(rect:NSRect, 
	  clip:MovieClip):Void;

	/**
	 * Returns this theme's scroller width.
	 */
	function scrollerWidth():Number;
	
	/**
	 * Returns the width of the <code>NSScroller</code>'s buttons.
	 */
	function scrollerButtonWidth():Number;
	
	/**
	 * Draws a scroller border of the provided type and style
	 */
	function drawScrollerCellBorderInRectOfScroller(cell:ASScrollerButtonCell, 
		rect:NSRect, view:NSScroller):Void;
		
	/**
	 * Draws a scroller button background.
	 */
	function drawScrollerCellBackgroundWithFrameMaskInScroller(cell:ASScrollerButtonCell, 
		frame:NSRect, mask:Number, scroller:NSScroller):Void;
	
	//******************************************************
	//*                   NSScrollView
	//******************************************************
	
	/**
	 * Draws the scroll view's borders in the view.
	 */
	function drawScrollViewBorderInRectWithViewBorderType(rect:NSRect, 
		view:NSView, border:NSBorderType):Void;
	
	//******************************************************
	//*                   NSTableView
	//******************************************************
	
	/**
	 * Draws a table header in the view. If highlighted is <code>true</code>, 
	 * it means the column header should be drawn pressed. If 
	 * <code>selected</code> is <code>true</code>, the header should be drawn
	 * to indicate selection.
	 */
	function drawTableHeaderWithRectInViewHighlightedSelected(rect:NSRect, 
	  view:NSView, highlighted:Boolean, selected:Boolean):Void;
	
	//******************************************************
	//*                    NSImageView
	//******************************************************
	
	/**
	 * Draws an image frame in the view <code>view</code>, bounded by the 
	 * rectangle <code>rect</code> with a frame style of <code>style</code>.
	 */
	function drawImageFrameWithRectInViewStyle(rect:NSRect, view:NSView,
      style:NSImageFrameStyle):Void;
    
    //******************************************************
    //*                    NSStatusBar
    //******************************************************
    
    /**
     * Returns the thickness of the status bar.
     */  	
    function statusBarThickness():Number;
    
    /**
     * <p>Draws the background of a status bar in the area defined by 
     * <code>rect</code>, onto <code>aView</code>.</p>
     * 
     * <p>If <code>highlight</code> is <code>true</code>, the background should
     * appear as it would if the status item was clicked. If <code>false</code>,
     * it should appear as it ordinarily would.</p>
     */
    function drawStatusBarBackgroundInRectWithViewHighlight(rect:NSRect,
      aView:NSView, highlight:Boolean):Void;
    
    //******************************************************
    //*                NSProgressIndicator
    //******************************************************
    
    /**
     * Returns the size of the progress indicator based on the size constant
     * <code>size</code>. 
     */    
    function progressIndicatorSizeForSize(size:NSControlSize):NSSize;
        
    /**
     * Draws a progress bar in <code>aView</code> constrained by
     * <code>rect</code>. If <code>bezeled</code> is <code>true</code> the
     * progress bar should have a 3-dimension border. <code>progress</code> is
     * a value from 0 to 100 specifying the progress the bar should display. If
     * <code>progress</code> is outside of the valid range, no progress bar is
     * drawn.
     */
    function drawProgressBarInRectWithViewBezeledProgress(
    	rect:NSRect, aView:NSView, bezeled:Boolean, progress:Number):Void;

    function drawProgressBarBorderInRectWithClipBezeledProgress(
    	rect:NSRect, mc:MovieClip, bezeled:Boolean, progress:Number):Void;

    function drawProgressBarPatternInRectWithClipIndeterminate(rect:NSRect, 
    	mc:MovieClip, indeterminate:Boolean):Void;

    function drawProgressBarSpinnerInRectWithClip(rect:NSRect, 
    	mc:MovieClip):Void;
    
    //******************************************************
    //*                     NSSlider
    //******************************************************
    
    /**
     * Returns the width of the track used by an <code>NSSlider</code>.
     */
    function sliderTrackWidthWithControlSize(size:NSControlSize):Number;

    /**
     * Returns the width of the track used by an <code>NSSlider</code>.
     */
    function sliderThumbSizeWithSliderCellControlSize(cell:NSSliderCell, 
    	size:NSControlSize):NSSize;
    
    /**
     * Returns the length of a tick used by a bar <code>NSSlider</code>.
     */
    function sliderTickLengthWithControlSize(size:NSControlSize):Number;
    
    /**
     * Draws the slider track in <code>view</code> constrained by
     * <code>rect</code>.
     */
    function drawSliderCellTrackWithRectInView(cell:NSSliderCell, 
    	rect:NSRect, view:NSView):Void;
    
    /**
     * Draws the background of a circular slider in <code>view</code> 
     * constrained by <code>rect</code>.
     */
    function drawCircularSliderCellWithRectInView(cell:NSSliderCell,
    	aRect:NSRect, view:NSView):Void;
    
    /**
     * Draws a slider tick in <code>view</code> constrained by 
     * <code>rect</code>.
     * 
     * <code>vertical</code> specifies the orientation of the tick.
     */
    function drawLinearSliderCellTickWithRectInView(cell:NSSliderCell, 
    	aRect:NSRect, view:NSView):Void;
    
    /**
     * Draws a circular slider tick with a length of <code>length</code> and an
     * angle of <code>angle</code> in <code>view</code>.
     */
    function drawCircularSliderCellTickWithRectLengthAngleInView(
    	cell:NSSliderCell, rect:NSRect, length:Number, angle:Number, 
    	view:NSView):Void;
    
    //******************************************************
    //*                    NSTabView
    //******************************************************
    
    /**
     * Returns the height used when drawing tabs in an <code>NSTabView</code>.
     */  
	function tabHeight():Number;
    
    /**
     * Draws the <code>NSTabViewItem</code> represented by <code>item</code> 
     * onto <code>view</code> inside the rectangle defined by <code>rect</code>.
     */
	function drawTabViewItemInRectWithView(item:NSTabViewItem, rect:NSRect,
		view:NSView):Void;
    
    //******************************************************
    //*                    NSToolbar
    //******************************************************
    
    /**
     * Draws the toolbar background in <code>view</code>.
     */
	function drawToolbarBackgroundWithRectInView(toolbar:NSToolbar, rect:NSRect,
		view:NSView):Void;
      
    /**
 	 * Returns the height of a toolbar. Should take 
	 * <code>NSToolbar#displayMode()</code> and <code>NSToolbar#sizeMode()</code> 
	 * into account.
	 */
	function toolbarHeightForToolbar(toolbar:NSToolbar):Number;
    
    /**
 	 * Returns the maximum width/height of an item's image in a toolbar. Should 
 	 * take <code>NSToolbar#displayMode()</code> and <code>NSToolbar#sizeMode()</code> 
	 * into account.
	 */
	function toolbarItemImageSizeForToolbar(toolbar:NSToolbar):Number;
    
    //******************************************************
    //*                      Colors
    //******************************************************
    
	/**
	 * <p>Returns the list of colors used by the application.</p>
	 * 
	 * <p>The names of colors used in the theme can be found by looking at the
	 * {@link org.actionstep.themes.ASThemeColorNames} class.</p>
	 * 	
	 * @see #setColors
	 * @see #addColorWithName
	 */
	function colors():NSColorList;
	
	/**
	 * Returns the color with the name <code>name</code>, or <code>null</code>
	 * if no such color exists.
	 * 
	 * @see #colors
	 */
	function colorWithName(name:String):NSColor;
	
	/**
	 * Sets the list of colors used by the theme.
	 * 
	 * @see #colors
	 * @see #addColorWithName
	 */
	function setColors(aColorList:NSColorList):Void;
	
	/**
	 * Adds the color <code>aColor</code> named <code>name</code> to the theme's 
	 * color list.
	 * 
	 * @see #colors
	 */
	function setColorForName(aColor:NSColor, name:String):Void;
	
	/**
	 * Registers the default named colors in the theme. Check the comment of
	 * <code>#colors</code> for specifics on what colors are named.
	 * 
	 * @see #colors
	 */
	function registerDefaultColors():Void;
	
	//******************************************************
	//*                     Images
	//******************************************************
	
	/**
	 * Registers the default image representations for buttons and other 
	 * controls.
	 */
	function registerDefaultImages():Void;

	//******************************************************
	//*                     Fonts
	//******************************************************
	
	/**
	 * Gives the theme an opportunity to perform any necessary font setup.
	 */
	function registerDefaultsFonts():Void;
	
	/**
	 * <p>Returns the system font used for standard interface items that are 
	 * rendered in boldface type in the specified size.</p>
	 * 
	 * <p>If <code>fontSize</code> is 0 or negative, returns the boldface system
	 * font at the default size.</p>
	 */
	function boldSystemFontOfSize(fontSize:Number):NSFont;
	
	/**
	 * <p>Returns the font used for the content of controls in the specified 
	 * size.</p>
	 * 
	 * <p>For example, in a table, the user’s input uses the control content 
	 * font, and the table’s header uses another font. If <code>fontSize</code> 
	 * is 0 or negative, returns the control content font at the default 
	 * size.</p>
	 */
	function controlContentFontOfSize(fontSize:Number):NSFont;
	
	/**
	 * <p>Returns the font used for standard interface labels in the specified 
	 * size.</p>
	 * 
	 * <p>If <code>fontSize</code> is 0 or negative, returns the label font with
	 * the default size.</p>
	 */
	function labelFontOfSize(fontSize:Number):NSFont;

	/**
	 * <p>Returns the font used for menu items, in the specified size.</p>
	 * 
	 * <p>If <code>fontSize</code> is 0 or negative, returns the menu item font 
	 * with the default size.</p>
	 */	
	function menuFontOfSize(fontSize:Number):NSFont;
	
	/**
	 * <p>Returns the font used for menu bar items, in the specified size.</p>
	 * 
	 * <p>If <code>fontSize</code> is 0 or negative, returns the menu bar font 
	 * with the default size.</p>
	 */
	function menuBarFontOfSize(fontSize:Number):NSFont;
	
	/**
	 * <p>
	 * Returns the font used for standard interface items, such as button 
	 * labels, menu items, and so on, in the specified size.
	 * </p>
	 * 
	 * <p>If <code>fontSize</code> is 0 or negative, returns the menu bar font 
	 * with the default size.</p>
	 */
	function messageFontOfSize(fontSize:Number):NSFont;
	
	/**
	 * <p>Returns the font used for palette window title bars, in the specified 
	 * size.</p>
	 * 
	 * <p>If <code>fontSize</code> is 0 or negative, returns the palette title 
	 * font with the default size.</p>
	 */
	function paletteFontOfSize(fontSize:Number):NSFont;
	
	/**
	 * <p>Returns the Aqua system font used for standard interface items, such 
	 * as button labels, menu items, and so on, in the specified size.</p>
	 * 
	 * <p>If <code>fontSize</code> is 0 or negative, returns the font with
	 * the default size.</p>
	 */
	function systemFontOfSize(fontSize:Number):NSFont;
	
	/**
	 * Default control font color
	 */
	function systemFontColor():NSColor;
	
	/**
	 * <p>Returns the font used for unhighlighted window title bars (title bars
	 * of windows that are not main), in the specified size.</p>
	 * 
	 * <p>If <code>fontSize</code> is 0 or negative, returns the font with
	 * the default size.</p>
	 */
	function titleBarFontOfSize(fontSize:Number):NSFont;
	
	/**
	 * <p>Returns the font used for tool tips labels, in the specified size.</p>
	 * 
	 * <p>If <code>fontSize</code> is 0 or negative, returns the label font with
	 * the default size.</p>
	 */
	function toolTipsFontOfSize(fontSize:Number):NSFont;
	
	/**
	 * Returns the size of the standard system font.
	 */
	function systemFontSize():Number;
	
	/**
	 * <p>Returns the font size used for the specified control size.</p>
	 * 
	 * <p>If <code>controlSize</code> does not correspond to a valid 
	 * {@link NSControlSize}, it returns the size of the standard system font.
	 * </p>
	 */
	function systemFontSizeForControlSize(controlSize:NSControlSize):Number;
	
	/**
	 * <p>Returns the default paragraph font used in this theme.</p>
	 */
	function defaultParagraphStyle():NSParagraphStyle;
}
