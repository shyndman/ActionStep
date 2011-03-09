/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;

/**
 * @author Scott Hyndman
 */
class org.actionstep.rpc.ASFault extends NSObject {

	//******************************************************
	//*                 Member variables
	//******************************************************

	private var m_fault:Object;
	private var m_code:String;
	private var m_details:String;
	private var m_description:String;
	private var m_type:String;

	//******************************************************
	//*                   Construction
	//******************************************************

	/**
	 * Constructs a new instance of the <code>ASResponse</code> class.
	 */
	public function ASFault() {
	}

	/**
	 * Initializes the response with the contents of the server response.
	 */
	public function initWithContentsOfFault(fault:Object):ASFault {
		m_fault = fault;

		if (m_fault.details != null) { // Flash ORB
			m_details = m_fault.details;
			m_description = m_fault.description;
			if(m_fault.errorCode != null) {
				m_code = m_fault.errorCode;
				m_type = m_fault._className;
			} else {
				//!TODO additional data: line #, exception stack --> new php version?
				m_code = m_fault.code;
				m_type = m_fault.level;
			}
		} else { // Flash Remoting
			m_details = m_fault.detail;
			m_code = m_fault.faultcode;
			m_type = m_fault.type;
			m_description = m_fault.faultstring;
		}

		return this;
	}

	//******************************************************
	//*               Describing the object
	//******************************************************

	/**
	 * Returns a string representation of the ASResponse instance.
	 */
	public function description():String {
		return "ASFault(\n"+
		buildDescription(
		"code", code(),
		"description", faultDescription(),
		"details", details(),
		"type", type())
		+ ")";
	}

	//******************************************************
	//*           Getting details about the fault
	//******************************************************

	/**
	 * Returns the code of the fault.
	 */
	public function code():String {
		return m_code;
	}

	/**
	 * Returns the details of the fault.
	 */
	public function details():String {
		return m_details;
	}

	/**
	 * Returns the description of the fault.
	 */
	public function faultDescription():String {
		return m_description;
	}

	/**
	 * Returns the type of fault.
	 */
	public function type():String {
		return m_type;
	}

	//******************************************************
	//*                  Internal fault
	//******************************************************

	/**
	 * Returns internal fault object as returned by the server.
	 */
	public function internalFault():Object {
		return m_fault;
	}
}