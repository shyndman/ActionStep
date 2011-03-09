/* See LICENSE for copyright and terms of use */

import org.actionstep.ASConnection;
import org.actionstep.ASDebugger;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSObject;
import org.actionstep.rpc.ASConnectionProtocol;
import org.actionstep.rpc.ASPendingCall;
import org.actionstep.rpc.ASRpcConstants;
import org.actionstep.rpc.remoting.ASRemotingOperation;

/**
 * <p>Represents a Flash remoting service.</p>
 *
 * <p>This works in a very similar way to Macromedia's remoting classes.</p>
 *
 * <p>Timeouts can be set on remote method calls that will result in the
 * responder's {@link ASResponderProtocol#didEncounterError} being called
 * by using {@link #setTimeOut}.</p>
 *
 * @author Scott Hyndman
 */
dynamic class org.actionstep.rpc.remoting.ASRemotingService extends NSObject
		implements org.actionstep.rpc.ASService {

	//******************************************************
	//*                  Class members
	//******************************************************

	private static var g_services:NSDictionary;

	//******************************************************
	//*                 Member variables
	//******************************************************

	private var m_name:String;
	private var m_connection:ASConnection;
	private var m_tracingEnabled:Boolean;
	private var m_timeout:Number;
	private var m_defaultResponder:Object;

	//******************************************************
	//*                   Construction
	//******************************************************

	/**
	 * Constructs a new instance of the <code>ASService</code> class.
	 */
	public function ASService() {
		m_tracingEnabled = false;
	}

	/**
	 * <p>Initializes the service with the name <code>name</code> and the
	 * connection <code>connection</code>.</p>
	 *
	 * <p>This method will throw an {@link NSException} if <code>name</code>
	 * or <code>connection</code> is <code>null</code>.</p>
	 *
	 * <p>This method will throw an {@link NSException} if a service named
	 * <code>name</code> already exists for the gateway URL
	 * <code>connection</code>.</p>
	 */
	public function initWithNameConnection(name:String,
			connection:ASConnectionProtocol):ASRemotingService {
		//
		// Trace if necessary
		//
		if (m_tracingEnabled) {
			trace(ASDebugger.debug("Creating service for " + name + " on "
				+ connection.URL()));
		}

		//
		// Null check
		//
		if (null == name || null == connection) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"name and connection arguments must be non-null",
				null);
			trace(e);
			throw e;
		}

		//
		// Make sure it the connection is an ASConnection
		//
		if (!(connection instanceof ASConnection)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"connection must be an ASConnection instance",
				null);
			trace(e);
			throw e;
		}

		//
		// Name check
		//
		if (hasNamedService(connection.URL(), name)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSGeneric,
				"A service named " + name + " already exists for the gateway" +
				" URL " + connection.URL() + ".",
				null);
			trace(e);
			throw e;
		}

		m_name = name;
		m_connection = ASConnection(connection);

		//
		// Register service with name
		//
		g_services.setObjectForKey(this, connection.URL() + "::" + m_name);

		//
		// Trace if necessary
		//
		if (m_tracingEnabled) {
			trace(ASDebugger.debug("Service successfully created."));
		}

		//
		// Set default timeout
		//
		setTimeout(ASRpcConstants.ASNoTimeOut);

		return this;
	}

	/**
	 * <p>Initializes the service with the name <code>name</code> and the
	 * connection <code>connection</code>.</p>
	 *
	 * <p><code>tracing</code> specifies whether the service should trace out
	 * debug messages.</p>
	 *
	 * <p>This method will throw an {@link NSException} if <code>name</code>
	 * or <code>connection</code> is <code>null</code>.</p>
	 *
	 * <p>This method will throw an {@link NSException} if a service named
	 * <code>name</code> already exists.</p>
	 */
	public function initWithNameConnectionTracing(name:String,
			connection:ASConnectionProtocol, tracing:Boolean):ASRemotingService {
		m_tracingEnabled = tracing;
		return initWithNameConnection(name, connection);
	}

	/**
	 * <p>Initializes the service with the service name <code>name</code> and the
	 * gateway URL <code>url</code>.</p>
	 *
	 * <p>This method will throw an {@link NSException} if <code>name</code>
	 * or <code>url</code> is <code>null</code>.</p>
	 *
	 * <p>This method will throw an {@link NSException} if a service named
	 * <code>name</code> already exists.</p>
	 */
	public function initWithNameGatewayURL(name:String, url:String):ASRemotingService {
		//
		// Null check
		//
		if (null == name || null == url) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"name and url arguments must be non-null",
				null);
			trace(e);
			throw e;
		}

		//
		// Create connection
		//
		var conn:ASConnection = ASConnection.connectionForURL(url);
		if (conn == null) {
			conn = ASConnection((new ASConnection()).initWithURL(url));
		}

		return initWithNameConnection(name, conn);
	}

	/**
	 * <p>Initializes the service with the service name <code>name</code> and the
	 * gateway URL <code>url</code>.</p>
	 *
	 * <p><code>tracing</code> specifies whether the service should trace out
	 * debug messages.</p>
	 *
	 * <p>This method will throw an {@link NSException} if <code>name</code>
	 * or <code>url</code> is <code>null</code>.</p>
	 *
	 * <p>This method will throw an {@link NSException} if a service named
	 * <code>name</code> already exists.</p>
	 */
	public function initWithNameGatewayURLTracing(name:String, url:String,
			tracing:Boolean):ASRemotingService {
		m_tracingEnabled = tracing;
		return initWithNameGatewayURL(name, url);
	}

	//******************************************************
	//*               Describing the object
	//******************************************************

	/**
	 * Returns a string representation of the service.
	 */
	public function description():String {
		return "ASService(name=" + name() + ",connection=" + connection() + ")";
	}

	//******************************************************
	//*       Getting information about the service
	//******************************************************

	/**
	 * Returns the name of this connection.
	 */
	public function name():String {
		return m_name;
	}

	/**
	 * Returns the connection used by this service.
	 */
	public function connection():ASConnectionProtocol {
		return m_connection;
	}

	//******************************************************
	//*         Setting the default responder
	//******************************************************

	/**
	 * Returns the default responder. This is the object that is called by
	 * default to handle remote method call responses if no other responder is
	 * specified.
	 */
	public function defaultResponder():Object {
		return m_defaultResponder;
	}

	/**
	 * <p>Sets the default responder object to <code>responder</code>.</p>
	 *
	 * <p>This is the responder that is used by default on remote method calls if
	 * no other responder is specified.</p>
	 *
	 * <p>This object should at least partially implement the functions found in
	 * {@link org.actionstep.remoting.ASResponderProtocol}.</p>
	 */
	public function setDefaultResponder(responder:Object):Void {
		m_defaultResponder = responder;
	}

	//******************************************************
	//*                Setting timeouts
	//******************************************************

	/**
	 * <p>Returns the number in seconds before a remote method call is marked
	 * as being timed out.</p>
	 *
	 * <p>A value of {@link org.actionstep.rpc.#ASNoTimeOut} means
	 * there is no timeout used.</p>
	 */
	public function timeout():Number {
		return m_timeout;
	}

	/**
	 * <p>Sets the amount of time in seconds that will pass before a remote method
	 * call is marked as being timed out.</p>
	 *
	 * <p>This will only affect future server calls, and not calls that are in
	 * process.</p>
	 *
	 * <p>To disable timeouts, pass
	 * {@link org.actionstep.rpc.#ASNoTimeOut} to this method.</p>
	 */
	public function setTimeout(seconds:Number):Void {
		m_timeout = seconds;
	}

	//******************************************************
	//*                Enabling tracing
	//******************************************************

	/**
	 * <p>Returns <code>true</code> if tracing is enabled for this service.</p>
	 *
	 * <p>The default value is <code>false</code>.</p>
	 */
	public function isTracingEnabled():Boolean {
		return m_tracingEnabled;
	}

	/**
	 * Sets whether this service traces out messages for debugging purposes.
	 */
	public function setTracingEnabled(flag:Boolean):Void {
		m_tracingEnabled = flag;
	}

	//******************************************************
	//*               Calling remote methods
	//******************************************************

	/**
	 * This method is called when a method is called on the service.
	 */
	private function __resolve(methodName:String):Function {
		var op:ASRemotingOperation = (new ASRemotingOperation()).initWithNameService(
			methodName, this);

		var self:ASRemotingService = this;

		//
		// Create the function that will be invoked by the remote call.
		//
		var returnFunction:Function = function():ASPendingCall {
			return op.invokeWithArgsTimeoutResponder(arguments, self.timeout(),
				self.defaultResponder());
		};

		//
		// Set up the function so that resolve will not be called again.
		//
		this[methodName] = returnFunction;

		return returnFunction;
	}

	//******************************************************
	//*              Getting named services
	//******************************************************

	/**
	 * Returns <code>true</code> if a service named <code>name</code> exists.
	 */
	public static function hasNamedService(url:String, name:String):Boolean {
		return serviceForNameURL(name, url) != null;
	}

	/**
	 * Returns the service named <code>name</code> for the gateway URL
	 * <code>url</code>, or <code>null</code> if  no service exists with that
	 * name.
	 */
	public static function serviceForNameURL(name:String, url:String):ASRemotingService {
		return ASRemotingService(g_services.objectForKey(url + "::" + name));
	}

	//******************************************************
	//*                Class constructor
	//******************************************************

	/**
	 * Class constructor.
	 */
	private static function initialize():Boolean {
		if (g_classConstruct) {
			return true;
		}

		g_services = NSDictionary.dictionary();
	}

	private static var g_classConstruct:Boolean = false;
}