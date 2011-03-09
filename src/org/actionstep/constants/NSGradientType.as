/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

class org.actionstep.constants.NSGradientType extends ASConstantValue {
  
  public static var NSGradientNone:NSGradientType = new NSGradientType(0);
  public static var NSGradientConcaveWeak:NSGradientType = new NSGradientType(1);
  public static var NSGradientConcaveStrong:NSGradientType = new NSGradientType(2);
  public static var NSGradientConvexWeak:NSGradientType = new NSGradientType(3);
  public static var NSGradientConvexStrong:NSGradientType = new NSGradientType(4);
  
  private function NSGradientType(num:Number) {
    super(num);
  }
}