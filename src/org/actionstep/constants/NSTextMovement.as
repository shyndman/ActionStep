/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;
 
class org.actionstep.constants.NSTextMovement extends ASConstantValue {
  
  static var NSIllegalTextMovement:NSTextMovement = new NSTextMovement(0);
  static var NSReturnTextMovement:NSTextMovement = new NSTextMovement(1);
  static var NSTabTextMovement:NSTextMovement = new NSTextMovement(2);
  static var NSBacktabTextMovement:NSTextMovement = new NSTextMovement(3);
  static var NSLeftTextMovement:NSTextMovement = new NSTextMovement(4);
  static var NSRightTextMovement:NSTextMovement = new NSTextMovement(5);
  static var NSUpTextMovement:NSTextMovement = new NSTextMovement(6);
  static var NSDownTextMovement:NSTextMovement = new NSTextMovement(7);
  
  private function NSTextMovement(num:Number) {
    super(num);
  }

}

