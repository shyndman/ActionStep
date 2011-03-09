/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.ASConstantValue;

class org.actionstep.constants.NSControlTint extends ASConstantValue {
  
  static var NSDefaultControlTint:NSControlTint = new NSControlTint(0);
  static var NSBlueControlTint:NSControlTint = new NSControlTint(1);
  static var NSGraphiteControlTint:NSControlTint = new NSControlTint(6);
  static var NSClearControlTint:NSControlTint = new NSControlTint(7);
    
  private function NSControlTint(num:Number) {
    super(num);
  }
}