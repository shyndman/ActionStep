/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;

/**
 * Wraps around a bindable object and provides full KVC-compatability.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.controllers.ASObjectProxy extends NSObject {
	
	private var m_content:Object;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASObjectProxy</code> class.
	 */
	public function ASObjectProxy() {
	}
	
	/**
	 * Initializes and returns the <code>ASObjectProxy</code> instance.
	 */
	public function init():ASObjectProxy {
		super.init();
		return this;
	}
	
	/**
	 * Initializes the proxy object with the content object to wrap around.
	 */
	public function initWithContent(content:Object):ASObjectProxy {
		super.init();
		setContent(content);	
		return this;
	}
	
	//******************************************************
	//*               Setting the content
	//******************************************************
	
	/**
	 * Sets the content of the proxy to <code>content</code>.
	 */
	public function setContent(content:Object):Void {
		m_content = content;
	}
}