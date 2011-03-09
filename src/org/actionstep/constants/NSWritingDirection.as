import org.actionstep.constants.ASConstantValue;
/* See LICENSE for copyright and terms of use */
 
class org.actionstep.constants.NSWritingDirection extends ASConstantValue {
  
  static var NSWritingDirectionNatural:NSWritingDirection = new NSWritingDirection(-1);
  static var NSWritingDirectionLeftToRight:NSWritingDirection = new NSWritingDirection(0);
  static var NSWritingDirectionRightToLeft:NSWritingDirection = new NSWritingDirection(1);
  
  private function NSWritingDirection(value:Number) {
    super(value);
  }

}