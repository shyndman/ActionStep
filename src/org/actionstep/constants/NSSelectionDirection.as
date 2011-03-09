/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

class org.actionstep.constants.NSSelectionDirection extends ASConstantValue {

  static var NSDirectSelection:NSSelectionDirection = new NSSelectionDirection(0);
  static var NSSelectingNext:NSSelectionDirection = new NSSelectionDirection(1);
  static var NSSelectingPrevious:NSSelectionDirection = new NSSelectionDirection(2);

  private function NSSelectionDirection(num:Number) {
    super(num);
  }

}