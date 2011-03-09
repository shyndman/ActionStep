/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;
 
class org.actionstep.constants.NSUsableScrollerParts extends ASConstantValue {
  
  static var NSNoScrollerParts:NSUsableScrollerParts = new NSUsableScrollerParts(0);
  static var NSOnlyScrollerArrows:NSUsableScrollerParts = new NSUsableScrollerParts(1);
  static var NSAllScrollerParts:NSUsableScrollerParts = new NSUsableScrollerParts(2);

  private function NSUsableScrollerParts(num:Number) {
    super(num);
  }
}

