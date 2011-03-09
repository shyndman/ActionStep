/* See LICENSE for copyright and terms of use */

import org.actionstep.NSDictionary;

/**
 * <p>NSException is used for exception handling and contains information about
 * the exception.</p>
 *
 * <p>An exception is a special condition raised to interupt the normal flow of a
 * program.</p>
 *
 * @author Scott Hyndman
 */
class org.actionstep.NSException extends Error //! can't extend NSObject
{
	//******************************************************
	//*                  Exception names
	//******************************************************

	/**
	 * The name of an exception thrown when an abstract method is called.
	 */
	public static var ASAbstractMethod:String = "NSAbstractMethodException";

	/**
	 * The name of the exception thrown when an unsupported method is called.
	 */
	public static var ASNotSupported:String = "ASNotSupportedException";
	
	/**
	 * A generic name for an exception. You should typically use a more specific
	 * exception name.
	 */
	public static var NSGeneric:String = "NSGenericException";

	/**
	 * Name of the exception that occurs when a bad comparison is attempted.
	 */
	public static var NSBadComparisonException:String = "NSBadComparisonException";
	
	/**
	 * Name of an exception that occurs when attempting to access outside the
	 * bounds of some data, such as beyond the end of a string.
	 */
	public static var NSRange:String = "NSRangeException";

	/**
	 * Name of the exception raised when an NSBrowser receives and illegal
	 * delegate.
	 */
	public static var NSBrowserIllegalDelegate:String = "NSBrowserIllegalDelegateException";
	
	/**
	 * Name of an exception that occurs when you pass an invalid argument to a
	 * method, such as a nil pointer where a non-nil object is required.
	 */
	public static var NSInvalidArgument:String = "NSInvalidArgumentException";

	/**
	 * Name of an exception that occurs when an internal assertion fails and
	 * implies an unexpected condition within the called code.
	 */
	public static var NSInternalInconsistency:String = "NSInternalInconsistencyException";

	/**
	 * No longer used.
	 */
	public static var NSOldStyle:String = "NSOldStyleException";

	//******************************************************
	//*                  Member variables
	//******************************************************

	private var m_name:String;
	private var m_reason:String;
	private var m_userinfo:NSDictionary;
	private var m_format:String;
	private var m_arguments:Array;
	private var m_innerException:NSException;
	
	// Reference
	private var m_refs:Array;

	//******************************************************
	//*                    Construction
	//******************************************************

	/**
	 * Creates a new instance of NSException.
	 */
	public function NSException()
	{
		m_refs = [];
	}

	/**
	 * Initializes the exception with the name name, a human-readable reason
	 * and additional information defined in userInfo.
	 */
	public function initWithNameReasonUserInfo(name:String, reason:String,
		userInfo:NSDictionary):NSException
	{
		return initWithNameReasonInnerExceptionUserInfo(name, reason, null, 
			userInfo);
	}
	
	/**
	 * <p>Initializes the exception with the name name, a human-readable reason
	 * and additional information defined in userInfo.</p>
	 * 
	 * <p><code>exception</code> is the exception that resulted in this one being
	 * thrown.</p>
	 * 
	 * <p>This method is ActionStep-specific.</p>
	 */
	public function initWithNameReasonInnerExceptionUserInfo(name:String, 
		reason:String, exception:NSException, userInfo:NSDictionary):NSException
	{
		m_name = name;
		m_reason = reason;
		m_innerException = exception;
		m_userinfo = userInfo;
		
		return this;
	}

	//******************************************************
	//*					  Properties					   *
	//******************************************************

	/**
	 * Returns the name of this exception.
	 */
	public function name():String
	{
		return m_name;
	}


	/**
	 * Returns the reason this exception occured.
	 */
	public function reason():String
	{
		return m_reason;
	}


	/**
	 * Returns the user-defined information describing this exception.
	 */
	public function userInfo():Object
	{
		return m_userinfo;
	}

	/**
	 * Returns the inner exception contained within this exception, or
	 * <code>null</code> if none exists.
	 */
	public function innerException():NSException 
	{
		return m_innerException;
	}
	 
	/**
	 * Returns the description() of the exception.
	 */
	public function get message():String 
	{
	  return description();
	}

	
	/**
	 * Adds the reference location for the exception to a list, which will be
	 * traced, first-in-first-out.
	 */
	public function addReference(className:String, file:String, line:Number):Void {
		var arr:Array;
		arr = file.split("/");
		file = arr[arr.length-1];
		arr = file.split("\\");
		file = arr[arr.length-1];

		arr = className.split("::");
		className = arr[0]+"."+arr[1];
		m_refs.push({className:className, file:file, line:line});
	}

	//******************************************************
	//*					 Public Methods					   *
	//******************************************************

	/**
	 * @see org.actionstep.NSObject#description
	 */
	public function description():String
	{
		var desc:String = "NSException(\n\t"+m_name + ":\n\t" + m_reason +
			",\n\t" + m_userinfo;
			
		if (m_arguments != undefined) {
			desc += ",\n\t" + m_arguments.toString();
		}
		
		if (m_innerException != undefined) {
			desc += ",\n\t" + m_innerException.toString();
		}
		
		desc += "\n\t)";

		if (m_refs.length > 0) {
			desc+= "\n";
			for (var i : Number = 0; i < m_refs.length; i++) {
				desc += "\tat " + m_refs[i].className+"("+m_refs[i].file+":"+m_refs[i].line+")\n";
			}
		}

		return desc;
	}


	/**
	 * Raises this exception.
	 */
	public function raise():Void
	{
		throw this;
	}


	/**
	 * @see org.actionstep.NSObject#toString
	 */
	public function toString():String
	{
		return description();
	}

	//******************************************************
	//*				 Public Static Methods				   *
	//******************************************************

	/**
	 * Returns an exception named name, with the reason reason, and
	 * additional information userInfo.
	 */
	public static function exceptionWithNameReasonUserInfo(name:String,
		reason:String, userInfo:NSDictionary):NSException
	{
		return (new NSException()).initWithNameReasonInnerExceptionUserInfo(
			name, reason, null, userInfo);
	}
	
	/**
	 * <p>Returns an exception named name, with the reason reason, and
	 * additional information userInfo.</p>
	 * 
	 * <p><code>exception</code> is the exception that resulted in this exception
	 * being raised.</p>
	 * 
	 * <p>This method is ActionStep-specific.</p>
	 */
	public static function exceptionWithNameReasonInnerExceptionUserInfo(
		name:String, reason:String, exception:NSException, 
		userInfo:NSDictionary):NSException
	{
		return (new NSException()).initWithNameReasonInnerExceptionUserInfo(
			name, reason, exception, userInfo);
	}	

	/**
	 * <p>Raises an exception named name, using the format format.</p>
	 *
	 * <p>Please note this name has been changed from raise(), but ActionScript
	 * does not support instance methods sharing the same name as static methods,
	 * so the change was necessary.</p>
	 */
	public static function raiseMessage(name:String, format:String):Void
	{
		var e:NSException = new NSException();
		e.m_name = name;
		e.m_format = format;
		e.raise();
	}


	/**
	 * Raises an exception named name, with the format format and the
	 * arguments arguments. The arguments should be the arguments
	 * of the method that threw this exception.
	 */
	public static function raiseFormatArguments(name:String, format:String,
		arguments:Array):Void
	{
		var e:NSException = new NSException();
		e.m_name = name;
		e.m_format = format;
		e.m_arguments = arguments;
		e.raise();
	}
}
