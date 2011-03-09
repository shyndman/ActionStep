/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.ASUtils;
import org.actionstep.NSDictionary;
import org.actionstep.NSException;
import org.actionstep.NSNotification;
import org.actionstep.NSNotificationCenter;
import org.actionstep.NSObject;
import org.actionstep.rpc.ASConnectionProtocol;
import org.actionstep.rpc.ASPendingCall;
import org.actionstep.rpc.ASRpcConstants;
import org.actionstep.rpc.ASService;
import org.actionstep.rpc.soap.ASSoapConnection;
import org.actionstep.rpc.soap.ASSoapDataType;
import org.actionstep.rpc.soap.ASSoapOperation;
import org.actionstep.rpc.soap.common.ASWsdlBinding;
import org.actionstep.rpc.soap.common.ASWsdlFile;
import org.actionstep.rpc.soap.common.ASWsdlMessage;
import org.actionstep.rpc.soap.common.ASWsdlMessagePart;
import org.actionstep.rpc.soap.common.ASWsdlOperation;
import org.actionstep.rpc.soap.common.ASWsdlPort;
import org.actionstep.rpc.soap.common.ASWsdlPortType;
import org.actionstep.rpc.soap.common.ASWsdlService;
import org.actionstep.rpc.xml.ASXmlConnection;

/**
 * <p>
 * A SOAP service. This class is used to call remote methods.
 * </p>
 * <p>
 * Remote methods cannot be called until the service is marked as loaded. This
 * can be tested by using the <code>#isLoaded()</code> property. If you have
 * just created the service with a brand new connection, you may wish to
 * observe the service for <code>#ASSoapServiceDidLoadNotification</code>
 * notifications.
 * </p>
 * 
 * @author Scott Hyndman
 */
dynamic class org.actionstep.rpc.soap.ASSoapService extends NSObject 
		implements ASService {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private static var g_services:NSDictionary;

	private var m_name:String;
	private var m_connection:ASSoapConnection;
	private var m_portName:String;
	private var m_methods:NSDictionary;
	private var m_tracingEnabled:Boolean;
	private var m_timeout:Number;
	private var m_defaultResponder:Object;
	private var m_portURL:String;
	private var m_multipleSimulataneousAllowed:Boolean;
	private var m_callsInProgress:Number;
	
	//******************************************************
	//*                  Construction
	//******************************************************

	/**
	 * Creates a new instance of the <code>ASSoapService</code> class.
	 */
	public function ASSoapService() {
		m_methods = NSDictionary.dictionary();
		m_tracingEnabled = false;
		m_portName = null;
		m_defaultResponder = null;
		m_callsInProgress = 0;
		m_multipleSimulataneousAllowed = true;
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
			connection:ASConnectionProtocol):ASSoapService {
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
		// Make sure it the connection is an ASSoapConnection
		//
		if (!(connection instanceof ASSoapConnection)) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInvalidArgument,
				"connection must be an ASXmlRpcConnection instance",
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
		m_connection = ASSoapConnection(connection);

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

		//
		// Populate method table if possible
		//
		_populateMethodTable();

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
			connection:ASConnectionProtocol, tracing:Boolean):ASSoapService {
		m_tracingEnabled = tracing;
		return initWithNameConnection(name, connection);
	}
	
	/**
	 * <p>Initializes the service with the name <code>name</code> and the
	 * connection <code>connection</code>.</p>
	 *
	 * <p><code>tracing</code> specifies whether the service should trace out
	 * debug messages.</p>
	 * 
	 * <p><code>portName</code> specifies the name of the SOAP port that should
	 * be used. The default is to use the first in the service.</p>
	 *
	 * <p>This method will throw an {@link NSException} if <code>name</code>
	 * or <code>connection</code> is <code>null</code>.</p>
	 *
	 * <p>This method will throw an {@link NSException} if a service named
	 * <code>name</code> already exists.</p>
	 */
	public function initWithNameConnectionPortNameTracing(name:String,
			connection:ASConnectionProtocol, portName:String, tracing:Boolean):ASSoapService {
		m_portName = portName;
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
	public function initWithNameGatewayURL(name:String, url:String):ASSoapService {
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
		var conn:ASXmlConnection = (new ASSoapConnection()).initWithURL(url);
		return initWithNameConnection(name, conn);
	}

	/**
	 * <p>Initializes the service with the service name <code>name</code> and the
	 * gateway URL <code>url</code>.</p>
	 *
	 * <p><code>tracing</code> specifies whether the service should trace out
	 * debug messages.</p>
	 * 
	 * <p><code>portName</code> specifies the name of the SOAP port that should
	 * be used. The default is to use the first in the service.</p>
	 *
	 * <p>This method will throw an {@link NSException} if <code>name</code>
	 * or <code>url</code> is <code>null</code>.</p>
	 *
	 * <p>This method will throw an {@link NSException} if a service named
	 * <code>name</code> already exists.</p>
	 */
	public function initWithNameGatewayURLPortNameTracing(name:String, url:String,
			portName:String, tracing:Boolean):ASSoapService {
		m_tracingEnabled = tracing;
		m_portName = portName;
		return initWithNameGatewayURL(name, url);
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
			tracing:Boolean):ASSoapService {
		m_tracingEnabled = tracing;
		return initWithNameGatewayURL(name, url);
	}
	
	//******************************************************
	//*       Getting information about the service
	//******************************************************

	/**
	 * Returns the name of this service.
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
	
	/**
	 * Returns the name of the SOAP port used by this service. If 
	 * <code>null</code> is returned, the first port in the service is used.
	 */
	public function portName():String {
		return m_portName;
	}
	
	/**
	 * <p>
	 * Returns this connection's WSDL file, or <code>null</code> if the file
	 * has not yet been loaded.
	 * </p>
	 * <p>
	 * The WSDL file describes available methods and types in the SOAP service.
	 * It is intended to be used internally.
	 * </p>
	 */
	public function wsdlFile():ASWsdlFile {
		return m_connection.wsdlFile();
	}

	/**
	 * <p>
	 * Returns <code>true</code> if the service is loaded. If it isn't, remote
	 * methods will not be available.
	 * </p>
	 * <p>
	 * If you want to be notified when the service becomes available, observe
	 * the service for a <code>#ASSoapServiceDidLoadNotification</code>.
	 * </p>
	 */
	public function isLoaded():Boolean {
		return m_connection.isLoaded();
	}
	
	/**
	 * <p>
	 * Returns <code>true</code> if more than one SOAP operation can be
	 * executed simulataneously.
	 * </p>
	 * <p>
	 * The default is <code>true</code>.
	 * </p>
	 * <p>
	 * If false, and a call is made while another call is in progress, an
	 * <code>#ASSoapCallAlreadyInProgressNotification</code> is posted to
	 * the default notification center.
	 * </p>
	 */
	public function multipleSimulataneousAllowed():Boolean {
		return m_multipleSimulataneousAllowed;
	}
	
	/**
	 * <p>
	 * Sets whether more than one SOAP operation can be executed simulataneously. 
	 * </p>
	 * <p>
	 * If false, and a call is made while another call is in progress, an
	 * <code>#ASSoapCallAlreadyInProgressNotification</code> is posted to
	 * the default notification center.
	 * </p>
	 */
	public function setMultipleSimulataneousAllowed(flag:Boolean):Void {
		m_multipleSimulataneousAllowed = flag;
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
	//*              Setting up remote methods
	//******************************************************

	/**
	 * Returns the remote operations of this service.
	 */
	public function remoteOperations():NSDictionary {
		return m_methods;
	}

	/**
	 * Returns the remote operation named <code>name</code> or null if no method
	 * exists with that name.
	 */
	public function getRemoteOperationWithName(name:String):ASSoapOperation {
		return ASSoapOperation(m_methods.objectForKey(name));
	}
	
	//******************************************************
	//*           Getting the service port URL
	//******************************************************
	
	/**
	 * <p>
	 * Returns the URL of this service's port. For internal use only.
	 * </p>
	 */
	public function portURL():String {
		return m_portURL;
	}
	
	//******************************************************
	//*               Calling remote methods
	//******************************************************

	/**
	 * This method is called when a method is called on the service.
	 */
	private function __resolve(methodName:String):Function {
		//
		// Throw exception if no WSDL is loaded
		//
		if (!m_connection.isLoaded()) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"SOAP services cannot be called until their connection's "
				+ "WSDL files are loaded. See ASSoapConnection's class docs "
				+ "for more details.",
				null);
			trace(e);
			throw e;
		}
		
		var op:ASSoapOperation = getRemoteOperationWithName(methodName);
		trace(op);
		
		//
		// Throw exception
		//
		if (op == null) {
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"SOAP service named " + m_name + " on connection at "
					+ m_connection.URL() + "cannot find an operation named " 
					+ methodName,
				null);
			trace(e);
			throw e;
		}

		//
		// Check if a call is already in progress
		//
		if (!m_multipleSimulataneousAllowed && m_callsInProgress == 1) {
			if (m_tracingEnabled) {
				trace(ASDebugger.debug("Call already in progress. Cannot call "
					+ op.fullName()));
			}
			
			NSNotificationCenter.defaultCenter().postNotificationWithNameObject(
					ASSoapCallAlreadyInProgressNotification,
					this);
			
			return function() {};
		}		


		m_callsInProgress++;
		
		var self:ASSoapService = this;

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
	//*                 Helper methods
	//******************************************************
	
	/**
	 * <p>
	 * Pulls method information from the connection's WSDL file. If the
	 * connection has not yet loaded, the service will begin watching the
	 * connection for a load notification.
	 * </p>
	 */
	private function _populateMethodTable(ntf:NSNotification):Void {
		//
		// Clean up notification stuff
		//
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		nc.removeObserverNameObject(this, 
			ASSoapConnection.ASWsdlFileDidLoadNotification, m_connection);
			
		//
		// Observe connection
		//
		if (!m_connection.isLoaded()) {
			if (m_tracingEnabled) {
				trace(ASDebugger.debug("WSDL not yet loaded. Begin observing"));
			}
			
			nc.addObserverSelectorNameObject(this, "_populateMethodTable",
				ASSoapConnection.ASWsdlFileDidLoadNotification, m_connection);
			return;
		} else {
			if (m_tracingEnabled) {
				trace(ASDebugger.debug("WSDL loaded. populating method table"));
			}
		}
		
		//
		// Check for failure
		//
		if (ntf != null && !Boolean(ntf.userInfo.objectForKey("ASLoadSuccess"))) {
			trace(ASDebugger.fatal("Service connection failed to load - " 
				+ m_connection.URL()));
			
			return;
		}
		
		//
		// Get service
		//
		var wsdl:ASWsdlFile = m_connection.wsdlFile();
		var service:ASWsdlService = wsdl.serviceWithNameDefault(m_name, true);
		
		//
		// Trace warning if service name different
		//
		if (service.name != m_name) {
			trace(ASDebugger.error("WSDL service named " + m_name 
				+ " not found in WSDL file at " + m_connection.URL() 
				+ "\nUsing default service")); 
		}
		
		//
		// Trace status message
		//
		if (m_tracingEnabled) {
			trace(ASDebugger.debug("Using methods from WSDL service " 
				+ service.name));
		}
		
		//
		// Get port
		//
		var port:ASWsdlPort = service.portWithNameDefault(m_portName, true);

		//
		// Trace warning if unexpected port
		//
		if (m_portName != null && m_portName != port.name) {
			trace(ASDebugger.error("WSDL service named " + m_name 
				+ " at " + m_connection.URL() + " could not find port named "
				+ m_portName + "\nUsing default service")); 
		}
		
		if (port == null) { // no port found
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"SOAP service " + m_name + " on connection " 
					+ m_connection.URL() + " could not obtain a port" 
					+ (m_portName == null ? "" : " (named: " + m_portName + ")"),
				null);
			trace(e);
			throw e;
		}
		m_portURL = port.address;
		
		//
		// Get binding
		//
		var binding:ASWsdlBinding = wsdl.bindingWithName(port.bindingName);
		if (binding == null) { // no binding found
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"SOAP service " + m_name + " on connection " 
					+ m_connection.URL() + " could not obtain the binding named " 
					+ port.bindingName, 
				null);
			trace(e);
			throw e;
		}
		
		//
		// Get binding's port type
		//
		var portType:ASWsdlPortType = wsdl.portTypeWithName(binding.typeName);
		if (portType == null) { // no binding found
			var e:NSException = NSException.exceptionWithNameReasonUserInfo(
				NSException.NSInternalInconsistency,
				"SOAP service " + m_name + " on connection " 
					+ m_connection.URL() + " could not obtain the portType named " 
					+ binding.typeName, 
				null);
			trace(e);
			throw e;
		}
		
		//
		// Create operations for each binding operation
		//
		var ops:Array = binding.operations.allValues().internalList();
		var len:Number = ops.length;
		for (var i:Number = 0; i < len; i++) {
			var bindOp:ASWsdlOperation = ops[i];
			var ptOp:ASWsdlOperation = portType.operationWithName(bindOp.name);
			var op:ASSoapOperation = (new ASSoapOperation()).initWithNameServiceSoapActionStyle(
				bindOp.name, this, bindOp.soapOperation.soapAction, bindOp.soapOperation.style);
			
			//
			// Setting use
			//
			op.setInputOutputUse(ptOp.input.body.use, ptOp.output.body.use);
			
			//
			// Examine the input, adding parts as operation parameters
			//
			var input:ASWsdlMessage = wsdl.messageWithName(ptOp.input.messageName);
			var parts:Array = input.parts;
			var len2:Number = parts.length;
						
			for (var j:Number = 0; j < len2; j++) {
				var p:ASWsdlMessagePart = parts[j];
				var dataType:ASSoapDataType;
								
				if (p.typeName != null) {
					dataType = wsdl.typeWithName(p.typeName);
				} else { // p.elementName != null
					dataType = wsdl.elementWithName(p.elementName);	
				}
				
				p.type = dataType;
				op.addParameter(p);
			}
			
			//
			// Examine the output
			//
			var output:ASWsdlMessage = wsdl.messageWithName(ptOp.output.messageName);
			parts = output.parts;
			len2 = parts.length;
			for (var j:Number = 0; j < len2; j++) {
				var p:ASWsdlMessagePart = parts[j];
				var dataType:ASSoapDataType;
								
				if (p.typeName != null) {
					dataType = wsdl.typeWithName(p.typeName);
				} else { // p.elementName != null
					dataType = wsdl.elementWithName(p.elementName);	
				}
				
				p.type = dataType;
				op.addReturnType(p);
			}

			//
			// Add the method
			//
			if (m_tracingEnabled) {
				trace(ASDebugger.debug("Adding method to service " + m_name 
					+ ": " + op.toString()));
			}
			m_methods.setObjectForKey(op, op.name());
		}
		
		//
		// Trace success method
		//
		if (m_tracingEnabled) {
			trace(ASDebugger.debug("Method table finished populating for "
				+ "service named " + m_name));
		}
		
		nc.postNotificationWithNameObject(ASSoapServiceDidLoadNotification,
			this);
	}
	
	/**
	 * Decreases the call count. For internal use only.
	 */
	public function _decreaseCallCount():Void {
		m_callsInProgress--;
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
	public static function serviceForNameURL(name:String, url:String):ASSoapService {
		return ASSoapService(g_services.objectForKey(url + "::" + name));
	}
	
	//******************************************************
	//*                 Notifications
	//******************************************************
	
	/**
	 * Posted when the service finishes loading, and remote methods are
	 * available.
	 */
	public static var ASSoapServiceDidLoadNotification:Number
		= ASUtils.intern("ASSoapServiceDidLoad");
		
	/**
	 * Posted when simultaneous calls are not allowed, and a call is made.
	 */
	public static var ASSoapCallAlreadyInProgressNotification:Number
		= ASUtils.intern("ASSoapCallAlreadyInProgress");

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
		g_classConstruct = true;
	}

	private static var g_classConstruct:Boolean = false;
}