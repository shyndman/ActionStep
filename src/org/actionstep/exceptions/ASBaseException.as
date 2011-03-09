/* See LICENSE for copyright and terms of use */

import org.actionstep.NSException;
import org.actionstep.NSDictionary;

/**
 * Classes that wish to implement their own exceptions should subclass this class instead of
 * NSException directly.
 *
 * @author Tay Ray Chuan
 */

class org.actionstep.exceptions.ASBaseException extends NSException {

	/** Override this method to specify your exception name. */
	private function exceptionName():String {
		return "ExceptionName";
	}

	public static function exceptionWithReasonUserInfo(
		reason:String, userInfo:NSDictionary):ASBaseException {
		return (new ASBaseException()).initWithReasonInnerExceptionUserInfo(
			reason, null, userInfo);
	}

	public static function exceptionWithReasonInnerExceptionUserInfo(
		reason:String, exception:NSException,
		userInfo:NSDictionary):ASBaseException {
		return (new ASBaseException()).initWithReasonInnerExceptionUserInfo(
			reason, exception, userInfo);
	}

	public function initWithReasonInnerExceptionUserInfo(reason:String,
		exception:NSException, userInfo:NSDictionary):ASBaseException {
		return initWithNameReasonInnerExceptionUserInfo(null, reason, null,
			userInfo);
	}

	public function initWithReasonUserInfo(reason:String,
		userInfo:NSDictionary):ASBaseException {
		return initWithNameReasonInnerExceptionUserInfo(null, reason, null,
			userInfo);
	}

	/**
	 * Don't allow access to the following functions.
	 */

	private function initWithNameReasonInnerExceptionUserInfo(name:String,
		reason:String, exception:NSException,
		userInfo:NSDictionary):ASBaseException {
		super.initWithNameReasonInnerExceptionUserInfo(exceptionName(), reason, exception, userInfo);

		return this;
	}

	private function initWithNameReasonUserInfo() {}

	private static function exceptionWithNameReasonUserInfo() {}
	private static function exceptionWithNameReasonInnerExceptionUserInfo() {}
}