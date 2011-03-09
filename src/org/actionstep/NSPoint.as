/* See LICENSE for copyright and terms of use */

import org.actionstep.NSCopying;
import org.actionstep.NSObject;
import org.actionstep.NSSize;

import flash.geom.Point;

/**
 * <p>Represents a point in 2D space. Contains an x-coordinate and a y-coordinate.</p>
 * 
 * <p>Points are used to specify the {@link org.actionstep.NSRect#origin}.</p>
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSPoint extends NSObject implements NSCopying {
    
  /** The x-coordinate. */
  public var x:Number;
  
  /** The y-coordinate. */
  public var y:Number;
    
  /**
   * Creates a new instance of NSPoint with the specified x and y coordinates.
   */
  public function NSPoint(x:Number, y:Number) {
    this.x = x;
    this.y = y;
  }

  /**
   * Creates a new point with the same properties as this one.
   */  
  public function clone():NSPoint {
    return new NSPoint(x, y);
  }

  /**
   * Creates a new point with the same properties as this one.
   */	
  public function copyWithZone():NSObject {
    return new NSPoint(x, y);
  }

  /**
   * Returns a {@link flash.geom.Point} containing the same x and y coordinates as 
   * this <code>NSPoint</code>.
   */
  public function toFlashPoint():Point {
    return new Point(x, y);
  }
  
  /**
   * @see org.actionstep.NSObject#description
   */
  public function description():String {
    return "NSPoint(x="+x+", y="+y+")";
  }
  
  /**
   * Returns <code>true</code> if this point's x and y coordinates are the same
   * as <code>other</code>'s.
   */
  public function isEqual(other:Object):Boolean {
    if (!(other instanceof NSPoint)) {
      return false;
    }
    var pt:NSPoint = NSPoint(other);
    
    return x == pt.x && y == pt.y;
  }
  
  /**
   * <p>Adds <code>point</code> to receiver and returns a new <code>NSPoint</code>.</p>
   * 
   * <p>This does not change the value of the receiver.</p>
   */
  public function addPoint(point:NSPoint):NSPoint
  {
    return new NSPoint(x + point.x, y + point.y); 
  }

  /**
   * <p>Subtracts <code>point</code> from receiver and returns a new 
   * <code>NSPoint</code>.</p>
   * 
   * <p>This does not change the value of the receiver.</p>
   */ 
  public function subtractPoint(point:NSPoint):NSPoint
  {
    return new NSPoint(x - point.x, y - point.y);
  }
  
  /**
   * Adds a size to this point and returns the resulting point.
   */
  public function addSize(size:NSSize):NSPoint {
    return new NSPoint(x + size.width, y + size.height);
  }
  
  /**
   * Subtracts a size from this point and returns the resulting point.
   */
  public function subtractSize(size:NSSize):NSPoint {
    return new NSPoint(x - size.width, y - size.height);
  }
  
  /**
   * Returns a point representing the distance from this point to
   * <code>point</code>.
   */
  public function pointDistanceToPoint(point:NSPoint):NSPoint {
    return new NSPoint(point.x - x, point.y - y);
  }
  
  /**
   * <p>Translates <code>point</code> with supplied <code>dx</code>, 
   * <code>dy</code> and returns a new <code>NSPoint</code>.</p>
   * 
   * <p>This does not change the value of the receiver.</p>
   */ 
  public function translate(dx:Number, dy:Number):NSPoint {
    return new NSPoint(x + dx, y + dy);
  }
	
  /**
   * Returns the distance from this point to <code>pt</code>.
   */
  public function distanceToPoint(pt:NSPoint):Number {
    return Math.sqrt((x-pt.x)*(x-pt.x) + (y-pt.y)*(y-pt.y));
  }

  /**
   * Returns a point with the minimum x and y values drawn from this point and
   * <code>pt</code>.
   */  
  public function min(pt:NSPoint):NSPoint {
  	return new NSPoint(Math.min(x, pt.x), Math.min(y, pt.y));
  }
  
  /**
   * Returns a point with the maximum x and y values drawn from this point and
   * <code>pt</code>.
   */
  public function max(pt:NSPoint):NSPoint {
  	return new NSPoint(Math.max(x, pt.x), Math.max(y, pt.y));
  }
	
  /**
   * Creates and returns a newly initialized <code>NSPoint</code> containing the
   * data of the {@link flash.geom.Point}, <code>aPoint</code>.
   */
  public static function pointWithFlashPoint(aPoint:Point):NSPoint {
    return new NSPoint(aPoint.x, aPoint.y);
  }
  
  /** Returns a point with location (0, 0). */
  public static function get ZeroPoint():NSPoint {
    return new NSPoint(0,0);
  }
}