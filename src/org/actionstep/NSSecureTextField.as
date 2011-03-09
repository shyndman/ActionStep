/* See LICENSE for copyright and terms of use */

import org.actionstep.NSTextField;

/**
 * <p>A textfield that displays "bullet" characters instead of text, to hide the
 * contents from those within view of the screen.</p>
 *
 * <p>For an example of this class' usage, please see
 * {@link org.actionstep.test.ASTestSecureTextField}.</p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.NSSecureTextField extends NSTextField {
	
	//******************************************************
	//*                  Class members
	//******************************************************
		
	private static var g_cellClass:Function = org.actionstep.NSSecureTextFieldCell;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSSecureTextField</code> class.
	 */
	public function NSSecureTextField() {
	}
	
	//******************************************************															 
	//*                 Public Methods
	//******************************************************
	
	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String {
		return "NSSecureTextField()";
	}

	//******************************************************															 
	//*             Public Static Properties
	//******************************************************
			
	/**
	 * @see org.actionstep.NSControl#cellClass()
	 */
	public static function cellClass():Function {
		return g_cellClass;
	}


	/**
	 * @see org.actionstep.NSControl#setCellClass()
	 */	
	public static function setCellClass(cellClass:Function):Void {
		if (cellClass == null) {
			g_cellClass = org.actionstep.NSSecureTextFieldCell;
		} else {
			g_cellClass = cellClass;
		}
	}
}
