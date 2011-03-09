/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImage;
import org.actionstep.NSView;
import org.aib.AIBApplication;
import org.aib.palette.PaletteBase;

/**
 * @author Scott Hyndman
 */
class org.aib.palette.ControllersPalette extends PaletteBase {
	
	//******************************************************															 
	//*                 Member variables
	//******************************************************
	
	private var m_contentsView:NSView;
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	public function ControllersPalette() {

	}
	
	//******************************************************															 
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the <code>ControllersPalette</code> 
	 * instance.
	 */
	public function description():String {
		return "ControllersPalette()";
	}
	
	//******************************************************															 
	//*         Implementation of PaletteProtocol
	//******************************************************
	
	/**
	 * Returns
	 * <code>AIBApplication#stringForKeyPath("Palettes.Controllers.Name")</code>.
	 */
	public function paletteName():String {
		return AIBApplication.stringForKeyPath("Palettes.Controllers.Name");
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
		return NSImage.imageNamed("Controllers");
	}

	/**
	 * Returns a view containing the contents of the controls palette.
	 */
	public function paletteContents():NSView {
		return m_contentsView;
	}
}