/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

class org.actionstep.constants.NSCellAttribute extends ASConstantValue {
  
  static var NSCellAllowsMixedState:NSCellAttribute = new NSCellAttribute(0);
  static var NSChangeBackgroundCell:NSCellAttribute = new NSCellAttribute(1);
  static var NSCellChangesContents:NSCellAttribute = new NSCellAttribute(2);
  static var NSChangeGrayCell:NSCellAttribute = new NSCellAttribute(3);
  static var NSCellDisabled:NSCellAttribute = new NSCellAttribute(4);
  static var NSCellEditable:NSCellAttribute = new NSCellAttribute(5);
  static var NSCellHasImageHorizontal:NSCellAttribute = new NSCellAttribute(6);
  static var NSCellHasImageOnLeftOrBottom:NSCellAttribute = new NSCellAttribute(7);
  static var NSCellHasOverlappingImage:NSCellAttribute = new NSCellAttribute(8);
  static var NSCellHighlighted:NSCellAttribute = new NSCellAttribute(9);
  static var NSCellIsBordered:NSCellAttribute = new NSCellAttribute(10);
  static var NSCellIsInsetButton:NSCellAttribute = new NSCellAttribute(11);
  static var NSCellLightsByBackground:NSCellAttribute = new NSCellAttribute(12);
  static var NSCellLightsByContents:NSCellAttribute = new NSCellAttribute(13);
  static var NSCellLightsByGray:NSCellAttribute = new NSCellAttribute(14);
  static var NSPushInCell:NSCellAttribute = new NSCellAttribute(15);
  static var NSCellState:NSCellAttribute = new NSCellAttribute(16);
  
  private function NSCellAttribute(num:Number) {
    super(num);
  }
}
