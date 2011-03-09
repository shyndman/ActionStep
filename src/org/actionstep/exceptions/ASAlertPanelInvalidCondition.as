/* See LICENSE for copyright and terms of use */

import org.actionstep.NSException;
import org.actionstep.NSDictionary;
import org.actionstep.exceptions.ASBaseException;

/**
 * @author Tay Ray Chuan
 */

class org.actionstep.exceptions.ASAlertPanelInvalidCondition extends ASBaseException {

	private function exceptionName():String {
		return "ASAlertPanelInvalidCondition";
	}

	public static function exceptionWithReasonUserInfo(
		reason:String, userInfo:NSDictionary):ASAlertPanelInvalidCondition {
		return ASAlertPanelInvalidCondition(
		(new ASAlertPanelInvalidCondition()).initWithReasonInnerExceptionUserInfo(
			reason, null, userInfo));
	}

	public static function exceptionWithReasonInnerExceptionUserInfo(
		reason:String, exception:NSException,
		userInfo:NSDictionary):ASAlertPanelInvalidCondition {
		return ASAlertPanelInvalidCondition(
		(new ASAlertPanelInvalidCondition()).initWithReasonInnerExceptionUserInfo(
			reason, exception, userInfo));
	}
}