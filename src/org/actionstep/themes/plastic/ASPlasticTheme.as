/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASDraw;
import org.actionstep.ASList;
import org.actionstep.ASTextEditor;
import org.actionstep.constants.NSControlSize;
import org.actionstep.constants.NSTextFieldBezelStyle;
import org.actionstep.graphics.ASBrush;
import org.actionstep.graphics.ASGradient;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.graphics.ASGraphicUtils;
import org.actionstep.graphics.ASLinearGradient;
import org.actionstep.NSColor;
import org.actionstep.NSRect;
import org.actionstep.NSTextFieldCell;
import org.actionstep.NSView;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.ASThemeImageNames;
import org.actionstep.themes.plastic.images.ASHighlightedRadioButtonRep;
import org.actionstep.themes.plastic.images.ASHighlightedSwitchRep;
import org.actionstep.themes.plastic.images.ASRadioButtonRep;
import org.actionstep.themes.plastic.images.ASSwitchRep;
import org.actionstep.themes.standard.ASStandardTheme;

import flash.filters.GlowFilter;
import flash.geom.Matrix;

/**
 * @author Scott Hyndman
 */
class org.actionstep.themes.plastic.ASPlasticTheme extends ASStandardTheme {

	private var m_firstResponderFilter:GlowFilter;
	
	//******************************************************
	//*                    Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASPlasticTheme</code> class.
	 */
	public function ASPlasticTheme() {
		m_firstResponderFilter = new GlowFilter(m_firstResponderColor.value,
			m_firstResponderColor.alphaValue, 7, 7, 1.0, 3, true, false);
	}
	
	//******************************************************
	//*                   First responder
	//******************************************************
	
	public function drawFirstResponderWithRectInView(rect:NSRect, view:NSView):Void {
		var mc:MovieClip = view.mcBounds();
		var curFilters:Array = mc.filters;
		curFilters.push(m_firstResponderFilter);
		mc.filters = curFilters;
	}
  
	//******************************************************
	//*                   Buttons
	//******************************************************

//		var bc:MovieClip = _root.createEmptyMovieClip("buttonClip", 1);
//		var matrix:Matrix = new Matrix();
//		matrix.createGradientBox(100, 21, ASDraw.getRadiansByDegrees(-103), 0, 3);
//		bc.beginGradientFill("linear", [0xB5B2AA, 0xEFEEEC], [100, 100], [0, 100], matrix);
//		ASDraw.outlineCornerRectWithRect(bc, new NSRect(0, 0, 100, 21), 3, 0x808080);
//		bc.endFill();
//
//		var glow:GlowFilter = new GlowFilter(0x999999, 30, 12, 7, .56, 2, true, false);
//		bc.filters = [glow];
//		bc._x = bc._y = 10;
//	/**
//	 * Draws a button border of the provided cell.
//	 */
//	public function drawButtonCellBorderInRectOfView(cell:NSButtonCell,
//			rect:NSRect, view:NSView):Void {
//		var mask:Number;
//		var highlighted:Boolean = cell.isHighlighted();
//		if (highlighted) {
//			mask = cell.highlightsBy();
//			if (cell.state() == 1) {
//				mask &= ~cell.showsStateBy();
//			}
//		} else if (cell.state() == 1) {
//			mask = cell.showsStateBy();
//		} else {
//			mask = NSCell.NSNoCellMask;
//		}
//
//		if (cell.isBezeled()) {
//			switch(cell.bezelStyle()) {
//				case NSBezelStyle.NSRoundedBezelStyle:
//
//
//				case NSBezelStyle.NSDisclosureBezelStyle:
//				case NSBezelStyle.NSCircularBezelStyle:
//				case NSBezelStyle.NSHelpButtonBezelStyle:
//				// ^-- above not implemented --^
//				//		 fall through to default
//				case NSBezelStyle.NSThickSquareBezelStyle:
//				case NSBezelStyle.NSThickerSquareBezelStyle:
//				case NSBezelStyle.NSRegularSquareBezelStyle:
//					//
//					// Determine the border thickness
//					//
//					var thickness:Number;
//					switch (cell.bezelStyle()) {
//						case NSBezelStyle.NSRegularSquareBezelStyle:
//							thickness = 2;
//							break;
//						case NSBezelStyle.NSThickSquareBezelStyle:
//							thickness = 3;
//							break;
//						case NSBezelStyle.NSThickerSquareBezelStyle:
//							thickness = 4;
//							break;
//					}
//
//					if (cell.isEnabled()) {
//						if (highlighted || (mask & (
//								NSCell.NSChangeGrayCellMask |
//								NSCell.NSChangeBackgroundCellMask))) {
//							drawButtonDown(view.mcBounds(), rect);
//						} else {
//							drawButtonUp(view.mcBounds(), rect);
//						}
//					} else {
//						if (highlighted || (mask & (
//								NSCell.NSChangeGrayCellMask |
//								NSCell.NSChangeBackgroundCellMask))) {
//							drawButtonDownDisabled(view.mcBounds(), rect);
//						} else {
//							drawButtonUpDisabled(view.mcBounds(), rect);
//						}
//					}
//
//					break;
//
//				case NSBezelStyle.NSShadowlessSquareBezelStyle:
//					if (cell.isEnabled()) {
//						if (highlighted || (mask & (
//								NSCell.NSChangeGrayCellMask |
//								NSCell.NSChangeBackgroundCellMask))) {
//							drawButtonDownWithoutBorder(view.mcBounds(), rect);
//						} else {
//							drawButtonUpWithoutBorder(view.mcBounds(), rect);
//						}
//					} else {
//						if (highlighted || (mask & (
//								NSCell.NSChangeGrayCellMask |
//								NSCell.NSChangeBackgroundCellMask))) {
//							drawButtonDownDisabledWithoutBorder(view.mcBounds(), rect);
//						} else {
//							drawButtonUpDisabledWithoutBorder(view.mcBounds(), rect);
//						}
//					}
//
//					break;
//			}
//		} else if (cell.isBordered()) {
//			if (cell.isEnabled()) {
//				drawBorderButtonUp(view.mcBounds(), rect);
//			} else {
//				drawBorderButtonDown(view.mcBounds(), rect);
//			}
//		}
//	}
//
//	private static var drawButtonUp_outlineColors:Array = [0x82858E, 0xD3D6DB];
//	private static var drawButtonUp_inlineColors:Array	= [0xDFE2E9, 0x858992];
//	private static var drawButtonUp_colors:Array = [0xEEF2F5, 0xC7CAD1, 0xC7CAD1, 0x858992];
//	private static var drawButtonUp_ratios:Array = [1, 5, 23, 26];
//	private function drawButtonUp(mc:MovieClip, rect:NSRect)
//	{
//		drawButtonUpWithoutBorder(mc, rect.insetRect(1,1));
//		ASDraw.outlineRectWithRect( mc, rect, drawButtonUp_outlineColors);
//	}
//
//	private function drawButtonUpWithoutBorder(mc:MovieClip, rect:NSRect)
//	{
//		ASDraw.gradientRectWithRect(mc, rect, ASDraw.ANGLE_TOP_TO_BOTTOM, drawButtonUp_colors, drawButtonUp_ratios);
//		ASDraw.outlineRectWithRect( mc, rect, drawButtonUp_inlineColors);
//	}
//
//	private static var drawButtonDown_outlineColors:Array = [0x82858E, 0xECEDF0];
//	private static var drawButtonDown_inlineColors:Array = [0x696F79, 0xD4D6DB];
//	private static var drawButtonDown_colors:Array = [0x696F79, 0xB1B5BC, 0xB1B5BC, 0xD9DBDF, 0xC9CDD2];
//	private static var drawButtonDown_ratios:Array = [1, 5, 23, 25, 26];
//	private function drawButtonDown(mc:MovieClip, rect:NSRect,
//			thickness:Number):Void {
//		drawButtonDownWithoutBorder(mc, rect.insetRect(thickness, thickness));
//		ASDraw.outlineRectWithRect( mc, rect, drawButtonDown_outlineColors);
//	}
//
//	private static var drawButtonUpDisabled_outlineAlphas:Array = [50, 50];
//	private static var drawButtonUpDisabled_inlineAlphas:Array	= [50, 50];
//	private static var drawButtonUpDisabled_alphas:Array = [50, 50, 50, 50];
//	public function drawButtonUpDisabled(mc:MovieClip, rect:NSRect)
//	{
//		drawButtonUpDisabledWithoutBorder(mc, rect.insetRect(1,1));
//		ASDraw.outlineRectWithAlphaRect( mc, rect, drawButtonUp_outlineColors, drawButtonUpDisabled_outlineAlphas);
//	}
//
//	public function drawButtonUpDisabledWithoutBorder(mc:MovieClip, rect:NSRect)
//	{
//		ASDraw.gradientRectWithAlphaRect(mc, rect, ASDraw.ANGLE_TOP_TO_BOTTOM,
//			drawButtonUp_colors, drawButtonUp_ratios, drawButtonUpDisabled_alphas);
//		ASDraw.outlineRectWithAlphaRect( mc, rect, drawButtonUp_inlineColors, drawButtonUpDisabled_inlineAlphas);
//	}
//
//	private function drawButtonDownWithoutBorder(mc:MovieClip, rect:NSRect)
//	{
//		ASDraw.gradientRectWithRect(mc, rect, ASDraw.ANGLE_TOP_TO_BOTTOM, drawButtonDown_colors, drawButtonDown_ratios);
//		ASDraw.outlineRectWithRect( mc, rect, drawButtonDown_inlineColors);
//	}
//
//	private static var drawButtonDownDisabled_outlineAlphas:Array = [50,50];
//	private static var drawButtonDownDisabled_inlineAlphas:Array  = [50,50];
//	private static var drawButtonDownDisabled_alphas:Array  = [50,50, 50, 50, 50];
//	public function drawButtonDownDisabled(mc:MovieClip, rect:NSRect)
//	{
//		drawButtonDownDisabledWithoutBorder(mc, rect.insetRect(1,1));
//		ASDraw.outlineRectWithAlphaRect( mc, rect, drawButtonDown_outlineColors, drawButtonDownDisabled_outlineAlphas);
//	}
//
//	public function drawButtonDownDisabledWithoutBorder(mc:MovieClip, rect:NSRect)
//	{
//		ASDraw.gradientRectWithAlphaRect(mc, rect, ASDraw.ANGLE_TOP_TO_BOTTOM,
// 			drawButtonDown_colors, drawButtonDown_ratios, drawButtonDownDisabled_alphas);
//		ASDraw.outlineRectWithAlphaRect( mc, rect, drawButtonDown_inlineColors, drawButtonDownDisabled_inlineAlphas);
//	}

	//******************************************************
	//*                  Text fields
	//******************************************************
	
	public function drawTextFieldCellInRectOfView(cell:NSTextFieldCell, rect:NSRect, view:NSView):Void {
		var g:ASGraphics = view.graphics();
		var bg:NSColor = null;
		
		if (cell.drawsBackground()) {
			bg = cell.backgroundColor();
			if (bg == null) {
				bg = ASColors.whiteColor();
			}
			
			g.brushDownWithBrush(bg);
		}
		
		if (cell.isBezeled()) {
			//
			// Get colors
			//
			// FIXME get these into the theme
			//
			var innerX:NSColor = new NSColor(0xD5DDDD);
			var innerMinY:NSColor = new NSColor(0xC4CCCC);
			var innerMaxY:NSColor = new NSColor(0xEEEEEE);
			var outerX:NSColor = new NSColor(0x919999);
			var outerMinY:NSColor = new NSColor(0x6F7777);
			var outerMaxY:NSColor = innerX;
			
			if (!cell.isEnabled()) {
				innerX = innerX.adjustColorBrightnessByFactor(1.1);
				innerMinY = innerMinY.adjustColorBrightnessByFactor(1.1);
				innerMaxY = innerMaxY.adjustColorBrightnessByFactor(1.1);
				outerX = outerX.adjustColorBrightnessByFactor(1.1);
				outerMinY = outerMinY.adjustColorBrightnessByFactor(1.1);
			}
			
			switch (cell.bezelStyle()) {
				case NSTextFieldBezelStyle.NSTextFieldSquareBezel:
					drawSquareBezelWithGraphicsInRect(g, rect, outerX, innerX,
						innerMinY, outerMinY, innerMaxY, bg);
					break;
					
				case NSTextFieldBezelStyle.NSTextFieldRoundedBezel:
					g.drawRoundedRectWithRect(rect.insetRect(1, 2), 5,
						innerX, 1);
					g.brushUp();
					
					var matrix:Matrix = new Matrix();
					matrix.createGradientBox(rect.size.width, rect.size.height,
						ASGraphicUtils.convertDegreesToRadians(
							ASGradient.ANGLE_TOP_TO_BOTTOM),
							-rect.size.width / 2, -rect.size.height / 2);
					var pen:ASLinearGradient = new ASLinearGradient(
						[outerMinY, innerMaxY], [0, 255], matrix);
					g.drawRoundedRectWithRect(rect, 5.2, pen, 1);
					
					break;
			}
		} 
		else if (cell.isBordered()) {
			g.drawRectWithRect(rect, ASColors.blackColor(), 1);
		} else {
			g.drawRectWithRect(rect, null, 0);
		}
		
		g.brushUp();
	}
	
	//******************************************************
	//*                    Lists
	//******************************************************
	
	public function drawListSelectionWithRectInView(rect:NSRect, aView:NSView):Void {
		ASDraw.solidCornerRectWithRect(aView.mcBounds(), 
			rect, 
			0,
			0x0000A0); 
	}
	
	public function drawListWithRectInView(rect:NSRect, view:ASList):Void {
		//
		// FIXME get these into the theme
		//
		var innerX:NSColor = new NSColor(0xD5DDDD);
		var innerMinY:NSColor = new NSColor(0xC4CCCC);
		var innerMaxY:NSColor = new NSColor(0xEEEEEE);
		var outerX:NSColor = new NSColor(0x919999);
		var outerMinY:NSColor = new NSColor(0x6F7777);
		var outerMaxY:NSColor = innerX;
		var bg:NSColor = view.drawsBackground() ? view.backgroundColor() : ASColors.whiteColor();
		
		drawSquareBezelWithGraphicsInRect(view.graphics(), rect,
			outerX, innerX, innerMinY, outerMinY, innerMaxY, bg);
	}
	
	//******************************************************
	//*                 Text editor
	//******************************************************
	
	public function drawTextEditorWithRectInView(rect:NSRect, view:ASTextEditor):Void {
		//
		// FIXME get these into the theme
		//
		var innerX:NSColor = new NSColor(0xD5DDDD);
		var innerMinY:NSColor = new NSColor(0xC4CCCC);
		var innerMaxY:NSColor = new NSColor(0xEEEEEE);
		var outerX:NSColor = new NSColor(0x919999);
		var outerMinY:NSColor = new NSColor(0x6F7777);
		var outerMaxY:NSColor = innerX;
		var bg:NSColor = view.drawsBackground() ? view.backgroundColor() : ASColors.whiteColor();
		
		drawSquareBezelWithGraphicsInRect(view.graphics(), rect,
			outerX, innerX, innerMinY, outerMinY, innerMaxY, bg);
	}
	
	//******************************************************
	//*                  Scrollers
	//******************************************************
	
	public function drawScrollerSlotWithRectInView(rect:NSRect, view:NSView):Void {
		ASDraw.gradientRectWithRect(view.mcBounds(), 
			rect, 
			ASDraw.ANGLE_LEFT_TO_RIGHT,
			[0xE0E0E0, 0xF8F8F8],
			[30, 145]);
	}
	
	public function scrollerWidth():Number {
		return 18;
	}
	
	public function scrollerButtonWidth():Number {
		return 16;
	}
  
	//******************************************************
	//*                    Images
	//******************************************************

	public function registerDefaultImages():Void {
		super.registerDefaultImages();
		
		//
		// Radio button
		//
		setImageWithRep(ASThemeImageNames.NSRegularRadioButtonImage,
			new ASRadioButtonRep(NSControlSize.NSRegularControlSize));
		setImageWithRep(ASThemeImageNames.NSRegularHighlightedRadioButtonImage,
			new ASHighlightedRadioButtonRep(NSControlSize.NSRegularControlSize));
		setImageWithRep(ASThemeImageNames.NSSmallRadioButtonImage,
			new ASRadioButtonRep(NSControlSize.NSSmallControlSize));
		setImageWithRep(ASThemeImageNames.NSSmallHighlightedRadioButtonImage,
			new ASHighlightedRadioButtonRep(NSControlSize.NSSmallControlSize));
		setImageWithRep(ASThemeImageNames.NSMiniRadioButtonImage,
			new ASRadioButtonRep(NSControlSize.NSMiniControlSize));
		setImageWithRep(ASThemeImageNames.NSMiniHighlightedRadioButtonImage,
			new ASHighlightedRadioButtonRep(NSControlSize.NSMiniControlSize));
		
		//
		// Checkbox
		//
		setImageWithRep(ASThemeImageNames.NSRegularSwitchImage,
			new ASSwitchRep(NSControlSize.NSRegularControlSize));
		setImageWithRep(ASThemeImageNames.NSRegularHighlightedSwitchImage,
			new ASHighlightedSwitchRep(NSControlSize.NSRegularControlSize));
		setImageWithRep(ASThemeImageNames.NSSmallSwitchImage,
			new ASSwitchRep(NSControlSize.NSSmallControlSize));
		setImageWithRep(ASThemeImageNames.NSSmallHighlightedSwitchImage,
			new ASHighlightedSwitchRep(NSControlSize.NSSmallControlSize));
		setImageWithRep(ASThemeImageNames.NSMiniSwitchImage,
			new ASSwitchRep(NSControlSize.NSMiniControlSize));
		setImageWithRep(ASThemeImageNames.NSMiniHighlightedSwitchImage,
			new ASHighlightedSwitchRep(NSControlSize.NSMiniControlSize));
				
		//
		// ComboBox
		//
		setImage(ASThemeImageNames.NSComboBoxDownArrowImage, 
			org.actionstep.themes.plastic.images.ASScrollerDownArrowRep);
		setImage(ASThemeImageNames.NSHighlightedComboBoxDownArrowImage,
			org.actionstep.themes.plastic.images.ASHighlightedScrollerDownArrowRep);

		//
		// Slider
		//
		setImage(ASThemeImageNames.NSRegularSliderRoundThumbRepImage, 
			org.actionstep.themes.plastic.images.ASSliderRoundThumbRep);
		setImage(ASThemeImageNames.NSRegularSliderLinearVerticalThumbRepImage,
			org.actionstep.themes.standard.images.ASSliderLinearVerticalThumbRep);
		setImage(ASThemeImageNames.NSRegularSliderLinearHorizontalThumbRepImage, 
			org.actionstep.themes.standard.images.ASSliderLinearHorizontalThumbRep);
		setImage(ASThemeImageNames.NSRegularSliderCircularThumbRepImage, 
			org.actionstep.themes.standard.images.ASSliderCircularThumbRep);
      
		//
		// Stepper
		//
		setImage(ASThemeImageNames.NSStepperUpArrowImage, 
			org.actionstep.themes.plastic.images.ASScrollerUpArrowRep);
		setImage(ASThemeImageNames.NSHighlightedStepperUpArrowImage, 
			org.actionstep.themes.plastic.images.ASHighlightedScrollerUpArrowRep);
		setImage(ASThemeImageNames.NSStepperDownArrowImage, 
			org.actionstep.themes.plastic.images.ASScrollerDownArrowRep);
		setImage(ASThemeImageNames.NSHighlightedStepperDownArrowImage, 
			org.actionstep.themes.plastic.images.ASHighlightedScrollerDownArrowRep);

		//
		// Register new scroller arrows
		//
		setImage(ASThemeImageNames.NSScrollerUpArrowImage, 
			org.actionstep.themes.plastic.images.ASScrollerUpArrowRep);
		setImage(ASThemeImageNames.NSHighlightedScrollerUpArrowImage, 
			org.actionstep.themes.plastic.images.ASHighlightedScrollerUpArrowRep);
		setImage(ASThemeImageNames.NSScrollerDownArrowImage, 
			org.actionstep.themes.plastic.images.ASScrollerDownArrowRep);
		setImage(ASThemeImageNames.NSHighlightedScrollerDownArrowImage, 
			org.actionstep.themes.plastic.images.ASHighlightedScrollerDownArrowRep);
		setImage(ASThemeImageNames.NSScrollerLeftArrowImage, 
			org.actionstep.themes.plastic.images.ASScrollerLeftArrowRep);
		setImage(ASThemeImageNames.NSHighlightedScrollerLeftArrowImage, 
			org.actionstep.themes.plastic.images.ASHighlightedScrollerLeftArrowRep);
		setImage(ASThemeImageNames.NSScrollerRightArrowImage, 
			org.actionstep.themes.plastic.images.ASScrollerRightArrowRep);
		setImage(ASThemeImageNames.NSHighlightedScrollerRightArrowImage, 
			org.actionstep.themes.plastic.images.ASHighlightedScrollerRightArrowRep);

		//
		// Browser
		//
		setImage(ASThemeImageNames.NSBrowserBranchImage,
			org.actionstep.themes.plastic.images.ASScrollerRightArrowRep);
		setImage(ASThemeImageNames.NSHighlightedBrowserBranchImage,
			org.actionstep.themes.plastic.images.ASHighlightedScrollerRightArrowRep);
		
		//
		// Tree
		//
		setImage(ASThemeImageNames.NSTreeBranchImage, 
			org.actionstep.themes.plastic.images.ASScrollerRightArrowRep);
		setImage(ASThemeImageNames.NSHighlightedTreeBranchImage, 
			org.actionstep.themes.plastic.images.ASHighlightedScrollerRightArrowRep);
		setImage(ASThemeImageNames.NSTreeOpenBranchImage, 
			org.actionstep.themes.plastic.images.ASScrollerDownArrowRep);
		setImage(ASThemeImageNames.NSHighlightedTreeOpenBranchImage, 
			org.actionstep.themes.plastic.images.ASHighlightedScrollerDownArrowRep);		
	}
	
	//******************************************************
	//*                      Colors
	//******************************************************
	
	public function registerDefaultColors():Void {
		super.registerDefaultColors();
		
		m_colorList.setColorForKey(ASColors.grayColor(),
			ASThemeColorNames.ASDisabledText);
	}
	
	//******************************************************
	//*                  Special drawing
	//******************************************************
	
	public static function drawGelButtonWithRectColorInView(aRect:NSRect, 
			baseColor:NSColor, view:NSView):Void {
		//
		// Aqua button
		//
		var depth:Number = _root.getNextHighestDepth();
		var button:MovieClip = _root.createEmptyMovieClip("button" + depth, depth);
		var upperHl:MovieClip = button.createEmptyMovieClip("upperHl", 1);
		var lowerHl:MovieClip = button.createEmptyMovieClip("lowerHl", 2);
		var base:MovieClip = button.createEmptyMovieClip("base", 0);
		var g:ASGraphics = view.graphics();
		var x:Number = aRect.origin.x;
		var y:Number = aRect.origin.y;
		var w:Number = aRect.size.width;
		var h:Number = aRect.size.height;
		var r:Number = Math.floor(Math.min(w, h) / 2);
		var dx:Number = (w - w * .97) / 2;
		var dy:Number = (h - h * .97) / 2;
		
		//
		// Draw base
		//
		g.brushDownWithBrush(baseColor);
		g.drawRoundedRect(x, y, w, h, r, null, 0);
		g.brushUp();

//		//
//		// Draw upper highlight
//		//
//		var matrix:Matrix = new Matrix();
//		matrix.createGradientBox(w, h / 2, ASDraw.getRadiansByDegrees(90));
//		upperHl.lineStyle(undefined, 0, 100);
//		upperHl.beginGradientFill("linear", [0xFFFFFF, 0xFFFFFF], [70, 0], 
//			[75, 255], matrix);
//		ASDraw.drawRoundedRect(upperHl, 0, 0, w, h, r);
//		upperHl.endFill();
//		upperHl._width -= 2 * dx;
//		upperHl._height -= 2 * dy;
//		upperHl._x = dx;
//		upperHl._y = dy;
//		upperHl.filters = [new BlurFilter(3, 3, 3)];
//		
//		//
//		// Draw lower highlight
//		//
//		matrix = new Matrix();
//		matrix.createGradientBox(w, h / 2, ASDraw.getRadiansByDegrees(90));
//		lowerHl.lineStyle(undefined, 0, 100);
//		lowerHl.beginGradientFill("linear", [0xFFFFFF, 0xFFFFFF], [70, 0], 
//			[20, 155], matrix);
//		ASDraw.drawRoundedRect(lowerHl, 0, 0, w, h, r);
//		lowerHl.endFill();
//		lowerHl._width -= 2 * dx;
//		lowerHl._height -= 5 * dy;
//		lowerHl._x = dx;
//		lowerHl._y = lowerHl._height - dy;
//		lowerHl._yscale *= -1;
//		lowerHl._alpha = 85;
//		lowerHl.blendMode = "overlay";
	}
	
	public static function drawSquareBezelWithGraphicsInRect(g:ASGraphics,
			rect:NSRect, outerX:ASBrush, innerX:ASBrush, innerMinY:ASBrush,
			outerMinY:ASBrush, innerMaxY:ASBrush, bg:ASBrush):Void {
		g.brushDownWithBrush(outerX);
		g.drawRectWithRect(rect, null, 0);
		g.brushUp();
		g.brushDownWithBrush(outerMinY);
		g.drawRect(1, 0, rect.size.width - 2, 1, null, 0);
		g.brushUp();
		g.brushDownWithBrush(innerMinY);
		g.drawRect(1, 1, rect.size.width - 2, 1, null, 0);
		g.brushUp();				
		g.brushDownWithBrush(innerX);
		g.drawRect(1, 2, rect.size.width - 2, rect.size.height - 2, null, 0);
		g.brushUp();
		g.brushDownWithBrush(innerMaxY);
		g.drawRect(1, rect.size.height - 2, rect.size.width - 2, 1, null, 0);
		g.brushUp();
		g.brushDownWithBrush(bg);
		g.drawRect(2, 2, rect.size.width - 4, rect.size.height - 4, null, 0);
		g.brushUp();
	}
}