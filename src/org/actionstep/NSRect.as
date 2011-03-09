/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSRectEdge;
import org.actionstep.NSCopying;
import org.actionstep.NSObject;
import org.actionstep.NSPoint;
import org.actionstep.NSSize;

import flash.geom.Rectangle;

/**
 * Represents a rectangle in 2D space. A rectangle has an origin point (an
 * instance of {@link NSPoint}), and a size (an instance of {@link NSSize}).
 * 
 * @author Richard Kilmer
 */
class org.actionstep.NSRect extends NSObject implements NSCopying {
	
	/** The size of the rectangle. */
	public var size:NSSize;
	
	/** The location of the rectangle. */
	public var origin:NSPoint;
	
	/**
	 * Creates a new instance of the <code>NSRect</code> class with an origin
	 * of <code>x, y</code> and a size of <code>width, height</code>.
	 */
	public function NSRect(x:Number, y:Number, width:Number, height:Number) {
		origin = new NSPoint(x, y);
		size = new NSSize(width, height);
	}
	
	/**
	 * Allows for use of <code>NSRects</code> as refs.<br/>
	 * eg.<br/><pre>
	 * function foo(ref:NSRect) {
	 *   //do smth
	 *   ref.reset(...);
	 * }
	 * </pre>
	 */
	public function reset(x:Number, y:Number, width:Number, height:Number):Void {
		origin.x = x;
		origin.y = y;
		size.width = width;
		size.height = height;
	}
	
    /**
     * Returns a copy of this rectangle.
     */
	public function clone():NSRect {
	  return NSRect.withOriginSize(origin, size);
	}

    /**
     * Returns a copy of this rectangle.
     */	
	public function copyWithZone():NSObject {
		return NSRect.withOriginSize(origin, size);
	}

    /**
     * Returns a string representation of the rectangle. 
     */	
	public function description():String {
		return "NSRect(origin="+origin.description()+", size="+size.description()+")";
	}
	
	/**
	 * Returns a {@link flash.geom.Rectangle} containing the same coordinates 
	 * and size as this rectangle.
	 */
	public function toFlashRect():Rectangle {
		return new Rectangle(origin.x, origin.y, size.width, size.height);
	}
	
	/**
	 * Returns <code>true</code> if this rectangle's <code>origin</code> and 
	 * <code>size</code> are equal to those of <code>other</code>.
	 */
    public function isEqual(other:Object):Boolean {
      if (!(other instanceof NSRect)) {
        return false;
      }
      
      var rect:NSRect = NSRect(other);
      
	  return origin.x == rect.origin.x &&
        origin.y == rect.origin.y &&
        size.width == rect.size.width &&
        size.height == rect.size.height;
	}
	
	/**
	 * Returns the X midpoint value of the rectangle.
	 */
	public function midX():Number {
		return origin.x + size.width/2;
	}

	/**
	 * Returns the Y midpoint value of the rectangle.
	 */
	public function midY():Number {
		return origin.y + size.height/2;
	}
	
	/**
	 * Returns the minimum X value of the rectangle.
	 */
	public function minX():Number {
		return origin.x;
	}
	
	/**
	 * Returns the minimum Y value of the rectangle.
	 */
	public function minY():Number {
		return origin.y;
	}

	/**
	 * Returns the maximum X value of the rectangle.
	 */	
	public function maxX():Number {
		return origin.x + size.width;
	}
	
	/**
	 * Returns the maximum Y value of the rectangle.
	 */
	public function maxY():Number {
		return origin.y + size.height;
	}
	
	/**
	 * Returns the width of the rectangle.
	 */
	public function width():Number {
		return size.width;
	}
	
	/**
	 * Returns the height of the rectangle.
	 */
	public function height():Number {
		return size.height;
	}

    /**
     * Returns a new rectangle representing this rectangle traslated by
     * <code>dx</code> on the x-axis and <code>dy</code> on the y-axis.
     */
    public function translateRect(dx:Number, dy:Number):NSRect {
      return new NSRect(origin.x + dx, origin.y + dy, size.width, size.height);
    }
    
	/**
	 * Creates and returns a new rectangle containing the values of this 
	 * rectangle insert <code>dx</code> x coordinates and <code>dy</code> y
	 * coordinates.
	 */
	public function insetRect(dx:Number, dy:Number):NSRect {
		return new NSRect(origin.x + dx, origin.y + dy, size.width - 2*dx, size.height - 2*dy);
	}
	
	/**
	 * Creates and returns a new rectangle with its width changed by
	 * <code>dw</code> and height changed by <code>dh</code>.
	 */
	public function scaledRect(dw:Number, dh:Number):NSRect {
		return new NSRect(origin.x, origin.y, size.width + dw, size.height + dh);
	}
	
	/**
	 * Creates and returns a new rectangle scaled by percentages. 
	 * <code>xPercentage</code> scales the width, and <code>yPercentage</code>
	 * scales the height. 
	 */
	public function scaledPercentageRect(xPercentage:Number, yPercentage:Number):NSRect {
		return new NSRect(origin.x, origin.y, 
			size.width * xPercentage / 100,
			size.height * yPercentage / 100);
	}

	public function sizeRectLeftRightTopBottom(left:Number, right:Number, top:Number, bottom:Number):NSRect {
		return new NSRect(origin.x + left, origin.y + top, size.width - (left+right), size.height - (top+bottom));
	}

	/**
	 * Returns <code>true</code> if the width and height of this rectangle
	 * are 0.
	 */
	public function isEmptyRect():Boolean {
		return (size.width == 0) && (size.height == 0);
	}
	
	/**
	 * Returns the rectangle of intersection between this rectangle and
	 * <code>rect</code>.
	 */
	public function intersectionRect(rect:NSRect):NSRect {
		var x = Math.max(origin.x, rect.origin.x);
		var y = Math.max(origin.y, rect.origin.y);
		var x2 = Math.min(maxX(), rect.maxX());
		var y2 = Math.min(maxY(), rect.maxY());
		
		return (x2 >= x && y2 >= y) ? new NSRect(x, y, x2 - x, y2 - y) : NSRect.ZeroRect;
	}

	/**
	 * Returns a rectangle that encompasses both this rect and <code>rect</code>.
	 */
	public function unionRect(rect:NSRect):NSRect {
		var minX:Number = Math.min(origin.x, rect.origin.x);
		var minY:Number = Math.min(origin.y, rect.origin.y);
		
		return new NSRect(
			minX,
			minY,
			Math.max(maxX() - minX, rect.maxX() - minX),
			Math.max(maxY() - minY, rect.maxY() - minY));
	}
	 
	/**
	 * Returns <code>true</code> if <code>point</code> lies within this 
	 * rectangle or <code>false</code> otherwise.
	 */
	public function pointInRect(point:NSPoint):Boolean {
		//! x>=minX, y<=maxY
		return point != null && (point.x >= origin.x && point.x <= (origin.x+size.width)) &&
			(point.y >= origin.y && point.y <= (origin.y+size.height));
	}

	/**
	 * Returns <code>true</code> if <code>rect</code> lies within this 
	 * rectangle or <code>false</code> otherwise.
	 */	
	public function containsRect(rect:NSRect):Boolean {
		return minX()<rect.minX() &&
					 minY()<rect.minY() &&
					 maxX()>rect.maxX() &&
					 maxY()>rect.maxY();
	}
	
	/**
	 * Returns <code>true</code> if <code>rect</code> intersects with this 
	 * rectangle or <code>false</code> otherwise.
	 */
	public function intersectsRect(rect:NSRect):Boolean {
		/* Note that intersecting at a line or a point doesn't count */
		return !(maxX() <= rect.minX()
		|| rect.maxX() <= minX()
		|| maxY() <= rect.minY()
		|| rect.maxY() <= minY());
	}

	//******************************************************															 
	//*                   Static Methods
	//******************************************************
	
	/**
	 * Divides a rectangle into two new rectangles. The slice and remainder
	 * parameters should be newly initialized NSRects.
	 */
	public static function divideRect(inRect:NSRect, slice:NSRect, 
		remainder:NSRect, amount:Number, edge:NSRectEdge):Void
	{		
		var h:Number = inRect.size.height;
		var w:Number = inRect.size.width;
		var x:Number = inRect.origin.x;
		var y:Number = inRect.origin.y;
		
		switch (edge)
		{
			case NSRectEdge.NSMinXEdge: // vertical slice from min x (left)
				slice.size.height = remainder.size.height = h;
				slice.size.width = amount;
				remainder.size.width = w - amount;
				slice.origin.y = remainder.origin.y = y;
				slice.origin.x = x;
				remainder.origin.x = x + amount;
				break;
				
			case NSRectEdge.NSMaxXEdge: // vertical slice from max x (right)
				slice.size.height = remainder.size.height = h;
				remainder.size.width = amount;
				slice.size.width = w - amount;
				slice.origin.y = remainder.origin.y = y;
				remainder.origin.x = x;
				slice.origin.x = x + w - amount;
				break;
				
			case NSRectEdge.NSMinYEdge: // horizontal slice from min y (top)
				slice.size.width = remainder.size.width = w;
				slice.size.height = amount;
				remainder.size.height = h - amount;
				slice.origin.x = remainder.origin.x = x;
				slice.origin.y = y;
				remainder.origin.y = y + amount;
				break;
				
			case NSRectEdge.NSMaxYEdge: // vertical slice from max y (bottom)
				slice.size.width = remainder.size.width = w;
				remainder.size.height = amount;
				slice.size.height = h - amount;
				slice.origin.x = remainder.origin.x = x;
				remainder.origin.y = y;
				slice.origin.y = y + h - amount;
				break;
		}
	}
	
	/**
	 * Prevents reference-related errors, as in the static var implementation.
	 */
	public static function get ZeroRect():NSRect {
		return new NSRect(0,0,0,0);
	}
	
	/**
	 * Returns a newly initialized <code>NSRect</code> containing an origin and 
	 * a size.
	 */
	public static function withOriginSize(origin:NSPoint, size:NSSize):NSRect {
		return new NSRect(origin.x, origin.y, size.width, size.height);
	}
	
	/**
	 * Returns a new initialized <code>NSRect</code> containing the origin and 
	 * size of the provided {@link flash.geom.Rectangle}.
	 */
	public static function rectWithFlashRect(rect:Rectangle):NSRect {
		return new NSRect(rect.x, rect.y, rect.width, rect.height);
	}
}