/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;
import org.actionstep.NSCopying;

/**
 * A class that represents a number.
 */
class org.actionstep.NSNumber extends NSObject implements NSCopying {

  private var m_number:Number;

  public static function numberWithDouble(number:Number):NSNumber {
    return (new NSNumber()).initWithDouble(number);
  }
  public static function numberWithFloat(number:Number):NSNumber {
    return (new NSNumber()).initWithFloat(number);
  }
  public static function numberWithInt(number:Number):NSNumber {
    return (new NSNumber()).initWithInt(number);
  }

  public function initWithDouble(number:Number):NSNumber {
    m_number = number;
    return this;
  }
  public function initWithFloat(number:Number):NSNumber {
    m_number = number;
    return this;
  }
  public function initWithInt(number:Number):NSNumber {
    m_number = number;
    return this;
  }

  public function doubleValue():Number {
    return m_number;
  }
  public function floatValue():Number {
    return m_number;
  }
  public function intValue():Number {
    return m_number;
  }

  /**
   * Returns a string representation of the NSNumber instance.
   */
  public function description():String {
  	return m_number.toString();
  }

	public function copyWithZone():NSObject {
		//!TODO handle specific type, eg int, float, bool
		return NSNumber.numberWithInt(m_number);
	}

}