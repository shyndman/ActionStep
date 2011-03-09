/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.ASConstantValue;

class org.actionstep.constants.NSScrollerPart extends ASConstantValue {
  
  static var NSScrollerNoPart:NSScrollerPart = new NSScrollerPart(0);
  static var NSScrollerDecrementPage:NSScrollerPart = new NSScrollerPart(1);
  static var NSScrollerKnob:NSScrollerPart = new NSScrollerPart(2);
  static var NSScrollerIncrementPage:NSScrollerPart = new NSScrollerPart(3);
  static var NSScrollerDecrementLine:NSScrollerPart = new NSScrollerPart(4);
  static var NSScrollerIncrementLine:NSScrollerPart = new NSScrollerPart(5);
  static var NSScrollerKnobSlot:NSScrollerPart = new NSScrollerPart(6);
    
  private function NSScrollerPart(num:Number) {
    super(num);
  }
  
  public function toString():String {
    return "NSScrollerPart("+value+")";
  }
}

