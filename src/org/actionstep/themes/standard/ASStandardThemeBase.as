/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.NSColor;
import org.actionstep.NSColorList;
import org.actionstep.NSImage;
import org.actionstep.NSImageRep;
import org.actionstep.NSObject;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.ASThemeImageNames;

/**
 * @author Scott Hyndman
 */
class org.actionstep.themes.standard.ASStandardThemeBase extends NSObject {
	
  private var m_colorList:NSColorList;
	
  //******************************************************
  //*                    Colors
  //******************************************************
	
  /**
   * Registers the default colors for the theme.
   */
  public function registerDefaultColors():Void {
  	// Text
  	m_colorList.setColorForKey(ASColors.lightGrayColor(),
  	  ASThemeColorNames.ASDisabledText);
  	// NSAlert
  	m_colorList.setColorForKey(ASColors.whiteColor(),
  	  ASThemeColorNames.ASAlertBackground);
  	// ASToolTip
  	m_colorList.setColorForKey(ASColors.blackColor(),
  	  ASThemeColorNames.ASToolTipBorder);
  	m_colorList.setColorForKey(new NSColor(0xFFFFE1),
  	  ASThemeColorNames.ASToolTipBackground);
    // NSMenu
    m_colorList.setColorForKey(new NSColor(0xEEEEEE),
      ASThemeColorNames.ASMenuBackground);
    m_colorList.setColorForKey(
      m_colorList.colorWithKey("ASMenuBackground").
      adjustColorBrightnessByFactor(0.8),
      ASThemeColorNames.ASMenuBorder);
    m_colorList.setColorForKey(new NSColor(0x227CE8),
      ASThemeColorNames.ASMenuItemSelectedBackground);
	m_colorList.setColorForKey(new NSColor(0xFFFFFF),
	  ASThemeColorNames.ASMenuItemSelectedText);
	m_colorList.setColorForKey(ASColors.blackColor(),
	  ASThemeColorNames.ASMenuItemText);
	m_colorList.setColorForKey(ASColors.lightGrayColor(),
	  ASThemeColorNames.ASMenuItemDisabledText);
	// NSProgressIndicator
    m_colorList.setColorForKey(ASColors.grayColor(),
      ASThemeColorNames.ASProgressBar);
    m_colorList.setColorForKey(NSColor.colorWithCalibratedWhiteAlpha(.44, 1),
      ASThemeColorNames.ASSliderBarColor);
    m_colorList.setColorForKey(
      ASColors.lightGrayColor().adjustColorBrightnessByFactor(1.1),
      ASThemeColorNames.ASProgressBarBackground);
    // NSTabView
    m_colorList.setColorForKey(new NSColor(0xC6C6C6),
      ASThemeColorNames.ASTabViewItem);
    // NSBrowser
    m_colorList.setColorForKey(ASColors.blackColor(),
      ASThemeColorNames.ASBrowserText);
    m_colorList.setColorForKey(ASColors.whiteColor(),
      ASThemeColorNames.ASBrowserFirstResponderSelectionText);
    m_colorList.setColorForKey(new NSColor(0x327AC4),
      ASThemeColorNames.ASBrowserFirstResponderSelectionBackground);
    m_colorList.setColorForKey(ASColors.whiteColor(),
      ASThemeColorNames.ASBrowserSelectionText);
    m_colorList.setColorForKey(ASColors.darkGrayColor(),
      ASThemeColorNames.ASBrowserSelectionBackground);
    m_colorList.setColorForKey(ASColors.whiteColor(),
      ASThemeColorNames.ASBrowserMatrixBackground);
    // NSButton
    m_colorList.setColorForKey(ASColors.whiteColor(),
      ASThemeColorNames.ASSwitchButtonBackground);
    m_colorList.setColorForKey(new NSColor(0x4C94E2),
      ASThemeColorNames.ASHighlightedSwitchButtonBackground);
    m_colorList.setColorForKey(ASColors.whiteColor(),
      ASThemeColorNames.ASRadioButtonBackground);
    m_colorList.setColorForKey(new NSColor(0x4C94E2),
      ASThemeColorNames.ASHighlightedRadioButtonBackground);
    m_colorList.setColorForKey(ASColors.blackColor(),
      ASThemeColorNames.ASSystemFontColor);
    // NSTableView
    m_colorList.setColorForKey(new NSColor(0xE8E8E8),
      ASThemeColorNames.ASTableHeaderBackground);
    m_colorList.setColorForKey(new NSColor(0xD6D6D6),
      ASThemeColorNames.ASHighlightedTableHeaderBackground);
    m_colorList.setColorForKey(new NSColor(0x639FDB),
      ASThemeColorNames.ASSelectedTableHeaderBackground);
    m_colorList.setColorForKey(new NSColor(0x5182B3),
      ASThemeColorNames.ASHighlightedSelectedTableHeaderBackground);
    m_colorList.setColorForKey(new NSColor(0xEDF3FE),
      ASThemeColorNames.ASAlternatingRowColor);
    m_colorList.setColorForKey(ASColors.whiteColor(),
      ASThemeColorNames.ASTableCellFirstResponderSelectionText);
    m_colorList.setColorForKey(new NSColor(0x327AC4),
      ASThemeColorNames.ASTableCellFirstResponderSelectionBackground);
    m_colorList.setColorForKey(ASColors.whiteColor(),
      ASThemeColorNames.ASTableCellSelectionText);
    m_colorList.setColorForKey(ASColors.darkGrayColor(),
      ASThemeColorNames.ASTableCellSelectionBackground);
    // NSToolbar
    m_colorList.setColorForKey(new NSColor(0x000000),
      ASThemeColorNames.ASToolbarBaseline);
    m_colorList.setColorForKey(new NSColor(0xF6F6F6),
      ASThemeColorNames.ASToolbarBackground);
    m_colorList.setColorForKey(new NSColor(0xB6B6B6),
      ASThemeColorNames.ASSelectedToolbarItemBorder);
    m_colorList.setColorForKey(new NSColor(0xDDDDDD),
      ASThemeColorNames.ASSelectedToolbarItemBackground);  	
  }

  //******************************************************
  //*                   Images
  //******************************************************

  public function registerDefaultImages():Void {
    //! TODO These images really should be constants
    
    //
    // Radio button
    //
    setImage(ASThemeImageNames.NSRegularRadioButtonImage,
      org.actionstep.themes.standard.images.ASRadioButtonRep);
    setImage(ASThemeImageNames.NSRegularHighlightedRadioButtonImage,
      org.actionstep.themes.standard.images.ASHighlightedRadioButtonRep);
    setImage(ASThemeImageNames.NSSmallRadioButtonImage,
      org.actionstep.themes.standard.images.ASRadioButtonRep);
    setImage(ASThemeImageNames.NSSmallHighlightedRadioButtonImage,
      org.actionstep.themes.standard.images.ASHighlightedRadioButtonRep);
    setImage(ASThemeImageNames.NSMiniRadioButtonImage,
      org.actionstep.themes.standard.images.ASRadioButtonRep);
    setImage(ASThemeImageNames.NSMiniHighlightedRadioButtonImage,
      org.actionstep.themes.standard.images.ASHighlightedRadioButtonRep);
  
    //
    // Checkbox
    //
    setImage(ASThemeImageNames.NSRegularSwitchImage,
      org.actionstep.themes.standard.images.ASSwitchRep);
    setImage(ASThemeImageNames.NSRegularHighlightedSwitchImage,
      org.actionstep.themes.standard.images.ASHighlightedSwitchRep);
    setImage(ASThemeImageNames.NSSmallSwitchImage,
      org.actionstep.themes.standard.images.ASSwitchRep);
    setImage(ASThemeImageNames.NSSmallHighlightedSwitchImage,
      org.actionstep.themes.standard.images.ASHighlightedSwitchRep);
    setImage(ASThemeImageNames.NSMiniSwitchImage,
      org.actionstep.themes.standard.images.ASSwitchRep);
    setImage(ASThemeImageNames.NSMiniHighlightedSwitchImage,
      org.actionstep.themes.standard.images.ASHighlightedSwitchRep);

	//
	// Slider
	//
    setImage(ASThemeImageNames.NSRegularSliderRoundThumbRepImage, 
      org.actionstep.themes.standard.images.ASSliderRoundThumbRep);
    setImage(ASThemeImageNames.NSRegularSliderLinearVerticalThumbRepImage,
      org.actionstep.themes.standard.images.ASSliderLinearVerticalThumbRep);
    setImage(ASThemeImageNames.NSRegularSliderLinearHorizontalThumbRepImage, 
      org.actionstep.themes.standard.images.ASSliderLinearHorizontalThumbRep);
    setImage(ASThemeImageNames.NSRegularSliderCircularThumbRepImage, 
      org.actionstep.themes.standard.images.ASSliderCircularThumbRep);
	
	//
	// Alerts
	//
	setImage(ASThemeImageNames.NSInformationAlertImage,
	  org.actionstep.themes.standard.images.ASAlertInformationIconRep);
	setImage(ASThemeImageNames.NSWarningAlertImage,
	  org.actionstep.themes.standard.images.ASAlertWarningIconRep);
	setImage(ASThemeImageNames.NSCriticalAlertImage,
	  org.actionstep.themes.standard.images.ASAlertCriticalIconRep);
	
	//
    // Scrollers
    //
    setImage(ASThemeImageNames.NSScrollerUpArrowImage, 
      org.actionstep.themes.standard.images.ASScrollerUpArrowRep);
    setImage(ASThemeImageNames.NSHighlightedScrollerUpArrowImage,
      org.actionstep.themes.standard.images.ASHighlightedScrollerUpArrowRep);
    setImage(ASThemeImageNames.NSScrollerDownArrowImage, 
      org.actionstep.themes.standard.images.ASScrollerDownArrowRep);
    setImage(ASThemeImageNames.NSHighlightedScrollerDownArrowImage, 
      org.actionstep.themes.standard.images.ASHighlightedScrollerDownArrowRep);
    setImage(ASThemeImageNames.NSScrollerLeftArrowImage,
      org.actionstep.themes.standard.images.ASScrollerLeftArrowRep);
    setImage(ASThemeImageNames.NSHighlightedScrollerLeftArrowImage,
      org.actionstep.themes.standard.images.ASHighlightedScrollerLeftArrowRep);
    setImage(ASThemeImageNames.NSScrollerRightArrowImage,
      org.actionstep.themes.standard.images.ASScrollerRightArrowRep);
    setImage(ASThemeImageNames.NSHighlightedScrollerRightArrowImage,
      org.actionstep.themes.standard.images.ASHighlightedScrollerRightArrowRep);

    //
    // Browser
    //
    setImage(ASThemeImageNames.NSBrowserBranchImage, 
      org.actionstep.themes.standard.images.ASScrollerRightArrowRep);
    setImage(ASThemeImageNames.NSHighlightedBrowserBranchImage, 
      org.actionstep.themes.standard.images.ASHighlightedScrollerRightArrowRep);

    //
    // Tree
    //
    setImage(ASThemeImageNames.NSTreeBranchImage, 
      org.actionstep.themes.standard.images.ASScrollerRightArrowRep);
    setImage(ASThemeImageNames.NSHighlightedTreeBranchImage, 
      org.actionstep.themes.standard.images.ASHighlightedScrollerRightArrowRep);
    setImage(ASThemeImageNames.NSTreeOpenBranchImage, 
      org.actionstep.themes.standard.images.ASScrollerDownArrowRep);
    setImage(ASThemeImageNames.NSHighlightedTreeOpenBranchImage, 
      org.actionstep.themes.standard.images.ASHighlightedScrollerDownArrowRep);
    
    //
    // Combobox
    //
    setImage(ASThemeImageNames.NSComboBoxDownArrowImage,
      org.actionstep.themes.standard.images.ASScrollerDownArrowRep);
    setImage(ASThemeImageNames.NSHighlightedComboBoxDownArrowImage,
      org.actionstep.themes.standard.images.ASHighlightedScrollerDownArrowRep);

    //
    // Stepper
    //
    setImage(ASThemeImageNames.NSStepperUpArrowImage,
      org.actionstep.themes.standard.images.ASScrollerUpArrowRep);
    setImage(ASThemeImageNames.NSHighlightedStepperUpArrowImage,
      org.actionstep.themes.standard.images.ASHighlightedScrollerUpArrowRep);
    setImage(ASThemeImageNames.NSStepperDownArrowImage,
      org.actionstep.themes.standard.images.ASScrollerDownArrowRep);
    setImage(ASThemeImageNames.NSHighlightedStepperDownArrowImage,
      org.actionstep.themes.standard.images.ASHighlightedScrollerDownArrowRep);

    //
    // Toolbar
    //
    setImage(ASThemeImageNames.NSToolbarSeparatorItemImage,
    	org.actionstep.themes.standard.images.ASToolbarSeparatorItemImageRep);
    setImage(ASThemeImageNames.NSToolbarOverflowImage,
    	org.actionstep.themes.standard.images.ASScrollerRightArrowRep);
    	
    // Sort indicators

    setImage(ASThemeImageNames.NSSortUpIndicatorImage,
      org.actionstep.themes.standard.images.ASSortUpIndicatorRep);
    setImage(ASThemeImageNames.NSSortDownIndicatorImage,
      org.actionstep.themes.standard.images.ASSortDownIndicatorRep);

    // Cursors

    setImage(ASThemeImageNames.NSArrowCursorRepImage, 
      org.actionstep.themes.standard.images.ASArrowCursorRep);
    setImage(ASThemeImageNames.NSResizeUpDownCursorRepImage, 
      org.actionstep.themes.standard.images.ASResizeUpDownCursorRep);
    setImage(ASThemeImageNames.NSResizeUpCursorRepImage, 
      org.actionstep.themes.standard.images.ASResizeUpCursorRep);
    setImage(ASThemeImageNames.NSResizeDownCursorRepImage, 
      org.actionstep.themes.standard.images.ASResizeDownCursorRep);
    setImage(ASThemeImageNames.NSResizeLeftRightCursorRepImage, 
      org.actionstep.themes.standard.images.ASResizeLeftRightCursorRep);
    setImage(ASThemeImageNames.NSResizeRightCursorRepImage, 
      org.actionstep.themes.standard.images.ASResizeRightCursorRep);
    setImage(ASThemeImageNames.NSResizeLeftCursorRepImage,
      org.actionstep.themes.standard.images.ASResizeLeftCursorRep);
    setImage(ASThemeImageNames.NSResizeDiagonalDownCursorRepImage,
      org.actionstep.themes.standard.images.ASResizeDiagonalDownCursorRep);
    setImage(ASThemeImageNames.NSResizeDiagonalUpCursorRepImage, 
      org.actionstep.themes.standard.images.ASResizeDiagonalUpCursorRep);
    setImage(ASThemeImageNames.NSCrosshairCursorRepImage, 
      org.actionstep.themes.standard.images.ASCrosshairCursorRep);

    // Window icons

    setImage(ASThemeImageNames.NSWindowCloseIconRepImage, 
      org.actionstep.themes.standard.images.ASWindowCloseIconRep);
    setImage(ASThemeImageNames.NSWindowMiniaturizeIconRepImage, 
      org.actionstep.themes.standard.images.ASWindowMiniaturizeIconRep);
    setImage(ASThemeImageNames.NSWindowRestoreIconRepImage, 
      org.actionstep.themes.standard.images.ASWindowRestoreIconRep);

    // Progress bar

    setImage(ASThemeImageNames.NSProgressBarIndeterminatePatternRepImage, 
      org.actionstep.themes.standard.images.ASProgressBarIndeterminatePatternRep);
    setImage(ASThemeImageNames.NSProgressBarDeterminatePatternRepImage,
      org.actionstep.themes.standard.images.ASProgressBarDeterminatePatternRep);
    setImage(ASThemeImageNames.NSProgressBarSpinnerRepImage, 
      org.actionstep.themes.standard.images.ASProgressBarSpinnerRep);

    // Menu Items

    setImage(ASThemeImageNames.NSMenuItemOnStateImage,
      org.actionstep.themes.standard.images.ASMenuItemOnStateRep);
    setImage(ASThemeImageNames.NSMenuItemOffStateImage, 
      org.actionstep.themes.standard.images.ASMenuItemOffStateRep);
    setImage(ASThemeImageNames.NSMenuItemMixedStateImage, 
      org.actionstep.themes.standard.images.ASMenuItemMixedStateRep);
    setImage(ASThemeImageNames.NSMenuArrowImage, 
      org.actionstep.themes.standard.images.ASMenuArrowRep);
    setImage(ASThemeImageNames.NSHighlightedMenuArrowImage, 
      org.actionstep.themes.standard.images.ASHighlightedMenuArrowRep);
      
    // Movie Controller
    
    setImage(ASThemeImageNames.NSMovieControllerPlayRepImage,
      org.actionstep.themes.standard.images.ASMovieControllerPlayRep);
    setImage(ASThemeImageNames.NSMovieControllerPauseRepImage,
      org.actionstep.themes.standard.images.ASMovieControllerPauseRep);

    // Modifier glyphs

    setImage(ASThemeImageNames.NSGlyphControlRepImage, 
      org.actionstep.themes.standard.images.glyphs.ASControlRep);
    setImage(ASThemeImageNames.NSGlyphAlternateRepImage, 
      org.actionstep.themes.standard.images.glyphs.ASAlternateRep);
      
    // Colors
    
    setImage(ASThemeImageNames.NSColorSwatchRepImage,
      org.actionstep.themes.standard.images.ASColorSwatchRep);
    setImage(ASThemeImageNames.NSColorCrayonRepImage,
      org.actionstep.themes.standard.images.ASColorCrayonRep);
  }
  
  public function setImage(name:String, klass:Function):Void {
    setImageWithRep(name, new klass());
  }
  
  public function setImageWithRep(name:String, rep:NSImageRep):Void {
    var image:NSImage = (new NSImage()).init();
    image.setName(name);
    image.addRepresentation(rep);
  }
}