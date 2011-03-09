/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.ASConstantValue;

/**
 * These are button types that can be specified using
 * <code>org.actionstep.NSButton#setButtonType()</code>.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.constants.NSButtonType extends ASConstantValue {
  
  /**
   * While the mouse button is held down, the button is shown as "lit" and
   * pushed in if the button is bordered. This button type always displays
   * its normal text and image.
   */
  static var NSMomentaryLightButton:NSButtonType = new NSButtonType(0);
  
  /**
   * This button's first click causes the button to be pushed in. The second
   * click returns the button to its normal state.
   */
  static var NSPushOnPushOffButton:NSButtonType = new NSButtonType(1);
  
  /**
   * After the first click the button displays an alternate image and title.
   * The second click returns the button to its normal state.
   */
  static var NSToggleButton:NSButtonType = new NSButtonType(2);
  
  /**
   * This is an <code>NSToggleButton</code> with no border.
   */
  static var NSSwitchButton:NSButtonType = new NSButtonType(3);
  
  /**
   * Similar to <code>NSSwitchButton</code>, but uses special radio
   * button images.
   */
  static var NSRadioButton:NSButtonType = new NSButtonType(4);
  
  /**
   * While the mouse button is held down, this button displays its alternate
   * image and text. The normal image and text are displayed when the button
   * isn't pressed.
   */
  static var NSMomentaryChangeButton:NSButtonType = new NSButtonType(5);
  
  /**
   * The first click highlights the button. The second click returns the button
   * to its original state.
   */
  static var NSOnOffButton:NSButtonType = new NSButtonType(6);
  
  /**
   * The default button type. While the mouse button is held down, the button
   * is displayed "lit". This button type always displays its normal text and
   * image.
   */
  static var NSMomentaryPushInButton:NSButtonType = new NSButtonType(7);
    
    
  /**
   * Constructs a new instance of the <code>NSButtonType</code> class.
   */
  private function NSButtonType(num:Number) {
  	super(num);
  }
}
