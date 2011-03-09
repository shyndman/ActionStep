/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.constants.NSCompositingOperation;
import org.actionstep.constants.NSImageLoadStatus;
import org.actionstep.graphics.ASGraphics;
import org.actionstep.NSArray;
import org.actionstep.NSColor;
import org.actionstep.NSCopying;
import org.actionstep.NSDictionary;
import org.actionstep.NSImageRep;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSObject;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;

/**
 * <p>This class represents an image. An image uses image representations
 * ({@link org.actionstep.NSImageRep}) to draw itself.</p>
 *
 * <p>If you wish to load an image from an external location, use the
 * {@link #initWithContentsOfUrl} initializer. When the image has
 * completed loading, an {@link #NSImageDidLoadNotification} will
 * be posted to the default notification center.</p>
 *
 * <p>The delegate for the image is sent messages under a few conditions when
 * an image is initialized using {@link #initWithContentsOfUrl}.
 * <code>imageDidLoadRepresentationWithStatus(NSImage,NSImageRep,NSImageLoadStatus)</code>
 * is sent when the image finishes loading, or an error occurs.
 * <code>imageHasLoadedImageRepBytesOfTotalBytes(NSImage,NSImageRep,Number,Number)</code> is
 * sent on every load progress event.</p>
 *
 * @see org.actionstep.ASSymbolImageRep
 * @see org.actionstep.ASBitmapImageRep
 * @see org.actionstep.images.*
 *
 * @author Scott Hyndman
 * @author Rich Kilmer
 */
class org.actionstep.NSImage extends NSObject implements NSCopying {

  private static var g_images:Array = [];

  private var m_name:String;
  private var m_size:NSSize;
  private var m_sizeWasSet:Boolean;
  private var m_representations:Array;
  private var m_movieClipStack:Array;
  private var m_delegate:Object;
  private var m_backgroundColor:NSColor;
  private var m_scalesWhenResized:Boolean;
  private var m_flipped:Boolean;
  private var m_isLoaded:Boolean;
  private var m_isLoading:Boolean;
  private var m_lastCanvas:MovieClip;
  private var m_graphics:ASGraphics;
  
  private var m_filters:NSArray;
  private var m_blendMode:Object;
  private var m_invalidateEffects:Boolean;
  
  //******************************************************
  //*                  Construction
  //******************************************************

  /**
   * Creates a new instance of <code>NSImage</code>.
   */
  public function NSImage() {
    m_representations = [];
    m_movieClipStack = [];
    m_sizeWasSet = false;
    m_backgroundColor = null;
    m_scalesWhenResized = false;
    m_flipped = false;
    m_isLoaded = true;
    m_isLoading = false;
    m_graphics = (new ASGraphics()).init();
    
    m_filters = NSArray.array();
    m_blendMode = "normal";
    m_invalidateEffects = false;
  }

  /**
   * Default initializer. Sizes the image to {@link NSSize#ZeroSize}.
   */
  public function init():NSImage {
    return initWithSize(NSSize.ZeroSize);
  }

  /**
   * Initializes the image to a size of <code>size</code>.
   */
  public function initWithSize(size:NSSize):NSImage {
    super.init();
    setSize(size);
    return this;
  }

  /**
   * <p>Initializes the NSImage with the image that is located at
   * <code>url</code>.</p>
   *
   * <p>An {@link #NSImageDidLoadNotification} notification is sent to the
   * default notification center when the image finishes loading.</p>
   */
  public function initWithContentsOfURL(url:String):NSImage {
    m_isLoaded = false;
    m_isLoading = true;
  	var rep:NSImageRep = NSImageRep.imageRepWithContentsOfURL(url);
  	NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
  		this, "imageDidLoad", NSImageRep.ASImageRepDidLoadNotification, rep);
  	NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
  		this, "imageGotProgress", NSImageRep.ASImageRepGotProgressNotification, rep);
  	addRepresentation(rep);
    return this;
  }

  /**
   * Releases the image from memory.
   */
  public function release():Boolean {
  	//
  	// Release representations
  	//
    for (var i:Number = 0; i < m_representations.length; i++) {
      var rep:NSImageRep = NSImageRep(m_representations[i]);
      rep.release();
    }
    m_representations = null;

    //
    // Remove from named dictionary
    //
    if (null != name()) {
      delete g_images[name()];
    }
    
    return super.release();
  }

  //******************************************************
  //*              NSCopying protocol
  //******************************************************
  
  /**
   * <p>Returns a copy of the image, identical except the copy is unnamed.</p>
   * <p>
   * This image's {@link #bestRepresentationForDevice()} is also used for the
   * copy.
   * </p>
   */
  public function copyWithZone():NSObject {
    var img:NSImage = (new NSImage()).init();
    var rep:NSImageRep = bestRepresentationForDevice(null);
    img.addRepresentation(rep);
    img.m_sizeWasSet = m_sizeWasSet;
    if (m_sizeWasSet) {
      img.m_size = m_size.clone();
    }
    
    img.setFilters(null);
    img.setBlendMode(null);
    img.m_backgroundColor = m_backgroundColor;
    img.m_scalesWhenResized = m_scalesWhenResized;
    img.m_flipped = m_flipped;
    img.m_isLoaded = m_isLoaded;
    if (!m_isLoaded) {
      NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
        img, "imageDidLoad", NSImageRep.ASImageRepDidLoadNotification, rep);
      NSNotificationCenter.defaultCenter().addObserverSelectorNameObject(
        img, "imageGotProgress", NSImageRep.ASImageRepGotProgressNotification, rep);	
    }
    
    return img;
  }
  
  //******************************************************
  //*                Event Handlers
  //******************************************************

  /**
   * <p>Fired when the image representation finishes loading from a url.</p>
   *
   * <p>This results in an {@link #NSImageDidLoadNotification} notification
   * being posted to the default notification center and the delegate being sent
   * a <code>imageDidLoadRepresentationWithStatus</code> message.</p>
   */
  private function imageDidLoad(ntf:NSNotification):Void {
  	m_isLoaded = true;
  	m_isLoading = false;
  	if (!m_sizeWasSet) {
  	  setSize(NSImageRep(ntf.object).size().clone());
  	}
  	
    NSNotificationCenter.defaultCenter().postNotificationWithNameObjectUserInfo(
    	NSImageDidLoadNotification,
    	this,
    	NSDictionary.dictionaryWithDictionary(ntf.userInfo));

    if (null == m_delegate) {
      return;
    }

    m_delegate.imageDidLoadRepresentationWithStatus(this,
      bestRepresentationForDevice(),
      Boolean(NSDictionary(ntf.userInfo).objectForKey("ASLoadSuccess"))
      ? NSImageLoadStatus.NSImageLoadStatusCompleted
      : NSImageLoadStatus.NSImageLoadStatusReadError);
  }

  /**
   * <p>Fired when information from the image representation is written to the
   * hard drive during the load process.</p>
   *
   * <p>This results in the delegate being sent an
   * <code>imageHasLoadedImageRepBytesOfTotalBytes</code> message.</p>
   */
  private function imageGotProgress(ntf:NSNotification):Void {
    m_delegate.imageHasLoadedImageRepBytesOfTotalBytes(this,
      bestRepresentationForDevice(),
      Number(NSDictionary(ntf.userInfo).objectForKey("ASBytesLoaded")),
      Number(NSDictionary(ntf.userInfo).objectForKey("ASBytesTotal")));
    NSNotificationCenter.defaultCenter().postNotificationWithNameObjectUserInfo(
      ASImageGotProgressNotification, this,
      NSDictionary.dictionaryWithDictionary(ntf.userInfo));
  }

  //******************************************************
  //*               Common Properties
  //******************************************************

  /**
   * Returns a string representation of the image.
   */
  public function description():String {
    return "NSImage(name="+name()+", size="+size() +
    	", representation="+bestRepresentationForDevice(null)+")";
  }

  //******************************************************
  //*           Setting the size of the image
  //******************************************************

  /**
   * Sets the size of the image to <code>value</code>.
   */
  public function setSize(value:NSSize) {
    m_size = value;
    m_sizeWasSet = value != null;
  }

  /**
   * Returns the size of this image. If no size can be determined,
   * {@link NSSize#ZeroSize} is returned.
   */
  public function size():NSSize {
    if (!m_sizeWasSet || m_size.width == 0) {
      var rep:NSImageRep = bestRepresentationForDevice(null);
      if (rep != null) {
        m_size = rep.size();
      } else {
        m_size = NSSize.ZeroSize;
      }
    }
    return m_size;
  }

  //******************************************************
  //*                   Effects
  //******************************************************
  
  /**
   * <p>
   * Returns an array of filters used to adjust the appearance of the rendered
   * image.
   * </p>
   * <p>
   * This method is ActionStep-specific and may not work with all types
   * of image reps.
   * </p>
   */
  public function filters():NSArray {
    return (new NSArray()).initWithArrayCopyItems(m_filters, false);
  }
  
  /**
   * <p>
   * Sets an array of filters used to adjust the appearance of the rendered
   * image.
   * </p>
   * <p>
   * If <code>colorTransform</code> is <code>null</code>, the argument will
   * default to an empty array.
   * </p>
   * <p>
   * This method is ActionStep-specific and may not work with all types
   * of image reps.
   * </p>
   */
  public function setFilters(filters:NSArray):Void {
    if (filters == null) {
      filters = NSArray.array();
    }
    
    if (m_filters.isEqualToArray(filters)) {
      m_invalidateEffects = true;
    }
    
    m_filters = filters;
  }
  
  /**
   * <p>
   * Returns the object used to affect the appearance of the image when it is in
   * a layer above another object onscreen.
   * </p> 
   * <p>
   * This method is ActionStep-specific and may not work with all types
   * of image reps.
   * </p>
   */
  public function blendMode():Object {
    return m_blendMode;
  }

  /**
   * <p>
   * Sets the object used to affect the appearance of the image when it is in
   * a layer above another object onscreen.
   * </p>
   * <p>
   * If <code>blendMode</code> is <code>null</code> a value of 
   * <code>"normal"</code> is used.
   * </p>
   * <p>
   * This method is ActionStep-specific and may not work with all types
   * of image reps.
   * </p>
   */  
  public function setBlendMode(blendMode:Object):Void {
    if (blendMode == null) {
      blendMode = "normal";
    }
    
    if (blendMode != m_blendMode) {
      m_invalidateEffects = true;
    }
    
    m_blendMode = blendMode;
  }
  
  /**
   * Forces the image rep to rebuild itself using the effects.
   */
  public function invalidateEffects():Void {
    m_invalidateEffects = true;
  }
  
  //******************************************************
  //*            Referring to images by name
  //******************************************************

  /**
   * <p>Removes all the named images.</p>
   * 
   * <p>This method is ActionStep only.</p>
   */
  public static function clearNamedImaged():Void {
    g_images = [];
  }
  
  /**
   * Removes the image named <code>name</code> from the named image map.
   */
  public static function clearImageNamed(name:String):Void {
    delete g_images[name];
  }
  
  /**
   * Returns the <code>NSImage</code> associated with <code>name</code>.
   * This association is created by a {@link NSImage#setName()} call.
   */
  public static function imageNamed(name:String):NSImage {
    if(g_images[name]!=undefined) {
      return g_images[name];
    }
    return null;
  }

  /**
   * Sets the name of this image to <code>name</code>. After calling this
   * method, you can access this image by calling {@link NSImage#imageNamed()}.
   *
   * @see NSImage#imageNamed()
   */
  public function setName(name:String):Boolean {
    if (g_images[name] != undefined) {
      trace(asWarning("An image named " + name + " already exists. Setting anyways"));
    }
    g_images[name] = this;
    m_name = name;
    return true;
  }

  /**
   * Returns the name of this <code>NSImage</code>, or <code>null</code> if no
   * name has been set.
   */
  public function name():String {
    return m_name;
  }

  //******************************************************
  //*               Specifying the image
  //******************************************************

  /**
   * Returns <code>true</code> if this image's representation has loaded, or
   * <code>false</code> otherwise.
   */
  public function isRepresentationLoaded():Boolean {
    return m_isLoaded;
  }
  
  /**
   * Returns <code>true</code> if this image's representation is loading, or
   * <code>false</code> otherwise.
   */
  public function isRepresentationLoading():Boolean {
    return m_isLoading;
  }


  /**
   * <p>Adds <code>rep</code> to this images list of representations.</p>
   *
   * <p>Please not that actionstep has no concept of what is the "best"
   * representation for a given device. As a result, it will always choose
   * the first.</p>
   */
  public function addRepresentation(rep:NSImageRep) {
    m_representations.push(rep);
  }

  /**
   * Prepares the image for drawing on <code>mc</code>.
   */
  public function lockFocus(mc:MovieClip) {
    m_movieClipStack.push(mc);
    m_graphics.setClip(mc);
  }

  /**
   * Unlocks the top-most focused <code>MovieClip</code>.
   */
  public function unlockFocus() {
    m_movieClipStack.pop();
    
    if (m_movieClipStack.length > 0) {
    	m_graphics.setClip(m_movieClipStack[m_movieClipStack.length - 1]);
    } else {
    	m_graphics.setClip(null);
    }
  }

  /**
   * Returns the <code>MovieClip</code> on which the <code>NSImage</code>
   * currently has focus.
   */
  public function focusClip():MovieClip {
    return m_movieClipStack[m_movieClipStack.length-1];
  }

  // Getting the representations

  public function bestRepresentationForDevice(description:String):NSImageRep {
    //! this is a major hack
    return m_representations[0];
  }

  //******************************************************
  //*        Getting the last clip drawn upon
  //******************************************************
  
  /**
   * Returns a reference to the last movieclip that was drawn upon.
   */
  public function lastCanvas():MovieClip {
    return m_lastCanvas;
  }
  
  //******************************************************
  //*               Drawing the image
  //******************************************************

  /**
   * <p>Draws the image on the focused clip at location <code>point</code> as
   * expressed in the coordinate system of the focused clip.</p>
   *
   * <p>This method is ActionStep only.</p>
   */
  public function drawAtPoint(point:NSPoint):Boolean {
  	return drawInRect(NSRect.withOriginSize(point, imageRepSize()));
  }

  /**
   * <p>Draws the image on the focused clip in the rectangle <code>rect</code> as
   * expressed in the coordinate system of the focused clip.</p>
   *
   * <p>This method is ActionStep only.</p>
   */
  public function drawInRect(rect:NSRect):Boolean {
  	//
  	// Draw the background color.
  	//
    drawBackgroundInRect(rect);

    //
    // Flip the rect if necessary.
    //! TODO Figure out if this is right.
    //
    if (isFlipped()) {
      rect = new NSRect(rect.origin.x, rect.maxY(),
        rect.width(), -rect.height());
    }

    //
    // Draw the image.
    //
    var ret:Boolean = false;
    var rep:NSImageRep = bestRepresentationForDevice(null);
    if (rep != null) {
      if (rep.supportsEffects()) {
        rep.setBlendModeFilters(blendMode(), filters());
        
        if (m_invalidateEffects || rep.effectsInvalid()) {
          rep.invalidateEffects();
          m_invalidateEffects = false;
        }
      }
      
      rep.setFocus(focusClip());
      ret = rep.drawInRect(rect);
      m_lastCanvas = rep.lastCanvas();
      rep.setFocus(null);
    }

    return ret;
  }

  /**
   * <p>Draws <code>rep</code> on the focused clip in the rectangle
   * <code>rect</code> using the settings defined by this image.</p>
   *
   * <p><code>rect</code> should be expressed in the coordinate system of the
   * focused clip.</p>
   */
  public function drawRepresentationInRect(rep:NSImageRep, rect:NSRect):Boolean {
    var oldRep:NSImageRep = bestRepresentationForDevice(null);
    m_representations[0] = rep;
    var ret:Boolean = drawInRect(rect);
    m_representations[0] = oldRep;

    return ret;
  }

  /**
   * As it stands, this wraps around {@link #drawAtPoint}.
   * <code>fromRect</code>, <code>operation</code> and <code>fraction</code>
   * are ignored.
   */
  public function drawAtPointFromRectOperationFraction(point:NSPoint,
      fromRect:NSRect, operation:NSCompositingOperation, fraction:Number):Boolean {
    //! FIXME This should use fromRect, operation and fraction.
    return drawAtPoint(point);
  }

  /**
   * As it stands, this method wraps around {@link #drawInRect<}.
   * <code>fromRect</code>, <code>operation</code> and <code>fraction</code>
   * arguments are ignored.
   */
  public function drawInRectFromRectOperationFraction(inRect:NSRect,
      fromRect:NSRect, operation:NSCompositingOperation, fraction:Number):Boolean {
    //! FIXME This should use all the arguments.
    return drawInRect(inRect);
  }

  /**
   * <p>Draws the background of the image.</p>
   *
   * <p>This method is used internally.</p>
   */
  private function drawBackgroundInRect(inRect:NSRect):Void {
    if (null == m_backgroundColor || null == focusClip()) {
      return;
    }

    m_graphics.brushDownWithBrush(m_backgroundColor);
    m_graphics.drawRectWithRect(inRect, null, null);
    m_graphics.brushUp();
  }

  /**
   * Returns the image rep size based on the values of
   * {@link #scalesWhenResized} and the size of the image.
   */
  private function imageRepSize():NSSize {
  	var sz:NSSize;

  	if (scalesWhenResized()) {
  	  sz = size();
  	} else {
  	  var rep:NSImageRep = bestRepresentationForDevice(null);
  	  sz = null == rep ? NSSize.ZeroSize : rep.size();
  	}

    return sz;
  }

  //******************************************************
  //*         Determining how an image is drawn
  //******************************************************

  /**
   * Returns <code>true</code> if representations whose sizes differ from that
   * of the image will be scaled to fit when drawn.
   */
  public function scalesWhenResized():Boolean {
    return m_scalesWhenResized;
  }

  /**
   * <p>Sets whether representations whose sizes differ from that of the image
   * will be scaled to fit.</p>
   *
   * <p>If <code>flag</code> is <code>true</code> the representations will be
   * scaled.</p>
   */
  public function setScalesWhenResized(flag:Boolean):Void {
    m_scalesWhenResized = flag;
  }

  /**
   * <p>Returns the background color of the image, or <code>null</code> if no
   * background color is used.</p>
   *
   * <p>The default is <code>null</code>.</p>
   */
  public function backgroundColor():NSColor {
    return m_backgroundColor;
  }

  /**
   * <p>Sets the background color of the image to <code>color</code>. If
   * <code>color</code> is <code>null</code>, no background color will be
   * used.</p>
   *
   * <p>The default is <code>null</code>.</p>
   */
  public function setBackgroundColor(color:NSColor):Void {
    m_backgroundColor = color;
  }

  /**
   * <p>Returns <code>true</code> if the image should be drawn with a vertically
   * flipped coordinate system, or <code>false</code> if the standard
   * coordinate system should be used.</p>
   *
   * <p>The default is <code>false</code>.</p>
   */
  public function isFlipped():Boolean {
    return m_flipped;
  }

  /**
   * <p>Sets whether the image should be drawn with a vertically flipped
   * coordinate system to <code>flag</code>.</p>
   *
   * <p>The default is <code>false</code>.</p>
   */
  public function setFlipped(flag:Boolean):Void {
    m_flipped = flag;
  }

  //******************************************************
  //*              Assigning a delegate
  //******************************************************

  /**
   * <p>Sets the delegate of this image to <code>anObject</code>.</p>
   *
   * <p>Delegates are informed when an image has finished loading, and informed
   * about loading progress.</p>
   */
  public function setDelegate(anObject:Object):Void {
    m_delegate = anObject;
  }

  /**
   * Returns the delegate of the image, or <code>null</code> if there
   * is none.
   */
  public function delegate():Object {
    return m_delegate;
  }

  //******************************************************
  //*                  Class methods
  //******************************************************

  public static function images():Array {
    return g_images;
  }

  //******************************************************
  //*                  Notifications
  //******************************************************

  /**
   * This notification is posted to the default notification center when
   * an NSImage initialized using {@link #initWithContentsOfURL} finishes
   * loading its image.
   */
  public static var NSImageDidLoadNotification:Number = ASUtils.intern(
  	"NSImageDidLoadNotification");
  	
  /**
   * Posted whenever an image created using
   * <code>NSImage#initWithContentsOfURL</code> writes content to the
   * hard drive during the load process.
   *
   * The user info dictionary contains:
   *   "ASBytesLoaded": The number of bytes loaded. (Number)
   *   "ASBytesTotal": The total number of bytes in the file. (Number)
   */
  public static var ASImageGotProgressNotification:Number = ASUtils.intern(
    "ASImageGotProgress");
}