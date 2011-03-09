/* See LICENSE for copyright and terms of use */

import org.actionstep.ASBitmapImageRep;
import org.actionstep.ASUtils;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSObject;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;

/**
 * <code>NSImageRep</code> is a semiabstract superclass (“semi” because it 
 * has some instance variables and implementation of its own); each of its 
 * subclasses knows how to draw an image from a particular kind of source data. 
 * While an NSImageRep subclass can be used directly, it’s typically used 
 * through an <code>NSImage</code> object.
 * 
 * @author Scott Hyndman
 * @author Richard Kilmer
 */
class org.actionstep.NSImageRep extends NSObject {
	
  //******************************************************
  //*                  Class members
  //******************************************************
  
  private static var g_imageHoldingArea:MovieClip;
  private static var g_graphics:ASGraphics;
  
  //******************************************************
  //*                    Members
  //******************************************************
  
  private var m_drawPoint:NSPoint;
  private var m_drawRect:NSRect;
  private var m_drawClip:MovieClip;
  private var m_size:NSSize;
  private var m_defaultRect:NSRect;
  private var m_lastCanvas:MovieClip;
  
  private var m_blendMode:Object;
  private var m_filters:NSArray;
  private var m_effectsInvalid:Boolean;
  
  //******************************************************
  //*                  Construction
  //******************************************************
  
  /**
   * Constructs a new image rep.
   */
  public function NSImageRep() {
    m_drawPoint = NSPoint.ZeroPoint;
    m_drawRect = null;
    m_effectsInvalid = false;
    m_blendMode = "normal";
    if (supportsEffects()) {
      m_filters = NSArray.array();
    }
  }
  
  //******************************************************
  //*                  NSCopying
  //******************************************************
  
  /**
   * Does a basic copy of the image rep. Some members in the clone may 
   * reference the same objects as the original does.
   */
  public function copyWithZone():NSImageRep {
    var rep:NSImageRep = NSImageRep(memberwiseClone());
    rep.m_size = m_size.clone();
    rep.m_defaultRect = m_defaultRect.clone();
    return rep;
  }

  //******************************************************
  //           Setting the size of an image
  //******************************************************

  /**
   * Sets the size of the image to <code>value</code>, which is a size
   * represented in the base coordinate system.
   */
  public function setSize(value:NSSize) {
    m_size = value;
  }

  /**
   * Returns the size of the image.
   */
  public function size():NSSize {
    return m_size;
  }


  //******************************************************
  //*   Specifying information about the representation
  //******************************************************

  /**
   * Returns the height of the image.
   */
  public function pixelsHigh():Number
  {
    return m_size.height;
  }

  /**
   * Sets the height of the image to <code>pixels</code>.
   */
  public function setPixelsHigh(pixels:Number):Void
  {
    m_size.height = pixels;
  }

  /**
   * Returns the width of the image.
   */
  public function pixelsWide():Number
  {
    return m_size.width;
  }

  /**
   * Sets the width of the image to <code>pixels</code>.
   */
  public function setPixelsWide(pixels:Number):Void
  {
    m_size.width = pixels;
  }
  
  //******************************************************
  //*              Getting the last canvas
  //******************************************************
  
  /**
   * Returns the last view this image drew upon.
   */
  public function lastCanvas():MovieClip {
    return m_lastCanvas;
  }

  //******************************************************
  //*                     Effects
  //******************************************************
  
  /**
   * <p>
   * Returns <code>true</code> if this image rep supports blend mode and
   * color transform effects.
   * </p>
   * <p>
   * The default implementation returns <code>false</code>.
   * </p>
   */
  public function supportsEffects():Boolean {
    return false;
  }
  
  /**
   * Called to rebuild the effects.
   */
  public function invalidateEffects():Void {
    
  }
  
  /**
   * Returns <code>true</code> if the effects need to be rebuilt.
   */
  public function effectsInvalid():Boolean {
    return m_effectsInvalid;
  }
  
  /**
   * <p>
   * Sets the blend mode and filters used to affect the appearance
   * of this image rep.
   * </p>
   * <p>
   * This method is only called if {@link #supportsEffects()} returns
   * <code>true</code>. 
   * </p>
   */
  public function setBlendModeFilters(blendMode:Object, 
      filters:NSArray):Void {
    if (m_blendMode == blendMode && filters.isEqualToArray(m_filters)) {
      return;
    }
    
    m_blendMode = blendMode;
    m_filters = filters;
    m_effectsInvalid = true;
  }
  
  //******************************************************
  //*                     Drawing
  //******************************************************

  /**
   * Draws the image at location (0,0). This method returns <code>true</code>
   * if the image was successfully drawn, or <code>false</code> if it
   * wasn't.
   */
  public function draw():Boolean {
    return true;
  }

  /**
   * Draws the image so that it fits inside the rectangle <code>rect</code>.
   *
   * This method sets the drawing point to be <code>rect.origin</code> and
   * will scale the image to fit within <code>rect.size</code>.
   *
   * After drawing is complete, the scaling settings are restored to their
   * original values.
   */
  public function drawInRect(rect:NSRect):Boolean {
  	if (null == m_drawClip || null == rect) {
  	  return false;
  	}

  	m_drawPoint = rect.origin;
  	var oSz:NSSize = size();

  	setSize(rect.size);
    draw();
    setSize(oSz);

    return true;
  }

  /**
   * Sets the image reps base coordinates to <code>point</code>, then invokes
   * draw to draw the image.
   *
   * After the image has been drawn, the base coordinates are restored to
   * their original values.
   */
  public function drawAtPoint(point:NSPoint):Boolean {
  	if (null == m_drawClip || null == point) {
  	  return false;
  	}

    m_drawPoint = point;
    draw();
    m_drawPoint = null;

    return true;
  }

  public function setFocus(clip:MovieClip) {
    m_drawClip = m_lastCanvas = clip;
    m_drawPoint = NSPoint.ZeroPoint;
    if (m_defaultRect == null) {
      m_defaultRect = new NSRect(0,0,size().width, size().height);
    }
    m_drawRect = m_defaultRect;
  }


  /**
   * Replaces the draw clip's clear() method with a new method that will also
   * cover the removal of MovieClip based image representations.
   *
   * For internal use only.
   */
  private function decorateDrawClipIfNeeded():Void {
    if (m_drawClip == null || m_drawClip.__oldClear != null) {
      return;
    }

    var dc:MovieClip = m_drawClip;
    m_drawClip.__imageReferences = new Array();
    m_drawClip.__oldClear = m_drawClip.clear;
    m_drawClip.__unusedDepths = {length:0};
    _global.ASSetPropFlags(m_drawClip, 
      ["__imageReferences", "__oldClear", "__unusedDepths"], 1);
    _global.ASSetPropFlags(m_drawClip.__unusedDepths, ["length"], 1);

    m_drawClip.clear = function() {
      var refs:Array = dc.__imageReferences;
      var len:Number = refs.length;
      var obj:Object = this.__unusedDepths;

      for (var i:Number = 0; i < len; i++) {
      	obj[MovieClip(refs[i]).getDepth()] = true;
      	obj.length++;

        refs[i].removeMovieClip();
      }

      dc.__imageReferences = new Array();
      dc.__oldClear();
    };
  }

  /**
   * Adds an image rep created movieclip to a list of references held on the
   * draw clip. These references are used for clearing.
   */
  private function addImageRepToDrawClip(ref:MovieClip):Void {
    decorateDrawClipIfNeeded();
    m_drawClip.__imageReferences.push(ref);
  }

  //******************************************************
  //*            Getting the clip depth
  //******************************************************
  
  /**
   * Gets the next depth at which a movie clip can be created on the focused
   * clip.
   */
  private function getClipDepth():Number {
    //
    // Determine depth
    //
    var depth:Number = m_drawClip.getNextHighestDepth();
    if (m_drawClip.view != undefined) {
      var obj:Object = m_drawClip.__unusedDepths;
      if (obj != null && obj.length > 0) {
        var i:String;
        for (i in obj) {
          depth = parseInt(i);
          break;
        }

        delete obj[i];
        obj.length--;
      } else {
        depth = NSView(m_drawClip.view).getNextDepth();
      }
    }
    
    return depth;
  }
  
  //******************************************************
  //*             Creating an NSImageRep
  //******************************************************

  private static function createImageHoldingArea():Void {
    if (_root.__imageHoldingArea == undefined) {
  	  _root.__imageHoldingArea = _root.createEmptyMovieClip(
  	    "__imageHoldingArea", _root.getNextHighestDepth());
  	  _root.__imageHoldingArea._visible = false;
  	  g_imageHoldingArea = _root.__imageHoldingArea;
  	}
  }
  
  /**
   * Creates and returns a new image rep that will be filled with the
   * contents of the image at <code>url</code>.
   *
   * Since Flash loads images asynchronously, the image itself will not
   * be immediately available. An NSImageRepDidLoad <code>notification</code>
   * will be posted to the default notificaiton center when the loading
   * completes.
   */
  public static function imageRepWithContentsOfURL(url:String):NSImageRep
  {
  	createImageHoldingArea();

  	var loadingClip:MovieClip = g_imageHoldingArea.createEmptyMovieClip(
  	  "image" + g_imageHoldingArea.getNextHighestDepth(),
  	  g_imageHoldingArea.getNextHighestDepth());

  	//
  	// Set up our image rep
  	//
  	var rep:ASBitmapImageRep = new ASBitmapImageRep();

  	//
  	// Set up listener and MovieClipLoader
  	//
  	var listener:Object = {};
  	var mcloader:MovieClipLoader = new MovieClipLoader();
  	mcloader.loadClip(url, loadingClip);
  	mcloader.addListener(listener);

  	//
  	// Complete listener
  	//
  	listener.onLoadInit = function(target:MovieClip):Void {
	  //
	  // Give image rep its source image
	  //
	  rep.initWithMovieClip(target);

	  //
	  // Now that we've extracted the image data, remove the movieclip
	  //
	  target.removeMovieClip();

      try {
	    //
        // Post notification
        //
        NSNotificationCenter.defaultCenter()
	      .postNotificationWithNameObjectUserInfo(
	        NSImageRep.ASImageRepDidLoadNotification,
	        rep,
	        NSDictionary.dictionaryWithObjectForKey(
	          true, "ASLoadSuccess"));
      } catch (e:Error) {
        trace(e.toString());
      }
  	};

  	//
  	// Error listener
  	//
  	listener.onLoadError = function(target:MovieClip, errorCode:String, 
  	    httpStatus:Number):Void {
  	  target.removeMovieClip();
      
      //
      // TODO Consider initializing the rep with a red square, to indicate error
      //
      
	  //
	  // Post notification
	  //
	  try {
	    NSNotificationCenter.defaultCenter()
	      .postNotificationWithNameObjectUserInfo(
	        NSImageRep.ASImageRepDidLoadNotification,
	        rep,
	        NSDictionary.dictionaryWithObjectForKey(
	          false, "ASLoadSuccess"));
      } catch (e:Error) {
        trace(e.toString());
      }
  	};

  	//
  	// Progress listener
  	//
  	listener.onLoadProgress = function(target:MovieClip,
  	    loadedBytes:Number, totalBytes:Number):Void {
  	  try {
	    //
	    // Post notification
        //
        NSNotificationCenter.defaultCenter()
	      .postNotificationWithNameObjectUserInfo(
	        NSImageRep.ASImageRepGotProgressNotification,
	        rep,
	        NSDictionary.dictionaryWithObjectsAndKeys(
	          loadedBytes, "ASBytesLoaded",
	          totalBytes, "ASBytesTotal"));
  	  } catch (e:Error) {
  	    trace(e.toString());
  	  }
  	};

  	return rep;
  }

  //******************************************************
  //*               Class construction
  //******************************************************
  
  private static function initialize():Void {
    g_graphics = (new ASGraphics()).init();
  }

  //******************************************************
  //*                 Notifications
  //******************************************************

  /**
   * Posted when an image rep created using
   * <code>NSImageRep#imageRepWithContentsOfURL</code> finishes loading, or
   * encounters an error.
   *
   * The user info dictionary contains:
   *   "ASLoadSuccess": true if the image loaded successfully. (Boolean)
   */
  public static var ASImageRepDidLoadNotification:Number = ASUtils.intern(
    "ASImageRepDidLoad");

  /**
   * Posted whenever an image rep created using
   * <code>NSImageRep#imageRepWithContentsOfURL</code> writes content to the
   * hard drive during the load process.
   *
   * The user info dictionary contains:
   *   "ASBytesLoaded": The number of bytes loaded. (Number)
   *   "ASBytesTotal": The total number of bytes in the file. (Number)
   */
  public static var ASImageRepGotProgressNotification:Number = ASUtils.intern(
    "ASImageRepGotProgress");
}