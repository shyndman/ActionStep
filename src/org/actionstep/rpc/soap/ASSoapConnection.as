/* See LICENSE for copyright and terms of use */

import org.actionstep.ASDebugger;
import org.actionstep.ASUtils;
import org.actionstep.NSDictionary;
import org.actionstep.NSNotificationCenter;
import org.actionstep.rpc.ASOperation;
import org.actionstep.rpc.soap.ASSoapOperation;
import org.actionstep.rpc.soap.ASSoapSerializer;
import org.actionstep.rpc.soap.ASSoapService;
import org.actionstep.rpc.soap.common.ASWsdlFile;
import org.actionstep.rpc.soap.common.ASWsdlParser;
import org.actionstep.rpc.xml.ASXmlConnection;
import org.actionstep.rpc.soap.ASSoapUtils;

/**
 * <p>
 * Represents a connection to a SOAP web service. This class is initialized
 * using the <code>#initWithURL(String)</code> method, where the argument 
 * represents the URL of the service's WSDL file. 
 * </p>
 * <p>
 * Please note that services will not be accessible until this connection's
 * WSDL file has loaded. The loading process begins automatically when the
 * connection is initialized using <code>#initWithURL(String)</code>. When the
 * WSDL file has completed loading (or failed to load), an 
 * <code>#ASWsdlFileDidLoadNotification</code> is posted to the default 
 * notification center.
 * </p>
 * 
 * @author Scott Hyndman
 */
class org.actionstep.rpc.soap.ASSoapConnection extends ASXmlConnection {
	
	//******************************************************
	//*                     Members
	//******************************************************
	
	private var m_wsdl:ASWsdlFile;
	private var m_xmlWsdl:XML;
	private var m_isLoading:Boolean;
	private var m_isLoaded:Boolean;
	
	//******************************************************
	//*                   Construction
	//******************************************************
	
	/**
	 * Creates a new instance of the <code>ASXmlConnection</code> class.
	 */
	public function ASSoapConnection() {
		m_isLoaded = false;
		m_isLoading = false;
	}

	/**
	 * <p>
	 * Initializes the connection with a connection string of <code>url</code>.
	 * </p>
	 * 
	 * <code>url</code> represents the URL of the SOAP service's WSDL file. This
	 * file will be read and parsed immediately, and the connection will post
	 * a
	 */
	public function initWithURL(url:String):ASSoapConnection {
		super.initWithURL(url);

		loadWsdlFile();

		return this;
	}
	
	//******************************************************
	//*             Describing the connection
	//******************************************************
	
	/**
	 * Returns a string representation of the ASSoapConnection instance.
	 */
	public function description():String {
		return "ASSoapConnection(url=" + m_url + ")";
	}
	
	//******************************************************
	//*                Getting load state
	//******************************************************
	
	/**
	 * <p>
	 * Returns <code>true</code> if this connection is loading this connection's
	 * WSDL file.
	 * </p>
	 * <p>
	 * <code>false</code> means that either loading has not begun 
	 * (<code>#isLoaded()</code> <code>false</code>) or that loading has
	 * completed successfully (<code>#isLoaded()</code> <code>true</code>).
	 * </p>
	 */
	public function isLoading():Boolean {
		return m_isLoading;
	}
	
	/**
	 * Returns <code>true</code> if this connection's WSDL file has finished
	 * loading.
	 */
	public function isLoaded():Boolean {
		return m_isLoaded;
	}
	
	//******************************************************
	//*            Getting service information
	//******************************************************
	
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
		return m_wsdl;
	}
	
	//******************************************************
	//*            Loading and parsing the WSDL
	//******************************************************
	
	/**
	 * Begins loading the WSDL file.
	 */
	private function loadWsdlFile():Void {
		m_isLoading = true;
		
		//
		// Set up
		//
		m_xmlWsdl = new XML();
		m_xmlWsdl.ignoreWhite = true;

		var self:ASXmlConnection = this;
		m_xmlWsdl.onLoad = function(success:Boolean):Void {
			try {
				self["wsdlDidLoad"](success);
			} catch (e:Error) {
				trace(e.toString());
			}
		};

		//
		// Perform call
		//
		m_xmlWsdl.load(URL());
	}
	
	/**
	 * Called when the WSDL file finishes loading.
	 */
	private function wsdlDidLoad(success:Boolean):Void {
		//
		// Flag as not loading
		//
		m_isLoading = false;
		
		//
		// Parse XML file
		//
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		if (success) {
			//
			// Parse the XML file
			//
			try {
				m_wsdl = ASWsdlParser.instance().createWsdlFromXml(m_xmlWsdl);
				m_wsdl.isRootWsdl = true;
				
				if (m_wsdl.unresolvedImports == 0) {
					parseWsdlFile();
				} else {
					nc.addObserverSelectorNameObject(this, "parseWsdlFile",
						ASWsdlFileDidLoadNotification, m_wsdl);
				}
				
				return;
			} catch (e:Error) {
				//
				// Error encountered. Post notification and throw error
				//
				m_xmlWsdl = null;
				nc.postNotificationWithNameObjectUserInfo(
					ASWsdlFileDidLoadNotification,
					this,
					NSDictionary.dictionaryWithObjectForKey(false, "ASLoadSuccess"));
				trace(e);
				throw e;
			}
		} else {
			trace(ASDebugger.fatal("WSDL at URL " + URL() + " failed to load"));
		}
				
		//
		// Change loaded state
		//
		m_isLoaded = success;
		
		//
		// Post the notification
		//
		nc.postNotificationWithNameObjectUserInfo(
			ASWsdlFileDidLoadNotification,
			this,
			NSDictionary.dictionaryWithObjectForKey(success, "ASLoadSuccess"));
	}
	
	/**
	 * Parses the WSDL file when it is fully loaded.
	 */
	private function parseWsdlFile():Void {
		var nc:NSNotificationCenter = NSNotificationCenter.defaultCenter();
		nc.removeObserverNameObject(this, ASWsdlFileDidLoadNotification,
			m_wsdl);
			
		try {
			m_wsdl = ASWsdlParser.instance().parseWsdlXml(m_wsdl, m_xmlWsdl);
			m_xmlWsdl = null;
		} catch (e:Error) {
			//
			// Error encountered. Post notification and throw error
			//
			m_xmlWsdl = null;
			nc.postNotificationWithNameObjectUserInfo(
				ASWsdlFileDidLoadNotification,
				this,
				NSDictionary.dictionaryWithObjectForKey(false, "ASLoadSuccess"));
			trace(e);
			throw e;
		}
		
		
		//
		// Change loaded state
		//
		m_isLoaded = true;
		
		//
		// Post the notification
		//
		nc.postNotificationWithNameObjectUserInfo(
			ASWsdlFileDidLoadNotification,
			this,
			NSDictionary.dictionaryWithObjectForKey(true, "ASLoadSuccess"));
	}
	
	//******************************************************
	//*     Performing operations with the connection
	//******************************************************

	/**
	 * Returns the URL for the specified remote method. This method can be
	 * overridden to provide specific functionality.
	 */
	private function urlForMethod(remoteMethod:ASOperation):String {
		return ASSoapService(remoteMethod.service()).portURL();
	}
	
	/**
	 * Gives subclasses an opportunity to add request headers or modify the
	 * contents of the request.
	 */
	private function prepareRequest(request:XML, remoteMethod:ASOperation):Void {
		var meth:ASSoapOperation = ASSoapOperation(remoteMethod);
		request.addRequestHeader("SOAPAction", "\"" 
			+ meth.soapAction() + "\"");
	}
	
	//******************************************************
	//*                  Event handlers
	//******************************************************

	/**
	 * Fired when the XML-RPC call finishes.
	 */
	private function connectionOnLoad(success:Boolean, callID:Number):Void {
		//
		// Get call object and remove it from the pending set
		//
		var callObj:Object = m_pendingCalls.objectForKey(callID.toString());
		m_pendingCalls.removeObjectForKey(callID.toString());

		//
		// Deal with call properties
		//
		var response:XML = callObj.xml;
		callObj.xml = null;
		response.onLoad = null;
				
		var responder:Object = callObj.responder;
		callObj.responder = null;
		
		var method:ASSoapOperation = callObj.method;
		callObj.method = null;
		
		//
		// Decrease the call count
		//
		ASSoapService(method.service())._decreaseCallCount();
		
		//
		// Server failure
		//
		if (!success) {
			connectionOnStatus(null);
			return;
		}
		
		//
		// Deserialize fault or response
		//
		var serializer:ASSoapSerializer = ASSoapSerializer.instance();
		if (ASSoapUtils.isFaultResponse(response)) {
			var fault:Object = serializer.deserializeFaultWithWsdlXml(
				m_wsdl, response);
			connectionOnStatus(fault);
			responder.onStatus(fault);
		} else {
			var res:Object = serializer.deserializeResponseWithOperationWsdlXml(
				method, m_wsdl, response);
			connectionOnResult(res);
			responder.onResult(res);
		}

//		var xmlString:String = response.toString();
//		xmlString = xmlString.split("<").join("&lt;");
//		xmlString = xmlString.split(">").join("&gt;");
//		trace(ASDebugger.debug("RPC XML: " + xmlString));
	}
	
	//******************************************************
	//*                   Notifications
	//******************************************************
	
	/**
	 * <p>
	 * Posted to the default notification center when a SOAP connection's
	 * WSDL file finishes loading.
	 * </p>
	 * <p>
	 * The WSDL file begins loading when the connection is initialized using
	 * <code>#initWithURL(String)</code>. 
	 * </p>
	 * <p>
	 * The user info dictionary contains:
	 *   "ASLoadSuccess": true if the image loaded successfully. (Boolean)
	 * </p>
	 */
	public static var ASWsdlFileDidLoadNotification:Number 
		= ASUtils.intern("ASWsdlFileDidLoad");
}