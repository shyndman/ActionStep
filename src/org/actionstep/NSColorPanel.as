/* See LICENSE for copyright and terms of use */

import org.actionstep.ASLabel;
import org.actionstep.ASUtils;
import org.actionstep.color.ASColorPanelToolbarDelegate;
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSControlSize;
import org.actionstep.constants.NSTickMarkPosition;
import org.actionstep.constants.NSTitlePosition;
import org.actionstep.constants.NSToolbarDisplayMode;
import org.actionstep.constants.NSToolbarSizeMode;
import org.actionstep.layout.ASHBox;
import org.actionstep.layout.ASVBox;
import org.actionstep.NSApplication;
import org.actionstep.NSArray;
import org.actionstep.NSBox;
import org.actionstep.NSColor;
import org.actionstep.NSColorList;
import org.actionstep.NSColorPicker;
import org.actionstep.NSColorPicking;
import org.actionstep.NSColorWell;
import org.actionstep.NSDraggingSource;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSImageRep;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSPanel;
import org.actionstep.NSPasteboard;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSSlider;
import org.actionstep.NSSplitView;
import org.actionstep.NSTextField;
import org.actionstep.NSToolbar;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASThemeImageNames;
import org.actionstep.themes.standard.images.ASColorSwatchRep;
import org.actionstep.themes.ASTheme;

/**
 * <code>NSColorPanel</code> provides a standard user interface for selecting 
 * color in an application. It provides a number of standard color selection 
 * modes and, with the {@link org.actionstep.NSColorPickingDefault} and 
 * {@link org.actionstep.NSColorPickingCustom} protocols, allows an application 
 * to add its own color selection modes. It allows the user to save swatches 
 * containing frequently used colors.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSColorPanel extends NSPanel {
	
	//******************************************************
	//*                   Notifications
	//******************************************************
	
	/**
	 * Posted when the <code>NSColorPanel</code>’s color is set, as when 
	 * {@link #setColor} is invoked. The notification object is the notifying 
	 * <code>NSColorPanel</code>. This notification does not contain a userInfo 
	 * dictionary.
	 */
	public static var NSColorPanelColorDidChangeNotification:Number
		= ASUtils.intern("NSColorPanelColorDidChangeNotification");
	
	//******************************************************
	//*                     Constants
	//******************************************************
	
	//
	// These constants specify the available modes, and can be bitwise-ORed
	// together.
	//
	
	/** Grayscale-alpha */
	public static var NSColorPanelGrayModeMask:Number 				= 1;
	/** Red-green-blue */
	public static var NSColorPanelRGBModeMask:Number 				= 2;
	/** Cyan-yellow-magenta-black */
	public static var NSColorPanelCMYKModeMask:Number 				= 4;
	/** Hue-saturation-brightness */
	public static var NSColorPanelHSBModeMask:Number 				= 8;
	/** Custom palette */
	public static var NSColorPanelCustomPaletteModeMask:Number 		= 16;
	/** Custom color list */
	public static var NSColorPanelColorListModeMask:Number 			= 32;
	/** Color wheel */
	public static var NSColorPanelWheelModeMask:Number 				= 64;
	/** Crayons */
	public static var NSColorPanelCrayonModeMask:Number 			= 128;
	/** All of the above */
	public static var NSColorPanelAllModesMask:Number 				= 255;
	
	//
	// These constants specify the active mode
	//
	
	/** Grayscale-alpha */
	public static var NSGrayModeColorPanel:Number 				= 1;
	/** Red-green-blue */
	public static var NSRGBModeColorPanel:Number 				= 2;
	/** Cyan-yellow-magenta-black */
	public static var NSCMYKModeColorPanel:Number 				= 4;
	/** Hue-saturation-brightness */
	public static var NSHSBModeColorPanel:Number 				= 8;
	/** Custom palette */
	public static var NSCustomPaletteModeColorPanel:Number 		= 16;
	/** Custom color list */
	public static var NSColorListModeColorPanel:Number 			= 32;
	/** Color wheel */
	public static var NSWheelModeColorPanel:Number 				= 64;
	/** Crayons */
	public static var NSCrayonModeColorPanel:Number 			= 128;
	
	//
	// Size constants
	//
	private static var DEFAULT_WIDTH:Number = 260;
	private static var DEFAULT_HEIGHT:Number = 490;
	private static var INSET:Number = 8;
	private static var SPACING:Number = 8;
	private static var WELL_HEIGHT:Number = 28;
	private static var ALPHA_HEIGHT:Number = 22;
	private static var ALPHA_TEXT_WIDTH:Number = 40;
	private static var ALPHA_LABEL_WIDTH:Number = 20;
	private static var SWATCH_SIZE:Number = 16;
	private static var SWATCH_SPACING:Number = 0;
	private static var PICKER_CELL_SIZE:Number = 30;
	
	//******************************************************
	//*                  Class members
	//******************************************************
	
	private static var g_instance:NSColorPanel;
	private static var g_mask:Number = NSColorPanelAllModesMask;
	private static var g_mode:Number = NSRGBModeColorPanel;
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private var m_accessoryView:NSView;
	private var m_pickers:Array;
	private var m_showsAlpha:Boolean;
	private var m_isContinuous:Boolean;
	private var m_mode:Number;
	private var m_target:Object;
	private var m_action:String;
	private var m_currentPicker:NSColorPicking;
	
	private var m_well:NSColorWell;
	private var m_toolbar:NSToolbar;
	private var m_splitView:NSSplitView;
	private var m_pickerBox:NSBox;
	private var m_alphaSlider:NSSlider;
	private var m_alphaText:NSTextField;
	private var m_alphaPercentLabel:ASLabel;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSColorPanel</code> class.
	 */
	private function NSColorPanel() {
		m_accessoryView = null;
		m_isContinuous = true;
		m_showsAlpha = true;
	}
	
	/**
	 * Initializes and returns the color panel.
	 */
	public function init():NSColorPanel {
		super.initWithContentRectStyleMask(
			new NSRect(0, 0, DEFAULT_WIDTH, DEFAULT_HEIGHT),
			NSWindow.NSTitledWindowMask 
			| NSWindow.NSResizableWindowMask 
			| NSWindow.NSClosableWindowMask);
		setMinWidth(DEFAULT_WIDTH);
		setTitle("Colors");
		setBackgroundColor(new NSColor(0xECECEC));
		
		initPickers();
		buildUI();
		setMode(g_mode);
		
		center();
		
		return this;
	}
	
	/**
	 * Builds the panel UI.
	 */
	private function buildUI():Void {
		//
		// Build the toolbar
		//
		m_toolbar = (new NSToolbar()).initWithIdentifier("colorPanelToolbar");
		m_toolbar.setSizeMode(NSToolbarSizeMode.NSToolbarSizeModeRegular);
		m_toolbar.setDisplayMode(NSToolbarDisplayMode.NSToolbarDisplayModeIconOnly);
		m_toolbar.setShowsBaselineSeparator(true);
		m_toolbar.setDelegate((new ASColorPanelToolbarDelegate()).initWithColorPanel(this));
		setToolbar(m_toolbar);
		
		//
		// Build controls
		//
		var contentRect:NSRect = NSRect.withOriginSize(NSPoint.ZeroPoint, contentSize());
		var insetContentRect:NSRect = contentRect.insetRect(INSET, INSET);
		var wellSize:NSSize = new NSSize(100, WELL_HEIGHT);
		var splitterSize:NSSize = new NSSize(120, 200);
		var pickerViewSize:NSSize = new NSSize(100, 100);
		var pickerBoxRect:NSRect = new NSRect(0, 0, 100, 100);
		var alphaRect:NSRect = new NSRect(0, 0, 100, ALPHA_HEIGHT);
		var swatchSize:NSSize = new NSSize(100, SWATCH_SIZE + SPACING * 2);
		var v:NSView = contentView();
		
		//
		// Build splitter
		//
		m_splitView = (new NSSplitView()).initWithFrame(
			NSRect.withOriginSize(NSPoint.ZeroPoint, splitterSize));
		m_splitView.setVertical(false);
		m_splitView.setAutoresizingMask(NSView.WidthSizable | NSView.HeightSizable);
		m_splitView.setBackgroundColor(backgroundColor());
		//v.addSubview(m_splitView);
		
		//
		// Build vbox and vbox holder
		//
		var vboxHolder:NSView = (new NSView()).initWithFrame(new NSRect(0, 0, 100, 100));
		var vbox:ASVBox = (new ASVBox()).init();
		vbox.setAutoresizingMask(NSView.WidthSizable | NSView.HeightSizable);
		
		//
		// Add color well
		//
		m_well = (new NSColorWell()).initWithFrame(
			NSRect.withOriginSize(NSPoint.ZeroPoint, wellSize));
		m_well.setAutoresizingMask(NSView.WidthSizable);
		m_well.setTarget(this);
		m_well.setAction("updatePicker");
		vbox.addViewEnableYResizingWithMinYMargin(m_well, false, SPACING);
		
		//
		// Picker view
		//
		var pickerView:NSView = (new NSView()).initWithFrame(
			NSRect.withOriginSize(NSPoint.ZeroPoint, pickerViewSize));
		pickerView.setAutoresizingMask(NSView.WidthSizable | NSView.HeightSizable);
				
		//
		// Picker box
		//
		m_pickerBox = (new NSBox()).initWithFrame(pickerBoxRect);
		m_pickerBox.setAutoresizingMask(NSView.WidthSizable | NSView.HeightSizable);
		m_pickerBox.setBorderType(NSBorderType.NSNoBorder);
		m_pickerBox.setTitle("");
		m_pickerBox.setTitlePosition(NSTitlePosition.NSNoTitle);
		m_pickerBox.setContentViewMargins(NSSize.ZeroSize);
		pickerView.addSubview(m_pickerBox);
		vbox.addViewEnableYResizingWithMinYMargin(pickerView, true, SPACING);
		
		//
		// Alpha label
		//
		var alphaLabel:ASLabel = (new ASLabel()).initWithFrame(new NSRect(
			0, 0, 50, 18));
		alphaLabel.setFont(ASTheme.current().systemFontOfSize(11));
		alphaLabel.setStringValue("Opacity");
		vbox.addViewEnableYResizingWithMinYMargin(alphaLabel, false, SPACING);
		
		//
		// Alpha slider
		//		
		var alphaHBox:ASHBox = (new ASHBox()).init();
		alphaHBox.setAutoresizingMask(NSView.WidthSizable);
		
		alphaRect.origin.y -= m_splitView.dividerThickness();
		m_alphaSlider = NSSlider((new NSSlider()).initWithFrame(alphaRect));
		m_alphaSlider.setAutoresizingMask(NSView.WidthSizable | NSView.MinYMargin);
		m_alphaSlider.setNumberOfTickMarks(3);
		m_alphaSlider.setTickMarkPosition(NSTickMarkPosition.NSTickMarkAbove);
		m_alphaSlider.cell().setControlSize(NSControlSize.NSMiniControlSize);
		m_alphaSlider.setContinuous(true);
		m_alphaSlider.cell().setTitle("Opacity");
		m_alphaSlider.setTarget(this);
		m_alphaSlider.setAction("alphaChanged");
		m_alphaSlider.setMinValue(0.0);
		m_alphaSlider.setMaxValue(100.0);
		m_alphaSlider.setFloatValue(100.0);
		alphaHBox.addViewEnableXResizing(m_alphaSlider, true);
		
		//
		// Alpha text
		//
		m_alphaText = (new NSTextField()).initWithFrame(new NSRect(
			0, 0, ALPHA_TEXT_WIDTH, 22));
		m_alphaText.setStringValue("100");
		m_alphaText.setTarget(this);
		m_alphaText.setAction("alphaTextChanged");
		
		alphaHBox.addViewEnableXResizingWithMinXMargin(m_alphaText, false, SPACING);
		
		//
		// Alpha percent label
		//
		m_alphaPercentLabel = (new ASLabel()).initWithFrame(new NSRect(
			0, 0, ALPHA_LABEL_WIDTH, 22));
		m_alphaPercentLabel.setStringValue("%");
		alphaHBox.addViewEnableXResizingWithMinXMargin(m_alphaPercentLabel, false, 2);
		
		vbox.addViewEnableYResizingWithMinYMargin(alphaHBox, false, 0);	
		
		//
		// Scale vbox
		//
		vboxHolder.setFrameSize(vbox.frame().size.addSize(new NSSize(INSET * 2, INSET * 2)));
		vboxHolder.addSubview(vbox);
		vbox.setFrameOrigin(new NSPoint(INSET, INSET));
		vboxHolder.setFrame(insetContentRect.scaledPercentageRect(100, 60));
		
		//
		// Swatches
		//
		var swatchView:NSView = (new NSView()).initWithFrame(
			NSRect.withOriginSize(NSPoint.ZeroPoint, swatchSize));
		swatchView.setAutoresizingMask(NSView.WidthSizable | NSView.HeightSizable);
		buildSwatches(swatchView);
		
		//
		// Add top views to splitter
		//
		m_splitView.addSubview(vboxHolder);
		m_splitView.addSubview(swatchView);	
		m_splitView.adjustSubviews();
		setContentView(m_splitView);
	}
	
	/**
	 * Creates the swatches in the swatch view.
	 */
	private function buildSwatches(swatchView:NSView):Void {
		for (var i:Number = 0; i < 14; i++) {
			var well:NSColorWell = (new NSColorWell()).initWithFrame(new NSRect(
				SPACING + i * (SWATCH_SIZE + SWATCH_SPACING),
				SPACING, SWATCH_SIZE, SWATCH_SIZE));
			well.setBordered(false);
			//well.setEnabled(false);
			well.setTarget(this);
			well.setAction("bottomWellAction");
			swatchView.addSubview(well);	
		}
	}
	
	/**
	 * Adds the pickers to the panel.
	 */
	private function initPickers():Void {
		
		var pickers:Array = m_pickers = NSColorPicker._allPickers().internalList();
		var len:Number = pickers.length;
		
		for (var i:Number = 0; i < len; i++) {
			var p:NSColorPicking = pickers[i];
			p.initWithPickerMaskColorPanel(g_mask, this);
			p.provideNewView(true);
			p["__tag"] = i;
		}		
	}
	
	//******************************************************
	//*            Setting color picker modes
	//******************************************************
	
	/**
	 * <p>Accepts as the mask parameter one or more logically ORed color mode masks
	 * described in <code>"Constants"</code>.</p>
	 * 
	 * <p>This method determines which color selection modes will be available in 
	 * an application’s <code>NSColorPanel</code>. This method has an effect 
	 * only before <code>NSColorPanel</code> is instantiated.</p>
	 * 
	 * @see #setPickerMode
	 */
	public static function setPickerMask(mask:Number):Void {
		g_mask = mask;
	}
	
	/**
	 * Sets the color panel’s initial picker to <code>mode</code>, which may be 
	 * one of the symbolic constants described in <code>"Constants"</code>. The 
	 * <code>mode</code> determines which picker will initially be visible. This
	 * method may be called at any time, whether or not an application’s 
	 * <code>NSColorPanel</code> has been instantiated.
	 * 
	 * @see #setPickerMask
	 */
	public static function setPickerMode(mode:Number):Void {
		g_mode = mode;
	}
	
	//******************************************************
	//*             Setting the NSColorPanel
	//******************************************************
	
	/**
	 * Returns the accessory view, or <code>null</code> if there is none.
	 * 
	 * @see #setAccessoryView()
	 */
	public function accessoryView():NSView {
		return m_accessoryView;
	}
	
	/**
	 * <p>Sets the accessory view displayed in the receiver to <code>aView</code>.</p>
	 * 
	 * <p>The accessory view can be any custom view you want to display with 
	 * <code>NSColorPanel</code>, such as a view offering color blends in a 
	 * drawing program. The accessory view is displayed below the color picker 
	 * and above the color swatches in the <code>NSColorPanel</code>. The 
	 * <code>NSColorPanel</code> automatically resizes to accommodate the 
	 * accessory view.</p>
	 * 
	 * @see #accessoryView()
	 */
	public function setAccessoryView(aView:NSView):Void {
		m_accessoryView = aView;
		//!TODO resize
	}
	
	/**
	 * Returns whether the receiver continuously sends the action message to 
	 * the target as the user manipulates the color picker.
	 * 
	 * @see #setContinuous()
	 */
	public function isContinuous():Boolean {
		return m_isContinuous;
	}
	
	/**
	 * Sets the receiver to send the action message to its target continuously 
	 * as the color of the <code>NSColorPanel</code> is set by the user.
	 * 
	 * @see #isContinuous()
	 */
	public function setContinuous(flag:Boolean):Void {
		m_isContinuous = flag;
	}
	
	/**
	 * Returns the color picker mode of the receiver.
	 * 
	 * @see #setPickerMode()
	 * @see #setMode()
	 */
	public function mode():Number {
		return m_currentPicker.mode();
	}
	
	/**
	 * Sets the mode of the receiver if mode is one of the modes allowed by 
	 * the color mask.
	 * 
	 * @see #setPickerMode()
	 * @see #mode()
	 */
	public function setMode(mode:Number):Void {
		if (mode & g_mask == 0) {
			trace(asWarning("mode " + mode + " not supported on mask " + g_mask));
			return;
		}
		
		m_mode = mode;
		setCurrentPicker(pickerForMode(mode));
	}
	
	/**
	 * <p>Returns whether or not the receiver shows alpha values and an opacity 
	 * slider.</p>
	 * 
	 * <p>Note that calling the <code>NSColor</code> method 
	 * {@link NSColor#setIgnoresAlpha} with a value of <code>true</code> 
	 * overrides any value set with {@link #setShowsAlpha}.</p>
	 * 
	 * @see #setShowsAlpha
	 * @see #alpha
	 */
	public function showsAlpha():Boolean {
		return m_showsAlpha && !color().ignoresAlpha;
	}
	
	/**
	 * <p>Tells the receiver whether or not to show alpha values and an opacity 
	 * slider, depending on the Boolean value <code>flag</code>.</p>
	 * 
	 * <p>Note that calling the <code>NSColor</code> method 
	 * {@link NSColor#setIgnoresAlpha} with a value of <code>true</code> 
	 * overrides any value set with {@link #setShowsAlpha}.</p>
	 * 
	 * @see #showsAlpha
	 * @see #alpha
	 */
	public function setShowsAlpha(flag:Boolean):Void {
		if (m_showsAlpha == flag) {
			return;
		}
		
		m_showsAlpha = flag;
		m_currentPicker.alphaControlAddedOrRemoved(this);
	}
	
	//******************************************************
	//*                 Current picker
	//******************************************************
	
	/**
	 * Sets the current picker.
	 */
	private function setCurrentPicker(picker:NSColorPicking):Void {
		if (picker.identifier() == m_currentPicker.identifier()) {
			m_currentPicker.setColor(color());
			m_currentPicker.setMode(m_mode);
			return;
		}
		
		m_currentPicker = picker;
		
		//
		// Prevents infinite loops
		//
		if (m_toolbar.selectedItemIdentifier() != picker.identifier()) {
			m_toolbar.setSelectedItemIdentifier(picker.identifier());
		}
		
		m_currentPicker.setColor(color());
		m_currentPicker.setMode(m_mode);
		
		m_pickerBox.setContentView(m_currentPicker.provideNewView(false));
	}
	
	//******************************************************
	//*                 Target-action
	//******************************************************
	
	/**
	 * <p>Sets the action message to <code>selector</code>.</p>
	 * 
	 * <p>When you select a color in the color panel <code>NSColorPanel</code> 
	 * sends its action to its target, provided that neither the action nor the 
	 * target is <code>null</code>. The target is <code>null</code> by default.</p>
	 * 
	 * @see #setTarget()
	 * @see #setContinuous()
	 */
	public function setAction(selector:String):Void {
		m_action = selector;
	}
	
	/**
	 * <p>Sets the target of the receiver to <code>anObject</code>.</p>
	 * 
	 * <p>When you select a color in the color panel <code>NSColorPanel</code> 
	 * sends its action to its target, provided that neither the action nor the 
	 * target is <code>null</code>. The target is <code>null</code> by default.</p>
	 * 
	 * @see #setAction()
	 * @see #setContinuous()
	 */
	public function setTarget(anObject:Object):Void {
		m_target = anObject;
	}
	
	//******************************************************
	//*              Attaching a color list
	//******************************************************
	
	/**
	 * Adds the list of <code>NSColor</code>s specified in 
	 * <code>colorList</code> to all the color pickers in the receiver that 
	 * display color lists by invoking {@link NSColorPicker#attachColorList} on 
	 * all color pickers in the application.
	 * 
	 * @see #detachColorList()
	 */
	public function attachColorList(colorList:NSColorList):Void {
		//! TODO implement
	}
	
	/**
	 * Removes the list of <code>NSColor</code>s specified in 
	 * <code>colorList</code> from all the color pickers in the receiver that 
	 * display color lists by invoking {@link NSColorPicker#detachColorList} on 
	 * all color pickers in the application.
	 * 
	 * @see #attachColorList()
	 */
	public function detachColorList(colorList:NSColorList):Void {
		//! TODO implement
	}
	
	//******************************************************
	//*                 Setting color
	//******************************************************
	
	/**
	 * <p>Drags <code>color</code> into a destination view from 
	 * <code>sourceView</code> in response to <code>anEvent</code>.</p> 
	 * 
	 * <p>This method is usually invoked by the {@link #mouseDown} method of 
	 * <code>sourceView</code>. The dragging mechanism handles all subsequent 
	 * events.</p>
	 */
	public static function dragColorWithEventFromView(color:NSColor,
			anEvent:NSEvent, sourceView:NSView):Boolean {
		//
		// Make sure source view is a dragging source
		//
		if (!(sourceView instanceof NSDraggingSource)) {
			trace("Could not drag color. sourceView is not a dragging soruce.");
			return false;
		}
		
		//
		// Get the pasteboard
		//
		var pb:NSPasteboard = NSPasteboard.pasteboardWithName(
			NSPasteboard.NSDragPboard);
			
		//
		// Get the swatch image
		//
		color = color.copyWithZone();
		var rep:NSImageRep = NSImage.imageNamed(
			ASThemeImageNames.NSColorSwatchRepImage).bestRepresentationForDevice().copyWithZone();
		var img:NSImage = (new NSImage()).init();
		img.addRepresentation(rep);
		ASColorSwatchRep(rep).setColor(color);
		
		//
		// Declare types
		//
		var types:NSArray = NSArray.arrayWithObjects(NSPasteboard.NSColorPboardType);
		pb.declareTypesOwner(types);
		pb.addTypesOwner(types);
		pb.setDataForType(color, NSPasteboard.NSColorPboardType);
		
		//
		// Begin drag
		// 
		var s:NSSize = img.size();
		var p:NSPoint = sourceView.convertPointFromView(anEvent.mouseLocation, null);
		var offset:Number = s.width/2 + 2;
		p.x -= offset;
		p.y -= offset;
		
		sourceView.dragImageAtOffsetEventPasteboardSourceSlideBack(
			img, p, new NSSize(-offset, -offset), anEvent, pb, NSDraggingSource(sourceView), false);
		
		return true;		
	}
	
	/**
	 * <p>Sets the color of the receiver to <code>color</code>.</p>
	 * 
	 * <p>This method posts an {@link #NSColorPanelColorDidChangeNotification} with
	 * the receiver to the default notification center.</p>
	 * 
	 * @see #color()
	 */
	public function setColor(color:NSColor):Void {
		color.calculateValueFromRGB();		
				
		//
		// Update well
		//
		m_well.setColor(color);
						
		//
		// Update slider
		//
		if (showsAlpha()) {
			m_alphaSlider.setFloatValue(color.alphaValue);
			m_alphaText.setStringValue(Math.round(color.alphaValue).toString());
			
			m_alphaSlider.setNeedsDisplay(true);
			m_alphaText.setNeedsDisplay(true);
		}
		
		//
		// Disable/enable slider
		//
		var ignoresAlpha:Boolean = color.ignoresAlpha;
		if (m_alphaSlider.isEnabled() != !ignoresAlpha) { 
		  m_alphaSlider.setEnabled(!ignoresAlpha);
		}
		
		//
		// Send changeColor message to first responder
		//
		var first:Object = NSApplication.sharedApplication().mainWindow().firstResponder();
		if (ASUtils.respondsToSelector(first, "changeColor")) {
			first["changeColor"](this);
		}
		
		//
		// Invoke action method
		//
		if (m_target != null) {
			m_target[m_action](this);
		}
		
		//
		// Post notification
		//
		NSNotificationCenter.defaultCenter().postNotificationWithNameObject(
			NSColorPanelColorDidChangeNotification,
			this);
	}
	
	//******************************************************
	//*            Getting color information
	//******************************************************
	
	/**
	 * Returns the receiver’s current alpha value based on its opacity slider.
	 */
	public function alpha():Number {
		if (!showsAlpha()) {
			return 1.0;
		} else {
			return color().alphaComponent();
		}
	}
	
	/**
	 * Returns the currently selected color in the receiver.
	 * 
	 * @see #setColor()
	 */
	public function color():NSColor {
		return m_well.color();
	}
	
	//******************************************************
	//*                Action methods
	//******************************************************
	
	/**
	 * Updates the current picker
	 */
	private function updatePicker(sender:Object):Void {
		m_currentPicker.setColor(color());
	}
	
	/**
	 * Reflects alpha value changes
	 */
	private function alphaChanged(sender:NSSlider):Void {
		var c:NSColor = m_well.color();
		c.alphaValue = sender.floatValue();
		c["m_alpha"] = c.alphaValue / 100;
		
		m_alphaText.setStringValue(Math.round(c.alphaValue).toString());
		m_alphaText.setNeedsDisplay(true);
		
		m_well.setNeedsDisplay(true);
	}
	
	/**
	 * The alpha text field changed
	 */
	private function alphaTextChanged(sender:NSTextField):Void {
		var alpha:Number = parseInt(sender.stringValue(), 10);
		if (isNaN(alpha)) {
			sender.setStringValue(m_alphaSlider.floatValue().toString());
			sender.setNeedsDisplay(true);
			return;
		}
		
		var c:NSColor = m_well.color();
		c.alphaValue = alpha;
		c["m_alpha"] = alpha / 100;
		m_alphaSlider.setFloatValue(alpha);
		
		m_well.setNeedsDisplay(true);
	}
	
	/**
	 * Sets the current color to the color that was clicked in the well.
	 */
	private function bottomWellAction(sender:NSColorWell):Void {
		setColor(sender.color());
	}
	
	/**
	 * Changes the current picker to <code>picker</code>.
	 */
	public function changePicker(picker:NSColorPicking):Void {
		setMode(picker.mode());
	}
	
	//******************************************************
	//*                Helper methods
	//******************************************************
	
	/**
	 * Returns the first picker matching mode.
	 */
	private function pickerForMode(mode:Number):NSColorPicking {
		
		var len:Number = m_pickers.length;
		for (var i:Number = 0; i < len; i++) {
			if (m_pickers[i].supportsMode(mode)) {
				return NSColorPicking(m_pickers[i]);
			}
		}
		
		return null;
	}
	
	//******************************************************
	//*            Creating the NSColorPanel
	//******************************************************
	
	/**
	 * Returns the shared <code>NSColorPanel</code>, creating it if necessary.
	 */
	public static function sharedColorPanel():NSColorPanel {
		if (g_instance == undefined) {
			g_instance = (new NSColorPanel()).init();
		}
		
		return g_instance;
	}
	
	/**
	 * Returns <code>true</code> if the <code>NSColorPanel</code> has been 
	 * created already.
	 */
	public static function sharedColorPanelExists():Boolean {
		return g_instance != undefined;
	}
}