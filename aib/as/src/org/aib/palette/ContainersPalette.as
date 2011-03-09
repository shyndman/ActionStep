/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImage;
import org.actionstep.NSView;
import org.aib.AIBApplication;
import org.aib.palette.PaletteBase;

/**
 * @author Scott Hyndman
 */
class org.aib.palette.ContainersPalette extends PaletteBase {
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	public function ContainersPalette() {
		
	}
	
	//******************************************************															 
	//*               Describing the object
	//******************************************************
	
	/**
	 * Returns a string representation of the <code>ContainersPalette</code> 
	 * instance.
	 */
	public function description():String {
		return "ContainersPalette()";
	}
	
	//******************************************************															 
	//*         Implementation of PaletteProtocol
	//******************************************************
	
	/**
	 * Returns
	 * <code>AIBApplication#stringForKeyPath("Palettes.Containers.Name")</code>.
	 */
	public function paletteName():String {
		return AIBApplication.stringForKeyPath("Palettes.Containers.Name");
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
		return NSImage.imageNamed("Containers");
	}

	/**
	 * Returns a view containing the contents of the controls palette.
	 */
	public function paletteContents():NSView {
		return null;
	}
}