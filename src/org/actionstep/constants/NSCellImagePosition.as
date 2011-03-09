/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

class org.actionstep.constants.NSCellImagePosition extends ASConstantValue {
  
  public static var NSNoImage:NSCellImagePosition = new NSCellImagePosition(0);
  public static var NSImageOnly:NSCellImagePosition = new NSCellImagePosition(1);
  public static var NSImageLeft:NSCellImagePosition = new NSCellImagePosition(2);
  public static var NSImageRight:NSCellImagePosition = new NSCellImagePosition(3);
  public static var NSImageBelow:NSCellImagePosition = new NSCellImagePosition(4);
  public static var NSImageAbove:NSCellImagePosition = new NSCellImagePosition(5);
  public static var NSImageOverlaps:NSCellImagePosition = new NSCellImagePosition(6);
  
  private function NSCellImagePosition(num:Number) {
    super(value);
  }
}