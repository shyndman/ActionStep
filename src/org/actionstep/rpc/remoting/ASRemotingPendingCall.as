/* See LICENSE for copyright and terms of use */

import org.actionstep.NSException;
import org.actionstep.rpc.ASPendingCall;
import org.actionstep.rpc.ASService;
import org.actionstep.rpc.remoting.ASRecordSet;
import org.actionstep.rpc.remoting.ASRemotingService;

/**
 * Introduces recordset functionality into the pending call.
 *
 * @author Scott Hyndman
 */
class org.actionstep.rpc.remoting.ASRemotingPendingCall extends ASPendingCall {

	//******************************************************
	//*                  Event handlers
	//******************************************************

	private function onResult(result:Object):Void {
		//
		// Map the datatypes
		//
		result = mapDataTypes(result, operation().service());
		super.onResult(result);
	}

	//******************************************************
	//*            RecordSet related functions
	//******************************************************

	private function mapDataTypes(result:Object, service:ASService):Object {
		var tmp:Object = [result];
		try {
			//!FIXME try mapping many classes
			__mapDataTypes(tmp, service);
		} catch(e:NSException) {
			trace(e);
			trace(e.message);
		} finally {
			return tmp[0];
		}
	}

	private function __mapDataTypes(result:Object, service:ASService):Void {
		try {
			switch(result.constructor) {
				//ignore all others
				case Array:
				case Object:

		for(var i:String in result) {
			if(ASRecordSet.isRecognizedType(result[i])) {
				result[i] = Object((new ASRecordSet()).
					initWithResponseForService(result[i],
					ASRemotingService(service)));
			} else {
				__mapDataTypes(result[i], service);
			}
		}
				break;
			}
		} catch(e:NSException) {
			trace(e.message);
		}
	}
}