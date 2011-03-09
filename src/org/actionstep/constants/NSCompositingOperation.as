/* See LICENSE for copyright and terms of use */
 
import org.actionstep.constants.ASConstantValue;

class org.actionstep.constants.NSCompositingOperation extends ASConstantValue {
  
  static var NSCompositeClear:NSCompositingOperation           = new NSCompositingOperation(0 );
  static var NSCompositeCopy:NSCompositingOperation            = new NSCompositingOperation(1 );
  static var NSCompositeSourceOver:NSCompositingOperation      = new NSCompositingOperation(2 );
  static var NSCompositeSourceIn:NSCompositingOperation        = new NSCompositingOperation(3 );
  static var NSCompositeSourceOut:NSCompositingOperation       = new NSCompositingOperation(4 ); 
  static var NSCompositeSourceAtop:NSCompositingOperation      = new NSCompositingOperation(5 );
  static var NSCompositeDestinationOver:NSCompositingOperation = new NSCompositingOperation(6 );
  static var NSCompositeDestinationIn:NSCompositingOperation   = new NSCompositingOperation(7 );
  static var NSCompositeDestinationOut:NSCompositingOperation  = new NSCompositingOperation(8 );
  static var NSCompositeDestinationAtop:NSCompositingOperation = new NSCompositingOperation(9 );
  static var NSCompositeXOR:NSCompositingOperation             = new NSCompositingOperation(10);
  static var NSCompositePlusDarker:NSCompositingOperation      = new NSCompositingOperation(11);
  static var NSCompositeHighlight:NSCompositingOperation       = new NSCompositingOperation(12);
  static var NSCompositePlusLighter:NSCompositingOperation     = new NSCompositingOperation(13);
    
  private function NSCompositingOperation(num:Number) {
    super(num);
  }

}