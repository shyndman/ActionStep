/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDraw;
import org.actionstep.constants.NSControlSize;
import org.actionstep.constants.NSProgressIndicatorStyle;
import org.actionstep.NSImage;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSTimer;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;

/**
 * <p>This view is used to show that a lengthy task is being performed. A progress 
 * indicator can be determinate, meaning that the task's progress can be
 * measured in some real way and represented as a percentage, or indeterminate,
 * meaning that the indicator will do nothing more than spin to show that the
 * application is busy.</p>
 * 
 * <p>For examples of this class' usage, please see
 * {@link org.actionstep.test.ASTestProgressIndicator}.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSProgressIndicator extends NSView 
{
	//******************************************************															 
	//*                    Constants
	//******************************************************
	
	public static var NSProgressIndicatorPreferredThickness:Number 		= 14;
	public static var NSProgressIndicatorPreferredSmallThickness:Number	= 10;
	public static var NSProgressIndicatorPreferredLargeThickness:Number	= 18;
	
//
//	TODO we can't share patterns across all Indicators since the patterns may be different sizes. 
//	so instead of using image names and the ImageReps from ASTheme, we're creating our images here, 
//	one per indicator. This kind of sucks, but could be alleviated one multiple image reps per 
//	NSImage are working.
//

//	private static var INDET_PATTERN_NAME:String = "NSProgressBarIndeterminatePatternRep";
//	private static var DET_PATTERN_NAME:String   = "NSProgressBarDeterminatePatternRep";
//	private static var SPINNER_NAME:String = "NSProgressBarSpinnerRep";
	private static var INDET_CLASS:Function   = org.actionstep.themes.standard.images.ASProgressBarIndeterminatePatternRep;
	private static var DET_CLASS:Function     = org.actionstep.themes.standard.images.ASProgressBarDeterminatePatternRep;
	private static var SPINNER_CLASS:Function = org.actionstep.themes.standard.images.ASProgressBarSpinnerRep;
	private var m_image:NSImage;

	private static var ANIMATION_DELTA_X:Number = 2;
	
	//******************************************************															 
	//*                Member variables
	//******************************************************
	
	private var m_dblValue:Number;
	private var m_minValue:Number;
	private var m_maxValue:Number;
	
	private var m_controlSize:NSControlSize;
	private var m_bezeled:Boolean;
	private var m_indeterminate:Boolean;
	private var m_animated:Boolean;
	private var m_style:NSProgressIndicatorStyle;
	private var m_displayWhenStopped:Boolean;
	
	private var m_animationOverlay:MovieClip;
	private var m_animationOverlayMask:MovieClip;
	private var m_bezelOverlay:MovieClip;
	private var m_overlayInvalidated:Boolean;
	private var m_animationDelay:Number;
	private var m_animationTimer:NSTimer;
	private var m_isAnimating:Boolean;
	private var m_animationStep:Number;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of NSProgressIndicator.
	 */
	public function NSProgressIndicator()
	{
		m_minValue = 0;
		m_maxValue = 100;
		m_dblValue = 0;
		m_bezeled = true;
		m_style = NSProgressIndicatorStyle.NSProgressIndicatorBarStyle;
		m_indeterminate = false;
		m_animated = false;
		m_displayWhenStopped = true;
		m_isAnimating = true;
		m_animationDelay = 0.0322; // 1/31
		m_animationTimer = new NSTimer();
		m_animationStep = 0;
		m_overlayInvalidated = true;
	}
	
	/**
	 * Overridden to create the overlay clip for indeterminate progress bars.
	 */
	public function createMovieClips():Void 
	{
		if (m_mcFrame != null)
		{
			//return if already created
			return;
		}
    
		super.createMovieClips();
		
//		m_animationOverlayMask = m_mcFrame.createEmptyMovieClip("m_animationOverlayMask", getNextDepth());
//		m_animationOverlay = m_animationOverlayMask.createEmptyMovieClip("m_animationOverlay", 1);
		//
		// TODO need to get m_animationOverlay embedded in another clip. or add a mask 
		// and move the mask as m_animationOverlay is moved.
		// 
		m_animationOverlay = m_mcFrame.createEmptyMovieClip("m_animationOverlay", getNextDepth());
		m_animationOverlay._x = 0;
		m_animationOverlay._y = 0;
		m_animationOverlay.view = this;
		
		m_animationOverlayMask = m_mcFrame.createEmptyMovieClip("m_animationOverlayMask", getNextDepth());
		m_animationOverlayMask._x = 0;
		m_animationOverlayMask._y = 0;
		m_animationOverlayMask.view = this;
		m_animationOverlay.setMask(m_animationOverlayMask);
//		m_animationOverlayMask.setMask(m_animationOverlay);

		m_bezelOverlay = m_mcFrame.createEmptyMovieClip("bezelOverlay", getNextDepth());
		m_bezelOverlay.view = this;
	}
	
	/**
	 * Overridden to flag the indeterminate overlay as needing a redraw.
	 */
	private function updateFrameMovieClipSize():Void 
	{
		super.updateFrameMovieClipSize();
		
		m_overlayInvalidated = true;
	}
	
	//******************************************************															 
	//*          Animating the progress indicator
	//******************************************************
	
	/**
	 * Advances the animation of an indeterminate progress indicator by one 
	 * step.
	 */
	public function animate():Void
	{
		if (!isAnimated()) {
			return;
		}
		
		m_animationStep += ANIMATION_DELTA_X;
		setNeedsDisplay(true);
	}
	
	/**
	 * Returns the delay (in seconds) between animation steps for an
	 * indeterminate progress bar. 
	 */
	public function animationDelay():Number
	{
		return m_animationDelay;
	}
	
	/**
	 * Sets the delay (in seconds) between animation steps for an indeterminate
	 * progress bar to <code>delay</code>.
	 */
	public function setAnimationDelay(delay:Number):Void
	{
		if (delay < 0)
		  return;
		  
		m_animationDelay = delay;
	}
	
	/**
	 * Starts the animation of an indeterminate progress bar.
	 */
	public function startAnimation():Void
	{
		if (!isAnimated()) {
			return;
		}
		
		stopAnimation();
		m_animationTimer.initWithFireDateIntervalTargetSelectorUserInfoRepeats(
			new Date(), m_animationDelay, this, "animate", null, true);
			
		m_isAnimating = true;
		setHidden(false);
	}
	
	/**
	 * Stops the animation of an indeterminate progress bar.
	 */
	public function stopAnimation():Void
	{
		if (!isAnimated()) {
			return;
		}
		
		m_animationTimer.invalidate();
		m_isAnimating = false;
		if (!isDisplayedWhenStopped()) {
			setHidden(true);
		}
	}
	
	//******************************************************															 
	//*             Advancing the progress bar
	//******************************************************
	
	/**
	 * <p>Advances a determinate progress bar by <code>delta</code>.</p>
	 * 
	 * <p>This method does nothing if the indicator is indeterminate.</p>
	 */
	public function incrementBy(delta:Number):Void
	{
		setDoubleValue(doubleValue() + delta);
	}
	
	/**
	 * Returns the progress of the bar, or <code>null</code> if this progress
	 * indicator is indeterminate.
	 */
	public function doubleValue():Number
	{
		if (isIndeterminate()) {
			return null;
		}
		
		return m_dblValue;
	}
	
	/**
	 * <p>Sets the progress of the bar to <code>value</code>.</p>
	 * 
	 * <p>This method does nothing if the indicator is indeterminate.</p>
	 */
	public function setDoubleValue(value:Number):Void
	{
		if (isIndeterminate() || m_dblValue == value) {
			return;
		}
		
		m_dblValue = value;
		
		if (m_dblValue > maxValue())
		{
			m_dblValue = maxValue();
		}
		else if (m_dblValue < minValue())
		{
			m_dblValue = minValue();
		}
		setNeedsDisplay(true);
	}
	
	/**
	 * Returns the minimum value of the progress bar.
	 */
	public function minValue():Number
	{
		return m_minValue;
	}
	
	/**
	 * Sets the minimum value of the progress bar to <code>value</code>.
	 */
	public function setMinValue(value:Number):Void
	{
		m_minValue = value;
	}

	/**
	 * Returns the maximum value of the progress bar.
	 */	
	public function maxValue():Number
	{
		return m_maxValue;
	}

	/**
	 * Sets the maximum value of the progress bar to <code>value</code>.
	 */	
	public function setMaxValue(value:Number):Void
	{
		m_maxValue = value;
	}
	
	//******************************************************															 
	//*              Setting the appearance         
	//******************************************************
	
	/**
	 * Returns the size of the progress bar.
	 */
	public function controlSize():NSControlSize
	{
		return m_controlSize;
	}
	
	/**
	 * <p>Sets the size of the progress bar to <code>size</code>.</p>
	 * 
	 * <p>Setting this value should be followed by a call to 
	 * {@link #sizeToFit} if you wish for the progress indicator to size
	 * appropriately.</p>
	 */
	public function setControlSize(size:NSControlSize):Void
	{
		m_controlSize = size;
	}
	
	/**
	 * Returns whether the progress bar has a 3-dimensions bezel.
	 */
	public function isBezeled():Boolean
	{
		return m_bezeled;
	}
	
	/**
	 * Sets whether the progress bar has a 3-dimensional bezel. If 
	 * <code>flag</code> is <code>true</code> it will.
	 */
	public function setBezeled(flag:Boolean):Void
	{
		m_bezeled = flag;
	}
	
	/**
	 * Returns <code>true</code> if the progress bar is indeterminate, or 
	 * false otherwise.
	 */
	public function isIndeterminate():Boolean
	{
		return m_indeterminate || style() 
			== NSProgressIndicatorStyle.NSProgressIndicatorSpinningStyle;
	}

	public function isAnimated():Boolean
	{
		return m_animated || style() 
			== NSProgressIndicatorStyle.NSProgressIndicatorSpinningStyle;
	}
	
	/**
	 * If <code>flag</code> is <code>true</code>, the progress indicator will
	 * be indeterminate.
	 */
	public function setIndeterminate(flag:Boolean):Void
	{
		if (m_indeterminate == flag) {
			return;
		}
		
		m_indeterminate = flag;
		setAnimated(m_indeterminate);
		m_overlayInvalidated = true;
	}
	
	/**
	 * If <code>flag</code> is <code>true</code>, the progress indicator will
	 * be animated.
	 */
	public function setAnimated(flag:Boolean):Void
	{
		if (m_animated == flag) {
			return;
		}
		
		m_animated = flag;
		
		if (!m_animated) {
			m_isAnimating = true;
			m_animationOverlay._visible = false;
			setHidden(false);
		} else {
			m_animationOverlay._visible = true;
			stopAnimation();
		}
	}
	
	/**
	 * Returns this progress indicator's style.
	 */
	public function style():NSProgressIndicatorStyle
	{
		return m_style;
	}
	
	/**
	 * Sets the style of this progress indicator to <code>style</code>.
	 */
	public function setStyle(style:NSProgressIndicatorStyle):Void
	{
		if (m_style == style) {
			return;
		}
		
		m_style = style;
		stopAnimation();
		
		m_overlayInvalidated = true;
		
		if (m_style == NSProgressIndicatorStyle.NSProgressIndicatorSpinningStyle) {
			setIndeterminate(true);
		}
		
		if (!isDisplayedWhenStopped() && !m_isAnimating) {
			setHidden(false);
		}
	}
	
	/**
	 * Sets up the image to use.
	 */
	public function setupImage():Void {
		var klass:Function;
    
		if (m_style == NSProgressIndicatorStyle.NSProgressIndicatorSpinningStyle) {
			klass = SPINNER_CLASS;
		}
		else if (isIndeterminate()){
			klass = INDET_CLASS;
		}
		else {
			klass = DET_CLASS;
		}
		if (m_image != null) {
			m_image.release();
		}
		m_image = (new NSImage()).init();
//		image.setName(name);
		m_image.addRepresentation(new klass());
	}

	
	/**
	 * Sizes the progress indicator to the size defined by {@link #style}.
	 */
	public function sizeToFit():Void
	{
		if (null == m_controlSize) {
			return;
		}
		
		var sz:NSSize = ASTheme.current().progressIndicatorSizeForSize(
			m_controlSize);
			
		if (null != sz) {
			setFrameSize(sz);
		}
	}
	
	/**
	 * <p>Returns <code>true</code> if the progress bar is visible when not 
	 * animating.</p>
	 * 
	 * <p>If {@link #style()} is 
	 * {@link NSProgressIndicatorStyle#NSProgressIndicatorSpinningStyle} 
	 * this will always return <code>false</code>.</p>
	 * 
	 * @see #setDisplayedWhenStopped
	 */
	public function isDisplayedWhenStopped():Boolean
	{
		return m_displayWhenStopped 
			&& m_style != NSProgressIndicatorStyle.NSProgressIndicatorSpinningStyle;
	}
	
	/**
	 * Sets whether the progress bar is visible when not animating. If
	 * <code>true</code> the progress bar will remain visible when stopped.
	 * 
	 * @see #isDisplayedWhenStopped
	 */
	public function setDisplayedWhenStopped(flag:Boolean):Void
	{
		if (flag == m_displayWhenStopped) {
			return;
		}
		
		m_displayWhenStopped = flag;
		
		if (!m_isAnimating && !m_displayWhenStopped) {
			setHidden(true);
		}
	}
	
	//******************************************************															 
	//*           Drawing the progress indicator
	//******************************************************
	
	/**
	 * Draws the progress indicator.
	 */
	public function drawRect(rect:NSRect):Void
	{
		mcBounds().clear();
		
		var style:NSProgressIndicatorStyle = style();
		var indet:Boolean   = isIndeterminate();
		var animate:Boolean = isAnimated();
		
		if (style == NSProgressIndicatorStyle.NSProgressIndicatorBarStyle)
		{
			//
			// Get the progress.
			//
			var progress:Number;
			if (indet) {
				progress = -1;
			} else {
				progress = ((m_dblValue - m_minValue) / 
					(m_maxValue - m_minValue)) * 100;	
			}
			
			if (animate) 
			{
				//
				// Draw the indeterminate parts.
				//
				if (m_overlayInvalidated) {
					drawPatternOverlayInRect(rect);
				}

				m_animationStep %= m_image.size().width;
				m_animationOverlay._x = -m_animationStep;

				if (!indet) {
					var maskRect:NSRect = rect.clone();
					var width:Number = maskRect.size.width;
					//
					// the overlay rect should be the full size
					// the masking rect should be smaller and clip out the animation.
					//					
					maskRect.size.width = width*progress/100;
					m_animationOverlayMask.clear();
					ASDraw.fillRectWithRect(m_animationOverlayMask, maskRect, 0x000000);
//					m_animationOverlayMask._x = -m_animationOverlay._x;
				}
			}
			
			//
			// Draw the bar.
			//
			//TODO separate out the bezel and don't draw the bar unless it's actually needed.
			ASTheme.current().drawProgressBarInRectWithViewBezeledProgress(
				rect, this, m_bezeled, progress);

			m_bezelOverlay.clear();
			ASTheme.current().drawProgressBarBorderInRectWithClipBezeledProgress(
				rect, m_bezelOverlay, m_bezeled, progress);
		}
		else if (style == NSProgressIndicatorStyle.NSProgressIndicatorSpinningStyle)
		{
			//! FIXME Deal with animation somehow.
			
			if (m_overlayInvalidated) {
				drawSpinnerOverlayInRect(rect);
			}
			m_animationOverlay._rotation += 15;
			// TODO should probably not use the mask on spinning style, or indeterminate style
			m_animationOverlayMask.clear();
			ASDraw.fillRectWithRect(m_animationOverlayMask, rect, 0x000000);
		}
	}

	/**
	 * Draws the pattern overlay for an indeterminate progress bar.
	 */
	private function drawPatternOverlayInRect(rect:NSRect):Void
	{
		setupImage();

		m_animationOverlay.cacheAsBitmap = false;
		m_animationOverlay.clear();
		
		// the width of the pattern is set to the height of the bar. this may need to change.
		var patternRect:NSRect = new NSRect(0, 0, frame().size.height, frame().size.height);
		if (m_bezeled) {
			patternRect.origin.y += 2;
			patternRect.size.height -= 4;
			patternRect.size.width  -= 4;
		}
		var repetitions:Number = Math.ceil(rect.size.width / patternRect.size.width) + 1;
		m_image.setSize(patternRect.size);
		m_image.lockFocus(m_animationOverlay);
		for (var i:Number = 0; i < repetitions; i++)
		{
			// using drawInRect will scale the image rep for us.
			m_image.drawInRect(patternRect);
			patternRect.origin.x += patternRect.size.width;
		}
		
		m_image.unlockFocus();
		m_animationOverlay.cacheAsBitmap = true;

		m_overlayInvalidated = false;
	}
	
	private function drawSpinnerOverlayInRect(rect:NSRect):Void
	{
		setupImage();
		m_animationOverlay.clear();

		
		var sz:NSSize = frame().size;
		var diameter:Number = sz.width < sz.height ? sz.width : sz.height;
		var spinnerRect:NSRect = new NSRect(-(sz.width-diameter)/2, -(sz.height-diameter)/2, diameter, diameter);

		m_image.setSize(sz);
		m_image.lockFocus(m_animationOverlay);
		m_image.drawInRect(spinnerRect);
		m_image.unlockFocus();

		m_animationOverlay._x = sz.width / 2;
		m_animationOverlay._y = sz.height / 2;

		m_overlayInvalidated = false;
	}
	
	//******************************************************
	//*                 Class construction
	//******************************************************
}