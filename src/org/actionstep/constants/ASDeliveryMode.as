/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.ASConstantValue;

/**
 * Constants to specify the type of delivery mode.
 *
 * @author Tay Ray Chuan
 */

class org.actionstep.constants.ASDeliveryMode extends ASConstantValue {

  public static var OnDemand:ASDeliveryMode = new ASDeliveryMode(0);
  public static var FetchAll:ASDeliveryMode = new ASDeliveryMode(1);
  public static var Page:ASDeliveryMode = new ASDeliveryMode(2);

  private function ASDeliveryMode(num:Number) {
    super(value);
  }
}