/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImage;
import org.actionstep.NSView;
import org.aib.AIBApplication;
import org.aib.palette.PaletteBase;
import org.actionstep.NSRect;
import org.aib.controls.EditableTextField;
import org.aib.controls.EditableSecureTextField;

/**
 * @author Scott Hyndman
 */
class org.aib.palette.TextPalette extends PaletteBase {
	
	//******************************************************															 
	//*                  Member variables
	//******************************************************
	
	private var m_contentsView:NSView; 
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	public function TextPalette() {
		m_contentsView = new NSView();
		m_contentsView.initWithFrame(new NSRect(0, 0, 400, 300));
		
		var textField:EditableTextField = new EditableTextField();
		textField.initWithFrame(new NSRect(10, 10, 90, 22));
		textField.setInPlaceEditingEnabled(false);
		textField.setStringValue("TextField");
		textField.setToolTip("NSTextField");
		m_contentsView.addSubview(textField);

		var secure:EditableSecureTextField = new EditableSecureTextField();
		secure.initWithFrame(new NSRect(10, 40, 90, 22));
		secure.setInPlaceEditingEnabled(false);
		secure.setStringValue("avae");
		secure.setToolTip("NSSecureTextField");
		m_contentsView.addSubview(secure);
	}
	
	//******************************************************															 
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the <code>TextPalette</code> 
	 * instance.
	 */
	public function description():String {
		return "TextPalette()";
	}
	
	//******************************************************															 
	//*         Implementation of PaletteProtocol
	//******************************************************
	
	/**
	 * Returns
	 * <code>AIBApplication#stringForKeyPath("Palettes.Text.Name")</code>.
	 */
	public function paletteName():String {
		return AIBApplication.stringForKeyPath("Palettes.Text.Name");
	}

	/**
	 * Returns the same value as <code>#paletteName</code>.
	 */
	public function buttonTipText():String {
		return paletteName();
	}

	/**
	 * Returns an image representing the controls palette.
	 */
	public function buttonImage():NSImage {
		return NSImage.imageNamed("Text");
	}

	/**
	 * Returns a view containing the contents of the controls palette.
	 */
	public function paletteContents():NSView {
		return m_contentsView;
	}
}