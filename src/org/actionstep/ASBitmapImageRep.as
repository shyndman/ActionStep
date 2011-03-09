/* See LICENSE for copyright and terms of use */

import org.actionstep.NSArray;
import org.actionstep.NSImageRep;
import org.actionstep.NSObject;
import org.actionstep.NSRect;
import org.actionstep.NSSize;

import flash.display.BitmapData;
import flash.filters.BitmapFilter;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * <p>
 * Represents an image defined by a rectangle of a {@link BitmapData} instance.
 * </p>
 * <p>
 * This class supports blend mode and color transform effects.
 * </p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.ASBitmapImageRep extends NSImageRep
{
	private var m_rotation:Number;
	private var m_image:BitmapData;
	private var m_effectsImage:BitmapData;
	
	/**
	 * Creates a new instance of <code>ASBitmapImageRep</code>.
	 */
	public function ASBitmapImageRep() {
		m_rotation = 0;
	}

	/**
	 * Initializes the image rep with an image composed of the area of
	 * <code>source</code> as defined by <code>rect</code>.
	 */
	public function initWithSourceRect(source:BitmapData, rect:NSRect)
			:ASBitmapImageRep {
		setImageWithSourceRect(source, rect);
		return this;
	}

	/**
	 * Initializes the image rep with an image composed of the contents of
	 * <code>source</code>.
	 */
	public function initWithMovieClip(source:MovieClip):ASBitmapImageRep {
		m_image = new BitmapData(source._width, source._height, true, null);
		m_image.draw(source);
		m_size = new NSSize(source._width, source._height);

		return this;
	}

	/**
	 * Releases this <code>ASBitmapImageRep</code> from memory.
	 */
	public function release():Boolean {
		m_image.dispose();
		m_image = null;
		return super.release();
	}
	
	//******************************************************
	//*                    Cloning
	//******************************************************

	public function copyWithZone():NSObject {
		var rep:ASBitmapImageRep = (new ASBitmapImageRep()).initWithSourceRect(
			m_image, new NSRect(0, 0, m_size.width, m_size.height));
		return rep;
	}
	
	//******************************************************
	//*                   Properties
	//******************************************************

	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String {
		return "ASBitmapImageRep(size=" + m_size + ")";
	}

	/**
	 * Extracts the image from the <code>source</code> bitmap data, as defined
	 * by the rectangle <code>rect</code>.
	 */
	public function setImageWithSourceRect(source:BitmapData, rect:NSRect):Void {
		if (null == source) {
			return;
		}

		if (null == rect) {
			rect = new NSRect(0, 0, source.width, source.height);
		}

		m_image = source.clone();
		m_size = rect.size;
	}

	//******************************************************
	//*                    Effects
	//******************************************************
	
	/**
	 * <p>
	 * Returns <code>true</code> if this image rep supports blend mode and
	 * color transform effects.
	 * </p>
	 * <p>
	 * This method returns <code>true</code>.
	 * </p>
	 */
	public function supportsEffects():Boolean {
		return true;
	}
	
	/**
	 * Called to rebuild the effects.
	 */
	public function invalidateEffects():Void {
		if (m_effectsImage != null) {
			m_effectsImage.dispose();
			m_effectsImage = null;
		}
		
		m_effectsImage = new BitmapData(m_image.width, m_image.height, 
			true, null);
		m_effectsImage.draw(m_image);
		//m_effectsImage.applyFilter();
		
		//
		// Apply filters
		//
		var arr:Array = m_filters.internalList();
		var len:Number = arr.length;
		for (var i:Number = 0; i < len; i++) {
			var f:BitmapFilter = BitmapFilter(arr[i]);
			var ret:Number = m_effectsImage.applyFilter(m_effectsImage,
				new Rectangle(0, 0, m_size.width, m_size.height),
				new Point(0, 0),
				f);
			if (ret != 0) trace(ret);
		}
		
		m_effectsInvalid = false;
	}
  
	/**
	 * <p>
	 * Overridden to build an altered bitmap data instance based on the
	 * effects.
	 * </p>
	 */
	public function setBlendModeFilters(blendMode:Object, 
			filters:NSArray):Void {
		super.setBlendModeFilters(blendMode, filters);
	}
	
	//******************************************************
	//*               Rotating the image
	//******************************************************
	
	/**
	 * Returns the rotation of the image.
	 */
	public function rotation():Number {
		return m_rotation;
	}
	
	/**
	 * Sets the rotation of the image.
	 */
	public function setRotation(value:Number):Void {
		m_rotation = value;
	}
	
	//******************************************************
	//*                 Public Methods
	//******************************************************

	/**
	 * Draws the image.
	 */
	public function draw():Void {
		var clip:MovieClip;
		var innerClip:MovieClip;
		var depth:Number;
		var flipped:Boolean = false;

		//
		// Determine depth
		//
		depth = super.getClipDepth();

		//
		// If we're flipped, calculate the proper draw rect.
		//
		if (m_size.height < 0) {
		  flipped = true;
		  m_drawPoint.y += m_size.height;
		  m_size.height *= -1;
		}

		//
		// Create the holder clip.
		//
		clip = m_lastCanvas = m_drawClip.createEmptyMovieClip("__bdclip__" 
			+ depth, depth);
		clip.view = m_drawClip.view;
		super.addImageRepToDrawClip(clip);
		
		//
		// Get the bitmap data we're using
		//
		var img:BitmapData = m_effectsImage != null ? m_effectsImage : m_image;
		
		//
		// Deal with rotation
		//
		if (m_rotation != 0) {
			innerClip = clip.createEmptyMovieClip("__bdclip__", 1);
			innerClip.attachBitmap(img, 0, "auto", true);
			innerClip.view = m_drawClip.view;
		} else {
			clip.attachBitmap(img, 0, "auto", true);
		}
		
		//
		// Draw the image
		//
		clip._x = m_drawPoint.x;
		clip._y = m_drawPoint.y;
		clip._width = m_size.width;
		clip._height = m_size.height;

		//
		// Flip the image if necessary.
		//
		if (flipped) {
		  clip._yscale *= -1;
		  clip._y += clip._height;
		}

		//
		// Rotate the image
		//
		if (m_rotation != 0) {
			clip._x += m_size.width / 2;
			clip._y += m_size.height / 2;
			innerClip._x -= m_size.width / 4;
			innerClip._y -= m_size.height / 4;
			clip._rotation = m_rotation;
		}
    }
}
