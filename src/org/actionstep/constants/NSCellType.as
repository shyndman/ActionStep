/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;
 
/**
 * These constants specify what a cell contains. They’re used by 
 * {@link org.actionstep.NSCell#setType()} and 
 * {@link org.actionstep.NSCell#type()}.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSCellType extends ASConstantValue {
  
  /**
   * Cell displays nothing.
   */
  static var NSNullCellType:NSCellType = new NSCellType(0);
  
  /**
   * Cell displays text.
   */
  static var NSTextCellType:NSCellType = new NSCellType(1);
  
  /**
   * Cell displays images.
   */
  static var NSImageCellType:NSCellType = new NSCellType(2);
  
  
  /**
   * Private to prevent construction.
   */
  private function NSCellType(num:Number) {
    super(num);
  }
}

