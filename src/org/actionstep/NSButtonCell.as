/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASUtils;
import org.actionstep.constants.NSBezelStyle;
import org.actionstep.constants.NSBorderType;
import org.actionstep.constants.NSButtonType;
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.constants.NSCellType;
import org.actionstep.constants.NSComparisonResult;
import org.actionstep.constants.NSControlSize;
import org.actionstep.constants.NSGradientType;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSActionCell;
import org.actionstep.NSApplication;
import org.actionstep.NSAttributedString;
import org.actionstep.NSCell;
import org.actionstep.NSColor;
import org.actionstep.NSControl;
import org.actionstep.NSEvent;
import org.actionstep.NSException;
import org.actionstep.NSFont;
import org.actionstep.NSImage;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSNumber;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSSound;
import org.actionstep.NSTimer;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.ASThemeImageNames;

import flash.display.BitmapData;

/**
 * <p><code>NSButtonCell</code> is a subclass of <code>NSActionCell</code> used 
 * to implement the user interfaces of push buttons, switches, and radio 
 * buttons. It can also be used for any other region of a view that’s designed 
 * to send a message to a target when clicked. The <code>NSButton</code> 
 * subclass of {@link NSControl} uses a single <code>NSButtonCell</code>.</p>
 * 
 * <p>The class responsible for the default drawing behavior of the
 * {@link org.actionstep.NSButton} class.</p>
 *
 * @author Rich Kilmer
 */
class org.actionstep.NSButtonCell extends NSActionCell {

  private var m_textField:TextField;
  private var m_textFormat:TextFormat;

  private var m_buttonType:NSButtonType;
  private var m_highlightsBy:Number;
  private var m_showsStateBy:Number;
  private var m_imageDimsWhenDisabled:Boolean;
  private var m_alternateImage:NSImage;
  private var m_bezelStyle:NSBezelStyle;
  private var m_gradientType:NSGradientType;
  private var m_showsBorderOnlyWhileMouseInside:Boolean;
  private var m_waitingToTrackMouse:Boolean;
  private var m_mouseInside:Boolean;
  private var m_sound:NSSound;
  private var m_keyEquivalent:String;
  private var m_keyEquivalentModifierMask:Number;
  private var m_keyEquivalentFont:NSFont;
  private var m_alternateTitle:String;
  private var m_bcellTransparent:Boolean;
  private var m_backgroundColor:NSColor;
  private var m_periodicInterval:Number;
  private var m_periodicDelay:Number;
  private var m_showAltStateMask:Number;
  private var m_highlightsByMask:Number;
  private var m_trackingTag:Number;
  private var m_trackingRect:NSRect;
  
  //******************************************************
  //*                 Construction
  //******************************************************

  public function NSButtonCell() {
    m_textField = null;
    m_imageDimsWhenDisabled = true;
    m_showsBorderOnlyWhileMouseInside = false;
    m_waitingToTrackMouse = false;
    m_mouseInside = false;
    m_keyEquivalent = "";
    m_alternateTitle = null;
    m_bcellTransparent = false;
    m_trackingTag = null;
    m_bezelStyle = NSBezelStyle.NSRegularSquareBezelStyle;
    m_gradientType = NSGradientType.NSGradientConvexWeak;
    m_periodicDelay = 0.4;
    m_periodicInterval = 0.075;
  }

  public function init():NSButtonCell {
    initTextCell("Button");
    return this;
  }

  public function initImageCell(image:NSImage):NSButtonCell {
    super.initImageCell(image);
    return __init();
  }

  public function initTextCell(string:String):NSButtonCell {
    super.initTextCell(string);
    return __init();
  }

  /**
   * Common initializer between public initializers.
   */
  private function __init():NSButtonCell {
    setAlignment(NSTextAlignment.NSCenterTextAlignment);
    m_showsStateBy = NSNoCellMask;
    m_highlightsBy = NSPushInCellMask | NSChangeGrayCellMask;
    m_keyEquivalentModifierMask = NSEvent.NSCommandKeyMask;
    m_bordered = false;
    m_keyEquivalent = "";
    m_alternateTitle = null;
    m_bezeled = true;
    m_font = ASTheme.current().messageFontOfSize(0);
    return this;
  }

  /**
   * Releases the button cell from memory.
   */
  public function release():Boolean {
    if (m_textField != null) {
      m_textField.removeTextField();
      m_textField = null;
    }
    return super.release();
  }

  //******************************************************
  //*               Setting the titles
  //******************************************************

  public function setType(type:NSCellType) {
    //Do nothing (just like Cocoa)
  }

  /**
   * Sets the string displayed on the cell when in its normal state to
   * <code>value</code>.
   */
  public function setTitle(title:String) {
    setStringValue(title);
  }

  /**
   * Returns the string displayed on the cell when in its normal state.
   */
  public function title():String {
    return stringValue();
  }

  /**
   * Sets the string displayed on the cell when in its alternate state to
   * <code>value</code>.
   */
  public function setAlternateTitle(value:String) {
    m_alternateTitle = value;
    if (m_controlView != null) {
      if (m_controlView instanceof NSControl) {
        NSControl(m_controlView).updateCell(this);
      }
    }
  }

  /**
   * Returns the string displayed on the cell when in its alternate state.
   */
  public function alternateTitle():String {
    return m_alternateTitle ? m_alternateTitle : stringValue();
  }

  public function setAttributedTitle(string:NSAttributedString) {
    setAttributedStringValue(string);
  }

  public function attributedTitle():NSAttributedString {
    return attributedStringValue();
  }

  public function setAttributedAlternateTitle(attribString:NSAttributedString) {
    setAlternateTitle(attribString.string());
  }

  public function attributedAlternateTitle():NSAttributedString {
    if (m_alternateTitle == null || m_alternateTitle.length == 0) {
      return null;
    }

    return (new NSAttributedString()).initWithString(m_alternateTitle);
  }

  /**
   * Sets the font used by the cell to <code>font</code>.
   */
  public function setFont(font:NSFont) {
    super.setFont(font);
    m_textFormat = null;
    if((font != null) && (m_keyEquivalentFont!=null)
        && font.pointSize() != m_keyEquivalentFont.pointSize()) {
      setKeyEquivalentFont(NSFont.fontWithNameSizeEmbedded(
        m_keyEquivalentFont.fontName(), font.pointSize(), font.isEmbedded()));
    }
  }

  /**
   * Sets the font color used by the cell to <code>font</code>.
   */
  public function setFontColor(color:NSColor) {
    super.setFontColor(color);
    if (m_textFormat != null) {
      m_textFormat.color = color.value;
    }
    if (m_textField != null) {
      m_textField._alpha = color.alphaComponent();
    }
  }

  //******************************************************
  //*              Setting the images
  //******************************************************

  public function image():NSImage {
    return m_image;
  }

  /**
   * Sets the image displayed when the button is in its alternate state to
   * <code>value</code>.
   */
  public function setAlternateImage(value:NSImage) {
  	var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
    
    //
    // Stop observing old image
    //
    if (m_alternateImage != null) {
      nc.removeObserverNameObject(this, NSImage.NSImageDidLoadNotification, m_alternateImage);
    }
    
    m_alternateImage = value;
    
    //
    // Begin observing new image
    //
    if (m_alternateImage != null && !m_alternateImage.isRepresentationLoaded()) {
      nc.addObserverSelectorNameObject(this, "altImageDidLoad", 
        NSImage.NSImageDidLoadNotification, m_alternateImage);
    } else {
      if (m_controlView != null) {
        if (m_controlView instanceof g_controlClass) {
          NSControl(m_controlView).updateCell(this);
        }
      }	
    }
  }

  /**
   * Returns the image displayed when the button is in its alternate state.
   */
  public function alternateImage():NSImage {
    return m_alternateImage;
  }

  /**
   * Sets the position of the image within the cell to <code>value</code>.
   */
  public function setImagePosition(value:NSCellImagePosition) {
    super.setImagePosition(value);
  }

  /**
   * Returns the position of the image within this cell.
   */
  public function imagePosition():NSCellImagePosition {
    return super.imagePosition();
  }
  
  /**
   * Calls setAlternateImage() with the newly loaded image. The observer will be removed,
   * and <code>ActionCell</code> subclasses will tell their controls to update.
   */
  private function altImageDidLoad(ntf:NSNotification):Void {
    setAlternateImage(m_alternateImage);
  }

  //******************************************************
  //*           Setting the repeat interval
  //******************************************************

  /**
   * Returns an object with delay and interval properties
   */
  public function getPeriodicDelayInterval():Object {
    return {delay:m_periodicDelay, interval:m_periodicInterval};
  }

  /**
   * Sets the message delay and interval to <code>delay</code> and
   * <code>interval</code> respectively.
   */
  public function setPeriodicDelayInterval(delay:Number, interval:Number) {
  	if (delay > 60) {
  		delay = 60;
  	}
  	if (interval > 60) {
  		interval = 60;
  	}
  	
    m_periodicDelay = delay;
    m_periodicInterval = interval;
  }

  //******************************************************
  //*            Setting the key equivalent
  //******************************************************

  /**
   * Sets the key-equivalent character of the button cell to <code>value</code>.
   */
  public function setKeyEquivalent(value:String) {
    m_keyEquivalent = value;
  }

  /**
   * Returns the key-equivalent character of the button cell, or
   * <code>null</code> if none exists.
   */
  public function keyEquivalent():String {
    return m_keyEquivalent;
  }

  /**
   * Sets the modifier mask indicating modifier keys that are applied to
   * the button cell's key-equivalent to <code>value</code>.
   */
  public function setKeyEquivalentModifierMask(value:Number) {
    m_keyEquivalentModifierMask = value;
  }

  /**
   * Returns the modifier mask indicating modifier keys that are applied to
   * the button cell's key-equivalent.
   */
  public function keyEquivalentModifierMask():Number {
    return m_keyEquivalentModifierMask;
  }

  /**
   * Sets the font used to draw the key-equivalent to <code>value</code>, then
   * redraws the button cell if necessary.
   */
  public function setKeyEquivalentFont(value:NSFont) {
  	if (value.isEqual(m_keyEquivalentFont)) {
  	  return;
  	}

    m_keyEquivalentFont = value;
    m_controlView.setNeedsDisplay(true); //! TODO see if this is necessary
  }

  /**
   * Sets the name and point size of the font used to draw the key-equivalent
   * to <code>font</code> and <code>size</code> respectively, then redraws
   * the button cell.
   */
  public function setKeyEquivalentFontSize(font:String, size:Number) {
  	setKeyEquivalentFont(NSFont.fontWithNameSize(font, size));
  }

  /**
   * Returns the font used to display the key-equivalent.
   */
  public function keyEquivalentFont():NSFont {
    return m_keyEquivalentFont;
  }

  //******************************************************
  //*           Modifying graphics attributes
  //******************************************************
  
  
  public function setGradientType(gradientType:NSGradientType) {
    m_gradientType = gradientType;
  }
  
  public function gradientType():NSGradientType {
    return m_gradientType;
  }

  /**
   * Sets the background color of the button cell to <code>value</code>.
   */
  public function setBackgroundColor(value:NSColor) {
    m_backgroundColor = value;
  }

  /**
   * Returns the background color of the button cell.
   */
  public function backgroundColor():NSColor {
    return m_backgroundColor;
  }

  /**
   * Sets whether the button cell is transparent to <code>value</code>.
   */
  public function setTransparent(value:Boolean) {
    m_bcellTransparent = value;
  }

  /**
   * Returns <code>true</code> if the button cell is transparent.
   */
  public function isTransparent():Boolean {
    return m_bcellTransparent;
  }

  /**
   * <p>Returns <code>true</code> if the button cell is opaque.</p>
   *
   * <p>For a button cell to be opaque, it must be bordered and not transparent.</p>
   */
  public function isOpaque():Boolean {
    return m_bordered && !m_bcellTransparent;
  }

  /**
   * <p>Sets whether the button cell displays its border only while the mouse is
   * hovering to <code>value</code>.</p>
   * 
   * <p>If <code>show</code> is <code>true</code>, the border is displayed only 
   * when the cursor is within the receiver’s border and the button is active. 
   * If <code>show</code> is <code>false</code>, the receiver’s border continues
   * to be displayed when the cursor is outside button’s bounds.</p>
   */
  public function setShowsBorderOnlyWhileMouseInside(show:Boolean) {
    m_showsBorderOnlyWhileMouseInside = show;
    
    if (show && m_trackingTag == null) {
      m_waitingToTrackMouse = true;
    }
    else if (!show && m_trackingTag != null) {
      controlView().removeTrackingRect(m_trackingTag);
      m_trackingTag = null;
      m_trackingRect = null;
      m_waitingToTrackMouse = false;
    }
  }

  /**
   * <p>Returns <code>true</code> if the button cell only displays its border while
   * the mouse is hovering.</p>
   * 
   * <p>By default, this method returns <code>false</code>.</p>
   * 
   * @see #setShowsBorderOnlyWhileMouseInside()
   */
  public function showsBorderOnlyWhileMouseInside():Boolean {
    return m_showsBorderOnlyWhileMouseInside;
  }

  /**
   * Sets whether the button cell's image should dim when the button cell is
   * disabled.
   */
  public function setImageDimsWhenDisabled(value:Boolean) {
    m_imageDimsWhenDisabled = value;
  }

  /**
   * Returns <code>true</code> if the button cell's image should dim if the
   * button is disabled, or <code>false</code> otherwise.
   */
  public function imageDimsWhenDisabled():Boolean {
    return m_imageDimsWhenDisabled;
  }

  /**
   * Sets the button cell's bezel style to <code>value</code>.
   */
  public function setBezelStyle(value:NSBezelStyle) {
    m_bezelStyle = value;
  }

  /**
   * Returns the button cell's bezel style.
   */
  public function bezelStyle():NSBezelStyle {
    return m_bezelStyle;
  }

  //******************************************************
  //*                  Displaying
  //******************************************************

  /**
   * Returns the buttons type.
   */
  public function buttonType():NSButtonType {
    return m_buttonType;
  }
  
  /**
   * Sets how the button cell highlights when pressed, and how it shows its
   * state.
   */
  public function setButtonType(type:NSButtonType) {
    switch(type.value) {
      case NSButtonType.NSMomentaryLightButton.value:
        setHighlightsBy(NSPushInCellMask | NSChangeGrayCellMask);
        setShowsStateBy(NSChangeBackgroundCellMask);
        setImageDimsWhenDisabled(true);
        break;
      case NSButtonType.NSPushOnPushOffButton.value:
        setHighlightsBy(NSPushInCellMask | NSChangeGrayCellMask);
        setShowsStateBy(NSChangeBackgroundCellMask);
        setImageDimsWhenDisabled(true);
        break;
      case NSButtonType.NSToggleButton.value:
        setHighlightsBy(NSPushInCellMask | NSContentsCellMask);
        setShowsStateBy(NSContentsCellMask);
        setImageDimsWhenDisabled(true);
        break;
      case NSButtonType.NSRadioButton.value:
        setHighlightsBy(NSContentsCellMask);
        setShowsStateBy(NSContentsCellMask);
        setAlignment(NSTextAlignment.NSLeftTextAlignment);
        setupRadioButtonImages();
        setImagePosition(NSCellImagePosition.NSImageLeft);
        setBordered(false);
        setBezeled(false);
        setImageDimsWhenDisabled(false);
        break;
      case NSButtonType.NSSwitchButton.value:
        setHighlightsBy(NSContentsCellMask);
        setShowsStateBy(NSContentsCellMask);
        setAlignment(NSTextAlignment.NSLeftTextAlignment);
        setupSwitchImages();
        setImagePosition(NSCellImagePosition.NSImageLeft);
        setBordered(false);
        setBezeled(false);
        setImageDimsWhenDisabled(true);
        break;
      case NSButtonType.NSMomentaryChangeButton.value:
        setHighlightsBy(NSContentsCellMask);
        setShowsStateBy(NSNoCellMask);
        setImageDimsWhenDisabled(true);
        break;
      case NSButtonType.NSOnOffButton.value:
        setHighlightsBy(NSChangeBackgroundCellMask);
        setShowsStateBy(NSChangeBackgroundCellMask);
        setImageDimsWhenDisabled(true);
        break;
      case NSButtonType.NSMomentaryPushInButton.value:
        setHighlightsBy(NSPushInCellMask | NSChangeGrayCellMask);
        setShowsStateBy(NSNoCellMask);
        setImageDimsWhenDisabled(true);
        break;
    }
    
    m_buttonType = type;
  }

  /**
   * Sets the way the button cell highlights when pressed.
   */
  public function setHighlightsBy(value:Number) {
    m_highlightsBy = value;
  }

  /**
   * Returns the way the button cell highlights when pressed.
   */
  public function highlightsBy():Number {
    return m_highlightsBy;
  }

  /**
   * Sets the way the button cell displays its alternate state to
   * <code>value</code>.
   */
  public function setShowsStateBy(value:Number) {
    m_showsStateBy = value;
  }

  /**
   * Returns the way the button cell displays its alternate state.
   */
  public function showsStateBy():Number {
    return m_showsStateBy;
  }
  
  //******************************************************
  //*          Getting and setting cell values
  //******************************************************

  /**
   * Sets the cell's object value to <code>value</code>.
   */
  public function setObjectValue(value:Object) {
    if (value == null) {
    	setState(NSOffState);
    }
    else if (ASUtils.respondsToSelector(value, "intValue")) {
    	setState(value["intValue"]);
    } else {
    	setState(NSOnState);	
    }
  }

  /**
   * Returns the cell's object value unless if it is valid, otherwise
   * <code>null</code>.
   */
  public function objectValue():Object {
  	var state:Number = state();
    if (state == NSOffState) {
    	return NSNumber.numberWithInt(0);
    }
    else if (state == NSOnState) {
    	return NSNumber.numberWithInt(1);
    } else {
    	return NSNumber.numberWithInt(-1);
    }
  }

  /**
   * Sets the value of the cell to an object <code>value</code>, representing
   * an integer value.
   */
  public function setIntValue(value:Number) {
    setState((value != 0) ? 1 : 0);
  }

  /**
   * Returns the cell’s value as an int.
   */
  public function intValue():Number {
    return state();
  }

  /**
   * Sets the value of the cell to an object <code>value</code>, representing
   * a double value.
   */
  public function setDoubleValue(value:Number) {
    setState((value != 0) ? 1 : 0);
  }

  /**
   * Returns the cell’s value as a double.
   */
  public function doubleValue():Number {
    return state();
  }

  /**
   * Sets the value of the cell to an object <code>value</code>, representing
   * a float value.
   */
  public function setFloatValue(value:Number) {
    setState((value != 0) ? 1 : 0);
  }

  /**
   * Returns the cell’s value as a float.
   */
  public function floatValue():Number {
    return state();
  }
  
  //******************************************************
  //*                  Playing sound
  //******************************************************

  public function setSound(value:NSSound) {
    m_sound = value;
  }

  public function sound():NSSound {
    return m_sound;
  }

  //******************************************************
  //*        Handling events and action messages
  //******************************************************

  public function mouseEntered(event:NSEvent) {
    m_mouseInside = true;
    
    if (showsBorderOnlyWhileMouseInside()) {
      NSView(event.userData).setNeedsDisplay(true);
    }
  }

  public function mouseExited(event:NSEvent) {
    m_mouseInside = false;

    if (showsBorderOnlyWhileMouseInside()) {
      NSView(event.userData).setNeedsDisplay(true);
    }
  }

  public function performClickWithFrameInView(frame:NSRect, view:NSView) {
    if (m_sound != null) {
      m_sound.play();
    }
    super.performClickWithFrameInView(frame, view);
  }

  /**
   * Overridden to prevent next state if we are a checkbox or a radio button.
   */
  private function __performClickCallback(timer:NSTimer) {
    var info:Object = timer.userInfo();
    
    if (m_buttonType != NSButtonType.NSSwitchButton || m_buttonType != NSButtonType.NSRadioButton) {
      setHighlighted(false);
      setNextState();
      NSControl(info.view).sendActionTo(action(), target());
    }
    
    NSControl(info.view).drawCell(this);
  }

  //******************************************************
  //*                 Comparing cells
  //******************************************************
  
  /**
   * <p>Compares the string values of the cell and <code>otherObject</code> (which 
   * must be a kind of <code>NSButtonCell</code>), disregarding case.</p>
   */
  public function compare(otherObject:Object):NSComparisonResult {
    if (!(otherObject instanceof NSButtonCell)) {
      var e:NSException = NSException.exceptionWithNameReasonUserInfo(
      	NSException.NSBadComparisonException,
      	"A button cell can only be compared with another button cell",
      	null);
      trace(e);
      throw e;
    }
    
  	return super.compare(otherObject);
  }

  //******************************************************
  //*                    Drawing
  //******************************************************

  /**
   * Overridden to set images properly.
   */
  public function setControlSize(csize:NSControlSize):Void {
    super.setControlSize(csize);
    
    switch (m_buttonType) {
      case NSButtonType.NSRadioButton:
        setupRadioButtonImages();
        break;
        
      case NSButtonType.NSSwitchButton:
        setupSwitchImages();
        break;
    }
  }
  
  public function cellSize():NSSize {
    var size:NSSize = new NSSize(0,0);
    var titleSize:NSSize;
    var imageSize:NSSize;
    var borderSize:NSSize;
    var mask:Number;
    var image:NSImage;
    var title:NSAttributedString;

    if (m_highlighted) {
      mask = m_highlightsBy;
      if (m_state == 1) {
        mask &= ~m_showsStateBy;
      }
    } else if (m_state == 1) {
      mask = m_showsStateBy;
    } else {
      mask = NSCell.NSNoCellMask;
    }

    if (mask & NSCell.NSContentsCellMask) {
      image = m_alternateImage;
      if (image == null) {
        image = m_image;
      }
      title = attributedAlternateTitle();
      if (title == null || title.string().length==0) {
        title = attributedTitle();
      }
    } else {
      image = m_image;
      title = attributedTitle();
    }

    if (title != null) {
      titleSize = m_font.getTextExtent(title.string());
      titleSize.height -= 1;
    }
    if (image != null) {
      imageSize = image.size().clone();
    }

    switch (m_imagePosition) {
    case NSCellImagePosition.NSNoImage:
      size = titleSize;
      break;
    case NSCellImagePosition.NSImageOnly:
      size = imageSize;
      break;
    case NSCellImagePosition.NSImageLeft:
    case NSCellImagePosition.NSImageRight:
      size.width = titleSize.width + imageSize.width + 5;
      size.height = Math.max(imageSize.height, titleSize.height);
      break;
    case NSCellImagePosition.NSImageBelow:
    case NSCellImagePosition.NSImageAbove:
      size.width = Math.max(imageSize.width, titleSize.width);
      size.height = imageSize.height + titleSize.height + 3;
      break;
    case NSCellImagePosition.NSImageOverlaps:
      size.width = Math.max(imageSize.width, titleSize.width);
      size.height = Math.max(imageSize.height, titleSize.height);
      break;
    }

    if (m_bordered) {
      borderSize = new NSSize(3,3);
    } else {
      borderSize = new NSSize(0,0);
    }
    if ((m_bordered && m_imagePosition != NSCellImagePosition.NSImageOnly)
        || m_bezeled) {
      borderSize.width += 6;
      borderSize.height += 6;
    }
    size.width += borderSize.width;
    size.height += borderSize.height;
    return size;
  }

  public function drawWithFrameInView(cellFrame:NSRect, inView:NSView) {
    if (m_controlView != inView) {
      //
      // Change the control view if necessary
      //
      setControlView(inView);
    }
    else if (m_showsBorderOnlyWhileMouseInside && !cellFrame.isEqual(m_trackingRect)) {
      //
      // If we're tracking for border visibility reasons, and the cellFrame has
      // changed, we'll remove the current tracking rect.
      //
      if (m_trackingTag != null) {
        controlView().removeTrackingRect(m_trackingTag);
        m_trackingTag = null;
      }
      
      m_trackingRect = cellFrame.clone();
      m_waitingToTrackMouse = true;
    }
    
    if (m_bcellTransparent) { // Do nothing if transparent
      return;
    }
    
    //
    // Add a tracking rect if necessary
    //
    if (m_waitingToTrackMouse) {
      var cv:NSView = controlView();
      m_trackingTag = cv.addTrackingRectOwnerUserDataAssumeInside(
        cellFrame, this, cv, false);

      //
      // Check if the mouse cursor is currently inside the control view's frame
      //
      if (cv.convertRectFromView(cv.frame(), cv).pointInRect(
          NSApplication.sharedApplication().currentEvent().mouseLocation)) {
        m_mouseInside = true;
      }

      m_waitingToTrackMouse = false;
    }
    
    //
    // Don't draw anything if we don't have access to mcBounds
    //
    try {
    	controlView().mcBounds();
    } catch (e:NSException) {
    	return;
    }
    
    //
    // Draw the cell
    //
    if ((m_bordered) &&
  	    (!m_showsBorderOnlyWhileMouseInside || m_mouseInside)) {
  	  // TODO make better borders
  	  drawBorderWithFrameInView(cellFrame, m_controlView);
  	}
  	else if (m_bezeled) {
  	  drawBezelWithFrameInView(cellFrame, m_controlView);
  	}
    
    drawInteriorWithFrameInView(cellFrame, inView);
  }
  
  private function drawBorderWithFrameInView(cellFrame:NSRect, inView:NSView):Void {
    ASTheme.current().drawBoxBorderWithRectInViewExcludeRectBorderType(
  	  cellFrame, inView, null, NSBorderType.NSBezelBorder);
  }

  private function drawBezelWithFrameInView(cellFrame:NSRect, inView:NSView):Void {
    ASTheme.current().drawButtonCellBorderInRectOfView(this, cellFrame, inView);
  }

  /**
   * Draws the "inside" of the cell. No border is drawn.
   */
  public function drawInteriorWithFrameInView(cellFrame:NSRect, inView:NSView) {
    //
    // Set the control view
    //
    if (m_controlView != inView) {
      setControlView(inView);
    }
    
    //
    // Do nothing if transparent
    //
    if (m_bcellTransparent) { 
      return;
    }
    
    /*
    cellFrame = drawingRectForBounds(cellFrame);
    if (m_bordered || m_bezeled) { // inset a bit more
      cellFrame = cellFrame.insetRect(3,1);
    }*/

    var mc:MovieClip;
    try {
    	mc = controlView().mcBounds();
    } catch (e:NSException) {
    	return;
    } 
    var titleSize:NSSize;
    var imageRect:NSRect = new NSRect(0,0,0,0);
    var mask:Number;
    var image:NSImage;
    var title:NSAttributedString;

    //
    // Determine mask
    //
    if (m_highlighted) {
      mask = m_highlightsBy;
      if (m_state == 1) {
        mask &= ~m_showsStateBy;
      }
    } else if (m_state == 1) {
      mask = m_showsStateBy;
    } else {
      mask = NSCell.NSNoCellMask;
    }

    //
    // Draw background
    //
    drawBackgroundWithFrameMaskInView(cellFrame, mask, inView);

    //
    // Get image and title based on the mask
    //
    if (mask & NSCell.NSContentsCellMask) {
      image = m_alternateImage;

      if (image == null || !m_enabled) {
        image = m_image;
      }
      title = attributedAlternateTitle();
      if (title == null || title.string().length==0) {
        title = attributedTitle();
      }
    } else {
      image = m_image;
      title = attributedTitle();
    }
    
    //
    // Get the image and title sizes
    //
    if (title != null) {
      titleSize = m_font.getTextExtent(title.string());
      titleSize.height -= 1;
    }
    
    if (image != null) {
      imageRect.size = image.size().clone();
    }
    
    //
    // Draw the title
    //
    drawTitleWithFrameInView(title, m_controlView);

    //
    // Position the title and image
    //
    imageRect.origin = positionParts(cellFrame, imageRect.size, titleSize);
    
    //
    // Offset the title and image if showing a highlight and bezeled
    //
    if (m_bezeled && (m_highlighted  || (mask & (NSChangeGrayCellMask | NSChangeBackgroundCellMask)))) {
      m_textField._x += 1;
      m_textField._y += 1;
      imageRect.origin.x += 1;
      imageRect.origin.y += 1;
    }
    
    //
    // Draw the image
    //
    drawImageWithFrameInView(image, cellFrame, m_controlView, imageRect);
    
    //
    // Draw first responder
    //
    if (m_showsFirstResponder) {
      if (image != null && m_buttonType == NSButtonType.NSSwitchButton) {
        drawFirstResponderWithRectInView(new NSRect(
				imageRect.origin.x-1, imageRect.origin.y-1,
				imageRect.size.width+2, imageRect.size.height+2), inView);
      } else {
        drawFirstResponderWithRectInView(cellFrame, inView);
      }
    }
  }
  
  /**
   * Override to provide more specific behavior.
   */
  private function drawFirstResponderWithRectInView(cellFrame:NSRect, inView:NSView):Void {
    ASTheme.current().drawFirstResponderWithRectInView(cellFrame, inView);
  }
  
  /**
   * Draws the background given a frame rectangle, a mask that indicates
   * highlighting conditions and a view to draw in. 
   */
  private function drawBackgroundWithFrameMaskInView(frame:NSRect, mask:Number, 
      controlView:NSView):Void {
    if (!m_bordered) {
      var bg:NSColor = null;
      if (mask & NSChangeBackgroundCellMask) {
        bg = ASColors.whiteColor();
      } else {
        bg = backgroundColor();
      }
      
      if (bg != null) {
        ASTheme.current().drawFillWithRectColorInView(frame, bg, controlView);
      } 
    } 
    else if (m_bezeled) {
      drawBezelWithFrameInView(frame, controlView);
    }
  }
  
  private function drawTitleWithFrameInView(title:NSAttributedString, controlView:NSView):Void {
    var tfUpdated:Boolean = validateTextFormat();
  	if (m_textField == null || m_textField._parent == undefined) {
      m_textField = controlView.createBoundsTextField();
      m_textField.autoSize = true;
      m_textField.selectable = false;
      m_textField.multiline = true;
      m_textField._alpha = m_fontColor.alphaComponent()*100;
      m_textField.embedFonts = m_font.isEmbedded();
      m_textField.type = "dynamic";
      m_textField.antiAliasType = "advanced";
    }
    
      if (m_font.pointSize() > 20) {
    	m_textField.gridFitType = "none";
      } else {
	    m_textField.gridFitType = m_alignment == NSTextAlignment.NSLeftTextAlignment ? 
	    	"pixel" : "subpixel";
      }

    if (title.string() == null) {
      m_textField.text = "";
    } else if (m_textField.text != title.string()) {
      if (title.isFormatted()) {
        m_textField.html = true;
        m_textField.htmlText = title.htmlString();
      } else {
        m_textField.text = title.string();
        m_textField.setTextFormat(m_textFormat);
      }
    }
    if (tfUpdated) {
      m_textField.setTextFormat(m_textFormat);
    }

    if (m_imagePosition == NSCellImagePosition.NSImageOnly) {
      m_textField._visible = false;
    } else {
      m_textField._visible = true;
    }
  }

  private function drawImageWithFrameInView(image:NSImage, cellFrame:NSRect, inView:NSView,
      imageRect:NSRect):Void {
    if (image != null && m_imagePosition != NSCellImagePosition.NSNoImage) {
      var mc:MovieClip;
      try {
        mc = inView.mcBounds();
      } catch (e:Error) {
        return;
      }
      
      image.lockFocus(mc);
      image.drawAtPoint(imageRect.origin);
      image.unlockFocus();
      
      if (!m_enabled && m_imageDimsWhenDisabled) {
        ASTheme.current().dimImageCanvasInViewWithFactor(image, inView, 0.3);
      }
    }
  }
  
  /**
   * <p>Sets the receiver’s control view.</p>
   * 
   * <p>The control view represents the control currently being rendered by the 
   * cell.</p>
   * 
   * @see #controlView()
   */  
  public function setControlView(view:NSView) {
    if (m_trackingTag != null) {
      m_controlView.removeTrackingRect(m_trackingTag);
      m_trackingTag = null;
    }
    
    m_controlView = view;
    m_waitingToTrackMouse = m_controlView != null 
        && m_showsBorderOnlyWhileMouseInside;
  }
  
  private function validateTextFormat():Boolean {
    var updated:Boolean = false;
    if (m_textFormat == null) {
      m_textFormat = m_font.textFormat();
      updated = true;
    }
    var color:Number = m_enabled ? m_fontColor.value : ASTheme.current(
    	).colorWithName(ASThemeColorNames.ASDisabledText).value;
    if (m_textFormat.color != color) {
      m_textFormat.color = color;
      updated = true;
    }
    switch(m_alignment) {
      case NSTextAlignment.NSRightTextAlignment:
        if (m_textFormat.align != "right") {
	        m_textFormat.align = "right";
	        updated = true;
	      }
        break;
      case NSTextAlignment.NSCenterTextAlignment:
        if (m_textFormat.align != "center") {
          m_textFormat.align = "center";
          updated = true;
        }
        break;
      case NSTextAlignment.NSLeftTextAlignment:
        default:
        if (m_textFormat.align != "left") {
	        m_textFormat.align = "left";
	        updated = true;
	      }
        break;
    }
    return updated;
  }

  private function positionParts(cellFrame:NSRect, imageSize:NSSize,
      titleSize:NSSize):NSPoint {
    var borderSize:NSSize;

    if (m_bordered) {
      borderSize = new NSSize(3,3);
    } else {
      borderSize = new NSSize(0,0);
    }
    if ((m_bordered && m_imagePosition != NSCellImagePosition.NSImageOnly)
        || m_bezeled) {
      borderSize.width += 6;
      borderSize.height += 6;
    }
    
    var imageLocation:NSPoint = new NSPoint(0,0);
    var x:Number = cellFrame.origin.x;
    var y:Number = cellFrame.origin.y;
    var width:Number = cellFrame.size.width-1;
    var height:Number = cellFrame.size.height-1;
	
    var combinedHeight:Number = imageSize.height+titleSize.height+3;
    var combinedWidth:Number = imageSize.width+titleSize.width+3;

    switch (m_imagePosition) {
      case NSCellImagePosition.NSNoImage:
        m_textField._y = int(y + (height - titleSize.height)/2);
        switch(m_alignment) {
          case NSTextAlignment.NSRightTextAlignment:
            m_textField._x = int(x + width - borderSize.width/2 - titleSize.width);
            break;
          case NSTextAlignment.NSLeftTextAlignment:
            m_textField._x = int(borderSize.width/2);
            break;
          case NSTextAlignment.NSCenterTextAlignment :
          default:
            m_textField._x = int(x + (width - titleSize.width)/2);
            break;
        }
        break;

      case NSCellImagePosition.NSImageOnly:
        
        imageLocation.x = x + (width - imageSize.width)/2;
        imageLocation.y = y + (height - imageSize.height)/2;
        
        break;

      case NSCellImagePosition.NSImageLeft:
        switch(m_alignment) {
          case NSTextAlignment.NSRightTextAlignment:
            imageLocation.x = x + width - combinedWidth - borderSize.width/2
              - 1;
            break;
          case NSTextAlignment.NSCenterTextAlignment:
            imageLocation.x = x + (width - combinedWidth)/2;
            break;
          case NSTextAlignment.NSLeftTextAlignment:
          default:
            imageLocation.x = x + borderSize.width/2 + 1;
            break;
        }
        imageLocation.y = y + (height - imageSize.height)/2;
        m_textField._x = imageLocation.x + imageSize.width + 3;
        m_textField._y = y + (height - titleSize.height)/2;
        break;

      case NSCellImagePosition.NSImageRight:
        switch(m_alignment) {
          case NSTextAlignment.NSRightTextAlignment:
            imageLocation.x = x + width - imageSize.width - borderSize.width/2
              - 1;
            break;
          case NSTextAlignment.NSCenterTextAlignment:
            imageLocation.x = x + (width - combinedWidth)/2 + titleSize.width
              + 3;
            break;
          case NSTextAlignment.NSLeftTextAlignment:
          default:
            imageLocation.x = x + borderSize.width/2 + 1 + combinedWidth
              - imageSize.width;
            break;
        }
        imageLocation.y = y + (height - imageSize.height)/2;
        m_textField._x = imageLocation.x - titleSize.width - 3;
        m_textField._y = y + (height - titleSize.height)/2;
        break;

      case NSCellImagePosition.NSImageBelow:
        m_textField._x = x + (width - titleSize.width)/2;
        imageLocation.x = x + (width - imageSize.width)/2;
        m_textField._y = y + (height - combinedHeight)/2;
        imageLocation.y = m_textField._y + titleSize.height + 3;
        break;

      case NSCellImagePosition.NSImageAbove:
        imageLocation.x = x + (width - imageSize.width)/2;
        imageLocation.y = y + (height - combinedHeight)/2;
        m_textField._x = x + (width - titleSize.width)/2;
        m_textField._y = y + imageLocation.y + imageSize.height + 3;
        break;

      case NSCellImagePosition.NSImageOverlaps:
        imageLocation.x = x + (width - imageSize.width)/2;
        imageLocation.y = y + (height - imageSize.height)/2;
        m_textField._x = x + (width - titleSize.width)/2;
        m_textField._y = y + (height - titleSize.height)/2;
        break;
    }

    return imageLocation;
  }
  
  //******************************************************
  //*        Setting up switch and radio images
  //******************************************************
  
  private function setupSwitchImages():Void {
    switch (m_controlSize) {
      case NSControlSize.NSRegularControlSize:
        setImage(NSImage.imageNamed(ASThemeImageNames.NSRegularSwitchImage));
        setAlternateImage(NSImage.imageNamed(ASThemeImageNames.NSRegularHighlightedSwitchImage));
        break;
        
      case NSControlSize.NSMiniControlSize:
        setImage(NSImage.imageNamed(ASThemeImageNames.NSMiniSwitchImage));
        setAlternateImage(NSImage.imageNamed(ASThemeImageNames.NSMiniHighlightedSwitchImage));
        break;

      case NSControlSize.NSSmallControlSize:
        setImage(NSImage.imageNamed(ASThemeImageNames.NSSmallSwitchImage));
        setAlternateImage(NSImage.imageNamed(ASThemeImageNames.NSSmallHighlightedSwitchImage));
        break;
    }
  }

  private function setupRadioButtonImages():Void {
    switch (m_controlSize) {
      case NSControlSize.NSRegularControlSize:
        setImage(NSImage.imageNamed(ASThemeImageNames.NSRegularRadioButtonImage));
        setAlternateImage(NSImage.imageNamed(ASThemeImageNames.NSRegularHighlightedRadioButtonImage));
        break;
        
      case NSControlSize.NSMiniControlSize:
        setImage(NSImage.imageNamed(ASThemeImageNames.NSMiniRadioButtonImage));
        setAlternateImage(NSImage.imageNamed(ASThemeImageNames.NSMiniHighlightedRadioButtonImage));
        break;

      case NSControlSize.NSSmallControlSize:
        setImage(NSImage.imageNamed(ASThemeImageNames.NSSmallRadioButtonImage));
        setAlternateImage(NSImage.imageNamed(ASThemeImageNames.NSSmallHighlightedRadioButtonImage));
        break;
    }
  }
  
  //******************************************************															 
  //*                     Internal
  //******************************************************
  
  /**
   * Returns the text field that is used internally by this button cell.
   */
  public function internalTextField():TextField {
  	return m_textField;
  }
  
  /**
   * <p>Removes the button's textfield.</p>
   * 
   * <p>For internal use only.</p>
   */
  public function removeTextField():Void {
    if (m_textField != null) {
      m_textField.removeTextField();
      m_textField = null;
    }
  }
  
}