/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;

/**
 * @author Scott Hyndman
 */
class org.actionstep.rpc.ASResponse extends NSObject {

	//******************************************************
	//*                 Member variables
	//******************************************************

	private var m_response:Object;

	//******************************************************
	//*                   Construction
	//******************************************************

	/**
	 * Constructs a new instance of the <code>ASResponse</code> class.
	 */
	public function ASResponse() {
	}

	/**
	 * Initializes the response with the contents of the server response.
	 */
	public function initWithContentsOfResponse(response:Object):ASResponse {
		m_response = response;
		return this;
	}

	//******************************************************
	//*               Describing the object
	//******************************************************

	/**
	 * Returns a string representation of the ASResponse instance.
	 */
	public function description():String {
		return "ASResponse(response=" + response() + ")";
	}

	//******************************************************
	//*               Getting the response
	//******************************************************

	/**
	 * Returns the server response.
	 */
	public function response():Object {
		return m_response;
	}
}