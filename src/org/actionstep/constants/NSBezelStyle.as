/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;
 
//! TODO Add comments
class org.actionstep.constants.NSBezelStyle extends ASConstantValue {
  
  /**
   * A rounded rectangle button, designed for text.
   */
  public static var NSRoundedBezelStyle:NSBezelStyle = new NSBezelStyle(0);
  
  /**
   * A rectangular button with a 2 pixel border, designed for icons.
   */
  public static var NSRegularSquareBezelStyle:NSBezelStyle = new NSBezelStyle(1);
  
  /**
   * A rectangular button with a 3 pixel border, designed for icons.
   */
  public static var NSThickSquareBezelStyle:NSBezelStyle = new NSBezelStyle(2);
  
  /**
   * A rectangular button with a 4 pixel border, designed for icons.
   */
  public static var NSThickerSquareBezelStyle:NSBezelStyle = new NSBezelStyle(3);
  
  /**
   * A bezel style for use with a disclosure triangle. To create the disclosure 
   * triangle, set the button bezel style to {@link #NSDisclosureBezelStyle} and
   * the button type to {@link org.actionstep.constants.NSButtonType#NSOnOffButton}.
   * 
   * FIXME Implement this
   */
  public static var NSDisclosureBezelStyle:NSBezelStyle = new NSBezelStyle(4);
  
  /**
   * Similar to {@link #NSRegularSquareBezelStyle}, but has no shadow so you can
   * abut the cells without overlapping shadows. This style would be used in a 
   * tool palette, for example.
   */
  public static var NSShadowlessSquareBezelStyle:NSBezelStyle = new NSBezelStyle(5);
  
  /**
   * A round button with room for a small icon or a single character.
   */
  public static var NSCircularBezelStyle:NSBezelStyle = new NSBezelStyle(6);
  
  // I don't think should even be available
  // public static var NSTexturedSquareBezelStyle:NSBezelStyle = new NSBezelStyle(7);
  
  /**
   * A round button with a question mark providing the standard help button look.
   */
  public static var NSHelpButtonBezelStyle:NSBezelStyle = new NSBezelStyle(8);
  
  private function NSBezelStyle(value:Number) {
    super(value);
  }
}