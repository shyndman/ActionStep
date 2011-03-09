/* See LICENSE for copyright and terms of use */

import org.actionstep.ASColoredView;
import org.actionstep.ASColors;
import org.actionstep.ASLabel;
import org.actionstep.color.view.ASColorPickerView;
import org.actionstep.NSColor;
import org.actionstep.NSColorList;
import org.actionstep.NSColorPicker;
import org.actionstep.NSEvent;
import org.actionstep.NSImage;
import org.actionstep.NSPoint;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.actionstep.themes.ASThemeImageNames;
import org.actionstep.themes.standard.images.ASColorCrayonRep;

import flash.filters.GlowFilter;
import org.actionstep.constants.NSTextAlignment;
import org.actionstep.themes.ASTheme;

/**
 * @author Scott Hyndman
 */
class org.actionstep.color.view.ASCrayonColorPickerView extends ASColorPickerView {
	
	//******************************************************
	//*                   Constants
	//******************************************************
	
	private static var CRAYONS_PER_ROW:Number = 8;
	private static var CRAYONS_ROW_Y_INC:Number = 20;
	private static var CRAYONS_ALT_ROW_X_OFFSET:Number = 11;
	
	//******************************************************
	//*                    Members
	//******************************************************
	
	private var m_crayonHolder:ASColoredView;
	private var m_colorName:ASLabel;
	private var m_crayonColors:NSColorList;
	private var m_selCrayonGlow:GlowFilter;
	private var m_innerDarkGlow:GlowFilter;
	private var m_lastCrayon:MovieClip;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASCrayonColorPickerView</code> class.
	 */
	public function ASCrayonColorPickerView() {
		m_crayonColors = NSColorList.colorListNamed("Crayons");
		
		var frc:NSColor = ASTheme.current().firstResponderColor();
		m_selCrayonGlow = new GlowFilter(frc.value, frc.alphaValue / 100, 5, 5,
			6, 1, false);
		m_innerDarkGlow = new GlowFilter(0x3F3F3F, 0.6, 3, 3, 2, 1, true);
	}
	
	/**
	 * Initializes and returns the <code>ASCrayonColorPickerView</code> instance with a frame
	 * area of <code>aRect</code>.
	 */
	public function initWithPicker(picker:NSColorPicker):ASCrayonColorPickerView {
		super.initWithPicker(picker);
		buildUI();
		return this;
	}
	
	/**
	 * Builds all the UI controls.
	 */
	private function buildUI():Void {
		var minSize:NSSize = m_picker.minContentSize();
		
		//
		// Build the crayon holder
		//
		m_crayonHolder = ASColoredView((new ASColoredView()).initWithFrame(
			NSRect.withOriginSize(NSPoint.ZeroPoint, minSize)));
		m_crayonHolder.setAutoresizingMask(NSView.MinXMargin | NSView.MaxXMargin 
			| NSView.MinYMargin | NSView.MaxYMargin);
		m_crayonHolder.setBackgroundColor(ASColors.whiteColor());
		m_crayonHolder.setBorderColor(ASColors.blackColor());
		addSubview(m_crayonHolder);
		
		//
		// Build the color title label
		//
		m_colorName = (new ASLabel()).initWithFrame(
			new NSRect(0, 0, minSize.width, 28));
		m_colorName.setAlignment(NSTextAlignment.NSCenterTextAlignment);
		m_colorName.setFont(ASTheme.current().boldSystemFontOfSize(13));
		m_colorName.setTextColor(new NSColor(0x757575));
		m_crayonHolder.addSubview(m_colorName);
	}
	
	//******************************************************
	//*          Creating the crayon movieclips
	//******************************************************
	
	private function createMovieClips():Boolean {
		if (super.createMovieClips()) {
			createCrayonClips();
			return true;
		}
		
		return false;
	}
	
	/**
	 * Builds the crayon clips
	 */
	private function createCrayonClips():Void {
		//
		// Get the crayon image
		//
		var crayonRep:ASColorCrayonRep = ASColorCrayonRep(NSImage.imageNamed(
			ASThemeImageNames.NSColorCrayonRepImage)
			.bestRepresentationForDevice().copyWithZone());
		var crayonSz:NSSize = crayonRep.size();
		var crayonImg:NSImage = (new NSImage()).init();
		crayonImg.addRepresentation(crayonRep);
		
		//
		// Build the crayon clips
		//
		var colors:NSColorList = m_crayonColors;
		var keys:Array = colors.allKeys().internalList();
		var len:Number = keys.length;
		var minX = (m_crayonHolder.frame().size.width - (8.5 * crayonSz.width)) / 2; 
		var x:Number = minX;
		var y:Number = 28;
		var row:Number = 0;
		var col:Number = 0;
		
		for (var i:Number = 0; i < len; i++) {
			//
			// Get the color and pass it to the rep
			//
			var c:NSColor = colors.colorWithKey(keys[i]);
			crayonRep.setColor(c);
			
			//
			// Get the clips we need and decorate them with the necessary 
			// information
			//
			var holder:MovieClip = m_crayonHolder.createBoundsMovieClip();
			holder.__colorKey = keys[i];
			holder.view = this;
			
			var base:MovieClip = holder.createEmptyMovieClip("base", 1);
			base.__colorKey = keys[i];
			base.view = this;
			
			var lightOverlay:MovieClip = holder.createEmptyMovieClip("lightOverlay", 2);
			lightOverlay.__colorKey = keys[i];
			lightOverlay.view = this;
			
			var darkOverlay:MovieClip = holder.createEmptyMovieClip("darkOverlay", 3);
			darkOverlay.__colorKey = keys[i];
			darkOverlay.view = this;
			
			//
			// Draw the crayon base colors
			//
			crayonRep.setMode(0);
			crayonImg.lockFocus(base);
			crayonImg.drawAtPoint(NSPoint.ZeroPoint);
			crayonImg.unlockFocus();
			
			//
			// Draw the light overlay
			//
			crayonRep.setMode(1);
			crayonImg.lockFocus(lightOverlay);
			crayonImg.drawAtPoint(NSPoint.ZeroPoint);
			crayonImg.unlockFocus();
			lightOverlay.blendMode = "screen";
			
			//
			// Draw the dark overlay
			//
			crayonRep.setMode(2);
			crayonImg.lockFocus(darkOverlay);
			crayonImg.drawAtPoint(NSPoint.ZeroPoint);
			crayonImg.unlockFocus();
			darkOverlay.blendMode = "multiply";
			
			//
			// Position the crayon
			//
			holder._x = x;
			holder._y = y;
			
			//
			// Add a little inner glow
			//
			holder.filters = [m_innerDarkGlow];
			
			//
			// Increment rows and columns
			//
			col++;
			if (col == CRAYONS_PER_ROW) {
				col = 0;
				row++;
				x = (row % 2 == 0) ? minX : minX + CRAYONS_ALT_ROW_X_OFFSET;
				y += CRAYONS_ROW_Y_INC;
			} else {
				x += crayonSz.width;	
			}
		}	
	}
	
	//******************************************************
	//*                Setting the color
	//******************************************************
	
	/**
	 * Overridden to remove the color name label text if need be.
	 */
	public function setColor(color:NSColor):Void {
		if (m_color.isEqual(color)) {
			return;
		}
		
		m_color = color.copyWithZone();
		
		//
		// Perform name search
		//
		var keys:Array = m_crayonColors.allKeys().internalList();
		var len:Number = keys.length;
		for (var i:Number = 0; i < len; i++) {
			if (m_crayonColors.colorWithKey(keys[i]).isEqual(m_color)) {
				m_colorName.setStringValue(keys[i]);
				m_colorName.setNeedsDisplay(true);
				// TODO crayon MC glow
				return;
			}
		}
		
		m_colorName.setStringValue("");
		m_colorName.setNeedsDisplay(true);
		m_lastCrayon.filters = [m_innerDarkGlow];
	}
	
	/**
	 * Sets the color without performing a name search
	 */
	private function _setColor(color:NSColor):Void {
		super.setColor(color);
	}
	
	//******************************************************
	//*                     Events
	//******************************************************
	
	/**
	 * Is either called when the user clicks on the picker itself, or on
	 * one of the crayons.
	 */
	public function mouseDown(event:NSEvent):Void {
		if (event.flashObject.__colorKey != undefined) {
			crayonMouseDown(event);
			return;
		}
		
		super.mouseDown(event);
	}
	
	/**
	 * Mouse down handler for crayons.
	 */
	private function crayonMouseDown(event:NSEvent):Void {
		m_lastCrayon.filters = [m_innerDarkGlow];
		
		var crayon:MovieClip = m_lastCrayon = MovieClip(event.flashObject);
		if (crayon._parent.__colorKey != undefined) {
			crayon = m_lastCrayon = crayon._parent;	
		}
		
		var filters:Array = crayon.filters;
		filters.push(m_selCrayonGlow);
		crayon.filters = filters;
		
		var key:String = crayon.__colorKey;
				
		m_colorName.setStringValue(key);
		m_colorName.setNeedsDisplay(true);
		_setColor(m_crayonColors.colorWithKey(key));
				
		m_picker["colorChanged"](this);
	}
}