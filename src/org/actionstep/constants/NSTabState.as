/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.ASConstantValue;

class org.actionstep.constants.NSTabState extends ASConstantValue {
  
  static var NSSelectedTab:NSTabState = new NSTabState(0);
  static var NSBackgroundTab:NSTabState = new NSTabState(1);
  static var NSPressedTab:NSTabState = new NSTabState(2);
    
  private function NSTabState(num:Number) {
    super(num);
  }

}
