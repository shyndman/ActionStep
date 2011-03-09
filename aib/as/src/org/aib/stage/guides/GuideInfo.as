/* See LICENSE for copyright and terms of use */

import org.aib.AIBObject;

/**
 * Describes the location and orientation of a guide.
 * 
 * @author Scott Hyndman
 */
class org.aib.stage.guides.GuideInfo extends AIBObject {
	
	/**
	 * The position of the guide in the window. Depending on the guide's
	 * orientation, this is either an x or y coordinate.
	 */
	public var position:Number;
	
	/**
	 * <p><code>true</code> if the guide is vertical, or <code>false</code> if 
	 * it is horizontal.</p>
	 * 
	 * If vertical, {@link #position} represents a y-position. If horizontal,
	 * {@link #position} represents an x-position.
	 */
	public var isVertical:Boolean;
	
	/**
	 * Creates a new instance of the <code>GuideInfo</code> class.
	 */
	public function GuideInfo(position:Number, isVertical:Boolean) {
		this.position = position;
		this.isVertical = isVertical;
	}
}