/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColors;
import org.actionstep.ASDraw;
import org.actionstep.NSColor;
import org.actionstep.NSEvent;
import org.actionstep.NSPoint;
import org.actionstep.NSProgressIndicator;
import org.actionstep.NSRect;
import org.actionstep.NSView;
import org.actionstep.themes.ASTheme;
import org.actionstep.themes.ASThemeColorNames;
import org.actionstep.themes.ASThemeProtocol;

/**
 * @author Scott Hyndman
 */
class org.actionstep.movie.ASMovieProgressBar extends NSProgressIndicator {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_target:Object;
	private var m_action:String;
	private var m_loadedValue:Number;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASMovieProgressBar</code> class.
	 */
	public function ASMovieProgressBar() {
		m_loadedValue = 0;
	}
	
	/**
	 * Initializes and returns the <code>ASMovieProgressBar</code> instance with a frame
	 * area of <code>aRect</code>.
	 */
	public function initWithFrame(aRect:NSRect):ASMovieProgressBar {
		super.initWithFrame(aRect);
		
		return this;
	}
	
	//******************************************************
	//*             Setting the load progress
	//******************************************************
	
	/**
	 * Returns a value from 0 to 1 representing the current load progress of
	 * the flv.
	 */
	public function loadProgress():Number {
		return m_loadedValue;
	}
	
	/**
	 * Returns a value from 0 to 1 representing the current load progress of
	 * the flv.
	 */
	public function setLoadProgress(value:Number):Void {
		if (value < 0) {
			value = 0;
		}
		else if (value > 1) {
			value = 1;
		}
		
		m_loadedValue = value;
	}
	
	//******************************************************
	//*               Target action stuff
	//******************************************************
	
	public function setAction(value:String) {
		m_action = value;
	}
	
	public function action():String {
		return m_action;
	}
	
	public function setTarget(value:Object) {
		m_target = value;
	}
	
	public function target():Object {
		return m_target;
	}

	//******************************************************
	//*               Dealing with events
	//******************************************************
	
	public function mouseDown(event:NSEvent):Void {
		var pt:NSPoint = convertPointFromView(event.mouseLocation, null);
		var percent:Number = pt.x / m_frame.size.width;
		setDoubleValue(percent);
		setNeedsDisplay(true);
		
		//
		// Call action
		//
		m_target[m_action](this);
	}
	
	//******************************************************
	//*                    Drawing
	//******************************************************
	
	public function drawRect(rect:NSRect):Void {		
		var theme:ASThemeProtocol = ASTheme.current();
		
		this.mcBounds().clear();
		
		//
		// Draw background
		//
		ASDraw.fillRectWithRect(this.mcBounds(), rect,
			theme.colorWithName(ASThemeColorNames.ASProgressBarBackground).value);
      
		//
		// Get the progress.
		//
		var progress:Number = m_loadedValue * 100;
				
		//
		// Draw the loading bar.
		//
		drawProgressBarInRectWithViewBezeledProgressColor(
			rect, this, m_bezeled, progress, 
			ASColors.grayColor());		
		
		//
		// Draw the playhead bar.
		//
		progress = ((m_dblValue - m_minValue) / (m_maxValue - m_minValue)) * 100;
		drawProgressBarInRectWithViewBezeledProgressColor(
			rect, this, m_bezeled, progress, 
			new NSColor(0x336CC2));

		//
		// Draw the border
		//
		m_bezelOverlay.clear();
		theme.drawProgressBarBorderInRectWithClipBezeledProgress(
			rect, m_bezelOverlay, m_bezeled, progress);
	}
	
	/**
	 * Draws a progress bar
	 */
	public function drawProgressBarInRectWithViewBezeledProgressColor(
			rect:NSRect, aView:NSView, bezeled:Boolean, progress:Number,
			color:NSColor):Void {
		var mc:MovieClip = aView.mcBounds();

		if (progress > 100 || progress <= 0) {
			return;
		}
		
		//
		// Draw progress bar
		//
		var pbColor1:NSColor = color;
		var pbColor2:NSColor = pbColor1.adjustColorBrightnessByFactor(0.6);
		var alpha:Number = pbColor1.alphaComponent() * 100;
		rect = rect.insetRect(0,1);
		rect = rect.insetRect(0,-1);
		rect.size.width *= progress / 100;
		ASDraw.gradientRectWithAlphaRect(mc, rect, 90, [pbColor1.value, pbColor2.value], [0, 255], [alpha, alpha]);
	}
}