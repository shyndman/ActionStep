/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.constants.NSNumberFormatterPadPosition;
import org.actionstep.constants.NSNumberFormatterRoundingMode;
import org.actionstep.constants.NSNumberFormatterStyle;
import org.actionstep.formatter.ASFormatResult;
import org.actionstep.NSAttributedString;
import org.actionstep.NSDictionary;
import org.actionstep.NSFormatter;
import org.actionstep.NSNumber;

/**
 *
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSNumberFormatter extends NSFormatter {	

	private var m_negativeFormat:String;
	private var m_positiveFormat:String;
	private var m_formatWidth:Number;
	private var m_multiplier:Number;
	private var m_paddingCharacter:String;
	private var m_paddingPosition:NSNumberFormatterPadPosition;
	private var m_currencySymbol:String;
	private var m_internationalCurrencySymbol:String;
	private var m_percentSymbol:String;
	private var m_perMillSymbol:String;
	private var m_minusSign:String;
	private var m_plusSign:String;
	private var m_exponentSymbol:String;
	private var m_zeroSymbol:String;
	private var m_nilSymbol:String;
	private var m_notANumberSymbol:String;
	private var m_negativeInfinitySymbol:String;
	private var m_positiveInfinitySymbol:String;
	private var m_positivePrefix:String;
	private var m_positiveSuffix:String;
	private var m_negativePrefix:String;
	private var m_negativeSuffix:String;
	private var m_textAttributesForNegativeValues:NSDictionary;
	private var m_textAttributesForPositiveValues:NSDictionary;
	private var m_attributedStringForZero:NSAttributedString;
	private var m_textAttributesForZero:NSDictionary;
	private var m_attributedStringForNil:NSAttributedString;
	private var m_textAttributesForNil:NSDictionary;
	private var m_attributedStringForNotANumber:NSAttributedString;
	private var m_textAttributesForNotANumber:NSDictionary;
	private var m_textAttributesForPositiveInfinity:NSDictionary;
	private var m_textAttributesForNegativeInfinity:NSDictionary;
	private var m_hasThousandsSeparators:Boolean;
	private var m_thousandSeparator:String;
	private var m_decimalSeparator:String;
	private var m_alwaysShowsDecimalSeparator:Boolean;
	private var m_currencyDecimalSeparator:String;
	private var m_usesGroupingSeparator:Boolean;
	private var m_groupingSeparator:String;
	private var m_groupingSize:Number;
	private var m_secondaryGroupingSize:Number;
	private var m_currencyCode:String;
	private var m_allowsFloats:Boolean;
	private var m_roundingIncrement:Number;
	private var m_roundingMode:NSNumberFormatterRoundingMode;
	private var m_minimum:Number;
	private var m_maximum:Number;
	private var m_minimumIntegerDigits:Number;
	private var m_minimumFractionDigits:Number;
	private var m_maximumIntegerDigits:Number;
	private var m_maximumFractionDigits:Number;
	private var m_numberStyle:NSNumberFormatterStyle;

	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSNumberFormatter</code> class.
	 */
	public function NSNumberFormatter() {
		m_multiplier = 1;
		
		m_paddingCharacter = " ";
		m_paddingPosition = NSNumberFormatterPadPosition.NSNumberFormatterPadAfterPrefix;
		m_currencySymbol = "$";
		m_internationalCurrencySymbol = "CAD";
		m_percentSymbol = "%";
		m_perMillSymbol = "/m";
		m_minusSign = "-";
		m_plusSign = "+";
		m_exponentSymbol = "^";
		m_zeroSymbol = "0";
		m_nilSymbol = "null";
		m_notANumberSymbol = "NaN";
		m_negativeInfinitySymbol = "-∞";
		m_positiveInfinitySymbol = "∞";
		m_positivePrefix = "";
		m_positiveSuffix = "";
		m_negativePrefix = "-";
		m_negativeSuffix = "";
		
		m_hasThousandsSeparators = false;
		m_thousandSeparator = "";
		m_decimalSeparator = ".";
		m_alwaysShowsDecimalSeparator = false;
		m_currencyDecimalSeparator = ".";
		m_usesGroupingSeparator = false;
		m_groupingSeparator = "";
		m_groupingSize = 3;
		m_secondaryGroupingSize = 3;
		m_currencyCode = "CAD";
		m_allowsFloats = true;
		m_roundingIncrement = 1;
		m_roundingMode = null;
		m_minimum = Number.MIN_VALUE;
		m_maximum = Number.MAX_VALUE;
		m_minimumIntegerDigits = null;
		m_minimumFractionDigits = null;
		m_maximumIntegerDigits = null;
		m_maximumFractionDigits = null;
		m_numberStyle = NSNumberFormatterStyle.NSNumberFormatterNoStyle;
	}

	//******************************************************
	//*            Setting and getting formats
	//******************************************************
	
	public function negativeFormat():String{
		return m_negativeFormat;
	}
	
	public function setNegativeFormat(value:String):Void {
		m_negativeFormat= value;
	}
	
	public function positiveFormat():String{
		return m_positiveFormat;
	}
	
	public function setPositiveFormat(value:String):Void {
		m_positiveFormat= value;
	}
	
	public function format():String {
		return m_positiveFormat + ";" + m_negativeFormat;
	}
	
	public function setFormat(value:String):Void {
		if (value.indexOf(";") == -1) {
			setPositiveFormat(value);
			setNegativeFormat("-" + value);
		} else {
			var parts:Array = value.split(";");
			if (parts.length == 2) {
				setPositiveFormat(parts[0]);
				setNegativeFormat(parts[1]);
			} else {
				setPositiveFormat(parts[0]);
				setZeroSymbol(parts[1]);
				setNegativeFormat(parts[2]);
			}
		}
	}
	
	public function formatWidth():Number{
		return m_formatWidth;
	}
	
	public function setFormatWidth(value:Number):Void {
		m_formatWidth= value;
	}
	
	public function multiplier():Number{
		return m_multiplier;
	}
	
	public function setMultiplier(value:Number):Void {
		m_multiplier= value;
	}
	
	//******************************************************
	//*            Setting and getting padding
	//******************************************************
	
	public function paddingCharacter():String{
		return m_paddingCharacter;
	}
	
	public function setPaddingCharacter(value:String):Void {
		m_paddingCharacter= value;
	}
	
	public function paddingPosition():NSNumberFormatterPadPosition {
		return m_paddingPosition;
	}
	
	public function setPaddingPosition(value:NSNumberFormatterPadPosition):Void {
		m_paddingPosition= value;
	}
	
	//******************************************************
	//*            Setting and getting symbols
	//******************************************************
	
	public function currencySymbol():String{
		return m_currencySymbol;
	}
	
	public function setCurrencySymbol(value:String):Void {
		m_currencySymbol= value;
	}
	
	public function internationalCurrencySymbol():String{
		return m_internationalCurrencySymbol;
	}
	
	public function setInternationalCurrencySymbol(value:String):Void {
		m_internationalCurrencySymbol= value;
	}
	
	public function percentSymbol():String{
		return m_percentSymbol;
	}
	
	public function setPercentSymbol(value:String):Void {
		m_percentSymbol= value;
	}
	
	public function perMillSymbol():String{
		return m_perMillSymbol;
	}
	
	public function setPerMillSymbol(value:String):Void {
		m_perMillSymbol= value;
	}
	
	public function minusSign():String{
		return m_minusSign;
	}
	
	public function setMinusSign(value:String):Void {
		m_minusSign= value;
	}
	
	public function plusSign():String{
		return m_plusSign;
	}
	
	public function setPlusSign(value:String):Void {
		m_plusSign= value;
	}
	
	public function exponentSymbol():String{
		return m_exponentSymbol;
	}
	
	public function setExponentSymbol(value:String):Void {
		m_exponentSymbol= value;
	}
	
	public function zeroSymbol():String{
		return m_zeroSymbol;
	}
	
	public function setZeroSymbol(value:String):Void {
		m_zeroSymbol= value;
	}
	
	public function nilSymbol():String{
		return m_nilSymbol;
	}
	
	public function setNilSymbol(value:String):Void {
		m_nilSymbol= value;
	}
	
	public function notANumberSymbol():String{
		return m_notANumberSymbol;
	}
	
	public function setNotANumberSymbol(value:String):Void {
		m_notANumberSymbol= value;
	}
	
	public function negativeInfinitySymbol():String{
		return m_negativeInfinitySymbol;
	}
	
	public function setNegativeInfinitySymbol(value:String):Void {
		m_negativeInfinitySymbol= value;
	}
	
	public function positiveInfinitySymbol():String{
		return m_positiveInfinitySymbol;
	}
	
	public function setPositiveInfinitySymbol(value:String):Void {
		m_positiveInfinitySymbol= value;
	}
	
	//******************************************************
	//*      Setting and getting prefixes and suffixes
	//******************************************************
	
	public function positivePrefix():String{
		return m_positivePrefix;
	}
	
	public function setPositivePrefix(value:String):Void {
		m_positivePrefix= value;
	}
	
	public function positiveSuffix():String{
		return m_positiveSuffix;
	}
	
	public function setPositiveSuffix(value:String):Void {
		m_positiveSuffix= value;
	}
	
	public function negativePrefix():String{
		return m_negativePrefix;
	}
	
	public function setNegativePrefix(value:String):Void {
		m_negativePrefix= value;
	}
	
	public function negativeSuffix():String{
		return m_negativeSuffix;
	}
	
	public function setNegativeSuffix(value:String):Void {
		m_negativeSuffix= value;
	}
	
	//******************************************************
	//*   Setting characteristics for displaying values
	//******************************************************
	
	public function textAttributesForNegativeValues():NSDictionary{
		return m_textAttributesForNegativeValues;
	}
	
	public function setTextAttributesForNegativeValues(value:NSDictionary):Void {
		m_textAttributesForNegativeValues= value;
	}
	
	public function textAttributesForPositiveValues():NSDictionary{
		return m_textAttributesForPositiveValues;
	}
	
	public function setTextAttributesForPositiveValues(value:NSDictionary):Void {
		m_textAttributesForPositiveValues= value;
	}
	
	public function attributedStringForZero():NSAttributedString{
		return m_attributedStringForZero;
	}
	
	public function setAttributedStringForZero(value:NSAttributedString):Void {
		m_attributedStringForZero= value;
	}
	
	public function textAttributesForZero():NSDictionary{
		return m_textAttributesForZero;
	}
	
	public function setTextAttributesForZero(value:NSDictionary):Void {
		m_textAttributesForZero= value;
	}
	
	public function attributedStringForNil():NSAttributedString{
		return m_attributedStringForNil;
	}
	
	public function setAttributedStringForNil(value:NSAttributedString):Void {
		m_attributedStringForNil= value;
	}
	
	public function textAttributesForNil():NSDictionary{
		return m_textAttributesForNil;
	}
	
	public function setTextAttributesForNil(value:NSDictionary):Void {
		m_textAttributesForNil= value;
	}
	
	public function attributedStringForNotANumber():NSAttributedString{
		return m_attributedStringForNotANumber;
	}
	
	public function setAttributedStringForNotANumber(value:NSAttributedString):Void {
		m_attributedStringForNotANumber= value;
	}
	
	public function textAttributesForNotANumber():NSDictionary{
		return m_textAttributesForNotANumber;
	}
	
	public function setTextAttributesForNotANumber(value:NSDictionary):Void {
		m_textAttributesForNotANumber= value;
	}
	
	public function textAttributesForPositiveInfinity():NSDictionary{
		return m_textAttributesForPositiveInfinity;
	}
	
	public function setTextAttributesForPositiveInfinity(value:NSDictionary):Void {
		m_textAttributesForPositiveInfinity= value;
	}
	
	public function textAttributesForNegativeInfinity():NSDictionary{
		return m_textAttributesForNegativeInfinity;
	}
	
	public function setTextAttributesForNegativeInfinity(value:NSDictionary):Void {
		m_textAttributesForNegativeInfinity= value;
	}
	
	//******************************************************
	//*  Setting and getting separators and grouping size
	//******************************************************
	
	public function hasThousandsSeparators():Boolean{
		return m_hasThousandsSeparators;
	}
	
	public function setHasThousandsSeparators(value:Boolean):Void {
		m_hasThousandsSeparators= value;
	}
	
	public function thousandSeparator():String{
		return m_thousandSeparator;
	}
	
	public function setThousandSeparator(value:String):Void {
		m_thousandSeparator= value;
	}
	
	public function decimalSeparator():String{
		return m_decimalSeparator;
	}
	
	public function setDecimalSeparator(value:String):Void {
		m_decimalSeparator= value;
	}
	
	public function alwaysShowsDecimalSeparator():Boolean{
		return m_alwaysShowsDecimalSeparator;
	}
	
	public function setAlwaysShowsDecimalSeparator(value:Boolean):Void {
		m_alwaysShowsDecimalSeparator= value;
	}
	
	public function currencyDecimalSeparator():String{
		return m_currencyDecimalSeparator;
	}
	
	public function setCurrencyDecimalSeparator(value:String):Void {
		m_currencyDecimalSeparator= value;
	}
	
	public function usesGroupingSeparator():Boolean{
		return m_usesGroupingSeparator;
	}
	
	public function setUsesGroupingSeparator(value:Boolean):Void {
		m_usesGroupingSeparator= value;
	}
	
	public function groupingSeparator():String{
		return m_groupingSeparator;
	}
	
	public function setGroupingSeparator(value:String):Void {
		m_groupingSeparator= value;
	}
	
	public function groupingSize():Number{
		return m_groupingSize;
	}
	
	public function setGroupingSize(value:Number):Void {
		m_groupingSize= value;
	}
	
	public function secondaryGroupingSize():Number{
		return m_secondaryGroupingSize;
	}
	
	public function setSecondaryGroupingSize(value:Number):Void {
		m_secondaryGroupingSize= value;
	}
	
	//******************************************************
	//*Enabling localization and setting locale information
	//******************************************************
	
	public function currencyCode():String{
		return m_currencyCode;
	}
	
	public function setCurrencyCode(value:String):Void {
		m_currencyCode= value;
	}
	
	//******************************************************
	//*         Setting and getting float behavior
	//******************************************************
	
	public function allowsFloats():Boolean{
		return m_allowsFloats;
	}
	
	public function setAllowsFloats(value:Boolean):Void {
		m_allowsFloats= value;
	}
	
	//******************************************************
	//*        Setting and getting rounding behavior
	//******************************************************
		
	public function roundingIncrement():Number{
		return m_roundingIncrement;
	}
	
	public function setRoundingIncrement(value:Number):Void {
		m_roundingIncrement= value;
	}
	
	public function roundingMode():NSNumberFormatterRoundingMode{
		return m_roundingMode;
	}
	
	public function setRoundingMode(value:NSNumberFormatterRoundingMode):Void {
		m_roundingMode= value;
	}
	
	//******************************************************
	//*         Setting and getting input attributes
	//******************************************************
	
	public function minimum():Number{
		return m_minimum;
	}
	
	public function setMinimum(value:Number):Void {
		m_minimum= value;
	}
	
	public function maximum():Number{
		return m_maximum;
	}
	
	public function setMaximum(value:Number):Void {
		m_maximum= value;
	}
	
	public function minimumIntegerDigits():Number{
		return m_minimumIntegerDigits;
	}
	
	public function setMinimumIntegerDigits(value:Number):Void {
		m_minimumIntegerDigits= value;
	}
	
	public function minimumFractionDigits():Number{
		return m_minimumFractionDigits;
	}
	
	public function setMinimumFractionDigits(value:Number):Void {
		m_minimumFractionDigits= value;
	}
	
	public function maximumIntegerDigits():Number{
		return m_maximumIntegerDigits;
	}
	
	public function setMaximumIntegerDigits(value:Number):Void {
		m_maximumIntegerDigits= value;
	}
	
	public function maximumFractionDigits():Number{
		return m_maximumFractionDigits;
	}
	
	public function setMaximumFractionDigits(value:Number):Void {
		m_maximumFractionDigits= value;
	}
	
	//******************************************************
	//* Setting and getting formatter behavior and style
	//******************************************************
	
	public function numberStyle():NSNumberFormatterStyle {
		return m_numberStyle;
	}
	
	public function setNumberStyle(value:NSNumberFormatterStyle):Void {
		m_numberStyle= value;
	}
	
	//******************************************************
	//*     Converting between numbers and strings
	//******************************************************
	
	/**
	 * <p>This method will return an object formatted as follows:<br/>
	 * <code>{success:Boolean, obj:Object, error:String}</code></p>
	 *
	 * <p>If the success property is <code>true</code>, the conversion succeeded
	 * and the <code>obj</code> property will contain the newly created object. 
	 * If the <code>success</code> property is <code>false</code>, the 
	 * conversion failed and the error property will contain a descriptive error
	 * message.</p>
	 *
	 * <p>The implementation of this method differs from Cocoa's as ActionScript
	 * does not have pointers. Ordinarily a boolean is returned indicating
	 * success and the obj and error arguments are pointers.</p>
	 */	 
	public function getObjectValueForString(string:String):ASFormatResult {
		var num:Number = parseFloat(string); // TODO make this better
		
		//
		// Format
		//
		num /= m_multiplier;
		
		return (new ASFormatResult()).initWithSuccessObjectError(
			true, NSNumber.numberWithDouble(num), "");
	}
	
	/**
	 * Returns an NSNumber object created by parsing a given string.
	 */
	public function numberFromString(string:String):NSNumber {
		return NSNumber(getObjectValueForString(string).objectValue());
	}
	
	/**
	 * Returns the NSNumber as a string.
	 */
	public function stringFromNumber(number:NSNumber):String {
		if (number == null) {
			return m_nilSymbol;
		}
		
		var num:Number = number.doubleValue();
		if (isNaN(num)) {
			return m_notANumberSymbol;
		}
		
		num *= m_multiplier;
				
		//TODO deal with rounding increment
		switch (m_roundingMode) {
			case NSNumberFormatterRoundingMode.NSNumberFormatterRoundCeiling:
			case NSNumberFormatterRoundingMode.NSNumberFormatterRoundUp:
				num = Math.ceil(num);
				break;
			
			case NSNumberFormatterRoundingMode.NSNumberFormatterRoundFloor:
			case NSNumberFormatterRoundingMode.NSNumberFormatterRoundDown:
				num = Math.floor(num);
				break;
			
			case NSNumberFormatterRoundingMode.NSNumberFormatterRoundHalfDown:
			case NSNumberFormatterRoundingMode.NSNumberFormatterRoundHalfEven:
			case NSNumberFormatterRoundingMode.NSNumberFormatterRoundHalfUp:
				num = Math.round(num);
				break;	
		}
		
		//! TODO fill this in
		
		return number.description();
	}
	
	/**
	 * Wraps around stringFromNumber().
	 */
	public function stringForObjectValue(value:Object):String {
		if (value == null) {
			return m_nilSymbol;
		}
		else if (ASUtils.isNumber(value)) {
			value = NSNumber.numberWithDouble(Number(value));
		}
		else if (!(value instanceof NSNumber)) {
			return null;
		} 
		
		return stringFromNumber(NSNumber(value));
	}
	
	
}
