/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;
 
class org.actionstep.constants.NSWindowOrderingMode extends ASConstantValue {
	// Modal run responses
	public static var	NSWindowAbove:NSWindowOrderingMode = new NSWindowOrderingMode(1);
	public static var	NSWindowBelow:NSWindowOrderingMode = new NSWindowOrderingMode(-1);
	public static var	NSWindowOut:NSWindowOrderingMode = new NSWindowOrderingMode(0);
  
  private function NSWindowOrderingMode(num:Number) {
    super(num);
  }
}