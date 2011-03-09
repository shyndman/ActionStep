/* See LICENSE for copyright and terms of use */

import org.actionstep.ASLabel;
import org.actionstep.color.view.ASColorPickerView;
import org.actionstep.color.view.ASColorSliderCell;
import org.actionstep.graphics.ASLinearGradient;
import org.actionstep.layout.ASGrid;
import org.actionstep.layout.ASVBox;
import org.actionstep.NSArray;
import org.actionstep.NSColorPanel;
import org.actionstep.NSColorPicker;
import org.actionstep.NSComboBox;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSSlider;
import org.actionstep.NSTextField;
import org.actionstep.NSView;
import org.actionstep.ASColors;
import org.actionstep.graphics.ASGraphicUtils;
import org.actionstep.constants.NSTickMarkPosition;
import org.actionstep.constants.NSControlSize;
import org.actionstep.NSColor;

/**
 * @author Scott Hyndman
 */
class org.actionstep.color.view.ASSliderColorPickerView extends ASColorPickerView {
		
	private static var VALUE_WIDTH:Number = 40;
	private static var CONTROL_HEIGHT:Number = 18;
	private static var SLIDER_HEIGHT:Number = 36;
	private static var SPACING:Number = 5;
	
	private static var GRAY_OPTION:String = "Gray Sliders";
	private static var RGB_OPTION:String = "RGB Sliders";
	private static var HSB_OPTION:String = "HSB Sliders";
	private static var CMYK_OPTION:String = "CMYK Sliders";
		
	private static var GRAY_GRADIENT:ASLinearGradient;
		
	private static var HUE_GRADIENT:ASLinearGradient;
	private static var SATURATION_GRADIENT:ASLinearGradient;
	private static var BRIGHTNESS_GRADIENT:ASLinearGradient;
	
	private static var RED_GRADIENT:ASLinearGradient;
	private static var GREEN_GRADIENT:ASLinearGradient;
	private static var BLUE_GRADIENT:ASLinearGradient;
	
	private static var C_GRADIENT:ASLinearGradient;
	private static var M_GRADIENT:ASLinearGradient;
	private static var Y_GRADIENT:ASLinearGradient;
	private static var K_GRADIENT:ASLinearGradient;
		
	private var m_mode:Number;
	
	private var m_action:String;
	
	private var m_modePicker:NSComboBox;
	
	private var m_label1:ASLabel;
	private var m_slider1:NSSlider;
	private var m_value1:NSTextField;
	
	private var m_label2:ASLabel;
	private var m_slider2:NSSlider;
	private var m_value2:NSTextField;
	
	private var m_label3:ASLabel;
	private var m_slider3:NSSlider;
	private var m_value3:NSTextField;
	
	private var m_label4:ASLabel;
	private var m_slider4:NSSlider;
	private var m_value4:NSTextField;
			
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASSliderColorPickerView</code> class.
	 */
	public function ASSliderColorPickerView() {
	}
	
	/**
	 * Initializes and returns the <code>ASColorPickerView</code> instance with a frame
	 * area of <code>aRect</code>.
	 */
	public function initWithPicker(picker:NSColorPicker):ASSliderColorPickerView {
		super.initWithPicker(picker);
		
		m_mode = picker.mode();
		buildUI();
				
		return this;
	}
	
	/**
	 * Builds all the UI controls.
	 */
	private function buildUI():Void {
		var minSize:NSSize = m_picker.minContentSize();
		var vbox:ASVBox = (new ASVBox()).init();
		vbox.setAutoresizingMask(NSView.WidthSizable | NSView.HeightSizable);
		
		//
		// Build mode picker
		//		
		m_modePicker = (new NSComboBox()).initWithFrame(new NSRect(0, 0,
			minSize.width, CONTROL_HEIGHT));
		m_modePicker.addItemsWithObjectValues(NSArray.arrayWithArray([
			GRAY_OPTION,
			RGB_OPTION,
			HSB_OPTION,
			CMYK_OPTION
		]));
		m_modePicker.setAutoresizingMask(NSView.WidthSizable);
		m_modePicker.setTarget(this);
		m_modePicker.setAction("modeDropdownDidChange");
		vbox.addViewEnableYResizing(m_modePicker, false);
		
		//
		// Build grid
		//		
		var grid:ASGrid = (new ASGrid()).initWithNumberOfRowsNumberOfColumns(
			4, 3);
		grid.setAutoresizingMask(NSView.WidthSizable);
		grid.setXResizingEnabledForColumn(true, 0);
		grid.setXResizingEnabledForColumn(false, 1);
		grid.setXResizingEnabledForColumn(false, 2);
		
		m_slider1 = buildSlider();
		grid.putViewAtRowColumnWithXMarginsYMargins(m_slider1, 0, 0, 0, SPACING);
		m_slider2 = buildSlider();
		grid.putViewAtRowColumnWithXMarginsYMargins(m_slider2, 1, 0, 0, SPACING);
		m_slider3 = buildSlider();
		grid.putViewAtRowColumnWithXMarginsYMargins(m_slider3, 2, 0, 0, SPACING);
		m_slider4 = buildSlider();
		grid.putViewAtRowColumnWithXMarginsYMargins(m_slider4, 3, 0, 0, SPACING);
		
		m_value1 = buildValueText();
		grid.putViewAtRowColumnWithXMarginsYMargins(m_value1, 0, 1, SPACING, SPACING);
		m_value2 = buildValueText();
		grid.putViewAtRowColumnWithXMarginsYMargins(m_value2, 1, 1, SPACING, SPACING);
		m_value3 = buildValueText();
		grid.putViewAtRowColumnWithXMarginsYMargins(m_value3, 2, 1, SPACING, SPACING);
		m_value4 = buildValueText();
		grid.putViewAtRowColumnWithXMarginsYMargins(m_value4, 3, 1, SPACING, SPACING);
		
		m_label1 = buildLabel();
		grid.putViewAtRowColumnWithXMarginsYMargins(m_label1, 0, 2, 0, SPACING);
		m_label2 = buildLabel();
		grid.putViewAtRowColumnWithXMarginsYMargins(m_label2, 1, 2, 0, SPACING);
		m_label3 = buildLabel();
		grid.putViewAtRowColumnWithXMarginsYMargins(m_label3, 2, 2, 0, SPACING);
		m_label4 = buildLabel();
		grid.putViewAtRowColumnWithXMarginsYMargins(m_label4, 3, 2, 0, SPACING);	
		
		grid.setFrameWidth(minSize.width);
		vbox.addViewEnableYResizing(grid, false);
		addSubview(vbox);
	}
	
	//******************************************************
	//*                 Control creation
	//******************************************************
	
	/**
	 * Builds a slider.
	 */
	private function buildSlider():NSSlider {
		var slider:NSSlider = NSSlider((new NSSlider()).initWithFrame(
			new NSRect(12, 0, 40, SLIDER_HEIGHT)));
		slider.setCell((new ASColorSliderCell()).init());
		slider.setAutoresizingMask(NSView.WidthSizable);
		slider.setNumberOfTickMarks(3);
		slider.setTickMarkPosition(NSTickMarkPosition.NSTickMarkAbove);
		slider.cell().setControlSize(NSControlSize.NSSmallControlSize);
		slider.setContinuous(true);
		slider.setTarget(this);
		slider.setAction("changeColorComponent");
		
		return slider;
	}
	
	/**
	 * Builds a value textbox.
	 */
	private function buildValueText():NSTextField {
		var value:NSTextField = (new NSTextField()).initWithFrame(
			new NSRect(12, 0, VALUE_WIDTH, CONTROL_HEIGHT));
		
		return value;
	}
	
	/**
	 * Builds a label textbox.
	 */
	private function buildLabel():ASLabel {
		var value:ASLabel = (new ASLabel()).initWithFrame(
			new NSRect(12, 0, VALUE_WIDTH, CONTROL_HEIGHT));
		
		return value;
	}
	
	//******************************************************
	//*                 Action Methods
	//******************************************************
	
	/**
	* Returns the action-message selector (the method name of the method that 
	* will be called on <code>#target()</code>)
	*/
	public function action():String {
		return m_cell.action();
	}
	
	/**
	 * Sets the receiver’s action method to <code>value</code>.
	 */
	public function setAction(value:String) {
		m_action = value;
	}
	
	private function modeDropdownDidChange(sender:NSComboBox):Void {
		var mode:Number;
		var selection:String = sender.objectValueOfSelectedItem().toString();
		switch (selection) {
			case GRAY_OPTION:
				mode = NSColorPanel.NSGrayModeColorPanel;
				break;
				
			case RGB_OPTION:
				mode = NSColorPanel.NSRGBModeColorPanel;
				break;
				
			case HSB_OPTION:
				mode = NSColorPanel.NSHSBModeColorPanel;
				break;
				
			case CMYK_OPTION:
				mode = NSColorPanel.NSCMYKModeColorPanel;
				break;
		}
		
		m_picker.setMode(mode);
	}
	
	public function modeDidChange(oldMode:Number):Void {
		m_mode = m_picker.mode();
		tile();
	}	
	
	public function changeColorComponent(sender:NSSlider):Void {
		switch (m_mode) {
			case NSColorPanel.NSGrayModeColorPanel:
				
				break;
				
			case NSColorPanel.NSRGBModeColorPanel:
				
				if (sender == m_slider1) {
					var r:Number = m_slider1.floatValue();
					m_color["m_red"] = r / 100;
					m_value1.setStringValue(Math.round(r).toString());
					m_value1.setNeedsDisplay(true);
				}
				else if (sender == m_slider2) {
					var g:Number = m_slider2.floatValue();
					m_color["m_green"] = g / 100;
					m_value2.setStringValue(Math.round(g).toString());
					m_value2.setNeedsDisplay(true);
				} else {
					var b:Number = m_slider3.floatValue();
					m_color["m_blue"] = b / 100;
					m_value3.setStringValue(Math.round(b).toString());
					m_value3.setNeedsDisplay(true);
				}
				
				setRGBGradients(m_color, sender);
				
				m_target[m_action](this);
				break;
				
			case NSColorPanel.NSHSBModeColorPanel:
				
				if (sender == m_slider1) {
					var hue:Number = sender.floatValue();
					m_color["m_hue"] = hue / 360;
					
					var pureHue:NSColor = NSColor.colorWithCalibratedHueSaturationBrightnessAlpha(
					m_color.hueComponent(), 1, 1, 1);
					SATURATION_GRADIENT["m_gradientArgs"][1][1] = pureHue.value;
					BRIGHTNESS_GRADIENT["m_gradientArgs"][1][1] = pureHue.value;
					
					m_slider2.setNeedsDisplay(true);
					m_slider3.setNeedsDisplay(true);
					
					m_value1.setStringValue(Math.round(hue).toString());
					m_value1.setNeedsDisplay(true);
				}
				else if (sender == m_slider2) {
					var sat:Number = sender.floatValue();
					m_color["m_saturation"] = sat / 100;
					
					m_value2.setStringValue(Math.round(sat).toString());
					m_value2.setNeedsDisplay(true);
				}
				else if (sender == m_slider3) {
					var bright:Number = sender.floatValue();
					m_color["m_brightness"] = bright / 100;
					
					m_value3.setStringValue(Math.round(bright).toString());
					m_value3.setNeedsDisplay(true);
				}
				
				m_target[m_action](this);
				break;
				
			case NSColorPanel.NSCMYKModeColorPanel:
				
				break;
		}
	}
	
	//******************************************************
	//*                Layout and drawing
	//******************************************************
	
	/**
	 * Tiles the contents of this view. To be overridden by subclasses.
	 */
	public function tile():Void {
		var option:String;
		var curOption:String = m_modePicker.objectValueOfSelectedItem().toString();
		switch (m_mode) {
			case NSColorPanel.NSGrayModeColorPanel:
				option = GRAY_OPTION;
				
				setRowHidden(1, false);
				setRowHidden(2, true);
				setRowHidden(3, true);
				setRowHidden(4, true);
								
				setRowValues(1, "White", "%", 100, m_color.redComponent() * 100, GRAY_GRADIENT);
				break;
				
			case NSColorPanel.NSRGBModeColorPanel:
				option = RGB_OPTION;
				
				setRowHidden(1, false);
				setRowHidden(2, false);
				setRowHidden(3, false);
				setRowHidden(4, true);
				
				setRGBGradients(m_color);
				
				setRowValues(1, "Red", "%", 100, m_color.redComponent() * 100, RED_GRADIENT);
				setRowValues(2, "Green", "%", 100, m_color.greenComponent() * 100, GREEN_GRADIENT);
				setRowValues(3, "Blue", "%", 100, m_color.blueComponent() * 100, BLUE_GRADIENT);
				
				
				break;
				
			case NSColorPanel.NSHSBModeColorPanel:
				option = HSB_OPTION;
				
				setRowHidden(1, false);
				setRowHidden(2, false);
				setRowHidden(3, false);
				setRowHidden(4, true);
				
				var pureHue:NSColor = NSColor.colorWithCalibratedHueSaturationBrightnessAlpha(
					m_color.hueComponent(), 1, 1, 1);
				SATURATION_GRADIENT["m_gradientArgs"][1][1] = pureHue.value;
				BRIGHTNESS_GRADIENT["m_gradientArgs"][1][1] = pureHue.value;
				
				setRowValues(1, "Hue", "º", 360, m_color.hueComponent() * 360, 
					HUE_GRADIENT);
				setRowValues(2, "Saturation", "%", 100, m_color.saturationComponent() * 100,
					SATURATION_GRADIENT);
				setRowValues(3, "Brightness", "%", 100, m_color.brightnessComponent() * 100,
					BRIGHTNESS_GRADIENT);
					
				m_target[m_action](this);
				break;
				
			case NSColorPanel.NSCMYKModeColorPanel:
				option = CMYK_OPTION;
				
				setRowHidden(1, false);
				setRowHidden(2, false);
				setRowHidden(3, false);
				setRowHidden(4, false);
				
				setRowValues(1, "Cyan", "%", 100);
				setRowValues(2, "Magenta", "%", 100);
				setRowValues(3, "Yellow", "%", 100);
				setRowValues(4, "Black", "%", 100);
				break;
		}
		
		if (curOption != option) {
			m_modePicker.selectItemWithObjectValue(option);
		}
		
		
	}
	
	private function setRowHidden(row:Number, flag:Boolean):Void {
		this["m_label" + row].setHidden(flag);
		this["m_value" + row].setHidden(flag);
		this["m_slider" + row].setHidden(flag);
	}
	
	private function setRowValues(row:Number, title:String, postfix:String, 
			max:Number, value:Number, gradient:ASLinearGradient):Void {
		gradient.setMatrix(ASGraphicUtils.linearGradientMatrixWithRectDegrees(
			this["m_slider" + row].bounds()), ASLinearGradient.ANGLE_LEFT_TO_RIGHT);
				
		this["m_label" + row].setStringValue(postfix);
		this["m_slider" + row].setTitle(title);
		this["m_slider" + row].setMaxValue(max);
		this["m_slider" + row].setFloatValue(value);
		this["m_slider" + row].cell().setGradient(gradient);
		this["m_value" + row].setStringValue(Math.round(value).toString());
		
		this["m_label" + row].setNeedsDisplay(true);
		this["m_slider" + row].setNeedsDisplay(true);
		this["m_value" + row].setNeedsDisplay(true);
	}
	
	//******************************************************
	//*                   Gradients
	//******************************************************
	
	private function setRGBGradients(color:NSColor, exclude:Object) {
		if (exclude != m_slider1) {
			var rLo:NSColor = NSColor.colorWithCalibratedRedGreenBlueAlpha(
				0, color["m_green"], color["m_blue"], 1);
			var rHi:NSColor = NSColor.colorWithCalibratedRedGreenBlueAlpha(
				1, color["m_green"], color["m_blue"], 1);
			var cs:Array = RED_GRADIENT["m_gradientArgs"][1];
			cs[0] = rLo.value;
			cs[1] = rHi.value;
			
			m_slider1.setNeedsDisplay(true);
		}
		
		if (exclude != m_slider2) {
			var gLo:NSColor = NSColor.colorWithCalibratedRedGreenBlueAlpha(
				color["m_red"], 0, color["m_blue"], 1);
			var gHi:NSColor = NSColor.colorWithCalibratedRedGreenBlueAlpha(
				color["m_red"], 1, color["m_blue"], 1);
			var cs:Array = GREEN_GRADIENT["m_gradientArgs"][1];
			cs[0] = gLo.value;
			cs[1] = gHi.value;
			
			m_slider2.setNeedsDisplay(true);
		}
		
		if (exclude != m_slider3) {
			var bLo:NSColor = NSColor.colorWithCalibratedRedGreenBlueAlpha(
				color["m_red"], color["m_green"], 0, 1);
			var bHi:NSColor = NSColor.colorWithCalibratedRedGreenBlueAlpha(
				color["m_red"], color["m_green"], 1, 1);
			var cs:Array = BLUE_GRADIENT["m_gradientArgs"][1];
			cs[0] = bLo.value;
			cs[1] = bHi.value;
			
			m_slider3.setNeedsDisplay(true);
		}
	}
	
	//******************************************************
	//*                Class construction
	//******************************************************
	
	private static function initialize():Void {
		//
		// Hue
		//
		var colors:Array = [
			ASColors.redColor(),
			ASColors.yellowColor(),
			ASColors.greenColor(),
			ASColors.cyanColor(),
			ASColors.blueColor(),
			ASColors.magentaColor(),
			ASColors.redColor()];
		var ratios:Array = [];
		var stepSize:Number = 255 / 6;
		var cur:Number = 0;
		for (var i:Number = 0; i < 7; i++) {
			ratios.push(cur);
			cur += stepSize;
		}
		
		HUE_GRADIENT = new ASLinearGradient(colors, ratios, 
			ASGraphicUtils.linearGradientMatrixWithRectDegrees(
			new NSRect(0, 0, 30, 20), ASLinearGradient.ANGLE_LEFT_TO_RIGHT));
			
		//
		// Saturation
		//
		colors = [
			ASColors.whiteColor(),
			ASColors.greenColor()];
		ratios = [0, 255];
		
		SATURATION_GRADIENT = new ASLinearGradient(colors, ratios, 
			ASGraphicUtils.linearGradientMatrixWithRectDegrees(
			new NSRect(0, 0, 30, 20), ASLinearGradient.ANGLE_LEFT_TO_RIGHT));
			
		//
		// Saturation
		//
		colors = [
			ASColors.blackColor(),
			ASColors.greenColor()];
		ratios = [0, 255];
		
		BRIGHTNESS_GRADIENT = new ASLinearGradient(colors, ratios, 
			ASGraphicUtils.linearGradientMatrixWithRectDegrees(
			new NSRect(0, 0, 30, 20), ASLinearGradient.ANGLE_LEFT_TO_RIGHT));
			
		//
		// Gray
		//
		colors = [
			ASColors.blackColor(),
			ASColors.whiteColor()];
		ratios = [0, 255];
		
		GRAY_GRADIENT = new ASLinearGradient(colors, ratios, 
			ASGraphicUtils.linearGradientMatrixWithRectDegrees(
			new NSRect(0, 0, 30, 20), ASLinearGradient.ANGLE_LEFT_TO_RIGHT));
			
		//
		// Red
		//
		colors = [
			ASColors.blackColor(),
			ASColors.redColor()];
		ratios = [0, 255];
		
		RED_GRADIENT = new ASLinearGradient(colors, ratios, 
			ASGraphicUtils.linearGradientMatrixWithRectDegrees(
			new NSRect(0, 0, 30, 20), ASLinearGradient.ANGLE_LEFT_TO_RIGHT));
			
		//
		// Green
		//
		colors = [
			ASColors.blackColor(),
			ASColors.greenColor()];
		ratios = [0, 255];
		
		GREEN_GRADIENT = new ASLinearGradient(colors, ratios, 
			ASGraphicUtils.linearGradientMatrixWithRectDegrees(
			new NSRect(0, 0, 30, 20), ASLinearGradient.ANGLE_LEFT_TO_RIGHT));
			
		//
		// Gray
		//
		colors = [
			ASColors.blackColor(),
			ASColors.blueColor()];
		ratios = [0, 255];
		
		BLUE_GRADIENT = new ASLinearGradient(colors, ratios, 
			ASGraphicUtils.linearGradientMatrixWithRectDegrees(
			new NSRect(0, 0, 30, 20), ASLinearGradient.ANGLE_LEFT_TO_RIGHT));
	}
}