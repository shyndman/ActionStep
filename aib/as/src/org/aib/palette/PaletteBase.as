/* See LICENSE for copyright and terms of use */

import org.actionstep.NSException;
import org.actionstep.NSImage;
import org.actionstep.NSView;
import org.aib.AIBObject;
import org.aib.palette.PaletteProtocol;
import org.aib.PaletteController;

/**
 * Base class for all AIB palettes. 
 * 
 * @author Scott Hyndman
 */
class org.aib.palette.PaletteBase extends AIBObject 
		implements PaletteProtocol {
		
	//******************************************************															 
	//*                  Member variables
	//******************************************************
	
	private var m_window:PaletteController; 
	
	//******************************************************															 
	//*                   Construction
	//******************************************************
	
	/**
	 * Constructs a new instance of <code>PaletteBase</code>.
	 */
	public function PaletteBase() {
	}
	
	/**
	 * Initializes the palette with the palette window <code>window</code>.
	 */
	public function initWithPaletteController(window:PaletteController)
			:PaletteProtocol {
		m_window = window;
		return this;
	}

	//******************************************************															 
	//*         Implementation of PaletteProtocol
	//******************************************************
	
	public function paletteName():String {
		throwAbstractMethodException("paletteName");
		return null;
	}

	public function buttonTipText():String {
		return paletteName();
	}

	public function buttonImage():NSImage {
		throwAbstractMethodException("buttonImage");
		return null;
	}

	public function paletteContents():NSView {
		throwAbstractMethodException("paletteContents");
		return null;
	}

	/**
	 * Throws an NSException.
	 * 
	 * Should be called by abstract methods. <code>methodName</code> is the
	 * name of the abstract method.
	 */
	private function throwAbstractMethodException(methodName:String):Void {
		var e:NSException = NSException.exceptionWithNameReasonUserInfo(
			NSException.ASAbstractMethod,
			methodName + "() is an abstract method.",
			null);
		trace(e);
		throw e;	
	}
}