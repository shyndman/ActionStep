/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;
import org.actionstep.NSCopying;

/**
 * Represents a list of consecutive values. A range has a location and a length.
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSRange extends NSObject implements NSCopying{
  
  public static var NSNotFound:Number = 0x7fffffff;
  public static var NotFoundRange:NSRange = new NSRange(NSNotFound,0);

  /** The location of the range. */
  public var location:Number;
  
  /** The length of the range. */
  public var length:Number;
  
  /**
   * Creates a new instance of the <code>NSRange</code> class with a location
   * of <code>location</code> and a length of <code>length</code>.
   */
  public function NSRange(location:Number, length:Number) {
    this.location = location;
    this.length = length;
  }

  /**
   * Returns <code>location + length - 1</code>.
   */
  public function upperBound():Number {
    return location + length - 1;
  }
  
  /**
   * Returns a copy of this range.
   */  
  public function clone():NSRange {
    return new NSRange(location, length);
  }
  
  /**
   * Returns a copy of this range.
   */
  public function copyWithZone():NSObject {
    return new NSRange(location, length);
  }

  /**
   * Returns true if <code>anObject</code> is a range and has the same
   * length and location as this range.
   */
  public function isEqual(anObject:Object):Boolean {
    if (!(anObject instanceof NSRange)) {
      return false;
    }
    
    var rng:NSRange = NSRange(anObject);
    return rng.location == location && rng.length == length;
  }
  
  /**
   * Returns <code>true</code> if this range intersects with
   * <code>range</code>.
   */
  public function intersectsRange(range:NSRange):Boolean {
  	var s:NSRange; // small
  	var b:NSRange; // big
  	
  	if (range.length > length) {
  		b = range;
  		s = this;
  	} else {
  		b = this;
  		s = range;
  	}
  	
  	var sI:Number = s.location;
  	var sE:Number = sI + s.length - 1;
  	var sM:Number = (sI + sE) / 2;
  	
  	var bI:Number = b.location;
  	var bE:Number = bI + b.length - 1;
  	
  	return sI >= bI || sE <= bE || s.containsValue(sM);
  }
  
  /**
   * Returns <code>true</code> if the range contains <code>value</code>.
   */
  public function containsValue(value:Number):Boolean {
    return value >= location && value < (location + length);
  }
  
  /**
   * Returns a string representation of the range.
   */
  public function description():String {
    return "NSRange(location="+location+", length="+length+")";
  }

  /**
   * Returns a range with a location and length of 0.
   */
  public static function get ZeroRange():NSRange {
    return new NSRange(0,0);
  }
}