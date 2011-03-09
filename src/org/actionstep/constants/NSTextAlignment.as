/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * These constants specify text alignment.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSTextAlignment extends ASConstantValue {
  
  /**
   * Text is visually left aligned.
   */
  public static var NSLeftTextAlignment:NSTextAlignment = new NSTextAlignment(0);
  
  /**
   * Text is visually right aligned.
   */
  public static var NSRightTextAlignment:NSTextAlignment = new NSTextAlignment(1);
  
  /**
   * Text is visually center aligned.
   */
  public static var NSCenterTextAlignment:NSTextAlignment = new NSTextAlignment(2);
  
  /**
   * <p>Text is justified.</p>
   * 
   * <p>Justified text is not supported, and defaults to left alignment.</p>
   */
  public static var NSJustifiedTextAlignment:NSTextAlignment = new NSTextAlignment(3);
  
  /**
   * <p>Use the natural alignment of the text’s script.</p>
   * 
   * <p>Naturally aligned text is not supported, and defaults to left 
   * alignment.</p>
   */
  public static var NSNaturalTextAlignment:NSTextAlignment = new NSTextAlignment(4);
  
  /**
   * Hold strings for the text format object <code>align</code> property.
   */
  private static var g_strings:Array = ["left", "right", "center", "left", "left"];
  
  /**
   * A map of string to constants.
   */
  private static var g_strToConst:Object = {};
  
  /**
   * The alignment value of the constant as applied to a text format object.
   */
  public var string:String;
  
  /**
   * Constructs a new constant.
   */
  private function NSTextAlignment(num:Number) {
    super(num);
    string = g_strings[num];
    if (g_strToConst[string] == null) {
      g_strToConst[string] = this;
    }
  }

  /**
   * <p>
   * Returns the constant representation of the string <code>string</code>.
   * </p>
   * 
   * <p><code>string</code> should contain the value of a text format's align
   * property.</p>
   */
  public static function constantForString(string:String):NSTextAlignment {
    return g_strings[string];
  }
}