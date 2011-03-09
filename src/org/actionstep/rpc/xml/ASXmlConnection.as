/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.ASUtils;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.rpc.ASConnectionProtocol;
import org.actionstep.rpc.ASFault;
import org.actionstep.rpc.ASOperation;
import org.actionstep.rpc.xml.ASXmlOperation;

/**
 * Abstract connection class used for SOAP and XML-RPC.
 *
 * @author Scott Hyndman
 */
class org.actionstep.rpc.xml.ASXmlConnection extends NSObject
		implements ASConnectionProtocol {

	//******************************************************
	//*                     Members
	//******************************************************

	private var m_xml:XML;
	private var m_url:String;
	private var m_delegate:Object;
	private var m_pendingCalls:NSDictionary;
	private var m_callCounter:Number;
	
	//******************************************************
	//*                   Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>ASXmlConnection</code> class.
	 */
	public function ASXmlConnection() {
		m_pendingCalls = NSDictionary.dictionary();
		m_callCounter = 0;
	}

	/**
	 * Initializes the connection with a connection string of <code>url</code>.
	 */
	public function initWithURL(url:String):ASXmlConnection {

		m_url = url;

		return this;
	}

	//******************************************************
	//*            Getting a URL information
	//******************************************************

	/**
	 * Returns the url of this connection, or <code>null</code> if none
	 * exists.
	 */
	public function URL():String {
		return m_url;
	}

	/**
	 * Returns the protocol of this connection's url, or <code>null</code> if
	 * the connection does not have a url or if no protocol is specified by
	 * the url.
	 */
	public function protocol():String {
		return ASUtils.protocolOfURL(URL());
	}

	/**
	 * Returns the port of this connection's url, or <code>null</code> if
	 * the connection does not have a url or if no port is specified by
	 * the url.
	 */
	public function port():Number {
		return ASUtils.portOfURL(URL());
	}

	//******************************************************
	//*               Setting the delegate
	//******************************************************

	/**
	 * Returns the connector's delegate or <code>null</code> if none exists.
	 */
	public function delegate():Object {
		return m_delegate;
	}

	/**
	 * Sets the delegate of the connection to <code>delegate</code>.
	 *
	 * A delegate can choose to implement the following methods to respond
	 * to the connector's events:
	 *
	 * connectionHandleStatus(Object):Void
	 * connectionHandleResult(Object):Void
	 */
	public function setDelegate(delegate:Object):Void {
		m_delegate = delegate;
	}

	//******************************************************
	//*     Performing operations with the connection
	//******************************************************

	/**
	 * Closes the connection.
	 */
	public function close():Void {
		// do nothing
	}

	/**
	 * <p>
	 * The default implementation of this method asks the remote method object
	 * for its request XML (<code>ASXmlOperation#getXmlWithArgs()</code>) and
	 * performs a requestXML.sendAndLoad() call.
	 * </p>
	 * <p>
	 * <code>ASXmlConnection#connectionOnLoad(Boolean, Number)</code> is called
	 * when the response finishes loading.
	 * </p>
	 */
	public function call(remoteMethod:ASOperation, responder:Object
			/*, ...*/):Void {
		//
		// Make sure the method is an XML-RPC operation
		//
		var meth:ASXmlOperation = ASXmlOperation(remoteMethod);
		if (meth == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"remoteMethod argument must be an instance of ASXmlOperation",
				null);
			trace(e);
			throw e;
		}

		//
		// Set up
		//
		var response:XML = new XML();
		response.ignoreWhite = true;

		var callID:Number = m_callCounter++;
		var callObj:Object = {xml: response, responder: responder, ID: callID, 
			method: meth};
		m_pendingCalls.setObjectForKey(callObj, callID.toString());

		var self:ASXmlConnection = this;
		response.onLoad = function(success:Boolean):Void {
			try {
				self["connectionOnLoad"](success, callID);
			} catch (e:Error) {
				trace(e.toString());
			}
		};

		//
		// Perform call
		//
		var request:XML = meth.getXmlWithArgs(arguments.slice(2));
		prepareRequest(request, meth);
				
		if (meth.service().isTracingEnabled()) {
			trace("SOAP request for " + meth + ":\n" + ASDebugger.dump(request));
		}
				
		request.sendAndLoad(urlForMethod(meth), response);
	}

	/**
	 * Returns the URL for the specified remote method. This method can be
	 * overridden to provide specific functionality.
	 */
	private function urlForMethod(remoteMethod:ASOperation):String {
		return URL();
	}
	
	/**
	 * Gives subclasses an opportunity to add request headers or modify the
	 * contents of the request.
	 */
	private function prepareRequest(request:XML, remoteMethod:ASOperation):Void {
		
	}

	//******************************************************
	//*                 Responding to events
	//******************************************************

	/**
	 * Fired when the internal <code>NetConnection</code> receieves a status
	 * event.
	 */
	private function connectionOnStatus(infoObject:Object):Void {
		if (infoObject == null) {
			infoObject = (new ASFault()).initWithContentsOfFault(
				{
					detail: "Server not found or unexpected termination on " +
						"server (parse error?)",
					faultcode: "SERVER.ERROR",
					type: "Unknown",
					faultstring: "Server returned <null>"
				});
			trace(asFatal(infoObject));
		}

		if (m_delegate == null
				|| !ASUtils.respondsToSelector(m_delegate, "connectionHandleStatus")) {
			return;
		}

		try {
			m_delegate.connectionHandleStatus(infoObject);
		} catch (e:Error) {
			trace(asError(e));
		}
	}

	/**
	 * Fired when the internal <code>NetConnection</code> receieves a result
	 * event.
	 */
	private function connectionOnResult(infoObject:Object):Void {
		if (m_delegate == null
				|| !ASUtils.respondsToSelector(
				m_delegate, "connectionHandleResult")) {
			return;
		}

		try {
			m_delegate.connectionHandleResult(infoObject);
		} catch (e:Error) {
			trace(asError(e));
		}
	}
}