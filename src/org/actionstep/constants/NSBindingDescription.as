/* See LICENSE for copyright and terms of use */

import org.actionstep.constants.NSTextAlignment;
import org.actionstep.NSArray;
import org.actionstep.NSAttributedString;
import org.actionstep.NSColor;
import org.actionstep.NSDictionary;
import org.actionstep.NSFont;
import org.actionstep.NSImage;
import org.actionstep.NSObject;

/**
 * @author Scott Hyndman
 */
class org.actionstep.constants.NSBindingDescription extends NSObject {
	
	public static var NSAlignmentBinding:NSBindingDescription 
		= new NSBindingDescription("alignment", NSTextAlignment);
		
	public static var NSAlternateImageBinding:NSBindingDescription 
		= new NSBindingDescription("alternateImage", NSImage);
		
	public static var NSAlternateTitleBinding:NSBindingDescription 
		= new NSBindingDescription("alternateTitle", String);
		
	//! TODO NSAnimateBinding
	//! TODO NSAnimationDelayBinding
	//! TODO NSArgumentBinding
	
	public static var NSAttributedStringBinding:NSBindingDescription 
		= new NSBindingDescription("attributedStringValue", NSAttributedString);
		
	//! TODO NSContentArrayBinding
	//! TODO NSContentArrayForMultipleSelectionBinding
	//! TODO NSContentBinding

	public static var NSContentHeightBinding:NSBindingDescription 
		= new NSBindingDescription("contentHeight", Number);
		
	public static var NSContentObjectBinding:NSBindingDescription
		= new NSBindingDescription("contentObject", Object);
		
	public static var NSContentObjectsBinding:NSBindingDescription 
		= new NSBindingDescription("contentObjects", NSArray);

	//! TODO NSContentSetBinding
	//! TODO NSContentValuesBinding
	//! TODO NSContentValuesBinding
	
	public static var NSContentWidthBinding:NSBindingDescription 
		= new NSBindingDescription("contentWidth", Number);
		
	//! TODO NSCriticalValueBinding
	//! TODO NSDataBinding
	//! TODO NSObservedObjectKey
	//! TODO NSDisplayPatternTitleBinding
	//! TODO NSDisplayPatternValueBinding
	//! TODO NSDocumentEditedBinding
	
	public static var NSEditableBinding:NSBindingDescription 
		= new NSBindingDescription("editable", Boolean);
		
	public static var NSEnabledBinding:NSBindingDescription 
		= new NSBindingDescription("enabled", Boolean);
		
	public static var NSFontBinding:NSBindingDescription 
		= new NSBindingDescription("font", NSFont);
		
	//! TODO Figure out what these font things bind to
	public static var NSFontBoldBinding:NSBindingDescription 
		= new NSBindingDescription("fontBold", Boolean);
		
	public static var NSFontFamilyNameBinding:NSBindingDescription 
		= new NSBindingDescription("fontFamilyName", String);
		
	public static var NSFontItalicBinding:NSBindingDescription 
		= new NSBindingDescription("fontItalic", Boolean);
		
	public static var NSFontNameBinding:NSBindingDescription 
		= new NSBindingDescription("fontName", String);
	
	public static var NSFontSizeBinding:NSBindingDescription 
		= new NSBindingDescription("fontSize", Number);
	
	public static var NSHeaderTitleBinding:NSBindingDescription 
		= new NSBindingDescription("headerTitle", String);
		
	public static var NSHiddenBinding:NSBindingDescription 
		= new NSBindingDescription("hidden", Boolean);
		
	public static var NSImageBinding:NSBindingDescription 
		= new NSBindingDescription("image", NSImage);
		
	public static var NSIsIndeterminateBinding:NSBindingDescription 
		= new NSBindingDescription("isIndeterminate", Boolean);
		
	public static var NSLabelBinding:NSBindingDescription 
		= new NSBindingDescription("label", String);
		
	//! TODO NSManagedObjectContextBinding
	
	public static var NSMaxValueBinding:NSBindingDescription 
		= new NSBindingDescription("maxValue", Number);
		
	public static var NSMaxWidthBinding:NSBindingDescription 
		= new NSBindingDescription("maxWidth", Number);
		
	public static var NSMinValueBinding:NSBindingDescription 
		= new NSBindingDescription("minValue", Number);
		
	public static var NSMinWidthBinding:NSBindingDescription 
		= new NSBindingDescription("minWidth", Number);
		
	public static var NSMixedStateImageBinding:NSBindingDescription 
		= new NSBindingDescription("mixedStateImage", NSImage);
		
	public static var NSOffStateImageBinding:NSBindingDescription 
		= new NSBindingDescription("offStateImage", NSImage);
		
	public static var NSOnStateImageBinding:NSBindingDescription 
		= new NSBindingDescription("onStateImage", NSImage);
		
	//! TODO NSPredicateBinding
	//! TODO NSRecentSearchesBinding
	//! TODO NSRepresentedFilenameBinding
	
	public static var NSRowHeightBinding:NSBindingDescription 
		= new NSBindingDescription("rowHeight", Number);
		
	//! TODO NSSelectedIdentifierBinding
	
	public static var NSSelectedIndexBinding:NSBindingDescription 
		= new NSBindingDescription("selectedIndex", Number);
		
	public static var NSSelectedLabelBinding:NSBindingDescription 
		= new NSBindingDescription("selectedLabel", String);
		
	public static var NSSelectedObjectBinding:NSBindingDescription 
		= new NSBindingDescription("selectedObject", Object);
		
	public static var NSSelectedObjectsBinding:NSBindingDescription 
		= new NSBindingDescription("selectedObjects", NSArray);
		
	public static var NSSelectedTagBinding:NSBindingDescription 
		= new NSBindingDescription("selectedTag", Number);
		
	public static var NSSelectedValueBinding:NSBindingDescription 
		= new NSBindingDescription("selectedValue", Object);
	
	public static var NSSelectedValuesBinding:NSBindingDescription 
		= new NSBindingDescription("selectedValues", NSArray);
		
	public static var NSSelectionIndexesBinding:NSBindingDescription 
		= new NSBindingDescription("selectionIndexes", NSArray);
		
	//! TODO NSSelectionIndexPathsBinding
	
	public static var NSSortDescriptorsBinding:NSBindingDescription 
		= new NSBindingDescription("sortDescriptors", NSArray);
		
	public static var NSTargetBinding:NSBindingDescription 
		= new NSBindingDescription("target", Object);
		
	public static var NSTextColorBinding:NSBindingDescription 
		= new NSBindingDescription("textColor", NSColor);
		
	public static var NSTitleBinding:NSBindingDescription 
		= new NSBindingDescription("title", String);
		
	public static var NSToolTipBinding:NSBindingDescription 
		= new NSBindingDescription("toolTip", String);
		
	public static var NSValueBinding:NSBindingDescription 
		= new NSBindingDescription("value", Object);
		
	public static var NSValuePathBinding:NSBindingDescription 
		= new NSBindingDescription("valuePath", String);
		
	public static var NSValueURLBinding:NSBindingDescription 
		= new NSBindingDescription("valueURL", String);
		
	public static var NSVisibleBinding:NSBindingDescription 
		= new NSBindingDescription("visible", Boolean);
		
	//! TODO NSWarningValueBinding
	
	public static var NSWidthBinding:NSBindingDescription 
		= new NSBindingDescription("width", Number);
	
	
	//******************************************************															 
	//*                   Class members
	//******************************************************
	
	private static var g_bindingDescriptions:NSDictionary;
	
	//******************************************************															 
	//*                      Instance
	//******************************************************
	
	public var name:String;
	public var type:Function;
	
	/**
	 * Constructs a new instance of the <code>NSBindingDescription</code>
	 * class.
	 */
	public function NSBindingDescription(name:String, type:Function) {
		if (g_bindingDescriptions == null) {
			g_bindingDescriptions = NSDictionary.dictionary();
		}
		
		name = name;
		type = type;
		
		g_bindingDescriptions.setObjectForKey(type, name);
	}
	
	//******************************************************															 
	//*              Getting databinding types
	//******************************************************
	
	public static function typeForBinding(binding:String):Function {
		return Function(g_bindingDescriptions.objectForKey(binding));
	}
}