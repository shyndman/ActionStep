/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Used by <code>NSDraggingInfo</code>, <code>NSDraggingSource</code> and
 * <code>NSDraggingDestination</code> protocols to describe drag operations.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSDragOperation extends ASConstantValue {
	
  /** No drag operations are allowed. */
  static var NSDragOperationNone:NSDragOperation    = new NSDragOperation(0);
  
  /** The data represented by the image can be copied. */
  static var NSDragOperationCopy:NSDragOperation    = new NSDragOperation(1);
  
  /** The data can be shared. */
  static var NSDragOperationLink:NSDragOperation    = new NSDragOperation(2);
  
  /** The operation can be defined by the destination. */
  static var NSDragOperationGeneric:NSDragOperation = new NSDragOperation(4);
  
  /** The operation is negotiated privately between the source and the destination. */
  static var NSDragOperationPrivate:NSDragOperation = new NSDragOperation(8); 
  
  /** The data can be moved. */
  static var NSDragOperationMove:NSDragOperation    = new NSDragOperation(16);
  
  /** The data can be deleted. */
  static var NSDragOperationDelete:NSDragOperation  = new NSDragOperation(32);
  
  /** All of the above. */
  static var NSDragOperationEvery:NSDragOperation   = new NSDragOperation(Number.MAX_VALUE);
   
  private function NSDragOperation(num:Number) {
    super(num);
  }

}