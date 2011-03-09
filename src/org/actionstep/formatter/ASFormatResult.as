/* See LICENSE for copyright and terms of use */

import org.actionstep.NSObject;
import org.actionstep.NSRange;

/**
 * Returned from certain {@link org.actionstep.NSFormatter} methods because
 * of ActionStep's lack of pointers.
 * 
 * @author Scott Hyndman
 */
class org.actionstep.formatter.ASFormatResult extends NSObject {
	
	private var m_success:Boolean;
	private var m_newString:String;
	private var m_obj:Object;
	private var m_errorDescription:String;
	private var m_proposedSelRange:NSRange;
	
	//******************************************************
	//*                  Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASFormatResult</code> class.
	 */
	public function ASFormatResult() {
	}
	
	public function initWithSuccessObjectError(success:Boolean, obj:Object,
			error:String):ASFormatResult {
		m_success = success;
		m_obj = obj;
		m_errorDescription = error;		
		return this;		
	}
	
	public function initWithSuccessNewStringError(success:Boolean, 
			newString:String, error:String):ASFormatResult {
		m_success = success;
		m_newString = newString;
		m_errorDescription = error;	
		return this;		
	}
	
	public function initWithSuccessNewStringProposedSelRangeError(
			success:Boolean, newString:String, error:String,
			aRange:NSRange):ASFormatResult {
		m_success = success;
		m_newString = newString;
		m_proposedSelRange = (aRange == null) ? null : aRange.clone();
		m_errorDescription = error;	
		return this;		
	}
	
	//******************************************************
	//*       Getting the result of a format call
	//******************************************************
	
	public function success():Boolean {
		return m_success;
	}
	
	public function newString():String {
		return m_newString;
	}
	
	public function objectValue():Object {
		return m_obj;
	}
	
	public function proposedSelectionRange():NSRange {
		return m_proposedSelRange.clone();
	}
	
	public function errorDescription():String {
		return m_errorDescription;
	}
}