/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImageRep;
import org.actionstep.NSSize;
import org.actionstep.NSView;

/**
 * Draws a MovieClip symbol attached from the swf library.
 * 
 * This class offers a few properties for working with MovieClips. The 
 * animate property determines whether attached symbols should animate, and
 * initialFrame is the initial location of the timeline playhead.
 * 
 * @author Rich Kilmer
 */
class org.actionstep.ASSymbolImageRep extends NSImageRep {
  
  private var m_symbolName:String;
  private var m_animates:Boolean;
  private var m_initialFrame:Number;
  
  /**
   * Creates a new instance of ASSymbolImageRep that will draw the symbol
   * named <code>symbolName</code> with a size of <code>size</code>.
   * 
   * If <code>size</code> is <code>null</code>, the default size of the
   * attached symbol is used.
   */
  public function ASSymbolImageRep(symbolName:String, size:NSSize) {
  	//as specified by Aqua guidelines
    m_size = size;
    m_symbolName = symbolName;
    m_animates = true;
    m_initialFrame = 0;
  }

  /**
   * Returns the size of the rep if it were to be drawn on <code>clip</code>.
   */
  public function repSizeForClip(clip:MovieClip):NSSize {
    var mc:MovieClip = clip.attachMovie(m_symbolName, "__sizingClip__", clip.getNextHighestDepth());
    var sz:NSSize = new NSSize(mc._width, mc._height);;
    mc.removeMovieClip();
    return sz;
  }
  
  /**
   * Returns <code>true</code> if symbols drawn by this image rep should
   * animate, or <code>false</code> if they should not.
   * 
   * The default is <code>true</code>.
   * 
   * @see #setAnimates
   */
  public function animates():Boolean {
    return m_animates;
  }
  
  /**
   * Sets whether the attached symbol should animate. If <code>flag</code>
   * is <code>true</code> it does, or if <code>false</code> it does not.
   * 
   * This setting does not affect images that have already been drawn.
   * 
   * @see #animates
   */
  public function setAnimates(flag:Boolean):Void {
    m_animates = flag;
  }
  
  /**
   * Returns the initial location of the timeline playhead applied to
   * attached symbols.
   * 
   * The default is <code>0</code>.
   * 
   * @see #setInitialFrame
   */
  public function initialFrame():Number {
    return m_initialFrame;
  }
  
  /**
   * Sets the initial location of the timeline playhead applied to attached
   * symbols to <code>frame</code>.
   * 
   * This setting does not affect images that have already been drawn.
   * 
   * @see #initialFrame
   */
  public function setInitialFrame(frame:Number):Void {
  	if (frame < 0) {
  	  return;
  	}
  	
    m_initialFrame = frame;
  }
  
  /**
   * Returns a string representation of the image rep.
   */
  public function description():String {
    return "ASSymbolImageRep(symbolName=" + m_symbolName + ")";
  }

  /**
   * Draws the image rep.
   */
  public function draw() {
    var clip:MovieClip;
    var level:Number = NSView.MaxClipDepth - 1000;
    var flipped:Boolean = false;
    var size:NSSize = m_size;
    
  	//
  	// Create the symbol image rep
  	//    
    if (m_drawClip.view != undefined) {
      level = m_drawClip.view.getNextDepth();
    }
    clip = m_drawClip.attachMovie(m_symbolName, embedName() + level, level);
    clip.view = m_drawClip.view;
    
    //
    // Get a size if we don't have one
    //
    if (m_size == null) {
      size = repSizeForClip(m_drawClip);
    }
    
    //
    // Determine whether the image is flipped.
    //
    if (size.height < 0) {
      flipped = true;
      m_drawPoint.y += size.height;
      m_size.height *= -1;
    }
    
    //
    // Set location and size
    //
    clip._x = m_drawPoint.x;
    clip._y = m_drawPoint.y;
    clip._width = size.width;
    clip._height = size.height;
    
    //
    // Flip the image if necessary.
    //
    if (flipped) {
      clip._yscale *= -1;
      clip._y += clip._height;
    }
    
    //
    // Set initial frame and animation properties.
    //
    if (m_animates) {
      clip.gotoAndPlay(m_initialFrame);
    } else {
      clip.gotoAndStop(m_initialFrame);
    }
    
    //
    // Add the image rep to the draw clip so that it can be removed later.
    //
    addImageRepToDrawClip(clip);
  }
  
  private function embedName():String {
    return "__"+m_symbolName+"__";
  }
}