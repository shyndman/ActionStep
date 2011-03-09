/* See LICENSE for copyright and terms of use */

import org.actionstep.NSTextFieldCell;

/**
 * Draws the cell for an {@link org.actionstep.NSSecureTextField}.
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSSecureTextFieldCell extends NSTextFieldCell
{	
	private var m_echosbullets:Boolean;
	
	//******************************************************															 
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>NSSecureTextFieldCell</code> class.
	 */
	public function NSSecureTextFieldCell()
	{
		m_echosbullets = true;
	}
	
	/**
	 * Default initializer.
	 */
	public function init():Void
	{
		super.init();
	}
	
	//******************************************************															 
	//*                   Properties
	//******************************************************
	
	/**
	 * Returns whether the cell outputs bullets instead of each character
	 * typed. Default is <code>true</code>.
	 */
	public function echosBullets():Boolean
	{
		return m_echosbullets;
	}
	
	
	/**
	 * <p>Sets whether the cell outputs bullets instead of each character 
	 * typed.</p>
	 * 
	 * <p>When <code>flag</code> is <code>true</code>, bullets will be outputted
	 * instead of characters.</p>
	 */
	public function setEchosBullets(flag:Boolean):Void
	{
		//
		// Check for same value
		//
		if (m_echosbullets == flag)
			return;
			
		m_echosbullets = flag;
		
		//
		// Change the textfield property if appropriate
		//
		if (m_textField == null || m_textField._parent == undefined) 
			m_textField.password = flag;
	}
	
	/**
	* Returns the cell's textfield. Will build if necessary.
	*/
	private function textField():TextField 
	{
		if (m_textField == null || m_textField._parent == undefined) 
		{
			m_textField = super.textField();
			
			if (m_echosbullets)
				m_textField.password = true;
		}
	
		return m_textField;
	}
	
	//******************************************************														 
	//*              Describing the object
	//******************************************************
	
	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String 
	{
		return "NSSecureTextFieldCell";
	}
}
