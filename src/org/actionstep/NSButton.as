/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSBezelStyle;
import org.actionstep.constants.NSButtonType;
import org.actionstep.constants.NSCellImagePosition;
import org.actionstep.NSAttributedString;
import org.actionstep.NSButtonCell;
import org.actionstep.NSCell;
import org.actionstep.NSControl;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSRect;
import org.actionstep.NSSound;

/**
 * <p>A clickable button.</p>
 *
 * <p>The <code>NSButton</code> can assume many different forms. It can be used
 * as a toggle button, a radio button, a check box or a standard button. It has
 * support for displaying images and text.</p>
 *
 * <p>The <code>NSButton</code> uses the {@link NSButtonCell} class to implement
 * its interface.</p>
 *
 * <p>For an example of this class' usage, please see the test classes in the
 * {@link org.actionstep.test.*} namespace (it's used all over the place).</p>
 *
 * <p>For examples of all of the button types, please see
 * {@link org.actionstep.test.ASTestButtonTypes}.</p>
 *
 * @author Richard Kilmer
 */
class org.actionstep.NSButton extends NSControl {

  private static var g_cellClass:Function = org.actionstep.NSButtonCell;

  //******************************************************
  //*                   Construction
  //******************************************************

  /**
   * Initializes an <code>NSButton</code> with a frame rectangle of
   * <code>rect</code>.
   */
  public function initWithFrame(rect:NSRect):NSButton {
    super.initWithFrame(rect);
    return this;
  }

  //******************************************************
  //*             Setting the button type
  //******************************************************

  /**
   * Returns the buttons type.
   */
  public function buttonType():NSButtonType {
    return NSButtonCell(m_cell).buttonType();
  }
  
  /**
   * Sets the type of this button to <code>type</code>.
   *
   * This method marks the button as needing redisplay.
   */
  public function setButtonType(type:NSButtonType) {
    NSButtonCell(m_cell).setButtonType(type);
    setNeedsDisplay(true);
  }

  //******************************************************
  //*              Describing the object
  //******************************************************

  /**
   * Returns a string representation of the button.
   */
  public function description():String {
    return "NSButton(title=" + title() + ")";
  }

  //******************************************************
  //*                 Setting the state
  //******************************************************

  /**
   * Returns <code>true</code> if this button has three states, on, off and
   * mixed.
   */
  public function allowsMixedState():Boolean {
    return m_cell.allowsMixedState();
  }

  /**
   * Sets whether this button has on, off and mixed states. If
   * <code>value</code> is <code>true</code>, it will.
   */
  public function setAllowsMixedState(value:Boolean) {
    m_cell.setAllowsMixedState(value);
  }

  /**
   * Sets this button into its next state.
   *
   * If the button has two states, the state will toggle between on and off.
   * If the button has three states, the state will move in the following
   * order "on, off, mixed, on, ..." and so on.
   */
  public function setNextState() {
    m_cell.setNextState();
    setNeedsDisplay(true);
  }

  /**
   * Sets the state of the button to <code>state</code>, which can be
   * <code>NSCell#NSOffState</code>, <code>NSCell#NSOnState</code> or
   * <code>NSCell#NSMixedState</code>.
   *
   */
  public function setState(state:Number) {
    m_cell.setState(state);
  }

  /**
   * Returns the state of the button.
   */
  public function state():Number {
    return m_cell.state();
  }

  //******************************************************
  //*           Setting the repeat interval
  //******************************************************

  /**
   * <p>Returns by reference the delay and interval periods for a continuous
   * button. The object contains <code>interval</code> and <code>delay</code>
   * properties.</p>
   *
   * <p><code>delay</code> is the amount of time (in seconds) the button will pause
   * before starting to periodically send action messages to the target object.
   * <code>interval</code> is the amount of time (also in seconds) between those
   * messages.</p>
   *
   * <p>The default values for <code>delay</code> and <code>interval</code> are
   * <code>0.4</code> seconds and <code>0.075</code> seconds respectively.</p>
   *
   * @see NSControl#isContinuous()
   * @see #setPeriodicDelayInterval()
   */
  public function getPeriodicDelayInterval():Object {
    return NSButtonCell(m_cell).getPeriodicDelayInterval();
  }

  /**
   * <p>Sets the message delay and interval for the receiver.</p>
   *
   * <p>These two values are used if the button is configured (by a
   * {@link #setContinuous} message) to continuously send the action message to
   * the target object while tracking the mouse. <code>delay</code> is the
   * amount of time (in seconds) that a continuous button will pause before
   * starting to periodically send action messages to the target object.
   * <code>interval</code> is the amount of time (also in seconds) between those
   * messages.</p>
   *
   * <p>The maximum value allowed for both <code>delay</code> and
   * <code>interval</code> is <code>60.0</code> seconds; if a larger value is
   * supplied, it is ignored, and <code>60.0</code> seconds is used.</p>
   *
   * @see NSControl#isContinuous()
   * @see #getPeriodicDelayInterval()
   */
  public function setPeriodicDelayInterval(delay:Number, interval:Number) {
    NSButtonCell(m_cell).setPeriodicDelayInterval(delay, interval);
  }


  //******************************************************
  //*               Setting the titles
  //******************************************************

  /**
   * Sets the string that appears on the button when it is in its alternate
   * state to <code>value</code>.
   */
  public function setAlternateTitle(value:String) {
    NSButtonCell(m_cell).setAlternateTitle(value);
    setNeedsDisplay(true);
  }

  /**
   * Returns the string that appears on the button when it is in its alternate
   * state.
   */
  public function alternateTitle():String {
    return NSButtonCell(m_cell).alternateTitle();
  }

  /**
   * Sets the string that appears on the button when it is in its normal state
   * to <code>value</code>.
   */
  public function setTitle(value:String) {
    NSButtonCell(m_cell).setTitle(value);
    setNeedsDisplay(true);
  }

  /**
   * Returns the string that appears on the button when it is in its normal
   * state.
   */
  public function title():String {
    return NSButtonCell(m_cell).title();
  }

  public function setAttributedTitle(value:NSAttributedString) {
    NSButtonCell(m_cell).setAttributedTitle(value);
    setNeedsDisplay(true);
  }

  public function attributedTitle():NSAttributedString {
    return NSButtonCell(m_cell).attributedTitle();
  }

  public function setAttributedAlternateTitle(value:NSAttributedString) {
    NSButtonCell(m_cell).setAttributedAlternateTitle(value);
    setNeedsDisplay(true);
  }

  public function attributedAlternateTitle():NSAttributedString {
    return NSButtonCell(m_cell).attributedAlternateTitle();
  }

  //******************************************************
  //*                Setting the images
  //******************************************************

  /**
   * Returns the image that appears on the button in its alternate state.
   */
  public function alternateImage():NSImage {
    return NSButtonCell(m_cell).alternateImage();
  }

  /**
   * Sets the image that appears on the button in its alternate state to
   * <code>image</code>.
   */
  public function setAlternateImage(image:NSImage) {
    NSButtonCell(m_cell).setAlternateImage(image);
  }

  /**
   * Returns the image that appears on the button in its normal state.
   */
  public function image():NSImage {
    return NSButtonCell(m_cell).image();
  }

  /**
   * Sets the image that appears on the button in its normal state to
   * <code>image</code>.
   */
  public function setImage(anImage:NSImage) {
    NSButtonCell(m_cell).setImage(anImage);
  }

  /**
   * Returns the position of the image on the button.
   */
  public function imagePosition():NSCellImagePosition {
    return NSButtonCell(m_cell).imagePosition();
  }

  /**
   * Sets the position of the image on the button to <code>position</code>.
   */
  public function setImagePosition(position:NSCellImagePosition) {
    NSButtonCell(m_cell).setImagePosition(position);
    setNeedsDisplay(true);
  }

  //******************************************************
  //*           Modifying graphics attributes
  //******************************************************

  /**
   * <p>Sets whether the receiver is transparent, depending on the Boolean value
   * <code>flag</code>, and redraws the receiver if necessary.</p>
   *
   * <p>A transparent button tracks the mouse and sends its action, but doesn’t
   * draw. A transparent button is useful for sensitizing an area on the screen
   * so that an action gets sent to a target when the area receives a mouse
   * click.</p>
   *
   * @see #isTransparent
   */
  public function setTransparent(value:Boolean) {
    if (NSButtonCell(m_cell).isTransparent() == value) {
      return;
    }

    NSButtonCell(m_cell).setTransparent(value);
    setNeedsDisplay(true);
  }

  /**
   * <p>Returns <code>true</code> if the receiver is transparent,
   * <code>false</code> otherwise.</p>
   *
   * <p>A transparent button never draws itself, but it receives mouse-down
   * events and tracks the mouse properly.</p>
   *
   * @see #setTransparent
   */
  public function isTransparent():Boolean {
    return NSButtonCell(m_cell).isTransparent();
  }

  /**
   * <p>Sets whether the receiver has a bezeled border.</p>
   *
   * <p>If <code>flag</code> is <code>true</code>, the receiver displays a border;
   * if <code>flag</code> is <code>false</code>, the receiver doesn’t display a
   * border. A button’s border is not the single line of most other controls’
   * borders—instead, it’s a raised bezel. This method redraws the button if
   * {@link #setBordered} causes the bordered state to change.</p>
   *
   * @see #isBordered
   */
  public function setBordered(value:Boolean) {
  	if (NSButtonCell(m_cell).isBordered() == value) {
  	  return;
  	}

    NSButtonCell(m_cell).setBordered(value);
    setNeedsDisplay(true);
  }

  /**
   * <p>Returns <code>true</code> if the receiver has a border,
   * <code>false</code> otherwise.</p>
   *
   * <p>A button’s border isn’t the single line of most other controls’ borders—
   * instead, it’s a raised bezel. By default, buttons are bordered.</p>
   *
   * @see #setBordered
   */
  public function isBordered():Boolean {
    return NSButtonCell(m_cell).isBordered();
  }

  /**
   * <p>Sets the appearance of the border, if the receiver has one.</p>
   * <p>If the button is not bordered, the bezel style is ignored.</p>
   *
   * @see #bezelStyle
   */
  public function setBezelStyle(style:NSBezelStyle) {
    NSButtonCell(m_cell).setBezelStyle(style);
    setNeedsDisplay(true);
  }

  /**
   * <p>Returns the appearance of the receiver’s border.</p>
   *
   * <p>Examine the documentation for the {@link NSBezelStyle} class for
   * information on specific styles.</p>
   *
   * @see #setBezelStyle
   */
  public function bezelStyle():NSBezelStyle {
    return NSButtonCell(m_cell).bezelStyle();
  }

  /**
   * <p>Sets whether the receiver’s border is displayed only when the cursor is
   * over the button.</p>
   *
   * <p>If <code>show</code> is <code>true</code>, the border is displayed only
   * when the cursor is within the button’s border and the button is active. If
   * <code>show</code> is <code>false</code>, the button’s border continues to
   * be displayed when the cursor is outside button’s bounds.</p>
   *
   * <p>If {@link #isBordered} returns <code>false</code>, the border is never
   * displayed, regardless of what this method returns.</p>
   *
   * @see #showsBorderOnlyWhileMouseInside
   */
  public function setShowsBorderOnlyWhileMouseInside(value:Boolean) {
    NSButtonCell(m_cell).setShowsBorderOnlyWhileMouseInside(value);
    setNeedsDisplay(true);
  }

  /**
   * <p>Returns <code>true</code> if the receiver’s border is displayed only when
   * the cursor is over the button and the button is active.</p>
   *
   * <p>By default, this method returns <code>false</code>.</p>
   *
   * <p>If {@link #isBordered} returns <code>false</code>, the border is never
   * displayed, regardless of what this method returns.</p>
   *
   * @see #setShowsBorderOnlyWhileMouseInside
   */
  public function showsBorderOnlyWhileMouseInside():Boolean {
    return NSButtonCell(m_cell).showsBorderOnlyWhileMouseInside();
  }

  //******************************************************
  //*                    Displaying
  //******************************************************

  /**
   * <p>Highlights (or unhighlights) the receiver according to <code>flag</code>.</p>
   *
   * <p>Highlighting may involve the button appearing “pushed in” to the screen,
   * displaying its alternate title or image, or causing the button to appear to
   * be “lit.” If the current state of the button matches <code>flag</code>, no
   * action is taken.</p>
   *
   * @see #setButtonType()
   */
  public function highlight(value:Boolean):Void {
  	var intValue:Number = Number(value ? NSCell.NSOnState : NSCell.NSOffState);

  	if (state() == intValue) {
  	  return;
  	}

    m_cell.highlightWithFrameInView(value, m_bounds, this);
  }

  //******************************************************
  //*            Setting the key equivalent
  //******************************************************

  /**
   * Returns the key-equivalent character of the button, or an empty string
   * if none is defined.
   */
  public function keyEquivalent():String {
    return NSButtonCell(m_cell).keyEquivalent();
  }

  /**
   * Returns a mask of modifier keys that must be pressed to perform the key
   * equivalent.
   *
   * The mask bits are defined in <code>NSEvent</code>.
   */
  public function keyEquivalentModifierMask():Number {
    return NSButtonCell(m_cell).keyEquivalentModifierMask();
  }

  /**
   * Sets the key equivalent character of the button to <code>value</code>.
   */
  public function setKeyEquivalent(value:String) {
    NSButtonCell(m_cell).setKeyEquivalent(value);
  }

  /**
   * Sets the key equivalent modifier mask of the button to <code>value</code>.
   *
   * The mask bits are defined in <code>NSEvent</code>.
   */
  public function setKeyEquivalentModifierMask(value:Number) {
    NSButtonCell(m_cell).setKeyEquivalentModifierMask(value);
  }

  //******************************************************
  //*        Handling events and action messages
  //******************************************************

  /**
   * If the character in <code>anEvent</code> matches the receiver’s key
   * equivalent, and the modifier flags in <code>anEvent</code> match the
   * key-equivalent modifier mask, {@link #performKeyEquivalent}: simulates the
   * user clicking the button and returning <code>true</code>. Otherwise,
   * {@link #performKeyEquivalent} does nothing and returns <code>false</code>.
   * {@link #performKeyEquivalent} also returns <code>false</code> in the event
   * that the receiver is blocked by a modal panel or the button is disabled.
   *
   * @see #keyEquivalentModifierMask()
   * @see #keyEquivalent()
   */
  public function performKeyEquivalent(anEvent:NSEvent):Boolean {
  	//! TODO Check for modal session

    //
    // Test the character and mask
    //
    var ke:String = keyEquivalent();

    if (ke == ""
        || anEvent.charactersIgnoringModifiers != ke
        || !anEvent.matchesModifiers(keyEquivalentModifierMask())) {
      return false;
    }

    performClick();
    return true;
  }

  //******************************************************
  //*                 Playing sound
  //******************************************************

  /**
   * <p>Sets the sound that’s played when the user presses the button to
   * <code>sound</code>.</p>
   *
   * <p>The sound is played during a mouse-down event, such as
   * {@link NSEvent#NSLeftMouseDown}.</p>
   *
   * @see #sound()
   */
  public function setSound(sound:NSSound) {
    NSButtonCell(m_cell).setSound(sound);
  }

  /**
   * Returns the sound that’s played when the user presses the button.
   *
   * @see #setSound()
   */
  public function sound():NSSound {
    return NSButtonCell(m_cell).sound();
  }

  //******************************************************
  //*                 First responder
  //******************************************************

  public function becomeFirstResponder():Boolean {
    m_cell.setShowsFirstResponder(true);
    setNeedsDisplay(true);
    return true;
  }

  public function resignFirstResponder():Boolean {
    m_cell.setShowsFirstResponder(false);
    setNeedsDisplay(true);
    return true;
  }

  public function becomeKeyWindow() {
    m_cell.setShowsFirstResponder(true);
    setNeedsDisplay(true);
  }

  public function resignKeyWindow() {
    m_cell.setShowsFirstResponder(false);
    setNeedsDisplay(true);
  }

  public function keyDown(event:NSEvent):Void {
    var character:Number = event.keyCode;
    if ((character ==  NSNewlineCharacter)
      || (character == NSEnterCharacter)
      || (character == NSCarriageReturnCharacter)
      || (character == 32)) {
      performClick(this);
      return;
    }

    super.keyDown(event);
  }

  public function acceptsFirstMouse(event:NSEvent):Boolean {
    return true;
  }
  
  //******************************************************
  //*             MovieClip (ActionStep-only)
  //******************************************************
  
  private function requiresMask():Boolean {
    return false;
  }

  //******************************************************
  //*              Required by NSControl
  //******************************************************

  public static function cellClass():Function {
    return g_cellClass;
  }

  public static function setCellClass(cellClass:Function) {
    if (cellClass == null) {
      g_cellClass = org.actionstep.NSButtonCell;
    } else {
      g_cellClass = cellClass;
    }
  }
}