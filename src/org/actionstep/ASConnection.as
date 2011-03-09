/* See LICENSE for copyright and terms of use */

import org.actionstep.ASUtils;
import org.actionstep.NSArray;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.rpc.ASConnectionProtocol;
import org.actionstep.rpc.ASFault;
import org.actionstep.rpc.ASOperation;

/**
 * This class is used to represent a connection to any server that supports the
 * AMF protocol. This includes a Flash Remoting server, Red5 and Flash Comm
 * Server.
 *
 * This is a wrapper around the <code>NetConnection</code> class.
 *
 * @see org.actionstep.NSMovie
 * @see org.actionstep.remoting.ASService
 * @author Scott Hyndman
 */
class org.actionstep.ASConnection extends NSObject implements ASConnectionProtocol {

	//******************************************************
	//*                  Class members
	//******************************************************

	private static var g_connections:NSDictionary;

	//******************************************************
	//*                 Member variables
	//******************************************************

	private var m_connection:NetConnection;
	private var m_url:String;
	private var m_delegate:Object;
	private var m_callResponder:Object;

	//******************************************************
	//*                   Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>ASConnection</code> class.
	 *
	 * Construction should be followed by a call to one of the initializers.
	 */
	public function ASConnection() {
		//
		// Set up internal connection object
		//
		m_connection = new NetConnection();

		//! TODO make sure this doesn't hold the reference to the object even
		// after it goes out of scope. We don't want a memory leak.
		var self:ASConnection = this;
		m_connection.onStatus = function(infoObject:Object) {
			self["connectionOnStatus"](infoObject);
		};

		m_connection.onResult = function(infoObject:Object) {
			self["connectionOnResult"](infoObject);
		};
	}

	/**
	 * Initializes the connection with a <code>null</code> connection string.
	 */
	public function init():ASConnection {
		m_url = null;
		m_connection.connect(null);
		return this;
	}

	/**
	 * Initializes the connection with a connection string of <code>url</code>.
	 */
	public function initWithURL(url:String):ASConnection {
		//
		// Name check
		//
		if (null != url && !hasConnectionForURL(url)) {
			g_connections.setObjectForKey(this, url);
		}

		m_url = url;
		m_connection.connect(url);

		return this;
	}

	/**
	 * Initializes the connection with a netconnection object. 
	 */
	public function initWithConnection(connection:NetConnection):ASConnection {
		m_connection = connection;
		m_url = m_connection.uri;
		
		return this;
	}
	
	//******************************************************
	//*              Describing the object
	//******************************************************

	/**
	 * Returns a string representation of the connection.
	 */
	public function description():String {
		return "ASConnection(URL=" + URL() + ")";
	}

	//******************************************************
	//*          Getting the internal connection
	//******************************************************

	/**
	 * Returns the <code>NetConnection</code> object that is used internally
	 * by this class instance.
	 *
	 * This method is for internal use only.
	 */
	public function internalConnection():NetConnection {
		return m_connection;
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
	//*                 Connection headers
	//******************************************************

	/**
	 * Sets the credentials of this application to <code>userName</code> and
	 * <code>password</code>. These values will be sent with all requests over
	 * this connection.
	 */
	public function setCredentials(userName:String, password:String):Void {
		addHeaderWithNameValueMustUnderstand("Credentials",
			{userid: userName, password: password}, false);
	}

	/**
	 * Adds a header that will be included with every AMF packet over this
	 * connection. <code>name</code> is the name of the header.
	 * <code>mustUnderstand</code> specifies whether the server is required
	 * to understand and process this header. <code>obj</code> contains the
	 * values for the header.
	 *
	 * This is typically not used directly.
	 */
	public function addHeaderWithNameValueMustUnderstand(name:String,
			obj:Object, mustUnderstand:Boolean):Void {
		m_connection.addHeader(name, mustUnderstand, obj);
	}

	//******************************************************
	//*     Performing operations with the connection
	//******************************************************

	/**
	 * Closes the connection.
	 */
	public function close():Void {
		m_connection.close();
	}

	/**
	 * Invokes a remote method with the name <code>remoteMethod</code>.
	 * <code>responder</code> is the object that will respond to the call.
	 */
	public function call(remoteMethod:ASOperation, responder:Object
			/*, ...*/):Void {
		var args:Array = arguments;
		args[0] = remoteMethod.fullName();
		m_callResponder = responder;
		m_connection.call.apply(m_connection, args);
	}

	//******************************************************
	//*               Responding to events
	//******************************************************

	/**
	 * Fired when the internal <code>NetConnection</code> receieves a status
	 * event.
	 */
	private function connectionOnStatus(infoObject:Object):Void {
		if(infoObject == null) {
			m_callResponder["onStatus"]({
					detail: "Either server not found or unexpected termination on server (parse error?)",
					faultcode: "SERVER.ERROR",
					type: "Unknown",
					faultstring: "Server returned 'null'"
				});
		}

		if (m_delegate == null
				|| !ASUtils.respondsToSelector(
				m_delegate, "connectionHandleStatus")) {
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

	//******************************************************
	//*             Getting named connections
	//******************************************************

	/**
	 * Returns <code>true</code> if there is a connection with the url
	 * <code>url</code>.
	 */
	public static function hasConnectionForURL(url:String):Boolean {
		return connectionForURL(url) != null;
	}

	/**
	 * Returns the connection with the URL <code>url</code>, or
	 * <code>null</code> if no connection exists with the url.
	 */
	public static function connectionForURL(url:String):ASConnection {
		return ASConnection(g_connections.objectForKey(url));
	}

	//******************************************************
	//*             Getting all NSConnections
	//******************************************************

	/**
	 * Returns all named connections (connections with URLs) used by the
	 * application.
	 */
	public static function allConnections():NSArray {
		return g_connections.allValues();
	}

	//******************************************************
	//*               Static Constructor
	//******************************************************

	/**
	 * Runs when the application begins.
	 */
	private static function classConstruct():Boolean {
		if (classConstructed)
			return true;

		g_connections = NSDictionary.dictionary();

		return true;
	}

	private static var classConstructed:Boolean = classConstruct();
}