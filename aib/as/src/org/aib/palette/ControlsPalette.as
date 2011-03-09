/* See LICENSE for copyright and terms of use */

import org.actionstep.ASCellImageRep;
import org.actionstep.NSButtonCell;
import org.actionstep.NSDictionary;
import org.actionstep.NSImage;
import org.actionstep.NSRect;
import org.actionstep.NSSize;
import org.actionstep.NSView;
import org.aib.AIBApplication;
import org.aib.constants.SourceObjectType;
import org.aib.controls.EditableButton;
import org.aib.palette.PaletteBase;
import org.aib.palette.PaletteObjectSource;

/**
 * @author Scott Hyndman
 */
class org.aib.palette.ControlsPalette extends PaletteBase {
	
	//******************************************************															 
	//*                 Member variables
	//******************************************************
	
	private var m_contentsView:NSView;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	public function ControlsPalette() {
		m_contentsView = new NSView();
		m_contentsView.initWithFrame(new NSRect(0, 0, 400, 300));
		
		m_contentsView.addSubview(createButtonSource());
	}
	
	private function createButtonSource():PaletteObjectSource {
		//
		// Create image
		//
		var img:NSImage = (new NSImage()).initWithSize(new NSSize(70, 25));
		var btnCell:NSButtonCell = (new NSButtonCell()).initTextCell("Button");
		var rep:ASCellImageRep = new ASCellImageRep(btnCell, new NSSize(70, 25));
		img.addRepresentation(rep);
		
		//
		// Create object source
		//
		var src:PaletteObjectSource = new PaletteObjectSource();
		src.initWithFrame(new NSRect(0, 0, 70, 25));
		src.setToolTip("NSButton");
		src.setImage(img);
		src.setSourceObjectClass(EditableButton);
		src.setSourceObjectType(SourceObjectType.AIBView);
		src.setSourceObjectProperties(NSDictionary.dictionaryWithObjectsAndKeys(
			"Button", "stringValue",
			new NSSize(70, 25), "frameSize"
			));
		
		return src;
	}
	
	//******************************************************															 
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the <code>ControlsPalette</code> 
	 * instance.
	 */
	public function description():String {
		return "ControlsPalette()";
	}
	
	//******************************************************															 
	//*         Implementation of PaletteProtocol
	//******************************************************
	
	/**
	 * Returns
	 * <code>AIBApplication#stringForKeyPath("Palettes.Controls.Name")</code>.
	 */
	public function paletteName():String {
		return AIBApplication.stringForKeyPath("Palettes.Controls.Name");
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
		return NSImage.imageNamed("Controls");
	}

	/**
	 * Returns a view containing the contents of the controls palette.
	 */
	public function paletteContents():NSView {
		return m_contentsView;
	}
}