/* See LICENSE for copyright and terms of use */

import org.actionstep.NSImage;
import org.actionstep.NSView;
import org.aib.PaletteController;

/**
 * Defines methods that must be implemented by all palettes that are displayed
 * in the <code>org.aib.PaletteController</code> class.
 * 
 * @author Scott Hyndman
 */
interface org.aib.palette.PaletteProtocol {

	/**
	 * Initializes the palette with the palette controller <code>window</code>.
	 */	
	function initWithPaletteController(controller:PaletteController):PaletteProtocol;
	
	/**
	 * Returns the name of this palette. This value is used in the palette 
	 * window's title when this palette is selected, and in a few other 
	 * situations.
	 * 
	 * The return value should typically be fetched from the Application string
	 * table, that can be accessed using 
	 * <code>AIBApplication#stringForKeyPath</code>.
	 * 
	 * As an example, the controls palette 
	 * <code>org.aib.palette.AIBControlPalette</code> returns the value 
	 * returned from 
	 * <code>org.aib.AIBApplication.stringWithName("Palettes.Controls.Name")</code>.
	 */
	function paletteName():String;
	
	/**
	 * Returns the tip text for this palette's button. Typically this will 
	 * return the name of the palette.
	 * 
	 * The return value should typically be fetched from the Application string
	 * table, that can be accessed using 
	 * <code>AIBApplication#stringForKeyPath</code>.
	 */
	function buttonTipText():String;
	
	/**
	 * Returns the image that will be placed on this palette's button. This 
	 * image should be representative of the palette's contents.
	 */
	function buttonImage():NSImage;
	
	/**
	 * Returns the contents of this palette that will be displayed when the
	 * palette is selected.
	 */
	function paletteContents():NSView;
}