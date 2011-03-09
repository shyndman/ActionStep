/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.ASConstantValue;

class org.actionstep.constants.NSScrollerArrow extends ASConstantValue {
  
  static var NSScrollerIncrementArrow:NSScrollerArrow = new NSScrollerArrow(0);
  static var NSScrollerDecrementArrow:NSScrollerArrow = new NSScrollerArrow(1);
  
  private function NSScrollerArrow(num:Number) {
    super(num);
  }
}

