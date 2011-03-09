/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASDraw;
import org.actionstep.ASTextEditor;
import org.actionstep.constants.NSAnimationCurve;
import org.actionstep.constants.NSBezelStyle;
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSControlSize;
import org.actionstep.constants.NSImageFrameStyle;
import org.actionstep.constants.NSLineBreakMode;
import org.actionstep.constants.NSSliderType;
import org.actionstep.constants.NSTabState;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.constants.NSToolbarDisplayMode;
import org.actionstep.constants.NSToolbarSizeMode;
import org.actionstep.graphics.ASGradient;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.graphics.ASGraphicUtils;
import org.actionstep.graphics.ASLinearGradient;
import org.actionstep.menu.NSMenuView;
import org.actionstep.NSAlert;
import org.actionstep.NSButtonCell;
import org.actionstep.NSCell;
import org.actionstep.NSColor;
import org.actionstep.NSColorList;
import org.actionstep.NSColorWell;
import org.actionstep.NSFont;
import org.actionstep.NSImage;
import org.actionstep.NSParagraphStyle;
import org.actionstep.NSProgressIndicator;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSSliderCell;
import org.actionstep.NSStepperCell;
import org.actionstep.NSTabViewItem;
import org.actionstep.NSTextFieldCell;
import org.actionstep.NSTextView;
import org.actionstep.NSToolbar;
import org.actionstep.NSView;
import org.actionstep.NSWindow;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.ASThemeProtocol;
import org.actionstep.themes.standard.ASStandardThemeBase;

import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import org.actionstep.scroller.ASScrollerButtonCell;
import org.actionstep.NSScroller;

/**
 * <p>This is the default ActionStep theme class.</p>
 *
 * <p>The current theme can be accessed through the {@link #current()} class
 * property, and can be set using {@link #setCurrent()}.</p>
 *
 * <p>When the theme changes, an {@link #ASThemeDidChangeNotification} is
 * posted to the default notification center.</p>
 *
 * @author Scott Hyndman
 * @author Rich Kilmer
 */
class org.actionstep.themes.standard.ASStandardTheme extends ASStandardThemeBase 
	implements ASThemeProtocol {
	
  //******************************************************
  //*                    Members
  //******************************************************

  private var m_firstResponderColor:NSColor;
  
  //******************************************************
  //*                   Construction
  //******************************************************

  /**
   * Constructs a new instance of ASTheme.
   */
  public function ASStandardTheme() {
    m_firstResponderColor = new NSColor(0x3333dd);
    m_firstResponderColor.alphaValue = 40;
    m_colorList = (new NSColorList()).initWithName("ASTheme");
    registerDefaultColors();
  }

  /**
   * Can perform setup operations in this method
   */
  public function setActive(value:Boolean):Void {
  }

  //******************************************************
  //*                 Public Methods
  //******************************************************

  /**
   * @see org.actionstep.ASThemeProtocol#drawFillWithRectColorInView
   */
  public function drawFillWithRectColorInView(aRect:NSRect, aColor:NSColor,
    inView:NSView):Void
  {
    var g:ASGraphics = inView.graphics();
    g.beginFill(aColor);  
    g.drawRectWithRect(aRect, null, null);
    g.endFill();
  }

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
  public function dimImageCanvasInViewWithFactor(image:NSImage, view:NSView, 
      factor:Number):Void {
    var mc:MovieClip = image.lastCanvas();
    if (mc == null || mc == view.mcBounds()) {
      return;
    }
    
    var matrix:Array = new Array();
    matrix = matrix.concat([factor, factor, factor, factor, 0]); // red
    matrix = matrix.concat([factor, factor, factor, factor, 0]); // green
    matrix = matrix.concat([factor, factor, factor, factor, 0]); // blue
    matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
    var cmf:ColorMatrixFilter = new ColorMatrixFilter(matrix);
    mc.filters = [cmf];
  }
	
  //******************************************************
  //*                     Lists
  //******************************************************

  /**
   * Draws the the ASList background
   */
  public function drawListWithRectInView(rect:NSRect, view:NSView):Void {
    var mc:MovieClip = view.mcBounds();
    var topShadowRect:NSRect  = ASDraw.getScaledPixelRect(rect, rect.size.width-20, 
    	0, -rect.size.width+3, -2);
    drawTextfield(mc, rect);
  }

  public function drawListSelectionWithRectInView(rect:NSRect, aView:NSView):Void {
    ASDraw.gradientRectWithAlphaRect(aView.mcBounds(),
      rect,
      ASDraw.ANGLE_LEFT_TO_RIGHT,
      [0x494D56, 0x494D56, 0x494D56, 0x494D56],
      [265,373,413,430],
      [40,40,0,0]);
  }

  //******************************************************
  //*                    NSAlert
  //******************************************************
	
  function buttonTextColorForAlert(alert:NSAlert):NSColor {
  	return ASColors.blackColor();
  }
	
  //******************************************************
  //*                    Drawers
  //******************************************************

  /**
   * <p>Draws the drawer.</p>
   */
  public function drawDrawerWithRectInView(aRect:NSRect, view:NSView):Void {
    var g:ASGraphics = view.graphics();

    aRect = aRect.insetRect(1, 1);
    g.beginFill(ASColors.whiteColor());
    g.drawCutCornerRectWithRect(aRect, 5, null, 0);
    g.endFill();
    g.beginFill(new NSColor(0xCDCDCD));
    g.drawCutCornerRectWithRect(aRect.insetRect(5, 5), 3, null, 0);
    g.endFill();
    g.drawCutCornerRectWithRect(aRect, 5, ASColors.blackColor(), 1);
  }

  /**
   * Returns the amount of time (in milliseconds) the drawer takes to open.
   */
  public function drawerOpenDuration():Number {
    return 500;
  }

  /**
   * Returns the amount of time (in milliseconds) the drawer takes to close.
   */
  public function drawerCloseDuration():Number {
    return 500;
  }

  /**
   * Returns the function the drawer uses to ease open.
   */
  public function drawerEaseOpenFunction():Function {
    return ASDraw.easeInOutQuad;
  }

  /**
   * Returns the function the drawer uses to ease close.
   */
  public function drawerEaseCloseFunction():Function {
    return ASDraw.easeInOutQuad;
  }

  /**
   * Returns the width of the drawer's borders.
   */
  function drawerBorderWidth():Number {
    return 10;
  }

  //******************************************************
  //*                   Image Views
  //******************************************************

  /**
   * Draws an image frame in the view <code>view</code>, bounded by the
   * rectangle <code>rect</code> with a frame style of <code>style</code>.
   */
  public function drawImageFrameWithRectInViewStyle(rect:NSRect, view:NSView,
      style:NSImageFrameStyle):Void {

    var mc:MovieClip = view.mcBounds();
    switch (style)
    {
      case NSImageFrameStyle.NSImageFrameNone:
        // do nothing
        break;
      case NSImageFrameStyle.NSImageFramePhoto:
        ASDraw.drawRect(mc, rect.origin.x, rect.origin.y,
          rect.size.width, rect.size.height, 0x000000);
        // FIXME Add shadow
        break;
      case NSImageFrameStyle.NSImageFrameButton:
        ASDraw.outlineRectWithRect(mc, rect,
          [0xBEBEBE, 0x7D7D7D, 0x7D7D7D, 0xBEBEBE]);
        break;
      case NSImageFrameStyle.NSImageFrameGrayBezel:
        ASDraw.outlineRectWithRect(mc, rect,
          [0x353535, 0xE7E7E7, 0xE7E7E7, 0x353535]);
        break;
      case NSImageFrameStyle.NSImageFrameGroove:
        // TODO make this look decent.
        //ASDraw.drawRectWithRect(mc, rect, 0xDDDDDD);
        ASDraw.outlineRectWithThickness(mc,
          rect.origin.x+3,
          rect.origin.y+3,
          rect.size.width -3,
          rect.size.height - 3,
          [0xDDDDDD], 2);
        ASDraw.outlineRectWithThickness(mc,
          rect.origin.x,
          rect.origin.y,
          rect.size.width-3,
          rect.size.height-3,
          [0x333333], 2);
        break;
    }
  }
  
  //******************************************************
  //*                 NSColorWell
  //******************************************************
  
  public function drawColorWellBorderWithRectInWell(rect:NSRect,
      well:NSColorWell):Number {
    
    var drawRect:NSRect = rect;
    var g:ASGraphics = well.graphics();
    var mc:MovieClip = g.clip();
        
    if (well.isBordered()) {
	    //
	    // Draw button border
	    //
	    drawButtonUp(mc, rect);
	    
	    //
	    // Draw some solids
	    //
	    drawRect = drawRect.insetRect(2, 2);
	    if (well.isActive()) {
	    	g.brushDownWithBrush(ASColors.whiteColor());
	    } else {
	    	g.brushDownWithBrush(ASColors.lightGrayColor());
	    }    
	    g.drawRectWithRect(drawRect);
	    g.brushUp();	    
    }
        
    //
    // Draw inner border
    //
    if (well.isEnabled()) {
    	var dark:NSColor = ASColors.darkGrayColor();
    	var light:NSColor = ASColors.lightGrayColor();
		g.brushDownWithBrush(dark);
		g.drawRectWithRect(drawRect.insetRect(1, 1));
		g.brushUp();
        drawRect = drawRect.insetRect(2, 2);
    } else {
		drawRect = drawRect.insetRect(1, 1);	
    }
        
	return Math.ceil((rect.size.width - drawRect.size.width) / 2);
  }
    
  //******************************************************
  //*                  ToolTips
  //******************************************************

  public function drawToolTipWithRectInView(rect:NSRect, view:NSView):Void {
    var g:ASGraphics = view.graphics();

	g.drawRectWithRect(rect, colorWithName(ASThemeColorNames.ASToolTipBorder), 1);
	g.beginFill(colorWithName(ASThemeColorNames.ASToolTipBackground));
    g.drawRectWithRect(rect.insetRect(1, 1), null, 0);
    g.endFill();
  }

  public function toolTipStyleCss():String {
  	var fnt:NSFont = toolTipsFontOfSize(0);
    return
    "tipText {" +
    "  font-family: " + fnt.fontName() + ";" +
    "  font-size: " + fnt.pointSize() + ";" +
    "}";
  }
  
  public function isToolTipFontEmbedded():Boolean {
    return toolTipsFontOfSize(0).isEmbedded();
  }

  public function toolTipInitialDelay():Number {
    return 0.5;
  }

  public function toolTipAutoPopDelay():Number {
    return 5;
  }

  public function toolTipSwf():String {
    return null;
  }

  //******************************************************
  //*                    Sliders
  //******************************************************

  public function sliderTrackWidthWithControlSize(size:NSControlSize):Number {
    var w:Number;
    switch (size) {
      case NSControlSize.NSMiniControlSize:
        w = 4;
        break;
        
      case NSControlSize.NSSmallControlSize:
        w = 5;
        break;
                
      case NSControlSize.NSRegularControlSize:
        w = 7;
        break;
    }
      
    return w;
  }

  public function sliderTickLengthWithControlSize(size:NSControlSize):Number {
    var l:Number;
    switch (size) {
      case NSControlSize.NSMiniControlSize:
        l = 5;
        break;
        
      case NSControlSize.NSSmallControlSize:
        l = 7;
        break;
                
      case NSControlSize.NSRegularControlSize:
        l = 10;
        break;
    }
      
    return l;
  }

  /**
   * Returns the width of the track used by an <code>NSSlider</code>.
   */
  public function sliderThumbSizeWithSliderCellControlSize(cell:NSSliderCell, 
      size:NSControlSize):NSSize {
    var sz:NSSize = null;
    if (cell.sliderType() == NSSliderType.NSCircularSlider) {
      
      switch (cell.controlSize()) {
        case NSControlSize.NSSmallControlSize:
        case NSControlSize.NSMiniControlSize:
          sz = new NSSize(26, 26);
          break;
        
        case NSControlSize.NSRegularControlSize:
          sz = new NSSize(32, 32);
          break;
      }
    } else {

      switch (cell.controlSize()) {
        case NSControlSize.NSMiniControlSize:
          sz = new NSSize(12, 12);
          break;
          
        case NSControlSize.NSSmallControlSize:
          sz = new NSSize(15, 15);
          break;
                  
        case NSControlSize.NSRegularControlSize:
          sz = new NSSize(21, 21);
          break;
      }
    }
    
    return sz;
  }
    	
  public function drawSliderCellTrackWithRectInView(cell:NSSliderCell,
      aRect:NSRect, view:NSView):Void {
    var vert:Boolean = aRect.size.height >= aRect.size.width;
    var mc:MovieClip = view.mcBounds();
    var c1:NSColor = colorWithName(ASThemeColorNames.ASSliderBarColor);
    var c2:NSColor = c1.adjustColorBrightnessByFactor(1.3);
    var rot:Number = vert ? ASGradient.ANGLE_LEFT_TO_RIGHT : ASGradient.ANGLE_TOP_TO_BOTTOM;
    rot = ASGraphicUtils.convertDegreesToRadians(rot);
    
    var matrix:Matrix = new Matrix();
    matrix.createGradientBox(aRect.size.width, aRect.size.height, rot, 0, 0);
    var brush:ASLinearGradient = new ASLinearGradient([c1, c2], [0, 255], matrix);
    var g:ASGraphics = view.graphics();
    g.brushDownWithBrush(brush);
    g.drawRoundedRectWithRect(aRect, 3, null, 0);
    g.brushUp();
  }

  public function drawCircularSliderCellWithRectInView(cell:NSSliderCell,
      aRect:NSRect, view:NSView):Void {
    var mc:MovieClip = view.mcBounds();
    aRect = aRect.insetRect(1, 1);

    ASDraw.gradientEllipseWithRect(mc, aRect,
      [0xEDEDED, 0xEDEDED],
      [0, 255]);

    var highlightRect:NSRect = new NSRect(aRect.origin.x + aRect.size.width / 4,
      aRect.origin.y + 3, aRect.size.width / 2, aRect.height() / 3);
    ASDraw.gradientEllipseWithRect(mc, highlightRect,
      [0xFBFBFB, 0xFBFBFB],
      [0, 255]);

    mc.lineStyle(1, 0x000000, 100);
    ASDraw.drawEllipseWithRect(mc, aRect);
  }

  public function drawLinearSliderCellTickWithRectInView(
      cell:NSSliderCell, aRect:NSRect, view:NSView):Void {
    var g:ASGraphics = view.graphics();

    if (cell.isVertical()) {
      aRect = aRect.insetRect(0, (aRect.size.height - 2) / 2);
    } else {
      aRect = aRect.insetRect((aRect.size.width - 2) / 2, 0);
    }

    var lg:NSColor = new NSColor(0xDDDDDD);
    g.drawRectWithRect(aRect, lg, 1);
    g.drawRectWithRect(
      new NSRect(aRect.origin.x+1, aRect.origin.y+1, aRect.size.width, aRect.size.height),
      lg, 1);
    g.drawRectWithRect(
      new NSRect(aRect.origin.x, aRect.origin.y, aRect.size.width-1, aRect.size.height-1),
      new NSColor(0x333333), 1);
  }

  public function drawCircularSliderCellTickWithRectLengthAngleInView(
      cell:NSSliderCell, rect:NSRect, length:Number, angle:Number, 
      view:NSView):Void {

  }

  //******************************************************
  //*                    Windows
  //******************************************************

  public function drawResizingWindowWithRectInView(aRect:NSRect, view:NSView):Void {
    var mc:MovieClip = view.mcBounds();
    var x:Number = aRect.origin.x;
    var y:Number = aRect.origin.y;
    var w:Number = aRect.size.width;
    var h:Number = aRect.size.height;

    var g:ASGraphics = view.graphics();
    g.beginFill(NSColor.colorWithHexValueAlpha(0xDDDDDD, 40));
    g.drawRectWithRect(aRect, new NSColor(0x888888), 1);
    g.endFill();
  }

  public function drawWindowTitleBarWithRectInViewIsKey(aRect:NSRect,
      view:NSView, isKey:Boolean):Void {

    var fillColors:Array = isKey ? [0xFFFFFF, 0xDEDEDE, 0xC6C6C6] : [0xFFFFFF, 0xDEDEDE, 0xFFFFFF];
    var fillAlpha:Number = 100;
    var cornerRadius:Number = 4;
    var x:Number = aRect.origin.x;
    var y:Number = aRect.origin.y;
    var width:Number = aRect.size.width;
    var height:Number = aRect.size.height;

    with (view.mcBounds()) {
      lineStyle(1.5, 0x8E8E8E, 100);
      beginGradientFill("linear", fillColors, [100,100,100], [0, 50, 255],
        {matrixType:"box", x:x,y:y,w:width,h:height,r:(.5*Math.PI)});
      moveTo(x+cornerRadius, y);
      lineTo(x+width-cornerRadius, y);
      lineTo(x+width, y+cornerRadius); //Angle
      lineTo(x+width, y+height);
      lineStyle(1.5, 0x6E6E6E, 100);
      lineTo(x, y+height);
      lineStyle(1.5, 0x8E8E8E, 100);
      lineTo(x, y+cornerRadius);
      lineTo(x+cornerRadius, y); //Angle
      endFill();
    }
  }
  
  /**
   * Returns the height of a window's title bar.
   */
  public function windowTitleBarHeight():Number {
    return 22;
  }

  /**
   * Returns the amount of time <code>wnd</code>'s resize animation should
   * take. The time should be expressed in seconds.
   */
  public function windowAnimationResizeTime(wnd:NSWindow):Number {
    return 0.2;
  }
  
  /**
   * Returns the animation curve of <code>wnd</code>'s resize animation.
   */
  public function windowAnimationResizeCurve(wnd:NSWindow):NSAnimationCurve {
    return NSAnimationCurve.NSEaseInOut;
  }

  //******************************************************
  //*                   Buttons
  //******************************************************

  /**
   * Draws a button border of the provided type and style
   */
  function drawButtonCellBorderInRectOfView(cell:NSButtonCell, rect:NSRect, view:NSView):Void {
    var mask:Number;
    var highlighted:Boolean = cell.isHighlighted();
    if (highlighted) {
      mask = cell.highlightsBy();
      if (cell.state() == 1) {
        mask &= ~cell.showsStateBy();
      }
    } else if (cell.state() == 1) {
      mask = cell.showsStateBy();
    } else {
      mask = NSCell.NSNoCellMask;
    }

    if (cell.isBezeled()) {
      switch(cell.bezelStyle()) {
        case NSBezelStyle.NSRoundedBezelStyle:
        case NSBezelStyle.NSThickSquareBezelStyle:
        case NSBezelStyle.NSThickerSquareBezelStyle:
        case NSBezelStyle.NSDisclosureBezelStyle:
        case NSBezelStyle.NSCircularBezelStyle:
        case NSBezelStyle.NSHelpButtonBezelStyle:
        // ^-- above not implemented --^
        //     fall through to default
        case NSBezelStyle.NSRegularSquareBezelStyle:
          if (cell.isEnabled()) {
            if (highlighted || (mask & (NSCell.NSChangeGrayCellMask | NSCell.NSChangeBackgroundCellMask))) {
              drawButtonDown(view.mcBounds(), rect);
            } else {
              drawButtonUp(view.mcBounds(), rect);
            }
          } else {
            if (highlighted || (mask & (NSCell.NSChangeGrayCellMask | NSCell.NSChangeBackgroundCellMask))) {
              drawButtonDownDisabled(view.mcBounds(), rect);
            } else {
              drawButtonUpDisabled(view.mcBounds(), rect);
            }
          }
        break;
        case NSBezelStyle.NSShadowlessSquareBezelStyle:
          if (cell.isEnabled()) {
            if (highlighted || (mask & (NSCell.NSChangeGrayCellMask | NSCell.NSChangeBackgroundCellMask))) {
              drawButtonDownWithoutBorder(view.mcBounds(), rect);
            } else {
              drawButtonUpWithoutBorder(view.mcBounds(), rect);
            }
          } else {
            if (highlighted || (mask & (NSCell.NSChangeGrayCellMask | NSCell.NSChangeBackgroundCellMask))) {
              drawButtonDownDisabledWithoutBorder(view.mcBounds(), rect);
            } else {
              drawButtonUpDisabledWithoutBorder(view.mcBounds(), rect);
            }
          }
        break;
      }
    } else if (cell.isBordered()) {
      if (cell.isEnabled()) {
        drawBorderButtonUp(view.mcBounds(), rect);
      } else {
        drawBorderButtonDown(view.mcBounds(), rect);
      }
    }
  }

  /**
   * Draws a button interior of the provided color, type and style
   */
  function drawButtonCellInteriorInRectOfView(cell:NSButtonCell, rect:NSRect, view:NSView):Void {
    //enabled:Boolean, backgroundColor:NSColor, borderType:NSBorderType, bezelStyle:NSBezelStyle
  }

  /**
   * <p>Returns the size of the "switch" image given a cell and a size.</p>
   * 
   * <p>The switch image is also known as the checkbox.</p>
   */
  function switchImageSizeForControlSize(size:NSControlSize):NSSize {
    var sidelen:Number;
    
    switch (size) {
      case NSControlSize.NSMiniControlSize:
        sidelen = 9;
        break;
        
      case NSControlSize.NSSmallControlSize:
        sidelen = 12;
        break;
        
      case NSControlSize.NSRegularControlSize:
      default:
        sidelen = 14;
        break;
    }
    
    return new NSSize(sidelen, sidelen);
  }
    
  /**
   * <p>Returns the size of the "radio" image given a cell and a size.</p>
   */
  function radioImageSizeForControlSize(size:NSControlSize):NSSize {
    var sidelen:Number = 0;
    switch (size) {
      case NSControlSize.NSMiniControlSize:
        sidelen = 10;
        break;
        
      case NSControlSize.NSSmallControlSize:
        sidelen = 13;
        break;
        
      case NSControlSize.NSRegularControlSize:
      default:
        sidelen = 15;
        break;
    }
    
    return new NSSize(sidelen, sidelen);
  }
		

  //******************************************************
  //*                 First Responder
  //******************************************************

  public function firstResponderColor():NSColor {
    return m_firstResponderColor;
  }

  public function drawFirstResponderWithRectInView(rect:NSRect, view:NSView):Void {
  	rect = rect.sizeRectLeftRightTopBottom(1, 1, 2, 2);
    view.graphics().drawRectWithRect(rect, firstResponderColor(), 3);
  }

  public function drawFirstResponderWithRectInClip(rect:NSRect, mc:MovieClip):Void {
  	// FIXME why is this method necessary?
    var x:Number = rect.origin.x+1;
    var y:Number = rect.origin.y+1;
    var width:Number = rect.size.width-3;
    var height:Number = rect.size.height-3;
    var color:Number = firstResponderColor().value;

    mc.lineStyle(3, color, 40);
    mc.moveTo(x, y);
    mc.lineTo(x+width, y);
    mc.lineTo(x+width, y+height);
    mc.lineTo(x, y+height);
    mc.lineTo(x, y);
  }

  //******************************************************
  //*                    Textfields
  //******************************************************
  
	/**
	 * Draws the NSTextFieldCell <code>cell</code>.
	 */
  public function drawTextFieldCellInRectOfView(cell:NSTextFieldCell, 
      rect:NSRect, view:NSView):Void {
    drawTextfield(view.mcBounds(), rect);
  }

  //******************************************************
  //*                     NSStepper
  //******************************************************
	
  public function drawStepperCellBorderInRectOfView(cell:NSStepperCell,
      rect:NSRect, view:NSView):Void {
    drawTextfield(view.mcBounds(), rect);
  }
  
  //******************************************************
  //*                     NSTextView
  //******************************************************
  
  public function drawTextViewWithRectInView(rect:NSRect, view:NSTextView):Void {
    var g:ASGraphics = view.graphics();
    g.brushDownWithBrush(view.backgroundColor());
    g.drawRectWithRect(rect, null, null);
    g.brushUp();
  }
  
  //******************************************************
  //*                    ASTextEditor
  //******************************************************

  public function drawTextEditorWithRectInView(rect:NSRect, view:ASTextEditor):Void {
    drawTextfield(view.mcBounds(), rect);
  }
	
  //******************************************************
  //*                   Scrollers
  //******************************************************

  public function drawScrollerSlotWithRectInView(rect:NSRect, view:NSView):Void {
    drawScrollerSlot(view.mcBounds(), rect);
  }

  public function drawScrollerWithRectInClip(rect:NSRect, clip:MovieClip):Void {
    drawScroller(clip, rect);
  }

  public function scrollerWidth():Number {
    return 20;
  }

  public function scrollerButtonWidth():Number {
    return 18;
  }
  
  /**
   * Draws a scroller border of the provided type and style
   */
  public function drawScrollerCellBorderInRectOfScroller(cell:ASScrollerButtonCell, 
      rect:NSRect, view:NSScroller):Void { 
    drawButtonCellBorderInRectOfView(cell, rect, view);		
  }
  
  public function drawScrollerCellBackgroundWithFrameMaskInScroller(cell:ASScrollerButtonCell, 
      frame:NSRect, mask:Number, scroller:NSScroller):Void {
    if (!cell.isBordered()) {
      var bg:NSColor = null;
      if (mask & NSCell.NSChangeBackgroundCellMask) {
        bg = ASColors.whiteColor();
      } else {
        bg = cell.backgroundColor();
      }
      
      if (bg != null) {
        drawFillWithRectColorInView(frame, bg, scroller);
      } 
    } 
    else if (cell.isBezeled()) {
      drawScrollerCellBorderInRectOfScroller(cell, frame, scroller);
    }	
  }

  //******************************************************
  //*                   Scrollviews
  //******************************************************

  public function drawScrollViewBorderInRectWithViewBorderType(rect:NSRect,
      view:NSView, border:NSBorderType):Void {
    drawBoxBorderWithRectInViewExcludeRectBorderType(rect, view, null, border);
  }

  //******************************************************
  //*                      Box
  //******************************************************

  public function drawBoxBorderWithRectInViewExcludeRectBorderType(rect:NSRect,
      view:NSView, excludeRect:NSRect, border:NSBorderType):Void {
    var mc:MovieClip = view.mcBounds();
    var grph:ASGraphics = view.graphics();
    switch(border) {
      case NSBorderType.NSNoBorder: // No border
        break;

      case NSBorderType.NSLineBorder:
        if (excludeRect != undefined) {
          grph.drawRectWithRectExcludingRect(rect, excludeRect, 
            [ASColors.blackColor()], 1);
        } else {
          grph.drawRectWithRect(rect, ASColors.blackColor(), 1);
        }
        break;

      case NSBorderType.NSBezelBorder:
        //! FIXME Implement this
        if (excludeRect != undefined) {
          grph.drawRectWithRectExcludingRect(rect, excludeRect, 
            [ASColors.blackColor()], 1);
        } else {
          grph.drawRectWithRect(rect, ASColors.blackColor(), 1);
        }
        break;

      case NSBorderType.NSGrooveBorder:
        var lGrey:NSColor = new NSColor(0xDDDDDD);
          grph.drawRectWithRectExcludingRect(rect, excludeRect, 
            [lGrey], 1);
          grph.drawRectWithRectExcludingRect(new NSRect(
              rect.origin.x+1,
              rect.origin.y+1,
              rect.size.width,
              rect.size.height), excludeRect, 
            [lGrey], 1);
          grph.drawRectWithRectExcludingRect(
            new NSRect(
              rect.origin.x,
              rect.origin.y,
              rect.size.width-1,
              rect.size.height-1),
            excludeRect, 
            [new NSColor(0x333333)], 1);
        
        break;
      }
  }
  //******************************************************
  //*                    Tabviews
  //******************************************************

  public function tabHeight():Number {
    return 20;
  }

  public function drawTabViewItemInRectWithView(item:NSTabViewItem, rect:NSRect,
      view:NSView):Void {
    var fillColors:Array;
    var fillAlpha:Number = 100;
    var cornerRadius:Number = 3;

    //
    // Calculate colors
    //
    var baseColor:NSColor = item.tabState() == NSTabState.NSBackgroundTab ?
      item.color().adjustColorBrightnessByFactor(0.7) : item.color();
    fillColors = [baseColor.adjustColorBrightnessByFactor(1.2).value,
      baseColor.value];

    //
    // Draw tab item
    //
    var mc:MovieClip = view.mcBounds();
    var x:Number = rect.origin.x;
    var y:Number = rect.origin.y;
    var width:Number = rect.size.width;
    var height:Number = rect.size.height;
    with (mc) {
      lineStyle(1.5, 0x8E8E8E, 100);
      beginGradientFill("linear", fillColors, [100,100], [0, 0xff],
                        {matrixType:"box", x:x,y:y,w:width,h:height,r:(.5*Math.PI)});
      moveTo(x+cornerRadius, y);
      lineTo(x+width-cornerRadius, y);
      lineTo(x+width, y+cornerRadius); //Angle
      lineTo(x+width, y+height);
      lineStyle(undefined, 0, 100);
      lineTo(x, y+height);
      lineStyle(1.5, 0x8E8E8E, 100);
      lineTo(x, y+cornerRadius);
      lineTo(x+cornerRadius, y); //Angle
      endFill();
    }
  }

  //******************************************************
  //*                      NSMenu
  //******************************************************

  /**
   * Draws a menu background on <code>view</code> in the area defined by
   * <code>aRect</code>.
   */
  public function drawMenuBackgroundWithRectInView(aRect:NSRect, view:NSMenuView):Void {
    //
    // Get colors
    //
    var border:NSColor = colorWithName(ASThemeColorNames.ASMenuBorder);
    var bg:NSColor = colorWithName(ASThemeColorNames.ASMenuBackground);

    var g:ASGraphics = view.graphics();

    //
    // Draw the background and border
    //
    g.beginFill(bg);
    g.drawRectWithRect(aRect, null, 0);
    g.endFill();
        
    if (view.isHorizontal()) {
      g.drawLine(aRect.minX(), aRect.maxX() - 2, aRect.maxX(), aRect.maxY() - 2,
        border, 2);
    } else {
      g.drawRectWithRect(aRect.insetRect(1, 1), border, 2);
    }
  }
  
  public function drawMenuBarBackgroundWithRectInView(aRect:NSRect, view:NSMenuView):Void {
    drawMenuBackgroundWithRectInView(aRect, view);
  }

  /**
   * Draws a menu separator on <code>view</code> in the area defined by
   * <code>rect</code>.
   */
  public function drawMenuSeparatorWithRectInView(aRect:NSRect, view:NSMenuView):Void {
    if (!view.isHorizontal()) {
      aRect = aRect.insetRect(0, (aRect.size.height - 2) / 2);
    } else {
      aRect = aRect.insetRect((aRect.size.width - 2) / 2, 0);
    }

    var g:ASGraphics = view.graphics();
    var lg:NSColor = new NSColor(0xDDDDDD);
    
    g.drawRectWithRect(aRect, lg, 1);
    g.drawRectWithRect(aRect.translateRect(1, 1), lg, 1);
    g.drawRectWithRect(aRect.scaledRect(-1, -1), new NSColor(0xAAAAAA), 1);
  }

  //******************************************************
  //*                   Tableviews
  //******************************************************

  /**
   * @see org.actionstep.ASThemeProtocol#drawTableHeaderWithRectInViewHighlightedSelected
   */
  public function drawTableHeaderWithRectInViewHighlightedSelected(rect:NSRect,
      view:NSView, highlighted:Boolean, selected:Boolean):Void {
    var mc:MovieClip = view.mcBounds();
    var x:Number = rect.origin.x;
    var y:Number = rect.origin.y;
    var w:Number = rect.size.width;
    var h:Number = rect.size.height;
    var baseColor:NSColor;
    var c1:Number;
    var c2:Number;
    var c3:Number;

    ASDraw.drawLine(mc, x + w, y, x + w, y + h, 0xC0C0C0);
    ASDraw.drawLine(mc, x, y + h, x + w, y + h, 0x666666);

    //
    // Get the base color
    //
    if (selected) {
      if (highlighted) {
        baseColor = colorWithName(ASThemeColorNames.ASHighlightedSelectedTableHeaderBackground);
      } else {
        baseColor = colorWithName(ASThemeColorNames.ASSelectedTableHeaderBackground);
      }
    } else {
      if (highlighted) {
        baseColor = colorWithName(ASThemeColorNames.ASHighlightedTableHeaderBackground);
      } else {
        baseColor = colorWithName(ASThemeColorNames.ASTableHeaderBackground);
      }
    }
    
    //
    // Generate aux colors if required
    //
    if (baseColor["__tableHeaderAuxFlag"] == undefined) {
      baseColor["__tableHeaderAuxFlag"] = true;
      
      var aux1:NSColor = baseColor.adjustColorBrightnessByFactor(1.3);
      var aux2:NSColor = baseColor.adjustColorBrightnessByFactor(1.2);
      
      baseColor["__tableHeaderAux1"] = aux1;
      baseColor["__tableHeaderAux2"] = aux2;
    }
    
    //
    // Get the aux colors
    //
    c1 = NSColor(baseColor["__tableHeaderAux1"]).value;
    c2 = baseColor.value;
    c3 = NSColor(baseColor["__tableHeaderAux2"]).value;

	//
	// Draw it
	//
    ASDraw.gradientRectWithRect(mc, new NSRect(x + 1, y + 1, w - 2, h - 2),
      90, [c1, c2, c3], [0, 50, 100]);
  }

  //******************************************************
  //*                 Status bars
  //******************************************************

  public function statusBarThickness():Number {
    return 22;
  }

  public function drawStatusBarBackgroundInRectWithViewHighlight(rect:NSRect,
      aView:NSView, highlight:Boolean):Void {
    var mc:MovieClip = aView.mcBounds();
    var colors:Array;
    var ratios:Array;

    if (highlight) {
      colors = [0x3973BD, 0x619BDF];
    } else {
      colors = [0xFFFFFF, 0xFFFFFF];
    }

    ratios = [0, 255];

    ASDraw.gradientRectWithRect(mc, rect, 90, colors, ratios);
  }

  //******************************************************
  //*               Progress Indicators
  //******************************************************

  public function progressIndicatorSizeForSize(size:NSControlSize):NSSize {
    var w:Number;
    var h:Number;

    switch(size) {
      case NSControlSize.NSMiniControlSize:
        w = 60;
        h = 8;
        break;

      case NSControlSize.NSRegularControlSize:
        w = 120;
        h = NSProgressIndicator.NSProgressIndicatorPreferredThickness;
        break;

      case NSControlSize.NSSmallControlSize:
        w = 90;
        h = NSProgressIndicator.NSProgressIndicatorPreferredSmallThickness;
        break;

      default:
        return null;
    }

    return new NSSize(w, h);
  }

  //because of the way the animation layer moves for the indeterminate bars, the border needs its own
  //clip to draw above everything else. otherwise the animation obscures the border.
  public function drawProgressBarBorderInRectWithClipBezeledProgress(
      rect:NSRect, mc:MovieClip, bezeled:Boolean, progress:Number):Void {
    ASDraw.gradientRectWithAlphaRect(mc, rect, ASDraw.ANGLE_TOP_TO_BOTTOM, [0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF,0xFFFFFF],
                                                                           [       0,       1,       4,       5,       7,       9,      12,      16],
                                                                           [       0,      30,      50,      30,      10,      40,      30,      20]);
    if (bezeled) {
      ASDraw.outlineRectWithRect(mc, rect, [0x333333, 0xAAAAAA]);
      ASDraw.outlineRectWithRect(mc, rect.insetRect(1,1), [0xAAAAAA,0x333333]);
    }
  }

  public function drawProgressBarInRectWithViewBezeledProgress(
      rect:NSRect, aView:NSView, bezeled:Boolean, progress:Number):Void {
    var mc:MovieClip = aView.mcBounds();

    //
    // Draw background
    //
    ASDraw.fillRectWithRect(mc, rect,
      colorWithName(ASThemeColorNames.ASProgressBarBackground).value);

    if (progress > 100 || progress <= 0) {
      return;
    }

    //
    // Draw progress bar
    //
    var pbColor1:NSColor = colorWithName(ASThemeColorNames.ASProgressBar);
    var pbColor2:NSColor = pbColor1.adjustColorBrightnessByFactor(0.6);
    var alpha:Number = pbColor1.alphaComponent() * 100;
    rect = rect.insetRect(0,1);
    rect = rect.insetRect(0,-1);
    rect.size.width *= progress / 100;
    ASDraw.gradientRectWithAlphaRect(mc, rect, 90, [pbColor1.value, pbColor2.value], [0, 255], [alpha, alpha]);
  }

  //TODO clean this up a bit
  private static var progressBarDeterminatePattern_colors:Array   = [0x336CC2,0x375ABB,0x336CC2];
  private static var progressBarIndeterminatePattern_colors:Array = [0x949494,0x949494,0x3548B0,0x3548B0,0x949494,0x949494,0x3548B0,0x3548B0,0x949494,0x949494];
  private static var progressBarIndeterminatePattern_alphas:Array = [     100,     100,     100,     100,     100,     100,     100,     100,     100,     100];
  public function drawProgressBarPatternInRectWithClipIndeterminate(rect:NSRect, mc:MovieClip, indeterminate:Boolean):Void {
    if (indeterminate) {
      var angle:Number   = 45;
      var radians:Number = ASGraphicUtils.convertDegreesToRadians(angle);

      //the size of the gradient has to be adjusted for the angle or the tiles won't line up.
      var gradientHeight:Number = Math.sqrt(rect.size.height*rect.size.height + rect.size.height*rect.size.height);

      var size:Number = gradientHeight/20;
      var beginEnd:Number = size;
      var solid:Number    = size*2;
      var fade:Number     = size*3;
      var total:Number    = 0;

      var ratios:Array = new Array();

      ratios[0] = total;
      total += beginEnd;
      ratios[1] = total;
      total += fade;
      ratios[2] = total;
      total += solid;
      ratios[3] = total;
      total += fade;
      ratios[4] = total;
      total += solid;
      ratios[5] = total;
      total += fade;
      ratios[6] = total;
      total += solid;
      ratios[7] = total;
      total += fade;
      ratios[8] = total;
      total += beginEnd;
      ratios[9] = total;

//      ASDraw.gradientRectWithRect(mc, rect, angle,
//                                  progressBarIndeterminatePattern_colors,
//                                  ratios);
//TODO move generalized logic for this into ASDraw
      var offset:Number = (rect.size.height - gradientHeight)/2;

      var matrix:Object = ASDraw.getMatrix(new NSRect(rect.origin.x+offset, rect.origin.y+offset, gradientHeight, gradientHeight), angle);
      var actualRatios:Array = ASDraw.getActualRatios(ratios);

      mc.lineStyle(undefined, 0, 100);
      ASDraw.beginLinearGradientFill(mc,progressBarIndeterminatePattern_colors,progressBarIndeterminatePattern_alphas,actualRatios,matrix);
      mc.moveTo(rect.origin.x,rect.origin.y);
      mc.lineTo(rect.origin.x+rect.size.width, rect.origin.y);
      mc.lineTo(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
      mc.lineTo(rect.origin.x, rect.origin.y+rect.size.height);
      mc.lineTo(rect.origin.x, rect.origin.y);
      mc.endFill();


    }
    else {
      var size:Number = rect.size.height/2;
      var ratios:Array = new Array();
      for (var i:Number = 0; i<3; i++) {
        ratios.push(i*size);
      }
      ASDraw.gradientRectWithRect(mc, rect, ASDraw.ANGLE_LEFT_TO_RIGHT,
                                  progressBarDeterminatePattern_colors,
                                  ratios);
    }
  }

  public function drawProgressBarSpinnerInRectWithClip(rect:NSRect, mc:MovieClip):Void {
    //the rect SHOULD have a negative origin, such that 0,0 is the center.
    var radius:Number   = Math.floor(rect.size.width/2);
    var segments:Number  = 12;
    var degrees:Number = 360/segments;
    var alphaIncrement:Number = 90/segments;
    var thickness:Number = 2;
    if (radius < 6) {
      thickness = 1;
    }
    for (var i:Number=1; i<=segments; i++) {
      var angle:Number = ASGraphicUtils.convertDegreesToRadians(i*degrees);
      var alpha:Number = 10+alphaIncrement*i;
      var x1:Number = Math.cos(angle)*radius/2;
      var y1:Number = Math.sin(angle)*radius/2;
      var x2:Number = Math.cos(angle)*radius;
      var y2:Number = Math.sin(angle)*radius;
      ASDraw.drawLine(mc, x1, y1, x2, y2, 0x0D0D0D, alpha, thickness);
    }
  }

  //******************************************************
  //*                    NSToolbar
  //******************************************************
    
  /**
   * Draws the toolbar background in <code>view</code>.
   */
  public function drawToolbarBackgroundWithRectInView(toolbar:NSToolbar, rect:NSRect,
      view:NSView):Void {
    var g:ASGraphics = view.graphics();
    
    //
    // Draw background
    //
    g.brushDownWithBrush(colorWithName(ASThemeColorNames.ASToolbarBackground));
    g.drawRectWithRect(rect);
    g.brushUp();
    
    //
    // Draw baseline separator
    //
    if (toolbar.showsBaselineSeparator()) {
      var y:Number = rect.maxY() - 1;
      g.brushDownWithBrush(colorWithName(ASThemeColorNames.ASToolbarBaseline));
      g.drawRect(rect.origin.x, y, rect.size.width, 1);
      g.brushUp();
    }
  }
  
  /**
   * Returns the height of a toolbar. Should take 
   * <code>NSToolbar#displayMode()</code> and <code>NSToolbar#sizeMode()</code> 
   * into account.
   */
  public function toolbarHeightForToolbar(toolbar:NSToolbar):Number {
    var size:NSToolbarSizeMode = toolbar.sizeMode();
    var display:NSToolbarDisplayMode = toolbar.displayMode();
    var height:Number = 0;
            
    if (display != NSToolbarDisplayMode.NSToolbarDisplayModeLabelOnly) {
	    height += toolbarItemImageSizeForToolbar(toolbar);
    }
    
    if (display != NSToolbarDisplayMode.NSToolbarDisplayModeIconOnly) {
    	switch (size) {
	      case NSToolbarSizeMode.NSToolbarSizeModeRegular:
	        height += 20;
	        break;
	        
	      case NSToolbarSizeMode.NSToolbarSizeModeSmall:
	        height += 17;
	        break;
	    }	
    }
    else if (height != 0) {
    	height += 6;
    }    
    
    return height;
  }
  
  /**
   * Returns the maximum width/height of an item's image in a toolbar. Should 
   * take <code>NSToolbar#displayMode()</code> and <code>NSToolbar#sizeMode()</code> 
   * into account.
   */
  public function toolbarItemImageSizeForToolbar(toolbar:NSToolbar):Number {
    var size:NSToolbarSizeMode = toolbar.sizeMode();
        
    switch (size) {
      case NSToolbarSizeMode.NSToolbarSizeModeRegular:
        return 32;
        
      case NSToolbarSizeMode.NSToolbarSizeModeSmall:
        return 26;
    }
  }
      
  //******************************************************
  //*                    Colors
  //******************************************************

  /**
   * @see org.actionstep.ASThemeProtocol#colors
   */
  public function colors():NSColorList {
    return m_colorList;
  }

  /**
   * @see org.actionstep.ASThemeProtocol#colorWithName
   */
  public function colorWithName(name:String):NSColor {
    return NSColor(m_colorList.colorWithKey(name).copyWithZone());
  }
  
  /**
   * @see org.actionstep.ASThemeProtocol#setColors
   */
  public function setColors(aColorList:NSColorList):Void {
    //! TODO should the current list's name be deregistered?
    m_colorList = aColorList;
  }

  /**
   * Adds the color <code>aColor</code> named <code>name</code> to the theme's
   * color list.
   */
  public function setColorForName(aColor:NSColor, name:String):Void {
    m_colorList.setColorForKey(aColor, name);
  }

  //******************************************************
  //*                     Fonts
  //******************************************************
  
  /**
   * Gives the theme an opportunity to perform any necessary font setup.
   */
  public function registerDefaultsFonts():Void {
  	
  }
  
  /**
   * <p>Returns the system font used for standard interface items that are 
   * rendered in boldface type in the specified size.</p>
   * 
   * <p>If <code>fontSize</code> is 0 or negative, returns the boldface system
   * font at the default size.</p>
   */
  public function boldSystemFontOfSize(fontSize:Number):NSFont {
    var fnt:NSFont = systemFontOfSize(fontSize);
    return NSFont.boldFontWithFont(fnt);
    
    return fnt;
  }
  
  /**
   * <p>Returns the font used for the content of controls in the specified 
   * size.</p>
   * 
   * <p>For example, in a table, the user’s input uses the control content 
   * font, and the table’s header uses another font. If <code>fontSize</code> 
   * is 0 or negative, returns the control content font at the default 
   * size.</p>
   */
  public function controlContentFontOfSize(fontSize:Number):NSFont {
    return systemFontOfSize(fontSize); // FIXME consider changing
  }
  
  /**
   * <p>Returns the font used for standard interface labels in the specified 
   * size.</p>
   * 
   * <p>If <code>fontSize</code> is 0 or negative, returns the label font with
   * the default size.</p>
   */
  function labelFontOfSize(fontSize:Number):NSFont {
    return systemFontOfSize(fontSize); // FIXME consider changing
  }

  /**
   * <p>Returns the font used for menu items, in the specified size.</p>
   * 
   * <p>If <code>fontSize</code> is 0 or negative, returns the menu item font 
   * with the default size.</p>
   */  
  function menuFontOfSize(fontSize:Number):NSFont {
    return systemFontOfSize(fontSize); // FIXME consider changing
  }
  
  /**
   * <p>Returns the font used for menu bar items, in the specified size.</p>
   * 
   * <p>If <code>fontSize</code> is 0 or negative, returns the menu bar font 
   * with the default size.</p>
   */
  function menuBarFontOfSize(fontSize:Number):NSFont {
    return systemFontOfSize(fontSize); // FIXME consider changing
  }
  
  /**
   * <p>
   * Returns the font used for standard interface items, such as button 
   * labels, menu items, and so on, in the specified size.
   * </p>
   * 
   * <p>If <code>fontSize</code> is 0 or negative, returns the menu bar font 
   * with the default size.</p>
   */
  public function messageFontOfSize(fontSize:Number):NSFont {
    return systemFontOfSize(fontSize);
  }
  
  /**
   * <p>Returns the font used for palette window title bars, in the specified 
   * size.</p>
   * 
   * <p>If <code>fontSize</code> is 0 or negative, returns the palette title 
   * font with the default size.</p>
   */
  function paletteFontOfSize(fontSize:Number):NSFont {
    return systemFontOfSize(fontSize); // FIXME consider changing
  }
  
  /**
   * <p>Returns the Aqua system font used for standard interface items, such 
   * as button labels, menu items, and so on, in the specified size.</p>
   * 
   * <p>If <code>fontSize</code> is 0 or negative, returns the font with
   * the default size.</p>
   */
  function systemFontOfSize(fontSize:Number):NSFont {
  	if (fontSize <= 0) {
  	  fontSize = systemFontSize();
  	}
  	
  	return NSFont.fontWithNameSize("Arial", fontSize);
  }
  
  /**
   * Helper method to return the color by name:
   * ASThemeColorNames.ASSystemFontColor
   * This is the default color used for controls
   */
  function systemFontColor():NSColor {
    return colorWithName(ASThemeColorNames.ASSystemFontColor);
  }
  
  /**
   * <p>Returns the font used for window title bars, in the specified size.</p>
   * 
   * <p>If <code>fontSize</code> is 0 or negative, returns the font with
   * the default size.</p>
   */
  public function titleBarFontOfSize(fontSize:Number):NSFont {
    return boldSystemFontOfSize(fontSize);
  }
  
  /**
   * <p>Returns the font used for tool tips labels, in the specified size.</p>
   * 
   * <p>If <code>fontSize</code> is 0 or negative, returns the label font with
   * the default size.</p>
   */
  public function toolTipsFontOfSize(fontSize:Number):NSFont {
    return systemFontOfSize(fontSize);
  }
  
  /**
   * Returns the size of the standard system font.
   */
  public function systemFontSize():Number {
    return 13;
  }
	
  /**
   * <p>Returns the font size used for the specified control size.</p>
   * 
   * <p>If <code>controlSize</code> does not correspond to a valid 
   * {@link NSControlSize}, it returns the size of the standard system font.
   * </p>
   */
  public function systemFontSizeForControlSize(controlSize:NSControlSize):Number {
    switch (controlSize) {
      case NSControlSize.NSMiniControlSize:
        return 9;
      case NSControlSize.NSSmallControlSize:
        return 11;
      case NSControlSize.NSRegularControlSize:
        return 13;
      default:
        return systemFontSize();
    }
  }

  /**
   * <p>Returns the default paragraph font used in this theme.</p>
   */
  public function defaultParagraphStyle():NSParagraphStyle {
    return new NSParagraphStyle(NSTextAlignment.NSNaturalTextAlignment,
      0, null, 0, NSLineBreakMode.NSDefaultLineBreak);
  }
	
  //******************************************************
  //*               Private Methods
  //******************************************************

  private function drawBorderButtonUp(mc:MovieClip, rect:NSRect):Void {
    var x:Number = rect.origin.x;
    var y:Number = rect.origin.y;
    var width:Number = rect.size.width-1;
    var height:Number = rect.size.height-1;
    ASDraw.fillRect(mc, x, y, width, height, 0xC7CAD1);
    ASDraw.drawRect(mc, x, y, width, height, 0x000000);
  }

  private function drawBorderButtonDown(mc:MovieClip, rect:NSRect):Void {
    var x:Number = rect.origin.x;
    var y:Number = rect.origin.y;
    var width:Number = rect.size.width-1;
    var height:Number = rect.size.height-1;
    ASDraw.fillRect(mc, x, y, width, height, 0xB1B5BC);
    ASDraw.drawRect(mc, x, y, width, height, 0x000000);
  }

  ///////////////////////////////
  // BUTTON DRAW FUNCTIONS

  private static var drawButtonUp_outlineColors:Array = [0x82858E, 0xD3D6DB];
  private static var drawButtonUp_inlineColors:Array  = [0xDFE2E9, 0x858992];
  private static var drawButtonUp_colors:Array = [0xEEF2F5, 0xC7CAD1, 0xC7CAD1, 0x858992];
  private static var drawButtonUp_ratios:Array = [       1,       5,       23,       26];
  private function drawButtonUp(mc:MovieClip, rect:NSRect)
  {
    drawButtonUpWithoutBorder(mc, rect.insetRect(1,1));
    ASDraw.outlineRectWithRect( mc, rect, drawButtonUp_outlineColors);
  }

  private function drawButtonUpWithoutBorder(mc:MovieClip, rect:NSRect)
  {
    ASDraw.gradientRectWithRect(mc, rect, ASDraw.ANGLE_TOP_TO_BOTTOM, drawButtonUp_colors, drawButtonUp_ratios);
    ASDraw.outlineRectWithRect( mc, rect, drawButtonUp_inlineColors);
  }

  private static var drawButtonDown_outlineColors:Array = [0x82858E, 0xECEDF0];
  private static var drawButtonDown_inlineColors:Array  = [0x696F79, 0xD4D6DB];
  private static var drawButtonDown_colors:Array = [0x696F79, 0xB1B5BC, 0xB1B5BC, 0xD9DBDF, 0xC9CDD2];
  private static var drawButtonDown_ratios:Array = [       1,        5,       23,       25,       26];
  private function drawButtonDown(mc:MovieClip, rect:NSRect)
  {
    drawButtonDownWithoutBorder(mc, rect.insetRect(1,1));
    ASDraw.outlineRectWithRect( mc, rect, drawButtonDown_outlineColors);
  }

  private static var drawButtonUpDisabled_outlineAlphas:Array = [      50,      50];
  private static var drawButtonUpDisabled_inlineAlphas:Array  = [      50,      50];
  private static var drawButtonUpDisabled_alphas:Array        = [      50,      50,       50,       50];
  public function drawButtonUpDisabled(mc:MovieClip, rect:NSRect)
  {
    drawButtonUpDisabledWithoutBorder(mc, rect.insetRect(1,1));
    ASDraw.outlineRectWithAlphaRect( mc, rect, drawButtonUp_outlineColors, drawButtonUpDisabled_outlineAlphas);
  }

  public function drawButtonUpDisabledWithoutBorder(mc:MovieClip, rect:NSRect)
  {
    ASDraw.gradientRectWithAlphaRect(mc, rect, ASDraw.ANGLE_TOP_TO_BOTTOM,
                                     drawButtonUp_colors, drawButtonUp_ratios, drawButtonUpDisabled_alphas);
    ASDraw.outlineRectWithAlphaRect( mc, rect, drawButtonUp_inlineColors, drawButtonUpDisabled_inlineAlphas);
  }

  private function drawButtonDownWithoutBorder(mc:MovieClip, rect:NSRect)
  {
    ASDraw.gradientRectWithRect(mc, rect, ASDraw.ANGLE_TOP_TO_BOTTOM, drawButtonDown_colors, drawButtonDown_ratios);
    ASDraw.outlineRectWithRect( mc, rect, drawButtonDown_inlineColors);
  }

  private static var drawButtonDownDisabled_outlineAlphas:Array = [      50,      50];
  private static var drawButtonDownDisabled_inlineAlphas:Array  = [      50,      50];
  private static var drawButtonDownDisabled_alphas:Array        = [      50,      50,       50,       50,       50];
  public function drawButtonDownDisabled(mc:MovieClip, rect:NSRect)
  {
    drawButtonDownDisabledWithoutBorder(mc, rect.insetRect(1,1));
    ASDraw.outlineRectWithAlphaRect( mc, rect, drawButtonDown_outlineColors, drawButtonDownDisabled_outlineAlphas);
  }

  public function drawButtonDownDisabledWithoutBorder(mc:MovieClip, rect:NSRect)
  {
    ASDraw.gradientRectWithAlphaRect(mc, rect, ASDraw.ANGLE_TOP_TO_BOTTOM,
                                     drawButtonDown_colors, drawButtonDown_ratios, drawButtonDownDisabled_alphas);
    ASDraw.outlineRectWithAlphaRect( mc, rect, drawButtonDown_inlineColors, drawButtonDownDisabled_inlineAlphas);
  }

  // END BUTTON DRAW FUNCTIONS
  ///////////////////////////////

  ///////////////////////////////
  // TEXTFIELD DRAW FUNCTIONS
  private static var drawTextfield_outlineColors:Array = [0x4B4F57, 0xDEE1E6];
  private static var drawTextfield_background:Number   = 0xD3D4D9;
  private static var drawTextfield_colors:Array        = [0x4B4F57, 0x81858E, 0xAEB3B9, 0xD3D4D9];
  private static var drawTextfield_ratios:Array        = [       0,       1,        5,        23];
  private static var drawTextfieldShadow_colors:Array  = [0x4B4F57, 0x4B4F57, 0x4B4F57];
  private static var drawTextfieldShadow_alphas:Array  = [      17,        0,        0];
  private static var drawTextfieldShadow_ratios:Array  = [       0,        8,       35];
  public function drawTextfield(mc:MovieClip, rect:NSRect) 
  {
    drawTextfieldBackground(   mc, rect);
    ASDraw.outlineRectWithRect(mc, rect, drawTextfield_outlineColors);
  }

  public function drawTextfieldBackground(mc:MovieClip, rect:NSRect) 
  {
    ASDraw.fillRectWithRect(        mc, rect, drawTextfield_background);
    ASDraw.gradientRectWithRect(     mc, new NSRect(rect.origin.x, rect.origin.y, rect.size.width, 23), ASDraw.ANGLE_TOP_TO_BOTTOM, 
                                            drawTextfield_colors, drawTextfield_ratios);
    ASDraw.gradientRectWithAlphaRect(mc, new NSRect(rect.origin.x, rect.origin.y, 35, 30), 20, 
                                            drawTextfieldShadow_colors, drawTextfieldShadow_ratios, drawTextfieldShadow_alphas);
  }
  // END TEXTFIELD DRAW FUNCTIONS
  ///////////////////////////////

  ///////////////////////////////
  // SCROLLER DRAW FUNCTIONS
  private static var drawScrollerSlot_outlineColors:Array = [0x4B4F57, 0xDEE1E6];
  private static var drawScrollerSlot_colors:Array = [0x80848F, 0xAFB4BA, 0xCACDD2];
  private static var drawScrollerSlot_ratios:Array = [       0,       6,        24];
  private static var drawScrollerSlotShadow_colors:Array = [0x767A85, 0xB6BBC1];
  private static var drawScrollerSlotShadow_alphas:Array = [     100,        0];
  private static var drawScrollerSlotShadow_ratios:Array = [       0,        5];
  private function drawScrollerSlot(mc:MovieClip, rect:NSRect) {
    var insetRect:NSRect = rect.insetRect(1,1);
    ASDraw.fillRectWithRect(        mc, rect, 0xCACDD2);
    //ASDraw.gradientRectWithRect(     mc, rect, ANGLE_TOP_TO_BOTTOM, drawTextfield_colors, drawTextfield_ratios);
    ASDraw.gradientRectWithAlphaRect(mc, new NSRect(rect.origin.x, rect.origin.y, rect.size.width, 5), ASDraw.ANGLE_TOP_TO_BOTTOM,
                                            drawScrollerSlotShadow_colors, drawScrollerSlotShadow_ratios, drawScrollerSlotShadow_alphas);
    ASDraw.gradientRectWithAlphaRect(mc, new NSRect(rect.origin.x, rect.origin.y, 5, rect.size.height), 30,
                                            drawScrollerSlotShadow_colors, drawScrollerSlotShadow_ratios, drawScrollerSlotShadow_alphas);
    ASDraw.outlineRectWithRect(      mc, rect, drawScrollerSlot_outlineColors);
  }

  private static var drawScroller_outlineColors:Array = [0xDEE1E6, 0x4B4F57];
  private function drawScroller(mc:MovieClip, rect:NSRect) {
    ASDraw.fillRectWithRect(        mc, rect, 0xCACDD2);
    ASDraw.outlineRectWithRect(      mc, rect, drawScroller_outlineColors);
    if (rect.size.width > rect.size.height) {
      var x1:Number = rect.origin.x + rect.size.width/2-1;
      var x2:Number = x1 + 6;
      x1 -= 6;
      var y1:Number = rect.origin.y + 3;
      var y2:Number = rect.origin.y + rect.size.height - 4;
      while (x1 < x2) {
        mc.lineStyle(1, 0xDEE1E6, 50);
        mc.moveTo(x1, y1);
        mc.lineTo(x1, y2);
        mc.lineStyle(1, 0x4B4F57, 50);
        mc.moveTo(x1+1, y2);
        mc.lineTo(x1+1, y1);
        x1+=2;
      }
    } else {
       var y1:Number = rect.origin.y + rect.size.height/2-1;
      var y2:Number = y1 + 6;
      y1 -= 6;
      var x1:Number = rect.origin.x + 3;
      var x2:Number = rect.origin.x + rect.size.width - 4;
      while (y1 < y2) {
        mc.lineStyle(1, 0xDEE1E6, 50);
        mc.moveTo(x1, y1);
        mc.lineTo(x2, y1);
        mc.lineStyle(1, 0x4B4F57, 50);
        mc.moveTo(x2, y1+1);
        mc.lineTo(x1, y1+1);
        y1+=2;
      }
    }
  }

  // END TEXTFIELD DRAW FUNCTIONS
  ///////////////////////////////

}