/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.ASConstantValue;

class org.actionstep.constants.NSControlSize extends ASConstantValue {
  
  static var NSRegularControlSize:NSControlSize = new NSControlSize(0);
  static var NSSmallControlSize:NSControlSize = new NSControlSize(1);
  static var NSMiniControlSize:NSControlSize = new NSControlSize(2);
    
  private function NSControlSize(num:Number) {
    super(num);
  }
}