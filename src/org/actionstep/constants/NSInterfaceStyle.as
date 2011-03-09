/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.ASConstantValue;

class org.actionstep.constants.NSInterfaceStyle extends ASConstantValue {
  
  static var NSNoInterfaceStyle:NSInterfaceStyle = new NSInterfaceStyle(0);
  static var NSNextStepInterfaceStyle:NSInterfaceStyle = new NSInterfaceStyle(1);
  static var NSWindows95InterfaceStyle:NSInterfaceStyle = new NSInterfaceStyle(2);
  static var NSMacintoshInterfaceStyle:NSInterfaceStyle = new NSInterfaceStyle(3);
  
  private function NSInterfaceStyle(num:Number) {
    super(num);
  }
}