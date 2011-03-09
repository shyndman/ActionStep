/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.ASConstantValue;

/**
 * Describe the positions of the scroll buttons within an
 * <code>org.actionstep.NSScroller</code> instance.
 */
class org.actionstep.constants.NSScrollArrowPosition extends ASConstantValue {
  /**
   * Default button location.
   */
  static var NSScrollerArrowsDefaultSetting:NSScrollArrowPosition 
    = new NSScrollArrowPosition(0);
    
  /**
   * No buttons.
   */
  static var NSScrollerArrowsNone:NSScrollArrowPosition 
    = new NSScrollArrowPosition(2);
  
  /**
   * Creates a new instance of the <code>NSScrollArrowPosition</code> class.
   */
  private function NSScrollArrowPosition(num:Number) {
    super(num);
  }
}

